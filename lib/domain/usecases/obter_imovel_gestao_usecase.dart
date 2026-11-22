import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/imovel_gestao.dart';
import '../repositories/gestao_imovel_repository.dart';

/// Delega direto ao repositório (sem lógica própria): o imóvel da tela de
/// gestão é sempre o que o servidor devolve (D-01).
@injectable
class ObterImovelGestaoUseCase {
  ObterImovelGestaoUseCase(this._repositorio);

  final GestaoImovelRepository _repositorio;

  Future<Result<ImovelGestao>> call(int id) => _repositorio.obterImovel(id);
}
