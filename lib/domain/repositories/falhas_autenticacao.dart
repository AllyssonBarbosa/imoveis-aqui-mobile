/// O servidor recusou o token (401): sessão expirada ou revogada. A camada de
/// dados traduz o 401 do cliente autenticado para esta exceção, então quem
/// está acima decide só pelo tipo — sem `try/catch` genérico na UI.
class SessaoExpiradaException implements Exception {
  const SessaoExpiradaException();

  @override
  String toString() => 'Sessão expirada ou revogada.';
}

/// O login foi recusado (400): e-mail ou senha não conferem. Não carrega o
/// texto do servidor — a tela escolhe a mensagem só pelo tipo, e a mesma
/// mensagem vale para e-mail inexistente e senha errada (D-03, AC-3).
class CredenciaisInvalidasException implements Exception {
  const CredenciaisInvalidasException();

  @override
  String toString() => 'E-mail ou senha inválidos.';
}

/// Muitas tentativas de login (429). [aguardar] é o `Retry-After` do servidor
/// em segundos, ou nulo se o servidor não mandou um valor válido.
class LimiteTentativasException implements Exception {
  const LimiteTentativasException({this.aguardar});

  final Duration? aguardar;

  @override
  String toString() => 'Limite de tentativas atingido.';
}

/// Falha de rede, tempo esgotado, erro 5xx ou qualquer resposta inesperada: o
/// caminho feliz não completou e tentar de novo pode resolver.
class FalhaDeConexaoException implements Exception {
  const FalhaDeConexaoException();

  @override
  String toString() => 'Falha de conexão com o servidor.';
}

/// O servidor entendeu o pedido mas o usuário não tem permissão (403).
class SemPermissaoException implements Exception {
  const SemPermissaoException();

  @override
  String toString() => 'Sem permissão para esta ação.';
}
