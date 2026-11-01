import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/cidade_model.dart';

/// Lê `GET /api/publico/cidades/` (VIT-06, D-05) — a API devolve um array
/// simples `[{id, nome, uf}]` só com as cidades que têm imóvel na vitrine
/// (sem cursor, sem paginação). Linhas sem `id`/`nome`/`uf` válidos são
/// descartadas silenciosamente (T-05-08-01), mesmo padrão defensivo da antiga
/// fonte local de cidades (removida, D-16). Corpo que não é uma lista lança
/// [FormatException].
@lazySingleton
class CidadeRemoteDataSource {
  CidadeRemoteDataSource(this._dio);

  final Dio _dio;

  static const String caminhoCidades = '/api/publico/cidades/';

  Future<List<CidadeModel>> obterCidades() async {
    final resposta = await _dio.get<Object?>(caminhoCidades);
    final corpo = resposta.data;
    if (corpo is! List) {
      throw const FormatException(
        'Corpo de GET /api/publico/cidades/ não é uma lista JSON.',
      );
    }

    final cidades = <CidadeModel>[];
    for (final linha in corpo) {
      if (linha is! Map<String, dynamic>) continue;
      final id = linha['id'];
      final nome = linha['nome'];
      final uf = linha['uf'];
      if (id is! int ||
          nome is! String ||
          nome.isEmpty ||
          uf is! String ||
          uf.isEmpty) {
        // Linha descartada: campo obrigatório ausente/vazio — nunca crash.
        continue;
      }
      cidades.add(CidadeModel(id: id, nome: nome, uf: uf));
    }
    return cidades;
  }
}
