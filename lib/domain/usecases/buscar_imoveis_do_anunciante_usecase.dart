import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/anunciante_ref.dart';
import '../entities/pagina_imoveis.dart';
import '../repositories/vitrine_anunciante_repository.dart';

/// Delega direto ao repositório (sem lógica própria) — o recorte por
/// anunciante e a ordem são sempre do servidor, nunca do app (§12).
@injectable
class BuscarImoveisDoAnuncianteUseCase {
  BuscarImoveisDoAnuncianteUseCase(this._repositorio);

  final VitrineAnuncianteRepository _repositorio;

  Future<Result<PaginaImoveis>> call(AnuncianteRef anunciante) =>
      _repositorio.buscarPrimeiraPagina(anunciante);

  Future<Result<PaginaImoveis>> proximaPagina(String proximaPagina) =>
      _repositorio.buscarProximaPagina(proximaPagina);
}
