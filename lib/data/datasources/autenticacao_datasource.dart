import '../models/eu_model.dart';

/// Fonte das três rotas de autenticação da API (`/api/auth/`). Cada método diz
/// qual cliente HTTP usa: o login vai pelo `Dio` público (nunca leva
/// `Authorization`); `eu` e `sair` vão pelo `Dio` `'autenticado'`.
abstract class AutenticacaoDataSource {
  /// `POST /api/auth/login/` pelo `Dio` público. Devolve só o token.
  Future<String> entrar({required String email, required String senha});

  /// `GET /api/auth/eu/` pelo `Dio` autenticado.
  Future<EuModel> obterEu();

  /// `POST /api/auth/sair/` pelo `Dio` autenticado (revoga o token no
  /// servidor).
  Future<void> sair();
}
