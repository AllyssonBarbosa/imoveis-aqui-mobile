import 'package:flutter/material.dart';

import '../../../domain/entities/imovel.dart';

/// Card do imóvel (VIT-02) — versão mínima do tracer (Task 1): apenas título
/// e bairro. Task 2 completa o layout com foto de capa, preço(s) e
/// natureza/quartos (D-01..D-04).
class ImovelCard extends StatelessWidget {
  const ImovelCard({super.key, required this.imovel});

  final Imovel imovel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
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
            Text(
              imovel.bairro,
              style: textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
