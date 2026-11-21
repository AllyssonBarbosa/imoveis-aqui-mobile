/// O servidor recusou o token (401): sessão expirada ou revogada. A camada de
/// dados traduz o 401 do cliente autenticado para esta exceção, então quem
/// está acima decide só pelo tipo — sem `try/catch` genérico na UI.
class SessaoExpiradaException implements Exception {
  const SessaoExpiradaException();

  @override
  String toString() => 'Sessão expirada ou revogada.';
}
