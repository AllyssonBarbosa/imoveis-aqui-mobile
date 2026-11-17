import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/canal_contato_api.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
import 'package:imoveis_aqui/data/models/imovel_model.dart';
import 'package:imoveis_aqui/data/models/url_segura.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/dados_natureza.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';

import '../support/api_falsa.dart';

/// Contrato de parse de `DetalheImovelModel` sobre o JSON REAL capturado da
/// API (`test/fixtures/api/detalhe_*.json`, D-15, DET-06, T-04-03-01): um
/// campo obrigatório ausente é `TypeError` (que o repositório traduz), valores
/// desconhecidos de enum são tratados na `paraEntidade()`. Os mapas alterados
/// são sempre cópias da captura com uma chave mudada.
void main() {
  Map<String, Object?> detalheCapturado(String nome) =>
      Map<String, Object?>.of(lerFixtureApi(nome)! as Map<String, Object?>);

  Map<String, Object?> mapaCompleto() => detalheCapturado('detalhe_casa.json');

  Map<String, Object?> enderecoCapturado() =>
      Map<String, Object?>.of(mapaCompleto()['endereco']! as Map<String, Object?>);

  group('canais_contato capturado -> entidade (D-01)', () {
    const capturados = [
      'detalhe_casa.json',
      'detalhe_apartamento.json',
      'detalhe_terreno.json',
      'detalhe_lote.json',
      'detalhe_sem_fotos.json',
      'detalhe_sem_corretor.json',
    ];

    for (final nome in capturados) {
      test('$nome: os nomes da entidade são os do JSON, na mesma ordem', () {
        final capturado = detalheCapturado(nome);

        final detalhe = DetalheImovelModel.fromJson(capturado).paraEntidade();

        expect(
          detalhe.canaisContato.map((canal) => canal.valorApi).toList(),
          capturado['canais_contato'],
        );
      });
    }

    test('a casa tem WhatsApp, telefone e e-mail, nessa ordem', () {
      final detalhe = DetalheImovelModel.fromJson(
        detalheCapturado('detalhe_casa.json'),
      ).paraEntidade();

      expect(detalhe.canaisContato, [
        CanalContato.whatsapp,
        CanalContato.telefone,
        CanalContato.email,
      ]);
    });

    test('sem corretor: canais da empresa não vazios e corretor nulo', () {
      final detalhe = DetalheImovelModel.fromJson(
        detalheCapturado('detalhe_sem_corretor.json'),
      ).paraEntidade();

      expect(detalhe.corretor, isNull);
      expect(detalhe.canaisContato, isNotEmpty);
    });
  });

  group('canais_contato (D-01, D-03)', () {
    List<CanalContato> canaisDe(Map<String, Object?> json) =>
        DetalheImovelModel.fromJson(json).paraEntidade().canaisContato;

    test('chave ausente: o detalhe parseia e a lista é vazia', () {
      final mapa = mapaCompleto()..remove('canais_contato');

      expect(canaisDe(mapa), isEmpty);
    });

    test('valor nulo: o detalhe parseia e a lista é vazia', () {
      final mapa = mapaCompleto()..['canais_contato'] = null;

      expect(canaisDe(mapa), isEmpty);
    });

    test('nome desconhecido é descartado e o detalhe continua parseando', () {
      final mapa = mapaCompleto()..['canais_contato'] = ['SMS', 'EMAIL', 'FAX'];

      expect(canaisDe(mapa), [CanalContato.email]);
    });

    test('repetido e fora de ordem: ordem do enum, sem duplicata', () {
      final mapa = mapaCompleto()
        ..['canais_contato'] = ['EMAIL', 'WHATSAPP', 'EMAIL'];

      expect(canaisDe(mapa), [CanalContato.whatsapp, CanalContato.email]);
    });

    test('lista vazia: só canaisContato muda em relação à captura', () {
      final original = DetalheImovelModel.fromJson(
        mapaCompleto(),
      ).paraEntidade();
      final mapa = mapaCompleto()..['canais_contato'] = <String>[];

      final vazio = DetalheImovelModel.fromJson(mapa).paraEntidade();

      expect(vazio.canaisContato, isEmpty);
      expect(
        vazio,
        original.copyWith(canaisContato: const <CanalContato>[]),
      );
    });
  });

  group('detalhes capturados', () {
    for (final nome in [
      'detalhe_casa.json',
      'detalhe_apartamento.json',
      'detalhe_terreno.json',
      'detalhe_lote.json',
      'detalhe_sem_fotos.json',
      'detalhe_sem_corretor.json',
    ]) {
      test('$nome parseia e vira a entidade', () {
        final capturado = detalheCapturado(nome);

        final detalhe = DetalheImovelModel.fromJson(capturado).paraEntidade();

        expect(detalhe.id, capturado['id']);
        expect(detalhe.titulo, capturado['titulo']);
        expect(detalhe.cidade?.nome, 'Campinas');
      });
    }
  });

  group('detalhe_casa.json no wire real (D-15, D-16)', () {
    test('endereco é lido inteiro, como veio na captura', () {
      final capturado = mapaCompleto();
      final endereco = capturado['endereco']! as Map<String, Object?>;
      final cidade = endereco['cidade']! as Map<String, Object?>;

      final modelo = DetalheImovelModel.fromJson(capturado);

      expect(modelo.endereco?.logradouro, endereco['logradouro']);
      expect(modelo.endereco?.numero, endereco['numero']);
      expect(modelo.endereco?.bairro, endereco['bairro']);
      expect(modelo.endereco?.cep, endereco['cep']);
      expect(modelo.endereco?.cidade?.id, cidade['id']);
      expect(modelo.endereco?.cidade?.nome, cidade['nome']);
      expect(modelo.endereco?.cidade?.uf, cidade['uf']);
      expect(modelo.endereco?.latitude, endereco['latitude']);
      expect(modelo.endereco?.longitude, endereco['longitude']);
    });

    test('a entidade traz bairro, cidade e coordenadas do endereco', () {
      final capturado = mapaCompleto();
      final endereco = capturado['endereco']! as Map<String, Object?>;

      final detalhe = DetalheImovelModel.fromJson(capturado).paraEntidade();

      expect(detalhe.bairro, endereco['bairro']);
      expect(detalhe.cidade?.nome, 'Campinas');
      expect(detalhe.cidade?.uf, 'SP');
      expect(detalhe.latitude, endereco['latitude']);
      expect(detalhe.longitude, endereco['longitude']);
    });

    test('campos de topo e preços chegam como a API mandou', () {
      final capturado = mapaCompleto();

      final detalhe = DetalheImovelModel.fromJson(capturado).paraEntidade();

      expect(detalhe.id, 21);
      expect(detalhe.titulo, capturado['titulo']);
      expect(detalhe.finalidade, FinalidadeImovel.venda);
      expect(detalhe.natureza, NaturezaImovel.casa);
      expect(detalhe.precoVenda, capturado['preco_venda']);
      expect(detalhe.precoAluguel, isNull);
      expect(detalhe.descricao, capturado['descricao']);
    });

    test('fotos: url = imagem, ordem e capa como recebidas, sem reordenar', () {
      final capturado = mapaCompleto();
      final fotos = (capturado['fotos']! as List<Object?>)
          .cast<Map<String, Object?>>();

      final modelo = DetalheImovelModel.fromJson(capturado);
      final detalhe = modelo.paraEntidade();

      expect(modelo.fotos.map((f) => f.url), fotos.map((f) => f['imagem']));
      expect(modelo.fotos.map((f) => f.ordem), fotos.map((f) => f['ordem']));
      expect(modelo.fotos.map((f) => f.capa), fotos.map((f) => f['capa']));
      expect(detalhe.fotos.map((f) => f.url), fotos.map((f) => f['imagem']));
      expect(detalhe.fotos.first.capa, isTrue);
    });

    test('características viram a lista de nomes', () {
      final detalhe = DetalheImovelModel.fromJson(mapaCompleto())
          .paraEntidade();

      expect(detalhe.caracteristicas, ['Churrasqueira', 'Varanda gourmet']);
    });

    test('corretor_responsavel: id, nome e foto', () {
      final capturado = mapaCompleto();
      final corretor =
          capturado['corretor_responsavel']! as Map<String, Object?>;

      final detalhe = DetalheImovelModel.fromJson(capturado).paraEntidade();

      expect(detalhe.corretor?.id, corretor['id']);
      expect(detalhe.corretor?.nome, corretor['nome']);
      expect(detalhe.corretor?.foto, corretor['foto']);
    });

    test('corretor_responsavel null vira corretor null', () {
      final detalhe = DetalheImovelModel.fromJson(
        detalheCapturado('detalhe_sem_corretor.json'),
      ).paraEntidade();

      expect(detalhe.corretor, isNull);
    });

    test('fotos [] vira lista vazia', () {
      final detalhe = DetalheImovelModel.fromJson(
        detalheCapturado('detalhe_sem_fotos.json'),
      ).paraEntidade();

      expect(detalhe.fotos, isEmpty);
    });
  });

  group('tolerância do endereco (D-15)', () {
    test('logradouro, numero e cep nulos ainda parseiam', () {
      final mapa = mapaCompleto()
        ..['endereco'] = (enderecoCapturado()
          ..['logradouro'] = null
          ..['numero'] = null
          ..['cep'] = null);

      final modelo = DetalheImovelModel.fromJson(mapa);
      final detalhe = modelo.paraEntidade();

      expect(modelo.endereco?.logradouro, isNull);
      expect(modelo.endereco?.numero, isNull);
      expect(modelo.endereco?.cep, isNull);
      expect(detalhe.cidade?.nome, 'Campinas');
    });

    test('endereco nulo vira bairro vazio e cidade nula', () {
      final mapa = mapaCompleto()..['endereco'] = null;

      final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

      expect(detalhe.bairro, '');
      expect(detalhe.cidade, isNull);
      expect(detalhe.latitude, isNull);
      expect(detalhe.longitude, isNull);
    });

    test('endereco.cidade nula vira cidade nula na entidade', () {
      final mapa = mapaCompleto()
        ..['endereco'] = (enderecoCapturado()..['cidade'] = null);

      final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

      expect(detalhe.cidade, isNull);
      expect(detalhe.bairro, isNotEmpty);
    });
  });

  group('erros de parse (DET-06)', () {
    test('mapa sem titulo lança TypeError em fromJson', () {
      final mapa = mapaCompleto()..remove('titulo');

      expect(
        () => DetalheImovelModel.fromJson(mapa),
        throwsA(isA<TypeError>()),
      );
    });

    test('foto sem ordem lança TypeError em fromJson', () {
      final fotos = (mapaCompleto()['fotos']! as List<Object?>)
          .cast<Map<String, Object?>>();
      final mapa = mapaCompleto()
        ..['fotos'] = [
          Map<String, Object?>.of(fotos.first)..remove('ordem'),
          ...fotos.skip(1),
        ];

      expect(
        () => DetalheImovelModel.fromJson(mapa),
        throwsA(isA<TypeError>()),
      );
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
            {'imagem': 'https://a.b/A.jpg', 'ordem': 0, 'capa': true},
            {'imagem': 'javascript:alert(1)', 'ordem': 1, 'capa': false},
            {'imagem': 'https://a.b/C.jpg', 'ordem': 2, 'capa': false},
          ];

        final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

        expect(detalhe.fotos.map((f) => f.url), [
          'https://a.b/A.jpg',
          'https://a.b/C.jpg',
        ]);
      },
    );

    test('DetalheImovelModel zera a foto do corretor fora de http(s)', () {
      final corretor = Map<String, Object?>.of(
        mapaCompleto()['corretor_responsavel']! as Map<String, Object?>,
      )..['foto'] = 'file:///x';
      final mapa = mapaCompleto()..['corretor_responsavel'] = corretor;

      final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

      expect(detalhe.corretor?.foto, isNull);
      expect(detalhe.corretor?.nome, corretor['nome']);
    });

    test('DetalheImovelModel mantém a foto http do corretor', () {
      final detalhe = DetalheImovelModel.fromJson(mapaCompleto())
          .paraEntidade();

      expect(detalhe.corretor?.foto, startsWith('http'));
    });

    Map<String, Object?> primeiraLinhaDaLista() =>
        Map<String, Object?>.of(
          ((lerFixtureApi('lista_campinas_p1.json')!
                      as Map<String, Object?>)['results']!
                  as List<Object?>)
              .first!
              as Map<String, Object?>,
        );

    test('ImovelModel descarta a capa da lista com esquema inseguro', () {
      final linha = primeiraLinhaDaLista()..['foto_capa'] = 'javascript:x';

      final imovel = ImovelModel.fromJson(linha).paraEntidade();

      expect(imovel.fotoCapa, isNull);
    });

    test('ImovelModel mantém a capa https', () {
      final linha = primeiraLinhaDaLista()
        ..['foto_capa'] = 'https://a.b/capa.jpg';

      final imovel = ImovelModel.fromJson(linha).paraEntidade();

      expect(imovel.fotoCapa, 'https://a.b/capa.jpg');
    });
  });

  group('dados da natureza nos blocos capturados (DET-04, D-14)', () {
    DadosNatureza? dadosDe(Map<String, Object?> mapa) =>
        DetalheImovelModel.fromJson(mapa).paraEntidade().dados;

    test('CASA capturada vira DadosCasa com todos os campos', () {
      final dados = dadosDe(mapaCompleto());

      expect(
        dados,
        const DadosNatureza.casa(
          areaTerreno: '325.00',
          areaConstruida: '150.00',
          areaLivre: '175.00',
          quartos: 4,
          suites: 2,
          banheiros: 3,
          salas: 2,
          vagas: 3,
          pavimentos: 2,
          anoConstrucao: 2010,
          piscina: true,
          quintal: true,
          churrasqueira: false,
          mobiliada: true,
        ),
      );
    });

    test('area_livre chega exatamente como o servidor mandou, sem cálculo', () {
      final casa = dadosDe(mapaCompleto())! as DadosCasa;

      // 325,00 - 150,00 também dá 175,00, mas o app nunca recalcula (D-04):
      // o valor é o da captura, tal e qual.
      expect(casa.areaLivre, '175.00');
      expect(casa.areaTerreno, '325.00');
      expect(casa.areaConstruida, '150.00');
    });

    test('TERRENO capturado vira DadosTerreno com topografia aclive', () {
      final dados = dadosDe(detalheCapturado('detalhe_terreno.json'));

      expect(dados, isA<DadosTerreno>());
      final terreno = dados! as DadosTerreno;
      expect(terreno.areaTotal, '375.00');
      expect(terreno.frente, '15.00');
      expect(terreno.fundo, '25.00');
      expect(terreno.lateralEsquerda, '25.00');
      expect(terreno.lateralDireita, '25.00');
      expect(terreno.topografia, Topografia.aclive);
      expect(terreno.murado, isTrue);
      expect(terreno.esquina, isFalse);
      // O código chega como a API mandou; o rótulo é da apresentação (A-04).
      expect(terreno.usoPermitido, 'COMERCIAL');
    });

    test('lateral_esquerda e lateral_direita são lidas separadas, sem soma', () {
      final mapa = detalheCapturado('detalhe_terreno.json');
      mapa['terreno'] = {
        ...(mapa['terreno']! as Map<String, Object?>),
        'lateral_esquerda': '20.00',
        'lateral_direita': null,
      };

      final terreno = dadosDe(mapa)! as DadosTerreno;
      expect(terreno.lateralEsquerda, '20.00');
      expect(terreno.lateralDireita, isNull);
    });

    test(
      'topografia PLANO, ACLIVE e DECLIVE são mapeadas; outra vira null',
      () {
        Topografia? topografiaCom(String? valor) {
          final mapa = detalheCapturado('detalhe_terreno.json');
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

    test('APARTAMENTO capturado mapeia os campos próprios', () {
      final dados = dadosDe(detalheCapturado('detalhe_apartamento.json'));

      expect(dados, isA<DadosApartamento>());
      final apto = dados! as DadosApartamento;
      expect(apto.andar, 11);
      expect(apto.areaPrivativa, '85.00');
      expect(apto.areaTotal, '100.00');
      expect(apto.quartos, 1);
      expect(apto.suites, 1);
      expect(apto.banheiros, 2);
      expect(apto.vagas, 2);
      expect(apto.varanda, isFalse);
    });

    test('posicao_solar chega como o código da API, sem enum (A-04)', () {
      expect(
        (dadosDe(detalheCapturado('detalhe_apartamento.json'))!
                as DadosApartamento)
            .posicaoSolar,
        'POENTE',
      );
    });

    test('apartamento.predio capturado vira DadosPredio', () {
      final apto =
          dadosDe(detalheCapturado('detalhe_apartamento.json'))!
              as DadosApartamento;

      expect(apto.predio?.nome, 'Edifício Girassol Campinas');
      expect(apto.predio?.andares, 12);
      expect(apto.predio?.anoConstrucao, 2013);
      expect(apto.predio?.elevadores, 2);
      expect(apto.predio?.portaria24h, isTrue);
      expect(apto.predio?.piscina, isTrue);
      expect(apto.predio?.academia, isTrue);
      expect(apto.predio?.salaoDeFestas, isTrue);
      expect(apto.predio?.playground, isFalse);
    });

    test('predio nulo ou ausente vira null', () {
      Map<String, Object?> comPredio(Object? valor) {
        final mapa = detalheCapturado('detalhe_apartamento.json');
        mapa['apartamento'] = {
          ...(mapa['apartamento']! as Map<String, Object?>),
          'predio': valor,
        };
        return mapa;
      }

      expect((dadosDe(comPredio(null))! as DadosApartamento).predio, isNull);

      final ausente = detalheCapturado('detalhe_apartamento.json');
      ausente['apartamento'] = Map<String, Object?>.of(
        ausente['apartamento']! as Map<String, Object?>,
      )..remove('predio');
      expect((dadosDe(ausente)! as DadosApartamento).predio, isNull);
    });

    test('LOTE capturado mapeia número, medidas e a quadra com o loteamento', () {
      final lote =
          dadosDe(detalheCapturado('detalhe_lote.json'))! as DadosLote;

      expect(lote.numero, '24');
      expect(lote.area, '275.00');
      expect(lote.frente, '11.00');
      expect(lote.fundo, '25.00');
      expect(lote.entradaMinima, '23500.00');
      expect(lote.parcelasMaximas, 120);
      expect(lote.condicoesParcelamento, 'Correção anual pelo IPCA.');
      expect(lote.quadra?.identificacao, 'B');
      expect(
        lote.quadra?.loteamento?.nome,
        'Loteamento Jardim dos Ipês Campinas',
      );
      expect(
        lote.quadra?.loteamento?.incorporadora,
        'Incorporadora Verde Vale',
      );
    });

    group('loteamento do lote capturado (A-03)', () {
      Map<String, Object?> comLoteamento(Map<String, Object?> alteracoes) {
        final mapa = detalheCapturado('detalhe_lote.json');
        final lote = Map<String, Object?>.of(
          mapa['lote']! as Map<String, Object?>,
        );
        final quadra = Map<String, Object?>.of(
          lote['quadra']! as Map<String, Object?>,
        );
        quadra['loteamento'] = {
          ...(quadra['loteamento']! as Map<String, Object?>),
          ...alteracoes,
        };
        lote['quadra'] = quadra;
        mapa['lote'] = lote;
        return mapa;
      }

      DadosLoteamento? loteamentoDe(Map<String, Object?> mapa) =>
          (dadosDe(mapa)! as DadosLote).quadra?.loteamento;

      test('os cinco booleanos verdadeiros viram rótulos na ordem fixa e '
          'areas_de_lazer chega como a frase do servidor', () {
        final loteamento = loteamentoDe(detalheCapturado('detalhe_lote.json'));

        expect(loteamento?.infraestrutura, [
          'Asfalto',
          'Água',
          'Energia',
          'Esgoto',
          'Iluminação pública',
        ]);
        expect(
          loteamento?.areasDeLazer,
          'Praça central, quadra poliesportiva e pista de caminhada.',
        );
      });

      test('só os booleanos verdadeiros entram; falso e nulo são omitidos', () {
        final loteamento = loteamentoDe(
          comLoteamento({
            'asfalto': false,
            'agua': true,
            'energia': null,
            'esgoto': false,
            'iluminacao': true,
          }),
        );

        expect(loteamento?.infraestrutura, ['Água', 'Iluminação pública']);
      });

      test('nenhum booleano verdadeiro resulta em infraestrutura vazia', () {
        final loteamento = loteamentoDe(
          comLoteamento({
            'asfalto': false,
            'agua': false,
            'energia': false,
            'esgoto': false,
            'iluminacao': false,
          }),
        );

        expect(loteamento?.infraestrutura, isEmpty);
      });

      test('areas_de_lazer em branco ou nula vira null, sem dividir o texto', () {
        expect(
          loteamentoDe(comLoteamento({'areas_de_lazer': '   '}))?.areasDeLazer,
          isNull,
        );
        expect(
          loteamentoDe(comLoteamento({'areas_de_lazer': ''}))?.areasDeLazer,
          isNull,
        );
        expect(
          loteamentoDe(comLoteamento({'areas_de_lazer': null}))?.areasDeLazer,
          isNull,
        );
        expect(
          loteamentoDe(
            comLoteamento({'areas_de_lazer': 'Praça, quadra'}),
          )?.areasDeLazer,
          'Praça, quadra',
        );
      });
    });

    test('entrada_minima e parcelas_maximas nulas viram null', () {
      final mapa = detalheCapturado('detalhe_lote.json');
      mapa['lote'] = {
        ...(mapa['lote']! as Map<String, Object?>),
        'entrada_minima': null,
        'parcelas_maximas': null,
      };

      final lote = dadosDe(mapa)! as DadosLote;
      expect(lote.entradaMinima, isNull);
      expect(lote.parcelasMaximas, isNull);
    });

    test('quadra nula e loteamento nulo viram null', () {
      Map<String, Object?> comLote(Map<String, Object?> alteracoes) {
        final mapa = detalheCapturado('detalhe_lote.json');
        mapa['lote'] = {
          ...(mapa['lote']! as Map<String, Object?>),
          ...alteracoes,
        };
        return mapa;
      }

      expect((dadosDe(comLote({'quadra': null}))! as DadosLote).quadra, isNull);

      final quadra =
          (dadosDe(
                    comLote({
                      'quadra': {'identificacao': 'B', 'loteamento': null},
                    }),
                  )!
                  as DadosLote)
              .quadra;
      expect(quadra?.identificacao, 'B');
      expect(quadra?.loteamento, isNull);
    });

    test('todos os campos do bloco são opcionais (bloco vazio não derruba)', () {
      final mapa = mapaCompleto()..['casa'] = <String, Object?>{};

      expect(dadosDe(mapa), const DadosNatureza.casa());
    });

    test('natureza desconhecida resulta em dados == null', () {
      final mapa = mapaCompleto()..['natureza'] = 'CHALE';

      expect(() => dadosDe(mapa), returnsNormally);
      expect(dadosDe(mapa), isNull);
    });

    test('bloco nulo ou ausente resulta em dados == null', () {
      final nulo = mapaCompleto()..['casa'] = null;
      final ausente = mapaCompleto()..remove('casa');

      expect(dadosDe(nulo), isNull);
      expect(dadosDe(ausente), isNull);
    });

    test('natureza sem bloco próprio (só outro bloco preenchido) -> null', () {
      final mapa = mapaCompleto()
        ..['casa'] = null
        ..['apartamento'] =
            detalheCapturado('detalhe_apartamento.json')['apartamento'];

      expect(() => dadosDe(mapa), returnsNormally);
      expect(dadosDe(mapa), isNull);
    });

    test('natureza ausente resulta em dados == null mesmo com bloco', () {
      final mapa = mapaCompleto()..remove('natureza');

      expect(dadosDe(mapa), isNull);
    });
  });
}
