import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/api_falsa.dart';

/// Teste de contrato do login, do `eu`, do Sair e da lista do acervo do
/// corretor (API-09, §14 de `01-CONTRATO-API.md`): os exemplos do contrato
/// (`contrato/*.example.json`) são cópias EXATAS das respostas capturadas do
/// Django da `feat/APP08` da web (`test/fixtures/api/`, nenhum wire escrito à
/// mão), e o conjunto de chaves de cada objeto é o travado pelos serializers
/// do servidor. Chave nova ou perdida no Django quebra este teste: sem drift
/// silencioso entre os dois repositórios. Ainda não há Models aqui; o parse
/// das fixtures pelos Models vem num plano seguinte.
///
/// Os exemplos vivem no diretório da Fase 1. Se esse diretório for um dia
/// arquivado, mova os três `*.example.json` e corrija [_pastaContrato].
const _pastaContrato =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato';

const _chavesEnvelope = {'count', 'next', 'previous', 'results'};

/// As 10 chaves do item do acervo: as 9 do D-13 mais `finalidade` (emenda ao
/// D-13, §14.5).
const _chavesItemAcervo = {
  'id',
  'codigo',
  'titulo',
  'finalidade',
  'preco_venda',
  'preco_aluguel',
  'foto_capa',
  'situacao',
  'meu_imovel',
  'na_vitrine',
};

/// Chaves que o acervo do corretor nunca expõe no item (deny-list do §14.5).
const _chavesProibidasNoItem = {
  'proprietario',
  'corretor_responsavel',
  'empresa',
  'descricao',
  'fotos',
  'endereco',
  'publicado',
  'pode_publicar',
  'pendencias_para_publicar',
  'criado_em',
};

const _situacoes = {'DISPONIVEL', 'RESERVADO', 'VENDIDO', 'ALUGADO'};

const _fixturesDoAcervo = [
  'acervo_p1.json',
  'acervo_p2.json',
  'acervo_busca.json',
  'acervo_situacao_vazia.json',
  'acervo_outra_empresa.json',
];

/// Conteúdo textual de um exemplo do contrato.
String _textoDoExemplo(String nome) =>
    File('$_pastaContrato/$nome').readAsStringSync();

/// Conteúdo textual de uma fixture capturada.
String _textoDaFixture(String nome) =>
    File('test/fixtures/api/$nome').readAsStringSync();

Map<String, Object?> _fixture(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

List<Map<String, Object?>> _itens(String nome) => [
  for (final item in _fixture(nome)['results']! as List<Object?>)
    item! as Map<String, Object?>,
];

/// Códigos dos imóveis de uma fixture do acervo.
Set<String> _codigos(String nome) => {
  for (final item in _itens(nome)) item['codigo']! as String,
};

/// Confere que as chaves de [objeto] são EXATAMENTE as de [esperadas]; falha
/// tanto por chave extra (vazamento) quanto por chave faltando.
void _exigirChavesExatas(Object? objeto, Set<String> esperadas, String rotulo) {
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
      'acervo.example.json': 'acervo_p1.json',
      'eu.example.json': 'eu_corretor.json',
      'login.example.json': 'login_200.json',
    };

    for (final par in pares.entries) {
      test('${par.key} é cópia exata de ${par.value}', () {
        // Byte a byte (o exemplo nunca é editado à mão) e, por garantia,
        // igualdade profunda do JSON decodificado.
        expect(_textoDoExemplo(par.key), _textoDaFixture(par.value));
        expect(
          jsonDecode(_textoDoExemplo(par.key)),
          equals(lerFixtureApi(par.value)),
        );
      });
    }
  });

  group('login e eu', () {
    test('o 200 do login tem exatamente a chave token', () {
      _exigirChavesExatas(_fixture('login_200.json'), {'token'}, 'login 200');
    });

    test('a fixture do login não guarda chave viva: só os 40 zeros', () {
      expect(_fixture('login_200.json')['token'], '0' * 40);
    });

    test('o eu do corretor tem exatamente perfil CORRETOR', () {
      final eu = _fixture('eu_corretor.json');

      _exigirChavesExatas(eu, {'perfil'}, 'eu do corretor');
      expect(eu['perfil'], 'CORRETOR');
    });

    test('o eu do gestor tem exatamente perfil GESTOR', () {
      final eu = _fixture('eu_gestor.json');

      _exigirChavesExatas(eu, {'perfil'}, 'eu do gestor');
      expect(eu['perfil'], 'GESTOR');
    });
  });

  group('erros capturados', () {
    test('o 401 e o 403 do acervo trazem a chave detail', () {
      expect(_fixture('erro_401.json'), contains('detail'));
      expect(_fixture('erro_403_acervo.json'), contains('detail'));
    });

    test('o 400 do login é um objeto de erros não vazio', () {
      expect(_fixture('erro_400_login.json'), isNotEmpty);
    });
  });

  group('acervo do corretor (PageNumberPagination)', () {
    for (final nome in _fixturesDoAcervo) {
      test('$nome tem o envelope e os itens com as 10 chaves exatas', () {
        _exigirChavesExatas(_fixture(nome), _chavesEnvelope, nome);

        for (final item in _itens(nome)) {
          _exigirChavesExatas(item, _chavesItemAcervo, '$nome results[]');
          expect(
            item.keys.toSet().intersection(_chavesProibidasNoItem),
            isEmpty,
            reason: '$nome results[] expõe chave da deny-list',
          );
        }
      });

      test('$nome tem situacao válida e meu_imovel/na_vitrine booleanos', () {
        for (final item in _itens(nome)) {
          expect(_situacoes, contains(item['situacao']));
          expect(item['meu_imovel'], isA<bool>());
          expect(item['na_vitrine'], isA<bool>());
        }
      });
    }

    test('a primeira página tem 20 itens, o total e o next absoluto', () {
      final p1 = _fixture('acervo_p1.json');

      expect(_itens('acervo_p1.json'), hasLength(20));
      expect(p1['count'], 36);
      expect(p1['previous'], isNull);
      expect(p1['next'], isA<String>());
      expect(Uri.parse(p1['next']! as String).hasAuthority, isTrue);
    });

    test('a segunda página tem os 16 restantes e aponta previous', () {
      final p2 = _fixture('acervo_p2.json');

      expect(_itens('acervo_p2.json'), hasLength(16));
      expect(p2['next'], isNull);
      expect(p2['previous'], isA<String>());
    });

    test('as duas páginas não repetem imóvel', () {
      final p1 = _codigos('acervo_p1.json');
      final p2 = _codigos('acervo_p2.json');

      expect(p1.intersection(p2), isEmpty);
      expect(p1.union(p2), hasLength(36));
    });

    test('a busca por código devolve exatamente um imóvel', () {
      expect(_fixture('acervo_busca.json')['count'], 1);
      expect(_codigos('acervo_busca.json'), {'DEV-CAMPINAS-14'});
    });

    test('a situação sem resultado é uma lista vazia, não um erro', () {
      final vazia = _fixture('acervo_situacao_vazia.json');

      expect(vazia['count'], 0);
      expect(vazia['results'], isEmpty);
    });

    test('o acervo de uma empresa nunca traz imóvel da outra (AC-5)', () {
      final demo = _codigos('acervo_p1.json').union(_codigos('acervo_p2.json'));
      final outra = _codigos('acervo_outra_empresa.json');

      expect(outra, isNotEmpty);
      expect(demo.intersection(outra), isEmpty);
      expect(demo.every((codigo) => codigo.startsWith('DEV-')), isTrue);
      expect(outra.any((codigo) => codigo.startsWith('DEV-')), isFalse);
    });
  });
}
