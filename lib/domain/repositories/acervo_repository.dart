import '../../core/result.dart';
import '../entities/consulta_acervo.dart';
import '../entities/pagina_acervo.dart';

/// Acervo do corretor (ACV-01, ACV-02, ACV-04). A busca e a situação são
/// resolvidas no servidor e a ordem da lista é a do servidor: o repositório
/// nunca filtra nem reordena (D-10, D-11).
abstract class AcervoRepository {
  /// Primeira página do acervo para [consulta]. Falhas tipadas:
  /// `SessaoExpiradaException` (401), `SemPermissaoException` (403) e as
  /// demais como `Failure` genérica.
  Future<Result<PaginaAcervo>> buscar(ConsultaAcervo consulta);

  /// Página seguinte, a partir do cursor opaco [proximaPagina] da página
  /// anterior.
  Future<Result<PaginaAcervo>> seguir(String proximaPagina);
}
