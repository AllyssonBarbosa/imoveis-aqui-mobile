import 'package:flutter/material.dart';

import '../../../domain/entities/foto_imovel.dart';
import '../../comum/imagem_rede.dart';
import '../apresentacao_fotos.dart';

/// Ações do menu de cada foto.
enum _AcaoFoto { definirCapa, apagar }

/// Uma foto do servidor na lista reordenável: miniatura, "Foto N", o selo
/// "Capa" (lido do campo `capa` do servidor) e o menu "Definir como capa" /
/// "Apagar". A alça de arrastar e o menu só ficam ativos com [podeAlterar]
/// (sem envio nem outra operação em andamento, D-20). Nenhuma decisão aqui.
class ItemFoto extends StatelessWidget {
  const ItemFoto({
    super.key,
    required this.foto,
    required this.posicao,
    required this.indice,
    required this.podeAlterar,
    required this.emOperacao,
    required this.aoDefinirCapa,
    required this.aoApagar,
    this.construirImagemDeRede,
  });

  final FotoImovel foto;

  /// Posição exibida (1, 2, 3…), na ordem do servidor.
  final int posicao;

  /// Índice no `ReorderableListView` (para a alça de arrastar).
  final int indice;
  final bool podeAlterar;

  /// Esta foto é a da capa ou da exclusão em andamento.
  final bool emOperacao;
  final VoidCallback aoDefinirCapa;
  final VoidCallback aoApagar;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 80,
          height: 60,
          child: ImagemRede(
            url: foto.url,
            construirImagemDeRede: construirImagemDeRede,
          ),
        ),
      ),
      title: Text(rotuloPosicaoDaFoto(posicao)),
      subtitle: foto.capa
          ? Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: Icon(Icons.star, size: 18, color: colorScheme.primary),
                label: const Text(rotuloCapa),
                visualDensity: VisualDensity.compact,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emOperacao)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            PopupMenuButton<_AcaoFoto>(
              enabled: podeAlterar,
              tooltip: rotuloAcoesDaFoto(posicao),
              onSelected: (acao) => switch (acao) {
                _AcaoFoto.definirCapa => aoDefinirCapa(),
                _AcaoFoto.apagar => aoApagar(),
              },
              itemBuilder: (_) => [
                if (!foto.capa)
                  const PopupMenuItem(
                    value: _AcaoFoto.definirCapa,
                    child: Text(rotuloDefinirComoCapa),
                  ),
                const PopupMenuItem(
                  value: _AcaoFoto.apagar,
                  child: Text(rotuloApagar),
                ),
              ],
            ),
          if (podeAlterar)
            ReorderableDragStartListener(
              index: indice,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.drag_handle,
                color: colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
        ],
      ),
    );
  }
}
