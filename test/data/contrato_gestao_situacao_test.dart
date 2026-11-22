import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/api_falsa.dart';

/// Teste de contrato do detalhe de gestão, da mudança de situação e do
/// histórico do imóvel (API-11, §16 de `01-CONTRATO-API.md`): os exemplos do
/// contrato (`contrato/*.example.json`) são cópias EXATAS das respostas
/// capturadas do Django da `origin/main` da web (`test/fixtures/api/`, nenhum
/// wire escrito à mão). As 9 chaves que o app lê do imóvel, as 6 do histórico
/// e a forma dos erros (400 em `situacao`, 403/404 em `detail`) são as do
/// servidor: chave perdida ou formato novo no Django quebra este teste, sem
/// drift silencioso entre os dois repositórios.
///
/// Os exemplos vivem no diretório da Fase 1. Se esse diretório for um dia
/// arquivado, mova os `*.example.json` e corrija [_pastaContrato].
const _pastaContrato =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato';

/// As 9 chaves do `ImovelSerializer` que o app lê. É SUBCONJUNTO, não
/// allowlist exata: o serializer é compartilhado com o painel do corretor e
/// traz outras 17 chaves que o app ignora.
const _chavesLidasDoImovel = {
  'id',
  'codigo',
  'titulo',
  'finalidade',
  'preco_venda',
  'preco_aluguel',
  'situacao',
  'situacao_desde',
  'pode_mudar_situacao',
};

/// As 6 chaves exatas de cada item do histórico.
const _chavesDoHistorico = {
  'id',
  'situacao_anterior',
  'situacao_nova',
  'alterado_por',
  'alterado_em',
  'observacao',
};

const _situacoesValidas = {'DISPONIVEL', 'RESERVADO', 'VENDIDO', 'ALUGADO'};

const _finalidadesValidas = {'VENDA', 'ALUGUEL', 'VENDA_E_ALUGUEL'};

const _fixturesDeImovel = [
  'imovel_gestao_disponivel.json',
  'imovel_gestao_reservado.json',
  'imovel_gestao_sem_permissao.json',
  'situacao_200.json',
];

const _fixturesDeHistorico = [
  'historico_vazio.json',
  'historico_um_item.json',
  'historico_contrato.json',
];

/// Termina em `Z` ou em offset `+hh:mm` / `-hh:mm`: o servidor sempre manda o
/// fuso, então `DateTime.parse` nunca interpreta como hora local do aparelho.
final _terminaEmOffset = RegExp(r'(Z|[+-]\d{2}:\d{2})$');

/// Conteúdo textual de um exemplo do contrato.
String _textoDoExemplo(String nome) =>
    File('$_pastaContrato/$nome').readAsStringSync();

/// Conteúdo textual de uma fixture capturada.
String _textoDaFixture(String nome) =>
    File('test/fixtures/api/$nome').readAsStringSync();

Map<String, Object?> _objeto(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

List<Map<String, Object?>> _itensDoHistorico(String nome) => [
  for (final item in lerFixtureApi(nome)! as List<Object?>)
    item! as Map<String, Object?>,
];

/// Confere que as chaves de [objeto] são EXATAMENTE as de [esperadas].
void _exigirChavesExatas(Object? objeto, Set<String> esperadas, String rotulo) {
  final chaves = (objeto! as Map<String, Object?>).keys.toSet();
  expect(
    chaves.difference(esperadas),
    isEmpty,
    reason: '$rotulo tem chave fora do que o servidor trava',
  );
  expect(
    esperadas.difference(chaves),
    isEmpty,
    reason: '$rotulo perdeu chave que o servidor trava',
  );
}

void main() {
  group('exemplo do contrato == resposta capturada', () {
    const pares = {
      'imovel_gestao.example.json': 'imovel_gestao_disponivel.json',
      'historico_situacao.example.json': 'historico_um_item.json',
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

  group('detalhe do imóvel (as 9 chaves que o app lê)', () {
    for (final nome in _fixturesDeImovel) {
      test('$nome tem as 9 chaves lidas, com os tipos certos', () {
        final imovel = _objeto(nome);

        expect(
          _chavesLidasDoImovel.difference(imovel.keys.toSet()),
          isEmpty,
          reason: '$nome perdeu chave lida pelo app',
        );
        expect(imovel['id'], isA<int>());
        expect(imovel['codigo'], isA<String>());
        expect(imovel['titulo'], isA<String>());
        expect(_finalidadesValidas, contains(imovel['finalidade']));
        for (final preco in ['preco_venda', 'preco_aluguel']) {
          expect(
            imovel[preco] == null || imovel[preco] is String,
            isTrue,
            reason: '$nome: $preco deveria ser texto decimal ou nulo',
          );
        }
        expect(_situacoesValidas, contains(imovel['situacao']));
        expect(imovel['pode_mudar_situacao'], isA<bool>());
      });

      test('$nome tem situacao_desde que o DateTime.parse aceita, com fuso', () {
        final texto = _objeto(nome)['situacao_desde']! as String;

        expect(() => DateTime.parse(texto), returnsNormally);
        expect(_terminaEmOffset.hasMatch(texto), isTrue);
      });
    }

    test('o imóvel disponível é o primeiro cartão do acervo e pode mudar', () {
      final primeiro =
          ((_objeto('acervo_p1.json')['results']! as List<Object?>).first!)
              as Map<String, Object?>;
      final imovel = _objeto('imovel_gestao_disponivel.json');

      expect(imovel['id'], primeiro['id']);
      expect(imovel['codigo'], primeiro['codigo']);
      expect(imovel['situacao'], 'DISPONIVEL');
      expect(imovel['pode_mudar_situacao'], isTrue);
    });

    test('o imóvel do colega é o do acervo_busca e não pode mudar', () {
      final unico =
          ((_objeto('acervo_busca.json')['results']! as List<Object?>).first!)
              as Map<String, Object?>;
      final imovel = _objeto('imovel_gestao_sem_permissao.json');

      expect(imovel['id'], unico['id']);
      expect(imovel['codigo'], unico['codigo']);
      expect(imovel['pode_mudar_situacao'], isFalse);
    });

    test('o 200 do POST e o detalhe relido mostram RESERVADO do mesmo imóvel', () {
      final antes = _objeto('imovel_gestao_disponivel.json');
      final depois = _objeto('imovel_gestao_reservado.json');
      final resposta = _objeto('situacao_200.json');

      expect(depois['situacao'], 'RESERVADO');
      expect(resposta['situacao'], 'RESERVADO');
      expect(depois['id'], antes['id']);
      expect(resposta['id'], antes['id']);
      // a data é do servidor (D-05): muda junto com a situação
      expect(depois['situacao_desde'], isNot(antes['situacao_desde']));
    });
  });

  group('histórico da situação', () {
    for (final nome in _fixturesDeHistorico) {
      test('$nome é uma lista sem envelope e cada item tem as 6 chaves', () {
        expect(lerFixtureApi(nome), isA<List<Object?>>());

        for (final item in _itensDoHistorico(nome)) {
          _exigirChavesExatas(item, _chavesDoHistorico, '$nome[]');
          expect(item['id'], isA<int>());
          expect(_situacoesValidas, contains(item['situacao_anterior']));
          expect(_situacoesValidas, contains(item['situacao_nova']));
          expect(item['alterado_por'], isA<String>());
          expect(item['observacao'], isA<String>());
          final alteradoEm = item['alterado_em']! as String;
          expect(() => DateTime.parse(alteradoEm), returnsNormally);
          expect(_terminaEmOffset.hasMatch(alteradoEm), isTrue);
        }
      });

      test('$nome vem em ordem de alterado_em decrescente (ordem do servidor)', () {
        final datas = [
          for (final item in _itensDoHistorico(nome))
            DateTime.parse(item['alterado_em']! as String),
        ];

        for (var i = 1; i < datas.length; i++) {
          expect(
            datas[i].isAfter(datas[i - 1]),
            isFalse,
            reason: '$nome fora da ordem mais recente primeiro',
          );
        }
      });
    }

    test('o histórico vazio é uma lista vazia, não um erro', () {
      expect(lerFixtureApi('historico_vazio.json'), isEmpty);
    });

    test('o histórico depois da mudança tem DISPONIVEL → RESERVADO', () {
      final itens = _itensDoHistorico('historico_um_item.json');

      expect(itens, hasLength(1));
      expect(itens.single['situacao_anterior'], 'DISPONIVEL');
      expect(itens.single['situacao_nova'], 'RESERVADO');
      expect(itens.single['observacao'], isNotEmpty);
    });

    test('o histórico do imóvel com contrato tem item de quem assinou', () {
      expect(_itensDoHistorico('historico_contrato.json'), isNotEmpty);
    });
  });

  group('erros capturados', () {
    test('os 400 são {situacao: [texto, ...]} com textos não vazios', () {
      for (final nome in [
        'erro_400_mesma_situacao.json',
        'erro_400_contrato_assinado.json',
      ]) {
        final erro = _objeto(nome);

        _exigirChavesExatas(erro, {'situacao'}, nome);
        final textos = erro['situacao']! as List<Object?>;
        expect(textos, isNotEmpty);
        for (final texto in textos) {
          expect(texto, isA<String>());
          expect((texto! as String).trim(), isNotEmpty);
        }
      }
    });

    test('o 400 do contrato assinado cita o contrato', () {
      final textos =
          _objeto('erro_400_contrato_assinado.json')['situacao']!
              as List<Object?>;

      expect(textos.join(' ').toLowerCase(), contains('contrato'));
    });

    test('o 403 e os 404 são {detail: texto}', () {
      for (final nome in [
        'erro_403_situacao.json',
        'erro_404_imovel.json',
        'erro_404_historico.json',
      ]) {
        final erro = _objeto(nome);

        _exigirChavesExatas(erro, {'detail'}, nome);
        expect(erro['detail'], isA<String>());
        expect((erro['detail']! as String).trim(), isNotEmpty);
      }
    });

    test('o 404 do histórico de outra empresa é igual ao do detalhe (T-09-02)', () {
      // O corretor de outra empresa não distingue "não é meu" de "não
      // existe", nem por qual das duas rotas perguntou.
      expect(
        _objeto('erro_404_historico.json'),
        equals(_objeto('erro_404_imovel.json')),
      );
    });

    test('o 404 vem em inglês: o app nunca o exibe', () {
      expect(
        _objeto('erro_404_imovel.json')['detail'],
        'No Imovel matches the given query.',
      );
    });
  });
}
