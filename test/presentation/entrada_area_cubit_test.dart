import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/papel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/obter_papel_usecase.dart';
import 'package:imoveis_aqui/presentation/sessao/entrada_area_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/entrada_area_state.dart';
import 'package:mocktail/mocktail.dart';

class _ObterPapelFalso extends Mock implements ObterPapelUseCase {}

void main() {
  late _ObterPapelFalso obterPapel;

  setUp(() {
    obterPapel = _ObterPapelFalso();
  });

  EntradaAreaCubit construir() => EntradaAreaCubit(obterPapel);

  test('estado inicial é carregando', () {
    expect(construir().state, const EntradaAreaState.carregando());
  });

  for (final papel in Papel.values) {
    blocTest<EntradaAreaCubit, EntradaAreaState>(
      'papel $papel emite papel($papel)',
      build: construir,
      setUp: () {
        when(() => obterPapel()).thenAnswer((_) async => Result.success(papel));
      },
      act: (cubit) => cubit.carregar(),
      expect: () => [EntradaAreaState.papel(papel)],
    );
  }

  blocTest<EntradaAreaCubit, EntradaAreaState>(
    'SessaoExpiradaException emite sessaoExpirada',
    build: construir,
    setUp: () {
      when(() => obterPapel()).thenAnswer(
        (_) async => Result.failure(const SessaoExpiradaException()),
      );
    },
    act: (cubit) => cubit.carregar(),
    expect: () => [const EntradaAreaState.sessaoExpirada()],
  );

  blocTest<EntradaAreaCubit, EntradaAreaState>(
    'outra falha emite erro',
    build: construir,
    setUp: () {
      when(() => obterPapel())
          .thenAnswer((_) async => Result.failure(Exception('sem rede')));
    },
    act: (cubit) => cubit.carregar(),
    expect: () => [const EntradaAreaState.erro()],
  );

  blocTest<EntradaAreaCubit, EntradaAreaState>(
    'tentarNovamente depois do erro passa por carregando e refaz a pergunta',
    build: construir,
    seed: () => const EntradaAreaState.erro(),
    setUp: () {
      when(() => obterPapel())
          .thenAnswer((_) async => const Result.success(Papel.corretor));
    },
    act: (cubit) => cubit.tentarNovamente(),
    expect: () => [
      const EntradaAreaState.carregando(),
      const EntradaAreaState.papel(Papel.corretor),
    ],
    verify: (_) {
      verify(() => obterPapel()).called(1);
    },
  );

  blocTest<EntradaAreaCubit, EntradaAreaState>(
    'tentarNovamente enquanto carrega não dispara pedido duplo',
    build: construir,
    act: (cubit) => cubit.tentarNovamente(),
    expect: () => <EntradaAreaState>[],
    verify: (_) {
      verifyNever(() => obterPapel());
    },
  );

  test('não emite depois de fechado', () async {
    when(() => obterPapel())
        .thenAnswer((_) async => const Result.success(Papel.corretor));
    final cubit = construir();
    final futuro = cubit.carregar();
    await cubit.close();
    await futuro;
    expect(cubit.state, const EntradaAreaState.carregando());
  });
}
