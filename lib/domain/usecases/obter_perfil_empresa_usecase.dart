import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/perfil_empresa.dart';
import '../repositories/perfil_repository.dart';

/// Delega direto ao repositório (sem lógica própria) — o perfil da empresa
/// sempre vem da camada de dados, buscado pelo id, nunca montado no app.
@injectable
class ObterPerfilEmpresaUseCase {
  ObterPerfilEmpresaUseCase(this._repositorio);

  final PerfilRepository _repositorio;

  Future<Result<PerfilEmpresa>> call(int id) => _repositorio.buscarEmpresa(id);
}
