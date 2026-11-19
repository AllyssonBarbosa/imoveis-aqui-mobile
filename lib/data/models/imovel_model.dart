import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel.dart';
import 'url_segura.dart';

part 'imovel_model.freezed.dart';
part 'imovel_model.g.dart';

/// Modelo de transporte para um item de
/// `GET /api/publico/cidades/<id>/imoveis/` (W09, D-17). A lista não manda
/// descrição, cidade, características nem data de criação, então o modelo
/// não os declara; chaves a mais (ex.: `preco_condominio`) são ignoradas. O
/// `bairro` pode vir nulo (`bairro_anuncio` vazio) e vira `''` na entidade.
@freezed
abstract class ImovelModel with _$ImovelModel {
  const ImovelModel._();

  const factory ImovelModel({
    required int id,
    required String titulo,
    required String finalidade,
    @JsonKey(name: 'preco_venda') String? precoVenda,
    @JsonKey(name: 'preco_aluguel') String? precoAluguel,
    String? bairro,
    @JsonKey(name: 'foto_capa') String? fotoCapa,
    String? natureza,
    int? quartos,
    int? suites,
    int? vagas,
    String? area,
  }) = _ImovelModel;

  factory ImovelModel.fromJson(Map<String, Object?> json) =>
      _$ImovelModelFromJson(json);

  /// Mapeia para a entidade de domínio. `bairro` nulo vira `''`;
  /// `finalidade` desconhecida lança
  /// [FormatException] — o repositório converte em `Result.failure`
  /// (T-02-01-01); `natureza` desconhecida ou ausente vira `null`;
  /// `fotoCapa` fora de http(s) vira `null` (V12/V13).
  Imovel paraEntidade() {
    return Imovel(
      id: id,
      titulo: titulo,
      finalidade: _mapearFinalidade(finalidade),
      precoVenda: precoVenda,
      precoAluguel: precoAluguel,
      bairro: bairro ?? '',
      fotoCapa: urlHttpOuNula(fotoCapa),
      natureza: _mapearNatureza(natureza),
      quartos: quartos,
    );
  }

  static FinalidadeImovel _mapearFinalidade(String valor) {
    switch (valor) {
      case 'VENDA':
        return FinalidadeImovel.venda;
      case 'ALUGUEL':
        return FinalidadeImovel.aluguel;
      case 'VENDA_E_ALUGUEL':
        return FinalidadeImovel.vendaEAluguel;
      default:
        throw FormatException('finalidade desconhecida: $valor');
    }
  }

  static NaturezaImovel? _mapearNatureza(String? valor) {
    switch (valor) {
      case 'CASA':
        return NaturezaImovel.casa;
      case 'APARTAMENTO':
        return NaturezaImovel.apartamento;
      case 'TERRENO':
        return NaturezaImovel.terreno;
      case 'LOTE':
        return NaturezaImovel.lote;
      default:
        return null;
    }
  }
}
