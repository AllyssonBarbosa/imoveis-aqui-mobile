import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/perfil_empresa.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../../domain/usecases/obter_perfil_empresa_usecase.dart';
import 'perfil_state.dart';

/// Carrega o perfil de UMA empresa — criado a cada abertura da página (via
/// `BlocProvider`); `carregar` guarda o id para o "Tentar de novo". A
/// checagem de `isClosed` garante que nenhum `emit` acontece depois de
/// `close()` (mesma disciplina de `PerfilCorretorCubit`).
@injectable
class PerfilEmpresaCubit extends Cubit<PerfilState<PerfilEmpresa>> {
  PerfilEmpresaCubit(this._obterPerfil)
    : super(const PerfilState<PerfilEmpresa>.carregando());

  final ObterPerfilEmpresaUseCase _obterPerfil;

  int? _id;

  /// Ponto de entrada — guarda o [id] e busca o perfil da empresa.
  Future<void> carregar(int id) {
    _id = id;
    return _buscar(id);
  }

  /// "Tentar de novo" da falha (D-15) — repete a busca do mesmo id passando
  /// por `carregando`. Não faz nada sem id guardado, enquanto já está
  /// carregando (sem busca dupla num toque duplo) nem no 404, onde repetir
  /// não resolve.
  Future<void> tentarNovamente() async {
    final id = _id;
    if (isClosed ||
        id == null ||
        state is PerfilCarregando<PerfilEmpresa> ||
        state is PerfilNaoEncontrado<PerfilEmpresa>) {
      return;
    }
    emit(const PerfilState<PerfilEmpresa>.carregando());
    await _buscar(id);
  }

  Future<void> _buscar(int id) async {
    final resultado = await _obterPerfil(id);
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        emit(PerfilState<PerfilEmpresa>.carregado(data));
      case Failure(:final erro):
        // Decide só pelo tipo de domínio — nunca por mensagem nem status HTTP.
        emit(
          erro is PerfilNaoEncontradoException
              ? const PerfilState<PerfilEmpresa>.naoEncontrado()
              : const PerfilState<PerfilEmpresa>.erro(),
        );
      case Loading():
        break;
    }
  }
}
