/// Tabela estática nome-do-estado → UF (2 caracteres), para normalizar
/// `Placemark.administrativeArea` (frequentemente o nome por extenso no
/// Android) antes do casamento D-09 nome+uf com `Cidade.uf`.
///
/// Nunca comparar `administrativeArea` diretamente com `Cidade.uf`
/// (RESEARCH Pitfall 2) — sempre passar por [normalizarUf] primeiro.
class UfLookup {
  const UfLookup._();

  static const Map<String, String> _nomeParaUf = {
    'acre': 'AC',
    'alagoas': 'AL',
    'amapa': 'AP',
    'amazonas': 'AM',
    'bahia': 'BA',
    'ceara': 'CE',
    'distrito federal': 'DF',
    'espirito santo': 'ES',
    'goias': 'GO',
    'maranhao': 'MA',
    'mato grosso': 'MT',
    'mato grosso do sul': 'MS',
    'minas gerais': 'MG',
    'para': 'PA',
    'paraiba': 'PB',
    'parana': 'PR',
    'pernambuco': 'PE',
    'piaui': 'PI',
    'rio de janeiro': 'RJ',
    'rio grande do norte': 'RN',
    'rio grande do sul': 'RS',
    'rondonia': 'RO',
    'roraima': 'RR',
    'santa catarina': 'SC',
    'sao paulo': 'SP',
    'sergipe': 'SE',
    'tocantins': 'TO',
  };

  static const Set<String> _ufsValidas = {
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS',
    'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC',
    'SP', 'SE', 'TO',
  };

  /// Normaliza um `administrativeArea` (nome do estado por extenso OU já a
  /// sigla de 2 letras) para a sigla UF de 2 caracteres.
  ///
  /// Retorna `null` quando o valor não corresponde a nenhum estado
  /// brasileiro conhecido.
  static String? normalizarUf(String? valor) {
    if (valor == null) return null;
    final bruto = valor.trim();
    if (bruto.isEmpty) return null;

    final maiusculo = bruto.toUpperCase();
    if (maiusculo.length == 2 && _ufsValidas.contains(maiusculo)) {
      return maiusculo;
    }

    final chave = _semAcentos(bruto.toLowerCase());
    return _nomeParaUf[chave];
  }

  static String _semAcentos(String valor) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucn';
    final builder = StringBuffer();
    for (final char in valor.split('')) {
      final indice = comAcento.indexOf(char);
      builder.write(indice >= 0 ? semAcento[indice] : char);
    }
    return builder.toString();
  }
}
