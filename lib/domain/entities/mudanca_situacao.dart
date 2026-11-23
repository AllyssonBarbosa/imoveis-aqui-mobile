import 'situacao_imovel.dart';

/// Entidade de domínio: uma mudança de situação de um imóvel, uma linha do
/// histórico (SIT-03).
///
/// Imutável, sem serialização — isso é papel de `MudancaSituacaoModel` em
/// `data/`. Tudo vem decidido pelo servidor: o app não calcula quem mudou nem
/// quando (D-05) e mostra a lista na ordem recebida (D-11). As situações são
/// anuláveis porque um código desconhecido vira `null`, nunca quebra a lista.
class MudancaSituacao {
  const MudancaSituacao({
    required this.id,
    this.situacaoAnterior,
    this.situacaoNova,
    this.alteradoPor,
    required this.alteradoEm,
    required this.observacao,
  });

  final int id;

  /// `null` quando o servidor mandou uma situação que o app não conhece.
  final SituacaoImovel? situacaoAnterior;

  /// `null` quando o servidor mandou uma situação que o app não conhece.
  final SituacaoImovel? situacaoNova;

  /// Nome de quem mudou, como o servidor mandou; `null` se não veio.
  final String? alteradoPor;

  /// Instante da mudança, UTC, como o servidor registrou (D-05).
  final DateTime alteradoEm;

  /// Texto como veio; vazio (`''`) quando não há observação.
  final String observacao;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MudancaSituacao &&
          other.id == id &&
          other.situacaoAnterior == situacaoAnterior &&
          other.situacaoNova == situacaoNova &&
          other.alteradoPor == alteradoPor &&
          other.alteradoEm == alteradoEm &&
          other.observacao == observacao);

  @override
  int get hashCode => Object.hash(
    id,
    situacaoAnterior,
    situacaoNova,
    alteradoPor,
    alteradoEm,
    observacao,
  );

  // Sem nome nem observação no texto: podem trazer dado de cliente (T-09-06).
  @override
  String toString() =>
      'MudancaSituacao(id: $id, $situacaoAnterior -> $situacaoNova, '
      'em: $alteradoEm)';
}
