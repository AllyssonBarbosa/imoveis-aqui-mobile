import '../../domain/entities/consulta_imoveis.dart';
import '../models/imoveis_envelope_model.dart';

/// Fronteira trocável da camada `data/` (API-04): `ImovelRemoteDataSource`
/// (dio) é a registrada no DI; `ImovelMockDataSource` é só um dublê de teste.
/// Trocar de uma para a outra nunca toca `domain/`/`presentation/`.
abstract class ImovelDataSource {
  /// Primeira página de uma consulta nova.
  Future<ImoveisEnvelopeModel> buscar(ConsultaImoveis consulta);

  /// Próxima página, a partir da URL absoluta `next` da resposta anterior.
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina);
}
