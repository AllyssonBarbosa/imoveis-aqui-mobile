import '../models/perfil_corretor_model.dart';

/// Caminho do endpoint público do perfil do corretor (WEB 02). O `id` é sempre
/// um inteiro, nunca texto do usuário, e o caminho termina em barra —
/// reaproveitado tal e qual quando a DataSource remota substituir o mock.
String caminhoPerfilCorretor(int id) => '/api/publico/corretores/$id/';

/// Fronteira trocável mock->real dos perfis públicos. Trocar o servidor
/// simulado pelo remoto é só uma mudança de DI — `domain/` e `presentation/`
/// não são tocados (D-03).
abstract class PerfilDataSource {
  /// Busca o perfil do corretor [id]. Lança `PerfilNaoEncontradoException`
  /// (mock) ou `DioException` 404 (remota) quando o corretor não existe, não é
  /// corretor ou está desativado.
  Future<PerfilCorretorModel> buscarCorretor(int id);
}
