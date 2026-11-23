import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/caixa_contatos_remote_datasource.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/domain/entities/consulta_contatos.dart';
import 'package:imoveis_aqui/domain/entities/imovel_com_contato.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';

import '../support/api_falsa.dart';
import '../support/armazenamento_token_em_memoria.dart';

void main() {
  group('CaixaContatosRemoteDataSource', () {
    late ApiFalsa api;
    late CaixaContatosRemoteDataSource datasource;

    Map<String, Object?> fixture(String arquivo) =>
        lerFixtureApi(arquivo)! as Map<String, Object?>;

    CaixaContatosRemoteDataSource criar(
      ArmazenamentoTokenEmMemoria armazenamento,
    ) => CaixaContatosRemoteDataSource(
      api.criarDioAutenticado(InterceptadorSessao(armazenamento)),
    );

    setUp(() {
      api = ApiFalsa();
      datasource = criar(ArmazenamentoTokenEmMemoria('token-de-teste'));
    });

    test('buscar pede GET /api/contatos/ com o token e devolve contatos_p1 '
        '(20 itens)', () async {
      final envelope = await datasource.buscar(const ConsultaContatos());

      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/contatos/');
      expect(pedido.uri.queryParameters, isEmpty);
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');

      final p1 = fixture('contatos_p1.json');
      expect(envelope.results, hasLength(20));
      expect(envelope.results, hasLength((p1['results']! as List).length));
      expect(envelope.next, p1['next']);
    });

    test('buscar com imóvel manda imovel= e recebe contatos_imovel', () async {
      final envelope = await datasource.buscar(
        const ConsultaContatos(
          imovel: ImovelComContato(id: 36, codigo: 'X', titulo: 'Y'),
        ),
      );

      expect(api.requisicoes.single.queryParameters, {'imovel': '36'});
      expect(
        envelope.results,
        hasLength((fixture('contatos_imovel.json')['results']! as List).length),
      );
    });

    test(
      'buscar com período manda de e ate e recebe contatos_periodo_vazio',
      () async {
        final envelope = await datasource.buscar(
          ConsultaContatos(
            periodo: PeriodoContatos(
              de: DateTime(2026, 11, 1),
              ate: DateTime(2026, 11, 22),
            ),
          ),
        );

        expect(api.requisicoes.single.queryParameters, {
          'de': '2026-11-01',
          'ate': '2026-11-22',
        });
        expect(envelope.results, isEmpty);
      },
    );

    test('buscar com imóvel e período manda as três chaves', () async {
      await datasource.buscar(
        ConsultaContatos(
          imovel: const ImovelComContato(id: 36, codigo: 'X', titulo: 'Y'),
          periodo: PeriodoContatos(
            de: DateTime(2026, 11, 1),
            ate: DateTime(2026, 11, 22),
          ),
        ),
      );

      expect(api.requisicoes.single.queryParameters, {
        'imovel': '36',
        'de': '2026-11-01',
        'ate': '2026-11-22',
      });
    });

    test('seguir(next) pede page=2 com o token e devolve contatos_p2', () async {
      final p1 = await datasource.buscar(const ConsultaContatos());

      final p2 = await datasource.seguir(p1.next!);

      expect(api.requisicoes.last.queryParameters['page'], '2');
      expect(
        api.requisicoesGravadas.last.cabecalho('Authorization'),
        'Token token-de-teste',
      );
      expect(
        p2.results,
        hasLength((fixture('contatos_p2.json')['results']! as List).length),
      );
    });

    test('seguir com next de outra origem lança FormatException e não gera '
        'pedido', () async {
      await expectLater(
        datasource.seguir('https://outra.origem/api/contatos/?page=2'),
        throwsFormatException,
      );
      expect(api.requisicoesGravadas, isEmpty);
    });

    test('contarSemRetorno pede GET /api/contatos/resumo/ e devolve o número '
        'do servidor', () async {
      final resumo = await datasource.contarSemRetorno();

      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/contatos/resumo/');
      expect(resumo.semRetorno, fixture('contatos_resumo.json')['sem_retorno']);
    });

    test('listarImoveis pede GET /api/contatos/imoveis/ e mantém a ordem da '
        'fixture', () async {
      final imoveis = await datasource.listarImoveis();

      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/contatos/imoveis/');
      final esperados = (lerFixtureApi('contatos_imoveis.json')! as List)
          .cast<Map<String, Object?>>();
      expect(imoveis.map((i) => i.id), esperados.map((e) => e['id']));
    });

    test(
      'anotarRetorno faz PATCH com barra final e corpo {retorno: FALEI}',
      () async {
        final id = fixture('contato_patch_200.json')['id']! as int;

        final contato = await datasource.anotarRetorno(
          id,
          RetornoContato.falei,
        );

        final pedido = api.requisicoesGravadas.single;
        expect(pedido.metodo, 'PATCH');
        expect(pedido.uri.path, '/api/contatos/$id/');
        expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
        expect(api.chamadas.single.corpo, {'retorno': 'FALEI'});
        expect(contato.id, id);
        expect(contato.retorno, 'FALEI');
      },
    );

    test('depois do PATCH aceito o resumo cai (contatos_resumo_apos)', () async {
      final id = fixture('contato_patch_200.json')['id']! as int;
      await datasource.anotarRetorno(id, RetornoContato.falei);

      final resumo = await datasource.contarSemRetorno();

      expect(
        resumo.semRetorno,
        fixture('contatos_resumo_apos.json')['sem_retorno'],
      );
    });

    test('anotarRetorno de outro id responde 404', () async {
      await expectLater(
        datasource.anotarRetorno(999999, RetornoContato.falei),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            404,
          ),
        ),
      );
    });

    test('anotarRetorno com PENDENTE responde 400', () async {
      final id = fixture('contato_patch_200.json')['id']! as int;
      await expectLater(
        datasource.anotarRetorno(id, RetornoContato.pendente),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            400,
          ),
        ),
      );
    });

    test('sem token toda rota da caixa falha com SessaoExpiradaException', () async {
      final semToken = criar(ArmazenamentoTokenEmMemoria());
      Matcher sessaoExpirada() => throwsA(
        isA<DioException>().having(
          (e) => e.error,
          'error',
          isA<SessaoExpiradaException>(),
        ),
      );

      await expectLater(
        semToken.buscar(const ConsultaContatos()),
        sessaoExpirada(),
      );
      await expectLater(semToken.contarSemRetorno(), sessaoExpirada());
      await expectLater(semToken.listarImoveis(), sessaoExpirada());
      await expectLater(
        semToken.anotarRetorno(1, RetornoContato.falei),
        sessaoExpirada(),
      );
      expect(
        api.requisicoesGravadas.every(
          (r) => r.cabecalho('Authorization') == null,
        ),
        isTrue,
      );
    });
  });
}
