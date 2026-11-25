import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/mudancas_recentes.dart';
import '../repositories/area_gestor_repository.dart';

/// Mudanças de situação recentes (GES-04). Repasse puro — o app não escolhe a
/// janela: ela é do servidor e volta em `dias` (D-19); nada é filtrado nem
/// reordenado no aparelho (critério 5).
@injectable
class ObterMudancasRecentesUseCase {
  ObterMudancasRecentesUseCase(this._repositorio);

  final AreaGestorRepository _repositorio;

  Future<Result<MudancasRecentes>> call() =>
      _repositorio.obterMudancasRecentes();
}
