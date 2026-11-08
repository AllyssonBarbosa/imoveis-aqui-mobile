import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/perfil_corretor.dart';
import '../repositories/perfil_repository.dart';

/// Delega direto ao repositório (sem lógica própria) — o perfil do corretor
/// sempre vem da camada de dados, buscado pelo id, nunca montado no app.
@injectable
class ObterPerfilCorretorUseCase {
  ObterPerfilCorretorUseCase(this._repositorio);

  final PerfilRepository _repositorio;

  Future<Result<PerfilCorretor>> call(int id) =>
      _repositorio.buscarCorretor(id);
}
