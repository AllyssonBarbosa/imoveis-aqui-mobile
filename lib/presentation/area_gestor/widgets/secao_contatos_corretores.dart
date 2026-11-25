import 'package:flutter/material.dart';

import '../../../domain/entities/contatos_por_corretor.dart';
import '../../../domain/entities/periodo_contatos.dart';
import '../../contatos/apresentacao_contatos.dart';
import '../apresentacao_area_gestor.dart';
import '../area_gestor_state.dart';
import 'moldura_secao.dart';

/// Seção "Contatos por corretor" (GES-03, GES-04, D-16, D-17): no topo o chip
/// "Período" (o mesmo da caixa de contatos) e a linha que diz qual período vale
/// — os dois ficam visíveis mesmo quando a seção está carregando ou em falha —;
/// depois uma linha por corretor, a linha da empresa com texto fixo e o rodapé
/// com os totais do servidor. As linhas não reagem a toque (D-08).
///
/// Só apresenta o [periodo] que recebe: quem o aplica e recarrega é o Cubit.
class SecaoContatosCorretores extends StatelessWidget {
  const SecaoContatosCorretores({
    super.key,
    required this.estado,
    required this.periodo,
    required this.aoTocarPeriodo,
    required this.aoLimparPeriodo,
    required this.aoTentarDeNovo,
  });

  final EstadoSecao<ContatosPorCorretor> estado;

  /// Período aplicado; `null` = todo o período.
  final PeriodoContatos? periodo;

  /// Toque no corpo do chip: abre o seletor de período.
  final VoidCallback aoTocarPeriodo;

  /// "x" do chip: volta a todo o período.
  final VoidCallback aoLimparPeriodo;

  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final temPeriodo = periodo != null;
    final textTheme = Theme.of(context).textTheme;

    return MolduraSecao<ContatosPorCorretor>(
      titulo: tituloSecaoContatos,
      estado: estado,
      aoTentarDeNovo: aoTentarDeNovo,
      cabecalho: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputChip(
            label: Text(rotuloChipPeriodo(periodo)),
            selected: temPeriodo,
            onPressed: aoTocarPeriodo,
            onDeleted: temPeriodo ? aoLimparPeriodo : null,
            deleteButtonTooltipMessage: tooltipLimparPeriodo,
          ),
          const SizedBox(height: 4),
          Text(textoDoPeriodo(periodo), style: textTheme.bodySmall),
        ],
      ),
      construirConteudo: (contatos) {
        if (contatos.linhas.isEmpty) {
          return Text(textoNenhumCorretor, style: textTheme.bodyMedium);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < contatos.linhas.length; i++) ...[
              if (i > 0) const Divider(),
              _LinhaDeContatos(linha: contatos.linhas[i]),
            ],
            const Divider(),
            Text(
              textoTotalContatos(contatos.total, contatos.pendentes),
              style: textTheme.titleSmall,
            ),
          ],
        );
      },
    );
  }
}

class _LinhaDeContatos extends StatelessWidget {
  const _LinhaDeContatos({required this.linha});

  final ContatosDoCorretor linha;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // A linha da empresa usa texto fixo; o nome que o servidor mandou nela
    // nem é guardado (D-17, T-12-20).
    final nome = linha.daEmpresa
        ? textoLinhaDaEmpresa
        : nomeDoCorretor(linha.nome ?? '', ativo: linha.ativo);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nome,
            style: textTheme.bodyLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            textoContatosDoCorretor(linha.total, linha.pendentes),
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
