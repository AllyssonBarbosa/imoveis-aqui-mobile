import '../../domain/entities/consulta_acervo.dart';
import '../models/acervo_envelope_model.dart';

/// Fonte do acervo do corretor (`GET /api/imoveis/`). Interface trocável: a
/// implementação remota usa o `Dio` autenticado, e quem está acima só enxerga
/// o envelope já tipado. A ordem e o recorte do resultado são do servidor.
abstract class AcervoDataSource {
  /// Primeira página do acervo para [consulta] (busca e situação vão ao
  /// servidor, nunca são aplicadas no aparelho).
  Future<AcervoEnvelopeModel> buscar(ConsultaAcervo consulta);

  /// Página seguinte: [proximaPagina] é o `next` absoluto da resposta
  /// anterior, seguido tal e qual e só se for da mesma origem da API.
  Future<AcervoEnvelopeModel> seguir(String proximaPagina);
}
