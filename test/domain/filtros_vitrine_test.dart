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
