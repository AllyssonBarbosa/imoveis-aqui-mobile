import 'package:flutter/material.dart';

import '../../../domain/entities/detalhe_imovel.dart';

// Esqueletos (RED): só compilam; o comportamento vem no commit GREEN.
class AvatarCorretor extends StatelessWidget {
  const AvatarCorretor({
    super.key,
    required this.foto,
    this.raio = 24,
    this.construirImagemDeRede,
  });

  final String? foto;
  final double raio;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class CartaoCorretor extends StatelessWidget {
  const CartaoCorretor({
    super.key,
    required this.corretor,
    required this.aoTocar,
    this.construirImagemDeRede,
  });

  final CorretorResponsavel corretor;
  final VoidCallback aoTocar;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
