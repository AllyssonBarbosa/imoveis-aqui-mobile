import 'package:flutter/material.dart';

import '../../../domain/entities/mudanca_situacao.dart';
import '../apresentacao_gestao.dart';
import '../gestao_imovel_state.dart';

/// Seção "Histórico" da tela de gestão (SIT-03, D-11): lista simples das
/// mudanças de situação NA ORDEM que o servidor mandou — não reordena, não
/// filtra e não pagina. A tela já rola, então os itens são uma `Column`, não
/// uma lista aninhada.
class HistoricoSituacao extends StatelessWidget {
  const HistoricoSituacao({
    super.key,
    required this.conteudo,
    required this.aoTentarDeNovo,
  });

  final ConteudoHistorico conteudo;

  /// "Tentar de novo" da falha só do histórico.
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tituloHistorico, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        switch (conteudo) {
          HistoricoCarregando() => const Center(
            child: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          HistoricoErro() => Row(
            children: [
              Expanded(
                child: Text(textoErroHistorico, style: textTheme.bodyMedium),
              ),
              TextButton(
                onPressed: aoTentarDeNovo,
                child: const Text(rotuloTentarDeNovo),
              ),
            ],
          ),
          HistoricoCarregado(:final itens) when itens.isEmpty => Text(
            textoHistoricoVazio,
            style: textTheme.bodyMedium,
          ),
          HistoricoCarregado(:final itens) => Column(
            children: [
              for (var i = 0; i < itens.length; i++) ...[
                if (i > 0) const Divider(),
                _ItemDoHistorico(mudanca: itens[i]),
              ],
            ],
          ),
        },
      ],
    );
  }
}

/// Uma mudança: de → para, quando e quem e, só se houver, a observação (texto
/// simples — nada do servidor vira marcação nem link, T-09-13).
class _ItemDoHistorico extends StatelessWidget {
  const _ItemDoHistorico({required this.mudanca});

  final MudancaSituacao mudanca;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(textoDeParaHistorico(mudanca), style: textTheme.titleSmall),
            Text(
              textoQuandoEQuem(mudanca),
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
      ),
    );
  }
}
