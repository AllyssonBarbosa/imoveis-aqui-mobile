import 'package:flutter/material.dart';

import '../../../domain/entities/dados_natureza.dart';
import '../apresentacao_natureza.dart';
import 'secoes_detalhe.dart';

/// Card do prédio do apartamento (D-13). Some quando o prédio não tem nenhuma
/// linha para mostrar (D-14).
class CardPredio extends StatelessWidget {
  const CardPredio({super.key, required this.predio});

  final DadosPredio predio;

  @override
  Widget build(BuildContext context) {
    final linhas = linhasDoPredio(predio);
    if (linhas.isEmpty) return const SizedBox.shrink();

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prédio', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            LinhasDeDados(linhas: linhas),
          ],
        ),
      ),
    );
  }
}

/// Card da quadra e do loteamento do lote (D-13): linhas de quadra,
/// loteamento e incorporadora, depois infraestrutura e áreas de lazer como
/// `Chip`s. Cada lista vazia é omitida e o card inteiro some quando não há
/// nada a mostrar (D-14).
class CardQuadraLoteamento extends StatelessWidget {
  const CardQuadraLoteamento({super.key, required this.quadra});

  final DadosQuadra quadra;

  @override
  Widget build(BuildContext context) {
    if (!quadraTemConteudo(quadra)) return const SizedBox.shrink();

    final linhas = linhasDaQuadra(quadra);
    final infraestrutura = quadra.loteamento?.infraestrutura ?? const [];
    final areasLazer = quadra.loteamento?.areasLazer ?? const [];

    final textTheme = Theme.of(context).textTheme;
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quadra e loteamento', style: textTheme.titleSmall),
            if (linhas.isNotEmpty) ...[
              const SizedBox(height: 8),
              LinhasDeDados(linhas: linhas),
            ],
            if (infraestrutura.isNotEmpty)
              _ListaDeChips(titulo: 'Infraestrutura', itens: infraestrutura),
            if (areasLazer.isNotEmpty)
              _ListaDeChips(titulo: 'Áreas de lazer', itens: areasLazer),
          ],
        ),
      ),
    );
  }
}

class _ListaDeChips extends StatelessWidget {
  const _ListaDeChips({required this.titulo, required this.itens});

  final String titulo;
  final List<String> itens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final item in itens) Chip(label: Text(item))],
          ),
        ],
      ),
    );
  }
}
