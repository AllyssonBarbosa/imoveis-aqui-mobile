/// Entidade de domínio: uma cidade atendida pelo marketplace.
///
/// Imutável, sem serialização (isso é papel de `CidadeModel` em `data/`).
class Cidade {
  const Cidade({required this.nome, required this.uf});

  final String nome;
  final String uf;

  /// Chave natural normalizada (minúsculas, sem espaços nas pontas, sem
  /// acentos) — usada para casar a cidade detectada por geocodificação com a
  /// lista de cidades atendidas (D-09) e como base da chave persistida
  /// (D-15), estável através da transição fixture → API real (a API não
  /// garante manter os mesmos `id`s da fixture).
  String get chaveNatural => '${_normalizar(nome)}-${_normalizar(uf)}';

  static String _normalizar(String valor) {
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cidade && other.nome == nome && other.uf == uf);

  @override
  int get hashCode => Object.hash(nome, uf);

  @override
  String toString() => 'Cidade(nome: $nome, uf: $uf)';
}
