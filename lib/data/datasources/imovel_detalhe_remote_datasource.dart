import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/detalhe_imovel_model.dart';
import 'imovel_detalhe_datasource.dart';

/// Lê o detalhe público de um imóvel (`GET /api/publico/imoveis/<id>/`, W09).
/// Exige um objeto JSON (senão [FormatException]) e devolve o
/// [DetalheImovelModel]. A `DioException` — o 404 de imóvel inexistente ou
/// despublicado inclusive — sobe tal e qual para o repositório, que a traduz
/// em falha tipada.
@LazySingleton(as: ImovelDetalheDataSource)
class ImovelDetalheRemoteDataSource implements ImovelDetalheDataSource {
  ImovelDetalheRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<DetalheImovelModel> buscarDetalhe(int id) async {
    final resposta = await _dio.get<Object?>(caminhoDetalheImovelPublico(id));
    final corpo = resposta.data;
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException(
        'Corpo do detalhe do imóvel não é um objeto JSON.',
      );
    }
    return DetalheImovelModel.fromJson(corpo);
  }
}
