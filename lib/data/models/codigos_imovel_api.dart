/// Único lugar do app que traduz os códigos de finalidade e de situação do
/// Django para os enums do domínio.
///
/// O acervo, o imóvel de gestão e o histórico de situação leem daqui, então o
/// chip do acervo, a situação da tela de gestão e o histórico nunca discordam
/// sobre o mesmo código do servidor. O sentido inverso (enum → código, usado no
/// envio) continua em `codigoDaSituacao`
/// (`data/datasources/parametros_consulta_acervo.dart`).
///
/// Aqui só se traduz: nenhum valor padrão é inventado e nenhuma regra de
/// negócio entra (a decisão é sempre do servidor).
library;

import '../../domain/entities/imovel.dart';
import '../../domain/entities/situacao_imovel.dart';

/// Traduz o código de finalidade do servidor. Código desconhecido lança
/// [FormatException]: os repositórios convertem em falha genérica (T-08-33).
FinalidadeImovel finalidadeDoCodigo(String codigo) => switch (codigo) {
  'VENDA' => FinalidadeImovel.venda,
  'ALUGUEL' => FinalidadeImovel.aluguel,
  'VENDA_E_ALUGUEL' => FinalidadeImovel.vendaEAluguel,
  _ => throw FormatException('finalidade desconhecida: $codigo'),
};

/// Traduz o código de situação do servidor. Código desconhecido ou nulo vira
/// `null` (nunca um valor padrão), para que uma situação nova no servidor não
/// derrube a tela (T-09-10).
SituacaoImovel? situacaoDoCodigo(String? codigo) => switch (codigo) {
  'DISPONIVEL' => SituacaoImovel.disponivel,
  'RESERVADO' => SituacaoImovel.reservado,
  'VENDIDO' => SituacaoImovel.vendido,
  'ALUGADO' => SituacaoImovel.alugado,
  _ => null,
};
