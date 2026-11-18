import 'package:flutter/material.dart';

import '../../../domain/entities/canal_contato.dart';
import '../rotulos_contato.dart';

/// Bottom sheet "Outras formas de contato" (D-05, D-06) — lista só os
/// [canais] que sobram além do principal, na ordem recebida. Tocar numa opção
/// já fecha o sheet e chama [aoEscolher] (sem passo de confirmação, mesmo
/// precedente de `mostrarOrdenacaoBottomSheet`).
///
/// [aoEscolher] deve vir capturado do contexto da TELA (`context.read`)
/// antes de abrir o sheet — a rota do modal fica fora do `BlocProvider`, então
/// o sheet nunca lê o Cubit diretamente. Só rótulos fixos: nenhum link,
/// número ou e-mail é mostrado aqui.
Future<void> mostrarContatoBottomSheet(
  BuildContext context, {
  required List<CanalContato> canais,
  required ValueChanged<CanalContato> aoEscolher,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (contextDoSheet) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Outras formas de contato',
                    style: Theme.of(contextDoSheet).textTheme.titleLarge,
                  ),
                ),
              ),
              for (final canal in canais)
                ListTile(
                  leading: Icon(canal.icone),
                  title: Text(canal.rotulo),
                  onTap: () {
                    Navigator.of(contextDoSheet).pop();
                    aoEscolher(canal);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
