import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/imovel_com_contato.dart';
import '../repositories/caixa_contatos_repository.dart';

/// Lista os imóveis que já receberam contato (as opções do filtro por
/// imóvel). Repasse puro: lista e ordem vêm do servidor (D-18).
@injectable
class ListarImoveisDosContatosUseCase {
  ListarImoveisDosContatosUseCase(this._repositorio);

  final CaixaContatosRepository _repositorio;

  Future<Result<List<ImovelComContato>>> call() => _repositorio.listarImoveis();
}
