import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/foto_imovel_model.dart';
import 'fotos_imovel_datasource.dart';

/// Tempo máximo para mandar o corpo de UMA foto (D-19). Só o envio da foto usa
/// este valor; as outras rotas seguem os 10 s do `Dio` autenticado. Com a
/// internet móvel da visita, um JPEG de ~1920 px leva bem menos do que isso.
const Duration tempoMaximoDeEnvioDaFoto = Duration(seconds: 60);

/// Fala com as rotas de fotos do §19 pelo `Dio` `@Named('autenticado')`, o
/// único que leva o token (só à origem da API). A barra final das rotas é
/// obrigatória e os ids são inteiros. A rota antiga `/api/fotos-imovel/` não é
/// usada.
///
/// Fina de propósito: não captura `DioException` (o repositório traduz 400,
/// 401, 403, 404 e demais) e não registra nada em log nem no console.
@LazySingleton(as: FotosImovelDataSource)
class FotosImovelRemoteDataSource implements FotosImovelDataSource {
  FotosImovelRemoteDataSource(@Named('autenticado') this._dio);

  final Dio _dio;

  String _fotos(int imovelId) => '/api/imoveis/$imovelId/fotos/';

  @override
  Future<List<FotoImovelModel>> listar(int imovelId) async =>
      _lista((await _dio.get<Object?>(_fotos(imovelId))).data);

  @override
  Future<FotoImovelModel> enviar(
    int imovelId,
    String caminho, {
    AoEnviarBytes? aoEnviar,
  }) async {
    // Corpo novo a cada chamada: um FormData já enviado não pode ser reenviado.
    final corpo = FormData.fromMap({
      'imagem': await MultipartFile.fromFile(
        caminho,
        filename: 'foto.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });
    final resposta = await _dio.post<Object?>(
      _fotos(imovelId),
      data: corpo,
      options: Options(sendTimeout: tempoMaximoDeEnvioDaFoto),
      onSendProgress: aoEnviar,
    );
    final dados = resposta.data;
    if (dados is! Map<String, dynamic>) {
      throw const FormatException('foto enviada: corpo não é objeto');
    }
    return FotoImovelModel.fromJson(dados);
  }

  @override
  Future<List<FotoImovelModel>> reordenar(int imovelId, List<int> ids) async =>
      _lista(
        (await _dio.put<Object?>(
          '${_fotos(imovelId)}ordem/',
          data: <String, Object?>{'ids': ids},
        )).data,
      );

  @override
  Future<List<FotoImovelModel>> definirCapa(int imovelId, int fotoId) async =>
      _lista(
        (await _dio.post<Object?>('${_fotos(imovelId)}$fotoId/capa/')).data,
      );

  @override
  Future<List<FotoImovelModel>> apagar(int imovelId, int fotoId) async =>
      _lista((await _dio.delete<Object?>('${_fotos(imovelId)}$fotoId/')).data);

  /// Lista de fotos na ordem recebida: sem sort, sem filtro (D-20).
  List<FotoImovelModel> _lista(Object? corpo) {
    if (corpo is! List<Object?>) {
      throw const FormatException('fotos: corpo não é lista');
    }
    return [
      for (final item in corpo)
        if (item is Map<String, dynamic>)
          FotoImovelModel.fromJson(item)
        else
          throw const FormatException('fotos: item não é objeto'),
    ];
  }
}
