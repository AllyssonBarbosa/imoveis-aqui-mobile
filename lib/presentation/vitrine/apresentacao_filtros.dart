// Funções puras de apresentação dos filtros (D-15, D-16) — a conversão de
// FiltrosVitrine para texto fica FORA do widget, mesma disciplina de
// `apresentacao_imovel.dart`.

/// Rótulo do botão "Filtros" (D-15) — 'Filtros' sem contagem quando nenhum
/// filtro está ativo, ou 'Filtros (N)' com o número de filtros ATIVOS (não
/// de valores, D-16) — a mesma fonte que os chips (plan 03-02) usarão.
String rotuloBotaoFiltros(int quantidade) {
  if (quantidade == 0) return 'Filtros';
  return 'Filtros ($quantidade)';
}
