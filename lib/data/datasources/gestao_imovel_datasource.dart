import '../models/imovel_gestao_model.dart';
import '../models/mudanca_situacao_model.dart';

/// Fonte do imóvel de gestão (`GET /api/imoveis/{id}/`). Interface trocável:
/// a implementação remota usa o `Dio` autenticado, e quem está acima só
/// enxerga o Model já tipado.
abstract class GestaoImovelDataSource {
  /// Lê o imóvel [id]. Falhas HTTP sobem como `DioException` (o repositório
  /// traduz 401, 404 e demais).
  Future<ImovelGestaoModel> obterImovel(int id);

  /// Lê o histórico do imóvel [id] (`GET /api/imoveis/{id}/historico/`), na
  /// ordem recebida. Falhas HTTP sobem como `DioException`; corpo que não é
  /// lista ou item que não é objeto sobe como `FormatException`.
  Future<List<MudancaSituacaoModel>> obterHistorico(int id);
}
