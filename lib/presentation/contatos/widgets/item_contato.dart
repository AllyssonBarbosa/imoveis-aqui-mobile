import 'package:flutter/material.dart';

import '../../../domain/entities/contato_recebido.dart';
import '../../../domain/entities/retorno_contato.dart';
import '../../contato/rotulos_contato.dart';
import '../apresentacao_contatos.dart';

/// Um contato da caixa (D-09, D-10): "código — título" do imóvel, o canal
/// (ícone + nome), quando chegou e o retorno anotado. Não mostra quem é o
/// corretor. Só apresenta: o toque sai por [aoTocar] (abre a edição na
/// tela, 10-09); sem ele, tocar não faz nada.
class ItemContato extends StatelessWidget {
  const ItemContato({super.key, required this.contato, this.aoTocar});

  final ContatoRecebido contato;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final textTheme = tema.textTheme;
    final retornoEm = contato.retornoEm;

    return Card(
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rotuloImovelDoContato(contato),
                style: textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    contato.canal.icone,
                    size: 18,
                    color: tema.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(contato.canal.nomeExibicao, style: textTheme.bodyMedium),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      formatarDataHoraContato(contato.criadoEm),
                      style: textTheme.bodyMedium?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ChipRetorno(retorno: contato.retorno),
                  if (retornoEm != null)
                    Text(
                      textoAnotadoEm(retornoEm),
                      style: textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip do retorno: "Aguardando retorno" destacado (o que pede ação do
/// corretor); os demais retornos ficam neutros.
class _ChipRetorno extends StatelessWidget {
  const _ChipRetorno({required this.retorno});

  final RetornoContato retorno;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final destaque = retorno == RetornoContato.pendente;
    final fundo = destaque
        ? cores.tertiaryContainer
        : cores.surfaceContainerHighest;
    final texto = destaque ? cores.onTertiaryContainer : cores.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          retorno.rotulo,
          style: tema.textTheme.labelMedium?.copyWith(color: texto),
        ),
      ),
    );
  }
}
