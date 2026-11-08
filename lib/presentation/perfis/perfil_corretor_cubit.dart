import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/perfil_corretor.dart';
import '../../domain/usecases/obter_perfil_corretor_usecase.dart';
import 'perfil_state.dart';

/// Carrega o perfil de UM corretor — criado a cada abertura da página (via
/// `BlocProvider`). A checagem de `isClosed` garante que nenhum `emit`
/// acontece depois de `close()` (mesma disciplina de `DetalheImovelCubit`).
@injectable
class PerfilCorretorCubit extends Cubit<PerfilState<PerfilCorretor>> {
  PerfilCorretorCubit(this._obterPerfil)
    : super(const PerfilState<PerfilCorretor>.carregando());

  final ObterPerfilCorretorUseCase _obterPerfil;

  /// Ponto de entrada — busca o perfil do corretor pelo [id].
  Future<void> carregar(int id) async {
    final resultado = await _obterPerfil(id);
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        emit(PerfilState<PerfilCorretor>.carregado(data));
      case Failure():
        emit(const PerfilState<PerfilCorretor>.erro());
      case Loading():
        break;
    }
  }
}
