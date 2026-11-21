import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/papel.dart';
import '../repositories/autenticacao_repository.dart';

/// Pergunta ao servidor o papel do usuário logado (ao tocar em "Meu acervo").
/// Repassa o resultado do repositório, sem lógica própria (D-02).
@injectable
class ObterPapelUseCase {
  ObterPapelUseCase(this._repositorio);

  final AutenticacaoRepository _repositorio;

  Future<Result<Papel>> call() => _repositorio.obterPapel();
}
