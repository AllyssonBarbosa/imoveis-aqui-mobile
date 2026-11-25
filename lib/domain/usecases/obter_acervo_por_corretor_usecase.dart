import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/acervo_por_corretor.dart';
import '../repositories/area_gestor_repository.dart';

/// Acervo por corretor (GES-02). Repasse puro — o número é calculado pelo
/// Django, nunca no aparelho (critério 5); quem aparece e a ordem são do
/// servidor (D-13).
@injectable
class ObterAcervoPorCorretorUseCase {
  ObterAcervoPorCorretorUseCase(this._repositorio);

  final AreaGestorRepository _repositorio;

  Future<Result<AcervoPorCorretor>> call() =>
      _repositorio.obterAcervoPorCorretor();
}
