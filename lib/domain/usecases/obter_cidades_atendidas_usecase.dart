import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/cidade.dart';
import '../repositories/cidade_repository.dart';

/// Obtém a lista de cidades atendidas via `GET /api/publico/cidades/`
/// (VIT-06, D-16).
@injectable
class ObterCidadesAtendidasUseCase {
  ObterCidadesAtendidasUseCase(this._repositorio);

  final CidadeRepository _repositorio;

  Future<Result<List<Cidade>>> call() => _repositorio.obterCidadesAtendidas();
}
