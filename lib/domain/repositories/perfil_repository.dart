import '../../core/result.dart';
import '../entities/perfil_corretor.dart';
import '../entities/perfil_empresa.dart';

/// Contrato de falha dos perfis públicos para o 404 da WEB 02 — corretor
/// inexistente, que não é corretor ou desativado; empresa inexistente ou
/// inativa. A camada de dados traduz o 404 do servidor para esta exceção
/// (D-04), então quem está acima decide só pelo tipo.
class PerfilNaoEncontradoException implements Exception {
  const PerfilNaoEncontradoException();

  @override
  String toString() => 'Perfil não encontrado ou desativado.';
}

/// Fronteira de domínio dos perfis públicos (PERF-04): corretor e empresa.
abstract class PerfilRepository {
  Future<Result<PerfilCorretor>> buscarCorretor(int id);

  /// Busca o perfil público da empresa [id]; empresa inexistente ou inativa
  /// falha com [PerfilNaoEncontradoException].
  Future<Result<PerfilEmpresa>> buscarEmpresa(int id);
}
