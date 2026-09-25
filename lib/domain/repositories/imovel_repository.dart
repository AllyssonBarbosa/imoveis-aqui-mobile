import '../../core/result.dart';
import '../entities/consulta_imoveis.dart';
import '../entities/pagina_imoveis.dart';

/// Interface trocável da camada de dados de imóveis (API-04) — a Fase 4 troca
/// a implementação mock por uma real via DI, sem tocar `domain/`/
/// `presentation/`.
abstract class ImovelRepository {
  /// Primeira página de uma consulta nova (cidade + busca + ordenação).
  Future<Result<PaginaImoveis>> buscarImoveis(ConsultaImoveis consulta);

  /// Próxima página, a partir do cursor opaco `proximaPagina` (Fase 3).
  Future<Result<PaginaImoveis>> buscarProximaPagina(String proximaPagina);
}
