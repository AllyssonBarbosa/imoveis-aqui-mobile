import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
import 'package:imoveis_aqui/data/models/imovel_model.dart';
import 'package:imoveis_aqui/data/models/url_segura.dart';
import 'package:imoveis_aqui/domain/entities/dados_natureza.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';

/// Contrato de parse de `DetalheImovelModel` (DET-06, T-04-03-01): um campo
/// obrigatório ausente é `TypeError` (que o repositório traduz), valores
/// desconhecidos de enum são tratados na `paraEntidade()`.
void main() {
  Map<String, Object?> mapaCompleto() =>
      Map<String, Object?>.of(detalhesAcervoFixture()[42]!);

  test('mapa completo do contrato é lido e mapeado para a entidade', () {
    final detalhe = DetalheImovelModel.fromJson(mapaCompleto()).paraEntidade();

    expect(detalhe.id, 42);
    expect(detalhe.titulo, 'Apartamento 2 quartos no Cambuí');
    expect(detalhe.finalidade, FinalidadeImovel.venda);
    expect(detalhe.fotos, isNotEmpty);
    expect(detalhe.caracteristicas, isNotEmpty);
  });

  test('mapa sem titulo lança TypeError em fromJson', () {
    final mapa = mapaCompleto()..remove('titulo');

    expect(() => DetalheImovelModel.fromJson(mapa), throwsA(isA<TypeError>()));
  });

  test('finalidade PERMUTA faz paraEntidade lançar FormatException', () {
    final mapa = mapaCompleto()..['finalidade'] = 'PERMUTA';
    final modelo = DetalheImovelModel.fromJson(mapa);

    expect(modelo.paraEntidade, throwsA(isA<FormatException>()));
  });

  test('natureza CHALE (desconhecida) vira null', () {
    final mapa = mapaCompleto()..['natureza'] = 'CHALE';

    final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

    expect(detalhe.natureza, isNull);
  });

  test('fotos e caracteristicas ausentes viram listas vazias', () {
    final mapa = mapaCompleto()
      ..remove('fotos')
      ..remove('caracteristicas');

    final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

    expect(detalhe.fotos, isEmpty);
    expect(detalhe.caracteristicas, isEmpty);
  });

  group('URLs seguras (DET-02, segurança V12/V13)', () {
    group('urlHttpOuNula', () {
      test('http e https passam sem alteração', () {
        expect(urlHttpOuNula('https://a.b/c.jpg'), 'https://a.b/c.jpg');
        expect(urlHttpOuNula('http://a.b/c.jpg'), 'http://a.b/c.jpg');
      });

      test('qualquer outro esquema, relativo, vazio ou nulo vira null', () {
        expect(urlHttpOuNula('javascript:alert(1)'), isNull);
        expect(urlHttpOuNula('file:///etc/passwd'), isNull);
        expect(urlHttpOuNula('/media/x.jpg'), isNull);
        expect(urlHttpOuNula('ftp://a.b/c.jpg'), isNull);
        expect(urlHttpOuNula('data:image/png;base64,AAAA'), isNull);
        expect(urlHttpOuNula('https://'), isNull);
        expect(urlHttpOuNula(''), isNull);
        expect(urlHttpOuNula(null), isNull);
      });

      test('espaços ao redor são aparados antes de validar', () {
        expect(urlHttpOuNula('  https://a.b/c.jpg '), 'https://a.b/c.jpg');
        expect(urlHttpOuNula('  javascript:x '), isNull);
      });
    });

    test(
      'DetalheImovelModel descarta fotos inseguras sem reordenar as demais',
      () {
        final mapa = mapaCompleto()
          ..['fotos'] = [
            {'url': 'https://a.b/A.jpg', 'capa': true, 'ordem': 0},
            {'url': 'javascript:alert(1)', 'capa': false, 'ordem': 1},
            {'url': 'https://a.b/C.jpg', 'capa': false, 'ordem': 2},
          ];

        final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

        expect(detalhe.fotos.map((f) => f.url), [
          'https://a.b/A.jpg',
          'https://a.b/C.jpg',
        ]);
      },
    );

    test('DetalheImovelModel zera a foto do corretor fora de http(s)', () {
      final mapa = mapaCompleto()
        ..['corretor'] = {
          'id': 7,
          'nome': 'Marina Lopes',
          'foto': 'file:///x',
          'slug': 'marina-lopes',
        };

      final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

      expect(detalhe.corretor?.foto, isNull);
      expect(detalhe.corretor?.nome, 'Marina Lopes');
    });

    test('DetalheImovelModel mantém a foto https do corretor', () {
      final detalhe = DetalheImovelModel.fromJson(mapaCompleto())
          .paraEntidade();

      expect(detalhe.corretor?.foto, startsWith('https://'));
    });

    test('ImovelModel descarta a capa da lista com esquema inseguro', () {
      final linha = Map<String, Object?>.of(linhasAcervoFixture().first)
        ..['foto_capa'] = 'javascript:x';

      final imovel = ImovelModel.fromJson(linha).paraEntidade();

      expect(imovel.fotoCapa, isNull);
    });

    test('ImovelModel mantém a capa https', () {
      final linha = Map<String, Object?>.of(linhasAcervoFixture().first)
        ..['foto_capa'] = 'https://a.b/capa.jpg';

      final imovel = ImovelModel.fromJson(linha).paraEntidade();

      expect(imovel.fotoCapa, 'https://a.b/capa.jpg');
    });
  });

  group('dados da natureza (DET-04, D-02, D-05, D-14)', () {
    Map<String, Object?> detalheDe(int id) =>
        Map<String, Object?>.of(detalhesAcervoFixture()[id]!);

    DadosNatureza? dadosDe(Map<String, Object?> mapa) =>
        DetalheImovelModel.fromJson(mapa).paraEntidade().dados;

    test('CASA com bloco casa vira DadosCasa com todos os campos', () {
      final mapa = detalheDe(57);

      final dados = dadosDe(mapa);

      expect(
        dados,
        const DadosNatureza.casa(
          areaTerreno: '300.00',
          areaConstruida: '180.00',
          areaLivre: '100.00',
          quartos: 3,
          suites: 0,
          banheiros: 2,
          salas: 2,
          vagas: 2,
          pavimentos: 1,
          anoConstrucao: 1998,
          piscina: false,
          quintal: true,
          churrasqueira: true,
          mobiliada: false,
        ),
      );
    });

    test('area_livre chega exatamente como o servidor mandou, sem cálculo', () {
      final dados = dadosDe(detalheDe(57));

      expect(dados, isA<DadosCasa>());
      final casa = dados! as DadosCasa;
      // 300,00 - 180,00 seria 120,00: o app nunca recalcula (D-04).
      expect(casa.areaLivre, '100.00');
      expect(casa.areaTerreno, '300.00');
      expect(casa.areaConstruida, '180.00');
    });

    test('TERRENO com topografia ACLIVE vira DadosTerreno aclive', () {
      final dados = dadosDe(detalheDe(63));

      expect(
        dados,
        const DadosNatureza.terreno(
          areaTotal: '300.00',
          frente: '12.00',
          fundo: '25.00',
          laterais: '25.00',
          topografia: Topografia.aclive,
          murado: true,
          esquina: false,
          usoPermitido: 'Residencial',
        ),
      );
    });

    test(
      'topografia PLANO, ACLIVE e DECLIVE são mapeadas; outra vira null',
      () {
        Topografia? topografiaCom(String? valor) {
          final mapa = detalheDe(63);
          mapa['terreno'] = {
            ...(mapa['terreno']! as Map<String, Object?>),
            'topografia': valor,
          };
          return (dadosDe(mapa)! as DadosTerreno).topografia;
        }

        expect(topografiaCom('PLANO'), Topografia.plano);
        expect(topografiaCom('ACLIVE'), Topografia.aclive);
        expect(topografiaCom('DECLIVE'), Topografia.declive);
        expect(topografiaCom('INCLINADO'), isNull);
        expect(topografiaCom(null), isNull);
      },
    );

    test('APARTAMENTO mapeia os campos próprios do apartamento', () {
      final dados = dadosDe(detalheDe(42));

      expect(dados, isA<DadosApartamento>());
      final apto = dados! as DadosApartamento;
      expect(apto.andar, 8);
      expect(apto.numero, '82');
      expect(apto.areaPrivativa, '68.50');
      expect(apto.areaTotal, '92.00');
      expect(apto.quartos, 2);
      expect(apto.suites, 1);
      expect(apto.banheiros, 2);
      expect(apto.vagas, 1);
      expect(apto.varanda, isTrue);
    });

    test('posicao_solar chega como o texto da API, sem enum (D-19 b)', () {
      expect(
        (dadosDe(detalheDe(42))! as DadosApartamento).posicaoSolar,
        'Nascente',
      );

      final mapa = detalheDe(42);
      mapa['apartamento'] = {
        ...(mapa['apartamento']! as Map<String, Object?>),
        'posicao_solar': 'Sol da manhã',
      };
      expect((dadosDe(mapa)! as DadosApartamento).posicaoSolar, 'Sol da manhã');
    });

    test('LOTE mapeia os campos próprios do lote', () {
      final mapa = detalheDe(103);
      mapa['lote'] = {
        'numero': '12',
        'area': '450.00',
        'frente': '15.00',
        'fundo': '30.00',
        'preco': '180000.00',
        'condicoes_parcelamento': 'Entrada de 20%',
      };

      final dados = dadosDe(mapa);

      expect(
        dados,
        const DadosNatureza.lote(
          numero: '12',
          area: '450.00',
          frente: '15.00',
          fundo: '30.00',
          preco: '180000.00',
          condicoesParcelamento: 'Entrada de 20%',
        ),
      );
    });

    test(
      'todos os campos do bloco são opcionais (bloco vazio não derruba)',
      () {
        final mapa = detalheDe(57);
        mapa['casa'] = <String, Object?>{};

        final dados = dadosDe(mapa);

        expect(dados, const DadosNatureza.casa());
      },
    );

    test('natureza desconhecida resulta em dados == null', () {
      final mapa = detalheDe(57)..['natureza'] = 'CHALE';

      expect(() => dadosDe(mapa), returnsNormally);
      expect(dadosDe(mapa), isNull);
    });

    test('bloco nulo ou ausente resulta em dados == null', () {
      final nulo = detalheDe(57)..['casa'] = null;
      final ausente = detalheDe(57)..remove('casa');

      expect(dadosDe(nulo), isNull);
      expect(dadosDe(ausente), isNull);
    });

    test('natureza sem bloco próprio (só outro bloco preenchido) -> null', () {
      final mapa = detalheDe(57)
        ..['casa'] = null
        ..['apartamento'] = (detalheDe(42)['apartamento']);

      expect(() => dadosDe(mapa), returnsNormally);
      expect(dadosDe(mapa), isNull);
    });

    test('natureza ausente resulta em dados == null mesmo com bloco', () {
      final mapa = detalheDe(57)..remove('natureza');

      expect(dadosDe(mapa), isNull);
    });
  });

  group('prédio, quadra e loteamento embutidos (DET-04, D-03)', () {
    Map<String, Object?> detalheDe(int id) =>
        Map<String, Object?>.of(detalhesAcervoFixture()[id]!);

    DadosNatureza? dadosDe(Map<String, Object?> mapa) =>
        DetalheImovelModel.fromJson(mapa).paraEntidade().dados;

    test('apartamento.predio vira DadosPredio com todos os campos', () {
      final apto = dadosDe(detalheDe(42))! as DadosApartamento;

      expect(
        apto.predio,
        const DadosPredio(
          nome: 'Edifício Jequitibá',
          andares: 15,
          unidadesPorAndar: 4,
          ano: 2012,
          elevadores: 2,
          portaria24h: true,
          piscina: true,
          academia: true,
          salaoDeFestas: true,
          playground: false,
        ),
      );
    });

    test('predio nulo ou ausente vira null', () {
      Map<String, Object?> comPredio(Object? valor) {
        final mapa = detalheDe(42);
        mapa['apartamento'] = {
          ...(mapa['apartamento']! as Map<String, Object?>),
          'predio': valor,
        };
        return mapa;
      }

      expect((dadosDe(comPredio(null))! as DadosApartamento).predio, isNull);

      final ausente = detalheDe(42);
      (ausente['apartamento']! as Map<String, Object?>).remove('predio');
      expect((dadosDe(ausente)! as DadosApartamento).predio, isNull);
    });

    test('lote.quadra vira DadosQuadra com o loteamento mapeado', () {
      final lote = dadosDe(detalheDe(103))! as DadosLote;

      expect(lote.quadra?.identificacao, 'Quadra B');
      expect(lote.quadra?.loteamento?.nome, 'Residencial Parque das Flores');
      expect(lote.quadra?.loteamento?.incorporadora, 'Flores Urbanismo');
      expect(lote.quadra?.loteamento?.infraestrutura, [
        'Asfalto',
        'Água encanada',
        'Rede de esgoto',
        'Energia elétrica',
        'Iluminação pública',
      ]);
      expect(lote.quadra?.loteamento?.areasLazer, [
        'Praça',
        'Playground',
        'Quadra poliesportiva',
      ]);
    });

    test('infraestrutura e areas_lazer ausentes viram listas vazias', () {
      final mapa = detalheDe(103);
      mapa['lote'] = {
        ...(mapa['lote']! as Map<String, Object?>),
        'quadra': {
          'identificacao': 'Quadra A',
          'loteamento': {'nome': 'Residencial X'},
        },
      };

      final lote = dadosDe(mapa)! as DadosLote;

      expect(lote.quadra?.loteamento?.infraestrutura, isEmpty);
      expect(lote.quadra?.loteamento?.areasLazer, isEmpty);
    });

    test('quadra nula e loteamento nulo viram null', () {
      final semQuadra = detalheDe(103);
      semQuadra['lote'] = {
        ...(semQuadra['lote']! as Map<String, Object?>),
        'quadra': null,
      };
      expect((dadosDe(semQuadra)! as DadosLote).quadra, isNull);

      final semLoteamento = detalheDe(103);
      semLoteamento['lote'] = {
        ...(semLoteamento['lote']! as Map<String, Object?>),
        'quadra': {'identificacao': 'Quadra A', 'loteamento': null},
      };
      final quadra = (dadosDe(semLoteamento)! as DadosLote).quadra;
      expect(quadra?.identificacao, 'Quadra A');
      expect(quadra?.loteamento, isNull);
    });

    test('lote 103 mantém o preço do servidor, sem derivar de preco_venda', () {
      final lote = dadosDe(detalheDe(103))! as DadosLote;
      final semPreco = detalheDe(103);
      semPreco['lote'] = {
        ...(semPreco['lote']! as Map<String, Object?>),
        'preco': null,
      };

      expect(lote.preco, '210500.50');
      expect((dadosDe(semPreco)! as DadosLote).preco, isNull);
    });
  });
}
