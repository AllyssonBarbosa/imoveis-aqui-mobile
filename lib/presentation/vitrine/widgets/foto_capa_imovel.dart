import 'package:flutter/material.dart';

import '../../comum/imagem_rede.dart';

/// Foto de capa do card (D-04) — `AspectRatio` único de 16:9 envolvendo TODOS
/// os três estados (placeholder, carregando, erro), para que a altura do
/// slot seja idêntica em qualquer desfecho (RESEARCH Pitfall 6). `url` nula
/// ou carregamento com falha caem no mesmo placeholder verde claro com ícone
/// de casa.
class FotoCapaImovel extends StatelessWidget {
  const FotoCapaImovel({
    super.key,
    required this.url,
    @visibleForTesting this.construirImagemDeRede,
  });

  final String? url;

  /// Ponto de extensão só para teste — permite substituir
  /// `CachedNetworkImage` (que depende de plugins nativos indisponíveis em
  /// `flutter test`) por um builder determinístico. Em produção fica sempre
  /// `null`, e a foto real usa `CachedNetworkImage`.
  @visibleForTesting
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ImagemRede(url: url, construirImagemDeRede: construirImagemDeRede),
    );
  }
}
