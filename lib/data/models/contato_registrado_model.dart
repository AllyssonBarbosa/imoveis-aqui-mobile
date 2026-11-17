import 'package:freezed_annotation/freezed_annotation.dart';

part 'contato_registrado_model.freezed.dart';
part 'contato_registrado_model.g.dart';

/// Modelo de transporte da resposta 201 de
/// `POST /api/publico/imoveis/{id}/contato/` (W11): o canal registrado e o
/// link pronto para abrir (`https://wa.me/...`, `tel:...` ou `mailto:...`).
///
/// O [link] carrega o código interno do imóvel e a mensagem do visitante, então
/// ele só é aberto: nunca é registrado em log, exibido, guardado nem
/// reconstruído. Por isso o `toString()` não o inclui.
@freezed
abstract class ContatoRegistradoModel with _$ContatoRegistradoModel {
  const ContatoRegistradoModel._();

  const factory ContatoRegistradoModel({
    required String canal,
    required String link,
  }) = _ContatoRegistradoModel;

  factory ContatoRegistradoModel.fromJson(Map<String, Object?> json) =>
      _$ContatoRegistradoModelFromJson(json);

  @override
  String toString() => 'ContatoRegistradoModel(canal: $canal)';
}
