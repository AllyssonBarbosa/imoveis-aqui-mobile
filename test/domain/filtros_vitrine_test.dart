import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';

void main() {
  group('FiltrosVitrine.quantidadeAtiva (D-16)', () {
    test('instância padrão (sem nenhum filtro) tem quantidadeAtiva 0', () {
      expect(const FiltrosVitrine().quantidadeAtiva, 0);
    });

    test(
      'naturezas com 2 valores + precoMin conta 2 filtros ATIVOS (não de '
      'valores)',
      () {
        const filtros = FiltrosVitrine(
          naturezas: {NaturezaImovel.casa, NaturezaImovel.apartamento},
          precoMin: 200000,
        );

        expect(filtros.quantidadeAtiva, 2);
      },
    );

    test('finalidade sozinha conta 1', () {
      expect(
        const FiltrosVitrine(
          finalidade: FinalidadeFiltro.venda,
        ).quantidadeAtiva,
        1,
      );
    });

    test('precoMin OU precoMax sozinho já conta como 1 filtro (faixa única)', () {
      expect(const FiltrosVitrine(precoMin: 100).quantidadeAtiva, 1);
      expect(const FiltrosVitrine(precoMax: 500).quantidadeAtiva, 1);
      expect(
        const FiltrosVitrine(precoMin: 100, precoMax: 500).quantidadeAtiva,
        1,
      );
    });

    test('areaMin OU areaMax sozinho conta 1', () {
      expect(const FiltrosVitrine(areaMin: 50).quantidadeAtiva, 1);
      expect(const FiltrosVitrine(areaMax: 120).quantidadeAtiva, 1);
    });

    test('todos os 9 campos ativos ao mesmo tempo contam 9', () {
      const filtros = FiltrosVitrine(
        finalidade: FinalidadeFiltro.aluguel,
        naturezas: {NaturezaImovel.casa},
        precoMin: 1000,
        quartosMin: 2,
        suitesMin: 1,
        vagasMin: 1,
        bairros: {'Cambuí'},
        areaMin: 50,
        caracteristicas: {'Piscina'},
      );

      expect(filtros.quantidadeAtiva, 9);
    });
  });

  group('FiltrosVitrine.ativos (ordem fixa, D-16)', () {
    test('instância padrão tem ativos vazio', () {
      expect(const FiltrosVitrine().ativos, isEmpty);
    });

    test(
      'ativos segue SEMPRE a ordem finalidade, naturezas, preco, quartos, '
      'suites, vagas, bairros, area, caracteristicas, independente da ordem '
      'de construção',
      () {
        const filtros = FiltrosVitrine(
          caracteristicas: {'Piscina'},
          bairros: {'Cambuí'},
          finalidade: FinalidadeFiltro.venda,
          areaMin: 50,
          quartosMin: 2,
          vagasMin: 1,
          suitesMin: 1,
          precoMin: 1000,
        );

        expect(filtros.ativos, [
          FiltroAtivo.finalidade,
          FiltroAtivo.preco,
          FiltroAtivo.quartos,
          FiltroAtivo.suites,
          FiltroAtivo.vagas,
          FiltroAtivo.bairros,
          FiltroAtivo.area,
          FiltroAtivo.caracteristicas,
        ]);
      },
    );

    test('quantidadeAtiva == ativos.length (mesma fonte, sem divergência)', () {
      const filtros = FiltrosVitrine(
        finalidade: FinalidadeFiltro.aluguel,
        naturezas: {NaturezaImovel.casa},
      );

      expect(filtros.quantidadeAtiva, filtros.ativos.length);
      expect(filtros.quantidadeAtiva, 2);
    });
  });

  group('FiltrosVitrine.semFiltro (D-03, D-17)', () {
    test('semFiltro(preco) limpa precoMin e precoMax, mantém o resto', () {
      const filtros = FiltrosVitrine(
        finalidade: FinalidadeFiltro.venda,
        precoMin: 1000,
        precoMax: 5000,
      );

      final resultado = filtros.semFiltro(FiltroAtivo.preco);

      expect(resultado.precoMin, isNull);
      expect(resultado.precoMax, isNull);
      expect(resultado.finalidade, FinalidadeFiltro.venda);
    });

    test(
      'semFiltro(finalidade) limpa finalidade E a faixa de preço (D-03 — '
      'uma faixa sem finalidade não tem escala)',
      () {
        const filtros = FiltrosVitrine(
          finalidade: FinalidadeFiltro.aluguel,
          precoMin: 1000,
          precoMax: 5000,
        );

        final resultado = filtros.semFiltro(FiltroAtivo.finalidade);

        expect(resultado, const FiltrosVitrine());
      },
    );

    test('semFiltro(naturezas) limpa o Set, mantém os demais campos', () {
      const filtros = FiltrosVitrine(
        finalidade: FinalidadeFiltro.venda,
        naturezas: {NaturezaImovel.casa, NaturezaImovel.apartamento},
      );

      final resultado = filtros.semFiltro(FiltroAtivo.naturezas);

      expect(resultado.naturezas, isEmpty);
      expect(resultado.finalidade, FinalidadeFiltro.venda);
    });

    test('semFiltro(area) limpa areaMin e areaMax', () {
      const filtros = FiltrosVitrine(areaMin: 50, areaMax: 120);

      expect(filtros.semFiltro(FiltroAtivo.area), const FiltrosVitrine());
    });

    test('semFiltro(bairros)/semFiltro(caracteristicas) limpam os Sets', () {
      const filtros = FiltrosVitrine(
        bairros: {'Cambuí'},
        caracteristicas: {'Piscina'},
      );

      expect(
        filtros.semFiltro(FiltroAtivo.bairros).bairros,
        isEmpty,
      );
      expect(
        filtros.semFiltro(FiltroAtivo.caracteristicas).caracteristicas,
        isEmpty,
      );
    });

    test(
      'semFiltro(quartos)/semFiltro(suites)/semFiltro(vagas) limpam só o '
      'próprio campo',
      () {
        const filtros = FiltrosVitrine(
          quartosMin: 2,
          suitesMin: 1,
          vagasMin: 1,
        );

        expect(filtros.semFiltro(FiltroAtivo.quartos).quartosMin, isNull);
        expect(filtros.semFiltro(FiltroAtivo.suites).suitesMin, isNull);
        expect(filtros.semFiltro(FiltroAtivo.vagas).vagasMin, isNull);
      },
    );
  });

  group('FiltrosVitrine — igualdade profunda (freezed)', () {
    test(
      'duas instâncias com os mesmos Sets (conteúdo igual, instâncias '
      'diferentes) são ==',
      () {
        const a = FiltrosVitrine(
          naturezas: {NaturezaImovel.casa, NaturezaImovel.apartamento},
          bairros: {'Cambuí', 'Taquaral'},
        );
        final b = FiltrosVitrine(
          naturezas: {NaturezaImovel.apartamento, NaturezaImovel.casa},
          bairros: {'Taquaral', 'Cambuí'},
        );

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      },
    );

    test('instâncias com valores diferentes não são ==', () {
      expect(
        const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
        isNot(const FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel)),
      );
    });
  });
}
