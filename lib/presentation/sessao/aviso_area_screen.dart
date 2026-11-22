import 'package:flutter/material.dart';

import 'dialogo_sair.dart';

/// Destino do gestor e do administrador depois do login (D-B): a área deles
/// ainda não existe no app, então a tela só avisa e oferece Sair. A área
/// própria (APP-12) troca esta tela sem mexer no login.
class AvisoAreaScreen extends StatelessWidget {
  const AvisoAreaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Área do gestor')),
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
                'A área do gestor ainda não está no app.',
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
