import '../../core/result.dart';
import '../entities/perfil_corretor.dart';

/// Contrato de falha dos perfis públicos para o 404 da WEB 02 — corretor
/// inexistente, que não é corretor ou desativado; empresa inexistente ou
/// inativa. A camada de dados traduz o 404 do servidor para esta exceção
/// (D-04), então quem está acima decide só pelo tipo.
class PerfilNaoEncontradoException implements Exception {
  const PerfilNaoEncontradoException();

  @override
  String toString() => 'Perfil não encontrado ou desativado.';
}

/// Fronteira de domínio dos perfis públicos (PERF-04). Nesta fatia só o
/// corretor; a empresa entra junto com o seu perfil.
abstract class PerfilRepository {
  Future<Result<PerfilCorretor>> buscarCorretor(int id);
}
