import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/canal_contato.dart';
import '../../domain/gateways/link_launcher_gateway.dart';
import '../../domain/repositories/contato_repository.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../../domain/usecases/contatar_corretor_usecase.dart';
import 'contato_state.dart';

/// Conduz um contato com o responsável pelo imóvel — um mesmo Cubit serve a
/// página do imóvel e o perfil do corretor, pois o imóvel vem em [contatar]
/// (sem `@factoryParam`). Ignora o toque duplo enquanto um POST está em voo
/// (D-13) e, como `DetalheImovelCubit`, nunca emite depois de `close()`.
/// O motivo da falha é decidido só pelo tipo (D-14, D-15).
@injectable
class ContatoCubit extends Cubit<ContatoState> {
  ContatoCubit(this._contatar) : super(const ContatoState.ocioso());

  final ContatarCorretorUseCase _contatar;

  /// Registra o contato pelo [canal] com o imóvel [imovelId] e abre o link do
  /// servidor por fora do app.
  Future<void> contatar(int imovelId, CanalContato canal) async {
    if (isClosed || state is ContatoEnviando) return;
    emit(ContatoState.enviando(canal));
    final resultado = await _contatar(imovelId, canal);
    if (isClosed) return;
    switch (resultado) {
      case Success():
        emit(const ContatoState.ocioso());
      case Failure(:final erro):
        emit(ContatoState.falhou(_motivoDe(erro)));
      case Loading():
        emit(const ContatoState.ocioso());
    }
  }

  /// Decide só pelo tipo de domínio — nunca por mensagem nem status HTTP.
  MotivoFalhaContato _motivoDe(Exception erro) => switch (erro) {
    CanalIndisponivelException() => MotivoFalhaContato.canalIndisponivel,
    ImovelNaoEncontradoException() => MotivoFalhaContato.imovelIndisponivel,
    ContatoLimiteExcedidoException() => MotivoFalhaContato.limiteExcedido,
    ContatoSemAplicativoException() => MotivoFalhaContato.semAplicativo,
    _ => MotivoFalhaContato.generico,
  };
}
