import 'package:freezed_annotation/freezed_annotation.dart';

part 'caracteristica_model.freezed.dart';
part 'caracteristica_model.g.dart';

/// Modelo de transporte para uma linha de `GET /api/publico/caracteristicas/`
/// (D-08, D-13): o catálogo vem como `[{id, nome}]`. O `id` é o que o filtro
/// enviará ao servidor (05-15); a promoção para a entidade de domínio chega
/// no 05-13.
@freezed
abstract class CaracteristicaModel with _$CaracteristicaModel {
  const factory CaracteristicaModel({
    required int id,
    required String nome,
  }) = _CaracteristicaModel;

  factory CaracteristicaModel.fromJson(Map<String, Object?> json) =>
      _$CaracteristicaModelFromJson(json);
}
