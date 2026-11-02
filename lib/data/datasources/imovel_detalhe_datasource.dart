import '../models/detalhe_imovel_model.dart';

/// Caminho do endpoint público do detalhe (o `id` é sempre um inteiro, nunca
/// texto do usuário).
String caminhoDetalheImovelPublico(int id) => '/api/publico/imoveis/$id/';

/// Fronteira do detalhe do imóvel (API-07). A única implementação é a remota
/// (`ImovelDetalheRemoteDataSource`, `dio` sobre a API pública); `domain/` e
/// `presentation/` só conhecem esta interface.
abstract class ImovelDetalheDataSource {
  /// Busca o detalhe do imóvel [id]. Lança `DioException` 404 quando o imóvel
  /// não existe ou não está disponível.
  Future<DetalheImovelModel> buscarDetalhe(int id);
}
