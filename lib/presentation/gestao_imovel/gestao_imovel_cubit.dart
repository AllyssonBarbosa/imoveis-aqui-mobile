import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/usecases/obter_imovel_gestao_usecase.dart';
import 'gestao_imovel_state.dart';

/// Orquestra a tela de gestão do imóvel (SIT-07): pede o imóvel ao use case e
/// mostra o que o servidor entregou — nada é montado no app (D-01). Decide só
/// pelo desfecho do `Result`.
///
/// Token de versão (`_versao`) descarta a resposta de uma leitura que já foi
/// superada por outra, e `isClosed` é conferido antes de todo `emit` (o abridor
/// fecha o Cubit na volta da tela, com resposta ainda em voo).
@injectable
class GestaoImovelCubit extends Cubit<GestaoImovelState> {
  GestaoImovelCubit(this._obterImovel) : super(const GestaoImovelState());

  final ObterImovelGestaoUseCase _obterImovel;

  int _versao = 0;
  int? _id;

  /// Lê o imóvel [id]: guarda o id (para [tentarNovamente]), emite o
  /// carregando e depois o desfecho.
  Future<void> carregar(int id) async {
    _id = id;
    final minhaVersao = ++_versao;
    if (isClosed) return;
    emit(const GestaoImovelState());

    final resultado = await _obterImovel(id);

    if (minhaVersao != _versao || isClosed) return;

    switch (resultado) {
      case Success(:final data):
        emit(state.copyWith(imovel: ConteudoImovelGestao.carregado(data)));
      case Failure():
        emit(state.copyWith(imovel: const ConteudoImovelGestao.erro()));
      case Loading():
        break;
    }
  }

  /// Repete a leitura com o id guardado; sem leitura anterior não faz nada.
  Future<void> tentarNovamente() async {
    final id = _id;
    if (id == null) return;
    await carregar(id);
  }
}
