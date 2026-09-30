// Funções puras de apresentação dos filtros (D-15, D-16) — a conversão de
// FiltrosVitrine para texto fica FORA do widget, mesma disciplina de
// `apresentacao_imovel.dart`.

import 'package:intl/intl.dart';

import '../../domain/entities/filtros_vitrine.dart';
import '../../domain/entities/imovel.dart';

/// Rótulo do botão "Filtros" (D-15) — 'Filtros' sem contagem quando nenhum
/// filtro está ativo, ou 'Filtros (N)' com o número de filtros ATIVOS (não
/// de valores, D-16) — a mesma fonte que os chips usam.
String rotuloBotaoFiltros(int quantidade) {
  if (quantidade == 0) return 'Filtros';
  return 'Filtros ($quantidade)';
}

/// Um chip resumido: a dimensão que ele representa + o rótulo já formatado.
/// Const e com igualdade por valor — comparável em teste sem depender de
/// identidade.
class ChipDeFiltro {
  const ChipDeFiltro({required this.filtro, required this.rotulo});

  final FiltroAtivo filtro;
  final String rotulo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChipDeFiltro &&
          other.filtro == filtro &&
          other.rotulo == rotulo);

  @override
  int get hashCode => Object.hash(filtro, rotulo);

  @override
  String toString() => 'ChipDeFiltro(filtro: $filtro, rotulo: $rotulo)';
}

/// Um chip por dimensão ATIVA de [filtros], na ordem de
/// [FiltrosVitrine.ativos] (D-16) — TODAS as nove dimensões são rotuladas
/// aqui, mesmo as que ainda não têm controle no sheet (planos 03-03..03-05
/// só precisam expor o controle, o rótulo já existe).
List<ChipDeFiltro> chipsDosFiltros(FiltrosVitrine filtros) {
  return [
    for (final filtro in filtros.ativos)
      ChipDeFiltro(filtro: filtro, rotulo: _rotuloDoFiltro(filtro, filtros)),
  ];
}

String _rotuloDoFiltro(FiltroAtivo filtro, FiltrosVitrine filtros) =>
    switch (filtro) {
      FiltroAtivo.finalidade => _rotuloFinalidade(filtros.finalidade!),
      FiltroAtivo.naturezas => _rotuloNaturezas(filtros.naturezas),
      FiltroAtivo.preco => _rotuloPreco(filtros),
      FiltroAtivo.quartos => _rotuloMinimo(
        filtros.quartosMin!,
        'quarto',
        'quartos',
      ),
      FiltroAtivo.suites => _rotuloMinimo(
        filtros.suitesMin!,
        'suíte',
        'suítes',
      ),
      FiltroAtivo.vagas => _rotuloMinimo(filtros.vagasMin!, 'vaga', 'vagas'),
      FiltroAtivo.bairros => _rotuloMultiSelecao(filtros.bairros),
      FiltroAtivo.area => _rotuloArea(filtros),
      FiltroAtivo.caracteristicas => _rotuloMultiSelecao(
        filtros.caracteristicas,
      ),
    };

String _rotuloFinalidade(FinalidadeFiltro finalidade) => switch (finalidade) {
  FinalidadeFiltro.venda => 'Venda',
  FinalidadeFiltro.aluguel => 'Aluguel',
};

/// Ordem do ENUM (`NaturezaImovel.values`), nunca a ordem de iteração do
/// `Set` — determinístico independente de como o Set foi construído.
String _rotuloNaturezas(Set<NaturezaImovel> naturezas) {
  return NaturezaImovel.values
      .where(naturezas.contains)
      .map(_rotuloNaturezaAbreviado)
      .join(', ');
}

String _rotuloNaturezaAbreviado(NaturezaImovel natureza) => switch (natureza) {
  NaturezaImovel.casa => 'Casa',
  NaturezaImovel.apartamento => 'Apto',
  NaturezaImovel.terreno => 'Terreno',
  NaturezaImovel.lote => 'Lote',
};

/// "R$ 200 mil–500 mil" (faixa), "A partir de R$ 200 mil" (só mín), "Até
/// R$ 500 mil" (só máx) — com "/mês" no fim quando a finalidade é aluguel
/// (D-03).
String _rotuloPreco(FiltrosVitrine filtros) {
  final sufixo = filtros.finalidade == FinalidadeFiltro.aluguel ? '/mês' : '';
  final min = filtros.precoMin;
  final max = filtros.precoMax;
  if (min != null && max != null) {
    return 'R\$ ${formatarValorCompacto(min)}–${formatarValorCompacto(max)}'
        '$sufixo';
  }
  if (min != null) {
    return 'A partir de R\$ ${formatarValorCompacto(min)}$sufixo';
  }
  return 'Até R\$ ${formatarValorCompacto(max!)}$sufixo';
}

/// "50–120 m²" (faixa), "A partir de 50 m²" (só mín), "Até 120 m²" (só
/// máx) — sem compactação (área não usa "mil"/"mi", só R$ usa).
String _rotuloArea(FiltrosVitrine filtros) {
  final min = filtros.areaMin;
  final max = filtros.areaMax;
  if (min != null && max != null) return '$min–$max m²';
  if (min != null) return 'A partir de $min m²';
  return 'Até $max m²';
}

/// "N+ quartos" / "1+ quarto" (singular/plural corretos para 1) — D-01.
String _rotuloMinimo(int valor, String singular, String plural) {
  final unidade = valor == 1 ? singular : plural;
  return '$valor+ $unidade';
}

/// "Cambuí" (um só valor) ou "Cambuí +1" (demais, contados) — mesma forma
/// para bairros e características.
String _rotuloMultiSelecao(Set<String> valores) {
  final primeiro = valores.first;
  final resto = valores.length - 1;
  return resto == 0 ? primeiro : '$primeiro +$resto';
}

/// 950 -> '950'; 1000 -> '1 mil'; 3500 -> '3,5 mil'; 200000 -> '200 mil';
/// 1000000 -> '1 mi'; 1200000 -> '1,2 mi' — no máximo uma casa decimal,
/// vírgula pt_BR, sem separador de milhar (o valor dividido nunca chega a
/// 1000 nesta escala de preço/faixa).
String formatarValorCompacto(int valor) {
  if (valor >= 1000000) {
    return '${_umaCasaDecimal(valor / 1000000)} mi';
  }
  if (valor >= 1000) {
    return '${_umaCasaDecimal(valor / 1000)} mil';
  }
  return '$valor';
}

String _umaCasaDecimal(double valor) =>
    NumberFormat('#,##0.#', 'pt_BR').format(valor);
