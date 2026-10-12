import 'package:flutter/material.dart';

import '../apresentacao_natureza.dart';

/// Seção da página do imóvel: título em `titleMedium` e o conteúdo logo
/// abaixo, com o respiro horizontal e vertical comum a todas as seções.
class SecaoDetalhe extends StatelessWidget {
  const SecaoDetalhe({super.key, required this.titulo, required this.conteudo});

  final String titulo;
  final Widget conteudo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          conteudo,
        ],
      ),
    );
  }
}

/// Seção "Descrição" (D-14) — texto simples, nunca HTML nem links; some por
/// inteiro quando a descrição vem vazia.
class SecaoDescricao extends StatelessWidget {
  const SecaoDescricao({super.key, required this.descricao});

  final String descricao;

  @override
  Widget build(BuildContext context) {
    if (descricao.trim().isEmpty) return const SizedBox.shrink();
    return SecaoDetalhe(
      titulo: 'Descrição',
      conteudo: Text(descricao, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

/// Seção "Características" (D-14): um `Chip` por característica, em linhas
/// que quebram; some por inteiro quando a lista vem vazia.
class SecaoCaracteristicas extends StatelessWidget {
  const SecaoCaracteristicas({super.key, required this.caracteristicas});

  final List<String> caracteristicas;

  @override
  Widget build(BuildContext context) {
    if (caracteristicas.isEmpty) return const SizedBox.shrink();
    return SecaoDetalhe(
      titulo: 'Características',
      conteudo: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final nome in caracteristicas) Chip(label: Text(nome))],
      ),
    );
  }
}

/// Lista de linhas rótulo/valor (rótulo à esquerda em `onSurfaceVariant`,
/// valor alinhado à direita) — compartilhada pela seção da natureza e pelos
/// cards. Quem chama decide se a lista vazia some.
class LinhasDeDados extends StatelessWidget {
  const LinhasDeDados({super.key, required this.linhas});

  final List<LinhaDado> linhas;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final linha in linhas)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    linha.rotulo,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    linha.valor,
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
