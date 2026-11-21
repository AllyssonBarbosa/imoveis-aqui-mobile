import 'package:flutter/material.dart';

/// 404 do perfil (D-15): corretor ou empresa que não está mais disponível —
/// repetir não resolve, então só oferece o caminho de volta ("Voltar" fecha o
/// perfil). Compartilhado pelos perfis do corretor e da empresa.
class AvisoPerfil extends StatelessWidget {
  const AvisoPerfil({super.key, required this.icone, required this.mensagem});

  final IconData icone;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              mensagem,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.maybePop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Falha de carregamento do perfil (D-15): mensagem e "Tentar de novo", que
/// repete a mesma busca. Compartilhado pelos perfis do corretor e da empresa.
class ErroPerfil extends StatelessWidget {
  const ErroPerfil({
    super.key,
    required this.mensagem,
    required this.aoTentarDeNovo,
  });

  final String mensagem;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mensagem,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: aoTentarDeNovo,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }
}
