import 'situacao_imovel.dart';

/// Totais do acervo da empresa por situação (GES-01, D-09, D-10).
///
/// Imutável, sem serialização — isso é papel do Model em `data/`. Os quatro
/// números e o [total] vêm prontos do servidor: o app não soma, não confere e
/// não recalcula (critério 5). O mapa é copiado com `Map.unmodifiable` no
/// construtor, então este objeto não é `const`.
class TotaisPorSituacao {
  TotaisPorSituacao({
    required Map<SituacaoImovel, int> porSituacao,
    required this.total,
  }) : porSituacao = Map.unmodifiable(porSituacao);

  /// Quantidade de imóveis em cada uma das 4 situações, como o servidor mandou.
  final Map<SituacaoImovel, int> porSituacao;

  /// Total do servidor, guardado como veio (D-10).
  final int total;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TotaisPorSituacao) return false;
    if (other.total != total) return false;
    // Laço sobre o enum: o domínio não importa `package:collection`.
    for (final situacao in SituacaoImovel.values) {
      if (other.porSituacao[situacao] != porSituacao[situacao]) return false;
    }
    return other.porSituacao.length == porSituacao.length;
  }

  @override
  int get hashCode => Object.hash(
    total,
    Object.hashAll(
      SituacaoImovel.values.map((situacao) => porSituacao[situacao]),
    ),
  );

  @override
  String toString() =>
      'TotaisPorSituacao(porSituacao: $porSituacao, total: $total)';
}
