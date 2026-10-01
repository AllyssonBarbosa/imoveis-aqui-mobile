import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/cidade.dart';
import '../repositories/opcoes_filtro_repository.dart';

/// Delega direto ao repositório (sem lógica própria) — a lista de bairros
/// sempre vem da camada de dados, nunca de uma lista fixa no app (D-20).
@injectable
class ObterBairrosUseCase {
  ObterBairrosUseCase(this._repositorio);

  final OpcoesFiltroRepository _repositorio;

  Future<Result<List<String>>> call(Cidade cidade) =>
      _repositorio.bairrosDaCidade(cidade);
}
