import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/contatos_por_corretor.dart';
import '../entities/periodo_contatos.dart';
import '../repositories/area_gestor_repository.dart';

/// Contatos por corretor (GES-03). Repasse puro — o número é calculado pelo
/// Django, nunca no aparelho (critério 5). O período segue como veio; sem ele
/// vale todo o período (D-16) e nunca há filtro por imóvel (D-15).
@injectable
class ObterContatosPorCorretorUseCase {
  ObterContatosPorCorretorUseCase(this._repositorio);

  final AreaGestorRepository _repositorio;

  Future<Result<ContatosPorCorretor>> call([PeriodoContatos? periodo]) =>
      _repositorio.obterContatosPorCorretor(periodo);
}
