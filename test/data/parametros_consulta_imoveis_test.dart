import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/parametros_consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');

  group('parametrosDaConsulta — mapeamento de filtros (D-01, D-04, D-05, D-06)', () {
    test(
      'naturezas {apartamento, casa} emite natureza=CASA,APARTAMENTO — '
      'ordem do ENUM, independente da ordem de inserção no Set',
      () {
        final params = parametrosDaConsulta(
          const ConsultaImoveis(
            cidade: campinas,
            filtros: FiltrosVitrine(
              naturezas: {NaturezaImovel.apartamento, NaturezaImovel.casa},
            ),
          ),
        );

        expect(params['natureza'], 'CASA,APARTAMENTO');
      },
    );

    test('quartosMin/suitesMin/vagasMin emitem os três params decimais', () {
      final params = parametrosDaConsulta(
        const ConsultaImoveis(
          cidade: campinas,
          filtros: FiltrosVitrine(quartosMin: 2, suitesMin: 1, vagasMin: 3),
        ),
      );

      expect(params['quartos_min'], '2');
      expect(params['suites_min'], '1');
      expect(params['vagas_min'], '3');
    });

    test(
      'bairros e características saem em CSV ordenado por normalizarTexto, '
      'não pela ordem de inserção no Set',
      () {
        final params = parametrosDaConsulta(
          const ConsultaImoveis(
            cidade: campinas,
            filtros: FiltrosVitrine(
              bairros: {'Taquaral', 'Cambuí'},
              caracteristicas: {'Quintal', 'Ar-condicionado'},
            ),
          ),
        );

        expect(params['bairro'], 'Cambuí,Taquaral');
        expect(params['caracteristicas'], 'Ar-condicionado,Quintal');
      },
    );

    test(
      'Set vazio e campo null não emitem chave nenhuma (natureza, bairro, '
      'características, os três mínimos, as quatro faixas)',
      () {
        final params = parametrosDaConsulta(
          const ConsultaImoveis(cidade: campinas),
        );

        expect(params.containsKey('natureza'), isFalse);
        expect(params.containsKey('quartos_min'), isFalse);
        expect(params.containsKey('suites_min'), isFalse);
        expect(params.containsKey('vagas_min'), isFalse);
        expect(params.containsKey('bairro'), isFalse);
        expect(params.containsKey('caracteristicas'), isFalse);
        expect(params.containsKey('preco_min'), isFalse);
        expect(params.containsKey('preco_max'), isFalse);
        expect(params.containsKey('area_min'), isFalse);
        expect(params.containsKey('area_max'), isFalse);
      },
    );

    test(
      'round trip: filtrosDosParametros(parametrosDaConsulta(consulta)) == '
      'consulta.filtros, incluindo finalidade (03-01)',
      () {
        const consulta = ConsultaImoveis(
          cidade: campinas,
          filtros: FiltrosVitrine(
            finalidade: FinalidadeFiltro.aluguel,
            naturezas: {
              NaturezaImovel.casa,
              NaturezaImovel.terreno,
              NaturezaImovel.lote,
            },
            quartosMin: 2,
            suitesMin: 1,
            vagasMin: 0,
            bairros: {'Cambuí', 'Taquaral'},
            caracteristicas: {'Piscina', 'Quintal'},
          ),
        );

        final params = parametrosDaConsulta(consulta);
        final filtrosDeVolta = filtrosDosParametros(params);

        expect(filtrosDeVolta, consulta.filtros);
      },
    );

    test('round trip com FiltrosVitrine vazio devolve FiltrosVitrine vazio', () {
      const consulta = ConsultaImoveis(cidade: campinas);

      final params = parametrosDaConsulta(consulta);
      final filtrosDeVolta = filtrosDosParametros(params);

      expect(filtrosDeVolta, const FiltrosVitrine());
    });
  });

  group(
    'parametrosDaConsulta/filtrosDosParametros — faixas de preço e área '
    '(FIL-03, FIL-04, D-03, D-09)',
    () {
      test(
        'precoMin/precoMax/areaMin/areaMax emitem os quatro params decimais',
        () {
          final params = parametrosDaConsulta(
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(
                finalidade: FinalidadeFiltro.venda,
                precoMin: 250000,
                precoMax: 300000,
                areaMin: 80,
                areaMax: 120,
              ),
            ),
          );

          expect(params['preco_min'], '250000');
          expect(params['preco_max'], '300000');
          expect(params['area_min'], '80');
          expect(params['area_max'], '120');
        },
      );

      test(
        'round trip com faixas de preço (+finalidade) e área preserva os '
        'quatro valores',
        () {
          const consulta = ConsultaImoveis(
            cidade: campinas,
            filtros: FiltrosVitrine(
              finalidade: FinalidadeFiltro.aluguel,
              precoMin: 1500,
              precoMax: 3000,
              areaMin: 50,
              areaMax: 200,
            ),
          );

          final params = parametrosDaConsulta(consulta);
          final filtrosDeVolta = filtrosDosParametros(params);

          expect(filtrosDeVolta, consulta.filtros);
        },
      );

      test(
        'preco_min/preco_max/area_min/area_max não-numérico lança '
        'FormatException',
        () {
          for (final chave in [
            'preco_min',
            'preco_max',
            'area_min',
            'area_max',
          ]) {
            expect(
              () => filtrosDosParametros({'finalidade': 'VENDA', chave: 'abc'}),
              throwsFormatException,
              reason: chave,
            );
          }
        },
      );

      test(
        'preco_min/preco_max/area_min/area_max negativo lança '
        'FormatException',
        () {
          for (final chave in [
            'preco_min',
            'preco_max',
            'area_min',
            'area_max',
          ]) {
            expect(
              () => filtrosDosParametros({'finalidade': 'VENDA', chave: '-1'}),
              throwsFormatException,
              reason: chave,
            );
          }
        },
      );

      test(
        'preco_min/preco_max/area_min/area_max decimal (1.5) lança '
        'FormatException',
        () {
          for (final chave in [
            'preco_min',
            'preco_max',
            'area_min',
            'area_max',
          ]) {
            expect(
              () =>
                  filtrosDosParametros({'finalidade': 'VENDA', chave: '1.5'}),
              throwsFormatException,
              reason: chave,
            );
          }
        },
      );

      test('preco_min maior que preco_max lança FormatException (D-12)', () {
        expect(
          () => filtrosDosParametros({
            'finalidade': 'VENDA',
            'preco_min': '300000',
            'preco_max': '250000',
          }),
          throwsFormatException,
        );
      });

      test('area_min maior que area_max lança FormatException (D-12)', () {
        expect(
          () => filtrosDosParametros({'area_min': '120', 'area_max': '80'}),
          throwsFormatException,
        );
      });

      test('preco_min igual a preco_max é aceito (preço exato)', () {
        final filtros = filtrosDosParametros({
          'finalidade': 'VENDA',
          'preco_min': '250000',
          'preco_max': '250000',
        });

        expect(filtros.precoMin, 250000);
        expect(filtros.precoMax, 250000);
      });

      test('area_min igual a area_max é aceito (área exata)', () {
        final filtros = filtrosDosParametros({
          'area_min': '80',
          'area_max': '80',
        });

        expect(filtros.areaMin, 80);
        expect(filtros.areaMax, 80);
      });

      test('preco_min sem finalidade lança FormatException (D-03)', () {
        expect(
          () => filtrosDosParametros({'preco_min': '250000'}),
          throwsFormatException,
        );
      });

      test('preco_max sem finalidade lança FormatException (D-03)', () {
        expect(
          () => filtrosDosParametros({'preco_max': '300000'}),
          throwsFormatException,
        );
      });

      test(
        'faixa de área sem finalidade é aceita (área não depende de '
        'finalidade, D-09)',
        () {
          final filtros = filtrosDosParametros({
            'area_min': '80',
            'area_max': '120',
          });

          expect(filtros.areaMin, 80);
          expect(filtros.areaMax, 120);
        },
      );
    },
  );

  group('inteiroNaoNegativoDoParametro (D-09, D-12)', () {
    test('inteiro não-negativo é aceito', () {
      expect(inteiroNaoNegativoDoParametro('0'), 0);
      expect(inteiroNaoNegativoDoParametro('250000'), 250000);
    });

    test('negativo lança FormatException', () {
      expect(
        () => inteiroNaoNegativoDoParametro('-1'),
        throwsFormatException,
      );
    });

    test('não-numérico lança FormatException', () {
      expect(
        () => inteiroNaoNegativoDoParametro('abc'),
        throwsFormatException,
      );
    });

    test('decimal lança FormatException', () {
      expect(
        () => inteiroNaoNegativoDoParametro('1.5'),
        throwsFormatException,
      );
    });
  });

  group('naturezasDoParametro (D-06, D-12)', () {
    test('CSV com dois valores conhecidos devolve o Set correspondente', () {
      expect(
        naturezasDoParametro('CASA,APARTAMENTO'),
        {NaturezaImovel.casa, NaturezaImovel.apartamento},
      );
    });

    test('valor desconhecido (CHALE) lança FormatException', () {
      expect(() => naturezasDoParametro('CHALE'), throwsFormatException);
    });

    test('item vazio no CSV (CASA,) lança FormatException', () {
      expect(() => naturezasDoParametro('CASA,'), throwsFormatException);
    });
  });

  group('listaDoParametro (D-06, D-12)', () {
    test('CSV com dois itens devolve o Set com os dois, já com trim', () {
      expect(
        listaDoParametro('Cambuí, Taquaral'),
        {'Cambuí', 'Taquaral'},
      );
    });

    test('item vazio no CSV lança FormatException', () {
      expect(() => listaDoParametro('Cambuí,'), throwsFormatException);
    });

    test('CSV totalmente vazio lança FormatException', () {
      expect(() => listaDoParametro(''), throwsFormatException);
    });
  });

  group('minimoDoParametro (D-01, D-12)', () {
    test('inteiro não-negativo é aceito', () {
      expect(minimoDoParametro('0'), 0);
      expect(minimoDoParametro('4'), 4);
    });

    test('negativo lança FormatException', () {
      expect(() => minimoDoParametro('-1'), throwsFormatException);
    });

    test('não-numérico lança FormatException', () {
      expect(() => minimoDoParametro('dois'), throwsFormatException);
    });

    test('decimal lança FormatException', () {
      expect(() => minimoDoParametro('1.5'), throwsFormatException);
    });
  });
}
