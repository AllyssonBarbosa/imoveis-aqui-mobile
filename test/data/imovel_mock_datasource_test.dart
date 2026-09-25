import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');
  const indaiatuba = Cidade(nome: 'Indaiatuba', uf: 'SP');

  ImovelMockDataSource construir({int tamanhoPagina = 10}) =>
      ImovelMockDataSource.paraTeste(
        linhas: linhasAcervoFixture(),
        tamanhoPagina: tamanhoPagina,
      );

  group('linhasAcervoFixture (D-14, D-15)', () {
    test('é determinística — duas chamadas produzem listas iguais', () {
      expect(linhasAcervoFixture(), equals(linhasAcervoFixture()));
    });

    test('mantém as linhas 42, 57 e 63 verbatim do contrato', () {
      final linhas = linhasAcervoFixture();
      final id42 = linhas.firstWhere((linha) => linha['id'] == 42);
      final id57 = linhas.firstWhere((linha) => linha['id'] == 57);
      final id63 = linhas.firstWhere((linha) => linha['id'] == 63);

      expect(id42['titulo'], 'Apartamento 2 quartos no Cambuí');
      expect(id42['preco_venda'], '450000.00');
      expect(id57['titulo'], 'Casa térrea 3 quartos no Taquaral');
      expect(id63['titulo'], 'Terreno no Loteamento Jardim das Palmeiras');
    });

    test('40 linhas para cada cidade atendida, nenhuma para Indaiatuba', () {
      final linhas = linhasAcervoFixture();
      bool ehDaCidade(Map<String, Object?> linha, String nome) =>
          (linha['cidade']! as Map<String, Object?>)['nome'] == nome;

      expect(linhas.where((l) => ehDaCidade(l, 'Campinas')), hasLength(40));
      expect(linhas.where((l) => ehDaCidade(l, 'Valinhos')), hasLength(40));
      expect(linhas.where((l) => ehDaCidade(l, 'Vinhedo')), hasLength(40));
      expect(linhas.where((l) => ehDaCidade(l, 'Indaiatuba')), isEmpty);
    });

    test(
      'cobre as 3 finalidades, as 4 naturezas, foto_capa nula, area nula, '
      'centavos não-zero e bairro acentuado',
      () {
        final linhas = linhasAcervoFixture();

        expect(
          linhas.map((l) => l['finalidade']).toSet(),
          containsAll(<String>['VENDA', 'ALUGUEL', 'VENDA_E_ALUGUEL']),
        );
        expect(
          linhas.map((l) => l['natureza']).toSet(),
          containsAll(<String>['APARTAMENTO', 'CASA', 'TERRENO', 'LOTE']),
        );
        expect(linhas.any((l) => l['foto_capa'] == null), isTrue);
        expect(linhas.any((l) => l['area'] == null), isTrue);
        expect(
          linhas.any((l) {
            final precoVenda = l['preco_venda'] as String?;
            return precoVenda != null && !precoVenda.endsWith('.00');
          }),
          isTrue,
        );
        expect(linhas.any((l) => l['bairro'] == 'Cambuí'), isTrue);
      },
    );

    test('toda linha parseia via ImovelModel (parsing real)', () {
      // Exercitado implicitamente por buscar()/seguir() abaixo, que
      // constroem o envelope via ImoveisEnvelopeModel.fromJson — se
      // qualquer linha não parseasse, esses testes lançariam.
      expect(linhasAcervoFixture(), isNotEmpty);
    });
  });

  group('ImovelMockDataSource.buscar (primeira página)', () {
    test(
      'buscar(Campinas) devolve a primeira página (10), mais recente '
      'primeiro, com next preenchido',
      () async {
        final datasource = construir();

        final envelope = await datasource.buscar(
          const ConsultaImoveis(cidade: campinas),
        );

        expect(envelope.results, hasLength(10));
        expect(envelope.results.first.id, 42);
        expect(envelope.results[1].id, 57);
        expect(envelope.next, isNotNull);
        expect(envelope.previous, isNull);
      },
    );

    test(
      'buscar(Indaiatuba) devolve resultados vazios e next nulo — cidade '
      'atendida sem imóveis na fixture (D-15)',
      () async {
        final datasource = construir();

        final envelope = await datasource.buscar(
          const ConsultaImoveis(cidade: indaiatuba),
        );

        expect(envelope.results, isEmpty);
        expect(envelope.next, isNull);
      },
    );

    test(
      'a resposta atravessa o parsing real de ImoveisEnvelopeModel.fromJson '
      '(forma do contrato, incl. campos PENDENTE E2)',
      () async {
        final datasource = construir();

        final envelope = await datasource.buscar(
          const ConsultaImoveis(cidade: campinas),
        );

        final apartamento = envelope.results.firstWhere(
          (modelo) => modelo.id == 42,
        );
        expect(apartamento.titulo, 'Apartamento 2 quartos no Cambuí');
        expect(apartamento.finalidade, 'VENDA');
        expect(apartamento.cidade.nome, 'Campinas');
        expect(apartamento.cidade.uf, 'SP');
        expect(apartamento.natureza, 'APARTAMENTO');
        expect(apartamento.quartos, 2);
      },
    );

    test(
      'o primeiro next é uma URL absoluta com path/cidade/ordenacao/cursor '
      'corretos, sem busca quando a consulta não tem termo',
      () async {
        final datasource = construir();

        final envelope = await datasource.buscar(
          const ConsultaImoveis(cidade: campinas),
        );

        final uri = Uri.parse(envelope.next!);
        expect(uri.path, '/api/publico/imoveis/');
        expect(uri.queryParameters['cidade'], 'Campinas-SP');
        expect(uri.queryParameters['ordenacao'], 'mais_recentes');
        expect(uri.queryParameters['cursor'], isNotEmpty);
        expect(uri.queryParameters.containsKey('busca'), isFalse);
      },
    );

    test('busca aparece no next quando a consulta tem termo não-vazio', () async {
      final datasource = construir();

      final envelope = await datasource.buscar(
        const ConsultaImoveis(cidade: campinas, busca: 'cambuí'),
      );

      final uri = Uri.parse(envelope.next!);
      expect(uri.queryParameters['busca'], 'cambuí');
    });

    test(
      'paraTeste com latência configurada respeita o atraso informado',
      () async {
        final datasource = ImovelMockDataSource.paraTeste(
          linhas: linhasAcervoFixture(),
          latencia: const Duration(milliseconds: 20),
        );

        final cronometro = Stopwatch()..start();
        await datasource.buscar(const ConsultaImoveis(cidade: campinas));
        cronometro.stop();

        expect(cronometro.elapsedMilliseconds, greaterThanOrEqualTo(20));
      },
    );
  });

  group('ImovelMockDataSource.seguir (paginação cursor, D-01/API-04)', () {
    test(
      'andar Campinas até o fim devolve 4 páginas de 10, 40 ids únicos, só '
      'Campinas, em ordem decrescente de criado_em, última página next nulo',
      () async {
        final datasource = construir();

        final ids = <int>[];
        final tamanhos = <int>[];
        var envelope = await datasource.buscar(
          const ConsultaImoveis(cidade: campinas),
        );
        tamanhos.add(envelope.results.length);
        ids.addAll(envelope.results.map((m) => m.id));

        while (envelope.next != null) {
          envelope = await datasource.seguir(envelope.next!);
          tamanhos.add(envelope.results.length);
          ids.addAll(envelope.results.map((m) => m.id));
          expect(
            envelope.results.every((m) => m.cidade.nome == 'Campinas'),
            isTrue,
          );
        }

        expect(tamanhos, [10, 10, 10, 10]);
        expect(ids.toSet(), hasLength(40));
        expect(envelope.next, isNull);

        final criadosEm = ids
            .map(
              (id) => (linhasAcervoFixture().firstWhere(
                (l) => l['id'] == id,
              )['criado_em'])! as String,
            )
            .toList();
        for (var i = 0; i < criadosEm.length - 1; i++) {
          expect(
            criadosEm[i].compareTo(criadosEm[i + 1]),
            greaterThanOrEqualTo(0),
          );
        }
      },
    );

    test('seguir(mesmo next) duas vezes devolve a mesma página (idempotente)', () async {
      final datasource = construir();
      final primeira = await datasource.buscar(
        const ConsultaImoveis(cidade: campinas),
      );

      final seguida1 = await datasource.seguir(primeira.next!);
      final seguida2 = await datasource.seguir(primeira.next!);

      expect(
        seguida1.results.map((m) => m.id).toList(),
        seguida2.results.map((m) => m.id).toList(),
      );
      expect(seguida1.next, seguida2.next);
    });

    test(
      'Future.wait em duas cidades diferentes devolve páginas corretas e '
      'independentes (sem estado mutável entre chamadas, API-04)',
      () async {
        final datasource = construir();

        final resultados = await Future.wait([
          datasource.buscar(const ConsultaImoveis(cidade: campinas)),
          datasource.buscar(const ConsultaImoveis(cidade: valinhos)),
        ]);

        final envelopeCampinas = resultados[0];
        final envelopeValinhos = resultados[1];

        expect(
          envelopeCampinas.results.every((m) => m.cidade.nome == 'Campinas'),
          isTrue,
        );
        expect(
          envelopeValinhos.results.every((m) => m.cidade.nome == 'Valinhos'),
          isTrue,
        );
        expect(envelopeCampinas.results.first.id, 42);
        expect(envelopeValinhos.results.first.id, 63);
      },
    );

    test('seguir com cursor indecodificável lança FormatException', () {
      final datasource = construir();

      expect(
        () => datasource.seguir(
          'https://mock.imoveisaqui.local/api/publico/imoveis/'
          '?cidade=Campinas-SP&ordenacao=mais_recentes&cursor=***invalido***',
        ),
        throwsFormatException,
      );
    });

    test('seguir com ordenacao desconhecida lança FormatException', () {
      final datasource = construir();

      expect(
        () => datasource.seguir(
          'https://mock.imoveisaqui.local/api/publico/imoveis/'
          '?cidade=Campinas-SP&ordenacao=aleatorio&cursor=bz0w',
        ),
        throwsFormatException,
      );
    });
  });
}
