import 'package:flutter/material.dart';

import '../../../domain/entities/imovel.dart';
import '../apresentacao_imovel.dart';
import 'foto_capa_imovel.dart';

/// Card completo do imóvel (VIT-02, D-01): foto de capa larga (16:9) no
/// topo, título, linha(s) de preço, e uma linha de metadados juntando
/// natureza · bairro · quartos — sempre nessa ordem, em todos os cards.
/// Nenhuma lógica de negócio ou chamada de rede aqui: tudo já vem pronto do
/// servidor, formatado por `apresentacao_imovel.dart`.
class ImovelCard extends StatelessWidget {
  const ImovelCard({super.key, required this.imovel});

  final Imovel imovel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final metadados = [
      rotuloNatureza(imovel.natureza),
      imovel.bairro,
      rotuloQuartos(imovel.quartos),
    ].whereType<String>().where((texto) => texto.isNotEmpty).join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FotoCapaImovel(url: imovel.fotoCapa),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imovel.titulo,
                  style: textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                for (final linha in linhasDePreco(imovel))
                  Text(
                    linha,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                if (metadados.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    metadados,
                    style: textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
