import 'package:flutter/material.dart';

import '../../../domain/entities/mudancas_recentes.dart';
import '../apresentacao_area_gestor.dart';
import '../area_gestor_state.dart';
import 'moldura_secao.dart';

/// Seção "Mudanças de situação — últimos N dias" (GES-05, D-21): os itens na
/// ordem do servidor, cada um com "código — título", "Disponível → Reservado",
/// quando e quem mudou (hora local) e, só se houver, a observação. O N é a
/// janela que o servidor usou; carregando ou em falha o título vai sem ele. Os
/// itens não reagem a toque (D-08) e a seção não pagina: a janela de dias já a
/// limita (D-20).
class SecaoMudancas extends StatelessWidget {
  const SecaoMudancas({
    super.key,
    required this.estado,
    required this.aoTentarDeNovo,
  });

  final EstadoSecao<MudancasRecentes> estado;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final dias = switch (estado) {
      SecaoCarregada<MudancasRecentes>(:final dados) => dados.dias,
      _ => null,
    };

    return MolduraSecao<MudancasRecentes>(
      titulo: tituloSecaoMudancas(dias),
      estado: estado,
      aoTentarDeNovo: aoTentarDeNovo,
      construirConteudo: (recentes) {
        if (recentes.mudancas.isEmpty) {
          return Text(
            textoNenhumaMudanca(recentes.dias),
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < recentes.mudancas.length; i++) ...[
              if (i > 0) const Divider(),
              _ItemDaMudanca(mudanca: recentes.mudancas[i]),
            ],
          ],
        );
      },
    );
  }
}

/// Uma mudança: imóvel, de → para, quando e quem e, só se houver, a observação
/// (texto simples — nada do servidor vira marcação nem link).
class _ItemDaMudanca extends StatelessWidget {
  const _ItemDaMudanca({required this.mudanca});

  final MudancaRecente mudanca;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotuloImovelDaMudanca(mudanca),
            style: textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(textoDeParaMudanca(mudanca), style: textTheme.bodyMedium),
          Text(
            textoQuandoEQuemMudanca(mudanca),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (mudanca.observacao.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(mudanca.observacao, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
