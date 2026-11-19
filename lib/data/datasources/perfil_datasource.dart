import '../models/perfil_corretor_model.dart';
import '../models/perfil_empresa_model.dart';

/// Caminho do endpoint público do perfil do corretor (WEB 02). O `id` é sempre
/// um inteiro, nunca texto do usuário, e o caminho termina em barra.
String caminhoPerfilCorretor(int id) => '/api/publico/corretores/$id/';

/// Caminho do endpoint público do perfil da empresa (WEB 02), com a mesma
/// disciplina de [caminhoPerfilCorretor]: só um `int` entra no caminho.
String caminhoPerfilEmpresa(int id) => '/api/publico/empresas/$id/';

/// Fronteira de dados dos perfis públicos, implementada pela
/// `PerfilRemoteDataSource` (Dio). `domain/` e `presentation/` só conhecem
/// esta interface.
abstract class PerfilDataSource {
  /// Busca o perfil do corretor [id]. Lança `DioException` 404 quando o
  /// corretor não existe, não é corretor ou está desativado; o repositório
  /// traduz para `PerfilNaoEncontradoException`.
  Future<PerfilCorretorModel> buscarCorretor(int id);

  /// Busca o perfil da empresa [id]. Lança `DioException` 404 quando a empresa
  /// não existe ou está inativa; o repositório traduz para
  /// `PerfilNaoEncontradoException`.
  Future<PerfilEmpresaModel> buscarEmpresa(int id);
}
