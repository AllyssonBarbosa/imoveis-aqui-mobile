import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/pagina_acervo.dart';
import 'imovel_acervo_model.dart';

part 'acervo_envelope_model.freezed.dart';
part 'acervo_envelope_model.g.dart';

/// Envelope `PageNumberPagination` de `GET /api/imoveis/` (acervo do
/// corretor, §14): `count` é ignorado; `next` é uma URL absoluta ou nulo —
/// não-genérico de propósito, como `ImoveisEnvelopeModel`.
@freezed
abstract class AcervoEnvelopeModel with _$AcervoEnvelopeModel {
  const AcervoEnvelopeModel._();

  const factory AcervoEnvelopeModel({
    String? next,
    String? previous,
    required List<ImovelAcervoModel> results,
  }) = _AcervoEnvelopeModel;

  factory AcervoEnvelopeModel.fromJson(Map<String, Object?> json) =>
      _$AcervoEnvelopeModelFromJson(json);

  /// Mapeia para a página de domínio — `next` continua opaco, nunca
  /// interpretado fora da camada `data/`.
  PaginaAcervo paraPagina() => PaginaAcervo(
    itens: results.map((modelo) => modelo.paraEntidade()).toList(),
    proximaPagina: next,
  );
}
