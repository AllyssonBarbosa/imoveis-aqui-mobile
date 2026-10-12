import 'package:flutter/material.dart';

import '../../../domain/entities/dados_natureza.dart';
import '../apresentacao_natureza.dart';
import 'secoes_detalhe.dart';

/// Seção "Sobre a casa / o apartamento / o terreno / o lote" (D-13): linha de
/// destaques com ícone e, abaixo, a ficha rótulo/valor. Só desenha o que as
/// funções puras de `apresentacao_natureza.dart` decidiram; sem nada para
/// mostrar a seção some inteira (D-14).
class SecaoNatureza extends StatelessWidget {
  const SecaoNatureza({super.key, required this.dados});

  final DadosNatureza dados;

  @override
  Widget build(BuildContext context) {
    final destaques = destaquesDe(dados);
    final linhas = linhasDe(dados);
    if (destaques.isEmpty && linhas.isEmpty) return const SizedBox.shrink();

    return SecaoDetalhe(
      titulo: tituloSecaoNatureza(dados),
      conteudo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (destaques.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  for (final destaque in destaques)
                    _TileDestaque(destaque: destaque),
                ],
              ),
            ),
          if (linhas.isNotEmpty) LinhasDeDados(linhas: linhas),
        ],
      ),
    );
  }
}

class _TileDestaque extends StatelessWidget {
  const _TileDestaque({required this.destaque});

  final Destaque destaque;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(destaque.icone, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(destaque.valor, style: textTheme.titleMedium),
        Text(destaque.rotulo, style: textTheme.bodySmall),
      ],
    );
  }
}
