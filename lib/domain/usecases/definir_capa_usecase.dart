import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/foto_imovel.dart';
import '../repositories/fotos_imovel_repository.dart';

/// Pede que a foto vire a capa e devolve a lista relida: a capa única é
/// garantida pelo servidor (D-04, D-21).
@injectable
class DefinirCapaUseCase {
  DefinirCapaUseCase(this._repositorio);

  final FotosImovelRepository _repositorio;

  Future<Result<List<FotoImovel>>> call(int imovelId, int fotoId) =>
      _repositorio.definirCapa(imovelId, fotoId);
}
