import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/usecases/entrar_usecase.dart';
import 'apresentacao_login.dart';
import 'login_state.dart';

/// Faz o login do corretor: `enviando` e depois `entrou(papel)` ou
/// `falha(mensagem)` com o texto fixo do app. Não guarda e-mail nem senha.
@injectable
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._entrar) : super(const LoginState.editando());

  final EntrarUseCase _entrar;

  /// Envia as credenciais como digitadas (a senha nunca passa por `trim`).
  /// Um segundo toque durante o envio é ignorado, para não contar duas
  /// tentativas no limite do servidor.
  Future<void> entrar({required String email, required String senha}) async {
    if (isClosed || state is LoginEnviando) return;
    emit(const LoginState.enviando());
    final resultado = await _entrar(email: email, senha: senha);
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        emit(LoginState.entrou(data));
      case Failure(:final erro):
        emit(LoginState.falha(mensagem: mensagemDeFalhaDoLogin(erro)));
      case Loading():
        break;
    }
  }
}
