import 'package:flutter/material.dart';

import 'dialogo_sair.dart';

/// Destino só do administrador depois do login (D-02): as rotas da Área do
/// gestor usam `EhGestor` e o administrador não tem empresa, então a área dele
/// não existe no app — a tela só avisa e oferece Sair. O gestor vai à
/// `AreaGestorScreen` (APP-12).
class AvisoAreaScreen extends StatelessWidget {
  const AvisoAreaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Área do administrador')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: tema.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'A área do administrador não está no app.',
                style: tema.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => confirmarESair(context),
                child: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
