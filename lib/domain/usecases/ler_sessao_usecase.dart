import 'package:injectable/injectable.dart';

import '../repositories/autenticacao_repository.dart';

/// Diz se há sessão guardada no aparelho (rótulo do botão do topo, D-C).
///
/// Só lê o aparelho, nunca a rede (AC-6): a abertura do app não espera o
/// servidor para decidir entre "Entrar" e "Meu acervo".
@injectable
class LerSessaoUseCase {
  LerSessaoUseCase(this._repositorio);

  final AutenticacaoRepository _repositorio;

  Future<bool> call() => _repositorio.temSessaoGuardada();
}
