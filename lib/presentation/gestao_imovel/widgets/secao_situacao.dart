import 'package:flutter/material.dart';

import '../../../domain/entities/imovel_gestao.dart';
import '../../acervo/apresentacao_acervo.dart';
import '../apresentacao_gestao.dart';

/// Seção "Situação" (D-03, D-05): a situação atual (marca, quando o servidor
/// mandou uma conhecida) e "desde dd/MM/yyyy HH:mm" com a data do servidor.
class SecaoSituacao extends StatelessWidget {
  const SecaoSituacao({super.key, required this.imovel});

  final ImovelGestao imovel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final situacao = imovel.situacao;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tituloSecaoSituacao, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (situacao != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    rotuloSituacao(situacao),
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            Text(textoDesde(imovel.situacaoDesde), style: textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}
