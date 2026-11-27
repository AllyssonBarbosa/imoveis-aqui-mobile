import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/foto_imovel.dart';
import '../repositories/fotos_imovel_repository.dart';

/// Pede a ordem nova (lista completa de ids) e devolve a lista relida do
/// servidor. O app nunca move a foto localmente (D-02, D-20).
@injectable
class ReordenarFotosUseCase {
  ReordenarFotosUseCase(this._repositorio);

  final FotosImovelRepository _repositorio;

  Future<Result<List<FotoImovel>>> call(int imovelId, List<int> ids) =>
      _repositorio.reordenar(imovelId, ids);
}
