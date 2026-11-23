import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/mudanca_situacao.dart';
import '../repositories/gestao_imovel_repository.dart';

/// Delega direto ao repositório (sem lógica própria): o histórico é sempre o
/// que o servidor devolve, na ordem dele (D-11).
@injectable
class ObterHistoricoSituacaoUseCase {
  ObterHistoricoSituacaoUseCase(this._repositorio);

  final GestaoImovelRepository _repositorio;

  Future<Result<List<MudancaSituacao>>> call(int id) =>
      _repositorio.obterHistorico(id);
}
