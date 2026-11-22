import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/armazenamento_token.dart';
import 'package:imoveis_aqui/data/datasources/autenticacao_datasource.dart';
import 'package:imoveis_aqui/data/repositories/autenticacao_repository_impl.dart';
import 'package:imoveis_aqui/domain/usecases/descartar_sessao_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/ler_sessao_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/sair_usecase.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

class _LerSessaoFalso extends Mock implements LerSessaoUseCase {}

class _SairFalso extends Mock implements SairUseCase {}

class _DescartarSessaoFalso extends Mock implements DescartarSessaoUseCase {}

class _DataSourceFalso extends Mock implements AutenticacaoDataSource {}

class _ArmazenamentoFalso extends Mock implements ArmazenamentoToken {}

void main() {
  late _LerSessaoFalso lerSessao;
  late _SairFalso sair;
  late _DescartarSessaoFalso descartarSessao;

  setUp(() {
    lerSessao = _LerSessaoFalso();
    sair = _SairFalso();
    descartarSessao = _DescartarSessaoFalso();
    when(() => sair()).thenAnswer((_) async {});
    when(() => descartarSessao()).thenAnswer((_) async {});
  });

  SessaoCubit criar() => SessaoCubit(lerSessao, sair, descartarSessao);

  test('estado inicial é verificando', () {
    final cubit = criar();
    expect(cubit.state, const SessaoState.verificando());
    cubit.close();
  });

  blocTest<SessaoCubit, SessaoState>(
    'carregar com sessão guardada emite autenticada',
    setUp: () => when(() => lerSessao()).thenAnswer((_) async => true),
    build: criar,
    act: (cubit) => cubit.carregar(),
    expect: () => [const SessaoState.autenticada()],
  );

  blocTest<SessaoCubit, SessaoState>(
    'carregar sem sessão guardada emite anonima',
    setUp: () => when(() => lerSessao()).thenAnswer((_) async => false),
    build: criar,
    act: (cubit) => cubit.carregar(),
    expect: () => [const SessaoState.anonima()],
  );

  blocTest<SessaoCubit, SessaoState>(
    'marcarAutenticada emite autenticada',
    build: criar,
    act: (cubit) => cubit.marcarAutenticada(),
    expect: () => [const SessaoState.autenticada()],
  );

  blocTest<SessaoCubit, SessaoState>(
    'marcarAnonima emite anonima',
    build: criar,
    seed: () => const SessaoState.autenticada(),
    act: (cubit) => cubit.marcarAnonima(),
    expect: () => [const SessaoState.anonima()],
  );

  blocTest<SessaoCubit, SessaoState>(
    'sair chama o use case uma vez e termina anônimo a partir de autenticada',
    build: criar,
    seed: () => const SessaoState.autenticada(),
    act: (cubit) => cubit.sair(),
    expect: () => [const SessaoState.anonima()],
    verify: (_) => verify(() => sair()).called(1),
  );

  blocTest<SessaoCubit, SessaoState>(
    'encerrarPorExpiracao descarta a sessão local e termina anônimo (WR-03)',
    build: criar,
    seed: () => const SessaoState.autenticada(),
    act: (cubit) => cubit.encerrarPorExpiracao(),
    expect: () => [const SessaoState.anonima()],
    verify: (_) {
      verify(() => descartarSessao()).called(1);
      verifyNever(() => sair());
    },
  );

  test(
    'pilha real: 401 com apagar() lançando PlatformException, '
    'encerrarPorExpiracao tenta apagar de novo e termina anônimo (WR-03)',
    () async {
      final armazenamento = _ArmazenamentoFalso();
      when(() => armazenamento.apagar())
          .thenThrow(PlatformException(code: 'falha'));
      final cubit = SessaoCubit(
        lerSessao,
        sair,
        DescartarSessaoUseCase(
          AutenticacaoRepositoryImpl(_DataSourceFalso(), armazenamento),
        ),
      )..marcarAutenticada();

      await expectLater(cubit.encerrarPorExpiracao(), completes);

      expect(cubit.state, const SessaoState.anonima());
      verify(() => armazenamento.apagar()).called(1);
      await cubit.close();
    },
  );

  test('pilha real: servidor fora e apagar() lançando PlatformException, '
      'sair completa sem erro e termina anônimo', () async {
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

    final cubit = SessaoCubit(
      lerSessao,
      SairUseCase(AutenticacaoRepositoryImpl(dataSource, armazenamento)),
      descartarSessao,
    )..marcarAutenticada();
    expect(cubit.state, const SessaoState.autenticada());

    await expectLater(cubit.sair(), completes);

    expect(cubit.state, const SessaoState.anonima());
    verify(() => armazenamento.apagar()).called(1);
    await cubit.close();
  });

  test('regressão do contrato: use case que lança deixa o estado anônimo '
      '(o finally emite) e a falha sobe', () async {
    when(() => sair()).thenThrow(Exception('contrato quebrado'));
    final cubit = criar()..marcarAutenticada();

    await expectLater(cubit.sair(), throwsA(isA<Exception>()));

    expect(cubit.state, const SessaoState.anonima());
    await cubit.close();
  });

  test('carregar só lê o aparelho: não usa o use case de sair', () async {
    when(() => lerSessao()).thenAnswer((_) async => true);
    final cubit = criar();

    await cubit.carregar();

    verify(() => lerSessao()).called(1);
    verifyNever(() => sair());
    await cubit.close();
  });
}
