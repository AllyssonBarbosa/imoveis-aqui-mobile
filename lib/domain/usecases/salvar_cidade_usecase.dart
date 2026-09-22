import 'package:injectable/injectable.dart';

import '../entities/cidade.dart';
import '../repositories/cidade_repository.dart';

/// Persiste a cidade escolhida pelo visitante (nome+uf, D-15) — sem conta,
/// sem senha (LOC-04).
@injectable
class SalvarCidadeUseCase {
  SalvarCidadeUseCase(this._repositorio);

  final CidadeRepository _repositorio;

  Future<void> call(Cidade cidade) => _repositorio.salvarCidade(cidade);
}
