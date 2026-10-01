import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/filtros_vitrine.dart';
import '../../../domain/entities/imovel.dart';
import '../apresentacao_imovel.dart';
import '../rascunho_filtros_cubit.dart';

/// Segmento de apresentação do `SegmentedButton` de finalidade (FIL-01,
/// D-11) — "Qualquer" é um segmento REAL, nunca ausência de seleção
/// (RESEARCH Pattern 3/Pitfall 1: `SegmentedButton` lança se `selected`
/// ficar vazio sem `emptySelectionAllowed`).
enum _SegmentoFinalidade { qualquer, venda, aluguel }

FinalidadeFiltro? _paraFiltro(_SegmentoFinalidade segmento) =>
    switch (segmento) {
      _SegmentoFinalidade.qualquer => null,
      _SegmentoFinalidade.venda => FinalidadeFiltro.venda,
      _SegmentoFinalidade.aluguel => FinalidadeFiltro.aluguel,
    };

_SegmentoFinalidade _segmentoDe(FinalidadeFiltro? finalidade) =>
    switch (finalidade) {
      null => _SegmentoFinalidade.qualquer,
      FinalidadeFiltro.venda => _SegmentoFinalidade.venda,
      FinalidadeFiltro.aluguel => _SegmentoFinalidade.aluguel,
    };

/// Bottom sheet de filtros (D-07, D-08, D-11) — tela cheia
/// (`isScrollControlled`/`useSafeArea`), seções roláveis com rodapé fixo
/// "Limpar"/"Ver imóveis". Edita um [RascunhoFiltrosCubit] local e só chama
/// [aoAplicar] UMA vez, ao tocar "Ver imóveis"; fechar de qualquer outra
/// forma (arrastar, barreira, "Fechar") descarta o rascunho sem aplicar
/// (D-08).
///
/// [aplicados]/[aoAplicar] devem vir capturados do contexto da TELA
/// (`context.read`) antes de abrir o sheet — mesmo precedente de
/// [mostrarOrdenacaoBottomSheet]: a rota do modal fica fora do
/// `BlocProvider` da vitrine, então este sheet nunca lê o Cubit da vitrine
/// diretamente.
Future<void> mostrarFiltrosBottomSheet(
  BuildContext context, {
  required FiltrosVitrine aplicados,
  required ValueChanged<FiltrosVitrine> aoAplicar,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (contextDoSheet) {
      return BlocProvider<RascunhoFiltrosCubit>(
        create: (_) => RascunhoFiltrosCubit(aplicados),
        child: _ConteudoFiltrosBottomSheet(aoAplicar: aoAplicar),
      );
    },
  );
}

class _ConteudoFiltrosBottomSheet extends StatelessWidget {
  const _ConteudoFiltrosBottomSheet({required this.aoAplicar});

  final ValueChanged<FiltrosVitrine> aoAplicar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Tela cheia (D-07): 92% da altura disponível, com o restante ocupado
    // pelo `showDragHandle` acima. `Padding` com `viewInsetsOf` empurra o
    // rodapé para cima do teclado quando um campo numérico (planos
    // seguintes) estiver focado.
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Filtros', style: textTheme.titleLarge),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BlocBuilder<RascunhoFiltrosCubit, FiltrosVitrine>(
                  builder: (context, rascunho) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Finalidade', style: textTheme.titleMedium),
                        const SizedBox(height: 8),
                        SegmentedButton<_SegmentoFinalidade>(
                          segments: const [
                            ButtonSegment(
                              value: _SegmentoFinalidade.qualquer,
                              label: Text('Qualquer'),
                            ),
                            ButtonSegment(
                              value: _SegmentoFinalidade.venda,
                              label: Text('Venda'),
                            ),
                            ButtonSegment(
                              value: _SegmentoFinalidade.aluguel,
                              label: Text('Aluguel'),
                            ),
                          ],
                          selected: {_segmentoDe(rascunho.finalidade)},
                          onSelectionChanged: (novo) => context
                              .read<RascunhoFiltrosCubit>()
                              .definirFinalidade(_paraFiltro(novo.first)),
                        ),
                        const SizedBox(height: 24),
                        Text('Tipo de imóvel', style: textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final natureza in NaturezaImovel.values)
                              FilterChip(
                                label: Text(rotuloNatureza(natureza)!),
                                selected: rascunho.naturezas.contains(
                                  natureza,
                                ),
                                onSelected: (marcada) => context
                                    .read<RascunhoFiltrosCubit>()
                                    .alternarNatureza(
                                      natureza,
                                      marcada: marcada,
                                    ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _SeletorMinimo(
                          titulo: 'Quartos',
                          valor: rascunho.quartosMin,
                          aoEscolher: context
                              .read<RascunhoFiltrosCubit>()
                              .definirQuartosMin,
                        ),
                        const SizedBox(height: 24),
                        _SeletorMinimo(
                          titulo: 'Suítes',
                          valor: rascunho.suitesMin,
                          aoEscolher: context
                              .read<RascunhoFiltrosCubit>()
                              .definirSuitesMin,
                        ),
                        const SizedBox(height: 24),
                        _SeletorMinimo(
                          titulo: 'Vagas',
                          valor: rascunho.vagasMin,
                          aoEscolher: context
                              .read<RascunhoFiltrosCubit>()
                              .definirVagasMin,
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () =>
                          context.read<RascunhoFiltrosCubit>().limpar(),
                      child: const Text('Limpar'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        final rascunho = context
                            .read<RascunhoFiltrosCubit>()
                            .state;
                        Navigator.of(context).pop();
                        aoAplicar(rascunho);
                      },
                      child: const Text('Ver imóveis'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Seletor de mínimo reusado por Quartos/Suítes/Vagas (D-01, D-10) — cinco
/// `ChoiceChip`s de seleção única: `null` ("Qualquer") e 1, 2, 3, 4. Rótulos
/// sempre "N+" — nunca "exatamente N" (D-01): o servidor simulado compara
/// com `>=`, então a UI nunca sugere o contrário.
class _SeletorMinimo extends StatelessWidget {
  const _SeletorMinimo({
    required this.titulo,
    required this.valor,
    required this.aoEscolher,
  });

  final String titulo;
  final int? valor;
  final ValueChanged<int?> aoEscolher;

  static const List<int?> _opcoes = [null, 1, 2, 3, 4];

  String _rotulo(int? opcao) => opcao == null ? 'Qualquer' : '$opcao+';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final opcao in _opcoes)
              ChoiceChip(
                label: Text(_rotulo(opcao)),
                selected: valor == opcao,
                onSelected: (_) => aoEscolher(opcao),
              ),
          ],
        ),
      ],
    );
  }
}
