import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/imovel_acervo.dart';
import '../contatos/caixa_contatos_screen.dart';
import '../gestao_imovel/gestao_imovel_screen.dart';
import '../perfis/widgets/rodape_paginacao_lista.dart';
import '../sessao/dialogo_sair.dart';
import '../sessao/sessao_expirada.dart';
import 'acervo_cubit.dart';
import 'acervo_state.dart';
import 'apresentacao_acervo.dart';
import 'widgets/cartao_imovel_acervo.dart';
import 'widgets/chips_situacao.dart';

/// Tela "Meu acervo" (ACV-01, ACV-02, SIT-07): os imóveis do corretor e os da
/// imobiliária, com busca por código ou título (D-08), chips de situação
/// (D-09) e rolagem infinita na ordem do servidor (D-10). A tela só apresenta
/// o que o [AcervoCubit] entrega — nenhuma regra, rede ou filtro aqui.
///
/// A `AppBar` tem o ícone "Meus contatos", que abre a caixa de contatos
/// recebidos (D-01), e Sair com confirmação; quando o servidor recusa o token (401)
/// a sessão fica anônima e o login reabre com o aviso, deixando só a vitrine
/// embaixo na pilha (T-08-54).
class AcervoScreen extends StatelessWidget {
  const AcervoScreen({
    super.key,
    this.criarCubit,
    this.aoAbrirGestao = abrirGestaoImovel,
    this.aoAbrirContatos = abrirCaixaContatos,
  });

  /// Cria o Cubit da tela; `null` usa o localizador de serviços. Existe para
  /// os testes de widget não dependerem do DI.
  final AcervoCubit Function()? criarCubit;

  /// Abre a gestão do imóvel tocado — de TODO cartão (D-02 da Fase 9); o
  /// padrão navega por `Navigator.push`; testes injetam um falso.
  final AoAbrirGestao aoAbrirGestao;

  /// Abre a caixa "Meus contatos" — o padrão navega por `Navigator.push`;
  /// injetável para o teste do acervo não depender de DI.
  final AoAbrirCaixaContatos aoAbrirContatos;

  @override
  Widget build(BuildContext context) {
    final criar = criarCubit ?? () => getIt<AcervoCubit>();
    return BlocProvider<AcervoCubit>(
      create: (_) => criar()..carregar(),
      child: _CorpoAcervo(
        aoAbrirGestao: aoAbrirGestao,
        aoAbrirContatos: aoAbrirContatos,
      ),
    );
  }
}

/// `StatefulWidget` só para hospedar os controladores de rolagem e de texto
/// (estado efêmero de interface); a guarda contra disparos duplicados vive
/// inteira no Cubit.
class _CorpoAcervo extends StatefulWidget {
  const _CorpoAcervo({
    required this.aoAbrirGestao,
    required this.aoAbrirContatos,
  });

  final AoAbrirGestao aoAbrirGestao;
  final AoAbrirCaixaContatos aoAbrirContatos;

  @override
  State<_CorpoAcervo> createState() => _CorpoAcervoState();
}

class _CorpoAcervoState extends State<_CorpoAcervo> {
  // `keepScrollOffset: false` — uma consulta nova sempre volta ao topo.
  final ScrollController _controleDeRolagem = ScrollController(
    keepScrollOffset: false,
  );

  // Dono do texto da `SearchBar`: a tela pode limpá-lo pelo "X" da barra sem
  // duplicar estado no Cubit (que guarda só o termo já aplicado).
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
    context.read<AcervoCubit>().limparBusca();
  }

  /// Abre a gestão do imóvel e, se ela voltou com "mudou" (D-12), relê o acervo
  /// da API. O Cubit é capturado ANTES do `await` e a tela precisa seguir
  /// montada na volta.
  Future<void> _abrirGestao(ImovelAcervo imovel) async {
    final cubit = context.read<AcervoCubit>();
    final mudou = await widget.aoAbrirGestao(context, imovel);
    if (mudou && mounted) cubit.recarregar();
  }

  void _aoRolar() {
    if (!_controleDeRolagem.hasClients) return;
    final posicao = _controleDeRolagem.position;
    if (posicao.pixels >= posicao.maxScrollExtent * 0.9) {
      context.read<AcervoCubit>().carregarMais();
    }
  }

  /// Se a primeira página não preencher a tela (lista não rolável) e ainda
  /// houver próxima página, pede a próxima depois do primeiro quadro — sem
  /// isso a paginação travaria em telas altas, já que nada rolaria.
  void _agendarCarregarMaisSeNaoPreencheATela(ConteudoAcervo conteudo) {
    if (conteudo is! AcervoCarregada) return;
    if (conteudo.carregandoMais || conteudo.erroAoCarregarMais) return;
    if (conteudo.proximaPagina == null) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_controleDeRolagem.hasClients) return;
      if (_controleDeRolagem.position.maxScrollExtent <= 0) {
        context.read<AcervoCubit>().carregarMais();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AcervoCubit, AcervoState>(
      listenWhen: (anterior, atual) =>
          anterior.conteudo is! AcervoSessaoExpirada &&
          atual.conteudo is AcervoSessaoExpirada,
      listener: (context, state) =>
          unawaited(voltarAoLoginComSessaoTerminada(context)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(tituloAcervo),
          actions: [
            IconButton(
              icon: const Icon(Icons.inbox_outlined),
              tooltip: 'Meus contatos',
              onPressed: () => widget.aoAbrirContatos(context),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => confirmarESair(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(
                controller: _controleDeBusca,
                hintText: dicaBuscaAcervo,
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
                onChanged: (texto) => context.read<AcervoCubit>().buscar(texto),
              ),
              const SizedBox(height: 8),
              BlocBuilder<AcervoCubit, AcervoState>(
                buildWhen: (anterior, atual) =>
                    anterior.situacao != atual.situacao,
                builder: (context, state) => ChipsSituacao(
                  selecionada: state.situacao,
                  aoEscolher: context.read<AcervoCubit>().escolherSituacao,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocConsumer<AcervoCubit, AcervoState>(
                  // Uma consulta nova (busca ou situação) volta ao topo; o
                  // estado `carregando` só reaparece nesses reinícios, nunca em
                  // `carregarMais()`.
                  listener: (context, state) {
                    if (state.conteudo is AcervoCarregando &&
                        _controleDeRolagem.hasClients) {
                      _controleDeRolagem.jumpTo(0);
                    }
                  },
                  builder: (context, state) {
                    final conteudo = state.conteudo;
                    _agendarCarregarMaisSeNaoPreencheATela(conteudo);
                    return switch (conteudo) {
                      AcervoCarregando() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      AcervoVazio() => const _MensagemDoAcervo(
                        texto: textoAcervoVazio,
                      ),
                      AcervoSemResultado() => const _MensagemDoAcervo(
                        texto: textoAcervoSemResultado,
                      ),
                      AcervoErro() => _MensagemDoAcervo(
                        texto: textoErroAcervo,
                        aoTentarDeNovo: () =>
                            context.read<AcervoCubit>().tentarNovamente(),
                      ),
                      AcervoSessaoExpirada() => const _MensagemDoAcervo(
                        texto: textoSessaoExpiradaAcervo,
                      ),
                      AcervoCarregada(
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
                              return RodapePaginacaoLista(
                                carregandoMais: carregandoMais,
                                erroAoCarregarMais: erroAoCarregarMais,
                                temProximaPagina: proximaPagina != null,
                                aoTentarDeNovo: () => context
                                    .read<AcervoCubit>()
                                    .tentarNovamente(),
                              );
                            }
                            final imovel = itens[index];
                            return CartaoImovelAcervo(
                              key: ValueKey('imovel-acervo-${imovel.id}'),
                              imovel: imovel,
                              aoTocar: () => unawaited(_abrirGestao(imovel)),
                            );
                          },
                        ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mensagem central de um estado sem lista (vazio, sem resultado, erro,
/// sessão terminada); com [aoTentarDeNovo] mostra o "Tentar de novo".
class _MensagemDoAcervo extends StatelessWidget {
  const _MensagemDoAcervo({required this.texto, this.aoTentarDeNovo});

  final String texto;
  final VoidCallback? aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    final aoTentar = aoTentarDeNovo;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              texto,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (aoTentar != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: aoTentar,
                child: const Text('Tentar de novo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
