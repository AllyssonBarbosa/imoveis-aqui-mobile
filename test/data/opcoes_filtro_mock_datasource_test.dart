import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/texto_normalizado.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';

/// Servidor simulado das opções (D-20) — tudo derivado das MESMAS linhas do
/// acervo (`linhasAcervoFixture()`), nunca uma lista fixa paralela.
void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const indaiatuba = Cidade(nome: 'Indaiatuba', uf: 'SP');

  OpcoesFiltroMockDataSource construir() =>
      OpcoesFiltroMockDataSource.paraTeste(linhas: linhasAcervoFixture());

  group('bairros (D-20)', () {
    test(
      'Campinas: devolve os bairros distintos da fixture, contendo '
      '"Cambuí", ordenados por normalizarTexto, cada um uma única vez',
      () async {
        final dataSource = construir();

        final bairros = await dataSource.bairros(campinas);

        final esperado = linhasAcervoFixture()
            .where(
              (l) =>
                  (l['cidade']! as Map<String, Object?>)['nome'] ==
                  'Campinas',
            )
            .map((l) => l['bairro']! as String)
            .toSet();
        expect(bairros.toSet(), esperado);
        expect(bairros, contains('Cambuí'));
        expect(bairros.toSet(), hasLength(bairros.length));
        final ordenado = [...bairros]
          ..sort((a, b) => normalizarTexto(a).compareTo(normalizarTexto(b)));
        expect(bairros, ordenado);
      },
    );

    test('Indaiatuba (sem nenhum imóvel na fixture): devolve lista vazia', () async {
      final dataSource = construir();

      final bairros = await dataSource.bairros(indaiatuba);

      expect(bairros, isEmpty);
    });

    test(
      'duas chamadas seguidas devolvem listas profundamente iguais',
      () async {
        final dataSource = construir();

        final primeira = await dataSource.bairros(campinas);
        final segunda = await dataSource.bairros(campinas);

        expect(primeira, segunda);
      },
    );

    test(
      'todo bairro devolvido para uma cidade tem ao menos um imóvel '
      'publicado quando usado como filtro de bairro (bairros com imóvel '
      'publicado)',
      () async {
        final dataSource = construir();
        final imovelDataSource = ImovelMockDataSource.paraTeste(
          linhas: linhasAcervoFixture(),
        );

        final bairros = await dataSource.bairros(campinas);

        for (final bairro in bairros) {
          final envelope = await imovelDataSource.buscar(
            ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(bairros: {bairro}),
            ),
          );
          expect(
            envelope.results,
            isNotEmpty,
            reason: 'bairro "$bairro" sem nenhum imóvel publicado',
          );
        }
      },
    );
  });

  group('caracteristicas (D-20)', () {
    test(
      'devolve as características distintas da fixture, contendo '
      '"Piscina", ordenadas por normalizarTexto, cada uma uma única vez',
      () async {
        final dataSource = construir();

        final caracteristicas = await dataSource.caracteristicas();

        final esperado = linhasAcervoFixture()
            .expand((l) => (l['caracteristicas']! as List).cast<String>())
            .toSet();
        expect(caracteristicas.toSet(), esperado);
        expect(caracteristicas, contains('Piscina'));
        expect(caracteristicas.toSet(), hasLength(caracteristicas.length));
        final ordenado = [...caracteristicas]
          ..sort((a, b) => normalizarTexto(a).compareTo(normalizarTexto(b)));
        expect(caracteristicas, ordenado);
      },
    );

    test(
      'duas chamadas seguidas devolvem listas profundamente iguais',
      () async {
        final dataSource = construir();

        final primeira = await dataSource.caracteristicas();
        final segunda = await dataSource.caracteristicas();

        expect(primeira, segunda);
      },
    );
  });
}
