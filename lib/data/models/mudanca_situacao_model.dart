import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/mudanca_situacao.dart';
import 'codigos_imovel_api.dart';

part 'mudanca_situacao_model.freezed.dart';
part 'mudanca_situacao_model.g.dart';

/// Modelo de transporte de um item de `GET /api/imoveis/{id}/historico/`: só as
/// 6 chaves que o app lê, mais nada (T-09-06). As demais chaves do serializer
/// são ignoradas na desserialização e nunca ficam em memória.
@freezed
abstract class MudancaSituacaoModel with _$MudancaSituacaoModel {
  const MudancaSituacaoModel._();

  const factory MudancaSituacaoModel({
    required int id,
    @JsonKey(name: 'situacao_anterior') String? situacaoAnterior,
    @JsonKey(name: 'situacao_nova') String? situacaoNova,
    @JsonKey(name: 'alterado_por') String? alteradoPor,
    @JsonKey(name: 'alterado_em') required String alteradoEm,
    @Default('') String observacao,
  }) = _MudancaSituacaoModel;

  factory MudancaSituacaoModel.fromJson(Map<String, Object?> json) =>
      _$MudancaSituacaoModelFromJson(json);

  /// Mapeia para a entidade de domínio. As situações passam pelo mapa único de
  /// `codigos_imovel_api.dart`: código desconhecido ou nulo vira `null`
  /// (T-09-10). `alterado_em` é lido como instante UTC (D-05); data inválida
  /// lança [FormatException].
  MudancaSituacao paraEntidade() {
    return MudancaSituacao(
      id: id,
      situacaoAnterior: situacaoDoCodigo(situacaoAnterior),
      situacaoNova: situacaoDoCodigo(situacaoNova),
      alteradoPor: alteradoPor,
      alteradoEm: DateTime.parse(alteradoEm).toUtc(),
      observacao: observacao,
    );
  }
}
