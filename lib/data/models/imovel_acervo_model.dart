import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/imovel_acervo.dart';
import 'codigos_imovel_api.dart';
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

  /// Mapeia para a entidade de domínio. Finalidade e situação passam pelo mapa
  /// único de `codigos_imovel_api.dart`: `finalidade` desconhecida lança
  /// [FormatException] (o repositório converte em falha, T-08-33);
  /// `situacao` desconhecida ou nula vira `null`; `fotoCapa` fora de http(s)
  /// vira `null` (T-08-31).
  ImovelAcervo paraEntidade() {
    return ImovelAcervo(
      id: id,
      codigo: codigo,
      titulo: titulo,
      finalidade: finalidadeDoCodigo(finalidade),
      precoVenda: precoVenda,
      precoAluguel: precoAluguel,
      fotoCapa: urlHttpOuNula(fotoCapa),
      situacao: situacaoDoCodigo(situacao),
      meuImovel: meuImovel,
      naVitrine: naVitrine,
    );
  }
}
