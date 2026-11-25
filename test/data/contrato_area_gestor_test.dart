import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/api_falsa.dart';

/// Teste de contrato da Área do gestor (API-16, §18 de `01-CONTRATO-API.md`):
/// os exemplos do contrato (`contrato/*.example.json`) são cópias EXATAS das
/// respostas capturadas do Django da `feat/APP12` da web (`test/fixtures/api/`,
/// nenhum wire escrito à mão), e o conjunto de chaves de cada objeto lido pelo
/// app é o travado pelos serializers do servidor. Chave nova ou perdida no
/// Django quebra este teste: sem drift silencioso entre os dois repositórios.
///
/// Também prova, no wire, o isolamento entre empresas (critério 6 do card): a
/// empresa B tem acervo e mudança de verdade, e nenhum corretor nem imóvel dela
/// aparece nos relatórios da empresa A; e que a soma do acervo por corretor
/// fecha com o total do acervo (D-12). Ainda sem Models: o plano 12-05 testa os
/// Models contra estas mesmas fixtures.
///
/// Os exemplos vivem no diretório da Fase 1. Se esse diretório for um dia
/// arquivado, mova os quatro `*.example.json` e corrija [_pastaContrato].
const _pastaContrato =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato';

/// As 4 situações do imóvel (§16); qualquer outra é falha de formato (D-24).
const _situacoes = {'DISPONIVEL', 'RESERVADO', 'VENDIDO', 'ALUGADO'};

/// Resposta de `GET /api/relatorios/acervo-por-corretor/` (§18.3).
const _chavesAcervoPorCorretor = {'linhas', 'total'};

/// Linha do acervo por corretor (§18.3).
const _chavesLinhaAcervoCorretor = {
  'corretor_id',
  'corretor',
  'ativo',
  'total',
};

/// Linha dos contatos por corretor (§18.4).
const _chavesLinhaContatosCorretor = {
  'corretor_id',
  'corretor',
  'ativo',
  'total',
  'pendentes',
};

/// Resposta de `GET /api/relatorios/mudancas-situacao/` (§18.5).
const _chavesMudancas = {'dias', 'desde', 'mudancas'};

/// As 9 chaves de cada mudança de situação recente (D-20, §18.5).
const _chavesMudancaRecente = {
  'id',
  'imovel_id',
  'imovel_codigo',
  'imovel_titulo',
  'situacao_anterior',
  'situacao_nova',
  'alterado_por',
  'alterado_em',
  'observacao',
};

/// Conteúdo textual de um exemplo do contrato.
String _textoDoExemplo(String nome) =>
    File('$_pastaContrato/$nome').readAsStringSync();

/// Conteúdo textual de uma fixture capturada.
String _textoDaFixture(String nome) =>
    File('test/fixtures/api/$nome').readAsStringSync();

Map<String, Object?> _fixture(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

/// Itens de uma lista de [campo] numa fixture (`linhas` ou `mudancas`).
List<Map<String, Object?>> _itens(String nome, String campo) => [
  for (final item in _fixture(nome)[campo]! as List<Object?>)
    item! as Map<String, Object?>,
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

/// Soma do campo `total` das linhas de uma fixture.
int _somaDasLinhas(String nome) => _itens(
  nome,
  'linhas',
).fold(0, (soma, linha) => soma + (linha['total']! as int));

/// Ids dos corretores (não nulos) das linhas de uma fixture.
Set<int> _idsDosCorretores(String nome) => {
  for (final linha in _itens(nome, 'linhas'))
    if (linha['corretor_id'] != null) linha['corretor_id']! as int,
};

/// Ids dos imóveis das mudanças de uma fixture.
Set<int> _idsDosImoveis(String nome) => {
  for (final mudanca in _itens(nome, 'mudancas')) mudanca['imovel_id']! as int,
};

void main() {
  group('exemplo do contrato == resposta capturada', () {
    const pares = {
      'relatorio_acervo.example.json': 'relatorio_acervo.json',
      'relatorio_acervo_por_corretor.example.json':
          'relatorio_acervo_por_corretor.json',
      'relatorio_contatos.example.json': 'relatorio_contatos.json',
      'relatorio_mudancas.example.json': 'relatorio_mudancas.json',
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

  group('totais por situação (§18.2)', () {
    test('totais tem exatamente as 4 situações, todas inteiras', () {
      final acervo = _fixture('relatorio_acervo.json');
      final totais = acervo['totais']! as Map<String, Object?>;

      expect(totais.keys.toSet(), _situacoes);
      for (final entrada in totais.entries) {
        expect(entrada.value, isA<int>(), reason: 'totais.${entrada.key}');
        expect(entrada.value! as int, greaterThanOrEqualTo(0));
      }
    });

    test('total é inteiro e igual à soma dos totais por situação', () {
      final acervo = _fixture('relatorio_acervo.json');
      final totais = acervo['totais']! as Map<String, Object?>;
      final soma = totais.values.fold<int>(
        0,
        (parcial, valor) => parcial + (valor! as int),
      );

      expect(acervo['total'], isA<int>());
      expect(acervo['total'], soma);
    });

    test('situacoes e linhas existem (o app não lê, só o servidor usa)', () {
      final acervo = _fixture('relatorio_acervo.json');

      expect(acervo, contains('situacoes'));
      expect(acervo, contains('linhas'));
    });
  });

  group('acervo por corretor (§18.3)', () {
    const fixtures = [
      'relatorio_acervo_por_corretor.json',
      'relatorio_acervo_por_corretor_outra_empresa.json',
    ];

    for (final nome in fixtures) {
      test('$nome tem {linhas, total} e as linhas com as 4 chaves exatas', () {
        _exigirChavesExatas(_fixture(nome), _chavesAcervoPorCorretor, nome);

        for (final linha in _itens(nome, 'linhas')) {
          _exigirChavesExatas(linha, _chavesLinhaAcervoCorretor, '$nome linha');
          expect(linha['corretor_id'], isA<int>(), reason: '$nome corretor_id');
          expect(linha['corretor'], isA<String>(), reason: '$nome corretor');
          expect(linha['ativo'], isA<bool>(), reason: '$nome ativo');
          expect(linha['total'], isA<int>(), reason: '$nome total');
        }
      });

      test('$nome: a soma das linhas fecha com o total', () {
        expect(_fixture(nome)['total'], isA<int>());
        expect(_somaDasLinhas(nome), _fixture(nome)['total']);
      });
    }

    test('o total da empresa A é o total do acervo (D-12)', () {
      expect(
        _fixture('relatorio_acervo_por_corretor.json')['total'],
        _fixture('relatorio_acervo.json')['total'],
      );
    });

    test('tem corretor ativo com zero e corretor desativado (D-13)', () {
      final linhas = _itens('relatorio_acervo_por_corretor.json', 'linhas');

      expect(
        linhas.where((linha) => linha['ativo'] == true && linha['total'] == 0),
        isNotEmpty,
        reason: 'o corretor ativo sem acervo precisa aparecer',
      );
      expect(
        linhas.where((linha) => linha['ativo'] == false),
        isNotEmpty,
        reason: 'o desativado que ainda é responsável precisa aparecer',
      );
    });

    test('os totais vêm em ordem não crescente (D-13)', () {
      final totais = [
        for (final linha in _itens(
          'relatorio_acervo_por_corretor.json',
          'linhas',
        ))
          linha['total']! as int,
      ];

      for (var i = 1; i < totais.length; i++) {
        expect(
          totais[i],
          lessThanOrEqualTo(totais[i - 1]),
          reason: 'quem tem mais imóveis vem primeiro',
        );
      }
    });
  });

  group('contatos por corretor (§18.4)', () {
    const fixtures = [
      'relatorio_contatos.json',
      'relatorio_contatos_periodo.json',
    ];

    for (final nome in fixtures) {
      test('$nome tem linhas, total e pendentes, com 5 chaves por linha', () {
        final corpo = _fixture(nome);

        expect(corpo, contains('linhas'));
        expect(corpo['total'], isA<int>());
        expect(corpo['pendentes'], isA<int>());
        expect(_somaDasLinhas(nome), corpo['total']);

        for (final linha in _itens(nome, 'linhas')) {
          _exigirChavesExatas(
            linha,
            _chavesLinhaContatosCorretor,
            '$nome linha',
          );
          expect(linha['total'], isA<int>(), reason: '$nome total');
          expect(linha['pendentes'], isA<int>(), reason: '$nome pendentes');
        }
      });
    }

    test('a de todo o período tem uma linha com corretor_id nulo (D-17)', () {
      final linhas = _itens('relatorio_contatos.json', 'linhas');

      expect(
        linhas.where((linha) => linha['corretor_id'] == null),
        isNotEmpty,
        reason: 'a linha da empresa (corretor desativado no clique)',
      );
    });

    test('sem datas, de e ate voltam nulos; com datas, voltam ecoados', () {
      final todo = _fixture('relatorio_contatos.json');
      final periodo = _fixture('relatorio_contatos_periodo.json');

      expect(todo['de'], isNull);
      expect(todo['ate'], isNull);
      expect(periodo['de'], '2024-01-01');
      expect(periodo['ate'], '2024-01-31');
    });

    test('o período de janeiro de 2024 não tem contato nenhum', () {
      final periodo = _fixture('relatorio_contatos_periodo.json');

      expect(periodo['total'], 0);
      expect(periodo['pendentes'], 0);
    });
  });

  group('mudanças de situação (§18.5)', () {
    const fixtures = [
      'relatorio_mudancas.json',
      'relatorio_mudancas_outra_empresa.json',
    ];

    for (final nome in fixtures) {
      test('$nome tem {dias, desde, mudancas} e as 9 chaves por item', () {
        final corpo = _fixture(nome);

        _exigirChavesExatas(corpo, _chavesMudancas, nome);
        expect(corpo['dias'], isA<int>());
        expect(corpo['desde'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));

        for (final mudanca in _itens(nome, 'mudancas')) {
          _exigirChavesExatas(mudanca, _chavesMudancaRecente, '$nome item');
        }
      });

      test('$nome tem situações conhecidas e alterado_em ISO-8601', () {
        for (final mudanca in _itens(nome, 'mudancas')) {
          expect(_situacoes, contains(mudanca['situacao_anterior']));
          expect(_situacoes, contains(mudanca['situacao_nova']));

          final alteradoEm = mudanca['alterado_em'];
          expect(alteradoEm, isA<String>(), reason: '$nome alterado_em');
          expect(
            DateTime.tryParse(alteradoEm! as String),
            isNotNull,
            reason: '$nome: alterado_em não é ISO-8601',
          );
          // O wire de São Paulo vem sempre com offset explícito (§18.7).
          expect(alteradoEm, matches(RegExp(r'(Z|[+-]\d{2}:\d{2})$')));
        }
      });
    }

    test('a janela padrão é de 7 dias, decidida no servidor (D-19)', () {
      expect(_fixture('relatorio_mudancas.json')['dias'], 7);
    });

    test('a ordem é a fixa do servidor: mais recente primeiro', () {
      final datas = [
        for (final mudanca in _itens('relatorio_mudancas.json', 'mudancas'))
          DateTime.parse(mudanca['alterado_em']! as String),
      ];

      expect(datas, isNotEmpty);
      for (var i = 1; i < datas.length; i++) {
        expect(
          datas[i].isAfter(datas[i - 1]),
          isFalse,
          reason: 'alterado_em deve ser decrescente (-alterado_em, -id)',
        );
      }
    });
  });

  group('erros (§18.1, §18.4, §18.5)', () {
    test('o 403 do corretor traz a chave detail', () {
      expect(_fixture('erro_403_relatorio.json'), contains('detail'));
    });

    test('o 400 de dias inválido traz a chave dias', () {
      expect(_fixture('erro_400_dias.json'), contains('dias'));
    });

    test('o 400 do período invertido traz a chave de', () {
      expect(_fixture('erro_400_relatorio_contatos.json'), contains('de'));
    });
  });

  group('isolamento entre empresas no wire (critério 6)', () {
    test('os relatórios da outra empresa não são vazios (a prova vale)', () {
      expect(
        _itens('relatorio_acervo_por_corretor_outra_empresa.json', 'linhas'),
        isNotEmpty,
      );
      expect(
        _fixture('relatorio_acervo_por_corretor_outra_empresa.json')['total'],
        greaterThanOrEqualTo(1),
      );
      expect(
        _itens('relatorio_mudancas_outra_empresa.json', 'mudancas'),
        isNotEmpty,
      );
    });

    test('nenhum corretor da empresa B aparece no acervo da empresa A', () {
      final daA = _idsDosCorretores('relatorio_acervo_por_corretor.json');
      final daB = _idsDosCorretores(
        'relatorio_acervo_por_corretor_outra_empresa.json',
      );

      expect(daB, isNotEmpty);
      expect(daA.intersection(daB), isEmpty);
    });

    test('nenhum imóvel da empresa B aparece nas mudanças da empresa A', () {
      final daA = _idsDosImoveis('relatorio_mudancas.json');
      final daB = _idsDosImoveis('relatorio_mudancas_outra_empresa.json');

      expect(daA, isNotEmpty);
      expect(daB, isNotEmpty);
      expect(daA.intersection(daB), isEmpty);
    });

    test('o acervo da empresa A não soma o imóvel da empresa B', () {
      final totalA = _fixture('relatorio_acervo_por_corretor.json')['total'];
      final totalB = _fixture(
        'relatorio_acervo_por_corretor_outra_empresa.json',
      )['total'];

      expect(totalB, isNot(totalA));
      expect(_fixture('relatorio_acervo.json')['total'], totalA);
    });
  });
}
