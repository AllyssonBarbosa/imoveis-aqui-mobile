import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/caixa_contatos_datasource.dart';
import 'package:imoveis_aqui/data/datasources/caixa_contatos_remote_datasource.dart';
import 'package:imoveis_aqui/data/models/contato_recebido_model.dart';
import 'package:imoveis_aqui/data/models/contatos_envelope_model.dart';
import 'package:imoveis_aqui/data/models/imovel_com_contato_model.dart';
import 'package:imoveis_aqui/data/models/resumo_contatos_model.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/data/repositories/caixa_contatos_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/consulta_contatos.dart';
import 'package:imoveis_aqui/domain/entities/contato_recebido.dart';
import 'package:imoveis_aqui/domain/entities/imovel_com_contato.dart';
import 'package:imoveis_aqui/domain/entities/pagina_contatos.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';
import 'package:imoveis_aqui/domain/repositories/caixa_contatos_repository.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_caixa_contatos.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';
import '../support/armazenamento_token_em_memoria.dart';

class _FonteFalsa extends Mock implements CaixaContatosDataSource {}

RequestOptions _opcoes() => RequestOptions(path: '/api/contatos/');

DioException _erroDio({int? status, Object? erro}) => DioException(
  requestOptions: _opcoes(),
  response: status == null
      ? null
      : Response<Object?>(requestOptions: _opcoes(), statusCode: status),
  type: status == null
      ? DioExceptionType.connectionTimeout
      : DioExceptionType.badResponse,
  error: erro,
);

ContatosEnvelopeModel _envelope(String arquivo) =>
    ContatosEnvelopeModel.fromJson(
      lerFixtureApi(arquivo)! as Map<String, Object?>,
    );

ContatoRecebidoModel _contatoPatch() => ContatoRecebidoModel.fromJson(
  lerFixtureApi('contato_patch_200.json')! as Map<String, Object?>,
);

Exception? _falhaDe<T>(Result<T> resultado) => switch (resultado) {
  Failure<T>(:final erro) => erro,
  _ => null,
};

class _FalhaDeTeste implements Exception {
  const _FalhaDeTeste();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ConsultaContatos());
    registerFallbackValue(RetornoContato.falei);
  });

  group('CaixaContatosRepositoryImpl', () {
    late _FonteFalsa fonte;
    late CaixaContatosRepository repositorio;

    setUp(() {
      fonte = _FonteFalsa();
      repositorio = CaixaContatosRepositoryImpl(fonte);
    });

    group('sucesso', () {
      test(
        'buscar devolve a página de domínio com 20 itens e o next',
        () async {
          final envelope = _envelope('contatos_p1.json');
          when(() => fonte.buscar(any())).thenAnswer((_) async => envelope);

          final resultado = await repositorio.buscar(const ConsultaContatos());

          expect(resultado, isA<Success<PaginaContatos>>());
          final pagina = (resultado as Success<PaginaContatos>).data;
          expect(pagina.itens, hasLength(20));
          expect(pagina.proximaPagina, envelope.next);
        },
      );

      test('seguir repassa o next e devolve a última página', () async {
        final p1 = _envelope('contatos_p1.json');
        when(() => fonte.seguir(p1.next!))
            .thenAnswer((_) async => _envelope('contatos_p2.json'));

        final resultado = await repositorio.seguir(p1.next!);

        expect(resultado, isA<Success<PaginaContatos>>());
        expect((resultado as Success<PaginaContatos>).data.ehUltima, isTrue);
      });

      test('contarSemRetorno devolve o número do servidor', () async {
        when(() => fonte.contarSemRetorno())
            .thenAnswer((_) async => const ResumoContatosModel(semRetorno: 25));

        final resultado = await repositorio.contarSemRetorno();

        expect(resultado, isA<Success<int>>());
        expect((resultado as Success<int>).data, 25);
      });

      test('listarImoveis devolve as entidades na ordem da fonte', () async {
        when(() => fonte.listarImoveis()).thenAnswer(
          (_) async => const [
            ImovelComContatoModel(id: 2, codigo: 'B', titulo: 'Bb'),
            ImovelComContatoModel(id: 1, codigo: 'A', titulo: 'Aa'),
          ],
        );

        final resultado = await repositorio.listarImoveis();

        expect(resultado, isA<Success<List<ImovelComContato>>>());
        final imoveis = (resultado as Success<List<ImovelComContato>>).data;
        expect(imoveis.map((i) => i.id), [2, 1]);
      });

      test('anotarRetorno devolve o contato atualizado', () async {
        final modelo = _contatoPatch();
        when(() => fonte.anotarRetorno(modelo.id, RetornoContato.falei))
            .thenAnswer((_) async => modelo);

        final resultado = await repositorio.anotarRetorno(
          modelo.id,
          RetornoContato.falei,
        );

        expect(resultado, isA<Success<ContatoRecebido>>());
        expect(
          (resultado as Success<ContatoRecebido>).data.retorno,
          RetornoContato.falei,
        );
      });
    });

    /// Cada método da caixa, chamado com a fonte lançando [erro].
    final metodos = <String, Future<Result<Object?>> Function(Object erro)>{
      'buscar': (erro) async {
        when(() => fonte.buscar(any())).thenThrow(erro);
        return repositorio.buscar(const ConsultaContatos());
      },
      'seguir': (erro) async {
        when(() => fonte.seguir(any())).thenThrow(erro);
        return repositorio.seguir('http://127.0.0.1:8000/api/contatos/?page=2');
      },
      'contarSemRetorno': (erro) async {
        when(() => fonte.contarSemRetorno()).thenThrow(erro);
        return repositorio.contarSemRetorno();
      },
      'listarImoveis': (erro) async {
        when(() => fonte.listarImoveis()).thenThrow(erro);
        return repositorio.listarImoveis();
      },
      'anotarRetorno': (erro) async {
        when(() => fonte.anotarRetorno(any(), any())).thenThrow(erro);
        return repositorio.anotarRetorno(26, RetornoContato.falei);
      },
    };

    for (final entrada in metodos.entries) {
      group('falhas de ${entrada.key}', () {
        Future<Result<Object?>> chamar(Object erro) => entrada.value(erro);

        test('SessaoExpiradaException direta vira Failure com ela', () async {
          final resultado = await chamar(const SessaoExpiradaException());

          expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
        });

        test('DioException com error SessaoExpiradaException vira Failure com '
            'ela', () async {
          final resultado = await chamar(
            _erroDio(status: 401, erro: const SessaoExpiradaException()),
          );

          expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
        });

        test('DioException 403 vira SemPermissaoException', () async {
          final resultado = await chamar(_erroDio(status: 403));

          expect(_falhaDe(resultado), isA<SemPermissaoException>());
        });

        test('DioException 500 segue como a própria DioException', () async {
          final resultado = await chamar(_erroDio(status: 500));

          expect(_falhaDe(resultado), isA<DioException>());
        });

        test('timeout/erro de conexão segue como DioException', () async {
          final resultado = await chamar(_erroDio());

          expect(_falhaDe(resultado), isA<DioException>());
        });

        test('TypeError do wire malformado vira FormatException', () async {
          final resultado = await chamar(TypeError());

          expect(_falhaDe(resultado), isA<FormatException>());
        });

        test('FormatException passa como Failure com ela', () async {
          final resultado = await chamar(const FormatException('retorno'));

          expect(_falhaDe(resultado), isA<FormatException>());
        });

        test('outra Exception passa como está e nada lança', () async {
          final resultado = await chamar(const _FalhaDeTeste());

          expect(_falhaDe(resultado), isA<_FalhaDeTeste>());
        });

        test(
          entrada.key == 'anotarRetorno'
              ? 'DioException 404 vira ContatoNaoEncontradoException'
              : 'DioException 404 continua falha genérica (DioException)',
          () async {
            final resultado = await chamar(_erroDio(status: 404));

            expect(
              _falhaDe(resultado),
              entrada.key == 'anotarRetorno'
                  ? isA<ContatoNaoEncontradoException>()
                  : isA<DioException>(),
            );
          },
        );
      });
    }

    test('wire com canal desconhecido (FormatException do Model) vira Failure '
        'tipada, sem escapar', () async {
      final corpo = lerFixtureApi('contatos_p1.json')! as Map<String, Object?>;
      final itens = [
        for (final item in corpo['results']! as List<Object?>)
          Map<String, Object?>.of(item! as Map<String, Object?>),
      ];
      itens.first['canal'] = 'CARTA';
      final envelope = ContatosEnvelopeModel.fromJson({
        ...corpo,
        'results': itens,
      });
      when(() => fonte.buscar(any())).thenAnswer((_) async => envelope);

      final resultado = await repositorio.buscar(const ConsultaContatos());

      expect(_falhaDe(resultado), isA<FormatException>());
    });

    test('pilha real sem token: o 401 da ApiFalsa vira '
        'SessaoExpiradaException em todos os métodos', () async {
      final api = ApiFalsa();
      final real = CaixaContatosRepositoryImpl(
        CaixaContatosRemoteDataSource(
          api.criarDioAutenticado(
            InterceptadorSessao(ArmazenamentoTokenEmMemoria()),
          ),
        ),
      );

      expect(
        _falhaDe(await real.buscar(const ConsultaContatos())),
        isA<SessaoExpiradaException>(),
      );
      expect(
        _falhaDe(await real.contarSemRetorno()),
        isA<SessaoExpiradaException>(),
      );
      expect(
        _falhaDe(await real.listarImoveis()),
        isA<SessaoExpiradaException>(),
      );
      expect(
        _falhaDe(await real.anotarRetorno(26, RetornoContato.falei)),
        isA<SessaoExpiradaException>(),
      );
    });

    test('pilha real com token: PATCH de contato que não existe vira '
        'ContatoNaoEncontradoException', () async {
      final api = ApiFalsa();
      final real = CaixaContatosRepositoryImpl(
        CaixaContatosRemoteDataSource(
          api.criarDioAutenticado(
            InterceptadorSessao(ArmazenamentoTokenEmMemoria('token-de-teste')),
          ),
        ),
      );

      final resultado = await real.anotarRetorno(999999, RetornoContato.falei);

      expect(_falhaDe(resultado), isA<ContatoNaoEncontradoException>());
    });
  });
}
