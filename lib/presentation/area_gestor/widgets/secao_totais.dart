import 'package:flutter/material.dart';

import '../../../domain/entities/situacao_imovel.dart';
import '../../../domain/entities/totais_por_situacao.dart';
import '../../acervo/apresentacao_acervo.dart';
import '../apresentacao_area_gestor.dart';
import '../area_gestor_state.dart';
import 'moldura_secao.dart';

/// Seção "Totais da empresa por situação" (GES-01, D-10): quatro blocos
/// (número e rótulo) numa grade 2x2 na ordem Disponível, Reservado, Vendido e
/// Alugado, e abaixo o "Total: N imóveis". Todos os números são os do
/// servidor — o widget não soma nem confere nada.
class SecaoTotais extends StatelessWidget {
  const SecaoTotais({
    super.key,
    required this.estado,
    required this.aoTentarDeNovo,
  });

  final EstadoSecao<TotaisPorSituacao> estado;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return MolduraSecao<TotaisPorSituacao>(
      titulo: tituloSecaoTotais,
      estado: estado,
      aoTentarDeNovo: aoTentarDeNovo,
      construirConteudo: (totais) {
        const situacoes = SituacaoImovel.values;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LinhaDeBlocos(
              totais: totais,
              situacoes: situacoes.sublist(0, 2),
            ),
            const SizedBox(height: 8),
            _LinhaDeBlocos(
              totais: totais,
              situacoes: situacoes.sublist(2, 4),
            ),
            const SizedBox(height: 12),
            Text(
              textoTotalImoveis(totais.total),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        );
      },
    );
  }
}

/// Dois blocos lado a lado, com a mesma largura.
class _LinhaDeBlocos extends StatelessWidget {
  const _LinhaDeBlocos({required this.totais, required this.situacoes});

  final TotaisPorSituacao totais;
  final List<SituacaoImovel> situacoes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < situacoes.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _BlocoDeTotal(
              situacao: situacoes[i],
              quantidade: totais.porSituacao[situacoes[i]] ?? 0,
            ),
          ),
        ],
      ],
    );
  }
}

/// Um número grande com o rótulo da situação embaixo.
class _BlocoDeTotal extends StatelessWidget {
  const _BlocoDeTotal({required this.situacao, required this.quantidade});

  final SituacaoImovel situacao;
  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$quantidade', style: textTheme.headlineSmall),
            Text(rotuloSituacao(situacao), style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
