import 'package:flutter/material.dart';

/// Esqueleto (fase RED) — a implementação real vem no commit seguinte.
Future<void> abrirVisualizadorFotos(
  BuildContext context, {
  required List<String> urls,
  required int indiceInicial,
  Widget Function(String url)? construirImagemDeRede,
}) async {}

/// Esqueleto (fase RED) — a implementação real vem no commit seguinte.
class VisualizadorFotos extends StatelessWidget {
  const VisualizadorFotos({
    super.key,
    required this.urls,
    required this.indiceInicial,
    this.construirImagemDeRede,
  });

  final List<String> urls;
  final int indiceInicial;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
