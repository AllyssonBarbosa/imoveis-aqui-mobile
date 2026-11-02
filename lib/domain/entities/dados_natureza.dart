import 'package:freezed_annotation/freezed_annotation.dart';

part 'dados_natureza.freezed.dart';

/// Relevo de um terreno, como o servidor o classifica.
enum Topografia { plano, aclive, declive }

/// Dados próprios da natureza do imóvel (DET-04, D-02): exatamente uma das
/// quatro variantes, escolhida pelo discriminador `natureza` do detalhe.
///
/// Todos os campos são opcionais (D-14): campo nulo some da tela. Áreas,
/// medidas e valores são strings decimais do servidor, nunca parseadas nem
/// recalculadas no app (D-04) — em especial [DadosCasa.areaLivre], que chega
/// pronta da API.
@freezed
sealed class DadosNatureza with _$DadosNatureza {
  const factory DadosNatureza.casa({
    String? areaTerreno,
    String? areaConstruida,
    String? areaLivre,
    int? quartos,
    int? suites,
    int? banheiros,
    int? salas,
    int? vagas,
    int? pavimentos,
    int? anoConstrucao,
    bool? piscina,
    bool? quintal,
    bool? churrasqueira,
    bool? mobiliada,
  }) = DadosCasa;

  const factory DadosNatureza.terreno({
    String? areaTotal,
    String? frente,
    String? fundo,
    String? laterais,
    Topografia? topografia,
    bool? murado,
    bool? esquina,
    String? usoPermitido,
  }) = DadosTerreno;

  /// [posicaoSolar] é o texto que a API manda, mostrado como veio (D-19 b).
  const factory DadosNatureza.apartamento({
    int? andar,
    String? numero,
    String? areaPrivativa,
    String? areaTotal,
    int? quartos,
    int? suites,
    int? banheiros,
    int? vagas,
    bool? varanda,
    String? posicaoSolar,

    /// Prédio embutido no detalhe (D-03), sem chamada extra.
    DadosPredio? predio,
  }) = DadosApartamento;

  /// O preço do lote é o preço de venda do imóvel, mostrado no cabeçalho
  /// (§11.5 d): o bloco do lote não tem preço próprio. [entradaMinima] é a
  /// string decimal do servidor e [parcelasMaximas] o inteiro como veio.
  const factory DadosNatureza.lote({
    String? numero,
    String? area,
    String? frente,
    String? fundo,
    String? entradaMinima,
    int? parcelasMaximas,
    String? condicoesParcelamento,

    /// Quadra com o loteamento embutidos no detalhe (D-03).
    DadosQuadra? quadra,
  }) = DadosLote;
}

/// Prédio do apartamento (WEB 06), embutido em [DadosApartamento].
@freezed
abstract class DadosPredio with _$DadosPredio {
  const factory DadosPredio({
    String? nome,
    int? andares,
    int? unidadesPorAndar,
    int? ano,
    int? elevadores,
    bool? portaria24h,
    bool? piscina,
    bool? academia,
    bool? salaoDeFestas,
    bool? playground,
  }) = _DadosPredio;
}

/// Quadra do lote (WEB 07), embutida em [DadosLote].
@freezed
abstract class DadosQuadra with _$DadosQuadra {
  const factory DadosQuadra({
    String? identificacao,
    DadosLoteamento? loteamento,
  }) = _DadosQuadra;
}

/// Loteamento da quadra. [infraestrutura] são os rótulos dos itens que o
/// servidor marcou como verdadeiros (tradução feita em data/); [areasDeLazer]
/// é o texto corrido do servidor, nunca dividido no app.
@freezed
abstract class DadosLoteamento with _$DadosLoteamento {
  const factory DadosLoteamento({
    String? nome,
    String? incorporadora,
    @Default(<String>[]) List<String> infraestrutura,
    String? areasDeLazer,
  }) = _DadosLoteamento;
}
