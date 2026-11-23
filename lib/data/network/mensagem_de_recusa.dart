/// Tamanho máximo, em caracteres, da mensagem de recusa do servidor que a
/// folha mostra (D-10): acima disso o texto é cortado e ganha reticências.
const int limiteMensagemDeRecusa = 300;

/// Achata o corpo de um 400/403 do Django numa única mensagem para o usuário.
///
/// O Django devolve formatos diferentes conforme a recusa: `{"detail": "..."}`,
/// `{"situacao": ["..."]}`, `{"observacao": ["..."]}`,
/// `{"non_field_errors": ["..."]}`. Por isso junta, na ordem das chaves, todo
/// valor de texto e todo item de texto das listas, de qualquer chave, sem
/// espaços nas pontas e sem vazios, separados por espaço.
///
/// Devolve `null` quando o [corpo] não é um objeto ou não tem texto
/// aproveitável (corpo vazio, HTML, lista): quem chama trata como falha de
/// conexão. Pura e sem log: o texto vem do servidor e nunca decide nada.
String? mensagemDeRecusa(Object? corpo) {
  if (corpo is! Map<Object?, Object?>) return null;
  final partes = <String>[];
  for (final valor in corpo.values) {
    if (valor is String) {
      partes.add(valor.trim());
    } else if (valor is List<Object?>) {
      for (final item in valor) {
        if (item is String) partes.add(item.trim());
      }
    }
  }
  final texto = partes.where((parte) => parte.isNotEmpty).join(' ');
  if (texto.isEmpty) return null;
  if (texto.length <= limiteMensagemDeRecusa) return texto;
  return '${texto.substring(0, limiteMensagemDeRecusa)}…';
}
