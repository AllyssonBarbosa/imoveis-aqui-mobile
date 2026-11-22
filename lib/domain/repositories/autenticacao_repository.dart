import '../../core/result.dart';
import '../entities/papel.dart';

/// Contrato da autenticação do corretor (AUTH-01, AUTH-02, AUTH-03, AUTH-05).
///
/// Toda falha chega como `Result.failure` com um tipo de
/// `falhas_autenticacao.dart` — nunca com o texto do servidor. E-mail e senha
/// só passam por [entrar]; nada além do token é guardado no aparelho.
abstract class AutenticacaoRepository {
  /// Faz o login e guarda o token no aparelho. Falhas: credenciais inválidas
  /// (400), limite de tentativas (429), conexão e formato.
  Future<Result<void>> entrar({required String email, required String senha});

  /// O papel do usuário logado, lido do servidor. Papel desconhecido vira
  /// `FormatException`; token recusado vira `SessaoExpiradaException`.
  Future<Result<Papel>> obterPapel();

  /// Encerra a sessão: pede a revogação ao servidor (melhor esforço, até 5 s)
  /// e apaga o token do aparelho sempre.
  ///
  /// Nunca lança: tenta apagar o token do aparelho mesmo se a rede ou o
  /// armazenamento falharem (AC-2).
  Future<void> sair();

  /// Verdadeiro se há um token não vazio guardado no aparelho.
  Future<bool> temSessaoGuardada();

  /// Apaga o token do aparelho sem falar com o servidor (sessão expirada,
  /// rollback do login).
  ///
  /// Nunca lança: tenta apagar o token do aparelho mesmo se o armazenamento
  /// falhar.
  Future<void> descartarSessaoLocal();
}
