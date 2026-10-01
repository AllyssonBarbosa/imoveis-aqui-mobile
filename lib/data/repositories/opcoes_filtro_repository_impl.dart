import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/repositories/opcoes_filtro_repository.dart';
import '../datasources/opcoes_filtro_datasource.dart';

/// Impl de [OpcoesFiltroRepository] (API-04) — injeta a interface trocável
/// [OpcoesFiltroDataSource], nunca a classe mock diretamente (mesma
/// disciplina de `ImovelRepositoryImpl`).
@LazySingleton(as: OpcoesFiltroRepository)
class OpcoesFiltroRepositoryImpl implements OpcoesFiltroRepository {
  OpcoesFiltroRepositoryImpl(this._dataSource);

  final OpcoesFiltroDataSource _dataSource;

  @override
  Future<Result<List<String>>> bairrosDaCidade(Cidade cidade) async {
    try {
      final bairros = await _dataSource.bairros(cidade);
      return Result.success(bairros);
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }

  @override
  Future<Result<List<String>>> caracteristicas() async {
    try {
      final caracteristicas = await _dataSource.caracteristicas();
      return Result.success(caracteristicas);
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
