import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/constants/uf_lookup.dart';

void main() {
  group('UfLookup.normalizarUf', () {
    test('nome completo "São Paulo" normaliza para "SP"', () {
      expect(UfLookup.normalizarUf('São Paulo'), 'SP');
    });

    test('nome completo "Rio de Janeiro" normaliza para "RJ"', () {
      expect(UfLookup.normalizarUf('Rio de Janeiro'), 'RJ');
    });

    test('sigla já normalizada "SP" passa direto', () {
      expect(UfLookup.normalizarUf('SP'), 'SP');
    });

    test('sigla em minúsculas "sp" normaliza para "SP"', () {
      expect(UfLookup.normalizarUf('sp'), 'SP');
    });

    test('nome com acentos e variação de caixa é tolerado', () {
      expect(UfLookup.normalizarUf('  ESPÍRITO SANTO  '), 'ES');
    });

    test('valor nulo retorna null', () {
      expect(UfLookup.normalizarUf(null), isNull);
    });

    test('valor vazio retorna null', () {
      expect(UfLookup.normalizarUf(''), isNull);
    });

    test('valor desconhecido retorna null', () {
      expect(UfLookup.normalizarUf('Nárnia'), isNull);
    });
  });
}
