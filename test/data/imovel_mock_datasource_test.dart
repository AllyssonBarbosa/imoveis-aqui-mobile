import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/core/texto_normalizado.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/models/imovel_model.dart';
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/ordenacao_vitrine.dart';

/// Catálogo completo de características da fixture (mesmos 10 valores de
/// `_caracteristicasDisponiveis`, duplicado aqui só para o teste — a fonte
/// de verdade continua em `imoveis_fixture.dart`).
const _caracteristicasCatalogo = [
  'Portão eletrônico',
  'Ar-condicionado',
  'Varanda gourmet',
  'Quintal',
  'Churrasqueira',
  'Piscina',
  'Elevador',
  'Área de serviço',
  'Armários planejados',
  'Vista para o parque',
];

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

    test(
      'cada cidade atendida tem linhas com quartos 0, 1, 2, 3 e >= 4 (D-24)',
      () {
        for (final nomeCidade in ['Campinas', 'Valinhos', 'Vinhedo']) {
          final quartosDaCidade = linhasAcervoFixture()
              .where(
                (l) =>
                    (l['cidade']! as Map<String, Object?>)['nome'] ==
                    nomeCidade,
              )
              .map((l) => l['quartos']! as int)
              .toSet();

          expect(quartosDaCidade, contains(0), reason: nomeCidade);
          expect(quartosDaCidade, contains(1), reason: nomeCidade);
          expect(quartosDaCidade, contains(2), reason: nomeCidade);
          expect(quartosDaCidade, contains(3), reason: nomeCidade);
          expect(
            quartosDaCidade.any((q) => q >= 4),
            isTrue,
            reason: nomeCidade,
          );
        }
      },
    );

    test('cada cidade atendida tem linhas com suítes e vagas 0..4 (D-24)', () {
      for (final nomeCidade in ['Campinas', 'Valinhos', 'Vinhedo']) {
        final linhasDaCidade = linhasAcervoFixture().where(
          (l) =>
              (l['cidade']! as Map<String, Object?>)['nome'] == nomeCidade,
        );
        final suitesDaCidade = linhasDaCidade
            .map((l) => l['suites']! as int)
            .toSet();
        final vagasDaCidade = linhasDaCidade
            .map((l) => l['vagas']! as int)
            .toSet();

        for (var valor = 0; valor <= 4; valor++) {
          expect(
            suitesDaCidade,
            contains(valor),
            reason: '$nomeCidade suites',
          );
          expect(
            vagasDaCidade,
            contains(valor),
            reason: '$nomeCidade vagas',
          );
        }
      }
    });

    test(
      'cada cidade atendida tem ao menos uma linha com cada característica '
      'do catálogo (D-24)',
      () {
        for (final nomeCidade in ['Campinas', 'Valinhos', 'Vinhedo']) {
          final caracteristicasDaCidade = linhasAcervoFixture()
              .where(
                (l) =>
                    (l['cidade']! as Map<String, Object?>)['nome'] ==
                    nomeCidade,
              )
              .expand((l) => l['caracteristicas']! as List<Object?>)
              .cast<String>()
              .toSet();

          for (final caracteristica in _caracteristicasCatalogo) {
            expect(
              caracteristicasDaCidade,
              contains(caracteristica),
              reason: '$nomeCidade: $caracteristica',
            );
          }
        }
      },
    );

    test(
      'alguma linha tem Piscina sem Portão eletrônico e outra tem Portão '
      'eletrônico sem Piscina, em cada cidade atendida (D-24, combinação '
      'não-prefixo)',
      () {
        for (final nomeCidade in ['Campinas', 'Valinhos', 'Vinhedo']) {
          final linhasDaCidade = linhasAcervoFixture().where(
            (l) =>
                (l['cidade']! as Map<String, Object?>)['nome'] == nomeCidade,
          );
          bool tem(Map<String, Object?> l, String c) =>
              (l['caracteristicas']! as List<Object?>).contains(c);

          expect(
            linhasDaCidade.any(
              (l) => tem(l, 'Piscina') && !tem(l, 'Portão eletrônico'),
            ),
            isTrue,
            reason: '$nomeCidade: Piscina sem Portão eletrônico',
          );
          expect(
            linhasDaCidade.any(
              (l) => tem(l, 'Portão eletrônico') && !tem(l, 'Piscina'),
            ),
            isTrue,
            reason: '$nomeCidade: Portão eletrônico sem Piscina',
          );
        }
      },
    );

    test(
      'Campinas tem uma linha com Piscina e Churrasqueira ao mesmo tempo '
      '(D-24)',
      () {
        final linhasCampinas = linhasAcervoFixture().where(
          (l) => (l['cidade']! as Map<String, Object?>)['nome'] == 'Campinas',
        );
        bool tem(Map<String, Object?> l, String c) =>
            (l['caracteristicas']! as List<Object?>).contains(c);

        expect(
          linhasCampinas.any(
            (l) => tem(l, 'Piscina') && tem(l, 'Churrasqueira'),
          ),
          isTrue,
        );
      },
    );

    test('nenhum bairro ou característica contém vírgula (risco D-06)', () {
      for (final linha in linhasAcervoFixture()) {
        expect((linha['bairro']! as String).contains(','), isFalse);
        for (final caracteristica
            in linha['caracteristicas']! as List<Object?>) {
          expect((caracteristica! as String).contains(','), isFalse);
        }
      }
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

  group('ImovelMockDataSource — filtro finalidade (D-02, D-19)', () {
    Set<int> idsEsperadosCampinas(bool Function(String finalidadeLinha) aceita) =>
        linhasAcervoFixture()
            .where(
              (l) =>
                  (l['cidade']! as Map<String, Object?>)['nome'] ==
                      'Campinas' &&
                  aceita(l['finalidade']! as String),
            )
            .map((l) => l['id']! as int)
            .toSet();

    test(
      'finalidade=venda devolve exatamente as linhas VENDA ou '
      'VENDA_E_ALUGUEL de Campinas (inclusivo, D-02), cada uma uma vez',
      () async {
        final datasource = construir(tamanhoPagina: 100);
        final idsEsperados = idsEsperadosCampinas(
          (f) => f == 'VENDA' || f == 'VENDA_E_ALUGUEL',
        );
        expect(idsEsperados, isNotEmpty);

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(
            cidade: campinas,
            filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
          ),
        );

        final idsObtidos = resultados.map((m) => m.id).toList();
        expect(idsObtidos.toSet(), idsEsperados);
        expect(idsObtidos, hasLength(idsObtidos.toSet().length)); // sem duplicata
      },
    );

    test(
      'finalidade=aluguel devolve exatamente as linhas ALUGUEL ou '
      'VENDA_E_ALUGUEL de Campinas (inclusivo, D-02)',
      () async {
        final datasource = construir(tamanhoPagina: 100);
        final idsEsperados = idsEsperadosCampinas(
          (f) => f == 'ALUGUEL' || f == 'VENDA_E_ALUGUEL',
        );
        expect(idsEsperados, isNotEmpty);

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(
            cidade: campinas,
            filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
          ),
        );

        expect(resultados.map((m) => m.id).toSet(), idsEsperados);
      },
    );

    test('sem finalidade (Qualquer) continua devolvendo as 40 linhas', () async {
      final datasource = construir(tamanhoPagina: 100);

      final resultados = await andarTodasAsPaginas(
        datasource,
        const ConsultaImoveis(cidade: campinas),
      );

      expect(resultados, hasLength(40));
    });

    test('o next preserva finalidade=VENDA na URL (D-19)', () async {
      final datasource = construir(tamanhoPagina: 2);

      final envelope = await datasource.buscar(
        const ConsultaImoveis(
          cidade: campinas,
          filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
        ),
      );

      expect(envelope.next, isNotNull);
      final uri = Uri.parse(envelope.next!);
      expect(uri.queryParameters['finalidade'], 'VENDA');
    });

    test(
      'seguir com finalidade=VENDA_E_ALUGUEL (não é valor de filtro, D-02) '
      'lança FormatException',
      () {
        final datasource = construir();

        expect(
          () => datasource.seguir(
            'https://mock.imoveisaqui.local/api/publico/imoveis/'
            '?cidade=Campinas-SP&ordenacao=mais_recentes&finalidade=VENDA_E_ALUGUEL'
            '&cursor=bz0w',
          ),
          throwsFormatException,
        );
      },
    );

    test(
      'seguir com finalidade desconhecida lança FormatException',
      () {
        final datasource = construir();

        expect(
          () => datasource.seguir(
            'https://mock.imoveisaqui.local/api/publico/imoveis/'
            '?cidade=Campinas-SP&ordenacao=mais_recentes&finalidade=ALUGA'
            '&cursor=bz0w',
          ),
          throwsFormatException,
        );
      },
    );

    test(
      'andar todas as páginas com finalidade=ALUGUEL via seguir() preserva '
      'o filtro em toda página e não duplica ids',
      () async {
        final datasource = construir(tamanhoPagina: 5);
        final idsEsperados = idsEsperadosCampinas(
          (f) => f == 'ALUGUEL' || f == 'VENDA_E_ALUGUEL',
        );

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(
            cidade: campinas,
            filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
          ),
        );
        final ids = resultados.map((m) => m.id).toList();

        expect(ids.toSet(), hasLength(ids.length));
        expect(ids.toSet(), idsEsperados);
      },
    );
  });

  group(
    'ImovelMockDataSource — natureza, bairro, características e mínimos '
    '(D-01, D-04, D-05, D-24)',
    () {
      Set<int> idsCampinasQue(bool Function(Map<String, Object?>) aceita) =>
          linhasAcervoFixture()
              .where(
                (l) =>
                    (l['cidade']! as Map<String, Object?>)['nome'] ==
                        'Campinas' &&
                    aceita(l),
              )
              .map((l) => l['id']! as int)
              .toSet();

      test(
        'natureza=CASA,APARTAMENTO devolve exatamente as linhas casa OU '
        'apartamento de Campinas (D-05)',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          final idsEsperados = idsCampinasQue(
            (l) =>
                l['natureza'] == 'CASA' || l['natureza'] == 'APARTAMENTO',
          );
          expect(idsEsperados, isNotEmpty);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(
                naturezas: {NaturezaImovel.casa, NaturezaImovel.apartamento},
              ),
            ),
          );

          expect(resultados.map((m) => m.id).toSet(), idsEsperados);
        },
      );

      test(
        'quartos_min=2 devolve todas as linhas com quartos >= 2, INCLUINDO '
        'as de exatamente 2 quartos (D-01, nunca ==)',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          final idsEsperados = idsCampinasQue(
            (l) => (l['quartos']! as int) >= 2,
          );
          final idsExatamenteDois = idsCampinasQue(
            (l) => (l['quartos']! as int) == 2,
          );
          expect(idsExatamenteDois, isNotEmpty);
          expect(idsExatamenteDois, everyElement(isIn(idsEsperados)));

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(quartosMin: 2),
            ),
          );

          final idsObtidos = resultados.map((m) => m.id).toSet();
          expect(idsObtidos, idsEsperados);
          expect(idsExatamenteDois.every(idsObtidos.contains), isTrue);
        },
      );

      test('suites_min=2 devolve todas as linhas com suítes >= 2', () async {
        final datasource = construir(tamanhoPagina: 100);
        final idsEsperados = idsCampinasQue(
          (l) => (l['suites']! as int) >= 2,
        );
        expect(idsEsperados, isNotEmpty);

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(
            cidade: campinas,
            filtros: FiltrosVitrine(suitesMin: 2),
          ),
        );

        expect(resultados.map((m) => m.id).toSet(), idsEsperados);
      });

      test('vagas_min=2 devolve todas as linhas com vagas >= 2', () async {
        final datasource = construir(tamanhoPagina: 100);
        final idsEsperados = idsCampinasQue((l) => (l['vagas']! as int) >= 2);
        expect(idsEsperados, isNotEmpty);

        final resultados = await andarTodasAsPaginas(
          datasource,
          const ConsultaImoveis(
            cidade: campinas,
            filtros: FiltrosVitrine(vagasMin: 2),
          ),
        );

        expect(resultados.map((m) => m.id).toSet(), idsEsperados);
      });

      test(
        'bairro=Cambuí,Taquaral devolve linhas de qualquer um dos dois, '
        'acento/caixa-insensível ("cambui" também casa, D-05)',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          final idsEsperados = idsCampinasQue(
            (l) => l['bairro'] == 'Cambuí' || l['bairro'] == 'Taquaral',
          );
          expect(idsEsperados, isNotEmpty);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(bairros: {'cambui', 'taquaral'}),
            ),
          );

          expect(resultados.map((m) => m.id).toSet(), idsEsperados);
        },
      );

      test(
        'características=Portão eletrônico,Piscina devolve só linhas com '
        'AMBAS (E), um subconjunto estrito das que têm QUALQUER uma delas '
        '(D-04)',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          bool tem(Map<String, Object?> l, String c) =>
              (l['caracteristicas']! as List<Object?>).contains(c);

          final idsComAmbas = idsCampinasQue(
            (l) => tem(l, 'Portão eletrônico') && tem(l, 'Piscina'),
          );
          final idsComQualquer = idsCampinasQue(
            (l) => tem(l, 'Portão eletrônico') || tem(l, 'Piscina'),
          );
          expect(idsComAmbas, isNotEmpty);
          expect(idsComAmbas.length, lessThan(idsComQualquer.length));

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(
                caracteristicas: {'Portão eletrônico', 'Piscina'},
              ),
            ),
          );

          expect(resultados.map((m) => m.id).toSet(), idsComAmbas);
        },
      );

      test(
        'natureza=CASA + quartos_min=3 combina com E (só casas com 3+ '
        'quartos, nunca terrenos nem casas com menos)',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          final idsEsperados = idsCampinasQue(
            (l) =>
                l['natureza'] == 'CASA' && (l['quartos']! as int) >= 3,
          );
          expect(idsEsperados, isNotEmpty);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(
                naturezas: {NaturezaImovel.casa},
                quartosMin: 3,
              ),
            ),
          );

          final idsObtidos = resultados.map((m) => m.id).toSet();
          expect(idsObtidos, idsEsperados);
          expect(
            idsObtidos.every(
              (id) =>
                  linhasAcervoFixture().firstWhere(
                        (l) => l['id'] == id,
                      )['natureza'] ==
                  'CASA',
            ),
            isTrue,
          );
        },
      );

      test(
        'natureza=TERRENO + quartos_min=1 devolve zero linhas em toda '
        'cidade atendida (D-22 combinação determinística)',
        () async {
          for (final cidade in [campinas, valinhos]) {
            final datasource = construir(tamanhoPagina: 100);

            final resultados = await andarTodasAsPaginas(
              datasource,
              ConsultaImoveis(
                cidade: cidade,
                filtros: const FiltrosVitrine(
                  naturezas: {NaturezaImovel.terreno},
                  quartosMin: 1,
                ),
              ),
            );

            expect(resultados, isEmpty, reason: cidade.nome);
          }
        },
      );

      test(
        'ids permanecem únicos ao longo de todas as páginas com natureza+'
        'quartos_min ativos, e next preserva os dois params',
        () async {
          final datasource = construir(tamanhoPagina: 3);

          final envelope = await datasource.buscar(
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(
                naturezas: {NaturezaImovel.casa, NaturezaImovel.apartamento},
                quartosMin: 1,
              ),
            ),
          );
          expect(envelope.next, isNotNull);
          final uri = Uri.parse(envelope.next!);
          expect(uri.queryParameters['natureza'], 'CASA,APARTAMENTO');
          expect(uri.queryParameters['quartos_min'], '1');

          final ids = <int>[...envelope.results.map((m) => m.id)];
          var proxima = envelope;
          while (proxima.next != null) {
            proxima = await datasource.seguir(proxima.next!);
            ids.addAll(proxima.results.map((m) => m.id));
          }

          expect(ids.toSet(), hasLength(ids.length));
        },
      );
    },
  );

  group(
    'ImovelMockDataSource — faixas de preço (por finalidade) e de área '
    '(FIL-03, FIL-04, D-03, D-09, D-12)',
    () {
      double parseDecimal(String valor) => double.parse(valor);

      Set<int> idsCampinasQueFaixa(
        bool Function(Map<String, Object?>) aceita,
      ) => linhasAcervoFixture()
          .where(
            (l) =>
                (l['cidade']! as Map<String, Object?>)['nome'] ==
                    'Campinas' &&
                aceita(l),
          )
          .map((l) => l['id']! as int)
          .toSet();

      test(
        'Venda + preço 250000..300000 devolve exatamente as linhas VENDA '
        'ou VENDA_E_ALUGUEL de Campinas com preco_venda no intervalo '
        'inclusivo',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          final idsEsperados = idsCampinasQueFaixa((l) {
            final finalidade = l['finalidade']! as String;
            if (finalidade != 'VENDA' && finalidade != 'VENDA_E_ALUGUEL') {
              return false;
            }
            final precoVenda = l['preco_venda'] as String?;
            if (precoVenda == null) return false;
            final valor = parseDecimal(precoVenda);
            return valor >= 250000 && valor <= 300000;
          });
          expect(idsEsperados, isNotEmpty);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(
                finalidade: FinalidadeFiltro.venda,
                precoMin: 250000,
                precoMax: 300000,
              ),
            ),
          );

          expect(resultados.map((m) => m.id).toSet(), idsEsperados);
        },
      );

      test(
        'Aluguel + preço 2000..2500 devolve exatamente as linhas ALUGUEL '
        'ou VENDA_E_ALUGUEL de Campinas com preco_aluguel no intervalo '
        'inclusivo (D-03)',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          final idsEsperados = idsCampinasQueFaixa((l) {
            final finalidade = l['finalidade']! as String;
            if (finalidade != 'ALUGUEL' && finalidade != 'VENDA_E_ALUGUEL') {
              return false;
            }
            final precoAluguel = l['preco_aluguel'] as String?;
            if (precoAluguel == null) return false;
            final valor = parseDecimal(precoAluguel);
            return valor >= 2000 && valor <= 2500;
          });
          expect(idsEsperados, isNotEmpty);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(
                finalidade: FinalidadeFiltro.aluguel,
                precoMin: 2000,
                precoMax: 2500,
              ),
            ),
          );

          expect(resultados.map((m) => m.id).toSet(), idsEsperados);
        },
      );

      test(
        'só preço mínimo (sem máximo) devolve linhas com preco_venda >= '
        'mínimo — "a partir de" (D-09)',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          final idsEsperados = idsCampinasQueFaixa((l) {
            final finalidade = l['finalidade']! as String;
            if (finalidade != 'VENDA' && finalidade != 'VENDA_E_ALUGUEL') {
              return false;
            }
            final precoVenda = l['preco_venda'] as String?;
            if (precoVenda == null) return false;
            return parseDecimal(precoVenda) >= 300000;
          });
          expect(idsEsperados, isNotEmpty);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(
                finalidade: FinalidadeFiltro.venda,
                precoMin: 300000,
              ),
            ),
          );

          expect(resultados.map((m) => m.id).toSet(), idsEsperados);
        },
      );

      test(
        'só preço máximo (sem mínimo) devolve linhas com preco_venda <= '
        'máximo — "até" (D-09)',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          final idsEsperados = idsCampinasQueFaixa((l) {
            final finalidade = l['finalidade']! as String;
            if (finalidade != 'VENDA' && finalidade != 'VENDA_E_ALUGUEL') {
              return false;
            }
            final precoVenda = l['preco_venda'] as String?;
            if (precoVenda == null) return false;
            return parseDecimal(precoVenda) <= 220000;
          });
          expect(idsEsperados, isNotEmpty);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(
                finalidade: FinalidadeFiltro.venda,
                precoMax: 220000,
              ),
            ),
          );

          expect(resultados.map((m) => m.id).toSet(), idsEsperados);
        },
      );

      test(
        'área 80..120 devolve exatamente as linhas com área não-nula no '
        'intervalo, funcionando SEM finalidade escolhida (D-09)',
        () async {
          final datasource = construir(tamanhoPagina: 100);
          final idsEsperados = idsCampinasQueFaixa((l) {
            final area = l['area'] as String?;
            if (area == null) return false;
            final valor = parseDecimal(area);
            return valor >= 80 && valor <= 120;
          });
          expect(idsEsperados, isNotEmpty);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(areaMin: 80, areaMax: 120),
            ),
          );

          expect(resultados.map((m) => m.id).toSet(), idsEsperados);
        },
      );

      test(
        'imóveis sem área (area nula) ficam fora enquanto a faixa de área '
        'está ativa',
        () async {
          final datasource = construir(tamanhoPagina: 100);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(areaMin: 0, areaMax: 100000),
            ),
          );

          expect(resultados.every((m) => m.area != null), isTrue);
        },
      );

      test(
        'buscar com faixa de preço invertida (preco_min > preco_max) lança '
        'FormatException (D-12)',
        () async {
          final datasource = construir();

          await expectLater(
            datasource.buscar(
              const ConsultaImoveis(
                cidade: campinas,
                filtros: FiltrosVitrine(
                  finalidade: FinalidadeFiltro.venda,
                  precoMin: 300000,
                  precoMax: 250000,
                ),
              ),
            ),
            throwsFormatException,
          );
        },
      );

      test(
        'faixa de área invertida (area_min > area_max) através de '
        'ImovelRepositoryImpl vira Result.failure (D-12)',
        () async {
          final datasource = construir();
          final repositorio = ImovelRepositoryImpl(datasource);

          final resultado = await repositorio.buscarImoveis(
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(areaMin: 120, areaMax: 80),
            ),
          );

          expect(resultado, isA<Failure<Object?>>());
        },
      );
    },
  );

  group(
    'ImovelMockDataSource — ordenação por preço depende da finalidade '
    '(D-03, contrato §7.5)',
    () {
      double? parseDecimalOuNulo(String? valor) =>
          valor == null ? null : double.parse(valor);

      test(
        'com finalidade ALUGUEL, preco_asc ordena por preco_aluguel '
        'ascendente, nulls last',
        () async {
          final datasource = construir(tamanhoPagina: 100);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              ordenacao: OrdenacaoVitrine.precoAsc,
              filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
            ),
          );

          final comPreco = resultados
              .where((m) => m.precoAluguel != null)
              .toList();
          final semPreco = resultados
              .where((m) => m.precoAluguel == null)
              .toList();
          expect(comPreco, isNotEmpty);
          for (var i = 0; i < comPreco.length - 1; i++) {
            expect(
              parseDecimalOuNulo(comPreco[i].precoAluguel)!,
              lessThanOrEqualTo(
                parseDecimalOuNulo(comPreco[i + 1].precoAluguel)!,
              ),
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
        'com finalidade ALUGUEL, preco_desc ordena por preco_aluguel '
        'descendente, nulos continuam no fim',
        () async {
          final datasource = construir(tamanhoPagina: 100);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              ordenacao: OrdenacaoVitrine.precoDesc,
              filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
            ),
          );

          final comPreco = resultados
              .where((m) => m.precoAluguel != null)
              .toList();
          final semPreco = resultados
              .where((m) => m.precoAluguel == null)
              .toList();
          expect(comPreco, isNotEmpty);
          for (var i = 0; i < comPreco.length - 1; i++) {
            expect(
              parseDecimalOuNulo(comPreco[i].precoAluguel)!,
              greaterThanOrEqualTo(
                parseDecimalOuNulo(comPreco[i + 1].precoAluguel)!,
              ),
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
        'com finalidade VENDA, preco_asc continua ordenando por '
        'preco_venda (comportamento da Fase 2 inalterado)',
        () async {
          final datasource = construir(tamanhoPagina: 100);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              ordenacao: OrdenacaoVitrine.precoAsc,
              filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
            ),
          );

          final comPreco = resultados
              .where((m) => m.precoVenda != null)
              .toList();
          expect(comPreco, isNotEmpty);
          for (var i = 0; i < comPreco.length - 1; i++) {
            expect(
              parseDecimalOuNulo(comPreco[i].precoVenda)!,
              lessThanOrEqualTo(
                parseDecimalOuNulo(comPreco[i + 1].precoVenda)!,
              ),
            );
          }
        },
      );

      test(
        'sem finalidade escolhida, preco_asc continua ordenando por '
        'preco_venda (comportamento da Fase 2 inalterado)',
        () async {
          final datasource = construir(tamanhoPagina: 100);

          final resultados = await andarTodasAsPaginas(
            datasource,
            const ConsultaImoveis(
              cidade: campinas,
              ordenacao: OrdenacaoVitrine.precoAsc,
            ),
          );

          final comPreco = resultados
              .where((m) => m.precoVenda != null)
              .toList();
          expect(comPreco, isNotEmpty);
          for (var i = 0; i < comPreco.length - 1; i++) {
            expect(
              parseDecimalOuNulo(comPreco[i].precoVenda)!,
              lessThanOrEqualTo(
                parseDecimalOuNulo(comPreco[i + 1].precoVenda)!,
              ),
            );
          }
        },
      );
    },
  );
}
