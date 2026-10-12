import 'package:intl/intl.dart';

import '../../domain/entities/cidade.dart';
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

/// Linhas de preço do card (D-02): delega a [linhasDePrecoPorFinalidade].
List<String> linhasDePreco(Imovel imovel) => linhasDePrecoPorFinalidade(
  finalidade: imovel.finalidade,
  precoVenda: imovel.precoVenda,
  precoAluguel: imovel.precoAluguel,
);

/// Linhas de preço a partir dos campos soltos — compartilhada pelo card da
/// vitrine (via [linhasDePreco]) e pelo cabeçalho do detalhe: `VENDA_E_ALUGUEL`
/// mostra os dois preços empilhados com prefixo; `VENDA`/`ALUGUEL` mostram só o
/// preço correspondente (aluguel com sufixo "/mês"); nenhum preço disponível
/// vira "Preço sob consulta". Só formata, nunca calcula.
List<String> linhasDePrecoPorFinalidade({
  required FinalidadeImovel finalidade,
  String? precoVenda,
  String? precoAluguel,
}) {
  final linhas = <String>[];

  switch (finalidade) {
    case FinalidadeImovel.venda:
      if (precoVenda != null) {
        linhas.add(formatarPrecoBrl(precoVenda));
      }
    case FinalidadeImovel.aluguel:
      if (precoAluguel != null) {
        linhas.add('${formatarPrecoBrl(precoAluguel)}/mês');
      }
    case FinalidadeImovel.vendaEAluguel:
      if (precoVenda != null) {
        linhas.add('Venda ${formatarPrecoBrl(precoVenda)}');
      }
      if (precoAluguel != null) {
        linhas.add('Aluguel ${formatarPrecoBrl(precoAluguel)}/mês');
      }
  }

  if (linhas.isEmpty) return const ['Preço sob consulta'];
  return linhas;
}

/// Localização do imóvel: "bairro · cidade, UF"; o bairro é omitido quando
/// vazio.
String rotuloLocalizacao(String bairro, Cidade cidade) {
  return [
    bairro,
    '${cidade.nome}, ${cidade.uf}',
  ].where((texto) => texto.isNotEmpty).join(' · ');
}

/// Linhas de custo do detalhe: "Condomínio R$ X/mês" (condomínio é mensal por
/// natureza) e "IPTU R$ Y" — o período do IPTU está PENDENTE E2 (§11 item c),
/// então o app não afirma "/mês" nem "/ano". Cada linha só aparece quando o
/// valor veio; apenas formata, nunca soma nem converte período.
List<String> linhasDeCustos({String? precoCondominio, String? precoIptu}) {
  return [
    if (precoCondominio != null)
      'Condomínio ${formatarPrecoBrl(precoCondominio)}/mês',
    if (precoIptu != null) 'IPTU ${formatarPrecoBrl(precoIptu)}',
  ];
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
