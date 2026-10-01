import '../../core/result.dart';
import '../entities/cidade.dart';

/// Contrato trocável das opções de filtro (bairros/características, D-20).
/// Nesta fase a impl concreta lê a mesma fixture do acervo
/// (`OpcoesFiltroMockDataSource`); a Fase 4 troca por uma implementação
/// `dio` contra `GET /api/publico/bairros/`/`GET /api/publico/caracteristicas/`
/// sem tocar `domain/`/`presentation/` (mesma disciplina de
/// `ImovelRepository`).
abstract class OpcoesFiltroRepository {
  Future<Result<List<String>>> bairrosDaCidade(Cidade cidade);

  Future<Result<List<String>>> caracteristicas();
}
