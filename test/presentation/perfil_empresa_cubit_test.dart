import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/perfil_empresa.dart';
import 'package:imoveis_aqui/domain/repositories/perfil_repository.dart';
import 'package:imoveis_aqui/domain/usecases/obter_perfil_empresa_usecase.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_empresa_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_state.dart';
import 'package:mocktail/mocktail.dart';

class _ObterPerfilEmpresaUseCaseFalso extends Mock
    implements ObterPerfilEmpresaUseCase {}

void main() {
  late _ObterPerfilEmpresaUseCaseFalso obterPerfil;

  const jequitiba = PerfilEmpresa(
    id: 3,
    nome: 'Imobiliária Jequitibá',
    creci: 'J-1234',
  );

  setUp(() {
    obterPerfil = _ObterPerfilEmpresaUseCaseFalso();
  });

  PerfilEmpresaCubit construir() => PerfilEmpresaCubit(obterPerfil);

  test('estado inicial é carregando', () {
    expect(construir().state, const PerfilState<PerfilEmpresa>.carregando());
  });

  blocTest<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
    'carregar(3) com sucesso emite [carregado]',
    build: construir,
    setUp: () {
      when(() => obterPerfil(3))
          .thenAnswer((_) async => const Result.success(jequitiba));
    },
    act: (cubit) => cubit.carregar(3),
    expect: () => [const PerfilState<PerfilEmpresa>.carregado(jequitiba)],
  );

  blocTest<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
    'PerfilNaoEncontradoException emite [naoEncontrado] (404, D-15)',
    build: construir,
    setUp: () {
      when(() => obterPerfil(3)).thenAnswer(
        (_) async => Result.failure(const PerfilNaoEncontradoException()),
      );
    },
    act: (cubit) => cubit.carregar(3),
    expect: () => [const PerfilState<PerfilEmpresa>.naoEncontrado()],
  );

  blocTest<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
    'Exception genérica emite [erro]',
    build: construir,
    setUp: () {
      when(() => obterPerfil(3))
          .thenAnswer((_) async => Result.failure(Exception('rede')));
    },
    act: (cubit) => cubit.carregar(3),
    expect: () => [const PerfilState<PerfilEmpresa>.erro()],
  );

  blocTest<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
    'FormatException emite [erro]',
    build: construir,
    setUp: () {
      when(() => obterPerfil(3))
          .thenAnswer((_) async => Result.failure(const FormatException('x')));
    },
    act: (cubit) => cubit.carregar(3),
    expect: () => [const PerfilState<PerfilEmpresa>.erro()],
  );

  blocTest<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
    'de erro, tentarNovamente() emite [carregando, carregado] no 2º sucesso',
    build: construir,
    setUp: () {
      var chamadas = 0;
      when(() => obterPerfil(3)).thenAnswer((_) async {
        chamadas++;
        return chamadas == 1
            ? Result.failure(Exception('rede'))
            : const Result.success(jequitiba);
      });
    },
    act: (cubit) async {
      await cubit.carregar(3);
      await cubit.tentarNovamente();
    },
    expect: () => [
      const PerfilState<PerfilEmpresa>.erro(),
      const PerfilState<PerfilEmpresa>.carregando(),
      const PerfilState<PerfilEmpresa>.carregado(jequitiba),
    ],
    verify: (_) => verify(() => obterPerfil(3)).called(2),
  );

  blocTest<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
    'duas chamadas seguidas de tentarNovamente() fazem uma única busca extra',
    build: construir,
    setUp: () {
      var chamadas = 0;
      when(() => obterPerfil(3)).thenAnswer((_) async {
        chamadas++;
        return chamadas == 1
            ? Result.failure(Exception('rede'))
            : const Result.success(jequitiba);
      });
    },
    act: (cubit) async {
      await cubit.carregar(3);
      final primeira = cubit.tentarNovamente();
      final segunda = cubit.tentarNovamente();
      await Future.wait([primeira, segunda]);
    },
    expect: () => [
      const PerfilState<PerfilEmpresa>.erro(),
      const PerfilState<PerfilEmpresa>.carregando(),
      const PerfilState<PerfilEmpresa>.carregado(jequitiba),
    ],
    verify: (_) => verify(() => obterPerfil(3)).called(2),
  );

  blocTest<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
    'tentarNovamente() antes de qualquer carregar não emite nada',
    build: construir,
    act: (cubit) => cubit.tentarNovamente(),
    expect: () => <PerfilState<PerfilEmpresa>>[],
    verify: (_) => verifyNever(() => obterPerfil(any())),
  );

  blocTest<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
    'tentarNovamente() enquanto carregando não emite nem busca de novo',
    build: construir,
    setUp: () {
      when(() => obterPerfil(3))
          .thenAnswer((_) => Completer<Result<PerfilEmpresa>>().future);
    },
    act: (cubit) {
      unawaited(cubit.carregar(3));
      return cubit.tentarNovamente();
    },
    expect: () => <PerfilState<PerfilEmpresa>>[],
    verify: (_) => verify(() => obterPerfil(3)).called(1),
  );

  blocTest<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
    'tentarNovamente() no 404 não emite nem busca de novo (repetir não '
    'resolve)',
    build: construir,
    setUp: () {
      when(() => obterPerfil(3)).thenAnswer(
        (_) async => Result.failure(const PerfilNaoEncontradoException()),
      );
    },
    act: (cubit) async {
      await cubit.carregar(3);
      await cubit.tentarNovamente();
    },
    expect: () => [const PerfilState<PerfilEmpresa>.naoEncontrado()],
    verify: (_) => verify(() => obterPerfil(3)).called(1),
  );

  test(
    'fechar o Cubit antes do use case terminar não emite nem falha',
    () async {
      final completer = Completer<Result<PerfilEmpresa>>();
      when(() => obterPerfil(3)).thenAnswer((_) => completer.future);
      final cubit = construir();
      final emitidos = <PerfilState<PerfilEmpresa>>[];
      final inscricao = cubit.stream.listen(emitidos.add);

      final carga = cubit.carregar(3);
      await cubit.close();
      completer.complete(const Result.success(jequitiba));
      await carga;

      expect(emitidos, isEmpty);
      await inscricao.cancel();
    },
  );
}
