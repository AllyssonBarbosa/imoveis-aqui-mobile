import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/usecases/obter_detalhe_imovel_usecase.dart';
import 'detalhe_imovel_state.dart';

/// Carrega o detalhe de UM imóvel — criado a cada abertura da página (via
/// `BlocProvider`); `carregar` guarda o id para o "Tentar de novo". A
/// checagem de `isClosed` garante que nenhum `emit` acontece depois de
/// `close()` (mesma disciplina de `OpcoesFiltroCubit`).
@injectable
class DetalheImovelCubit extends Cubit<DetalheImovelState> {
  DetalheImovelCubit(this._obterDetalhe)
    : super(const DetalheImovelState.carregando());

  final ObterDetalheImovelUseCase _obterDetalhe;

  int? _id;

  /// Ponto de entrada — guarda o [id] e busca o detalhe do imóvel.
  Future<void> carregar(int id) {
    _id = id;
    return _buscar(id);
  }

  /// "Tentar de novo" da falha (D-17) — repete a busca do mesmo id passando
  /// por `carregando`. Não faz nada sem id guardado ou enquanto já está
  /// carregando (sem busca dupla num toque duplo).
  Future<void> tentarNovamente() async {
    final id = _id;
    if (isClosed || id == null || state is DetalheCarregando) return;
    emit(const DetalheImovelState.carregando());
    await _buscar(id);
  }

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
