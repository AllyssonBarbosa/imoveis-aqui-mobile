import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/canal_contato.dart';

part 'contato_state.freezed.dart';

/// Por que o contato não foi concluído (D-14, D-15). O Cubit decide o motivo
/// só pelo tipo da falha de domínio; a mensagem em português mora em
/// `rotulos_contato.dart`.
enum MotivoFalhaContato {
  generico,
  canalIndisponivel,
  imovelIndisponivel,
  limiteExcedido,
  semAplicativo,
}

/// Estado de `ContatoCubit` — união selada do ciclo de um contato (D-13).
///
/// O estado NUNCA guarda o link do servidor, um número de telefone ou um
/// e-mail: só o [CanalContato] em andamento ou o [MotivoFalhaContato].
@freezed
sealed class ContatoState with _$ContatoState {
  /// Nenhum contato em andamento (inclusive depois de um sucesso).
  const factory ContatoState.ocioso() = ContatoOcioso;

  /// O POST do contato está em voo pelo [canal] — o botão fica desabilitado.
  const factory ContatoState.enviando(CanalContato canal) = ContatoEnviando;

  /// O contato falhou pelo [motivo]; cada falha nova é uma nova emissão.
  const factory ContatoState.falhou(MotivoFalhaContato motivo) = ContatoFalhou;
}
