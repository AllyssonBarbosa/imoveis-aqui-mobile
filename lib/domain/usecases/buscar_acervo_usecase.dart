import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/consulta_acervo.dart';
import '../entities/pagina_acervo.dart';
import '../repositories/acervo_repository.dart';

/// Delega direto ao repositório (sem lógica própria): a ordem e o filtro do
/// acervo são sempre do servidor, nunca do app (D-10, D-11).
@injectable
class BuscarAcervoUseCase {
  BuscarAcervoUseCase(this._repositorio);

  final AcervoRepository _repositorio;

  Future<Result<PaginaAcervo>> call(ConsultaAcervo consulta) =>
      _repositorio.buscar(consulta);

  Future<Result<PaginaAcervo>> seguir(String proximaPagina) =>
      _repositorio.seguir(proximaPagina);
}
