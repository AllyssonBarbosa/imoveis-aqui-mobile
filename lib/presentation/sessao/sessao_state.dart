import 'package:freezed_annotation/freezed_annotation.dart';

part 'sessao_state.freezed.dart';

/// Estado da sessão do corretor no app (D-C): só o que o botão do topo
/// precisa para escolher o rótulo. O papel não mora aqui — é perguntado ao
/// servidor ao entrar ou ao tocar em "Meu acervo".
@freezed
sealed class SessaoState with _$SessaoState {
  /// O instante antes de ler o aparelho. O botão do topo ocupa o espaço sem
  /// rótulo para não piscar "Entrar" a quem já tem sessão.
  const factory SessaoState.verificando() = SessaoVerificando;

  /// Sem token guardado: o botão do topo mostra "Entrar".
  const factory SessaoState.anonima() = SessaoAnonima;

  /// Há token guardado: o botão do topo mostra "Meu acervo".
  const factory SessaoState.autenticada() = SessaoAutenticada;
}
