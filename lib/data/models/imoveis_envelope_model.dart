import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/pagina_imoveis.dart';
import 'imovel_model.dart';

part 'imoveis_envelope_model.freezed.dart';
part 'imoveis_envelope_model.g.dart';

/// Envelope `CursorPagination` de `GET /imoveis` (§4 do contrato) —
/// não-genérico de propósito (RESEARCH Pitfall 5: freezed genérico +
/// json_serializable exige boilerplate de `genericArgumentFactories`).
@freezed
abstract class ImoveisEnvelopeModel with _$ImoveisEnvelopeModel {
  const ImoveisEnvelopeModel._();

  const factory ImoveisEnvelopeModel({
    String? next,
    String? previous,
    required List<ImovelModel> results,
  }) = _ImoveisEnvelopeModel;

  factory ImoveisEnvelopeModel.fromJson(Map<String, Object?> json) =>
      _$ImoveisEnvelopeModelFromJson(json);

  /// Mapeia para a página de domínio (API-04) — `next` continua opaco, nunca
  /// interpretado fora da camada `data/`.
  PaginaImoveis paraPagina() => PaginaImoveis(
    itens: results.map((modelo) => modelo.paraEntidade()).toList(),
    proximaPagina: next,
  );
}
