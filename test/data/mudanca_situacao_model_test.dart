import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/mudanca_situacao_model.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';

import '../support/api_falsa.dart';

List<Map<String, Object?>> _fixture(String nome) =>
    (lerFixtureApi(nome)! as List<Object?>).cast<Map<String, Object?>>();

void main() {
  group('MudancaSituacaoModel.paraEntidade', () {
    test('historico_um_item: valores do wire capturado', () {
      final mudanca = MudancaSituacaoModel.fromJson(
        _fixture('historico_um_item.json').single,
      ).paraEntidade();

      expect(mudanca.id, 2);
      expect(mudanca.situacaoAnterior, SituacaoImovel.disponivel);
      expect(mudanca.situacaoNova, SituacaoImovel.reservado);
      expect(mudanca.alteradoPor, 'Corretor Vitrine Demo');
      expect(mudanca.observacao, 'Reservado na conversa com o cliente.');
    });

    test('alteradoEm vira instante UTC do servidor (D-05)', () {
      final mudanca = MudancaSituacaoModel.fromJson(
        _fixture('historico_um_item.json').single,
      ).paraEntidade();

      expect(mudanca.alteradoEm.isUtc, isTrue);
      // 12:25:43.371313-03:00 == 15:25:43.371313Z
      expect(
        mudanca.alteradoEm,
        DateTime.utc(2026, 11, 22, 15, 25, 43, 371, 313),
      );
    });

    test('historico_contrato: venda por contrato com observação automática',
        () {
      final mudanca = MudancaSituacaoModel.fromJson(
        _fixture('historico_contrato.json').single,
      ).paraEntidade();

      expect(mudanca.id, 1);
      expect(mudanca.situacaoAnterior, SituacaoImovel.disponivel);
      expect(mudanca.situacaoNova, SituacaoImovel.vendido);
      expect(mudanca.alteradoPor, 'Gestor Demo');
      expect(mudanca.observacao, 'Contrato #1 de venda assinado em 01/07/2026.');
    });

    test('código de situação desconhecido vira null, sem quebrar (T-09-10)',
        () {
      final mudanca = MudancaSituacaoModel.fromJson({
        ..._fixture('historico_um_item.json').single,
        'situacao_anterior': 'EM_OBRAS',
        'situacao_nova': null,
      }).paraEntidade();

      expect(mudanca.situacaoAnterior, isNull);
      expect(mudanca.situacaoNova, isNull);
    });

    test('observação ausente vira string vazia e alterado_por ausente vira '
        'null', () {
      final bruto = {..._fixture('historico_um_item.json').single}
        ..remove('observacao')
        ..remove('alterado_por');

      final mudanca = MudancaSituacaoModel.fromJson(bruto).paraEntidade();

      expect(mudanca.observacao, '');
      expect(mudanca.alteradoPor, isNull);
    });

    test('alterado_em que não é data lança FormatException', () {
      final modelo = MudancaSituacaoModel.fromJson({
        ..._fixture('historico_um_item.json').single,
        'alterado_em': 'ontem',
      });

      expect(modelo.paraEntidade, throwsFormatException);
    });
  });
}
