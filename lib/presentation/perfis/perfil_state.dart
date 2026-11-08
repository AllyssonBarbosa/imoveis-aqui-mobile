import 'package:freezed_annotation/freezed_annotation.dart';

part 'perfil_state.freezed.dart';

/// Estado de um perfil público — união selada do ciclo de carregamento. O
/// perfil do corretor e o da empresa compartilham a mesma forma, por isso é
/// genérico em [T] (o dado carregado). A tela faz `switch` exaustivo, sem
/// ramo abrangente.
@freezed
sealed class PerfilState<T> with _$PerfilState<T> {
  const factory PerfilState.carregando() = PerfilCarregando<T>;

  const factory PerfilState.carregado(T dados) = PerfilCarregado<T>;

  const factory PerfilState.erro() = PerfilErro<T>;
}
