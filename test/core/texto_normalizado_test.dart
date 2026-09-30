import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/texto_normalizado.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';

void main() {
  group('normalizarTexto', () {
    test('remove espaços nas pontas, coloca em minúsculas', () {
      expect(normalizarTexto('  Cambuí '), 'cambui');
    });

    test('remove acentos e coloca em minúsculas', () {
      expect(normalizarTexto('SÃO Paulo'), 'sao paulo');
    });

    test('mantém string vazia como vazia', () {
      expect(normalizarTexto(''), '');
    });
  });

  group('Cidade.chaveNatural continua usando a mesma normalização', () {
    test('Campinas-SP vira campinas-sp', () {
      expect(
        const Cidade(nome: 'Campinas', uf: 'SP').chaveNatural,
        'campinas-sp',
      );
    });

    test('acento e caixa não importam', () {
      expect(
        const Cidade(nome: 'São Paulo', uf: 'sp').chaveNatural,
        const Cidade(nome: 'SAO PAULO', uf: 'SP').chaveNatural,
      );
    });
  });
}
