import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/consulta_contatos.dart';
import '../entities/pagina_contatos.dart';
import '../repositories/caixa_contatos_repository.dart';

/// Delega direto ao repositório (sem lógica própria): a ordem e o filtro da
/// caixa de contatos são sempre do servidor, nunca do app (D-08, D-13).
@injectable
class BuscarContatosUseCase {
  BuscarContatosUseCase(this._repositorio);

  final CaixaContatosRepository _repositorio;

  Future<Result<PaginaContatos>> call(ConsultaContatos consulta) =>
      _repositorio.buscar(consulta);

  Future<Result<PaginaContatos>> seguir(String proximaPagina) =>
      _repositorio.seguir(proximaPagina);
}
