import 'package:flutter/material.dart';

import '../../../domain/entities/imovel_acervo.dart';
import '../../comum/imagem_rede.dart';
import '../../vitrine/apresentacao_imovel.dart';
import '../apresentacao_acervo.dart';

/// Cartão compacto em linha do acervo (D-05): miniatura quadrada à esquerda e,
/// à direita, código, título (até 2 linhas), preço e as marcas.
///
/// As marcas são só as do card (D-06): a situação (quando o servidor mandou
/// uma conhecida) e "Seu" quando [ImovelAcervo.meuImovel]. O cartão só reage ao
/// toque quando o servidor diz [ImovelAcervo.naVitrine] (D-07); senão não tem
/// `InkWell` nem ripple. Nada aqui compara ids nem olha situação ou
/// publicação para decidir marca ou toque.
class CartaoImovelAcervo extends StatelessWidget {
  const CartaoImovelAcervo({
    super.key,
    required this.imovel,
    this.aoTocar,
    this.construirImagemDeRede,
  });

  final ImovelAcervo imovel;

  /// Toque no cartão (abre a página pública); só é usado se `naVitrine`.
  final VoidCallback? aoTocar;

  /// Ponto de extensão só para teste — troca `CachedNetworkImage` por um
  /// builder determinístico (ver `ImagemRede`). Em produção fica `null`.
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final aoTocarNaVitrine = aoTocar;
    final conteudo = _LinhaDoCartao(
      imovel: imovel,
      construirImagemDeRede: construirImagemDeRede,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: (imovel.naVitrine && aoTocarNaVitrine != null)
          ? InkWell(onTap: aoTocarNaVitrine, child: conteudo)
          : conteudo,
    );
  }
}

class _LinhaDoCartao extends StatelessWidget {
  const _LinhaDoCartao({
    required this.imovel,
    required this.construirImagemDeRede,
  });

  final ImovelAcervo imovel;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final situacao = imovel.situacao;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.square(
              dimension: 96,
              child: ImagemRede(
                url: imovel.fotoCapa,
                construirImagemDeRede: construirImagemDeRede,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imovel.codigo,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  imovel.titulo,
                  style: textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                for (final linha in linhasDePrecoPorFinalidade(
                  finalidade: imovel.finalidade,
                  precoVenda: imovel.precoVenda,
                  precoAluguel: imovel.precoAluguel,
                ))
                  Text(linha, style: textTheme.bodyMedium),
                if (situacao != null || imovel.meuImovel) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (situacao != null)
                        _MarcaDoCartao(
                          rotulo: rotuloSituacao(situacao),
                          fundo: colorScheme.secondaryContainer,
                          texto: colorScheme.onSecondaryContainer,
                        ),
                      if (imovel.meuImovel)
                        _MarcaDoCartao(
                          rotulo: rotuloMarcaSeu,
                          fundo: colorScheme.primaryContainer,
                          texto: colorScheme.onPrimaryContainer,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Marca pequena do cartão (situação ou "Seu") — só texto sobre fundo do
/// `ColorScheme`, sem interação.
class _MarcaDoCartao extends StatelessWidget {
  const _MarcaDoCartao({
    required this.rotulo,
    required this.fundo,
    required this.texto,
  });

  final String rotulo;
  final Color fundo;
  final Color texto;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          rotulo,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: texto),
        ),
      ),
    );
  }
}
