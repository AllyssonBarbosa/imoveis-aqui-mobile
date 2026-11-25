import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/area_gestor_remote_datasource.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';

import '../support/api_falsa.dart';
import '../support/armazenamento_token_em_memoria.dart';

void main() {
  group('AreaGestorRemoteDataSource', () {
    late ApiFalsa api;
    late AreaGestorRemoteDataSource datasource;

    Map<String, Object?> fixture(String arquivo) =>
        lerFixtureApi(arquivo)! as Map<String, Object?>;

    AreaGestorRemoteDataSource criar(
      ArmazenamentoTokenEmMemoria armazenamento,
    ) => AreaGestorRemoteDataSource(
      api.criarDioAutenticado(InterceptadorSessao(armazenamento)),
    );

    setUp(() {
      api = ApiFalsa();
      datasource = criar(ArmazenamentoTokenEmMemoria('token-de-teste'));
    });

    test('obterTotaisPorSituacao pede GET /api/relatorios/acervo/ com o token '
        'e devolve o total da fixture', () async {
      final modelo = await datasource.obterTotaisPorSituacao();

      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/relatorios/acervo/');
      expect(pedido.uri.queryParameters, isEmpty);
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
      expect(modelo.total, fixture('relatorio_acervo.json')['total']);
    });

    test('obterAcervoPorCorretor pede GET /api/relatorios/acervo-por-corretor/ '
        'sem query e devolve as linhas da fixture', () async {
      final modelo = await datasource.obterAcervoPorCorretor();

      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/relatorios/acervo-por-corretor/');
      expect(pedido.uri.queryParameters, isEmpty);
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
      final esperado = fixture('relatorio_acervo_por_corretor.json');
      expect(modelo.total, esperado['total']);
      expect(modelo.linhas, hasLength((esperado['linhas']! as List).length));
    });

    test('obterMudancasRecentes pede GET /api/relatorios/mudancas-situacao/ '
        'sem query alguma (a janela é do servidor)', () async {
      final modelo = await datasource.obterMudancasRecentes();

      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/relatorios/mudancas-situacao/');
      expect(pedido.uri.queryParameters, isEmpty);
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
      final esperado = fixture('relatorio_mudancas.json');
      expect(modelo.dias, esperado['dias']);
      expect(
        modelo.mudancas,
        hasLength((esperado['mudancas']! as List).length),
      );
    });

    test('obterContatosPorCorretor sem período pede GET '
        '/api/relatorios/contatos/ sem query e devolve relatorio_contatos', () async {
      final modelo = await datasource.obterContatosPorCorretor();

      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/relatorios/contatos/');
      expect(pedido.uri.queryParameters, isEmpty);
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
      final esperado = fixture('relatorio_contatos.json');
      expect(modelo.total, esperado['total']);
      expect(modelo.pendentes, esperado['pendentes']);
    });

    test('obterContatosPorCorretor com período manda exatamente de e ate e '
        'devolve relatorio_contatos_periodo', () async {
      final modelo = await datasource.obterContatosPorCorretor(
        PeriodoContatos(de: DateTime(2026, 11, 1), ate: DateTime(2026, 11, 25)),
      );

      expect(api.requisicoes.single.queryParameters, {
        'de': '2026-11-01',
        'ate': '2026-11-25',
      });
      final esperado = fixture('relatorio_contatos_periodo.json');
      expect(modelo.total, esperado['total']);
      expect(modelo.pendentes, esperado['pendentes']);
    });

    test('nenhum pedido leva imovel nem dias', () async {
      await datasource.obterTotaisPorSituacao();
      await datasource.obterAcervoPorCorretor();
      await datasource.obterMudancasRecentes();
      await datasource.obterContatosPorCorretor();
      await datasource.obterContatosPorCorretor(
        PeriodoContatos(de: DateTime(2026, 11, 1), ate: DateTime(2026, 11, 25)),
      );

      expect(api.requisicoes, hasLength(5));
      for (final uri in api.requisicoes) {
        expect(uri.queryParameters.containsKey('imovel'), isFalse);
        expect(uri.queryParameters.containsKey('dias'), isFalse);
      }
    });

    test('todo pedido leva Authorization: Token ...', () async {
      await datasource.obterTotaisPorSituacao();
      await datasource.obterAcervoPorCorretor();
      await datasource.obterMudancasRecentes();
      await datasource.obterContatosPorCorretor();

      expect(api.requisicoesGravadas, hasLength(4));
      for (final pedido in api.requisicoesGravadas) {
        expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
      }
    });

    test('sem token a API falsa responde 401 nas 4 rotas e a DataSource '
        'deixa a DioException sair', () async {
      final semToken = criar(ArmazenamentoTokenEmMemoria(null));

      for (final leitura in <Future<Object?> Function()>[
        semToken.obterTotaisPorSituacao,
        semToken.obterAcervoPorCorretor,
        semToken.obterContatosPorCorretor,
        semToken.obterMudancasRecentes,
      ]) {
        await expectLater(
          leitura(),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'status',
              401,
            ),
          ),
        );
      }
    });

    test('um 403 servido por responder sai como DioException 403, sem captura',
        () async {
      api.responder(
        (uri) => uri.path.startsWith('/api/relatorios/'),
        status: 403,
        fixture: 'erro_403_relatorio.json',
      );

      await expectLater(
        datasource.obterTotaisPorSituacao(),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            403,
          ),
        ),
      );
    });

    test('corpo que não é objeto JSON (lista ou texto) lança FormatException',
        () async {
      api.responder(
        (uri) => uri.path == '/api/relatorios/acervo/',
        status: 200,
        corpo: const <Object?>[1, 2],
      );
      api.responder(
        (uri) => uri.path == '/api/relatorios/acervo-por-corretor/',
        status: 200,
        corpo: 'texto',
      );
      api.responder(
        (uri) => uri.path == '/api/relatorios/contatos/',
        status: 200,
        corpo: const <Object?>[],
      );
      api.responder(
        (uri) => uri.path == '/api/relatorios/mudancas-situacao/',
        status: 200,
        corpo: 'texto',
      );

      await expectLater(
        datasource.obterTotaisPorSituacao(),
        throwsA(isA<FormatException>()),
      );
      await expectLater(
        datasource.obterAcervoPorCorretor(),
        throwsA(isA<FormatException>()),
      );
      await expectLater(
        datasource.obterContatosPorCorretor(),
        throwsA(isA<FormatException>()),
      );
      await expectLater(
        datasource.obterMudancasRecentes(),
        throwsA(isA<FormatException>()),
      );
    });

    test('requisicoesDosRelatorios devolve só as rotas de relatórios, na '
        'ordem', () async {
      await datasource.obterMudancasRecentes();
      await datasource.obterTotaisPorSituacao();

      expect(api.requisicoesDosRelatorios.map((uri) => uri.path), [
        '/api/relatorios/mudancas-situacao/',
        '/api/relatorios/acervo/',
      ]);
    });
  });
}
