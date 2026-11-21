import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../detalhe_imovel/detalhe_imovel_screen.dart';
import '../../vitrine/widgets/imovel_card.dart';
import '../vitrine_anunciante_cubit.dart';
import '../vitrine_anunciante_state.dart';
import 'rodape_paginacao_lista.dart';

/// Vitrine "Imóveis de {nome}" em slivers: título + o estado da busca
/// (carregando, vazia, erro ou os cards na ORDEM RECEBIDA — nada é filtrado
/// nem reordenado aqui). Lê o [VitrineAnuncianteCubit] do contexto; deve
/// ficar dentro de uma `CustomScrollView`.
class SliverImoveisDoAnunciante extends StatelessWidget {
  const SliverImoveisDoAnunciante({
    super.key,
    required this.titulo,
    required this.aoAbrirImovel,
  });

  final String titulo;

  /// Abre a página do imóvel tocado (padrão `abrirDetalheImovel`).
  final AoAbrirImovel aoAbrirImovel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<VitrineAnuncianteCubit, VitrineAnuncianteState>(
      builder: (context, estado) {
        final Widget corpo = switch (estado) {
          VitrineAnuncianteCarregando() => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          VitrineAnuncianteVazia() => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Text(
                'Nenhum imóvel anunciado no momento.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          VitrineAnuncianteErro() => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Não foi possível carregar os imóveis.',
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => context
                        .read<VitrineAnuncianteCubit>()
                        .tentarNovamente(),
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ),
            ),
          ),
          VitrineAnuncianteCarregada(
            :final itens,
            :final proximaPagina,
            :final carregandoMais,
            :final erroAoCarregarMais,
          ) =>
            SliverList.builder(
              itemCount: itens.length + 1,
              itemBuilder: (context, indice) {
                if (indice == itens.length) {
                  return RodapePaginacaoLista(
                    carregandoMais: carregandoMais,
                    erroAoCarregarMais: erroAoCarregarMais,
                    temProximaPagina: proximaPagina != null,
                    aoTentarDeNovo: () => context
                        .read<VitrineAnuncianteCubit>()
                        .tentarNovamente(),
                  );
                }
                final imovel = itens[indice];
                return ImovelCard(
                  key: ValueKey('imovel-anunciante-${imovel.id}'),
                  imovel: imovel,
                  onTap: () => aoAbrirImovel(context, imovel),
                );
              },
            ),
        };
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(titulo, style: textTheme.titleMedium),
              ),
            ),
            corpo,
          ],
        );
      },
    );
  }
}
