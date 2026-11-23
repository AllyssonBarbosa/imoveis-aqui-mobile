import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/api_falsa.dart';

/// Teste de contrato da caixa de contatos do corretor (API-11, §16 de
/// `01-CONTRATO-API.md`): os exemplos do contrato (`contrato/*.example.json`)
/// são cópias EXATAS das respostas capturadas do Django da `feat/APP10` da web
/// (`test/fixtures/api/`, nenhum wire escrito à mão), e o conjunto de chaves de
/// cada objeto é o travado pelos serializers do servidor. Chave nova ou perdida
/// no Django quebra este teste: sem drift silencioso entre os dois
/// repositórios. Também prova, no wire, o isolamento entre empresas (CXA-04):
/// a caixa da empresa B tem contato de verdade e nenhum dele aparece na da A.
///
/// Os Models do app ainda não existem aqui; o plano 10-05 acrescenta o grupo
/// "Models leem toda fixture".
///
/// Os exemplos vivem no diretório da Fase 1. Se esse diretório for um dia
/// arquivado, mova os quatro `*.example.json` e corrija [_pastaContrato].
const _pastaContrato =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato';

const _chavesEnvelope = {'count', 'next', 'previous', 'results'};

/// As 12 chaves do item da caixa (`ContatoSerializer`, §16.2).
const _chavesItemContato = {
  'id',
  'imovel',
  'imovel_codigo',
  'imovel_titulo',
  'corretor',
  'corretor_nome',
  'canal',
  'canal_exibicao',
  'criado_em',
  'retorno',
  'retorno_exibicao',
  'retorno_em',
};

const _chavesResumo = {'sem_retorno'};

const _chavesOpcaoImovel = {'id', 'codigo', 'titulo'};

const _canais = {'WHATSAPP', 'TELEFONE', 'EMAIL'};

const _retornos = {
  'PENDENTE',
  'FALEI',
  'VISITA_AGENDADA',
  'SEM_RESPOSTA',
  'DESCARTADO',
};

/// As cinco fixtures de lista da caixa (envelope do §4).
const _fixturesDeLista = [
  'contatos_p1.json',
  'contatos_p2.json',
  'contatos_imovel.json',
  'contatos_periodo_vazio.json',
  'contatos_outra_empresa.json',
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

/// Ids dos contatos de uma fixture de lista.
Set<int> _idsDosContatos(String nome) => {
  for (final item in _itens(nome)) item['id']! as int,
};

/// Ids dos imóveis (`imovel`) dos contatos de uma fixture de lista.
Set<int> _idsDosImoveis(String nome) => {
  for (final item in _itens(nome)) item['imovel']! as int,
};

/// Opções do filtro de imóvel (`contatos_imoveis.json`: lista sem envelope).
List<Map<String, Object?>> _opcoesDeImovel() => [
  for (final opcao in lerFixtureApi('contatos_imoveis.json')! as List<Object?>)
    opcao! as Map<String, Object?>,
];

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

/// Confere canal, retorno e datas de um item (item da lista ou do PATCH 200).
void _exigirValoresDoItem(Map<String, Object?> item, String rotulo) {
  expect(_canais, contains(item['canal']), reason: '$rotulo: canal');
  expect(_retornos, contains(item['retorno']), reason: '$rotulo: retorno');

  final criadoEm = item['criado_em'];
  expect(criadoEm, isA<String>(), reason: '$rotulo: criado_em');
  expect(
    DateTime.tryParse(criadoEm! as String),
    isNotNull,
    reason: '$rotulo: criado_em não é ISO-8601',
  );
  // O wire de São Paulo vem sempre com offset explícito (§16.7).
  expect(criadoEm, matches(RegExp(r'(Z|[+-]\d{2}:\d{2})$')));

  final retornoEm = item['retorno_em'];
  if (retornoEm != null) {
    expect(retornoEm, isA<String>(), reason: '$rotulo: retorno_em');
    expect(
      DateTime.tryParse(retornoEm as String),
      isNotNull,
      reason: '$rotulo: retorno_em não é ISO-8601',
    );
  }
}

void main() {
  group('exemplo do contrato == resposta capturada', () {
    const pares = {
      'contatos.example.json': 'contatos_p1.json',
      'contatos_resumo.example.json': 'contatos_resumo.json',
      'contatos_imoveis.example.json': 'contatos_imoveis.json',
      'contato_patch.example.json': 'contato_patch_200.json',
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

  group('lista da caixa (PageNumberPagination)', () {
    for (final nome in _fixturesDeLista) {
      test('$nome tem o envelope e os itens com as 12 chaves exatas', () {
        _exigirChavesExatas(_fixture(nome), _chavesEnvelope, nome);

        for (final item in _itens(nome)) {
          _exigirChavesExatas(item, _chavesItemContato, '$nome results[]');
        }
      });

      test('$nome tem canal e retorno válidos e datas ISO-8601', () {
        for (final item in _itens(nome)) {
          _exigirValoresDoItem(item, '$nome results[]');
        }
      });
    }

    test('a primeira página tem 20 itens, o total e o next absoluto', () {
      final p1 = _fixture('contatos_p1.json');

      expect(_itens('contatos_p1.json'), hasLength(20));
      expect(p1['count'], 25);
      expect(p1['previous'], isNull);
      expect(p1['next'], isA<String>());
      expect(Uri.parse(p1['next']! as String).hasAuthority, isTrue);
    });

    test('o next tem a mesma origem da base URL do app (§16.8)', () {
      final proximo = Uri.parse(_fixture('contatos_p1.json')['next']! as String);
      final base = Uri.parse(urlBaseApiFalsa);

      expect(proximo.scheme, base.scheme);
      expect(proximo.host, base.host);
      expect(proximo.port, base.port);
    });

    test('a segunda página tem os 5 restantes e aponta previous', () {
      final p2 = _fixture('contatos_p2.json');

      expect(_itens('contatos_p2.json'), hasLength(5));
      expect(p2['next'], isNull);
      expect(p2['previous'], isA<String>());
    });

    test('as duas páginas não repetem contato e somam o count', () {
      final p1 = _idsDosContatos('contatos_p1.json');
      final p2 = _idsDosContatos('contatos_p2.json');

      expect(p1.intersection(p2), isEmpty);
      expect(p1.union(p2), hasLength(25));
    });

    test('a ordem é a fixa do servidor: mais recente primeiro', () {
      final datas = [
        for (final item in _itens('contatos_p1.json'))
          DateTime.parse(item['criado_em']! as String),
      ];

      for (var i = 1; i < datas.length; i++) {
        expect(
          datas[i].isAfter(datas[i - 1]),
          isFalse,
          reason: 'criado_em deve ser decrescente (-criado_em, -id)',
        );
      }
    });

    test('o filtro por imóvel devolve só contatos desse imóvel', () {
      final imovel = _fixture('contatos_imovel.json');

      expect(imovel['count'], 9);
      expect(_idsDosImoveis('contatos_imovel.json'), hasLength(1));
    });

    test('o período sem resultado é uma lista vazia, não um erro', () {
      final vazia = _fixture('contatos_periodo_vazio.json');

      expect(vazia['count'], 0);
      expect(vazia['results'], isEmpty);
      expect(vazia['next'], isNull);
      expect(vazia['previous'], isNull);
    });
  });

  group('anotar o retorno (PATCH)', () {
    test('o 200 traz o item completo, com as 12 chaves exatas', () {
      final item = _fixture('contato_patch_200.json');

      _exigirChavesExatas(item, _chavesItemContato, 'PATCH 200');
      _exigirValoresDoItem(item, 'PATCH 200');
    });

    test('o 200 grava retorno anotável e o instante da anotação', () {
      final item = _fixture('contato_patch_200.json');

      expect(item['retorno'], isNot('PENDENTE'));
      expect(item['retorno_em'], isNotNull);
    });

    test('o 200 é o mesmo contato da primeira página, agora anotado', () {
      final anotado = _fixture('contato_patch_200.json');
      final original = _itens('contatos_p1.json').firstWhere(
        (item) => item['id'] == anotado['id'],
      );

      expect(original['retorno'], 'PENDENTE');
      expect(original['retorno_em'], isNull);
      expect(original['imovel'], anotado['imovel']);
      expect(original['canal'], anotado['canal']);
      expect(original['criado_em'], anotado['criado_em']);
    });

    test('o 400 do retorno inválido traz a chave retorno', () {
      expect(_fixture('erro_400_retorno.json'), contains('retorno'));
    });

    test('o 404 do contato alheio traz a chave detail', () {
      expect(_fixture('erro_404_contato.json'), contains('detail'));
    });
  });

  group('contagem dos sem retorno', () {
    test('o resumo tem exatamente sem_retorno, com inteiro', () {
      for (final nome in ['contatos_resumo.json', 'contatos_resumo_apos.json']) {
        final resumo = _fixture(nome);

        _exigirChavesExatas(resumo, _chavesResumo, nome);
        expect(resumo['sem_retorno'], isA<int>());
        expect(resumo['sem_retorno']! as int, greaterThanOrEqualTo(0));
      }
    });

    test('a contagem cai exatamente 1 depois de anotar um retorno', () {
      final antes = _fixture('contatos_resumo.json')['sem_retorno']! as int;
      final depois =
          _fixture('contatos_resumo_apos.json')['sem_retorno']! as int;

      expect(depois, antes - 1);
    });

    test('a contagem é o total da caixa, sem filtros (D-05)', () {
      expect(
        _fixture('contatos_resumo.json')['sem_retorno'],
        _fixture('contatos_p1.json')['count'],
      );
    });
  });

  group('opções do filtro de imóvel', () {
    test('cada opção tem exatamente id, codigo e titulo', () {
      final opcoes = _opcoesDeImovel();

      expect(opcoes, isNotEmpty);
      for (final opcao in opcoes) {
        _exigirChavesExatas(opcao, _chavesOpcaoImovel, 'opção de imóvel');
      }
    });

    test('as opções vêm em ordem crescente de código', () {
      final codigos = [
        for (final opcao in _opcoesDeImovel()) opcao['codigo']! as String,
      ];

      expect(codigos, [...codigos]..sort());
    });

    test('as opções são exatamente os imóveis dos contatos da caixa', () {
      final dosContatos = _idsDosImoveis(
        'contatos_p1.json',
      ).union(_idsDosImoveis('contatos_p2.json'));
      final dasOpcoes = {
        for (final opcao in _opcoesDeImovel()) opcao['id']! as int,
      };

      expect(dasOpcoes, dosContatos);
    });
  });

  group('isolamento entre empresas no wire (CXA-04)', () {
    test('a caixa da outra empresa não é vazia (senão a prova não vale)', () {
      final outra = _fixture('contatos_outra_empresa.json');

      expect(outra['count'], greaterThanOrEqualTo(1));
      expect(_itens('contatos_outra_empresa.json'), isNotEmpty);
    });

    test('nenhum contato da empresa B aparece na caixa da empresa A', () {
      final empresaA = _idsDosContatos(
        'contatos_p1.json',
      ).union(_idsDosContatos('contatos_p2.json'));
      final empresaB = _idsDosContatos('contatos_outra_empresa.json');

      expect(empresaB, isNotEmpty);
      expect(empresaA.intersection(empresaB), isEmpty);
    });

    test('nenhum imóvel da empresa B aparece nas opções da empresa A', () {
      final imoveisDaB = _idsDosImoveis('contatos_outra_empresa.json');
      final opcoesDaA = {
        for (final opcao in _opcoesDeImovel()) opcao['id']! as int,
      };

      expect(imoveisDaB, isNotEmpty);
      expect(opcoesDaA.intersection(imoveisDaB), isEmpty);
    });

    test('a contagem da empresa A não soma o contato da empresa B', () {
      final totalA = _fixture('contatos_p1.json')['count']! as int;
      final totalB = _fixture('contatos_outra_empresa.json')['count']! as int;

      expect(_fixture('contatos_resumo.json')['sem_retorno'], totalA);
      expect(totalB, isNot(totalA));
    });
  });
}
