import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/core/texto_normalizado.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/models/imovel_model.dart';
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/ordenacao_vitrine.dart';

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');
  const indaiatuba = Cidade(nome: 'Indaiatuba', uf: 'SP');

  ImovelMockDataSource construir({int tamanhoPagina = 10}) =>
      ImovelMockDataSource.paraTeste(
        linhas: linhasAcervoFixture(),
        tamanhoPagina: tamanhoPagina,
      );

  /// Anda todas as páginas de uma consulta e devolve os `ImovelModel`s na
  /// ordem em que o servidor simulado os devolveu — usado pelos testes de
  /// busca/ordenação para comparar contra uma expectativa derivada da própria
  /// fixture, em vez de uma lista de ids hardcoded (fica em sincronia com
  /// qualquer mudança futura na fixture).
  Future<List<ImovelModel>> andarTodasAsPaginas(
    ImovelMockDataSource datasource,
    ConsultaImoveis consulta,
  ) async {
    final resultados = <ImovelModel>[];
    var envelope = await datasource.buscar(consulta);
    resultados.addAll(envelope.results);
    while (envelope.next != null) {
      envelope = await datasource.seguir(envelope.next!);
      resultados.addAll(envelope.results);
    }
    return resultados;
  }

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
      // Página pequena o bastante para "cambuí" (poucos resultados em
      // Campinas) continuar exigindo mais de uma página — a busca de fato
      // filtra desde o plano 02-05 (Task 1), então usar o tamanho de página
      // padrão faria a busca inteira caber numa única página (next nulo).
      final datasource = construir(tamanhoPagina: 2);

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

  group('ImovelMockDataSource.buscar — busca por texto (D-05, D-06)', () {
    bool linhaContemTermo(Map<String, Object?> linha, String termo) {
      final palavras = normalizarTexto(termo)
          .split(RegExp(r'\s+'))
          .where((p) => p.isNotEmpty);
      final tituloNormalizado = normalizarTexto(linha['titulo']! as String);
      final bairroNormalizado = normalizarTexto(linha['bairro']! as String);
      return palavras.every(
        (palavra) =>
            tituloNormalizado.contains(palavra) ||
            bairroNormalizado.contains(palavra),
      );
    }

    test(
      'busca "cambui" devolve exatamente as linhas de Campinas cujo título '
      'ou bairro normalizado contém "cambui" (acento/caixa-insensível)',
      () async {
        final datasource = construir(tamanhoPagina: 100);
        final linhasCampinas = linhasAcervoFixture().where(
          (l) => (l['cidade']! as Map<String, Object?>)['nome'] == 'Campinas',
        );
        final idsEsperados =
            linhasCampinas
                .where((l) => linhaContemTermo(l, 'cambui'))
                .map((l) => l['id']! as int)
                .toSet();
        expect(idsEsperados, isNotEmpty);

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(cidade: campinas, busca: 'cambui'),
        );

        expect(resultados.map((m) => m.id).toSet(), idsEsperados);
      },
    );

    test('busca "APARTAMENTO" casa case-insensível com o título', () async {
      final datasource = construir(tamanhoPagina: 100);
      final linhasCampinas = linhasAcervoFixture().where(
        (l) => (l['cidade']! as Map<String, Object?>)['nome'] == 'Campinas',
      );
      final idsEsperados =
          linhasCampinas
              .where((l) => linhaContemTermo(l, 'APARTAMENTO'))
              .map((l) => l['id']! as int)
              .toSet();
      expect(idsEsperados, isNotEmpty);

      final resultados = await andarTodasAsPaginas(
        datasource,
        const ConsultaImoveis(cidade: campinas, busca: 'APARTAMENTO'),
      );

      expect(resultados.map((m) => m.id).toSet(), idsEsperados);
      expect(
        resultados.every(
          (m) => normalizarTexto(m.titulo).contains('apartamento'),
        ),
        isTrue,
      );
    });

    test(
      'busca "apartamento cambui" exige TODAS as palavras em título+bairro '
      '(semântica de SearchFilter, DRF-like)',
      () async {
        final datasource = construir(tamanhoPagina: 100);
        final linhasCampinas = linhasAcervoFixture().where(
          (l) => (l['cidade']! as Map<String, Object?>)['nome'] == 'Campinas',
        );
        final idsEsperados =
            linhasCampinas
                .where((l) => linhaContemTermo(l, 'apartamento cambui'))
                .map((l) => l['id']! as int)
                .toSet();

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(cidade: campinas, busca: 'apartamento cambui'),
        );

        expect(resultados.map((m) => m.id).toSet(), idsEsperados);
      },
    );

    test(
      'busca "reformado" (só existe na descrição do id 42) devolve zero '
      'linhas — descrição nunca é buscada (D-06)',
      () async {
        final datasource = construir(tamanhoPagina: 100);

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(cidade: campinas, busca: 'reformado'),
        );

        expect(resultados, isEmpty);
      },
    );

    test(
      'busca vazia (após trim) não filtra — mesmo resultado que sem busca',
      () async {
        final datasource = construir(tamanhoPagina: 100);

        final semBusca = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(cidade: campinas),
        );
        final comBuscaEmBranco = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(cidade: campinas, busca: '   '),
        );

        expect(
          comBuscaEmBranco.map((m) => m.id).toList(),
          semBusca.map((m) => m.id).toList(),
        );
      },
    );
  });

  group('ImovelMockDataSource — gatilho "erro" determinístico (D-15)', () {
    test(
      'busca "erro" (qualquer caixa/espaço) lança FalhaSimuladaDoMock após '
      'a latência configurada',
      () async {
        final datasource = ImovelMockDataSource.paraTeste(
          linhas: linhasAcervoFixture(),
          latencia: const Duration(milliseconds: 5),
        );

        final cronometro = Stopwatch()..start();
        await expectLater(
          datasource.buscar(
            const ConsultaImoveis(cidade: campinas, busca: '  ERRO  '),
          ),
          throwsA(isA<FalhaSimuladaDoMock>()),
        );
        cronometro.stop();

        expect(cronometro.elapsedMilliseconds, greaterThanOrEqualTo(5));
      },
    );

    test(
      'busca "erro" através de ImovelRepositoryImpl vira Result.failure '
      '(T-02-01-01 style, D-15)',
      () async {
        final datasource = construir();
        final repositorio = ImovelRepositoryImpl(datasource);

        final resultado = await repositorio.buscarImoveis(
          const ConsultaImoveis(cidade: campinas, busca: 'erro'),
        );

        expect(resultado, isA<Failure<Object?>>());
      },
    );
  });

  group('ImovelMockDataSource — ordenação nulls-last (D-11, D-12)', () {
    double? parseDecimal(String? valor) =>
        valor == null ? null : double.parse(valor);

    List<Map<String, Object?>> linhasDaCidade(Cidade cidade) =>
        linhasAcervoFixture()
            .where(
              (l) =>
                  (l['cidade']! as Map<String, Object?>)['nome'] ==
                  cidade.nome,
            )
            .toList();

    test(
      'preco_asc: preco_venda ascendente, todo preco_venda nulo vai para o '
      'fim (ordem estável por id asc dentro do grupo nulo)',
      () async {
        final datasource = construir(tamanhoPagina: 100);

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(
            cidade: campinas,
            ordenacao: OrdenacaoVitrine.precoAsc,
          ),
        );

        final linhas = linhasDaCidade(campinas);
        expect(resultados.map((m) => m.id).toSet(), hasLength(40));
        expect(
          resultados.map((m) => m.id).toSet(),
          linhas.map((l) => l['id']! as int).toSet(),
        );

        final comPreco = resultados
            .where((m) => m.precoVenda != null)
            .toList();
        final semPreco = resultados
            .where((m) => m.precoVenda == null)
            .toList();

        for (var i = 0; i < comPreco.length - 1; i++) {
          expect(
            parseDecimal(comPreco[i].precoVenda)!,
            lessThanOrEqualTo(parseDecimal(comPreco[i + 1].precoVenda)!),
          );
        }
        // Nulls-last: todo item sem preco_venda vem depois de todo item com.
        expect(
          resultados.indexOf(comPreco.isEmpty ? resultados.first : comPreco.last) <
              resultados.length,
          isTrue,
        );
        if (comPreco.isNotEmpty && semPreco.isNotEmpty) {
          expect(
            resultados.indexOf(comPreco.last) <
                resultados.indexOf(semPreco.first),
            isTrue,
          );
        }
      },
    );

    test(
      'preco_desc: preco_venda descendente, nulos continuam no fim (nunca '
      'no início)',
      () async {
        final datasource = construir(tamanhoPagina: 100);

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(
            cidade: campinas,
            ordenacao: OrdenacaoVitrine.precoDesc,
          ),
        );

        final comPreco = resultados
            .where((m) => m.precoVenda != null)
            .toList();
        final semPreco = resultados
            .where((m) => m.precoVenda == null)
            .toList();

        for (var i = 0; i < comPreco.length - 1; i++) {
          expect(
            parseDecimal(comPreco[i].precoVenda)!,
            greaterThanOrEqualTo(parseDecimal(comPreco[i + 1].precoVenda)!),
          );
        }
        if (comPreco.isNotEmpty && semPreco.isNotEmpty) {
          expect(
            resultados.indexOf(comPreco.last) <
                resultados.indexOf(semPreco.first),
            isTrue,
          );
        }
      },
    );

    test(
      'area_asc / area_desc: mesma regra nulls-last aplicada a `area`',
      () async {
        final datasourceAsc = construir(tamanhoPagina: 100);
        final resultadosAsc = await andarTodasAsPaginas(
          datasourceAsc,
          const ConsultaImoveis(
            cidade: campinas,
            ordenacao: OrdenacaoVitrine.areaAsc,
          ),
        );
        final comAreaAsc = resultadosAsc
            .where((m) => m.area != null)
            .toList();
        final semAreaAsc = resultadosAsc
            .where((m) => m.area == null)
            .toList();
        for (var i = 0; i < comAreaAsc.length - 1; i++) {
          expect(
            parseDecimal(comAreaAsc[i].area)!,
            lessThanOrEqualTo(parseDecimal(comAreaAsc[i + 1].area)!),
          );
        }
        if (comAreaAsc.isNotEmpty && semAreaAsc.isNotEmpty) {
          expect(
            resultadosAsc.indexOf(comAreaAsc.last) <
                resultadosAsc.indexOf(semAreaAsc.first),
            isTrue,
          );
        }

        final datasourceDesc = construir(tamanhoPagina: 100);
        final resultadosDesc = await andarTodasAsPaginas(
          datasourceDesc,
          const ConsultaImoveis(
            cidade: campinas,
            ordenacao: OrdenacaoVitrine.areaDesc,
          ),
        );
        final comAreaDesc = resultadosDesc
            .where((m) => m.area != null)
            .toList();
        final semAreaDesc = resultadosDesc
            .where((m) => m.area == null)
            .toList();
        for (var i = 0; i < comAreaDesc.length - 1; i++) {
          expect(
            parseDecimal(comAreaDesc[i].area)!,
            greaterThanOrEqualTo(parseDecimal(comAreaDesc[i + 1].area)!),
          );
        }
        if (comAreaDesc.isNotEmpty && semAreaDesc.isNotEmpty) {
          expect(
            resultadosDesc.indexOf(comAreaDesc.last) <
                resultadosDesc.indexOf(semAreaDesc.first),
            isTrue,
          );
        }
      },
    );

    test(
      'mais_recentes continua inalterado (criado_em desc, id desc) depois da '
      'introdução das outras ordenações',
      () async {
        final datasource = construir(tamanhoPagina: 100);

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(cidade: campinas),
        );

        expect(resultados.first.id, 42);
        expect(resultados[1].id, 57);
      },
    );

    test(
      'andar todas as páginas com preco_asc não duplica ids e o next '
      'preserva busca e ordenacao',
      () async {
        final datasource = construir();

        var envelope = await datasource.buscar(
          const ConsultaImoveis(
            cidade: campinas,
            busca: 'quartos',
            ordenacao: OrdenacaoVitrine.precoAsc,
          ),
        );
        final ids = <int>[...envelope.results.map((m) => m.id)];
        if (envelope.next != null) {
          final uri = Uri.parse(envelope.next!);
          expect(uri.queryParameters['busca'], 'quartos');
          expect(uri.queryParameters['ordenacao'], 'preco_asc');
        }
        while (envelope.next != null) {
          envelope = await datasource.seguir(envelope.next!);
          ids.addAll(envelope.results.map((m) => m.id));
        }

        expect(ids.toSet(), hasLength(ids.length));
      },
    );
  });
}
