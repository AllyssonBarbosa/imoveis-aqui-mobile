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

  /// Falha de carregamento (rede, servidor, formato) — repetir pode resolver,
  /// então a tela oferece "Tentar de novo".
  const factory PerfilState.erro() = PerfilErro<T>;

  /// 404 da WEB 02: corretor desativado, inexistente ou que não é corretor
  /// (ou empresa inativa) — repetir não resolve, então a tela só oferece o
  /// caminho de volta e não mostra nenhum dado do perfil.
  const factory PerfilState.naoEncontrado() = PerfilNaoEncontrado<T>;
}
