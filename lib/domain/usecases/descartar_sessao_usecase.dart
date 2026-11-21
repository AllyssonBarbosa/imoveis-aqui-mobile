import 'package:injectable/injectable.dart';

import '../repositories/autenticacao_repository.dart';

/// Descarta o token do aparelho sem falar com o servidor: a sessão expirou
/// (401) e o token já está revogado.
///
/// É a segunda tentativa de apagar o token (T-08-49): o interceptor já tenta
/// apagá-lo ao receber o 401, mas o armazenamento seguro pode falhar nesse
/// momento — sem esta nova tentativa, o token revogado ficaria guardado e o
/// app voltaria a oferecer "Meu acervo" em ciclo.
///
/// Nunca lança: a garantia é herdada de
/// `AutenticacaoRepository.descartarSessaoLocal()`.
@injectable
class DescartarSessaoUseCase {
  DescartarSessaoUseCase(this._repositorio);

  final AutenticacaoRepository _repositorio;

  Future<void> call() => _repositorio.descartarSessaoLocal();
}
