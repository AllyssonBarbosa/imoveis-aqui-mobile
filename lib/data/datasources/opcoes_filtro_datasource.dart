import '../../domain/entities/cidade.dart';
import '../models/caracteristica_model.dart';

/// Caminho dos bairros com imóvel publicado na cidade de id [cidadeId]
/// (`GET /api/publico/cidades/<id>/bairros/`, 05-04). A cidade vai no
/// caminho pelo id da API, como a lista de imóveis.
String caminhoBairrosDaCidade(int cidadeId) =>
    '/api/publico/cidades/$cidadeId/bairros/';

/// Caminho do catálogo público de características (05-04).
const String caminhoCaracteristicasPublico = '/api/publico/caracteristicas/';

/// Fronteira das opções de bairro/característica (D-08): a implementação
/// real é [OpcoesFiltroRemoteDataSource] (`dio`), registrada no DI.
abstract class OpcoesFiltroDataSource {
  /// Bairros com ao menos um imóvel publicado em [cidade] — array não
  /// paginado de strings, na ordem recebida.
  Future<List<String>> bairros(Cidade cidade);

  /// Catálogo de características — array não paginado de `{id, nome}`, na
  /// ordem recebida (D-13).
  Future<List<CaracteristicaModel>> caracteristicas();
}
