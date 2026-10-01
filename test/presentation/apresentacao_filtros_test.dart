import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/presentation/vitrine/apresentacao_filtros.dart';

void main() {
  group('rotuloBotaoFiltros (D-15)', () {
    test('0 -> "Filtros"; N > 0 -> "Filtros (N)"', () {
      expect(rotuloBotaoFiltros(0), 'Filtros');
      expect(rotuloBotaoFiltros(1), 'Filtros (1)');
      expect(rotuloBotaoFiltros(3), 'Filtros (3)');
    });
  });

  group('formatarValorCompacto (D-16)', () {
    test('950 -> "950" (abaixo de mil, sem sufixo)', () {
      expect(formatarValorCompacto(950), '950');
    });

    test('1000 -> "1 mil"', () {
      expect(formatarValorCompacto(1000), '1 mil');
    });

    test('3500 -> "3,5 mil" (uma casa decimal, vírgula pt_BR)', () {
      expect(formatarValorCompacto(3500), '3,5 mil');
    });

    test('200000 -> "200 mil"', () {
      expect(formatarValorCompacto(200000), '200 mil');
    });

    test('1000000 -> "1 mi"', () {
      expect(formatarValorCompacto(1000000), '1 mi');
    });

    test('1200000 -> "1,2 mi"', () {
      expect(formatarValorCompacto(1200000), '1,2 mi');
    });
  });

  group('chipsDosFiltros — os nove formatos (D-16)', () {
    test('finalidade: "Venda" / "Aluguel"', () {
      expect(
        chipsDosFiltros(
          const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
        ).single.rotulo,
        'Venda',
      );
      expect(
        chipsDosFiltros(
          const FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
        ).single.rotulo,
        'Aluguel',
      );
    });

    test('naturezas: ordem do enum, "Apto" abreviado — "Casa, Apto"', () {
      final rotulo = chipsDosFiltros(
        const FiltrosVitrine(
          naturezas: {NaturezaImovel.apartamento, NaturezaImovel.casa},
        ),
      ).single.rotulo;

      expect(rotulo, 'Casa, Apto');
    });

    test(
      'preco venda: faixa completa, só mín, só máx — sem sufixo "/mês"',
      () {
        expect(
          chipsDosFiltros(
            const FiltrosVitrine(
              finalidade: FinalidadeFiltro.venda,
              precoMin: 200000,
              precoMax: 500000,
            ),
          ).last.rotulo,
          'R\$ 200 mil–500 mil',
        );
        expect(
          chipsDosFiltros(
            const FiltrosVitrine(
              finalidade: FinalidadeFiltro.venda,
              precoMin: 200000,
            ),
          ).last.rotulo,
          'A partir de R\$ 200 mil',
        );
        expect(
          chipsDosFiltros(
            const FiltrosVitrine(
              finalidade: FinalidadeFiltro.venda,
              precoMax: 500000,
            ),
          ).last.rotulo,
          'Até R\$ 500 mil',
        );
      },
    );

    test('preco aluguel: mesmo formato, com sufixo "/mês"', () {
      final rotulo = chipsDosFiltros(
        const FiltrosVitrine(
          finalidade: FinalidadeFiltro.aluguel,
          precoMin: 2000,
          precoMax: 3500,
        ),
      ).last.rotulo;

      expect(rotulo, 'R\$ 2 mil–3,5 mil/mês');
    });

    test('quartos: "2+ quartos" / "1+ quarto" (singular)', () {
      expect(
        chipsDosFiltros(const FiltrosVitrine(quartosMin: 2)).single.rotulo,
        '2+ quartos',
      );
      expect(
        chipsDosFiltros(const FiltrosVitrine(quartosMin: 1)).single.rotulo,
        '1+ quarto',
      );
    });

    test('suites: "2+ suítes" / "1+ suíte"', () {
      expect(
        chipsDosFiltros(const FiltrosVitrine(suitesMin: 2)).single.rotulo,
        '2+ suítes',
      );
      expect(
        chipsDosFiltros(const FiltrosVitrine(suitesMin: 1)).single.rotulo,
        '1+ suíte',
      );
    });

    test('vagas: "2+ vagas" / "1+ vaga"', () {
      expect(
        chipsDosFiltros(const FiltrosVitrine(vagasMin: 2)).single.rotulo,
        '2+ vagas',
      );
      expect(
        chipsDosFiltros(const FiltrosVitrine(vagasMin: 1)).single.rotulo,
        '1+ vaga',
      );
    });

    test('bairros: um só -> nome puro; mais de um -> "nome +N"', () {
      expect(
        chipsDosFiltros(
          const FiltrosVitrine(bairros: {'Cambuí'}),
        ).single.rotulo,
        'Cambuí',
      );
      expect(
        chipsDosFiltros(
          const FiltrosVitrine(bairros: {'Cambuí', 'Taquaral'}),
        ).single.rotulo,
        'Cambuí +1',
      );
    });

    test('area: faixa completa, só mín, só máx — sem compactação (m²)', () {
      expect(
        chipsDosFiltros(
          const FiltrosVitrine(areaMin: 50, areaMax: 120),
        ).single.rotulo,
        '50–120 m²',
      );
      expect(
        chipsDosFiltros(const FiltrosVitrine(areaMin: 50)).single.rotulo,
        'A partir de 50 m²',
      );
      expect(
        chipsDosFiltros(const FiltrosVitrine(areaMax: 120)).single.rotulo,
        'Até 120 m²',
      );
    });

    test(
      'caracteristicas: um só -> nome puro; mais de um -> "nome +N"',
      () {
        expect(
          chipsDosFiltros(
            const FiltrosVitrine(caracteristicas: {'Piscina'}),
          ).single.rotulo,
          'Piscina',
        );
        expect(
          chipsDosFiltros(
            const FiltrosVitrine(
              caracteristicas: {'Piscina', 'Elevador', 'Quintal'},
            ),
          ).single.rotulo,
          'Piscina +2',
        );
      },
    );

    test(
      'a ordem dos chips segue FiltrosVitrine.ativos (finalidade primeiro)',
      () {
        const filtros = FiltrosVitrine(
          caracteristicas: {'Piscina'},
          finalidade: FinalidadeFiltro.venda,
        );

        final chips = chipsDosFiltros(filtros);

        expect(chips, hasLength(2));
        expect(chips.first.filtro, FiltroAtivo.finalidade);
        expect(chips.last.filtro, FiltroAtivo.caracteristicas);
      },
    );

    test('filtro vazio produz lista de chips vazia', () {
      expect(chipsDosFiltros(const FiltrosVitrine()), isEmpty);
    });
  });

  group('filtrarOpcoes (D-21)', () {
    const opcoes = ['Cambuí', 'Castelo', 'Centro'];

    test('"CAMB" (maiúsculas, acento) mantém só "Cambuí"', () {
      expect(filtrarOpcoes(opcoes, 'CAMB'), ['Cambuí']);
    });

    test('"ca" mantém "Cambuí" e "Castelo", nessa ordem (preserva entrada)', () {
      expect(filtrarOpcoes(opcoes, 'ca'), ['Cambuí', 'Castelo']);
    });

    test('termo vazio ou em branco devolve a lista sem alteração', () {
      expect(filtrarOpcoes(opcoes, ''), opcoes);
      expect(filtrarOpcoes(opcoes, '   '), opcoes);
    });

    test('termo sem nenhuma correspondência devolve lista vazia', () {
      expect(filtrarOpcoes(opcoes, 'zzz'), isEmpty);
    });
  });
}
