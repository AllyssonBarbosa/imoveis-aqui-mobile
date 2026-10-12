import 'package:flutter/material.dart';

/// Esqueleto (fase RED) — a implementação real vem no commit seguinte.
class ImagemPadraoImovel extends StatelessWidget {
  const ImagemPadraoImovel({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Esqueleto (fase RED) — a implementação real vem no commit seguinte.
class ImagemRede extends StatelessWidget {
  const ImagemRede({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.imagemPadrao,
    @visibleForTesting this.construirImagemDeRede,
  });

  final String? url;
  final BoxFit fit;
  final Widget? imagemPadrao;

  @visibleForTesting
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
