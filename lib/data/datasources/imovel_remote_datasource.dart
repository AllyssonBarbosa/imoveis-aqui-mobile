import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/consulta_imoveis.dart';
import '../models/imoveis_envelope_model.dart';
import 'imovel_datasource.dart';
import 'parametros_consulta_imoveis.dart';

/// Lê a lista pública de imóveis de uma cidade
/// (`GET /api/publico/cidades/<id>/imoveis/`, W09). A cidade vai no caminho
/// pelo id da API; a ordenação e os demais parâmetros vão por
/// `queryParameters` (codificados pelo dio). A paginação é
/// `PageNumberPagination`: a próxima página é a URL absoluta `next` da
/// resposta, seguida tal e qual (nunca reconstruída), e só se tiver a mesma
/// origem da base URL configurada (T-05-09-01).
@LazySingleton(as: ImovelDataSource)
class ImovelRemoteDataSource implements ImovelDataSource {
  ImovelRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<ImoveisEnvelopeModel> buscar(ConsultaImoveis consulta) async {
    final cidadeId = consulta.cidade.id;
    if (cidadeId == null) {
      throw FormatException('cidade sem id da API: ${consulta.cidade}');
    }
    final resposta = await _dio.get<Object?>(
      caminhoImoveisDaCidade(cidadeId),
      queryParameters: parametrosDaApi(consulta),
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
        'Corpo da lista de imóveis não é um objeto JSON.',
      );
    }
    return ImoveisEnvelopeModel.fromJson(corpo);
  }

  /// Lança [FormatException], antes de qualquer requisição, se [url] não
  /// tiver o mesmo scheme/host/porta da base URL do [Dio] (T-02-04-02).
  void _exigirMesmaOrigem(String url) {
    final base = Uri.parse(_dio.options.baseUrl);
    final destino = Uri.parse(url);
    final mesmaOrigem =
        destino.scheme == base.scheme &&
        destino.host == base.host &&
        destino.port == base.port;
    if (!mesmaOrigem) {
      throw const FormatException(
        'URL "next" da lista de imóveis aponta para uma origem diferente da '
        'base URL configurada.',
      );
    }
  }
}
