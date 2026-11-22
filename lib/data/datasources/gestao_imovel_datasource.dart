import '../models/imovel_gestao_model.dart';

/// Fonte do imóvel de gestão (`GET /api/imoveis/{id}/`). Interface trocável:
/// a implementação remota usa o `Dio` autenticado, e quem está acima só
/// enxerga o Model já tipado.
abstract class GestaoImovelDataSource {
  /// Lê o imóvel [id]. Falhas HTTP sobem como `DioException` (o repositório
  /// traduz 401, 404 e demais).
  Future<ImovelGestaoModel> obterImovel(int id);
}
