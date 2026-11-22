import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/armazenamento_token.dart';
import 'package:imoveis_aqui/data/datasources/autenticacao_datasource.dart';
import 'package:imoveis_aqui/data/repositories/autenticacao_repository_impl.dart';
import 'package:imoveis_aqui/domain/repositories/autenticacao_repository.dart';
import 'package:imoveis_aqui/domain/usecases/ler_sessao_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/sair_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _RepositorioFalso extends Mock implements AutenticacaoRepository {}

class _DataSourceFalso extends Mock implements AutenticacaoDataSource {}

class _ArmazenamentoFalso extends Mock implements ArmazenamentoToken {}

void main() {
  late _RepositorioFalso repositorio;

  setUp(() {
    repositorio = _RepositorioFalso();
  });

  test('SairUseCase chama sair() do repositório uma vez e completa', () async {
    when(() => repositorio.sair()).thenAnswer((_) async {});

    await SairUseCase(repositorio)();

    verify(() => repositorio.sair()).called(1);
  });

  test('pilha real: servidor com DioException e apagar() com '
      'PlatformException, Sair completa sem lançar', () async {
    final dataSource = _DataSourceFalso();
    final armazenamento = _ArmazenamentoFalso();
    when(() => dataSource.sair()).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/api/auth/sair/'),
        type: DioExceptionType.connectionError,
      ),
    );
    when(() => armazenamento.apagar())
        .thenThrow(PlatformException(code: 'falha'));

    final caso = SairUseCase(
      AutenticacaoRepositoryImpl(dataSource, armazenamento),
    );

    await expectLater(caso(), completes);
    verify(() => armazenamento.apagar()).called(1);
  });

  test('pilha real: servidor respondendo 401 também completa e apaga o '
      'token do aparelho', () async {
    final dataSource = _DataSourceFalso();
    final armazenamento = _ArmazenamentoFalso();
    final opcoes = RequestOptions(path: '/api/auth/sair/');
    when(() => dataSource.sair()).thenThrow(
      DioException(
        requestOptions: opcoes,
        type: DioExceptionType.badResponse,
        response: Response<Object?>(requestOptions: opcoes, statusCode: 401),
      ),
    );
    when(() => armazenamento.apagar()).thenAnswer((_) async {});

    await expectLater(
      SairUseCase(AutenticacaoRepositoryImpl(dataSource, armazenamento))(),
      completes,
    );
    verify(() => armazenamento.apagar()).called(1);
  });

  test('LerSessaoUseCase devolve temSessaoGuardada()', () async {
    when(() => repositorio.temSessaoGuardada()).thenAnswer((_) async => true);
    expect(await LerSessaoUseCase(repositorio)(), isTrue);

    when(() => repositorio.temSessaoGuardada()).thenAnswer((_) async => false);
    expect(await LerSessaoUseCase(repositorio)(), isFalse);
  });
}
