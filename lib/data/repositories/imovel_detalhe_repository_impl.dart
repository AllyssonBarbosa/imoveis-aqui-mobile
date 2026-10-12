import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/detalhe_imovel.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../datasources/imovel_detalhe_datasource.dart';

/// Impl de [ImovelDetalheRepository] — injeta a interface trocável
/// [ImovelDetalheDataSource], nunca a classe mock diretamente (mesma
/// disciplina de `ImovelRepositoryImpl`).
@LazySingleton(as: ImovelDetalheRepository)
class ImovelDetalheRepositoryImpl implements ImovelDetalheRepository {
  ImovelDetalheRepositoryImpl(this._dataSource);

  final ImovelDetalheDataSource _dataSource;

  @override
  Future<Result<DetalheImovel>> buscarDetalhe(int id) async {
    try {
      final modelo = await _dataSource.buscarDetalhe(id);
      return Result.success(modelo.paraEntidade());
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
