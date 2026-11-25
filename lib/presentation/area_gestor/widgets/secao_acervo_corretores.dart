import 'package:flutter/material.dart';

import '../../../domain/entities/acervo_por_corretor.dart';
import '../apresentacao_area_gestor.dart';
import '../area_gestor_state.dart';
import 'moldura_secao.dart';

/// Seção "Acervo por corretor" (GES-02, D-14): uma linha por corretor, na
/// ordem do servidor, com o nome ("(desativado)" quando `ativo` é falso) e a
/// quantidade de imóveis, e o rodapé com o total do servidor. As linhas não
/// reagem a toque (D-08).
class SecaoAcervoCorretores extends StatelessWidget {
  const SecaoAcervoCorretores({
    super.key,
    required this.estado,
    required this.aoTentarDeNovo,
  });

  final EstadoSecao<AcervoPorCorretor> estado;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return MolduraSecao<AcervoPorCorretor>(
      titulo: tituloSecaoAcervo,
      estado: estado,
      aoTentarDeNovo: aoTentarDeNovo,
      construirConteudo: (acervo) {
        final textTheme = Theme.of(context).textTheme;
        if (acervo.linhas.isEmpty) {
          return Text(textoNenhumCorretor, style: textTheme.bodyMedium);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < acervo.linhas.length; i++) ...[
              if (i > 0) const Divider(),
              _LinhaDoAcervo(linha: acervo.linhas[i]),
            ],
            const Divider(),
            Text(
              textoTotalImoveis(acervo.total),
              style: textTheme.titleSmall,
            ),
          ],
        );
      },
    );
  }
}

class _LinhaDoAcervo extends StatelessWidget {
  const _LinhaDoAcervo({required this.linha});

  final AcervoDoCorretor linha;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nomeDoCorretor(linha.nome, ativo: linha.ativo),
              style: textTheme.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            textoImoveisDoCorretor(linha.total),
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
