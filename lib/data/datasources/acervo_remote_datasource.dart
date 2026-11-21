import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/consulta_acervo.dart';
import '../models/acervo_envelope_model.dart';
import '../network/mesma_origem.dart';
import 'acervo_datasource.dart';
import 'parametros_consulta_acervo.dart';

/// Lê o acervo do corretor (`GET /api/imoveis/`) pelo `Dio`
/// `@Named('autenticado')`, o único que leva o token. `busca` e `situacao` vão
/// na query (D-08, D-09) e a paginação segue o `next` absoluto da resposta
/// (D-10), seguido tal e qual e só se tiver a mesma origem da base URL: a
/// credencial nunca sai da origem da API (T-08-30).
///
/// Fina de propósito: não captura `DioException` (o repositório traduz 401,
/// 403 e demais), não loga e não aplica nenhum filtro nem ordenação local.
@LazySingleton(as: AcervoDataSource)
class AcervoRemoteDataSource implements AcervoDataSource {
  AcervoRemoteDataSource(@Named('autenticado') this._dio);

  final Dio _dio;

  @override
  Future<AcervoEnvelopeModel> buscar(ConsultaAcervo consulta) async {
    final resposta = await _dio.get<Object?>(
      '/api/imoveis/',
      queryParameters: parametrosDaConsultaAcervo(consulta),
    );
    return _lerEnvelope(resposta.data);
  }

  @override
  Future<AcervoEnvelopeModel> seguir(String proximaPagina) async {
    if (!mesmaOrigem(
      Uri.parse(proximaPagina),
      Uri.parse(_dio.options.baseUrl),
    )) {
      throw const FormatException(
        'URL "next" do acervo aponta para uma origem diferente da base URL '
        'configurada.',
      );
    }
    final resposta = await _dio.get<Object?>(proximaPagina);
    return _lerEnvelope(resposta.data);
  }

  AcervoEnvelopeModel _lerEnvelope(Object? corpo) {
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException('Corpo do acervo não é um objeto JSON.');
    }
    return AcervoEnvelopeModel.fromJson(corpo);
  }
}
