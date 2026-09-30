import 'package:flutter/material.dart';

import '../../../domain/entities/ordenacao_vitrine.dart';

/// Rótulos em PT das opções de ordenação (D-11) — ficam em `presentation/`;
/// o enum de domínio guarda só o valor do query param (`valorApi`).
extension RotuloOrdenacaoVitrine on OrdenacaoVitrine {
  String get rotulo => switch (this) {
    OrdenacaoVitrine.maisRecentes => 'Mais recentes',
    OrdenacaoVitrine.precoAsc => 'Menor preço',
    OrdenacaoVitrine.precoDesc => 'Maior preço',
    OrdenacaoVitrine.areaAsc => 'Menor área',
    OrdenacaoVitrine.areaDesc => 'Maior área',
  };
}

/// Bottom sheet "Ordenar por" (D-10/D-11) — Material 3, sem passo de
/// confirmação: tocar uma opção já fecha o sheet e chama [aoEscolher] (mesmo
/// precedente de toque direto de `SeletorCidadeTopo`). Usa [RadioGroup] em
/// vez de `RadioListTile.groupValue`/`onChanged` (ambos deprecados nesta
/// versão do Flutter — `flutter analyze` trata deprecation info como fatal).
///
/// [aoEscolher] deve vir capturado do contexto da TELA (`context.read`)
/// antes de abrir o sheet — a rota do modal fica fora do `BlocProvider` da
/// vitrine, então o sheet nunca lê o Cubit diretamente.
Future<void> mostrarOrdenacaoBottomSheet(
  BuildContext context, {
  required OrdenacaoVitrine atual,
  required ValueChanged<OrdenacaoVitrine> aoEscolher,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (contextDoSheet) {
      return SafeArea(
        child: RadioGroup<OrdenacaoVitrine>(
          groupValue: atual,
          onChanged: (valor) {
            if (valor == null) return;
            Navigator.of(contextDoSheet).pop();
            aoEscolher(valor);
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ordenar por',
                      style: Theme.of(contextDoSheet).textTheme.titleLarge,
                    ),
                  ),
                ),
                for (final opcao in OrdenacaoVitrine.values)
                  RadioListTile<OrdenacaoVitrine>(
                    value: opcao,
                    title: Text(opcao.rotulo),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
  );
}
