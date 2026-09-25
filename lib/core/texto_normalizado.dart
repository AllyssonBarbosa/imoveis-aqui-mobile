/// Normalização única de texto (acentos/caixa/espaços) — reusada por
/// `Cidade.chaveNatural` (F1/D-15) e pela busca do mock (D-05/D-06), evitando
/// que as duas implementações divirjam silenciosamente (RESEARCH Don't
/// Hand-Roll desta fase, mesmo tipo de risco do Pitfall-4 da Fase 1).
///
/// Trim, minúsculas e troca de vogais/consoantes acentuadas pelo equivalente
/// sem acento — mesma tabela que já existia em `Cidade._normalizar`.
String normalizarTexto(String valor) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';
  final minusculo = valor.trim().toLowerCase();
  final builder = StringBuffer();
  for (final char in minusculo.split('')) {
    final indice = comAcento.indexOf(char);
    builder.write(indice >= 0 ? semAcento[indice] : char);
  }
  return builder.toString();
}
