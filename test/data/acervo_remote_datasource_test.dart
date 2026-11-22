import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/acervo_remote_datasource.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/domain/entities/consulta_acervo.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';

import '../support/api_falsa.dart';
import '../support/armazenamento_token_em_memoria.dart';

void main() {
  group('AcervoRemoteDataSource', () {
    late ApiFalsa api;
    late AcervoRemoteDataSource datasource;

    Map<String, Object?> fixture(String arquivo) =>
        lerFixtureApi(arquivo)! as Map<String, Object?>;

    AcervoRemoteDataSource criar(ArmazenamentoTokenEmMemoria armazenamento) =>
        AcervoRemoteDataSource(
          api.criarDioAutenticado(InterceptadorSessao(armazenamento)),
        );

    setUp(() {
      api = ApiFalsa();
      datasource = criar(ArmazenamentoTokenEmMemoria('token-de-teste'));
    });

    test(
      'buscar pede GET /api/imoveis/ com o token e devolve acervo_p1',
      () async {
        final envelope = await datasource.buscar(const ConsultaAcervo());

        final pedido = api.requisicoesGravadas.single;
        expect(pedido.metodo, 'GET');
        expect(pedido.uri.path, '/api/imoveis/');
        expect(pedido.uri.queryParameters, isEmpty);
        expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');

        final p1 = fixture('acervo_p1.json');
        expect(envelope.results, hasLength((p1['results']! as List).length));
        expect(envelope.next, p1['next']);
        expect(envelope.next, isNotNull);
      },
    );

    test('buscar com busca manda ?busca= e recebe acervo_busca', () async {
      final envelope = await datasource.buscar(
        const ConsultaAcervo(busca: ' DEV-CAMPINAS-14 '),
      );

      expect(api.requisicoes.single.queryParameters, {
        'busca': 'DEV-CAMPINAS-14',
      });
      expect(
        envelope.results,
        hasLength((fixture('acervo_busca.json')['results']! as List).length),
      );
    });

    test('buscar com situação vendido manda ?situacao=VENDIDO e recebe a '
        'lista vazia', () async {
      final envelope = await datasource.buscar(
        const ConsultaAcervo(situacao: SituacaoImovel.vendido),
      );

      expect(api.requisicoes.single.queryParameters, {'situacao': 'VENDIDO'});
      expect(envelope.results, isEmpty);
    });

    test('seguir(next) pede page=2 e devolve acervo_p2', () async {
      final p1 = await datasource.buscar(const ConsultaAcervo());

      final p2 = await datasource.seguir(p1.next!);

      expect(api.requisicoes.last.queryParameters['page'], '2');
      expect(
        p2.results,
        hasLength((fixture('acervo_p2.json')['results']! as List).length),
      );
    });

    test('seguir com next de outra origem lança FormatException e não gera '
        'pedido', () async {
      await expectLater(
        datasource.seguir('http://outro.exemplo:8000/api/imoveis/?page=2'),
        throwsFormatException,
      );
      expect(api.requisicoes, isEmpty);
    });

    test('sem token a API responde 401 e buscar falha com '
        'SessaoExpiradaException', () async {
      final semToken = criar(ArmazenamentoTokenEmMemoria());

      await expectLater(
        semToken.buscar(const ConsultaAcervo()),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<SessaoExpiradaException>(),
          ),
        ),
      );
      expect(api.requisicoesGravadas.single.cabecalho('Authorization'), isNull);
    });
  });
}
