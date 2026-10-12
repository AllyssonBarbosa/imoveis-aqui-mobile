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
  }) = DadosApartamento;

  /// [preco] só existe quando o servidor manda; nunca é derivado do preço da
  /// parte comum (D-19 d).
  const factory DadosNatureza.lote({
    String? numero,
    String? area,
    String? frente,
    String? fundo,
    String? preco,
    String? condicoesParcelamento,
  }) = DadosLote;
}
