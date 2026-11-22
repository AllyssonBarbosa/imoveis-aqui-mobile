import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/papel.dart';

part 'login_state.freezed.dart';

/// Estado do login. Nenhum estado carrega e-mail ou senha: os campos vivem só
/// nos controladores da tela e seguem direto para o use case.
@freezed
sealed class LoginState with _$LoginState {
  /// Formulário pronto para digitar.
  const factory LoginState.editando() = LoginEditando;

  /// Pedido em curso: o botão fica desabilitado e mostra o carregamento.
  const factory LoginState.enviando() = LoginEnviando;

  /// Falha com a [mensagem] fixa do app (D-03, D-04).
  const factory LoginState.falha({required String mensagem}) = LoginFalha;

  /// Login concluído; a tela escolhe a área pelo [papel] (D-02).
  const factory LoginState.entrou(Papel papel) = LoginEntrou;
}
