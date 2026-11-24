import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../login/apresentacao_login.dart';
import '../login/login_screen.dart';
import '../perfis/widgets/rodape_paginacao_lista.dart';
import '../sessao/rota_vitrine.dart';
import '../sessao/sessao_cubit.dart';
import 'apresentacao_contatos.dart';
import 'caixa_contatos_cubit.dart';
import 'caixa_contatos_state.dart';
import 'widgets/chips_filtros_contatos.dart';
import 'widgets/folha_filtro_imovel.dart';
import 'widgets/item_contato.dart';
import 'widgets/seletor_periodo.dart';

/// Assinatura de quem abre a caixa "Meus contatos" a partir do acervo —
/// `AcervoScreen` recebe uma por parâmetro (padrão [abrirCaixaContatos]) para
/// que os testes do acervo não dependam do DI.
typedef AoAbrirCaixaContatos = Future<void> Function(BuildContext context);

/// Abre a caixa por `Navigator.push` (D-01, sem pacote de rotas): o voltar
/// retorna ao acervo.
Future<void> abrirCaixaContatos(BuildContext context) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const CaixaContatosScreen()));
}

/// Tela "Meus contatos" (CXA-01, CXA-05, CXA-06): os contatos que o corretor
/// recebeu, mais recentes primeiro, com rolagem infinita (D-12) e, logo abaixo
/// da `AppBar`, quantos estão sem retorno — o número vem do servidor (D-04,
/// D-06). A tela só apresenta o que o [CaixaContatosCubit] entrega: nenhuma
/// regra, rede ou texto do servidor aqui (D-28).
///
/// Quando o servidor recusa o token (401) a sessão fica anônima e o login
/// reabre com o aviso, deixando só a vitrine embaixo na pilha (D-23).
class CaixaContatosScreen extends StatelessWidget {
  const CaixaContatosScreen({
    super.key,
    this.criarCubit,
    this.escolherPeriodo = escolherPeriodoComSeletor,
  });

  /// Cria o Cubit da tela; `null` usa o localizador de serviços. Existe para
  /// os testes de widget não dependerem do DI.
  final CaixaContatosCubit Function()? criarCubit;

  /// Abre o seletor de período do chip "Período" (D-20). Injetável para os
  /// testes de widget trocarem o diálogo do Material por um falso.
  final EscolherPeriodo escolherPeriodo;

  @override
  Widget build(BuildContext context) {
    final criar = criarCubit ?? () => getIt<CaixaContatosCubit>();
    return BlocProvider<CaixaContatosCubit>(
      create: (_) => criar()..carregar(),
      child: _CorpoCaixaContatos(escolherPeriodo: escolherPeriodo),
    );
  }
}

/// `StatefulWidget` só para hospedar o controlador de rolagem (estado efêmero
/// de interface); a guarda contra disparos duplicados vive inteira no Cubit.
class _CorpoCaixaContatos extends StatefulWidget {
  const _CorpoCaixaContatos({required this.escolherPeriodo});

  final EscolherPeriodo escolherPeriodo;

  @override
  State<_CorpoCaixaContatos> createState() => _CorpoCaixaContatosState();
}

class _CorpoCaixaContatosState extends State<_CorpoCaixaContatos> {
  // `keepScrollOffset: false` — uma consulta nova sempre volta ao topo.
  final ScrollController _controleDeRolagem = ScrollController(
    keepScrollOffset: false,
  );

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
    super.dispose();
  }

  /// A sessão terminou (401 na lista, na página seguinte ou na contagem):
  /// descarta o token local, deixa a sessão anônima e abre o login com o
  /// aviso, mantendo só a rota da vitrine embaixo (D-23).
  Future<void> _aoSessaoExpirar() async {
    final navegador = Navigator.of(context);
    await context.read<SessaoCubit>().encerrarPorExpiracao();
    if (!mounted) return;
    navegador.pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(aviso: avisoSessaoTerminou),
      ),
      eRotaDaVitrine,
    );
  }

  /// Chip "Período": abre o seletor com o período atual e, se o usuário
  /// escolheu um intervalo, entrega ao Cubit (D-20). O Cubit é lido antes do
  /// await: depois dele o contexto pode já não ser o da tela.
  Future<void> _aoTocarPeriodo() async {
    final cubit = context.read<CaixaContatosCubit>();
    final periodo = await widget.escolherPeriodo(
      context,
      cubit.state.consulta.periodo,
    );
    if (periodo == null || !mounted) return;
    await cubit.aplicarPeriodo(periodo);
  }

  void _aoRolar() {
    if (!_controleDeRolagem.hasClients) return;
    final posicao = _controleDeRolagem.position;
    if (posicao.pixels >= posicao.maxScrollExtent * 0.9) {
      context.read<CaixaContatosCubit>().carregarMais();
    }
  }

  /// Se a primeira página não preencher a tela (lista não rolável) e ainda
  /// houver próxima página, pede a próxima depois do primeiro quadro — sem
  /// isso a paginação travaria em telas altas, já que nada rolaria.
  void _agendarCarregarMaisSeNaoPreencheATela(ConteudoCaixa conteudo) {
    if (conteudo is! CaixaCarregada) return;
    if (conteudo.carregandoMais || conteudo.erroAoCarregarMais) return;
    if (conteudo.proximaPagina == null) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_controleDeRolagem.hasClients) return;
      if (_controleDeRolagem.position.maxScrollExtent <= 0) {
        context.read<CaixaContatosCubit>().carregarMais();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CaixaContatosCubit, CaixaContatosState>(
      listenWhen: (anterior, atual) =>
          anterior.conteudo is! CaixaSessaoExpirada &&
          atual.conteudo is CaixaSessaoExpirada,
      listener: (context, state) => unawaited(_aoSessaoExpirar()),
      child: Scaffold(
        appBar: AppBar(title: const Text(tituloCaixaContatos)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocSelector<CaixaContatosCubit, CaixaContatosState, int?>(
              selector: (state) => state.semRetorno,
              builder: (context, semRetorno) => semRetorno == null
                  ? const SizedBox.shrink()
                  : _LinhaSemRetorno(quantidade: semRetorno),
            ),
            BlocBuilder<CaixaContatosCubit, CaixaContatosState>(
              buildWhen: (anterior, atual) =>
                  anterior.consulta != atual.consulta ||
                  (anterior.conteudo is CaixaSessaoExpirada) !=
                      (atual.conteudo is CaixaSessaoExpirada),
              builder: (context, state) {
                if (state.conteudo is CaixaSessaoExpirada) {
                  return const SizedBox.shrink();
                }
                final cubit = context.read<CaixaContatosCubit>();
                return ChipsFiltrosContatos(
                  consulta: state.consulta,
                  aoTocarImovel: () =>
                      mostrarFolhaFiltroImovel(context, cubit: cubit),
                  aoLimparImovel: cubit.limparImovel,
                  aoTocarPeriodo: _aoTocarPeriodo,
                  aoLimparPeriodo: cubit.limparPeriodo,
                );
              },
            ),
            Expanded(
              child: BlocConsumer<CaixaContatosCubit, CaixaContatosState>(
                // Uma consulta nova volta ao topo; o estado `carregando` só
                // reaparece nesses reinícios, nunca em `carregarMais()`.
                listener: (context, state) {
                  if (state.conteudo is CaixaCarregando &&
                      _controleDeRolagem.hasClients) {
                    _controleDeRolagem.jumpTo(0);
                  }
                },
                builder: (context, state) {
                  final conteudo = state.conteudo;
                  _agendarCarregarMaisSeNaoPreencheATela(conteudo);
                  return switch (conteudo) {
                    CaixaCarregando() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    CaixaVazia() => const _MensagemDaCaixa(
                      texto: textoCaixaVazia,
                    ),
                    CaixaSemResultado() => const _MensagemDaCaixa(
                      texto: textoCaixaSemResultado,
                    ),
                    CaixaErro() => _MensagemDaCaixa(
                      texto: textoErroCaixa,
                      aoTentarDeNovo: () =>
                          context.read<CaixaContatosCubit>().tentarNovamente(),
                    ),
                    CaixaSessaoExpirada() => const _MensagemDaCaixa(
                      texto: avisoSessaoTerminou,
                    ),
                    CaixaCarregada(
                      :final itens,
                      :final proximaPagina,
                      :final carregandoMais,
                      :final erroAoCarregarMais,
                    ) =>
                      ListView.builder(
                        controller: _controleDeRolagem,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: itens.length + 1,
                        itemBuilder: (context, index) {
                          if (index == itens.length) {
                            return RodapePaginacaoLista(
                              carregandoMais: carregandoMais,
                              erroAoCarregarMais: erroAoCarregarMais,
                              temProximaPagina: proximaPagina != null,
                              mensagemErro: textoErroAoCarregarMaisContatos,
                              aoTentarDeNovo: () => context
                                  .read<CaixaContatosCubit>()
                                  .tentarNovamente(),
                            );
                          }
                          final contato = itens[index];
                          return ItemContato(
                            key: ValueKey('contato-${contato.id}'),
                            contato: contato,
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
    );
  }
}

/// Linha "N contatos sem retorno" (D-07): mostra o número como o servidor
/// devolveu — nunca conta nem calcula aqui (D-04, D-06).
class _LinhaSemRetorno extends StatelessWidget {
  const _LinhaSemRetorno({required this.quantidade});

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Icon(
            Icons.mark_email_unread_outlined,
            size: 18,
            color: tema.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              textoSemRetorno(quantidade),
              style: tema.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensagem central de um estado sem lista (vazio, sem resultado, erro,
/// sessão terminada); com [aoTentarDeNovo] mostra o "Tentar de novo".
class _MensagemDaCaixa extends StatelessWidget {
  const _MensagemDaCaixa({required this.texto, this.aoTentarDeNovo});

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
