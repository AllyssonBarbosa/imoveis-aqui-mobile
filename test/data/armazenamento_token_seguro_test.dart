import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/armazenamento_token_seguro.dart';
import 'package:mocktail/mocktail.dart';

import '../support/armazenamento_token_em_memoria.dart';

class _ArmazenamentoSeguroFalso extends Mock implements FlutterSecureStorage {}

void main() {
  group('ArmazenamentoTokenSeguro', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('começa sem token', () async {
      final armazenamento = ArmazenamentoTokenSeguro(
        const FlutterSecureStorage(),
      );

      expect(await armazenamento.ler(), isNull);
    });

    test('salvar guarda o token e apagar o remove', () async {
      final armazenamento = ArmazenamentoTokenSeguro(
        const FlutterSecureStorage(),
      );

      await armazenamento.salvar('abc');
      expect(await armazenamento.ler(), 'abc');

      await armazenamento.apagar();
      expect(await armazenamento.ler(), isNull);
    });

    test('lê o token de uma abertura anterior (chave token_api)', () async {
      FlutterSecureStorage.setMockInitialValues({'token_api': 'xyz'});
      final armazenamento = ArmazenamentoTokenSeguro(
        const FlutterSecureStorage(),
      );

      expect(await armazenamento.ler(), 'xyz');
    });

    test('PlatformException na leitura vira "sem sessão" (null)', () async {
      final seguro = _ArmazenamentoSeguroFalso();
      when(
        () => seguro.read(key: any(named: 'key')),
      ).thenThrow(PlatformException(code: 'chave_invalida'));
      final armazenamento = ArmazenamentoTokenSeguro(seguro);

      expect(await armazenamento.ler(), isNull);
    });
  });

  group('ArmazenamentoTokenEmMemoria', () {
    test('aceita um token inicial opcional e cumpre a interface', () async {
      final vazio = ArmazenamentoTokenEmMemoria();
      expect(await vazio.ler(), isNull);

      final comToken = ArmazenamentoTokenEmMemoria('t0');
      expect(await comToken.ler(), 't0');

      await comToken.salvar('t1');
      expect(comToken.token, 't1');

      await comToken.apagar();
      expect(await comToken.ler(), isNull);
    });
  });
}
