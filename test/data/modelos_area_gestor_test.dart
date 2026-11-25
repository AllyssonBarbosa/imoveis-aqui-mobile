import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/acervo_por_corretor_model.dart';
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
}
