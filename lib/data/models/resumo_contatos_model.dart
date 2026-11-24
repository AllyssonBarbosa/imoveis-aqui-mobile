import 'package:freezed_annotation/freezed_annotation.dart';

part 'resumo_contatos_model.freezed.dart';
part 'resumo_contatos_model.g.dart';

/// Modelo de transporte de `GET /api/contatos/resumo/` (§17.4): só
/// `sem_retorno`, a contagem de contatos ainda sem retorno, calculada pelo
/// Django sobre a caixa inteira (D-05). O app apenas lê o número.
@freezed
abstract class ResumoContatosModel with _$ResumoContatosModel {
  const factory ResumoContatosModel({
    @JsonKey(name: 'sem_retorno') required int semRetorno,
  }) = _ResumoContatosModel;

  factory ResumoContatosModel.fromJson(Map<String, Object?> json) =>
      _$ResumoContatosModelFromJson(json);
}
