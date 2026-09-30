import 'package:flutter/material.dart';

import '../../../domain/entities/filtros_vitrine.dart';
import '../apresentacao_filtros.dart';

/// Linha horizontal rolável de chips resumidos (D-15, D-16) — só existe
/// quando há filtro ativo (`SizedBox.shrink()` caso contrário). O "x" de
/// cada chip remove aquele filtro e reconsulta na hora (D-17); tocar no
/// corpo reabre o sheet com o rascunho igual aos filtros aplicados; o
/// `ActionChip` no fim zera todos na hora (D-18) — nenhum dos três mexe em
/// busca ou ordenação.
class ChipsFiltrosAtivos extends StatelessWidget {
  const ChipsFiltrosAtivos({
    super.key,
    required this.filtros,
    required this.aoRemover,
    required this.aoTocar,
    required this.aoLimpar,
  });

  final FiltrosVitrine filtros;
  final ValueChanged<FiltroAtivo> aoRemover;
  final VoidCallback aoTocar;
  final VoidCallback aoLimpar;

  @override
  Widget build(BuildContext context) {
    final chips = chipsDosFiltros(filtros);
    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final chip in chips) ...[
              InputChip(
                label: Text(chip.rotulo),
                onPressed: aoTocar,
                onDeleted: () => aoRemover(chip.filtro),
                deleteButtonTooltipMessage: 'Remover filtro ${chip.rotulo}',
              ),
              const SizedBox(width: 8),
            ],
            ActionChip(
              label: const Text('Limpar filtros'),
              onPressed: aoLimpar,
            ),
          ],
        ),
      ),
    );
  }
}
