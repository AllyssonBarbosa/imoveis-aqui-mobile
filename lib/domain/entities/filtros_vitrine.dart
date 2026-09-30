import 'package:freezed_annotation/freezed_annotation.dart';

import 'imovel.dart';

part 'filtros_vitrine.freezed.dart';

/// Finalidade escolhida no filtro (FIL-01) — distinto de [FinalidadeImovel]:
/// a UI só oferece Qualquer/Venda/Aluguel (D-02), nunca "venda e aluguel"
/// como opção de filtro (é o SERVIDOR/mock quem aplica a inclusão). `null`
/// em [FiltrosVitrine.finalidade] significa "Qualquer".
enum FinalidadeFiltro { venda, aluguel }

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

  /// Número de filtros ATIVOS (não de valores) — contagem do botão
  /// "Filtros (N)" e fonte única também para os chips (D-15, D-16).
  int get quantidadeAtiva => [
    finalidade != null,
    naturezas.isNotEmpty,
    precoMin != null || precoMax != null,
    quartosMin != null,
    suitesMin != null,
    vagasMin != null,
    bairros.isNotEmpty,
    areaMin != null || areaMax != null,
    caracteristicas.isNotEmpty,
  ].where((ativo) => ativo).length;
}
