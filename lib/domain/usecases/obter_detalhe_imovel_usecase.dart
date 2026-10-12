import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/detalhe_imovel.dart';
import '../repositories/imovel_detalhe_repository.dart';

/// Delega direto ao repositório (sem lógica própria) — o detalhe sempre vem
/// da camada de dados, nunca é montado no app.
@injectable
class ObterDetalheImovelUseCase {
  ObterDetalheImovelUseCase(this._repositorio);

  final ImovelDetalheRepository _repositorio;

  Future<Result<DetalheImovel>> call(int id) => _repositorio.buscarDetalhe(id);
}
