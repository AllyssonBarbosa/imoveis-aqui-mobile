import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
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

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'alternarNatureza(casa, marcada: true) adiciona casa ao rascunho, sem '
      'tocar nos demais campos',
      build: () => RascunhoFiltrosCubit(
        const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
      ),
      act: (cubit) =>
          cubit.alternarNatureza(NaturezaImovel.casa, marcada: true),
      expect: () => [
        const FiltrosVitrine(
          finalidade: FinalidadeFiltro.venda,
          naturezas: {NaturezaImovel.casa},
        ),
      ],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'alternarNatureza(casa, marcada: false) remove só casa, mantendo as '
      'demais naturezas já marcadas',
      build: () => RascunhoFiltrosCubit(
        const FiltrosVitrine(
          naturezas: {NaturezaImovel.casa, NaturezaImovel.apartamento},
        ),
      ),
      act: (cubit) =>
          cubit.alternarNatureza(NaturezaImovel.casa, marcada: false),
      expect: () => [
        const FiltrosVitrine(naturezas: {NaturezaImovel.apartamento}),
      ],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'definirQuartosMin(2) define 2; definirQuartosMin(null) limpa de '
      'volta para "Qualquer"',
      build: () => RascunhoFiltrosCubit(const FiltrosVitrine()),
      act: (cubit) {
        cubit.definirQuartosMin(2);
        cubit.definirQuartosMin(null);
      },
      expect: () => const [
        FiltrosVitrine(quartosMin: 2),
        FiltrosVitrine(),
      ],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'definirSuitesMin(1) define 1; definirSuitesMin(null) limpa de volta '
      'para "Qualquer"',
      build: () => RascunhoFiltrosCubit(const FiltrosVitrine()),
      act: (cubit) {
        cubit.definirSuitesMin(1);
        cubit.definirSuitesMin(null);
      },
      expect: () => const [
        FiltrosVitrine(suitesMin: 1),
        FiltrosVitrine(),
      ],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'definirVagasMin(4) define 4; definirVagasMin(null) limpa de volta '
      'para "Qualquer"',
      build: () => RascunhoFiltrosCubit(const FiltrosVitrine()),
      act: (cubit) {
        cubit.definirVagasMin(4);
        cubit.definirVagasMin(null);
      },
      expect: () => const [
        FiltrosVitrine(vagasMin: 4),
        FiltrosVitrine(),
      ],
    );
  });
}
