import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cidade.dart';
import '../../domain/entities/ordenacao_vitrine.dart';
import '../cidade_selecao/widgets/seletor_cidade_topo.dart';
import 'vitrine_cubit.dart';
import 'vitrine_state.dart';
import 'widgets/imovel_card.dart';
import 'widgets/ordenacao_bottom_sheet.dart';

/// Tela da vitrine (VIT-01) — sem `Scaffold` próprio: vive dentro do
/// `Scaffold`/`SafeArea` de `CidadeSelecaoScreen` no desfecho
/// `autorizadaEAtendida`. `switch` exaustivo sobre [ConteudoVitrine], sem
/// ramo abrangente, igual à convenção de `CidadeSelecaoScreen`.
///
/// `StatefulWidget` só para hospedar o `ScrollController` do scroll infinito
/// (VIT-05): o listener chama `carregarMais()` a 90% do fim da lista
/// (RESEARCH Pattern 4); a guarda contra disparos duplicados vive inteira no
/// Cubit.
class VitrineScreen extends StatefulWidget {
  const VitrineScreen({super.key, required this.cidade});

  final Cidade cidade;

  @override
  State<VitrineScreen> createState() => _VitrineScreenState();
}

class _VitrineScreenState extends State<VitrineScreen> {
  // `keepScrollOffset: false` — uma lista reiniciada (nova cidade/busca/
  // ordenação) sempre volta ao topo (D-13), nunca preserva o offset de
  // rolagem de uma consulta anterior.
  final ScrollController _controleDeRolagem = ScrollController(
    keepScrollOffset: false,
  );

  // Dono da `SearchBar` (D-07) — a tela controla o texto para poder limpá-lo
  // de dois lugares (o "X" da própria barra e o "Limpar busca" do estado
  // sem-resultado), sem duplicar estado no Cubit (que só guarda o termo já
  // aplicado, não o rascunho em digitação).
  final TextEditingController _controleDeBusca = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controleDeRolagem.addListener(_aoRolar);
  }

  @override
  void dispose() {
    _controleDeRolagem
      ..removeListener(_aoRolar)
      ..dispose();
    _controleDeBusca.dispose();
    super.dispose();
  }

  void _limparBusca() {
    _controleDeBusca.clear();
    context.read<VitrineCubit>().limparBusca();
  }

  void _aoRolar() {
    if (!_controleDeRolagem.hasClients) return;
    final posicao = _controleDeRolagem.position;
    if (posicao.pixels >= posicao.maxScrollExtent * 0.9) {
      context.read<VitrineCubit>().carregarMais();
    }
  }

  /// Se a primeira página não preencher a tela (lista não rolável) e ainda
  /// houver próxima página, pede a próxima automaticamente depois do
  /// primeiro frame — sem isso, a paginação travaria em telas altas, já que
  /// o listener de rolagem nunca dispararia (nada para rolar).
  void _agendarCarregarMaisSeNaoPreencheATela(ConteudoVitrine conteudo) {
    if (conteudo is! VitrineCarregada) return;
    if (conteudo.carregandoMais || conteudo.erroAoCarregarMais) return;
    if (conteudo.proximaPagina == null) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_controleDeRolagem.hasClients) return;
      if (_controleDeRolagem.position.maxScrollExtent <= 0) {
        context.read<VitrineCubit>().carregarMais();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeletorCidadeTopo(cidade: widget.cidade),
          const SizedBox(height: 16),
          SearchBar(
            controller: _controleDeBusca,
            hintText: 'Buscar por título ou bairro',
            leading: const Icon(Icons.search),
            trailing: [
              ListenableBuilder(
                listenable: _controleDeBusca,
                builder: (context, _) {
                  if (_controleDeBusca.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    tooltip: 'Limpar busca',
                    icon: const Icon(Icons.clear),
                    onPressed: _limparBusca,
                  );
                },
              ),
            ],
            onChanged: (texto) => context.read<VitrineCubit>().buscar(texto),
          ),
          const SizedBox(height: 8),
          // Linha de ações logo abaixo da SearchBar (D-10): a 360dp a
          // SearchBar + "Ordenar: Mais recentes" não cabem lado a lado numa
          // única linha com o cabeçalho de cidade, então o botão de ordenar
          // fica aqui, com um `Spacer` reservando o espaço à direita para o
          // botão de filtros da Fase 3 — interpretação sinalizada no
          // human-check de fim de fase para confirmação do usuário.
          Row(
            children: [
              Flexible(
                child: BlocSelector<VitrineCubit, VitrineState, OrdenacaoVitrine>(
                  selector: (state) => state.ordenacao,
                  builder: (context, ordenacao) {
                    return OutlinedButton.icon(
                      icon: const Icon(Icons.sort),
                      label: Text(
                        'Ordenar: ${ordenacao.rotulo}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () {
                        final cubit = context.read<VitrineCubit>();
                        unawaited(
                          mostrarOrdenacaoBottomSheet(
                            context,
                            atual: ordenacao,
                            aoEscolher: cubit.ordenarPor,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Spacer(), // reservado para o botão de filtros (Fase 3)
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocConsumer<VitrineCubit, VitrineState>(
              // `keepScrollOffset: false` só restaura o topo quando um NOVO
              // `ScrollPosition` é criado (ex.: nova `VitrineScreen` ao
              // trocar de cidade) — uma troca de busca/ordenação reconstrói
              // o MESMO `ListView`/`ScrollController` in-place, então o
              // scroll não volta ao topo sozinho. `VitrineCarregando` só
              // reaparece nesses reinícios (D-13) — nunca durante
              // `carregarMais()`, que mantém `VitrineCarregada` — então
              // pular para 0 aqui é seguro e nunca interfere com a
              // paginação.
              listener: (context, state) {
                if (state.conteudo is VitrineCarregando &&
                    _controleDeRolagem.hasClients) {
                  _controleDeRolagem.jumpTo(0);
                }
              },
              builder: (context, state) {
                final conteudo = state.conteudo;
                _agendarCarregarMaisSeNaoPreencheATela(conteudo);
                return switch (conteudo) {
                  VitrineCarregando() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  VitrineVaziaNaCidade() => Center(
                    child: Text(
                      'Ainda não há imóveis anunciados em '
                      '${widget.cidade.nome}.',
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VitrineSemResultado(:final termo) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nenhum imóvel encontrado para "$termo"',
                            style: textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _limparBusca,
                            child: const Text('Limpar busca'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  VitrineErro() => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Não foi possível carregar os imóveis',
                            style: textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context
                                .read<VitrineCubit>()
                                .tentarNovamente(),
                            child: const Text('Tentar de novo'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  VitrineCarregada(
                    :final itens,
                    :final proximaPagina,
                    :final carregandoMais,
                    :final erroAoCarregarMais,
                  ) =>
                    ListView.builder(
                      controller: _controleDeRolagem,
                      itemCount: itens.length + 1,
                      itemBuilder: (context, index) {
                        if (index == itens.length) {
                          return _RodapePaginacao(
                            carregandoMais: carregandoMais,
                            erroAoCarregarMais: erroAoCarregarMais,
                            temProximaPagina: proximaPagina != null,
                          );
                        }
                        final imovel = itens[index];
                        return ImovelCard(
                          key: ValueKey('imovel-${imovel.id}'),
                          imovel: imovel,
                        );
                      },
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Rodapé da lista da vitrine (VIT-05): carregando-mais (spinner pequeno),
/// erro-ao-carregar-mais (mensagem + "Tentar de novo") ou fim-da-lista —
/// mutuamente exclusivos, nessa ordem de prioridade.
class _RodapePaginacao extends StatelessWidget {
  const _RodapePaginacao({
    required this.carregandoMais,
    required this.erroAoCarregarMais,
    required this.temProximaPagina,
  });

  final bool carregandoMais;
  final bool erroAoCarregarMais;
  final bool temProximaPagina;

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
              'Não foi possível carregar mais imóveis',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => context.read<VitrineCubit>().tentarNovamente(),
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
