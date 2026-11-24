import 'package:flutter/material.dart';

import '../../../domain/entities/consulta_contatos.dart';
import '../apresentacao_contatos.dart';

/// Linha horizontal rolável com os dois chips de filtro da caixa, "Imóvel" e
/// "Período" (D-18). Os dois ficam sempre visíveis: sem valor aparecem não
/// selecionados e sem "x"; com valor ficam selecionados, mostram o código ou as
/// datas e o "x" limpa só aquele filtro. Tocar no corpo do chip abre a escolha.
/// Só apresenta a [consulta]: quem filtra é o servidor (D-13).
class ChipsFiltrosContatos extends StatelessWidget {
  const ChipsFiltrosContatos({
    super.key,
    required this.consulta,
    required this.aoTocarImovel,
    required this.aoLimparImovel,
    required this.aoTocarPeriodo,
    required this.aoLimparPeriodo,
  });

  final ConsultaContatos consulta;
  final VoidCallback aoTocarImovel;
  final VoidCallback aoLimparImovel;
  final VoidCallback aoTocarPeriodo;
  final VoidCallback aoLimparPeriodo;

  @override
  Widget build(BuildContext context) {
    final temImovel = consulta.imovel != null;
    final temPeriodo = consulta.periodo != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InputChip(
              label: Text(rotuloChipImovel(consulta.imovel)),
              selected: temImovel,
              onPressed: aoTocarImovel,
              onDeleted: temImovel ? aoLimparImovel : null,
              deleteButtonTooltipMessage: tooltipLimparImovel,
            ),
            const SizedBox(width: 8),
            InputChip(
              label: Text(rotuloChipPeriodo(consulta.periodo)),
              selected: temPeriodo,
              onPressed: aoTocarPeriodo,
              onDeleted: temPeriodo ? aoLimparPeriodo : null,
              deleteButtonTooltipMessage: tooltipLimparPeriodo,
            ),
          ],
        ),
      ),
    );
  }
}
