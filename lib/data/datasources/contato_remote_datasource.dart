import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/canal_contato.dart';
import '../models/canal_contato_api.dart';
import '../models/contato_registrado_model.dart';
import 'contato_datasource.dart';

/// Registra o contato (`POST /api/publico/imoveis/<id>/contato/`, W11). O corpo
/// é só `{'canal': <valor do enum>}` e a chamada não leva cabeçalho nem
/// `Options` próprios: o contato é anônimo, sem credencial nem cookie (C6).
/// Exige um objeto JSON (senão [FormatException]); a `DioException` sobe tal e
/// qual para o repositório, que a traduz em falha tipada.
@LazySingleton(as: ContatoDataSource)
class ContatoRemoteDataSource implements ContatoDataSource {
  ContatoRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<ContatoRegistradoModel> registrar(
    int imovelId,
    CanalContato canal,
  ) async {
    final resposta = await _dio.post<Object?>(
      caminhoContatoImovelPublico(imovelId),
      data: <String, Object?>{'canal': canal.valorApi},
    );
    final corpo = resposta.data;
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException('Corpo do contato não é um objeto JSON.');
    }
    return ContatoRegistradoModel.fromJson(corpo);
  }
}
