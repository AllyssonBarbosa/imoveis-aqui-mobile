import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/papel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/entrar_usecase.dart';
import 'package:imoveis_aqui/presentation/login/login_cubit.dart';
import 'package:imoveis_aqui/presentation/login/login_state.dart';
import 'package:mocktail/mocktail.dart';

class _EntrarFalso extends Mock implements EntrarUseCase {}

void main() {
  late _EntrarFalso entrar;

  setUp(() {
    entrar = _EntrarFalso();
  });

  LoginCubit construir() => LoginCubit(entrar);

  test('estado inicial é editando', () {
    expect(construir().state, const LoginState.editando());
  });

  blocTest<LoginCubit, LoginState>(
    'sucesso emite [enviando, entrou(corretor)] com e-mail e senha como digitados',
    build: construir,
    setUp: () {
      when(() => entrar(email: 'a@b.com', senha: ' segredo '))
          .thenAnswer((_) async => const Result.success(Papel.corretor));
    },
    act: (cubit) => cubit.entrar(email: 'a@b.com', senha: ' segredo '),
    expect: () => [
      const LoginState.enviando(),
      const LoginState.entrou(Papel.corretor),
    ],
    verify: (_) {
      verify(() => entrar(email: 'a@b.com', senha: ' segredo ')).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'credencial inválida emite [enviando, falha(texto fixo)]',
    build: construir,
    setUp: () {
      when(
        () => entrar(
          email: any(named: 'email'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer(
        (_) async => Result.failure(const CredenciaisInvalidasException()),
      );
    },
    act: (cubit) => cubit.entrar(email: 'a@b.com', senha: 'x'),
    expect: () => [
      const LoginState.enviando(),
      const LoginState.falha(mensagem: 'E-mail ou senha inválidos.'),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    '429 emite a mensagem com os minutos do Retry-After',
    build: construir,
    setUp: () {
      when(
        () => entrar(
          email: any(named: 'email'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer(
        (_) async => Result.failure(
          const LimiteTentativasException(aguardar: Duration(seconds: 61)),
        ),
      );
    },
    act: (cubit) => cubit.entrar(email: 'a@b.com', senha: 'x'),
    expect: () => [
      const LoginState.enviando(),
      const LoginState.falha(
        mensagem: 'Muitas tentativas. Tente de novo em 2 minutos.',
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'falha de rede emite a mensagem genérica do app',
    build: construir,
    setUp: () {
      when(
        () => entrar(
          email: any(named: 'email'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer(
        (_) async => Result.failure(const FalhaDeConexaoException()),
      );
    },
    act: (cubit) => cubit.entrar(email: 'a@b.com', senha: 'x'),
    expect: () => [
      const LoginState.enviando(),
      const LoginState.falha(
        mensagem: 'Não foi possível entrar agora. Tente de novo.',
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'segundo entrar durante enviando é ignorado',
    build: construir,
    setUp: () {
      final espera = Completer<Result<Papel>>();
      when(
        () => entrar(
          email: any(named: 'email'),
          senha: any(named: 'senha'),
        ),
      ).thenAnswer((_) => espera.future);
    },
    act: (cubit) {
      unawaited(cubit.entrar(email: 'a@b.com', senha: 'x'));
      return cubit.entrar(email: 'a@b.com', senha: 'x');
    },
    expect: () => [const LoginState.enviando()],
    verify: (_) {
      verify(
        () => entrar(
          email: any(named: 'email'),
          senha: any(named: 'senha'),
        ),
      ).called(1);
    },
  );

  test('não emite depois de fechado', () async {
    final espera = Completer<Result<Papel>>();
    when(
      () => entrar(
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    ).thenAnswer((_) => espera.future);
    final cubit = construir();
    final emitidos = <LoginState>[];
    final inscricao = cubit.stream.listen(emitidos.add);

    final envio = cubit.entrar(email: 'a@b.com', senha: 'x');
    await cubit.close();
    espera.complete(const Result.success(Papel.corretor));
    await envio;
    await inscricao.cancel();

    expect(emitidos, [const LoginState.enviando()]);
  });
}
