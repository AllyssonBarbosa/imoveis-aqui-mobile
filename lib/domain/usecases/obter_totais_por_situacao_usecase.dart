import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/totais_por_situacao.dart';
import '../repositories/area_gestor_repository.dart';

/// Totais do acervo da empresa por situação (GES-01). Repasse puro — o número
/// é calculado pelo Django, nunca no aparelho (critério 5).
@injectable
class ObterTotaisPorSituacaoUseCase {
  ObterTotaisPorSituacaoUseCase(this._repositorio);

  final AreaGestorRepository _repositorio;

  Future<Result<TotaisPorSituacao>> call() =>
      _repositorio.obterTotaisPorSituacao();
}
