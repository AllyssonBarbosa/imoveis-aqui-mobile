/// Uma linha do acervo por corretor (GES-02, D-13, D-14): quantos imóveis o
/// corretor tem hoje. Imutável e `const`-construível, sem serialização.
///
/// [ativo] vem do servidor; o app só mostra a marca de desativado, nunca
/// decide quem aparece nem em que ordem (D-13).
class AcervoDoCorretor {
  const AcervoDoCorretor({
    required this.corretorId,
    required this.nome,
    required this.ativo,
    required this.total,
  });

  final int corretorId;
  final String nome;

  /// `false` quando o corretor foi desativado (D-14).
  final bool ativo;

  /// Imóveis do corretor, como o servidor contou.
  final int total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AcervoDoCorretor &&
          other.corretorId == corretorId &&
          other.nome == nome &&
          other.ativo == ativo &&
          other.total == total);

  @override
  int get hashCode => Object.hash(corretorId, nome, ativo, total);

  @override
  String toString() =>
      'AcervoDoCorretor(corretorId: $corretorId, ativo: $ativo, total: $total)';
}

/// Acervo por corretor (GES-02): [linhas] na ordem do servidor e o [total]
/// como veio. Quem aparece e a ordem são do servidor (D-13); o app não soma,
/// não filtra e não reordena (critério 5). A lista é copiada com
/// `List.unmodifiable`, então este objeto não é `const`.
class AcervoPorCorretor {
  AcervoPorCorretor({
    required List<AcervoDoCorretor> linhas,
    required this.total,
  }) : linhas = List.unmodifiable(linhas);

  final List<AcervoDoCorretor> linhas;

  /// Total do servidor, mesmo que difira da soma das [linhas].
  final int total;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AcervoPorCorretor) return false;
    if (other.total != total) return false;
    if (other.linhas.length != linhas.length) return false;
    for (var indice = 0; indice < linhas.length; indice++) {
      if (other.linhas[indice] != linhas[indice]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(linhas), total);

  @override
  String toString() =>
      'AcervoPorCorretor(linhas: ${linhas.length}, total: $total)';
}
