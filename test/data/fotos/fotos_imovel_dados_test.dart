import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/fotos_imovel_datasource.dart';
import 'package:imoveis_aqui/data/datasources/fotos_imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/models/foto_imovel_model.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/data/repositories/fotos_imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/foto_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/repositories/fotos_imovel_repository.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/api_falsa.dart';
import '../../support/armazenamento_token_em_memoria.dart';

class _DataSourceFalso extends Mock implements FotosImovelDataSource {}

const _imovel = 36;

List<Object?> _listaDaFixture(String nome) =>
    lerFixtureApi(nome)! as List<Object?>;

Exception? _falhaDe<T>(Result<T> resultado) => switch (resultado) {
  Failure<T>(:final erro) => erro,
  _ => null,
};

T _dadoDe<T>(Result<T> resultado) => (resultado as Success<T>).data;

void main() {
  late ApiFalsa api;
  late Directory pasta;
  late String caminhoDaFoto;

  FotosImovelRemoteDataSource dataSource({String? token = 'token-de-teste'}) =>
      FotosImovelRemoteDataSource(
        api.criarDioAutenticado(
          InterceptadorSessao(ArmazenamentoTokenEmMemoria(token)),
        ),
      );

  FotosImovelRepositoryImpl repositorio({String? token = 'token-de-teste'}) =>
      FotosImovelRepositoryImpl(dataSource(token: token));

  setUp(() {
    api = ApiFalsa();
    pasta = Directory.systemTemp.createTempSync('fotos_imovel_teste_');
    caminhoDaFoto = '${pasta.path}${Platform.pathSeparator}preparada.jpg';
    // 64 KB: grande o bastante para o Dio avisar o progresso mais de uma vez.
    File(caminhoDaFoto).writeAsBytesSync(List.filled(64 * 1024, 7));
  });

  tearDown(() => pasta.deleteSync(recursive: true));

  group('FotoImovelModel lê todas as fixtures de sucesso (§19.2)', () {
    for (final nome in [
      'fotos_lista_vazia.json',
      'fotos_lista.json',
      'fotos_reordenadas.json',
      'fotos_capa_definida.json',
      'fotos_apos_apagar_capa.json',
    ]) {
      test(nome, () {
        final fotos = [
          for (final item in _listaDaFixture(nome))
            FotoImovelModel.fromJson(item! as Map<String, Object?>)
                .paraEntidade(),
        ];
        final esperado = _listaDaFixture(nome);
        expect(fotos, hasLength(esperado.length));
        for (final (indice, foto) in fotos.indexed) {
          final item = esperado[indice]! as Map<String, Object?>;
          expect(foto.id, item['id']);
          expect(foto.url, item['imagem']);
          expect(foto.ordem, item['ordem']);
          expect(foto.capa, item['capa']);
        }
      });
    }

    test('foto_enviada.json vira a entidade sem mudar ordem nem capa', () {
      final foto = FotoImovelModel.fromJson(
        lerFixtureApi('foto_enviada.json')! as Map<String, Object?>,
      ).paraEntidade();
      expect((foto.ordem, foto.capa), (0, true));
    });

    test('chave faltando ou de tipo errado quebra a leitura', () {
      final base = lerFixtureApi('foto_enviada.json')! as Map<String, Object?>;
      expect(
        () => FotoImovelModel.fromJson({...base}..remove('capa')),
        throwsA(isA<TypeError>()),
      );
      expect(
        () => FotoImovelModel.fromJson({...base, 'ordem': '0'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('DataSource no Dio autenticado (rotas do §19)', () {
    test('listar faz GET /api/imoveis/36/fotos/ com o token', () async {
      final fotos = await dataSource().listar(_imovel);

      final pedido = api.requisicoesDasFotos.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/imoveis/36/fotos/');
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
      expect([for (final foto in fotos) foto.id], [88, 89, 90]);
    });

    test('enviar faz POST multipart com UM arquivo no campo imagem, em JPEG, '
        'e avisa o progresso até o fim', () async {
      final progresso = <(int, int)>[];

      final foto = await dataSource().enviar(
        _imovel,
        caminhoDaFoto,
        aoEnviar: (enviados, total) => progresso.add((enviados, total)),
      );

      final pedido = api.requisicoesDasFotos.single;
      expect(pedido.metodo, 'POST');
      expect(pedido.uri.path, '/api/imoveis/36/fotos/');
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
      expect(
        pedido.cabecalho('content-type'),
        startsWith('multipart/form-data'),
      );
      final texto = pedido.corpoEmTexto.toLowerCase();
      expect(
        'name="imagem"'.allMatches(texto),
        hasLength(1),
        reason: 'exatamente um arquivo por requisição',
      );
      expect(texto, contains('filename="foto.jpg"'));
      expect(texto, contains('content-type: image/jpeg'));
      expect(pedido.bytesEnviados!.length, greaterThan(64 * 1024));

      expect(progresso, isNotEmpty);
      expect(progresso.length, greaterThan(1));
      final (enviados, total) = progresso.last;
      expect(total, greaterThan(0));
      expect(enviados, total);
      expect((foto.id, foto.ordem, foto.capa), (88, 0, true));
    });

    test('enviar duas vezes o mesmo arquivo funciona (corpo novo a cada vez, '
        '"Tentar de novo")', () async {
      final fonte = dataSource();
      await fonte.enviar(_imovel, caminhoDaFoto);
      await fonte.enviar(_imovel, caminhoDaFoto);

      expect(api.requisicoesDasFotos, hasLength(2));
    });

    test('só o envio usa o tempo próprio de 60 s (D-19)', () async {
      final fonte = dataSource();
      await fonte.enviar(_imovel, caminhoDaFoto);
      await fonte.listar(_imovel);

      final [envio, leitura] = api.requisicoesDasFotos;
      expect(envio.tempoDeEnvio, const Duration(seconds: 60));
      expect(envio.tempoDeEnvio, tempoMaximoDeEnvioDaFoto);
      expect(leitura.tempoDeEnvio, isNot(tempoMaximoDeEnvioDaFoto));
    });

    test('reordenar faz PUT .../fotos/ordem/ com {"ids": [...]}', () async {
      final fotos = await dataSource().reordenar(_imovel, [90, 89, 88]);

      final chamada = api.chamadas.single;
      expect(chamada.metodo, 'PUT');
      expect(chamada.uri.path, '/api/imoveis/36/fotos/ordem/');
      expect(chamada.corpo, {
        'ids': [90, 89, 88],
      });
      expect([for (final foto in fotos) foto.id], [90, 89, 88]);
    });

    test('definir capa faz POST .../fotos/89/capa/ sem corpo', () async {
      await dataSource().definirCapa(_imovel, 89);

      final chamada = api.chamadas.single;
      expect(chamada.metodo, 'POST');
      expect(chamada.uri.path, '/api/imoveis/36/fotos/89/capa/');
      expect(chamada.corpo, isNull);
    });

    test('apagar faz DELETE .../fotos/89/', () async {
      final fotos = await dataSource().apagar(_imovel, 89);

      final chamada = api.chamadas.single;
      expect(chamada.metodo, 'DELETE');
      expect(chamada.uri.path, '/api/imoveis/36/fotos/89/');
      expect([for (final foto in fotos) foto.id], [90, 88]);
    });

    test('o app não usa a rota antiga /api/fotos-imovel/', () {
      final usos = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((arquivo) => arquivo.path.endsWith('.dart'))
          // só a rota dentro de string (comentários podem citá-la)
          .where(
            (arquivo) => RegExp(r"""['"][^'"
]*fotos-imovel""").hasMatch(arquivo.readAsStringSync()),
          );
      expect(usos, isEmpty);
    });
  });

  group('Repositório: pilha completa até a ApiFalsa', () {
    test(
      'listar devolve as entidades na ordem do servidor, imutáveis',
      () async {
        final resultado = await repositorio().listar(_imovel);

        final fotos = _dadoDe(resultado);
        expect([for (final foto in fotos) foto.id], [88, 89, 90]);
        expect(fotos.where((foto) => foto.capa).single.id, 88);
        expect(() => fotos.add(fotos.first), throwsUnsupportedError);
      },
    );

    test('enviar converte o progresso em fração 0..1 e termina em 1', () async {
      final fracoes = <double?>[];

      final resultado = await repositorio().enviar(
        _imovel,
        FotoEscolhida(caminho: caminhoDaFoto),
        aoProgredir: fracoes.add,
      );

      expect(_dadoDe(resultado).id, 88);
      expect(fracoes, isNotEmpty);
      expect(fracoes.last, 1.0);
      for (final fracao in fracoes) {
        expect(fracao, inInclusiveRange(0, 1));
      }
    });

    test(
      'sem token (401) vira SessaoExpiradaException nas 5 operações',
      () async {
        final repo = repositorio(token: null);
        final foto = FotoEscolhida(caminho: caminhoDaFoto);
        final resultados = <Result<Object?>>[
          await repo.listar(_imovel),
          await repo.enviar(_imovel, foto),
          await repo.reordenar(_imovel, [1]),
          await repo.definirCapa(_imovel, 1),
          await repo.apagar(_imovel, 1),
        ];
        for (final resultado in resultados) {
          expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
        }
      },
    );

    final recusas = {
      'erro_400_foto_tipo.json': 'O arquivo enviado não é uma imagem válida.',
      'erro_400_foto_tamanho.json': 'A imagem não pode passar de 5MB.',
      'erro_400_foto_quantidade.json':
          'Envie exatamente uma imagem por requisição.',
      'erro_400_foto_limite.json':
          'Este imóvel já tem 30 fotos, o máximo permitido.',
    };
    for (final recusa in recusas.entries) {
      test('400 do envio (${recusa.key}) vira FotoRecusadaException com a '
          'mensagem do servidor', () async {
        api.responder(
          (uri) => uri.path == '/api/imoveis/36/fotos/',
          status: 400,
          fixture: recusa.key,
        );

        final resultado = await repositorio().enviar(
          _imovel,
          FotoEscolhida(caminho: caminhoDaFoto),
        );

        final falha = _falhaDe(resultado);
        expect(falha, isA<FotoRecusadaException>());
        expect((falha! as FotoRecusadaException).mensagem, recusa.value);
      });
    }

    test('400 da ordem vira recusa com a mensagem do servidor', () async {
      api.responder(
        (uri) => uri.path.endsWith('/fotos/ordem/'),
        status: 400,
        fixture: 'erro_400_fotos_ordem.json',
      );

      final falha = _falhaDe(await repositorio().reordenar(_imovel, [88, 88]));

      expect(
        (falha! as FotoRecusadaException).mensagem,
        'Envie a lista completa das fotos deste imóvel, sem repetir.',
      );
    });

    test('403 (gestor) vira recusa com o texto do servidor', () async {
      api.responder(
        (uri) => uri.path.contains('/fotos/'),
        status: 403,
        fixture: 'erro_403_fotos_gestor.json',
      );

      final falha = _falhaDe(await repositorio().listar(_imovel));

      expect(
        (falha! as FotoRecusadaException).mensagem,
        'Este recurso é restrito ao corretor.',
      );
    });

    test('404 (outra empresa) vira ImovelNaoEncontradoException, sem o texto '
        'em inglês', () async {
      api.responder(
        (uri) => uri.path.contains('/fotos/'),
        status: 404,
        fixture: 'erro_404_fotos_outra_empresa.json',
      );

      final repo = repositorio();
      for (final resultado in <Result<Object?>>[
        await repo.listar(_imovel),
        await repo.definirCapa(_imovel, 1),
        await repo.apagar(_imovel, 1),
      ]) {
        expect(_falhaDe(resultado), isA<ImovelNaoEncontradoException>());
      }
    });

    test('500 e 400 sem texto viram FalhaDeConexaoException', () async {
      api.responder((uri) => uri.path == '/api/imoveis/36/fotos/', status: 500);
      expect(
        _falhaDe(await repositorio().listar(_imovel)),
        isA<FalhaDeConexaoException>(),
      );

      api.responder(
        (uri) => uri.path.endsWith('/capa/'),
        status: 400,
        corpo: const <String, Object?>{},
      );
      expect(
        _falhaDe(await repositorio().definirCapa(_imovel, 1)),
        isA<FalhaDeConexaoException>(),
      );
    });

    test(
      'corpo que não é lista ou item malformado vira falha de conexão',
      () async {
        api.responder(
          (uri) => uri.path == '/api/imoveis/36/fotos/',
          status: 200,
          corpo: const {'fotos': <Object?>[]},
        );
        expect(
          _falhaDe(await repositorio().listar(_imovel)),
          isA<FalhaDeConexaoException>(),
        );

        api.responder(
          (uri) => uri.path.endsWith('/ordem/'),
          status: 200,
          corpo: const [
            {
              'id': 1,
              'imagem': 'http://x/media/imoveis/fotos/a.jpg',
              'ordem': 0,
            },
          ],
        );
        expect(
          _falhaDe(await repositorio().reordenar(_imovel, [1])),
          isA<FalhaDeConexaoException>(),
        );
      },
    );

    test(
      'arquivo local que sumiu vira falha de conexão, sem requisição',
      () async {
        final resultado = await repositorio().enviar(
          _imovel,
          FotoEscolhida(caminho: '${pasta.path}/nao_existe.jpg'),
        );

        expect(_falhaDe(resultado), isA<FalhaDeConexaoException>());
        expect(api.requisicoesDasFotos, isEmpty);
      },
    );

    test(
      'tempo de envio esgotado vira falha de conexão, sem nova tentativa',
      () async {
        final fonte = _DataSourceFalso();
        when(() => fonte.enviar(any(), any(), aoEnviar: any(named: 'aoEnviar')))
            .thenThrow(
              DioException(
                requestOptions: RequestOptions(path: '/api/imoveis/36/fotos/'),
                type: DioExceptionType.sendTimeout,
              ),
            );

        final resultado = await FotosImovelRepositoryImpl(fonte)
            .enviar(_imovel, FotoEscolhida(caminho: caminhoDaFoto));

        expect(_falhaDe(resultado), isA<FalhaDeConexaoException>());
        verify(
          () => fonte.enviar(any(), any(), aoEnviar: any(named: 'aoEnviar')),
        ).called(1);
      },
    );
  });

  group('fracaoEnviada', () {
    test('total conhecido vira fração limitada a 0..1', () {
      expect(fracaoEnviada(0, 200), 0);
      expect(fracaoEnviada(50, 200), 0.25);
      expect(fracaoEnviada(200, 200), 1);
      expect(fracaoEnviada(250, 200), 1);
    });

    test('total desconhecido (-1 ou 0) vira null (barra indeterminada)', () {
      expect(fracaoEnviada(10, -1), isNull);
      expect(fracaoEnviada(0, 0), isNull);
    });
  });
}
