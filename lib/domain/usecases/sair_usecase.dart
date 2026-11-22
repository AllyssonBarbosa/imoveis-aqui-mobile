import 'package:injectable/injectable.dart';

import '../repositories/autenticacao_repository.dart';

/// Encerra a sessão (AC-2): revoga o token no servidor como melhor esforço e
/// descarta o token do aparelho sempre.
///
/// Nunca lança: a garantia é herdada de `AutenticacaoRepository.sair()`, que
/// completa mesmo com a rede fora, o servidor respondendo 401 ou o
/// armazenamento seguro falhando ao apagar.
@injectable
class SairUseCase {
  SairUseCase(this._repositorio);

  final AutenticacaoRepository _repositorio;

  Future<void> call() => _repositorio.sair();
}
