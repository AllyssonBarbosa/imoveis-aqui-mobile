import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/imovel_gestao_model.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';

import '../support/api_falsa.dart';

Map<String, Object?> _fixture(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

/// Cópia da fixture com chaves trocadas (ou removidas, com valor ausente).
Map<String, Object?> _com(
  String nome,
  Map<String, Object?> alteracoes, {
  List<String> sem = const [],
}) {
  final copia = {..._fixture(nome), ...alteracoes};
  for (final chave in sem) {
    copia.remove(chave);
  }
  return copia;
}

void main() {
  group('ImovelGestaoModel.paraEntidade', () {
    test('imovel_gestao_disponivel: valores do wire capturado', () {
      final imovel = ImovelGestaoModel.fromJson(
        _fixture('imovel_gestao_disponivel.json'),
      ).paraEntidade();

      expect(imovel.id, 36);
      expect(imovel.codigo, 'DEV-INDAIATUBA-04');
      expect(imovel.titulo, 'Lote no bairro Jardim Esplanada');
      expect(imovel.finalidade, FinalidadeImovel.venda);
      expect(imovel.precoVenda, '90000.00');
      expect(imovel.precoAluguel, isNull);
      expect(imovel.situacao, SituacaoImovel.disponivel);
      expect(imovel.podeMudarSituacao, isTrue);
    });

    test('imovel_gestao_reservado: situação reservada do wire', () {
      final bruto = _fixture('imovel_gestao_reservado.json');
      final imovel = ImovelGestaoModel.fromJson(bruto).paraEntidade();

      expect(imovel.id, 36);
      expect(imovel.situacao, SituacaoImovel.reservado);
      expect(imovel.podeMudarSituacao, bruto['pode_mudar_situacao']);
    });

    test('imovel_gestao_sem_permissao: aluguel, id 14 e sem permissão', () {
      final imovel = ImovelGestaoModel.fromJson(
        _fixture('imovel_gestao_sem_permissao.json'),
      ).paraEntidade();

      expect(imovel.id, 14);
      expect(imovel.codigo, 'DEV-CAMPINAS-14');
      expect(imovel.finalidade, FinalidadeImovel.aluguel);
      expect(imovel.precoVenda, isNull);
      expect(imovel.precoAluguel, '2550.00');
      expect(imovel.podeMudarSituacao, isFalse);
    });

    test('situacao_desde vira DateTime UTC com o mesmo instante do wire', () {
      final imovel = ImovelGestaoModel.fromJson(
        _fixture('imovel_gestao_disponivel.json'),
      ).paraEntidade();

      expect(imovel.situacaoDesde.isUtc, isTrue);
      expect(
        imovel.situacaoDesde,
        DateTime.utc(2026, 11, 22, 15, 25, 40, 749, 450),
      );
    });

    test('situação desconhecida ou nula vira null, sem quebrar', () {
      final desconhecida = ImovelGestaoModel.fromJson(
        _com('imovel_gestao_disponivel.json', {'situacao': 'EM_OBRA'}),
      ).paraEntidade();
      final nula = ImovelGestaoModel.fromJson(
        _com('imovel_gestao_disponivel.json', {'situacao': null}),
      ).paraEntidade();

      expect(desconhecida.situacao, isNull);
      expect(nula.situacao, isNull);
    });

    test('finalidade desconhecida lança FormatException', () {
      final modelo = ImovelGestaoModel.fromJson(
        _com('imovel_gestao_disponivel.json', {'finalidade': 'PERMUTA'}),
      );

      expect(modelo.paraEntidade, throwsA(isA<FormatException>()));
    });

    test('situacao_desde inválido lança FormatException', () {
      final modelo = ImovelGestaoModel.fromJson(
        _com('imovel_gestao_disponivel.json', {'situacao_desde': 'ontem'}),
      );

      expect(modelo.paraEntidade, throwsA(isA<FormatException>()));
    });

    test('sem pode_mudar_situacao o fromJson lança TypeError', () {
      final bruto = _com(
        'imovel_gestao_disponivel.json',
        const {},
        sem: const ['pode_mudar_situacao'],
      );

      expect(() => ImovelGestaoModel.fromJson(bruto), throwsA(isA<TypeError>()));
    });

    test('só as 9 chaves lidas: o Model não carrega dono, descrição nem '
        'endereço', () {
      final json = ImovelGestaoModel.fromJson(
        _fixture('imovel_gestao_disponivel.json'),
      ).toJson();

      expect(json.keys.toSet(), {
        'id',
        'codigo',
        'titulo',
        'finalidade',
        'preco_venda',
        'preco_aluguel',
        'situacao',
        'situacao_desde',
        'pode_mudar_situacao',
      });
    });
  });
}
