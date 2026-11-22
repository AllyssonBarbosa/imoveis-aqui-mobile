import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/situacao_imovel.dart';

part 'mudar_situacao_state.freezed.dart';

/// Estado da folha "Mudar situação" (SIT-01, D-09, D-10): o imóvel em questão,
/// a situação que ele tem agora ([atual], vinda do servidor), a situação que o
/// corretor escolheu ([escolhida]) e o andamento do pedido à API ([envio]).
///
/// O estado nunca guarda a situação "nova" como se já valesse: [escolhida] é só
/// o que o corretor quer pedir; quem diz a situação real é a releitura da API
/// que a tela faz depois do sucesso (D-10, T-09-03).
@freezed
abstract class MudarSituacaoState with _$MudarSituacaoState {
  const MudarSituacaoState._();

  const factory MudarSituacaoState({
    int? imovelId,
    SituacaoImovel? atual,
    SituacaoImovel? escolhida,
    @Default(EnvioSituacao.ocioso()) EnvioSituacao envio,
  }) = _MudarSituacaoState;

  /// "Confirmar" só vale com imóvel, com uma escolha diferente da atual (D-09)
  /// e sem um pedido em voo (guarda do toque duplo, T-09-07).
  bool get podeConfirmar =>
      imovelId != null &&
      escolhida != null &&
      escolhida != atual &&
      envio is! EnvioEnviando;
}

/// União selada do andamento do pedido de mudança — a folha decide o que
/// mostrar por `switch`, sem ramo abrangente.
@freezed
sealed class EnvioSituacao with _$EnvioSituacao {
  /// Nenhum pedido em andamento.
  const factory EnvioSituacao.ocioso() = EnvioOcioso;

  /// O POST está em voo.
  const factory EnvioSituacao.enviando() = EnvioEnviando;

  /// O servidor aceitou (200): [situacao] é a que o corretor pediu e o servidor
  /// aceitou — só serve para o aviso; a tela relê a API para mostrar o estado.
  const factory EnvioSituacao.concluido(SituacaoImovel situacao) =
      EnvioConcluido;

  /// O pedido falhou (rede, tempo esgotado, 5xx); a escolha continua para
  /// tentar de novo.
  const factory EnvioSituacao.falhou() = EnvioFalhou;

  /// O servidor recusou (400 ou 403): [mensagem] é o texto do próprio servidor,
  /// só para exibir como texto simples — nunca vira lógica (D-10, T-09-13). A
  /// escolha continua.
  const factory EnvioSituacao.recusado(String mensagem) = EnvioRecusado;
}
