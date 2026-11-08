import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/perfil_corretor.dart';
import 'package:imoveis_aqui/domain/repositories/perfil_repository.dart';
import 'package:imoveis_aqui/domain/usecases/obter_perfil_corretor_usecase.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_corretor_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_state.dart';
import 'package:mocktail/mocktail.dart';

class _ObterPerfilCorretorUseCaseFalso extends Mock
    implements ObterPerfilCorretorUseCase {}

void main() {
  late _ObterPerfilCorretorUseCaseFalso obterPerfil;

  const marina = PerfilCorretor(id: 7, nome: 'Marina Lopes', creci: '12345-F');

  setUp(() {
    obterPerfil = _ObterPerfilCorretorUseCaseFalso();
  });

  PerfilCorretorCubit construir() => PerfilCorretorCubit(obterPerfil);

  test('estado inicial é carregando', () {
    expect(
      construir().state,
      const PerfilState<PerfilCorretor>.carregando(),
    );
  });

  blocTest<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
    'carregar(7) com sucesso emite [carregado]',
    build: construir,
    setUp: () {
      when(() => obterPerfil(7))
          .thenAnswer((_) async => const Result.success(marina));
    },
    act: (cubit) => cubit.carregar(7),
    expect: () => [const PerfilState<PerfilCorretor>.carregado(marina)],
  );

  blocTest<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
    'PerfilNaoEncontradoException emite [naoEncontrado] (404, D-15)',
    build: construir,
    setUp: () {
      when(() => obterPerfil(7)).thenAnswer(
        (_) async => Result.failure(const PerfilNaoEncontradoException()),
      );
    },
    act: (cubit) => cubit.carregar(7),
    expect: () => [const PerfilState<PerfilCorretor>.naoEncontrado()],
  );

  blocTest<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
    'Exception genérica emite [erro]',
    build: construir,
    setUp: () {
      when(() => obterPerfil(7))
          .thenAnswer((_) async => Result.failure(Exception('rede')));
    },
    act: (cubit) => cubit.carregar(7),
    expect: () => [const PerfilState<PerfilCorretor>.erro()],
  );

  blocTest<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
    'FormatException emite [erro]',
    build: construir,
    setUp: () {
      when(() => obterPerfil(7))
          .thenAnswer((_) async => Result.failure(const FormatException('x')));
    },
    act: (cubit) => cubit.carregar(7),
    expect: () => [const PerfilState<PerfilCorretor>.erro()],
  );

  blocTest<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
    'de erro, tentarNovamente() emite [carregando, carregado] no 2º sucesso',
    build: construir,
    setUp: () {
      var chamadas = 0;
      when(() => obterPerfil(7)).thenAnswer((_) async {
        chamadas++;
        return chamadas == 1
            ? Result.failure(Exception('rede'))
            : const Result.success(marina);
      });
    },
    act: (cubit) async {
      await cubit.carregar(7);
      await cubit.tentarNovamente();
    },
    expect: () => [
      const PerfilState<PerfilCorretor>.erro(),
      const PerfilState<PerfilCorretor>.carregando(),
      const PerfilState<PerfilCorretor>.carregado(marina),
    ],
    verify: (_) => verify(() => obterPerfil(7)).called(2),
  );

  blocTest<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
    'duas chamadas seguidas de tentarNovamente() fazem uma única busca extra',
    build: construir,
    setUp: () {
      var chamadas = 0;
      when(() => obterPerfil(7)).thenAnswer((_) async {
        chamadas++;
        return chamadas == 1
            ? Result.failure(Exception('rede'))
            : const Result.success(marina);
      });
    },
    act: (cubit) async {
      await cubit.carregar(7);
      final primeira = cubit.tentarNovamente();
      final segunda = cubit.tentarNovamente();
      await Future.wait([primeira, segunda]);
    },
    expect: () => [
      const PerfilState<PerfilCorretor>.erro(),
      const PerfilState<PerfilCorretor>.carregando(),
      const PerfilState<PerfilCorretor>.carregado(marina),
    ],
    verify: (_) => verify(() => obterPerfil(7)).called(2),
  );

  blocTest<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
    'tentarNovamente() antes de qualquer carregar não emite nada',
    build: construir,
    act: (cubit) => cubit.tentarNovamente(),
    expect: () => <PerfilState<PerfilCorretor>>[],
    verify: (_) => verifyNever(() => obterPerfil(any())),
  );

  blocTest<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
    'tentarNovamente() enquanto carregando não emite nem busca de novo',
    build: construir,
    setUp: () {
      when(() => obterPerfil(7))
          .thenAnswer((_) => Completer<Result<PerfilCorretor>>().future);
    },
    act: (cubit) {
      unawaited(cubit.carregar(7));
      return cubit.tentarNovamente();
    },
    expect: () => <PerfilState<PerfilCorretor>>[],
    verify: (_) => verify(() => obterPerfil(7)).called(1),
  );

  blocTest<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
    'tentarNovamente() no 404 não emite nem busca de novo (repetir não '
    'resolve)',
    build: construir,
    setUp: () {
      when(() => obterPerfil(7)).thenAnswer(
        (_) async => Result.failure(const PerfilNaoEncontradoException()),
      );
    },
    act: (cubit) async {
      await cubit.carregar(7);
      await cubit.tentarNovamente();
    },
    expect: () => [const PerfilState<PerfilCorretor>.naoEncontrado()],
    verify: (_) => verify(() => obterPerfil(7)).called(1),
  );

  test(
    'fechar o Cubit antes do use case terminar não emite nem falha',
    () async {
      final completer = Completer<Result<PerfilCorretor>>();
      when(() => obterPerfil(7)).thenAnswer((_) => completer.future);
      final cubit = construir();
      final emitidos = <PerfilState<PerfilCorretor>>[];
      final inscricao = cubit.stream.listen(emitidos.add);

      final carga = cubit.carregar(7);
      await cubit.close();
      completer.complete(const Result.success(marina));
      await carga;

      expect(emitidos, isEmpty);
      await inscricao.cancel();
    },
  );
}
