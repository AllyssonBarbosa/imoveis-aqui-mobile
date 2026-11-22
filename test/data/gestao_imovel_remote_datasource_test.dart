import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/gestao_imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/data/repositories/gestao_imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/imovel_gestao.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/obter_imovel_gestao_usecase.dart';

import '../support/api_falsa.dart';
import '../support/armazenamento_token_em_memoria.dart';

void main() {
  late ApiFalsa api;

  GestaoImovelRemoteDataSource criarDataSource(
    ArmazenamentoTokenEmMemoria armazenamento,
  ) => GestaoImovelRemoteDataSource(
    api.criarDioAutenticado(InterceptadorSessao(armazenamento)),
  );

  setUp(() => api = ApiFalsa());

  group('pilha de dados (UseCase → Repository → DataSource → ApiFalsa)', () {
    test('ObterImovelGestaoUseCase(36) lê GET /api/imoveis/36/ com o token e '
        'devolve o ImovelGestao do wire', () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/',
        status: 200,
        fixture: 'imovel_gestao_disponivel.json',
      );
      final useCase = ObterImovelGestaoUseCase(
        GestaoImovelRepositoryImpl(
          criarDataSource(ArmazenamentoTokenEmMemoria('token-de-teste')),
        ),
      );

      final resultado = await useCase(36);

      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/imoveis/36/');
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');

      expect(resultado, isA<Success<ImovelGestao>>());
      final imovel = (resultado as Success<ImovelGestao>).data;
      expect(imovel.id, 36);
      expect(imovel.codigo, 'DEV-INDAIATUBA-04');
      expect(imovel.situacao, SituacaoImovel.disponivel);
      expect(imovel.podeMudarSituacao, isTrue);
    });
  });

  group('GestaoImovelRemoteDataSource', () {
    test('obterImovel(36) devolve o Model do wire capturado', () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/',
        status: 200,
        fixture: 'imovel_gestao_reservado.json',
      );
      final datasource = criarDataSource(
        ArmazenamentoTokenEmMemoria('token-de-teste'),
      );

      final modelo = await datasource.obterImovel(36);

      expect(modelo.id, 36);
      expect(modelo.situacao, 'RESERVADO');
    });

    test('401 sobe como DioException cujo error é SessaoExpiradaException',
        () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/',
        status: 401,
        fixture: 'erro_401.json',
      );
      final datasource = criarDataSource(
        ArmazenamentoTokenEmMemoria('token-de-teste'),
      );

      await expectLater(
        datasource.obterImovel(36),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<SessaoExpiradaException>(),
          ),
        ),
      );
    });

    test('corpo que não é objeto (lista) lança FormatException', () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/',
        status: 200,
        corpo: <Object?>[],
      );
      final datasource = criarDataSource(
        ArmazenamentoTokenEmMemoria('token-de-teste'),
      );

      await expectLater(
        datasource.obterImovel(36),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
