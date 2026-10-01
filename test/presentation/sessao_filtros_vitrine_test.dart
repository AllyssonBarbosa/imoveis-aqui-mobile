import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/presentation/vitrine/sessao_filtros_vitrine.dart';

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');

  group('SessaoFiltrosVitrine (D-14, D-23)', () {
    test(
      'instância nova -> filtrosPara(qualquer cidade) é o filtro vazio '
      '(D-23 — abertura nova do app = sem filtros)',
      () {
        final sessao = SessaoFiltrosVitrine();

        expect(sessao.filtrosPara(campinas), const FiltrosVitrine());
        expect(sessao.filtrosPara(valinhos), const FiltrosVitrine());
      },
    );

    test(
      'lembrar(campinas, f) -> filtrosPara(campinas) devolve f sem '
      'alteração (mesma chaveNatural)',
      () {
        final sessao = SessaoFiltrosVitrine();
        const filtros = FiltrosVitrine(
          finalidade: FinalidadeFiltro.venda,
          bairros: {'Cambuí'},
        );

        sessao.lembrar(campinas, filtros);

        expect(sessao.filtrosPara(campinas), filtros);
      },
    );

    test(
      'lembrar(campinas, f) -> filtrosPara(valinhos) devolve f com bairros '
      'limpos, mantendo todos os demais campos gerais (D-14)',
      () {
        final sessao = SessaoFiltrosVitrine();
        const filtros = FiltrosVitrine(
          finalidade: FinalidadeFiltro.venda,
          naturezas: {NaturezaImovel.casa},
          precoMin: 200000,
          precoMax: 500000,
          quartosMin: 2,
          suitesMin: 1,
          vagasMin: 1,
          bairros: {'Cambuí'},
          areaMin: 80,
          areaMax: 200,
          caracteristicas: {'Piscina'},
        );

        sessao.lembrar(campinas, filtros);

        expect(
          sessao.filtrosPara(valinhos),
          filtros.copyWith(bairros: const {}),
        );
      },
    );

    test(
      'um lembrar() posterior sobrescreve o anterior',
      () {
        final sessao = SessaoFiltrosVitrine();
        sessao.lembrar(
          campinas,
          const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
        );
        sessao.lembrar(
          campinas,
          const FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
        );

        expect(
          sessao.filtrosPara(campinas),
          const FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
        );
      },
    );
  });
}
