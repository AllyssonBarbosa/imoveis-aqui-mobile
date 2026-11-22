import 'package:flutter/material.dart';

import '../../../domain/entities/situacao_imovel.dart';
import '../apresentacao_acervo.dart';

/// Linha rolável de chips de escolha única (D-09): Todas, Disponível,
/// Reservado, Vendido, Alugado. O chip de [selecionada] (ou "Todas" quando
/// nula) fica marcado; tocar em outro chama [aoEscolher] na hora — quem
/// reconsulta é o Cubit, nunca este widget.
class ChipsSituacao extends StatelessWidget {
  const ChipsSituacao({
    super.key,
    required this.selecionada,
    required this.aoEscolher,
  });

  final SituacaoImovel? selecionada;
  final ValueChanged<SituacaoImovel?> aoEscolher;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final opcao in opcoesDeSituacao) ...[
            ChoiceChip(
              key: ValueKey('chip-situacao-${opcao?.name ?? 'todas'}'),
              label: Text(rotuloOpcaoDeSituacao(opcao)),
              selected: opcao == selecionada,
              onSelected: (_) => aoEscolher(opcao),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
