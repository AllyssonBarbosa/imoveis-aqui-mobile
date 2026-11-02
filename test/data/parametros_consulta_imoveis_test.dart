import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/parametros_consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/caracteristica.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/ordenacao_vitrine.dart';

void main() {
  group('parametrosDaApi (W09, D-12)', () {
    const campinasComId = Cidade(id: 1, nome: 'Campinas', uf: 'SP');

    test('cada OrdenacaoVitrine vira o ordenar da W09', () {
      const esperado = {
        OrdenacaoVitrine.maisRecentes: 'recentes',
        OrdenacaoVitrine.precoAsc: 'preco',
        OrdenacaoVitrine.precoDesc: '-preco',
        OrdenacaoVitrine.areaAsc: 'area',
        OrdenacaoVitrine.areaDesc: '-area',
      };
      expect(esperado.keys, unorderedEquals(OrdenacaoVitrine.values));
      for (final entrada in esperado.entries) {
        final params = parametrosDaApi(
          ConsultaImoveis(cidade: campinasComId, ordenacao: entrada.key),
        );
        expect(params['ordenar'], entrada.value, reason: '${entrada.key}');
      }
    });

    test('nunca leva a cidade como query (o id vai no caminho)', () {
      final params = parametrosDaApi(
        const ConsultaImoveis(cidade: campinasComId),
      );

      expect(params.containsKey('cidade'), isFalse);
    });

    test('busca vai aparada e só quando não vazia depois do trim', () {
      final comTermo = parametrosDaApi(
        const ConsultaImoveis(cidade: campinasComId, busca: '  Cambuí '),
      );
      final vazia = parametrosDaApi(
        const ConsultaImoveis(cidade: campinasComId, busca: '   '),
      );
      final nula = parametrosDaApi(
        const ConsultaImoveis(cidade: campinasComId),
      );

      expect(comTermo['busca'], 'Cambuí');
      expect(comTermo['ordenar'], 'recentes');
      expect(vazia.containsKey('busca'), isFalse);
      expect(nula.containsKey('busca'), isFalse);
    });

    test('finalidade vira VENDA ou ALUGUEL', () {
      final venda = parametrosDaApi(
        const ConsultaImoveis(
          cidade: campinasComId,
          filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
        ),
      );
      final aluguel = parametrosDaApi(
        const ConsultaImoveis(
          cidade: campinasComId,
          filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
        ),
      );

      expect(venda['finalidade'], 'VENDA');
      expect(aluguel['finalidade'], 'ALUGUEL');
    });

    test(
      'naturezas saem em CSV na ordem do enum (LOTE incluso), independente '
      'da ordem de inserção no Set',
      () {
        final params = parametrosDaApi(
          const ConsultaImoveis(
            cidade: campinasComId,
            filtros: FiltrosVitrine(
              naturezas: {
                NaturezaImovel.lote,
                NaturezaImovel.apartamento,
                NaturezaImovel.casa,
              },
            ),
          ),
        );

        expect(params['natureza'], 'CASA,APARTAMENTO,LOTE');
      },
    );

    test('quartos, suites e vagas levam o mínimo com os nomes da W09', () {
      final params = parametrosDaApi(
        const ConsultaImoveis(
          cidade: campinasComId,
          filtros: FiltrosVitrine(quartosMin: 2, suitesMin: 1, vagasMin: 0),
        ),
      );

      expect(params['quartos'], '2');
      expect(params['suites'], '1');
      expect(params['vagas'], '0');
      expect(params.containsKey('quartos_min'), isFalse);
      expect(params.containsKey('suites_min'), isFalse);
      expect(params.containsKey('vagas_min'), isFalse);
    });

    test('bairros saem em CSV ordenado por normalizarTexto', () {
      final params = parametrosDaApi(
        const ConsultaImoveis(
          cidade: campinasComId,
          filtros: FiltrosVitrine(bairros: {'Taquaral', 'Cambuí', 'Barão'}),
        ),
      );

      expect(params['bairro'], 'Barão,Cambuí,Taquaral');
    });

    test('faixas de preço e área levam os quatro nomes da W09', () {
      final params = parametrosDaApi(
        const ConsultaImoveis(
          cidade: campinasComId,
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
    });

    test('características viajam como CSV de ids em ordem crescente (D-13)', () {
      final params = parametrosDaApi(
        ConsultaImoveis(
          cidade: campinasComId,
          filtros: FiltrosVitrine(
            caracteristicas: {
              Caracteristica(id: 10, nome: 'Varanda gourmet'),
              Caracteristica(id: 2, nome: 'Churrasqueira'),
              Caracteristica(id: 1, nome: 'Piscina'),
            },
          ),
        ),
      );

      // Ordem numérica (2 antes de 10), nunca lexicográfica, e nunca o nome.
      expect(params['caracteristicas'], '1,2,10');
    });

    test('característica com vírgula no nome ainda viaja só pelo id (D-13)', () {
      final params = parametrosDaApi(
        ConsultaImoveis(
          cidade: campinasComId,
          filtros: FiltrosVitrine(
            caracteristicas: {Caracteristica(id: 5, nome: 'Sol, vista mar')},
          ),
        ),
      );

      expect(params['caracteristicas'], '5');
    });

    test('sem características a chave não aparece', () {
      final params = parametrosDaApi(
        const ConsultaImoveis(cidade: campinasComId),
      );

      expect(params.containsKey('caracteristicas'), isFalse);
    });

    test('sem filtros só vai ordenar: Set vazio e campo nulo não geram chave', () {
      final params = parametrosDaApi(
        const ConsultaImoveis(cidade: campinasComId),
      );

      expect(params, {'ordenar': 'recentes'});
    });

    test('caminhoImoveisDaCidade põe o id no caminho', () {
      expect(caminhoImoveisDaCidade(7), '/api/publico/cidades/7/imoveis/');
    });
  });
}
