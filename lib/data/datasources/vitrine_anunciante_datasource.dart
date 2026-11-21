import '../../domain/entities/anunciante_ref.dart';
import '../models/imoveis_envelope_model.dart';

/// Caminho do endpoint público da vitrine do anunciante (API-08, §13 do
/// contrato): `GET /api/publico/corretores/<id>/imoveis/` ou
/// `GET /api/publico/empresas/<id>/imoveis/`. Só um `int` entra no caminho,
/// nunca texto do usuário, e ele termina em barra — a mesma disciplina de
/// `caminhoPerfilCorretor`. Não há query string: o recorte (imóveis
/// publicados do anunciante) e a ordem ("mais recentes") são do servidor.
String caminhoVitrineDoAnunciante(AnuncianteRef anunciante) =>
    switch (anunciante) {
      AnuncianteCorretor(:final id) => '/api/publico/corretores/$id/imoveis/',
      AnuncianteEmpresa(:final id) => '/api/publico/empresas/$id/imoveis/',
    };

/// Fronteira da vitrine do anunciante (§13 do contrato, API-08), implementada
/// pela `VitrineAnuncianteRemoteDataSource` (Dio contra o Django). A lista usa
/// o mesmo envelope `PageNumberPagination` da vitrine da cidade.
abstract class VitrineAnuncianteDataSource {
  /// Primeira página da vitrine do [anunciante].
  Future<ImoveisEnvelopeModel> buscar(AnuncianteRef anunciante);

  /// Página seguinte, a partir da URL `next` absoluta ([proximaPagina]) da
  /// resposta anterior — opaca para o app, seguida tal e qual.
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina);
}
