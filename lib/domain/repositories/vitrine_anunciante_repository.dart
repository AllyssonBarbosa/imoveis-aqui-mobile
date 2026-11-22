import '../../core/result.dart';
import '../entities/anunciante_ref.dart';
import '../entities/pagina_imoveis.dart';

/// Interface trocável da vitrine do anunciante (contrato §12, API-08): os
/// imóveis de um corretor ou de uma empresa. Recorte e ordem são do servidor;
/// quem implementa só repassa a página na ordem recebida.
abstract class VitrineAnuncianteRepository {
  /// Primeira página da vitrine do [anunciante].
  Future<Result<PaginaImoveis>> buscarPrimeiraPagina(AnuncianteRef anunciante);

  /// Próxima página, a partir da próxima página (URL `next` do
  /// `PageNumberPagination`, opaca para o app) [proximaPagina].
  Future<Result<PaginaImoveis>> buscarProximaPagina(String proximaPagina);
}
