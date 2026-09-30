import 'package:freezed_annotation/freezed_annotation.dart';

import 'imovel.dart';

part 'filtros_vitrine.freezed.dart';

/// Finalidade escolhida no filtro (FIL-01) — distinto de [FinalidadeImovel]:
/// a UI só oferece Qualquer/Venda/Aluguel (D-02), nunca "venda e aluguel"
/// como opção de filtro (é o SERVIDOR/mock quem aplica a inclusão). `null`
/// em [FiltrosVitrine.finalidade] significa "Qualquer".
enum FinalidadeFiltro { venda, aluguel }

/// Cada dimensão filtrável da vitrine — ORDEM FIXA (também a ordem dos
/// chips resumidos e a base de [FiltrosVitrine.ativos], D-16).
enum FiltroAtivo {
  finalidade,
  naturezas,
  preco,
  quartos,
  suites,
  vagas,
  bairros,
  area,
  caracteristicas,
}

/// Conjunto completo de filtros da vitrine (FIL-01..FIL-04) — objeto de
/// domínio imutável, com todos os valores já normalizados/tipados
/// (`Set<NaturezaImovel>`, nunca strings soltas). O mapeamento para o
/// formato de wire exato do contrato (CSV, `_min`, nomes de campo) fica
/// inteiramente em `data/parametros_consulta_imoveis.dart` — este arquivo
/// nunca conhece nome de query param.
@freezed
abstract class FiltrosVitrine with _$FiltrosVitrine {
  const factory FiltrosVitrine({
    /// `null` = "Qualquer" (D-11).
    FinalidadeFiltro? finalidade,

    /// OU entre valores (D-05).
    @Default(<NaturezaImovel>{}) Set<NaturezaImovel> naturezas,

    /// Depende da finalidade escolhida (D-03) — comparado com `preco_venda`
    /// ou `preco_aluguel` conforme [finalidade], decisão que fica em
    /// `data/`.
    int? precoMin,
    int? precoMax,

    /// "N ou mais" (D-01) — nunca "exatamente N".
    int? quartosMin,
    int? suitesMin,
    int? vagasMin,

    /// OU entre valores (D-05).
    @Default(<String>{}) Set<String> bairros,
    int? areaMin,
    int? areaMax,

    /// E entre valores (D-04) — o imóvel precisa ter TODAS as marcadas.
    @Default(<String>{}) Set<String> caracteristicas,
  }) = _FiltrosVitrine;

  const FiltrosVitrine._();

  /// Dimensões ATIVAS, na ordem fixa de [FiltroAtivo] — fonte ÚNICA tanto
  /// da contagem do botão "Filtros (N)" quanto dos chips resumidos
  /// (D-15, D-16): nunca duas contagens que podem divergir.
  List<FiltroAtivo> get ativos => [
    if (finalidade != null) FiltroAtivo.finalidade,
    if (naturezas.isNotEmpty) FiltroAtivo.naturezas,
    if (precoMin != null || precoMax != null) FiltroAtivo.preco,
    if (quartosMin != null) FiltroAtivo.quartos,
    if (suitesMin != null) FiltroAtivo.suites,
    if (vagasMin != null) FiltroAtivo.vagas,
    if (bairros.isNotEmpty) FiltroAtivo.bairros,
    if (areaMin != null || areaMax != null) FiltroAtivo.area,
    if (caracteristicas.isNotEmpty) FiltroAtivo.caracteristicas,
  ];

  /// Número de filtros ATIVOS (não de valores) — contagem do botão
  /// "Filtros (N)" (D-15, D-16).
  int get quantidadeAtiva => ativos.length;

  /// Devolve uma cópia com a dimensão [filtro] limpa — usado pelo "x" do
  /// chip (D-17). `preco`/`area` limpam os dois extremos da faixa; limpar
  /// `finalidade` TAMBÉM limpa a faixa de preço (D-03): uma faixa sem
  /// finalidade não tem escala (`preco_venda` vs. `preco_aluguel`).
  FiltrosVitrine semFiltro(FiltroAtivo filtro) => switch (filtro) {
    FiltroAtivo.finalidade => copyWith(
      finalidade: null,
      precoMin: null,
      precoMax: null,
    ),
    FiltroAtivo.naturezas => copyWith(naturezas: const {}),
    FiltroAtivo.preco => copyWith(precoMin: null, precoMax: null),
    FiltroAtivo.quartos => copyWith(quartosMin: null),
    FiltroAtivo.suites => copyWith(suitesMin: null),
    FiltroAtivo.vagas => copyWith(vagasMin: null),
    FiltroAtivo.bairros => copyWith(bairros: const {}),
    FiltroAtivo.area => copyWith(areaMin: null, areaMax: null),
    FiltroAtivo.caracteristicas => copyWith(caracteristicas: const {}),
  };
}
