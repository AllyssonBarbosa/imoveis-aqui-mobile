import 'package:flutter/material.dart';

import '../../domain/entities/canal_contato.dart';
import 'contato_state.dart';

/// Rótulo e ícone de cada canal de contato (D-05, D-06) — ficam em
/// `presentation/`; o enum de domínio só enumera os canais. Ícones só do
/// Material, sem pacote de ícones (conferidos no aparelho na verificação
/// manual da fase).
extension ApresentacaoCanalContato on CanalContato {
  String get rotulo => switch (this) {
    CanalContato.whatsapp => 'WhatsApp',
    CanalContato.telefone => 'Ligar',
    CanalContato.email => 'Enviar e-mail',
  };

  IconData get icone => switch (this) {
    CanalContato.whatsapp => Icons.chat,
    CanalContato.telefone => Icons.call,
    CanalContato.email => Icons.email_outlined,
  };
}

/// Mensagem em português de cada motivo de falha (D-14, D-15) — textos fixos,
/// nunca o texto do servidor.
extension MensagemFalhaContato on MotivoFalhaContato {
  String get mensagem => switch (this) {
    MotivoFalhaContato.generico =>
      'Não foi possível abrir o contato. Tente de novo.',
    MotivoFalhaContato.canalIndisponivel =>
      'Este canal não está disponível para este imóvel.',
    MotivoFalhaContato.imovelIndisponivel =>
      'Este imóvel não está mais disponível.',
    MotivoFalhaContato.limiteExcedido =>
      'Muitas tentativas. Aguarde um pouco e tente de novo.',
    MotivoFalhaContato.semAplicativo =>
      'Nenhum aplicativo para abrir este contato.',
  };
}
