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
      'características, os três mínimos)',
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
