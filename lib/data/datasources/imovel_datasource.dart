import '../../domain/entities/consulta_imoveis.dart';
import '../models/imoveis_envelope_model.dart';

/// Fronteira trocável mock->real da camada `data/` (API-04). A Fase 4 troca
/// `ImovelMockDataSource` por uma implementação `dio` sem tocar
/// `domain/`/`presentation/` — só a anotação de DI muda.
abstract class ImovelDataSource {
  /// Primeira página de uma consulta nova.
  Future<ImoveisEnvelopeModel> buscar(ConsultaImoveis consulta);

  /// Próxima página, a partir do cursor opaco `proximaPagina` (Fase 3).
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina);
}
