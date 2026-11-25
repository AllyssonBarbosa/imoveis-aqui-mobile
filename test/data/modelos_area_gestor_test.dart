import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/acervo_por_corretor_model.dart';
import 'package:imoveis_aqui/data/models/contatos_por_corretor_model.dart';
import 'package:imoveis_aqui/data/models/mudancas_recentes_model.dart';
import 'package:imoveis_aqui/data/models/totais_por_situacao_model.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';

import '../support/api_falsa.dart';

Map<String, Object?> _fixture(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

/// Cópia rasa da fixture com chaves trocadas (os casos malformados nascem do
/// wire real, nunca de JSON escrito à mão — D-27).
Map<String, Object?> _fixtureCom(
  String nome,
  Map<String, Object?> alteracoes,
) => {..._fixture(nome), ...alteracoes};

void main() {
  group('TotaisPorSituacaoModel (GET /api/relatorios/acervo/)', () {
    test('lê as 4 situações e o total do servidor, sem somar', () {
      final bruto = _fixture('relatorio_acervo.json');
      final totais = TotaisPorSituacaoModel.fromJson(bruto).paraEntidade();

      expect(totais.porSituacao, {
        SituacaoImovel.disponivel: 33,
        SituacaoImovel.reservado: 2,
        SituacaoImovel.vendido: 1,
        SituacaoImovel.alugado: 0,
      });
      expect(totais.total, bruto['total']);
    });

    test('ignora as chaves situacoes e linhas do wire', () {
      final bruto = _fixture('relatorio_acervo.json');
      expect(bruto.containsKey('situacoes'), isTrue);
      expect(bruto.containsKey('linhas'), isTrue);

      expect(
        () => TotaisPorSituacaoModel.fromJson(bruto).paraEntidade(),
        returnsNormally,
      );
    });

    test('chave desconhecida em totais vira FormatException', () {
      final bruto = _fixtureCom('relatorio_acervo.json', {
        'totais': {
          ...(_fixture('relatorio_acervo.json')['totais']!
              as Map<String, Object?>),
          'EM_OBRA': 3,
        },
      });

      expect(
        () => TotaisPorSituacaoModel.fromJson(bruto).paraEntidade(),
        throwsFormatException,
      );
    });

    test('situação faltando em totais vira FormatException', () {
      final totaisDoWire = Map<String, Object?>.of(
        _fixture('relatorio_acervo.json')['totais']! as Map<String, Object?>,
      )..remove('ALUGADO');
      final bruto = _fixtureCom('relatorio_acervo.json', {
        'totais': totaisDoWire,
      });

      expect(
        () => TotaisPorSituacaoModel.fromJson(bruto).paraEntidade(),
        throwsFormatException,
      );
    });
  });

  group('AcervoPorCorretorModel (GET /api/relatorios/acervo/por-corretor/)', () {
    test('lê as linhas na ordem do wire e o total do servidor', () {
      final bruto = _fixture('relatorio_acervo_por_corretor.json');
      final acervo = AcervoPorCorretorModel.fromJson(bruto).paraEntidade();

      expect(acervo.total, bruto['total']);
      expect(acervo.linhas.map((linha) => linha.corretorId), [1, 2, 7]);
      expect(acervo.linhas.map((linha) => linha.nome), [
        'Corretor Vitrine Demo',
        'Corretor Desativado Demo',
        'Corretor Sem Acervo',
      ]);
      expect(acervo.linhas.map((linha) => linha.total), [35, 1, 0]);
    });

    test('guarda o ativo falso e o total zero como vieram', () {
      final acervo = AcervoPorCorretorModel.fromJson(
        _fixture('relatorio_acervo_por_corretor.json'),
      ).paraEntidade();

      expect(acervo.linhas.where((linha) => !linha.ativo), hasLength(1));
      expect(acervo.linhas[1].ativo, isFalse);
      expect(acervo.linhas.where((linha) => linha.total == 0), hasLength(1));
    });

    test('lê a fixture da outra empresa com os mesmos números do wire', () {
      final bruto = _fixture('relatorio_acervo_por_corretor_outra_empresa.json');
      final acervo = AcervoPorCorretorModel.fromJson(bruto).paraEntidade();

      expect(acervo.linhas, hasLength(1));
      expect(acervo.linhas.single.corretorId, 5);
      expect(acervo.linhas.single.nome, 'Corretor Demo');
      expect(acervo.linhas.single.ativo, isTrue);
      expect(acervo.linhas.single.total, 1);
      expect(acervo.total, 1);
    });

    test('linha sem corretor_id lança', () {
      final bruto = _fixture('relatorio_acervo_por_corretor.json');
      final linhas = (bruto['linhas']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Map<String, Object?>.of)
          .toList();
      linhas.first.remove('corretor_id');
      final malformado = {...bruto, 'linhas': linhas};

      expect(
        () => AcervoPorCorretorModel.fromJson(malformado).paraEntidade(),
        throwsA(anyOf(isA<TypeError>(), isA<FormatException>())),
      );
    });
  });

  group('ContatosPorCorretorModel (GET /api/relatorios/contatos/)', () {
    test('lê as linhas na ordem do wire com total e pendentes', () {
      final bruto = _fixture('relatorio_contatos.json');
      final contatos = ContatosPorCorretorModel.fromJson(
        bruto,
      ).paraEntidade();

      expect(contatos.total, bruto['total']);
      expect(contatos.pendentes, bruto['pendentes']);
      expect(contatos.linhas.map((linha) => linha.corretorId), [1, null, 7]);
      expect(contatos.linhas.map((linha) => linha.total), [3, 1, 0]);
      expect(contatos.linhas.map((linha) => linha.pendentes), [2, 1, 0]);
    });

    test('as linhas de corretor guardam o nome e o ativo', () {
      final contatos = ContatosPorCorretorModel.fromJson(
        _fixture('relatorio_contatos.json'),
      ).paraEntidade();

      expect(contatos.linhas.first.nome, 'Corretor Vitrine Demo');
      expect(contatos.linhas.first.ativo, isTrue);
      expect(contatos.linhas.first.daEmpresa, isFalse);
      expect(contatos.linhas.last.nome, 'Corretor Sem Acervo');
    });

    test('a linha com corretor_id nulo descarta o texto do servidor (D-17)', () {
      final bruto = _fixture('relatorio_contatos.json');
      final linhaDoWire = (bruto['linhas']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .firstWhere((linha) => linha['corretor_id'] == null);
      // O servidor manda um texto em `corretor`; o Model não o repassa.
      expect(linhaDoWire['corretor'], isA<String>());

      final contatos = ContatosPorCorretorModel.fromJson(
        bruto,
      ).paraEntidade();
      final linhaDaEmpresa = contatos.linhas.singleWhere(
        (linha) => linha.daEmpresa,
      );

      expect(linhaDaEmpresa.nome, isNull);
      expect(linhaDaEmpresa.ativo, isNull);
      expect(linhaDaEmpresa.total, 1);
      expect(linhaDaEmpresa.pendentes, 1);
    });

    test('lê a fixture do período com a ordem do servidor', () {
      final bruto = _fixture('relatorio_contatos_periodo.json');
      final contatos = ContatosPorCorretorModel.fromJson(
        bruto,
      ).paraEntidade();

      expect(contatos.linhas.map((linha) => linha.corretorId), [7, 1]);
      expect(contatos.total, 0);
      expect(contatos.pendentes, 0);
    });

    test('linha sem total lança', () {
      final bruto = _fixture('relatorio_contatos.json');
      final linhas = (bruto['linhas']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Map<String, Object?>.of)
          .toList();
      linhas.first.remove('total');

      expect(
        () => ContatosPorCorretorModel.fromJson({
          ...bruto,
          'linhas': linhas,
        }).paraEntidade(),
        throwsA(anyOf(isA<TypeError>(), isA<FormatException>())),
      );
    });
  });

  group('MudancasRecentesModel (GET /api/relatorios/mudancas-situacao/)', () {
    test('lê os campos da fixture na ordem do wire', () {
      final bruto = _fixture('relatorio_mudancas.json');
      final mudancas = MudancasRecentesModel.fromJson(bruto).paraEntidade();

      expect(mudancas.dias, bruto['dias']);
      expect(mudancas.mudancas.map((mudanca) => mudanca.id), [4, 3]);

      final primeira = mudancas.mudancas.first;
      expect(primeira.imovelId, 35);
      expect(primeira.imovelCodigo, 'DEV-INDAIATUBA-03');
      expect(primeira.imovelTitulo, 'Terreno no bairro Centro');
      expect(primeira.situacaoAnterior, SituacaoImovel.disponivel);
      expect(primeira.situacaoNova, SituacaoImovel.vendido);
      expect(primeira.alteradoPor, 'Corretor Vitrine Demo');
    });

    test('alterado_em vira o mesmo instante em UTC', () {
      final mudancas = MudancasRecentesModel.fromJson(
        _fixture('relatorio_mudancas.json'),
      ).paraEntidade();
      final alteradoEm = mudancas.mudancas.first.alteradoEm;

      expect(alteradoEm.isUtc, isTrue);
      expect(
        alteradoEm,
        DateTime.parse('2026-11-25T17:53:12.715486-03:00').toUtc(),
      );
      expect(alteradoEm.hour, 20);
    });

    test('observacao vazia no wire fica vazia e a preenchida vem como está', () {
      final mudancas = MudancasRecentesModel.fromJson(
        _fixture('relatorio_mudancas.json'),
      ).paraEntidade();

      expect(mudancas.mudancas[0].observacao, '');
      expect(
        mudancas.mudancas[1].observacao,
        'Captura APP-12: reserva para o relatório do gestor.',
      );
    });

    test('lê a fixture da outra empresa', () {
      final mudancas = MudancasRecentesModel.fromJson(
        _fixture('relatorio_mudancas_outra_empresa.json'),
      ).paraEntidade();

      expect(mudancas.mudancas, hasLength(1));
      expect(mudancas.mudancas.single.imovelCodigo, 'DEMO-CASA-01');
      expect(mudancas.mudancas.single.alteradoPor, 'Gestor Demo');
    });

    Map<String, Object?> comMudanca(Map<String, Object?> alteracoes) {
      final bruto = _fixture('relatorio_mudancas.json');
      final itens = (bruto['mudancas']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Map<String, Object?>.of)
          .toList();
      itens.first.addAll(alteracoes);
      return {...bruto, 'mudancas': itens};
    }

    test('situacao_nova desconhecida vira FormatException (D-24)', () {
      expect(
        () => MudancasRecentesModel.fromJson(
          comMudanca({'situacao_nova': 'EM_OBRA'}),
        ).paraEntidade(),
        throwsFormatException,
      );
    });

    test('situacao_anterior desconhecida vira FormatException (D-24)', () {
      expect(
        () => MudancasRecentesModel.fromJson(
          comMudanca({'situacao_anterior': 'EM_OBRA'}),
        ).paraEntidade(),
        throwsFormatException,
      );
    });

    test('alterado_em inválido vira FormatException', () {
      expect(
        () => MudancasRecentesModel.fromJson(
          comMudanca({'alterado_em': 'ontem à tarde'}),
        ).paraEntidade(),
        throwsFormatException,
      );
    });
  });
}
