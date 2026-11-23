import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/situacao_imovel.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/repositories/gestao_imovel_repository.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../../domain/usecases/mudar_situacao_usecase.dart';
import 'mudar_situacao_state.dart';

/// Conduz a folha "Mudar situação" (SIT-01): guarda a escolha do corretor e,
/// ao confirmar, PEDE a mudança à API pelo [MudarSituacaoUseCase] — o servidor
/// decide e grava (D-10). Ignora o toque duplo enquanto um POST está em voo
/// (T-09-07, mesmo molde do `ContatoCubit`) e nunca emite depois de `close()`.
///
/// O sucesso emite só `EnvioConcluido`; quem relê imóvel e histórico é a tela
/// (`GestaoImovelCubit.registrarMudanca`). Numa falha o desfecho é escolhido só
/// pelo TIPO da exceção de domínio (molde `ContatoCubit._motivoDe`); a mensagem
/// do servidor na recusa só é carregada para exibição (D-10).
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
      state.copyWith(escolhida: situacao, envio: const EnvioSituacao.ocioso()),
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
    final resultado = await _mudar(imovelId, escolhida, observacao: observacao);
    if (isClosed) return;
    switch (resultado) {
      case Success():
        emit(state.copyWith(envio: EnvioSituacao.concluido(escolhida)));
      case Failure(:final erro):
        emit(state.copyWith(envio: _envioDaFalha(erro)));
      case Loading():
        emit(state.copyWith(envio: const EnvioSituacao.ocioso()));
    }
  }

  /// Decide só pelo tipo de domínio — nunca por mensagem nem status HTTP. Sem
  /// nova tentativa automática: o reenvio é sempre do corretor (Pitfall 4).
  EnvioSituacao _envioDaFalha(Exception erro) => switch (erro) {
    MudancaSituacaoRecusadaException(:final mensagem) => EnvioSituacao.recusado(
      mensagem,
    ),
    ImovelNaoEncontradoException() => const EnvioSituacao.naoEncontrado(),
    SessaoExpiradaException() => const EnvioSituacao.sessaoExpirada(),
    _ => const EnvioSituacao.falhou(),
  };
}
