import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/filtros_vitrine.dart';
import '../../../domain/entities/imovel.dart';
import '../apresentacao_filtros.dart';
import '../apresentacao_imovel.dart';
import '../opcoes_filtro_cubit.dart';
import '../opcoes_filtro_state.dart';
import '../rascunho_filtros_cubit.dart';
import 'mascara_numerica.dart';

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
/// diretamente. [opcoes] (Task 2, D-20) segue a MESMA disciplina — é o
/// `OpcoesFiltroCubit` já lido pela tela, passado por valor (nunca criado
/// aqui, nunca fechado por este widget).
Future<void> mostrarFiltrosBottomSheet(
  BuildContext context, {
  required FiltrosVitrine aplicados,
  required ValueChanged<FiltrosVitrine> aoAplicar,
  required OpcoesFiltroCubit opcoes,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (contextDoSheet) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<RascunhoFiltrosCubit>(
            create: (_) => RascunhoFiltrosCubit(aplicados),
          ),
          BlocProvider<OpcoesFiltroCubit>.value(value: opcoes),
        ],
        child: _ConteudoFiltrosBottomSheet(aoAplicar: aoAplicar),
      );
    },
  );
}

class _ConteudoFiltrosBottomSheet extends StatefulWidget {
  const _ConteudoFiltrosBottomSheet({required this.aoAplicar});

  final ValueChanged<FiltrosVitrine> aoAplicar;

  @override
  State<_ConteudoFiltrosBottomSheet> createState() =>
      _ConteudoFiltrosBottomSheetState();
}

/// `StatefulWidget` (D-09) só para hospedar os quatro `TextEditingController`s
/// das faixas de preço/área e o controller do campo "Filtrar bairros" (Task
/// 2, D-21) — nenhuma lógica de negócio mora aqui, a fonte da verdade
/// continua sendo o [RascunhoFiltrosCubit] (D-08)/[OpcoesFiltroCubit] (D-20);
/// os controllers só espelham texto (já mascarado, [textoMascaradoDe], nos
/// quatro de faixa) ou filtram a lista de opções já carregada (bairros).
class _ConteudoFiltrosBottomSheetState
    extends State<_ConteudoFiltrosBottomSheet> {
  late final TextEditingController _precoMinController;
  late final TextEditingController _precoMaxController;
  late final TextEditingController _areaMinController;
  late final TextEditingController _areaMaxController;
  late final TextEditingController _filtroBairroController;

  @override
  void initState() {
    super.initState();
    final rascunho = context.read<RascunhoFiltrosCubit>().state;
    _precoMinController = TextEditingController(
      text: textoMascaradoDe(rascunho.precoMin),
    );
    _precoMaxController = TextEditingController(
      text: textoMascaradoDe(rascunho.precoMax),
    );
    _areaMinController = TextEditingController(
      text: textoMascaradoDe(rascunho.areaMin),
    );
    _areaMaxController = TextEditingController(
      text: textoMascaradoDe(rascunho.areaMax),
    );
    _filtroBairroController = TextEditingController();
  }

  @override
  void dispose() {
    _precoMinController.dispose();
    _precoMaxController.dispose();
    _areaMinController.dispose();
    _areaMaxController.dispose();
    _filtroBairroController.dispose();
    super.dispose();
  }

  /// "Limpar" do rodapé (D-18) — zera o rascunho E os cinco controllers (o
  /// rascunho sozinho não mexe em texto já digitado nos campos, incluindo o
  /// filtro local de bairros).
  void _limparTudo() {
    context.read<RascunhoFiltrosCubit>().limpar();
    _precoMinController.clear();
    _precoMaxController.clear();
    _areaMinController.clear();
    _areaMaxController.clear();
    _filtroBairroController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Tela cheia (D-07): 92% da altura disponível, com o restante ocupado
    // pelo `showDragHandle` acima. `Padding` com `viewInsetsOf` empurra o
    // rodapé para cima do teclado quando um campo numérico está focado.
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: BlocListener<RascunhoFiltrosCubit, FiltrosVitrine>(
          // D-13: trocar de finalidade limpa o TEXTO já digitado nos campos
          // de preço (o rascunho já limpou os VALORES, RascunhoFiltrosCubit
          // .definirFinalidade) — os controllers precisam seguir.
          listenWhen: (anterior, atual) =>
              anterior.finalidade != atual.finalidade,
          listener: (context, rascunho) {
            _precoMinController.clear();
            _precoMaxController.clear();
          },
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
                          _SecaoFaixa(
                            titulo: 'Preço',
                            minController: _precoMinController,
                            maxController: _precoMaxController,
                            habilitado: rascunho.finalidade != null,
                            textoDesabilitado:
                                'Escolha Venda ou Aluguel para filtrar por '
                                'preço',
                            prefixo: 'R\$ ',
                            sufixo: rascunho.finalidade ==
                                    FinalidadeFiltro.aluguel
                                ? '/mês'
                                : null,
                            erro: rascunho.erroFaixaPreco,
                            aoMudarMin: (texto) => context
                                .read<RascunhoFiltrosCubit>()
                                .definirPrecoMin(
                                  inteiroDoTextoMascarado(texto),
                                ),
                            aoMudarMax: (texto) => context
                                .read<RascunhoFiltrosCubit>()
                                .definirPrecoMax(
                                  inteiroDoTextoMascarado(texto),
                                ),
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
                          _SecaoFaixa(
                            titulo: 'Área',
                            minController: _areaMinController,
                            maxController: _areaMaxController,
                            habilitado: true,
                            textoDesabilitado: null,
                            prefixo: null,
                            sufixo: 'm²',
                            erro: rascunho.erroFaixaArea,
                            aoMudarMin: (texto) => context
                                .read<RascunhoFiltrosCubit>()
                                .definirAreaMin(
                                  inteiroDoTextoMascarado(texto),
                                ),
                            aoMudarMax: (texto) => context
                                .read<RascunhoFiltrosCubit>()
                                .definirAreaMax(
                                  inteiroDoTextoMascarado(texto),
                                ),
                          ),
                          const SizedBox(height: 24),
                          _SecaoBairros(controller: _filtroBairroController),
                          const SizedBox(height: 24),
                          const _SecaoCaracteristicas(),
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
                        onPressed: _limparTudo,
                        child: const Text('Limpar'),
                      ),
                      const Spacer(),
                      BlocBuilder<RascunhoFiltrosCubit, FiltrosVitrine>(
                        builder: (context, rascunho) {
                          return FilledButton(
                            onPressed: rascunho.podeAplicar
                                ? () {
                                    Navigator.of(context).pop();
                                    widget.aoAplicar(rascunho);
                                  }
                                : null,
                            child: const Text('Ver imóveis'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seção de faixa mín/máx reusada por Preço e Área (D-09, D-12) — dois
/// `TextField`s lado a lado com `MascaraMilhares`, erro inline SOMENTE no
/// campo Máximo (onde o visitante termina de digitar a faixa invertida), e
/// uma mensagem de ajuda quando [habilitado] é `false` (D-03, Pitfall 5).
class _SecaoFaixa extends StatelessWidget {
  const _SecaoFaixa({
    required this.titulo,
    required this.minController,
    required this.maxController,
    required this.habilitado,
    required this.textoDesabilitado,
    required this.prefixo,
    required this.sufixo,
    required this.erro,
    required this.aoMudarMin,
    required this.aoMudarMax,
  });

  final String titulo;
  final TextEditingController minController;
  final TextEditingController maxController;
  final bool habilitado;
  final String? textoDesabilitado;
  final String? prefixo;
  final String? sufixo;
  final String? erro;
  final ValueChanged<String> aoMudarMin;
  final ValueChanged<String> aoMudarMax;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        if (!habilitado && textoDesabilitado != null) ...[
          Text(
            textoDesabilitado!,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                enabled: habilitado,
                keyboardType: TextInputType.number,
                inputFormatters: const [MascaraMilhares()],
                onChanged: aoMudarMin,
                decoration: InputDecoration(
                  labelText: 'Mínimo',
                  prefixText: prefixo,
                  suffixText: sufixo,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: maxController,
                enabled: habilitado,
                keyboardType: TextInputType.number,
                inputFormatters: const [MascaraMilhares()],
                onChanged: aoMudarMax,
                decoration: InputDecoration(
                  labelText: 'Máximo',
                  prefixText: prefixo,
                  suffixText: sufixo,
                  errorText: erro,
                ),
              ),
            ),
          ],
        ),
      ],
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

/// Seção "Bairros" (FIL-04, D-05, D-20, D-21) — `ExpansionTile` cujo
/// conteúdo troca exaustivamente sobre `OpcoesFiltroState.bairros`: as
/// opções vêm do servidor simulado através de [OpcoesFiltroCubit] (nunca
/// uma lista fixa aqui), e o campo "Filtrar bairros" ([controller], de
/// propriedade do sheet) só filtra as opções JÁ carregadas via
/// [filtrarOpcoes] — nunca dispara consulta ao acervo. Começa expandida
/// quando o rascunho já tem bairros (D-17: reabrir o sheet a partir de um
/// chip já aplicado).
class _SecaoBairros extends StatelessWidget {
  const _SecaoBairros({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<RascunhoFiltrosCubit, FiltrosVitrine>(
      builder: (context, rascunho) {
        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: const Text('Bairros'),
          subtitle: rascunho.bairros.isEmpty
              ? null
              : Text(
                  '${rascunho.bairros.length} selecionado'
                  '${rascunho.bairros.length > 1 ? "s" : ""}',
                ),
          initiallyExpanded: rascunho.bairros.isNotEmpty,
          children: [
            BlocBuilder<OpcoesFiltroCubit, OpcoesFiltroState>(
              builder: (context, opcoesState) {
                return switch (opcoesState.bairros) {
                  OpcoesCarregando() => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  OpcoesFalha() => Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Não foi possível carregar os bairros',
                          style: textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context
                              .read<OpcoesFiltroCubit>()
                              .tentarNovamente(),
                          child: const Text('Tentar de novo'),
                        ),
                      ],
                    ),
                  ),
                  OpcoesCarregadas(:final opcoes) when opcoes.isEmpty =>
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nenhum bairro disponível nesta cidade',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  OpcoesCarregadas(:final opcoes) => ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      final visiveis = filtrarOpcoes(opcoes, controller.text);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'Filtrar bairros',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                          for (final bairro in visiveis)
                            CheckboxListTile(
                              title: Text(bairro),
                              value: rascunho.bairros.contains(bairro),
                              contentPadding: EdgeInsets.zero,
                              onChanged: (marcado) => context
                                  .read<RascunhoFiltrosCubit>()
                                  .alternarBairro(
                                    bairro,
                                    marcado: marcado ?? false,
                                  ),
                            ),
                        ],
                      );
                    },
                  ),
                };
              },
            ),
          ],
        );
      },
    );
  }
}

/// Seção "Características" (FIL-04, D-04, D-16, D-20) — última seção do
/// sheet, sempre visível (diferente de "Bairros": sem `ExpansionTile` nem
/// campo de busca local, mesmo padrão simples da seção "Tipo de imóvel").
/// O conteúdo troca exaustivamente sobre `OpcoesFiltroState.caracteristicas`:
/// as opções vêm do servidor simulado através de [OpcoesFiltroCubit] (nunca
/// uma lista fixa aqui); o servidor combina as marcadas com E (D-04).
class _SecaoCaracteristicas extends StatelessWidget {
  const _SecaoCaracteristicas();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Características', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        BlocBuilder<OpcoesFiltroCubit, OpcoesFiltroState>(
          builder: (context, opcoesState) {
            return switch (opcoesState.caracteristicas) {
              OpcoesCarregando() => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              OpcoesFalha() => Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Não foi possível carregar as características',
                      style: textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () =>
                          context.read<OpcoesFiltroCubit>().tentarNovamente(),
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              ),
              OpcoesCarregadas(:final opcoes) when opcoes.isEmpty => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Nenhuma característica disponível',
                  style: textTheme.bodyMedium,
                ),
              ),
              OpcoesCarregadas(:final opcoes) =>
                BlocBuilder<RascunhoFiltrosCubit, FiltrosVitrine>(
                  builder: (context, rascunho) {
                    return Wrap(
                      spacing: 8,
                      children: [
                        for (final caracteristica in opcoes)
                          FilterChip(
                            label: Text(caracteristica),
                            selected: rascunho.caracteristicas.contains(
                              caracteristica,
                            ),
                            onSelected: (marcada) => context
                                .read<RascunhoFiltrosCubit>()
                                .alternarCaracteristica(
                                  caracteristica,
                                  marcada: marcada,
                                ),
                          ),
                      ],
                    );
                  },
                ),
            };
          },
        ),
      ],
    );
  }
}
