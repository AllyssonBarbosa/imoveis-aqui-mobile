/// Uma linha dos contatos por corretor (GES-03, D-15, D-17). Imutável e
/// `const`-construível, sem serialização.
///
/// Linha da empresa: contato que foi para a empresa porque o corretor estava
/// desativado no clique. Ela vem com [corretorId], [nome] e [ativo] nulos; o
/// nome do servidor não é guardado, a tela usa texto fixo (D-17).
class ContatosDoCorretor {
  const ContatosDoCorretor({
    this.corretorId,
    this.nome,
    this.ativo,
    required this.total,
    required this.pendentes,
  });

  /// `null` na linha da empresa.
  final int? corretorId;

  /// `null` na linha da empresa.
  final String? nome;

  /// `null` na linha da empresa.
  final bool? ativo;

  /// Contatos recebidos no período, como o servidor contou.
  final int total;

  /// Contatos ainda sem retorno anotado, como o servidor contou.
  final int pendentes;

  /// `true` na linha da empresa (sem corretor).
  bool get daEmpresa => corretorId == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContatosDoCorretor &&
          other.corretorId == corretorId &&
          other.nome == nome &&
          other.ativo == ativo &&
          other.total == total &&
          other.pendentes == pendentes);

  @override
  int get hashCode => Object.hash(corretorId, nome, ativo, total, pendentes);

  @override
  String toString() =>
      'ContatosDoCorretor(corretorId: $corretorId, total: $total, '
      'pendentes: $pendentes)';
}

/// Contatos por corretor (GES-03): [linhas] na ordem do servidor, com [total]
/// e [pendentes] como vieram. Só por período, nunca por imóvel (D-15); o app
/// não soma, não filtra e não reordena (critério 5). A lista é copiada com
/// `List.unmodifiable`, então este objeto não é `const`.
class ContatosPorCorretor {
  ContatosPorCorretor({
    required List<ContatosDoCorretor> linhas,
    required this.total,
    required this.pendentes,
  }) : linhas = List.unmodifiable(linhas);

  final List<ContatosDoCorretor> linhas;

  /// Total do servidor, mesmo que difira da soma das [linhas].
  final int total;

  /// Pendentes do servidor, mesmo que difiram da soma das [linhas].
  final int pendentes;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ContatosPorCorretor) return false;
    if (other.total != total || other.pendentes != pendentes) return false;
    if (other.linhas.length != linhas.length) return false;
    for (var indice = 0; indice < linhas.length; indice++) {
      if (other.linhas[indice] != linhas[indice]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(linhas), total, pendentes);

  @override
  String toString() =>
      'ContatosPorCorretor(linhas: ${linhas.length}, total: $total, '
      'pendentes: $pendentes)';
}
