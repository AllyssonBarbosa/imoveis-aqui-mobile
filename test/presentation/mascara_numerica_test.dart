import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/mascara_numerica.dart';

void main() {
  group('MascaraMilhares (D-09)', () {
    TextEditingValue formatar(String textoDigitado) {
      return const MascaraMilhares().formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: textoDigitado,
          selection: TextSelection.collapsed(offset: textoDigitado.length),
        ),
      );
    }

    test('"250000" vira "250.000"', () {
      expect(formatar('250000').text, '250.000');
    });

    test('letras e símbolos são descartados', () {
      expect(formatar('R\$25a0.b000!').text, '250.000');
    });

    test('zeros à esquerda são descartados, exceto um "0" isolado', () {
      expect(formatar('0').text, '0');
      expect(formatar('0250').text, '250');
      expect(formatar('00').text, '0');
    });

    test('entrada é limitada a 9 dígitos', () {
      expect(formatar('1234567890').text.replaceAll('.', ''), '123456789');
    });

    test('o caret fica sempre no fim do texto formatado', () {
      final resultado = formatar('250000');
      expect(resultado.selection.baseOffset, resultado.text.length);
      expect(resultado.selection.extentOffset, resultado.text.length);
    });

    test('texto vazio devolve TextEditingValue vazio', () {
      expect(formatar('').text, '');
    });
  });

  group('inteiroDoTextoMascarado (D-09, conversão fora do widget)', () {
    test('"250.000" vira 250000', () {
      expect(inteiroDoTextoMascarado('250.000'), 250000);
    });

    test('texto vazio vira null', () {
      expect(inteiroDoTextoMascarado(''), isNull);
    });

    test('ignora caracteres não-numéricos', () {
      expect(inteiroDoTextoMascarado('R\$ 1.500'), 1500);
    });
  });

  group('textoMascaradoDe (D-09)', () {
    test('1500 vira "1.500"', () {
      expect(textoMascaradoDe(1500), '1.500');
    });

    test('null vira string vazia', () {
      expect(textoMascaradoDe(null), '');
    });
  });
}
