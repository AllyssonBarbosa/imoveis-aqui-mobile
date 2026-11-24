import 'package:flutter/material.dart';

/// Rodapé de uma lista paginada (PERF-03, D-12): carregando-mais (spinner
/// pequeno), erro-ao-carregar-mais (mensagem + "Tentar de novo") ou
/// fim-da-lista — mutuamente exclusivos, nessa ordem de prioridade. Mesmos
/// textos e comportamento do rodapé da vitrine da cidade; a única diferença é
/// que o retry chega por [aoTentarDeNovo], então o componente não conhece o
/// Cubit de nenhuma lista (serve à página do corretor e à da empresa).
class RodapePaginacaoLista extends StatelessWidget {
  const RodapePaginacaoLista({
    super.key,
    required this.carregandoMais,
    required this.erroAoCarregarMais,
    required this.temProximaPagina,
    required this.aoTentarDeNovo,
    this.mensagemErro = 'Não foi possível carregar mais imóveis',
  });

  final bool carregandoMais;
  final bool erroAoCarregarMais;
  final bool temProximaPagina;

  /// "Tentar de novo" — único caminho de nova tentativa depois de uma falha.
  final VoidCallback aoTentarDeNovo;

  /// Texto do erro-ao-carregar-mais. O padrão é o da vitrine, do acervo e dos
  /// perfis; a caixa de contatos passa o seu.
  final String mensagemErro;

  @override
  Widget build(BuildContext context) {
    if (carregandoMais) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (erroAoCarregarMais) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensagemErro,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: aoTentarDeNovo,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    }

    if (!temProximaPagina) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Você chegou ao fim da lista',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
