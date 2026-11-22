import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/situacao_imovel.dart';
import '../repositories/gestao_imovel_repository.dart';

/// Delega direto ao repositório (sem lógica própria): o app pede a mudança e o
/// servidor decide (D-05, D-10). Sem data nem autor no pedido.
@injectable
class MudarSituacaoUseCase {
  MudarSituacaoUseCase(this._repositorio);

  final GestaoImovelRepository _repositorio;

  Future<Result<void>> call(
    int id,
    SituacaoImovel nova, {
    String observacao = '',
  }) => _repositorio.mudarSituacao(id, nova, observacao: observacao);
}
