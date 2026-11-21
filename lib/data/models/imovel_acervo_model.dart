import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel.dart';
import '../../domain/entities/imovel_acervo.dart';
import '../../domain/entities/situacao_imovel.dart';
import 'url_segura.dart';

part 'imovel_acervo_model.freezed.dart';
part 'imovel_acervo_model.g.dart';

/// Modelo de transporte para um item de `GET /api/imoveis/` (acervo do
/// corretor, §14.5): as 10 chaves travadas pelo servidor. `meu_imovel` e
/// `na_vitrine` chegam calculados pelo Django (D-06, D-07) e só são lidos —
/// nenhuma decisão é tomada aqui. Chaves a mais são ignoradas.
@freezed
abstract class ImovelAcervoModel with _$ImovelAcervoModel {
  const ImovelAcervoModel._();

  const factory ImovelAcervoModel({
    required int id,
    required String codigo,
    required String titulo,
    required String finalidade,
    @JsonKey(name: 'preco_venda') String? precoVenda,
    @JsonKey(name: 'preco_aluguel') String? precoAluguel,
    @JsonKey(name: 'foto_capa') String? fotoCapa,
    String? situacao,
    @JsonKey(name: 'meu_imovel') required bool meuImovel,
    @JsonKey(name: 'na_vitrine') required bool naVitrine,
  }) = _ImovelAcervoModel;

  factory ImovelAcervoModel.fromJson(Map<String, Object?> json) =>
      _$ImovelAcervoModelFromJson(json);

  /// Mapeia para a entidade de domínio. `finalidade` desconhecida lança
  /// [FormatException] (o repositório converte em falha, T-08-33);
  /// `situacao` desconhecida ou nula vira `null`; `fotoCapa` fora de http(s)
  /// vira `null` (T-08-31).
  ImovelAcervo paraEntidade() {
    return ImovelAcervo(
      id: id,
      codigo: codigo,
      titulo: titulo,
      finalidade: _mapearFinalidade(finalidade),
      precoVenda: precoVenda,
      precoAluguel: precoAluguel,
      fotoCapa: urlHttpOuNula(fotoCapa),
      situacao: _mapearSituacao(situacao),
      meuImovel: meuImovel,
      naVitrine: naVitrine,
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

  static SituacaoImovel? _mapearSituacao(String? valor) {
    switch (valor) {
      case 'DISPONIVEL':
        return SituacaoImovel.disponivel;
      case 'RESERVADO':
        return SituacaoImovel.reservado;
      case 'VENDIDO':
        return SituacaoImovel.vendido;
      case 'ALUGADO':
        return SituacaoImovel.alugado;
      default:
        return null;
    }
  }
}
