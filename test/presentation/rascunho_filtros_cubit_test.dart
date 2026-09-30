import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/presentation/vitrine/rascunho_filtros_cubit.dart';

void main() {
  group('RascunhoFiltrosCubit (D-08, D-13, D-18)', () {
    test('estado inicial é seedado com os filtros APLICADOS', () {
      const aplicados = FiltrosVitrine(finalidade: FinalidadeFiltro.venda);
      final cubit = RascunhoFiltrosCubit(aplicados);

      expect(cubit.state, aplicados);
      unawaited(cubit.close());
    });

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'definirFinalidade(venda) a partir de "Qualquer" emite o rascunho com '
      'finalidade venda',
      build: () => RascunhoFiltrosCubit(const FiltrosVitrine()),
      act: (cubit) => cubit.definirFinalidade(FinalidadeFiltro.venda),
      expect: () => [
        const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
      ],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'trocar de finalidade limpa a faixa de preço do rascunho na mesma '
      'emissão (D-13)',
      build: () => RascunhoFiltrosCubit(
        const FiltrosVitrine(
          finalidade: FinalidadeFiltro.venda,
          precoMin: 200000,
          precoMax: 500000,
        ),
      ),
      act: (cubit) => cubit.definirFinalidade(FinalidadeFiltro.aluguel),
      expect: () => [
        const FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
      ],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'reselecionar a MESMA finalidade não emite nada (idempotência)',
      build: () => RascunhoFiltrosCubit(
        const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
      ),
      act: (cubit) => cubit.definirFinalidade(FinalidadeFiltro.venda),
      expect: () => const <FiltrosVitrine>[],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'limpar() emite o filtro vazio, mesmo a partir de um rascunho com '
      'filtros ativos',
      build: () => RascunhoFiltrosCubit(
        const FiltrosVitrine(
          finalidade: FinalidadeFiltro.aluguel,
          precoMin: 1000,
        ),
      ),
      act: (cubit) => cubit.limpar(),
      expect: () => const <FiltrosVitrine>[FiltrosVitrine()],
    );
  });
}
