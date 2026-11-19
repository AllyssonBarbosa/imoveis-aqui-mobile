import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/caracteristica_model.dart';
import 'package:imoveis_aqui/data/models/cidade_model.dart';
import 'package:imoveis_aqui/data/models/imoveis_envelope_model.dart';

import '../support/api_falsa.dart';

/// Teste de contrato da lista e das opções: os exemplos de
/// `01-CONTRATO-API.md` (`contrato/*.example.json`) são cópias EXATAS das
/// respostas capturadas da API semeada (`test/fixtures/api/`, D-02), e o
/// conjunto de chaves de cidade, envelope, item e característica é o travado
/// pelos testes Django do 05-02 (`VitrineAllowlistExataTests`). Se um dos
/// repositórios mudar o formato, a captura muda e este teste quebra: sem
/// drift silencioso entre os dois (ROADMAP Fase 5, critério 3).

const _pastaContrato =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato';

const _chavesCidade = {'id', 'nome', 'uf'};
const _chavesEnvelope = {'count', 'next', 'previous', 'results'};
const _chavesItem = {
  'id',
  'titulo',
  'natureza',
  'finalidade',
  'preco_venda',
  'preco_aluguel',
  'preco_condominio',
  'bairro',
  'area',
  'quartos',
  'suites',
  'vagas',
  'foto_capa',
};
const _chavesCaracteristica = {'id', 'nome'};

/// Conteúdo textual de um exemplo do contrato.
String _textoDoExemplo(String nome) =>
    File('$_pastaContrato/$nome').readAsStringSync();

/// JSON decodificado de um exemplo do contrato.
Object? _exemplo(String nome) => jsonDecode(_textoDoExemplo(nome));

/// Conteúdo textual de uma fixture capturada.
String _textoDaFixture(String nome) =>
    File('test/fixtures/api/$nome').readAsStringSync();

/// Confere que as chaves de [objeto] são EXATAMENTE as de [esperadas].
void _exigirChavesExatas(
  Object? objeto,
  Set<String> esperadas,
  String rotulo,
) {
  final mapa = objeto! as Map<String, Object?>;
  final chaves = mapa.keys.toSet();
  expect(
    chaves.difference(esperadas),
    isEmpty,
    reason: '$rotulo tem chave fora da allowlist do servidor',
  );
  expect(
    esperadas.difference(chaves),
    isEmpty,
    reason: '$rotulo perdeu chave da allowlist do servidor',
  );
}

void main() {
  group('exemplo do contrato == resposta capturada', () {
    const pares = {
      'cidades.example.json': 'cidades.json',
      'imoveis.example.json': 'lista_campinas_p1.json',
      'bairros.example.json': 'bairros_campinas.json',
      'caracteristicas.example.json': 'caracteristicas.json',
    };

    for (final par in pares.entries) {
      test('${par.key} é cópia exata de ${par.value}', () {
        // Byte a byte (D-02: o exemplo nunca é editado à mão) e, por
        // garantia, igualdade profunda do JSON decodificado.
        expect(_textoDoExemplo(par.key), _textoDaFixture(par.value));
        expect(_exemplo(par.key), equals(lerFixtureApi(par.value)));
      });
    }
  });

  group('cidades', () {
    final cidades = lerFixtureApi('cidades.json')! as List<Object?>;

    test('é um array simples, sem envelope, com as quatro cidades', () {
      expect(cidades, hasLength(4));
      expect(
        [for (final c in cidades) (c! as Map<String, Object?>)['nome']],
        containsAll(['Campinas', 'Valinhos', 'Vinhedo', 'Indaiatuba']),
      );
    });

    test('cada cidade tem exatamente id, nome e uf', () {
      for (final cidade in cidades) {
        _exigirChavesExatas(cidade, _chavesCidade, 'cidade');
      }
    });

    test('parseia pelo Model do app, com o id da API', () {
      for (final cidade in cidades) {
        final entidade = CidadeModel.fromJson(
          cidade! as Map<String, Object?>,
        ).paraEntidade();

        expect(entidade.id, (cidade as Map<String, Object?>)['id']);
        expect(entidade.nome, cidade['nome']);
      }
    });
  });

  group('lista de imóveis (PageNumberPagination)', () {
    final lista = lerFixtureApi('lista_campinas_p1.json')!
        as Map<String, Object?>;

    test('o envelope tem exatamente count, next, previous e results', () {
      _exigirChavesExatas(lista, _chavesEnvelope, 'envelope');
      expect(lista['count'], isA<int>());
      expect(lista['previous'], isNull);
      expect(lista['next'], startsWith('http://'));
      expect(lista['results'], hasLength(20));
    });

    test('cada item tem exatamente as chaves públicas da lista', () {
      for (final item in lista['results']! as List<Object?>) {
        _exigirChavesExatas(item, _chavesItem, 'item da lista');
      }
    });

    test('o item da lista não traz descricao, cidade nem caracteristicas', () {
      for (final item in lista['results']! as List<Object?>) {
        final chaves = (item! as Map<String, Object?>).keys;
        expect(chaves, isNot(contains('descricao')));
        expect(chaves, isNot(contains('cidade')));
        expect(chaves, isNot(contains('caracteristicas')));
        expect(chaves, isNot(contains('criado_em')));
      }
    });

    test('o exemplo parseia com ImoveisEnvelopeModel.fromJson', () {
      final envelope = ImoveisEnvelopeModel.fromJson(
        _exemplo('imoveis.example.json')! as Map<String, Object?>,
      );

      expect(envelope.results, hasLength(20));
      expect(envelope.next, lista['next']);
      final pagina = envelope.paraPagina();
      expect(pagina.itens, hasLength(20));
      expect(pagina.proximaPagina, lista['next']);
    });
  });

  group('opções de filtro', () {
    test('bairros é uma lista de strings', () {
      final bairros = _exemplo('bairros.example.json')! as List<Object?>;

      expect(bairros, isNotEmpty);
      expect(bairros, everyElement(isA<String>()));
    });

    test('cada característica tem exatamente id e nome', () {
      final catalogo = _exemplo('caracteristicas.example.json')!
          as List<Object?>;

      expect(catalogo, isNotEmpty);
      for (final item in catalogo) {
        _exigirChavesExatas(item, _chavesCaracteristica, 'característica');
        final modelo = CaracteristicaModel.fromJson(
          item! as Map<String, Object?>,
        );
        expect(modelo.id, (item as Map<String, Object?>)['id']);
      }
    });
  });

  group('guarda do contrato (prova de que o teste morde)', () {
    test('chave extra no item da lista é detectada', () {
      final item = Map<String, Object?>.of(
        ((lerFixtureApi('lista_campinas_p1.json')!
                    as Map<String, Object?>)['results']!
                as List<Object?>)
            .first! as Map<String, Object?>,
      )..['proprietario'] = 'Fulano';

      expect(
        () => _exigirChavesExatas(item, _chavesItem, 'sujo'),
        throwsA(anything),
      );
    });

    test('chave faltando no envelope é detectada', () {
      final envelope = Map<String, Object?>.of(
        lerFixtureApi('lista_campinas_p1.json')! as Map<String, Object?>,
      )..remove('count');

      expect(
        () => _exigirChavesExatas(envelope, _chavesEnvelope, 'incompleto'),
        throwsA(anything),
      );
    });

    test('exemplo adulterado deixaria de ser igual à fixture', () {
      final adulterado = _textoDoExemplo('cidades.example.json').replaceFirst(
        'Campinas',
        'Campinas2',
      );

      expect(adulterado, isNot(_textoDaFixture('cidades.json')));
    });
  });
}
