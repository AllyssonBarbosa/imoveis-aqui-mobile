import 'package:flutter/material.dart';

import '../../../domain/entities/retorno_contato.dart';
import '../apresentacao_contatos.dart';

/// Folha "Anotar retorno" (D-14): as quatro opções que o corretor pode anotar
/// ([RetornoContato.anotaveis], sem "Aguardando retorno"), com a [atual]
/// marcada. Um toque numa opção fecha a folha e entrega a escolha por
/// [aoEscolher] — sem botão Salvar e sem confirmação. Quem grava é o Cubit da
/// tela, que espera o servidor (D-16); a folha só apresenta.
///
/// O callback vem da TELA por valor, porque a rota do modal fica fora do
/// `BlocProvider` dela.
Future<void> mostrarFolhaAnotarRetorno(
  BuildContext context, {
  required RetornoContato atual,
  required ValueChanged<RetornoContato> aoEscolher,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (contextoDaFolha) {
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
                    tituloFolhaAnotarRetorno,
                    style: Theme.of(contextoDaFolha).textTheme.titleLarge,
                  ),
                ),
              ),
              for (final retorno in RetornoContato.anotaveis)
                ListTile(
                  title: Text(retorno.rotulo),
                  selected: retorno == atual,
                  trailing: retorno == atual ? const Icon(Icons.check) : null,
                  onTap: () {
                    Navigator.of(contextoDaFolha).pop();
                    aoEscolher(retorno);
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
