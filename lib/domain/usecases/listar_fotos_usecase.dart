import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/foto_imovel.dart';
import '../repositories/fotos_imovel_repository.dart';

/// Lê as fotos do imóvel na ordem do servidor (APP 11). Sem lógica própria: o
/// app não reordena nem filtra o que veio (D-20).
@injectable
class ListarFotosUseCase {
  ListarFotosUseCase(this._repositorio);

  final FotosImovelRepository _repositorio;

  Future<Result<List<FotoImovel>>> call(int imovelId) =>
      _repositorio.listar(imovelId);
}
