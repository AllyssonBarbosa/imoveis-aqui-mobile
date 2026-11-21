import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/anunciante_ref.dart';
import '../models/imoveis_envelope_model.dart';
import 'vitrine_anunciante_datasource.dart';

/// Lê a vitrine de imóveis de um anunciante
/// (`GET /api/publico/corretores/<id>/imoveis/` e
/// `GET /api/publico/empresas/<id>/imoveis/`, API-08). Não manda query string:
/// ordem e recorte são do servidor. A paginação é `PageNumberPagination`, a
/// mesma da vitrine da cidade: a próxima página é a URL absoluta `next` da
/// resposta, seguida tal e qual (nunca reconstruída), e só se tiver a mesma
/// origem da base URL configurada (T-07.1-01).
///
/// Fina de propósito: não captura `DioException` (o repositório traduz 404,
/// 429 e 500 em falha) e não tem interceptador de log.
@LazySingleton(as: VitrineAnuncianteDataSource)
class VitrineAnuncianteRemoteDataSource implements VitrineAnuncianteDataSource {
  VitrineAnuncianteRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<ImoveisEnvelopeModel> buscar(AnuncianteRef anunciante) async {
    final resposta = await _dio.get<Object?>(
      caminhoVitrineDoAnunciante(anunciante),
    );
    return _lerEnvelope(resposta.data);
  }

  @override
  Future<ImoveisEnvelopeModel> seguir(String proximaPagina) async {
    _exigirMesmaOrigem(proximaPagina);
    final resposta = await _dio.get<Object?>(proximaPagina);
    return _lerEnvelope(resposta.data);
  }

  ImoveisEnvelopeModel _lerEnvelope(Object? corpo) {
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException(
        'Corpo da vitrine do anunciante não é um objeto JSON.',
      );
    }
    return ImoveisEnvelopeModel.fromJson(corpo);
  }

  /// Lança [FormatException], antes de qualquer requisição, se [url] não
  /// tiver o mesmo scheme/host/porta da base URL do [Dio].
  void _exigirMesmaOrigem(String url) {
    final base = Uri.parse(_dio.options.baseUrl);
    final destino = Uri.parse(url);
    final mesmaOrigem =
        destino.scheme == base.scheme &&
        destino.host == base.host &&
        destino.port == base.port;
    if (!mesmaOrigem) {
      throw const FormatException(
        'URL "next" da vitrine do anunciante aponta para uma origem diferente '
        'da base URL configurada.',
      );
    }
  }
}
