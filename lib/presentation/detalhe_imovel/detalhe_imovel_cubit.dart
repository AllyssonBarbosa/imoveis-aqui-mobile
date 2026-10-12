import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/usecases/obter_detalhe_imovel_usecase.dart';
import 'detalhe_imovel_state.dart';

/// Carrega o detalhe de UM imóvel — criado a cada abertura da página (via
/// `BlocProvider`). A checagem de `isClosed` garante que nenhum `emit`
/// acontece depois de `close()` (mesma disciplina de `OpcoesFiltroCubit`).
@injectable
class DetalheImovelCubit extends Cubit<DetalheImovelState> {
  DetalheImovelCubit(this._obterDetalhe)
    : super(const DetalheImovelState.carregando());

  final ObterDetalheImovelUseCase _obterDetalhe;

  /// Ponto de entrada — busca o detalhe do imóvel [id].
  Future<void> carregar(int id) => _buscar(id);

  Future<void> _buscar(int id) async {
    final resultado = await _obterDetalhe(id);
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        emit(DetalheImovelState.carregado(data));
      case Failure():
        emit(const DetalheImovelState.erro());
      case Loading():
        break;
    }
  }
}
