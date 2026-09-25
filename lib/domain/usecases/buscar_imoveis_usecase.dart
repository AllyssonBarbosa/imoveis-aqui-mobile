import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/consulta_imoveis.dart';
import '../entities/pagina_imoveis.dart';
import '../repositories/imovel_repository.dart';

/// Delega direto ao repositório (sem lógica própria) — busca/ordenação/
/// filtro são sempre resolvidos no servidor/mock, nunca no app.
@injectable
class BuscarImoveisUseCase {
  BuscarImoveisUseCase(this._repositorio);

  final ImovelRepository _repositorio;

  Future<Result<PaginaImoveis>> call(ConsultaImoveis consulta) =>
      _repositorio.buscarImoveis(consulta);

  Future<Result<PaginaImoveis>> proximaPagina(String proximaPagina) =>
      _repositorio.buscarProximaPagina(proximaPagina);
}
