import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/armazenamento_token.dart';
import 'package:imoveis_aqui/data/datasources/autenticacao_datasource.dart';
import 'package:imoveis_aqui/data/repositories/autenticacao_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/papel.dart';
import 'package:imoveis_aqui/domain/repositories/autenticacao_repository.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/entrar_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_papel_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _RepositorioFalso extends Mock implements AutenticacaoRepository {}

class _DataSourceFalso extends Mock implements AutenticacaoDataSource {}

class _ArmazenamentoFalso extends Mock implements ArmazenamentoToken {}

Exception _falha(Result<Object?> resultado) =>
    (resultado as Failure<Object?>).erro;

void main() {
  late _RepositorioFalso repositorio;
  late EntrarUseCase caso;

  setUp(() {
    repositorio = _RepositorioFalso();
    caso = EntrarUseCase(repositorio);
    when(() => repositorio.descartarSessaoLocal()).thenAnswer((_) async {});
  });

  void loginOk() => when(
    () => repositorio.entrar(
      email: any(named: 'email'),
      senha: any(named: 'senha'),
    ),
  ).thenAnswer((_) async => Result.success(null));

  test('login e papel ok devolvem o papel e não descartam a sessão', () async {
    loginOk();
    when(() => repositorio.obterPapel())
        .thenAnswer((_) async => Result.success(Papel.corretor));

    final resultado = await caso(email: 'a@b.com', senha: 'x');

    expect(resultado, isA<Success<Papel>>());
    expect((resultado as Success<Papel>).data, Papel.corretor);
    verifyNever(() => repositorio.descartarSessaoLocal());
  });

  for (final falhaDeLogin in <Exception>[
    const CredenciaisInvalidasException(),
    const LimiteTentativasException(aguardar: Duration(seconds: 30)),
    const FalhaDeConexaoException(),
  ]) {
    test('login falha com ${falhaDeLogin.runtimeType}: devolve a mesma '
        'falha e não pergunta o papel', () async {
      when(
        () => repositorio.entrar(
          email: any(named: 'email'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer((_) async => Result.failure(falhaDeLogin));

      final resultado = await caso(email: 'a@b.com', senha: 'x');

      expect(_falha(resultado), same(falhaDeLogin));
      verifyNever(() => repositorio.obterPapel());
      verifyNever(() => repositorio.descartarSessaoLocal());
    });
  }

  for (final falhaDePapel in <Exception>[
    const FalhaDeConexaoException(),
    const FormatException('perfil desconhecido: X'),
    const SessaoExpiradaException(),
  ]) {
    test('papel falha com ${falhaDePapel.runtimeType}: descarta a sessão '
        'local uma vez e devolve a falha', () async {
      loginOk();
      when(() => repositorio.obterPapel())
          .thenAnswer((_) async => Result.failure(falhaDePapel));

      final resultado = await caso(email: 'a@b.com', senha: 'x');

      expect(_falha(resultado), same(falhaDePapel));
      verify(() => repositorio.descartarSessaoLocal()).called(1);
    });
  }

  test('pilha real: rollback com apagar() lançando PlatformException '
      'devolve a falha do papel sem lançar', () async {
    final dataSource = _DataSourceFalso();
    final armazenamento = _ArmazenamentoFalso();
    when(
      () => dataSource.entrar(
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    ).thenAnswer((_) async => 'token-123');
    when(() => dataSource.obterEu()).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/api/auth/eu/'),
        type: DioExceptionType.connectionError,
      ),
    );
    when(() => armazenamento.salvar(any())).thenAnswer((_) async {});
    when(() => armazenamento.apagar())
        .thenThrow(PlatformException(code: 'falha'));

    final casoReal = EntrarUseCase(
      AutenticacaoRepositoryImpl(dataSource, armazenamento),
    );

    final resultado = await casoReal(email: 'a@b.com', senha: 'x');

    expect(_falha(resultado), isA<FalhaDeConexaoException>());
    verify(() => armazenamento.apagar()).called(1);
  });

  test('ObterPapelUseCase repassa o resultado do repositório', () async {
    when(() => repositorio.obterPapel())
        .thenAnswer((_) async => Result.success(Papel.gestor));
    final sucesso = await ObterPapelUseCase(repositorio)();
    expect((sucesso as Success<Papel>).data, Papel.gestor);

    const falha = SessaoExpiradaException();
    when(() => repositorio.obterPapel())
        .thenAnswer((_) async => Result.failure(falha));
    final fracasso = await ObterPapelUseCase(repositorio)();
    expect(_falha(fracasso), same(falha));
  });
}
