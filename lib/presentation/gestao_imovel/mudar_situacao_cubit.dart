import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/situacao_imovel.dart';
import '../../domain/usecases/mudar_situacao_usecase.dart';
import 'mudar_situacao_state.dart';

/// Conduz a folha "Mudar situação" (SIT-01): guarda a escolha do corretor e,
/// ao confirmar, PEDE a mudança à API pelo [MudarSituacaoUseCase] — o servidor
/// decide e grava (D-10). Ignora o toque duplo enquanto um POST está em voo
/// (T-09-07, mesmo molde do `ContatoCubit`) e nunca emite depois de `close()`.
///
/// O sucesso emite só `EnvioConcluido`; quem relê imóvel e histórico é a tela
/// (`GestaoImovelCubit.registrarMudanca`). Falhas 400/403 aparecem aqui como a
/// falha genérica da folha; a mensagem do servidor entra no 09-12.
@injectable
class MudarSituacaoCubit extends Cubit<MudarSituacaoState> {
  MudarSituacaoCubit(this._mudar) : super(const MudarSituacaoState());

  final MudarSituacaoUseCase _mudar;

  /// Começa uma folha nova para o imóvel [imovelId], que está em [atual]: sem
  /// escolha e sem envio anterior.
  void iniciar({required int imovelId, required SituacaoImovel? atual}) {
    if (isClosed) return;
    emit(MudarSituacaoState(imovelId: imovelId, atual: atual));
  }

  /// Escolhe a situação [situacao]. Ignora durante o envio e quando é a atual
  /// (o chip dela fica desabilitado, D-09); depois de uma falha volta o envio
  /// a ocioso.
  void escolher(SituacaoImovel situacao) {
    if (isClosed || state.envio is EnvioEnviando) return;
    if (situacao == state.atual) return;
    emit(
      state.copyWith(
        escolhida: situacao,
        envio: const EnvioSituacao.ocioso(),
      ),
    );
  }

  /// Pede a mudança para a situação escolhida; [observacao] vai como o
  /// corretor digitou (o campo da folha entra no 09-11). Sem escolha válida ou
  /// com um envio em voo não faz nada.
  Future<void> confirmar({String observacao = ''}) async {
    final imovelId = state.imovelId;
    final escolhida = state.escolhida;
    if (isClosed || !state.podeConfirmar) return;
    if (imovelId == null || escolhida == null) return;

    emit(state.copyWith(envio: const EnvioSituacao.enviando()));
    final resultado = await _mudar(
      imovelId,
      escolhida,
      observacao: observacao,
    );
    if (isClosed) return;
    switch (resultado) {
      case Success():
        emit(state.copyWith(envio: EnvioSituacao.concluido(escolhida)));
      case Failure():
        emit(state.copyWith(envio: const EnvioSituacao.falhou()));
      case Loading():
        emit(state.copyWith(envio: const EnvioSituacao.ocioso()));
    }
  }
}
