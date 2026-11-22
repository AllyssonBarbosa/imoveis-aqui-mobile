import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/papel.dart';

part 'eu_model.freezed.dart';
part 'eu_model.g.dart';

/// Modelo de transporte de `GET /api/auth/eu/`: só o `perfil` (papel) do
/// usuário logado. Qualquer outra chave é ignorada — o app não guarda dado
/// pessoal do corretor além do necessário.
@freezed
abstract class EuModel with _$EuModel {
  const EuModel._();

  const factory EuModel({required String perfil}) = _EuModel;

  factory EuModel.fromJson(Map<String, Object?> json) =>
      _$EuModelFromJson(json);

  /// Converte o `perfil` do wire em [Papel]. Valor desconhecido lança
  /// [FormatException]: o app não adivinha papel (T-08-28); quem desfaz a
  /// sessão é o `EntrarUseCase`.
  Papel paraPapel() => switch (perfil) {
    'CORRETOR' => Papel.corretor,
    'GESTOR' => Papel.gestor,
    'ADMINISTRADOR' => Papel.administrador,
    _ => throw FormatException('perfil desconhecido: $perfil'),
  };
}
