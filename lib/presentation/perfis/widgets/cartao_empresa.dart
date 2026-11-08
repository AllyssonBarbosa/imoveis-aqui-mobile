import 'package:flutter/material.dart';

/// Cartão tocável do perfil do corretor que leva à página do anunciante
/// (empresa). O rótulo é único e neutro — o perfil do corretor só conhece o
/// `empresa_id`, nunca o tipo da empresa — então "Imobiliária" ou "Corretor
/// autônomo" só aparece na página da empresa, onde a API informa o tipo.
class CartaoEmpresa extends StatelessWidget {
  const CartaoEmpresa({super.key, required this.aoTocar});

  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Ver página do anunciante',
      child: Card.outlined(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: aoTocar,
          child: ListTile(
            leading: Icon(Icons.apartment_outlined, color: colorScheme.primary),
            title: const Text('Ver página do anunciante'),
            subtitle: const Text('Imóveis, cidades de atuação e contato'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
