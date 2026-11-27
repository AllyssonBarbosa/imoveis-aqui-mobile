import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/foto_imovel.dart';
import '../repositories/fotos_imovel_repository.dart';

/// Pede a exclusão da foto e devolve a lista relida: renumerar e promover a
/// capa são do servidor (D-04, D-05, D-22).
@injectable
class ApagarFotoUseCase {
  ApagarFotoUseCase(this._repositorio);

  final FotosImovelRepository _repositorio;

  Future<Result<List<FotoImovel>>> call(int imovelId, int fotoId) =>
      _repositorio.apagar(imovelId, fotoId);
}
