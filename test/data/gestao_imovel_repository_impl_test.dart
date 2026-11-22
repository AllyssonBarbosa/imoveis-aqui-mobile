import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/gestao_imovel_datasource.dart';
import 'package:imoveis_aqui/data/datasources/gestao_imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/models/imovel_gestao_model.dart';
import 'package:imoveis_aqui/data/models/mudanca_situacao_model.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/data/repositories/gestao_imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/imovel_gestao.dart';
import 'package:imoveis_aqui/domain/entities/mudanca_situacao.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/repositories/gestao_imovel_repository.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:imoveis_aqui/domain/usecases/obter_historico_situacao_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_imovel_gestao_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';
import '../support/armazenamento_token_em_memoria.dart';

class _GestaoDataSourceFalso extends Mock implements GestaoImovelDataSource {}

class _GestaoRepositoryFalso extends Mock implements GestaoImovelRepository {}

RequestOptions _opcoes() => RequestOptions(path: '/api/imoveis/36/');

/// Erro de status com o corpo do servidor (texto em inglês do Django no 404).
DioException _erroDio({int? status, Object? corpo}) => DioException(
  requestOptions: _opcoes(),
  response: status == null
      ? null
      : Response<Object?>(
          requestOptions: _opcoes(),
          statusCode: status,
          data: corpo,
        ),
  type: status == null
      ? DioExceptionType.connectionTimeout
      : DioExceptionType.badResponse,
);

ImovelGestaoModel _modelo([Map<String, Object?> alteracoes = const {}]) =>
    ImovelGestaoModel.fromJson({
      ...(lerFixtureApi('imovel_gestao_disponivel.json')!
          as Map<String, Object?>),
      ...alteracoes,
    });

Exception? _falhaDe(Result<ImovelGestao> resultado) => switch (resultado) {
  Failure<ImovelGestao>(:final erro) => erro,
  _ => null,
};

MudancaSituacaoModel _itemDoHistorico([
  Map<String, Object?> alteracoes = const {},
]) => MudancaSituacaoModel.fromJson({
  ...((lerFixtureApi('historico_um_item.json')! as List<Object?>).single!
      as Map<String, Object?>),
  ...alteracoes,
});

Exception? _falhaDoHistorico(Result<List<MudancaSituacao>> resultado) =>
    switch (resultado) {
      Failure<List<MudancaSituacao>>(:final erro) => erro,
      _ => null,
    };

void main() {
  group('GestaoImovelRepositoryImpl.mudarSituacao', () {
    late _GestaoDataSourceFalso dataSource;
    late GestaoImovelRepository repositorio;

    setUp(() {
      dataSource = _GestaoDataSourceFalso();
      repositorio = GestaoImovelRepositoryImpl(dataSource);
    });

    Exception? falhaDe(Result<void> resultado) => switch (resultado) {
      Failure<void>(:final erro) => erro,
      _ => null,
    };

    void dataSourceLanca(Object erro) => when(
      () => dataSource.mudarSituacao(36, SituacaoImovel.reservado, any()),
    ).thenThrow(erro);

    Future<Result<void>> pedir({String observacao = ''}) => repositorio
        .mudarSituacao(36, SituacaoImovel.reservado, observacao: observacao);

    void confereUmaChamada() => verify(
      () => dataSource.mudarSituacao(36, SituacaoImovel.reservado, any()),
    ).called(1);

    test('sucesso devolve Success e repassa a observação ao DataSource',
        () async {
      when(
        () => dataSource.mudarSituacao(36, SituacaoImovel.reservado, 'Sinal'),
      ).thenAnswer((_) async {});

      final resultado = await pedir(observacao: 'Sinal');

      expect(resultado, isA<Success<void>>());
      verify(
        () => dataSource.mudarSituacao(36, SituacaoImovel.reservado, 'Sinal'),
      ).called(1);
    });

    test('400 com erro_400_contrato_assinado.json vira recusa com a mensagem '
        'do contrato', () async {
      dataSourceLanca(
        _erroDio(
          status: 400,
          corpo: lerFixtureApi('erro_400_contrato_assinado.json'),
        ),
      );

      final falha = falhaDe(await pedir());

      expect(falha, isA<MudancaSituacaoRecusadaException>());
      expect(
        (falha! as MudancaSituacaoRecusadaException).mensagem,
        contains('contrato assinado'),
      );
      confereUmaChamada();
    });

    test('403 com erro_403_situacao.json vira recusa com o detail', () async {
      dataSourceLanca(
        _erroDio(status: 403, corpo: lerFixtureApi('erro_403_situacao.json')),
      );

      final falha = falhaDe(await pedir());

      expect(falha, isA<MudancaSituacaoRecusadaException>());
      expect(
        (falha! as MudancaSituacaoRecusadaException).mensagem,
        startsWith('Só o corretor responsável'),
      );
      confereUmaChamada();
    });

    test('400 com corpo {} (sem texto) vira FalhaDeConexaoException',
        () async {
      dataSourceLanca(_erroDio(status: 400, corpo: <String, Object?>{}));

      expect(falhaDe(await pedir()), isA<FalhaDeConexaoException>());
      confereUmaChamada();
    });

    test('403 com corpo HTML vira FalhaDeConexaoException', () async {
      dataSourceLanca(_erroDio(status: 403, corpo: '<html>Proibido</html>'));

      expect(falhaDe(await pedir()), isA<FalhaDeConexaoException>());
    });

    test('404 com erro_404_imovel.json vira ImovelNaoEncontradoException e o '
        'inglês não sobe', () async {
      dataSourceLanca(
        _erroDio(status: 404, corpo: lerFixtureApi('erro_404_imovel.json')),
      );

      final falha = falhaDe(await pedir());

      expect(falha, isA<ImovelNaoEncontradoException>());
      expect(falha.toString(), isNot(contains('No Imovel matches')));
      confereUmaChamada();
    });

    test('DioException com error SessaoExpiradaException vira '
        'SessaoExpiradaException', () async {
      dataSourceLanca(
        _erroDio(status: 401).copyWith(error: const SessaoExpiradaException()),
      );

      expect(falhaDe(await pedir()), isA<SessaoExpiradaException>());
      confereUmaChamada();
    });

    test('connectionTimeout vira FalhaDeConexaoException', () async {
      dataSourceLanca(_erroDio());

      expect(falhaDe(await pedir()), isA<FalhaDeConexaoException>());
      confereUmaChamada();
    });

    test('receiveTimeout vira FalhaDeConexaoException', () async {
      dataSourceLanca(
        DioException(
          requestOptions: _opcoes(),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(falhaDe(await pedir()), isA<FalhaDeConexaoException>());
      confereUmaChamada();
    });

    test('connectionError vira FalhaDeConexaoException', () async {
      dataSourceLanca(
        DioException(
          requestOptions: _opcoes(),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(falhaDe(await pedir()), isA<FalhaDeConexaoException>());
      confereUmaChamada();
    });

    test('500 com corpo HTML vira FalhaDeConexaoException', () async {
      dataSourceLanca(_erroDio(status: 500, corpo: '<html>Erro</html>'));

      expect(falhaDe(await pedir()), isA<FalhaDeConexaoException>());
      confereUmaChamada();
    });

    test('MudancaSituacaoRecusadaException.toString não contém a mensagem',
        () {
      const recusa = MudancaSituacaoRecusadaException('X-segredo');

      expect(recusa.toString(), isNot(contains('X-segredo')));
      expect(recusa.mensagem, 'X-segredo');
    });

    test('pilha real: 400 da ApiFalsa (erro_400_mesma_situacao.json) vira '
        'recusa com a mensagem do servidor', () async {
      final api = ApiFalsa();
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/situacao/',
        status: 400,
        fixture: 'erro_400_mesma_situacao.json',
      );
      final real = GestaoImovelRepositoryImpl(
        GestaoImovelRemoteDataSource(
          api.criarDioAutenticado(
            InterceptadorSessao(ArmazenamentoTokenEmMemoria('token-de-teste')),
          ),
        ),
      );

      final resultado = await real.mudarSituacao(
        36,
        SituacaoImovel.reservado,
      );

      final falha = falhaDe(resultado);
      expect(falha, isA<MudancaSituacaoRecusadaException>());
      expect(
        (falha! as MudancaSituacaoRecusadaException).mensagem,
        'O imóvel já está reservado.',
      );
      // Sem nova tentativa: um POST só.
      expect(api.chamadas, hasLength(1));
    });

    test('pilha real: 500 do POST vira FalhaDeConexaoException com um POST '
        'só', () async {
      final api = ApiFalsa()..falharProximas('/api/imoveis/36/situacao/');
      final real = GestaoImovelRepositoryImpl(
        GestaoImovelRemoteDataSource(
          api.criarDioAutenticado(
            InterceptadorSessao(ArmazenamentoTokenEmMemoria('token-de-teste')),
          ),
        ),
      );

      final resultado = await real.mudarSituacao(
        36,
        SituacaoImovel.reservado,
      );

      expect(falhaDe(resultado), isA<FalhaDeConexaoException>());
      expect(api.chamadas, hasLength(1));
    });
  });

  group('GestaoImovelRepositoryImpl.obterHistorico', () {
    late _GestaoDataSourceFalso dataSource;
    late GestaoImovelRepository repositorio;

    setUp(() {
      dataSource = _GestaoDataSourceFalso();
      repositorio = GestaoImovelRepositoryImpl(dataSource);
    });

    test('devolve a lista de domínio na ordem do DataSource', () async {
      when(() => dataSource.obterHistorico(36)).thenAnswer(
        (_) async => [_itemDoHistorico({'id': 7}), _itemDoHistorico({'id': 3})],
      );

      final resultado = await repositorio.obterHistorico(36);

      final lista = (resultado as Success<List<MudancaSituacao>>).data;
      expect(lista.map((m) => m.id), [7, 3]);
    });

    test('a lista do Success é imutável (D-11)', () async {
      when(() => dataSource.obterHistorico(36))
          .thenAnswer((_) async => [_itemDoHistorico()]);

      final resultado = await repositorio.obterHistorico(36);

      final lista = (resultado as Success<List<MudancaSituacao>>).data;
      expect(
        () => lista.add(lista.first),
        throwsUnsupportedError,
      );
      expect(lista.clear, throwsUnsupportedError);
    });

    test('SessaoExpiradaException (direta ou no DioException) vira Failure '
        'com ela', () async {
      when(() => dataSource.obterHistorico(36)).thenThrow(
        _erroDio(status: 401).copyWith(error: const SessaoExpiradaException()),
      );

      final resultado = await repositorio.obterHistorico(36);

      expect(_falhaDoHistorico(resultado), isA<SessaoExpiradaException>());
    });

    test('404 (erro_404_historico.json) vira ImovelNaoEncontradoException e o '
        'texto em inglês do servidor não sobe', () async {
      final corpo404 = lerFixtureApi('erro_404_historico.json');
      when(() => dataSource.obterHistorico(36))
          .thenThrow(_erroDio(status: 404, corpo: corpo404));

      final resultado = await repositorio.obterHistorico(36);

      final falha = _falhaDoHistorico(resultado);
      expect(falha, isA<ImovelNaoEncontradoException>());
      expect(falha.toString(), isNot(contains('No Imovel matches')));
    });

    test('500 vira FalhaDeConexaoException', () async {
      when(() => dataSource.obterHistorico(36))
          .thenThrow(_erroDio(status: 500, corpo: 'Internal Server Error'));

      final resultado = await repositorio.obterHistorico(36);

      expect(_falhaDoHistorico(resultado), isA<FalhaDeConexaoException>());
    });

    test('connectionTimeout vira FalhaDeConexaoException', () async {
      when(() => dataSource.obterHistorico(36)).thenThrow(_erroDio());

      final resultado = await repositorio.obterHistorico(36);

      expect(_falhaDoHistorico(resultado), isA<FalhaDeConexaoException>());
    });

    test('FormatException do DataSource vira FalhaDeConexaoException',
        () async {
      when(() => dataSource.obterHistorico(36))
          .thenThrow(const FormatException('histórico: corpo não é lista'));

      final resultado = await repositorio.obterHistorico(36);

      expect(_falhaDoHistorico(resultado), isA<FalhaDeConexaoException>());
    });

    test('TypeError (alterado_em numérico) vira FalhaDeConexaoException',
        () async {
      // O `fromJson` do freezed lança TypeError ao ler um número como String.
      when(() => dataSource.obterHistorico(36)).thenAnswer(
        (_) async => [_itemDoHistorico({'alterado_em': 12345})],
      );

      final resultado = await repositorio.obterHistorico(36);

      expect(_falhaDoHistorico(resultado), isA<FalhaDeConexaoException>());
    });

    test('alterado_em inválido (FormatException na entidade) vira '
        'FalhaDeConexaoException', () async {
      when(() => dataSource.obterHistorico(36)).thenAnswer(
        (_) async => [_itemDoHistorico({'alterado_em': 'ontem'})],
      );

      final resultado = await repositorio.obterHistorico(36);

      expect(_falhaDoHistorico(resultado), isA<FalhaDeConexaoException>());
    });

    test('pilha real sem token: 401 da ApiFalsa vira SessaoExpiradaException',
        () async {
      final real = GestaoImovelRepositoryImpl(
        GestaoImovelRemoteDataSource(
          ApiFalsa().criarDioAutenticado(
            InterceptadorSessao(ArmazenamentoTokenEmMemoria()),
          ),
        ),
      );

      final resultado = await real.obterHistorico(36);

      expect(_falhaDoHistorico(resultado), isA<SessaoExpiradaException>());
    });

    test('pilha real: 404 com erro_404_historico.json vira '
        'ImovelNaoEncontradoException', () async {
      final api = ApiFalsa();
      api.responder(
        (uri) => uri.path == '/api/imoveis/999/historico/',
        status: 404,
        fixture: 'erro_404_historico.json',
      );
      final real = GestaoImovelRepositoryImpl(
        GestaoImovelRemoteDataSource(
          api.criarDioAutenticado(
            InterceptadorSessao(ArmazenamentoTokenEmMemoria('token-de-teste')),
          ),
        ),
      );

      final resultado = await real.obterHistorico(999);

      expect(_falhaDoHistorico(resultado), isA<ImovelNaoEncontradoException>());
    });
  });

  group('GestaoImovelRepositoryImpl', () {
    late _GestaoDataSourceFalso dataSource;
    late GestaoImovelRepository repositorio;

    setUp(() {
      dataSource = _GestaoDataSourceFalso();
      repositorio = GestaoImovelRepositoryImpl(dataSource);
    });

    test('obterImovel devolve o ImovelGestao de domínio', () async {
      when(() => dataSource.obterImovel(36)).thenAnswer((_) async => _modelo());

      final resultado = await repositorio.obterImovel(36);

      expect(resultado, isA<Success<ImovelGestao>>());
      final imovel = (resultado as Success<ImovelGestao>).data;
      expect(imovel.id, 36);
      expect(imovel.podeMudarSituacao, isTrue);
    });

    test('SessaoExpiradaException direta vira Failure com ela', () async {
      when(() => dataSource.obterImovel(36))
          .thenThrow(const SessaoExpiradaException());

      final resultado = await repositorio.obterImovel(36);

      expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
    });

    test('DioException com error SessaoExpiradaException vira Failure com '
        'ela', () async {
      when(() => dataSource.obterImovel(36)).thenThrow(
        _erroDio(status: 401).copyWith(error: const SessaoExpiradaException()),
      );

      final resultado = await repositorio.obterImovel(36);

      expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
    });

    test('404 vira ImovelNaoEncontradoException e o texto em inglês do '
        'servidor não sobe', () async {
      final corpo404 = lerFixtureApi('erro_404_imovel.json');
      when(() => dataSource.obterImovel(36))
          .thenThrow(_erroDio(status: 404, corpo: corpo404));

      final resultado = await repositorio.obterImovel(36);

      final falha = _falhaDe(resultado);
      expect(falha, isA<ImovelNaoEncontradoException>());
      expect(falha.toString(), isNot(contains('No Imovel matches')));
    });

    test('500 vira FalhaDeConexaoException', () async {
      when(() => dataSource.obterImovel(36))
          .thenThrow(_erroDio(status: 500, corpo: 'Internal Server Error'));

      final resultado = await repositorio.obterImovel(36);

      expect(_falhaDe(resultado), isA<FalhaDeConexaoException>());
    });

    test('timeout de conexão vira FalhaDeConexaoException', () async {
      when(() => dataSource.obterImovel(36)).thenThrow(_erroDio());

      final resultado = await repositorio.obterImovel(36);

      expect(_falhaDe(resultado), isA<FalhaDeConexaoException>());
    });

    test('situacao_desde inválido (FormatException) vira '
        'FalhaDeConexaoException', () async {
      when(() => dataSource.obterImovel(36))
          .thenAnswer((_) async => _modelo({'situacao_desde': 'ontem'}));

      final resultado = await repositorio.obterImovel(36);

      expect(_falhaDe(resultado), isA<FalhaDeConexaoException>());
    });

    test(
      'item com tipo errado (TypeError) vira FalhaDeConexaoException',
      () async {
        when(() => dataSource.obterImovel(36)).thenThrow(TypeError());

        final resultado = await repositorio.obterImovel(36);

        expect(_falhaDe(resultado), isA<FalhaDeConexaoException>());
      },
    );

    test('pilha real sem token: o 401 da ApiFalsa vira '
        'SessaoExpiradaException', () async {
      final api = ApiFalsa();
      api.responder(
        (uri) => uri.path == '/api/imoveis/36/',
        status: 401,
        fixture: 'erro_401.json',
      );
      final real = GestaoImovelRepositoryImpl(
        GestaoImovelRemoteDataSource(
          api.criarDioAutenticado(
            InterceptadorSessao(ArmazenamentoTokenEmMemoria()),
          ),
        ),
      );

      final resultado = await real.obterImovel(36);

      expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
    });

    test('pilha real com token: o 404 da ApiFalsa (erro_404_imovel.json) vira '
        'ImovelNaoEncontradoException', () async {
      final api = ApiFalsa();
      api.responder(
        (uri) => uri.path == '/api/imoveis/999/',
        status: 404,
        fixture: 'erro_404_imovel.json',
      );
      final real = GestaoImovelRepositoryImpl(
        GestaoImovelRemoteDataSource(
          api.criarDioAutenticado(
            InterceptadorSessao(ArmazenamentoTokenEmMemoria('token-de-teste')),
          ),
        ),
      );

      final resultado = await real.obterImovel(999);

      expect(_falhaDe(resultado), isA<ImovelNaoEncontradoException>());
    });
  });

  group('ObterImovelGestaoUseCase', () {
    test('call repassa o id ao repositório e devolve o mesmo Result', () async {
      final repositorio = _GestaoRepositoryFalso();
      final useCase = ObterImovelGestaoUseCase(repositorio);
      final esperado = Result<ImovelGestao>.failure(
        const ImovelNaoEncontradoException(),
      );
      when(() => repositorio.obterImovel(36)).thenAnswer((_) async => esperado);

      final resultado = await useCase(36);

      expect(resultado, same(esperado));
      verify(() => repositorio.obterImovel(36)).called(1);
    });
  });

  group('ObterHistoricoSituacaoUseCase', () {
    test('call repassa o id ao repositório e devolve o mesmo Result', () async {
      final repositorio = _GestaoRepositoryFalso();
      final useCase = ObterHistoricoSituacaoUseCase(repositorio);
      final esperado = Result<List<MudancaSituacao>>.success(const []);
      when(() => repositorio.obterHistorico(36))
          .thenAnswer((_) async => esperado);

      final resultado = await useCase(36);

      expect(resultado, same(esperado));
      verify(() => repositorio.obterHistorico(36)).called(1);
    });
  });
}
