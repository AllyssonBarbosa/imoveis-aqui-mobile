import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/gestao_imovel_datasource.dart';
import 'package:imoveis_aqui/data/datasources/gestao_imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/models/imovel_gestao_model.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/data/repositories/gestao_imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/imovel_gestao.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/repositories/gestao_imovel_repository.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
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

void main() {
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
}
