import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Máscara de milhares pt_BR para os campos de faixa de preço/área (D-09) —
/// `TextInputFormatter` hand-rolado sobre `intl.NumberFormat`: um formatter
/// de poucas dezenas de linhas não justifica um pacote de máscara externo
/// (RESEARCH Don't Hand-Roll, mesmo racional do `Debouncer` hand-rolado na
/// Fase 2). Letras/símbolos são descartados (só dígitos entram), zeros à
/// esquerda são descartados (um "0" isolado permanece), a entrada é limitada
/// a 9 dígitos (cobre qualquer faixa de preço/área razoável) e o caret fica
/// sempre no fim. A conversão para/de `int` fica em [inteiroDoTextoMascarado]
/// e [textoMascaradoDe] — FORA do widget (mesma disciplina de
/// `apresentacao_imovel.dart`).
class MascaraMilhares extends TextInputFormatter {
  const MascaraMilhares();

  static const int _maximoDigitos = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    digitos = digitos.replaceFirst(RegExp(r'^0+(?=.)'), '');
    if (digitos.length > _maximoDigitos) {
      digitos = digitos.substring(0, _maximoDigitos);
    }
    if (digitos.isEmpty) {
      return const TextEditingValue();
    }
    final formatado = textoMascaradoDe(int.parse(digitos));
    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: formatado.length),
    );
  }
}

/// Converte o texto já mascarado (ex. "250.000") de volta ao inteiro cru que
/// vai para [FiltrosVitrine] (D-09) — texto vazio (ou só não-dígitos) vira
/// `null`.
int? inteiroDoTextoMascarado(String texto) {
  final digitos = texto.replaceAll(RegExp('[^0-9]'), '');
  if (digitos.isEmpty) return null;
  return int.parse(digitos);
}

/// Formata um inteiro com separador de milhar pt_BR (D-09) — `null` vira
/// string vazia (campo em branco).
String textoMascaradoDe(int? valor) {
  if (valor == null) return '';
  return NumberFormat('#,##0', 'pt_BR').format(valor);
}
