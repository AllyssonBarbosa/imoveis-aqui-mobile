import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../repositories/caixa_contatos_repository.dart';

/// Quantos contatos estão sem retorno anotado. Repasse puro: o número é
/// calculado pelo Django sobre a caixa inteira, nunca contado no aparelho
/// (D-04, D-05).
@injectable
class ObterSemRetornoUseCase {
  ObterSemRetornoUseCase(this._repositorio);

  final CaixaContatosRepository _repositorio;

  Future<Result<int>> call() => _repositorio.contarSemRetorno();
}
