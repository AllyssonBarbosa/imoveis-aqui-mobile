import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/imovel_gestao_model.dart';
import 'gestao_imovel_datasource.dart';

/// Lê o imóvel de gestão (`GET /api/imoveis/{id}/`) pelo `Dio`
/// `@Named('autenticado')`, o único que leva o token (só à origem da API,
/// T-09-04). A barra final da rota é obrigatória e o [id] é inteiro (T-09-02).
///
/// Fina de propósito: não captura `DioException` (o repositório traduz 401,
/// 404 e demais) e não registra nada em log nem no console.
@LazySingleton(as: GestaoImovelDataSource)
class GestaoImovelRemoteDataSource implements GestaoImovelDataSource {
  GestaoImovelRemoteDataSource(@Named('autenticado') this._dio);

  final Dio _dio;

  @override
  Future<ImovelGestaoModel> obterImovel(int id) async {
    final resposta = await _dio.get<Object?>('/api/imoveis/$id/');
    final corpo = resposta.data;
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException(
        'Corpo do imóvel de gestão não é um objeto JSON.',
      );
    }
    return ImovelGestaoModel.fromJson(corpo);
  }
}
