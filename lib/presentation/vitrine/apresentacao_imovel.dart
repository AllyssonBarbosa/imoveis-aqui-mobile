import 'package:intl/intl.dart';

import '../../domain/entities/imovel.dart';

/// Funções puras de apresentação do imóvel (D-03) — a conversão
/// string->número/formato fica FORA do widget, nunca no `ImovelCard`. Nenhuma
/// dessas funções calcula/decide preço: só apresenta o que já veio pronto do
/// servidor.

/// Formata uma string decimal do servidor em BRL (`pt_BR`), sem centavos
/// quando o valor é inteiro ("R$ 450.000") e com centavos quando não é
/// ("R$ 450.000,50", RESEARCH Pitfall 7). Um valor não-parseável é devolvido
/// sem alteração — nunca lança (T-02-01-02).
String formatarPrecoBrl(String valorDecimal) {
  final valor = double.tryParse(valorDecimal);
  if (valor == null) return valorDecimal;

  final temCentavos = valor % 1 != 0;
  final formatador = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: temCentavos ? 2 : 0,
  );
  return formatador.format(valor);
}

/// Linhas de preço do card (D-02): `VENDA_E_ALUGUEL` mostra os dois preços
/// empilhados com prefixo; `VENDA`/`ALUGUEL` mostram só o preço
/// correspondente (aluguel com sufixo "/mês"); nenhum preço disponível vira
/// "Preço sob consulta".
List<String> linhasDePreco(Imovel imovel) {
  final linhas = <String>[];

  switch (imovel.finalidade) {
    case FinalidadeImovel.venda:
      if (imovel.precoVenda != null) {
        linhas.add(formatarPrecoBrl(imovel.precoVenda!));
      }
    case FinalidadeImovel.aluguel:
      if (imovel.precoAluguel != null) {
        linhas.add('${formatarPrecoBrl(imovel.precoAluguel!)}/mês');
      }
    case FinalidadeImovel.vendaEAluguel:
      if (imovel.precoVenda != null) {
        linhas.add('Venda ${formatarPrecoBrl(imovel.precoVenda!)}');
      }
      if (imovel.precoAluguel != null) {
        linhas.add('Aluguel ${formatarPrecoBrl(imovel.precoAluguel!)}/mês');
      }
  }

  if (linhas.isEmpty) return const ['Preço sob consulta'];
  return linhas;
}

/// Rótulo em PT da natureza do imóvel — `null` quando o campo ainda não veio
/// preenchido (PENDENTE E2) ou é desconhecido.
String? rotuloNatureza(NaturezaImovel? natureza) {
  return switch (natureza) {
    NaturezaImovel.casa => 'Casa',
    NaturezaImovel.apartamento => 'Apartamento',
    NaturezaImovel.terreno => 'Terreno',
    NaturezaImovel.lote => 'Lote',
    null => null,
  };
}

/// Rótulo em PT da quantidade de quartos — `null` quando ausente ou zero
/// (nada para mostrar), singular/plural corretos para 1.
String? rotuloQuartos(int? quartos) {
  if (quartos == null || quartos == 0) return null;
  return quartos == 1 ? '1 quarto' : '$quartos quartos';
}
