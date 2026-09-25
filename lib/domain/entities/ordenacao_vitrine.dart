/// Opções de ordenação da vitrine (VIT-04, D-11) — os rótulos em PT ficam em
/// `presentation/` (plan 02-05); aqui só o enum e o valor de query param
/// (`valorApi`), proposta de trabalho do contrato §7.4 ainda sujeita a
/// sign-off do E2.
enum OrdenacaoVitrine {
  maisRecentes('mais_recentes'),
  precoAsc('preco_asc'),
  precoDesc('preco_desc'),
  areaAsc('area_asc'),
  areaDesc('area_desc');

  const OrdenacaoVitrine(this.valorApi);

  /// Valor exato do query param `ordenacao` de `GET /imoveis` (§5 do
  /// contrato).
  final String valorApi;
}
