import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/papel.dart';
import '../repositories/autenticacao_repository.dart';

/// Faz o login e já descobre o papel do usuário (D-02).
///
/// Sequência: `entrar` (guarda o token) → `obterPapel`. Se o papel falhar, o
/// token recém-guardado é descartado (rollback) e a falha do papel é
/// devolvida: o botão do topo nunca fica em "Meu acervo" sem um papel.
///
/// O rollback nunca lança: `descartarSessaoLocal()` não lança por contrato do
/// repositório, mesmo com o armazenamento seguro falhando ao apagar.
@injectable
class EntrarUseCase {
  EntrarUseCase(this._repositorio);

  final AutenticacaoRepository _repositorio;

  Future<Result<Papel>> call({
    required String email,
    required String senha,
  }) async {
    final login = await _repositorio.entrar(email: email, senha: senha);
    if (login is Failure<void>) {
      return Result.failure(login.erro);
    }

    final papel = await _repositorio.obterPapel();
    if (papel is Failure<Papel>) {
      await _repositorio.descartarSessaoLocal();
    }
    return papel;
  }
}
