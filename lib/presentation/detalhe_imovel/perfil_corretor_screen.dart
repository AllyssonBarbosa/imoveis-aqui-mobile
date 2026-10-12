import 'package:flutter/material.dart';

import '../../domain/entities/detalhe_imovel.dart';

// Esqueletos (RED): só compilam; o comportamento vem no commit GREEN.
Future<void> abrirPerfilCorretor(
  BuildContext context,
  CorretorResponsavel corretor, {
  Widget Function(String url)? construirImagemDeRede,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PerfilCorretorScreen(
        corretor: corretor,
        construirImagemDeRede: construirImagemDeRede,
      ),
    ),
  );
}

class PerfilCorretorScreen extends StatelessWidget {
  const PerfilCorretorScreen({
    super.key,
    required this.corretor,
    this.construirImagemDeRede,
  });

  final CorretorResponsavel corretor;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) => const Scaffold();
}
