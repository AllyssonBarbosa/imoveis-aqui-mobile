import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/gestao_imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/data/repositories/gestao_imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/imovel_gestao.dart';
import 'package:imoveis_aqui/domain/entities/mudanca_situacao.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/mudar_situacao_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_historico_situacao_usecase.dart';
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

  group('histórico — pilha de dados (UseCase → Repository → DataSource → '
      'ApiFalsa)', () {
    test('ObterHistoricoSituacaoUseCase(36) lê GET /api/imoveis/36/historico/ '
        'com o token e devolve Success([]) pela rota padrão', () async {
      final useCase = ObterHistoricoSituacaoUseCase(
        GestaoImovelRepositoryImpl(
          criarDataSource(ArmazenamentoTokenEmMemoria('token-de-teste')),
        ),
      );

      final resultado = await useCase(36);

      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'GET');
      expect(pedido.uri.path, '/api/imoveis/36/historico/');
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
      expect(resultado, isA<Success<List<MudancaSituacao>>>());
      expect((resultado as Success<List<MudancaSituacao>>).data, isEmpty);
    });

    test('a lista chega na MESMA ordem do servidor (D-11), sem reordenar',
        () async {
      // historico_contrato.json é o item mais antigo (id 1); o servidor pode
      // mandar na ordem que quiser — o app não reordena por data nem por id.
      final antigo = (lerFixtureApi('historico_contrato.json')! as List<Object?>)
          .single;
      final recente = (lerFixtureApi('historico_um_item.json')! as List<Object?>)
          .single;
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/historico/',
        status: 200,
        corpo: [antigo, recente],
      );
      final useCase = ObterHistoricoSituacaoUseCase(
        GestaoImovelRepositoryImpl(
          criarDataSource(ArmazenamentoTokenEmMemoria('token-de-teste')),
        ),
      );

      final resultado = await useCase(36);

      final lista = (resultado as Success<List<MudancaSituacao>>).data;
      expect(lista.map((m) => m.id), [1, 2]);
      expect(lista.first.situacaoNova, SituacaoImovel.vendido);
      expect(lista.last.situacaoNova, SituacaoImovel.reservado);
    });

    test('historico_contrato.json servido por responder chega inteiro',
        () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/historico/',
        status: 200,
        fixture: 'historico_contrato.json',
      );
      final useCase = ObterHistoricoSituacaoUseCase(
        GestaoImovelRepositoryImpl(
          criarDataSource(ArmazenamentoTokenEmMemoria('token-de-teste')),
        ),
      );

      final resultado = await useCase(36);

      final lista = (resultado as Success<List<MudancaSituacao>>).data;
      expect(lista, hasLength(1));
      expect(lista.single.alteradoPor, 'Gestor Demo');
      expect(lista.single.alteradoEm.isUtc, isTrue);
    });

    test('ApiFalsa: GET /api/imoveis/36/historico/ sem token é 401', () async {
      final useCase = ObterHistoricoSituacaoUseCase(
        GestaoImovelRepositoryImpl(
          criarDataSource(ArmazenamentoTokenEmMemoria()),
        ),
      );

      final resultado = await useCase(36);

      expect(resultado, isA<Failure<List<MudancaSituacao>>>());
      expect(
        (resultado as Failure<List<MudancaSituacao>>).erro,
        isA<SessaoExpiradaException>(),
      );
    });
  });

  group('GestaoImovelRemoteDataSource.obterHistorico', () {
    test('devolve os Models na ordem recebida', () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/historico/',
        status: 200,
        fixture: 'historico_um_item.json',
      );
      final datasource = criarDataSource(
        ArmazenamentoTokenEmMemoria('token-de-teste'),
      );

      final modelos = await datasource.obterHistorico(36);

      expect(modelos.single.situacaoNova, 'RESERVADO');
    });

    test('corpo que não é lista (objeto) lança FormatException', () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/historico/',
        status: 200,
        corpo: <String, Object?>{},
      );
      final datasource = criarDataSource(
        ArmazenamentoTokenEmMemoria('token-de-teste'),
      );

      await expectLater(
        datasource.obterHistorico(36),
        throwsA(isA<FormatException>()),
      );
    });

    test('item que não é objeto lança FormatException', () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/historico/',
        status: 200,
        corpo: <Object?>['texto solto'],
      );
      final datasource = criarDataSource(
        ArmazenamentoTokenEmMemoria('token-de-teste'),
      );

      await expectLater(
        datasource.obterHistorico(36),
        throwsA(isA<FormatException>()),
      );
    });

    test('sem token: DioException cujo error é SessaoExpiradaException',
        () async {
      final datasource = criarDataSource(ArmazenamentoTokenEmMemoria());

      await expectLater(
        datasource.obterHistorico(36),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<SessaoExpiradaException>(),
          ),
        ),
      );
    });
  });

  group('mudar situação — pilha de dados (UseCase → Repository → DataSource '
      '→ ApiFalsa)', () {
    MudarSituacaoUseCase criarUseCase(ArmazenamentoTokenEmMemoria armazenamento) =>
        MudarSituacaoUseCase(
          GestaoImovelRepositoryImpl(criarDataSource(armazenamento)),
        );

    test('MudarSituacaoUseCase(36, reservado) faz POST /api/imoveis/36/situacao/ '
        'com o token e o corpo exato {situacao: RESERVADO}', () async {
      final useCase = criarUseCase(ArmazenamentoTokenEmMemoria('token-de-teste'));

      final resultado = await useCase(36, SituacaoImovel.reservado);

      expect(resultado, isA<Success<void>>());
      final pedido = api.requisicoesGravadas.single;
      expect(pedido.metodo, 'POST');
      expect(pedido.uri.path, '/api/imoveis/36/situacao/');
      expect(pedido.cabecalho('Authorization'), 'Token token-de-teste');
      final chamada = api.chamadas.single;
      expect(chamada.corpo, {'situacao': 'RESERVADO'});
    });

    test('a observação vai sem espaços nas pontas', () async {
      final useCase = criarUseCase(ArmazenamentoTokenEmMemoria('token-de-teste'));

      final resultado = await useCase(
        36,
        SituacaoImovel.reservado,
        observacao: '  Sinal pago  ',
      );

      expect(resultado, isA<Success<void>>());
      expect(api.chamadas.single.corpo, {
        'situacao': 'RESERVADO',
        'observacao': 'Sinal pago',
      });
    });

    test('observação só com espaços não manda a chave observacao', () async {
      final useCase = criarUseCase(ArmazenamentoTokenEmMemoria('token-de-teste'));

      await useCase(36, SituacaoImovel.vendido, observacao: '   ');

      final corpo = api.chamadas.single.corpo! as Map<String, Object?>;
      expect(corpo, {'situacao': 'VENDIDO'});
      expect(corpo.containsKey('observacao'), isFalse);
    });

    test('o corpo não leva data nem autor (D-05)', () async {
      final useCase = criarUseCase(ArmazenamentoTokenEmMemoria('token-de-teste'));

      await useCase(36, SituacaoImovel.alugado, observacao: 'Contrato novo');

      final corpo = api.chamadas.single.corpo! as Map<String, Object?>;
      expect(corpo.keys, unorderedEquals(['situacao', 'observacao']));
    });

    test('200 com corpo inesperado ({}) continua Success: o 200 não é '
        'parseado (D-10)', () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/situacao/',
        status: 200,
        corpo: <String, Object?>{},
      );
      final useCase = criarUseCase(ArmazenamentoTokenEmMemoria('token-de-teste'));

      final resultado = await useCase(36, SituacaoImovel.reservado);

      expect(resultado, isA<Success<void>>());
    });

    test('200 com corpo que não é objeto também continua Success', () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/situacao/',
        status: 200,
        corpo: <Object?>['qualquer coisa'],
      );
      final useCase = criarUseCase(ArmazenamentoTokenEmMemoria('token-de-teste'));

      final resultado = await useCase(36, SituacaoImovel.reservado);

      expect(resultado, isA<Success<void>>());
    });

    test('ApiFalsa: POST sem token é 401 (SessaoExpiradaException)', () async {
      final useCase = criarUseCase(ArmazenamentoTokenEmMemoria());

      final resultado = await useCase(36, SituacaoImovel.reservado);

      expect(resultado, isA<Failure<void>>());
      expect((resultado as Failure<void>).erro, isA<SessaoExpiradaException>());
    });

    test('ApiFalsa: GET /api/imoveis/36/situacao/ é 405', () async {
      final dio = api.criarDioAutenticado(
        InterceptadorSessao(ArmazenamentoTokenEmMemoria('token-de-teste')),
      );

      await expectLater(
        dio.get<Object?>('/api/imoveis/36/situacao/'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            405,
          ),
        ),
      );
    });
  });

  group('GestaoImovelRemoteDataSource.mudarSituacao', () {
    test('POST com o código do Django e sem observacao quando vazia',
        () async {
      final datasource = criarDataSource(
        ArmazenamentoTokenEmMemoria('token-de-teste'),
      );

      await datasource.mudarSituacao(36, SituacaoImovel.disponivel, '');

      final chamada = api.chamadas.single;
      expect(chamada.metodo, 'POST');
      expect(chamada.uri.path, '/api/imoveis/36/situacao/');
      expect(chamada.corpo, {'situacao': 'DISPONIVEL'});
    });

    test('400 sobe como DioException (o repositório traduz)', () async {
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/situacao/',
        status: 400,
        fixture: 'erro_400_mesma_situacao.json',
      );
      final datasource = criarDataSource(
        ArmazenamentoTokenEmMemoria('token-de-teste'),
      );

      await expectLater(
        datasource.mudarSituacao(36, SituacaoImovel.reservado, ''),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            400,
          ),
        ),
      );
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
