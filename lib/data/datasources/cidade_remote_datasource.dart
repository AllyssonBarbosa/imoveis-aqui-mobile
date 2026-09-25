import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/cidade_model.dart';

/// Lê `GET /api/publico/cidades/` (VIT-06, D-16) — mesmo envelope cursor
/// `{next, previous, results}` do antigo asset local, agora a única fonte
/// da verdade. Segue o `next` como URL absoluta (RESEARCH Pattern 5 — nunca
/// reconstrói o cursor a partir de partes), parando em `next == null`.
@lazySingleton
class CidadeRemoteDataSource {
  CidadeRemoteDataSource(this._dio);

  final Dio _dio;

  static const String caminhoCidades = '/api/publico/cidades/';
  static const int maxPaginas = 20;

  Future<List<CidadeModel>> obterCidades() async {
    // TODO(RED): implementação real chega no commit GREEN desta task.
    throw UnimplementedError();
  }
}
