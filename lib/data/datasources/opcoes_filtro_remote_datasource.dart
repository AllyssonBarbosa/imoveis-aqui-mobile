import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/cidade.dart';
import '../models/caracteristica_model.dart';
import 'opcoes_filtro_datasource.dart';

/// Lê as opções do modal de filtros na API pública (D-08): os bairros da
/// cidade por id (`GET /api/publico/cidades/<id>/bairros/`, array de
/// strings) e o catálogo de características (`GET
/// /api/publico/caracteristicas/`, array de `{id, nome}`). O app mantém a
/// ordem recebida e nunca reordena. Linhas inválidas são descartadas
/// (T-05-12-01); corpo que não é uma lista lança [FormatException].
@LazySingleton(as: OpcoesFiltroDataSource)
class OpcoesFiltroRemoteDataSource implements OpcoesFiltroDataSource {
  OpcoesFiltroRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<String>> bairros(Cidade cidade) async {
    final cidadeId = cidade.id;
    if (cidadeId == null) {
      // Nenhuma requisição para uma cidade que o app não sabe endereçar
      // (T-05-12-03).
      throw FormatException('cidade sem id da API: $cidade');
    }
    final resposta = await _dio.get<Object?>(caminhoBairrosDaCidade(cidadeId));
    final corpo = resposta.data;
    if (corpo is! List) {
      throw const FormatException(
        'Corpo dos bairros da cidade não é uma lista JSON.',
      );
    }
    return [
      for (final linha in corpo)
        if (linha is String && linha.isNotEmpty) linha,
    ];
  }

  @override
  Future<List<CaracteristicaModel>> caracteristicas() async {
    final resposta = await _dio.get<Object?>(caminhoCaracteristicasPublico);
    final corpo = resposta.data;
    if (corpo is! List) {
      throw const FormatException(
        'Corpo de GET /api/publico/caracteristicas/ não é uma lista JSON.',
      );
    }
    final caracteristicas = <CaracteristicaModel>[];
    for (final linha in corpo) {
      if (linha is! Map<String, dynamic>) continue;
      final id = linha['id'];
      final nome = linha['nome'];
      if (id is! int || nome is! String || nome.isEmpty) {
        // Linha descartada: campo obrigatório ausente/inválido (sem crash).
        continue;
      }
      caracteristicas.add(CaracteristicaModel.fromJson(linha));
    }
    return caracteristicas;
  }
}
