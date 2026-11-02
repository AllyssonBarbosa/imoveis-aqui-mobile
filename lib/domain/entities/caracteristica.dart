import 'package:freezed_annotation/freezed_annotation.dart';

part 'caracteristica.freezed.dart';

/// Característica do imóvel (piscina, churrasqueira...) do catálogo do
/// servidor (D-13). O filtro guarda o [id]; o [nome] é só para mostrar.
/// Igualdade por valor nos dois campos.
@freezed
abstract class Caracteristica with _$Caracteristica {
  const factory Caracteristica({
    required int id,
    required String nome,
  }) = _Caracteristica;
}
