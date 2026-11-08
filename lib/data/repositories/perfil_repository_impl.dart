import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/perfil_corretor.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../datasources/perfil_datasource.dart';

/// Impl de [PerfilRepository] — injeta a interface trocável [PerfilDataSource],
/// nunca a classe mock diretamente (mesma disciplina de
/// `ImovelDetalheRepositoryImpl`).
///
/// Devolve o perfil já normalizado pelo Model e traduz qualquer falha da
/// DataSource em `Result.failure`. A tradução do 404 e do JSON malformado da
/// fonte remota entra junto com ela.
@LazySingleton(as: PerfilRepository)
class PerfilRepositoryImpl implements PerfilRepository {
  PerfilRepositoryImpl(this._dataSource);

  final PerfilDataSource _dataSource;

  @override
  Future<Result<PerfilCorretor>> buscarCorretor(int id) async {
    try {
      final modelo = await _dataSource.buscarCorretor(id);
      return Result.success(modelo.paraEntidade());
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
