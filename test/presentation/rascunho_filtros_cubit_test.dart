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

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'definirPrecoMin/definirPrecoMax são ignorados enquanto a finalidade '
      'é null (D-03) — nenhuma emissão',
      build: () => RascunhoFiltrosCubit(const FiltrosVitrine()),
      act: (cubit) {
        cubit.definirPrecoMin(250000);
        cubit.definirPrecoMax(300000);
      },
      expect: () => const <FiltrosVitrine>[],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'com finalidade escolhida, definirPrecoMin/definirPrecoMax aplicam '
      'normalmente',
      build: () => RascunhoFiltrosCubit(
        const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
      ),
      act: (cubit) {
        cubit.definirPrecoMin(250000);
        cubit.definirPrecoMax(300000);
      },
      expect: () => const [
        FiltrosVitrine(
          finalidade: FinalidadeFiltro.venda,
          precoMin: 250000,
        ),
        FiltrosVitrine(
          finalidade: FinalidadeFiltro.venda,
          precoMin: 250000,
          precoMax: 300000,
        ),
      ],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'definirAreaMin/definirAreaMax sempre aplicam, mesmo sem finalidade '
      'escolhida (D-09, área não depende de finalidade)',
      build: () => RascunhoFiltrosCubit(const FiltrosVitrine()),
      act: (cubit) {
        cubit.definirAreaMin(80);
        cubit.definirAreaMax(120);
      },
      expect: () => const [
        FiltrosVitrine(areaMin: 80),
        FiltrosVitrine(areaMin: 80, areaMax: 120),
      ],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'alternarBairro(Cambuí, marcado: true) adiciona Cambuí ao rascunho, '
      'sem tocar nos demais campos (FIL-04, D-21)',
      build: () => RascunhoFiltrosCubit(
        const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
      ),
      act: (cubit) => cubit.alternarBairro('Cambuí', marcado: true),
      expect: () => const [
        FiltrosVitrine(
          finalidade: FinalidadeFiltro.venda,
          bairros: {'Cambuí'},
        ),
      ],
    );

    blocTest<RascunhoFiltrosCubit, FiltrosVitrine>(
      'alternarBairro(Cambuí, marcado: false) remove só Cambuí, mantendo os '
      'demais bairros já marcados',
      build: () => RascunhoFiltrosCubit(
        const FiltrosVitrine(bairros: {'Cambuí', 'Taquaral'}),
      ),
      act: (cubit) => cubit.alternarBairro('Cambuí', marcado: false),
      expect: () => const [FiltrosVitrine(bairros: {'Taquaral'})],
    );
  });

  group('ValidacaoRascunho (D-12)', () {
    test(
      'erroFaixaPreco é null quando mínimo e máximo não existem, quando só '
      'um existe, ou quando mínimo <= máximo',
      () {
        expect(const FiltrosVitrine().erroFaixaPreco, isNull);
        expect(const FiltrosVitrine(precoMin: 250000).erroFaixaPreco, isNull);
        expect(const FiltrosVitrine(precoMax: 300000).erroFaixaPreco, isNull);
        expect(
          const FiltrosVitrine(
            precoMin: 250000,
            precoMax: 300000,
          ).erroFaixaPreco,
          isNull,
        );
        expect(
          const FiltrosVitrine(
            precoMin: 250000,
            precoMax: 250000,
          ).erroFaixaPreco,
          isNull,
        );
      },
    );

    test(
      'erroFaixaPreco não é null quando mínimo é maior que máximo',
      () {
        expect(
          const FiltrosVitrine(
            precoMin: 300000,
            precoMax: 250000,
          ).erroFaixaPreco,
          'O mínimo não pode ser maior que o máximo',
        );
      },
    );

    test(
      'erroFaixaArea segue a mesma regra de erroFaixaPreco',
      () {
        expect(const FiltrosVitrine().erroFaixaArea, isNull);
        expect(
          const FiltrosVitrine(areaMin: 80, areaMax: 120).erroFaixaArea,
          isNull,
        );
        expect(
          const FiltrosVitrine(areaMin: 80, areaMax: 80).erroFaixaArea,
          isNull,
        );
        expect(
          const FiltrosVitrine(
            areaMin: 120,
            areaMax: 80,
          ).erroFaixaArea,
          'O mínimo não pode ser maior que o máximo',
        );
      },
    );

    test(
      'podeAplicar é false enquanto erroFaixaPreco OU erroFaixaArea existir, '
      'true quando nenhum dos dois existe',
      () {
        expect(const FiltrosVitrine().podeAplicar, isTrue);
        expect(
          const FiltrosVitrine(
            precoMin: 300000,
            precoMax: 250000,
          ).podeAplicar,
          isFalse,
        );
        expect(
          const FiltrosVitrine(areaMin: 120, areaMax: 80).podeAplicar,
          isFalse,
        );
      },
    );
  });
}
