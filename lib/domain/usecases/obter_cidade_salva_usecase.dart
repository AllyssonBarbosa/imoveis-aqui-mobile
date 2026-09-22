import 'package:injectable/injectable.dart';

import '../entities/cidade.dart';
import '../repositories/cidade_repository.dart';

/// Lê a cidade previamente salva no aparelho, se existir — usada no
/// lançamento para decidir entrar direto na cidade guardada (D-08) sem
/// re-pedir GPS.
@injectable
class ObterCidadeSalvaUseCase {
  ObterCidadeSalvaUseCase(this._repositorio);

  final CidadeRepository _repositorio;

  Future<Cidade?> call() => _repositorio.obterCidadeSalva();
}
