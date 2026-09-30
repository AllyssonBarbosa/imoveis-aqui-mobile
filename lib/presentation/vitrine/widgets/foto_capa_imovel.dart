import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
      child: url == null
          ? _PlaceholderCasa(colorScheme: Theme.of(context).colorScheme)
          : (construirImagemDeRede?.call(url!) ??
                CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  placeholder: (context, _) =>
                      _PlaceholderCasa(colorScheme: Theme.of(context).colorScheme),
                  errorWidget: (context, _, _) =>
                      _PlaceholderCasa(colorScheme: Theme.of(context).colorScheme),
                )),
    );
  }
}

class _PlaceholderCasa extends StatelessWidget {
  const _PlaceholderCasa({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.home_outlined,
          size: 48,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
