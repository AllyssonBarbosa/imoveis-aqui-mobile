import 'package:flutter/material.dart';

import '../../../domain/entities/imovel_acervo.dart';
import '../../../domain/entities/imovel_gestao.dart';
import '../../comum/imagem_rede.dart';
import '../../vitrine/apresentacao_imovel.dart';

/// Cabeçalho da tela de gestão (D-03): foto de capa (a do cartão), código,
/// título e preço. Nada de endereço, descrição ou dados por natureza.
///
/// Usa os dados de [imovel] quando já carregado, senão os da [previa] — o
/// cabeçalho não "pula" quando o detalhe chega.
class CabecalhoGestao extends StatelessWidget {
  const CabecalhoGestao({
    super.key,
    required this.previa,
    this.imovel,
    this.urlDaCapa,
    this.temCapaAtualizada = false,
    this.construirImagemDeRede,
  });

  final ImovelAcervo previa;
  final ImovelGestao? imovel;

  /// Capa marcada pelo servidor depois de mexer nas fotos (APP 11); com
  /// [temCapaAtualizada] substitui a capa do cartão do acervo (`null` = sem
  /// fotos, imagem padrão).
  final String? urlDaCapa;
  final bool temCapaAtualizada;

  /// Ponto de extensão só para teste (ver `ImagemRede`); em produção `null`.
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lido = imovel;
    final codigo = lido?.codigo ?? previa.codigo;
    final titulo = lido?.titulo ?? previa.titulo;
    final linhasDePreco = linhasDePrecoPorFinalidade(
      finalidade: lido?.finalidade ?? previa.finalidade,
      precoVenda: lido != null ? lido.precoVenda : previa.precoVenda,
      precoAluguel: lido != null ? lido.precoAluguel : previa.precoAluguel,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ImagemRede(
              url: temCapaAtualizada ? urlDaCapa : previa.fotoCapa,
              construirImagemDeRede: construirImagemDeRede,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          codigo,
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(titulo, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        for (final linha in linhasDePreco)
          Text(linha, style: textTheme.bodyMedium),
      ],
    );
  }
}
