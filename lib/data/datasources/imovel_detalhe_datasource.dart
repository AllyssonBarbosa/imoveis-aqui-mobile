import '../models/detalhe_imovel_model.dart';

/// Caminho do endpoint público do detalhe (o `id` é sempre um inteiro, nunca
/// texto do usuário).
String caminhoDetalheImovelPublico(int id) => '/api/publico/imoveis/$id/';

/// Fronteira trocável mock->real do detalhe do imóvel. A troca por uma
/// implementação `dio` na Fase 5 é só uma mudança de DI — `domain/` e
/// `presentation/` não são tocados (API-07).
abstract class ImovelDetalheDataSource {
  /// Busca o detalhe do imóvel [id]. Lança `ImovelNaoEncontradoException`
  /// (mock) ou `DioException` 404 (remoto) quando o imóvel não existe ou não
  /// está publicado.
  Future<DetalheImovelModel> buscarDetalhe(int id);
}
