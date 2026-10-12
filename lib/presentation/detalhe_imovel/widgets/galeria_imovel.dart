import 'package:flutter/material.dart';

/// Esqueleto (fase RED) — a implementação real vem no commit seguinte.
class GaleriaImovel extends StatelessWidget {
  const GaleriaImovel({
    super.key,
    required this.urls,
    this.aoTocarFoto,
    @visibleForTesting this.construirImagemDeRede,
  });

  final List<String> urls;
  final ValueChanged<int>? aoTocarFoto;

  @visibleForTesting
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
