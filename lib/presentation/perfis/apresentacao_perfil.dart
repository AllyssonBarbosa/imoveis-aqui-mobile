import 'package:flutter/material.dart';

/// Funções puras de apresentação do perfil (D-10, D-11) — quais linhas de
/// contato existem é decidido aqui, nunca espalhado em widgets. Só repassa o
/// que o servidor mandou: nenhum valor é formatado, completado ou inferido.

/// Uma linha de contato: rótulo, valor exatamente como veio e ícone.
class LinhaContato {
  const LinhaContato({
    required this.rotulo,
    required this.valor,
    required this.icone,
  });

  final String rotulo;
  final String valor;
  final IconData icone;
}

/// As linhas de contato que EXISTEM, nesta ordem: Telefone, WhatsApp, E-mail.
/// Valor nulo omite a linha; todos nulos devolve lista vazia. Os valores vão
/// como vieram — a API mistura "(19) 3333-4444" e "19999998888", e formatar
/// seria regra nova no aparelho. O Material não tem ícone de WhatsApp, por
/// isso `chat_outlined`.
List<LinhaContato> linhasDeContato({
  String? telefone,
  String? whatsapp,
  String? email,
}) {
  return [
    if (telefone != null)
      LinhaContato(
        rotulo: 'Telefone',
        valor: telefone,
        icone: Icons.phone_outlined,
      ),
    if (whatsapp != null)
      LinhaContato(
        rotulo: 'WhatsApp',
        valor: whatsapp,
        icone: Icons.chat_outlined,
      ),
    if (email != null)
      LinhaContato(
        rotulo: 'E-mail',
        valor: email,
        icone: Icons.email_outlined,
      ),
  ];
}
