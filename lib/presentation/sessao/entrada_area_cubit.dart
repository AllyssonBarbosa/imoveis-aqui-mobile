import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/usecases/obter_papel_usecase.dart';
import 'entrada_area_state.dart';

/// Pergunta o papel ao servidor quando o usuário toca em "Meu acervo" (D-02).
/// O papel nunca é guardado no aparelho: cada entrada consulta de novo, então
/// uma sessão revogada ou um papel alterado aparecem na hora.
@injectable
class EntradaAreaCubit extends Cubit<EntradaAreaState> {
  EntradaAreaCubit(this._obterPapel)
    : super(const EntradaAreaState.carregando());

  final ObterPapelUseCase _obterPapel;

  /// Pergunta o papel ao servidor e emite o desfecho.
  Future<void> carregar() async {
    final resultado = await _obterPapel();
    if (isClosed) return;
    switch (resultado) {
      case Success(:final data):
        emit(EntradaAreaState.papel(data));
      case Failure(:final erro):
        // Decide só pelo tipo de domínio — nunca por mensagem nem status HTTP.
        emit(
          erro is SessaoExpiradaException
              ? const EntradaAreaState.sessaoExpirada()
              : const EntradaAreaState.erro(),
        );
      case Loading():
        break;
    }
  }

  /// "Tentar de novo" do erro: volta a `carregando` e pergunta outra vez. Não
  /// faz nada enquanto já está perguntando (sem pedido duplo num toque duplo).
  Future<void> tentarNovamente() async {
    if (isClosed || state is EntradaAreaCarregando) return;
    emit(const EntradaAreaState.carregando());
    await carregar();
  }
}
