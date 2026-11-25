import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/acervo_por_corretor.dart';
import '../../domain/entities/contatos_por_corretor.dart';
import '../../domain/entities/mudancas_recentes.dart';
import '../../domain/entities/periodo_contatos.dart';
import '../../domain/entities/totais_por_situacao.dart';
import '../contatos/widgets/seletor_periodo.dart';
import '../sessao/dialogo_sair.dart';
import '../sessao/sessao_expirada.dart';
import 'apresentacao_area_gestor.dart';
import 'area_gestor_cubit.dart';
import 'area_gestor_state.dart';
import 'widgets/secao_acervo_corretores.dart';
import 'widgets/secao_contatos_corretores.dart';
import 'widgets/secao_mudancas.dart';
import 'widgets/secao_totais.dart';

/// Tela "Área do gestor" (GES-01..GES-06): uma tela só, com rolagem, e as 4
/// perguntas do gestor respondidas de cima para baixo — totais da empresa por
/// situação, acervo por corretor, contatos por corretor (no período escolhido)
/// e mudanças de situação recentes (D-05, D-06). Cada seção carrega, falha e
/// repete sozinha (D-07); as linhas não reagem a toque (D-08).
///
/// A tela só apresenta o que o [AreaGestorCubit] entrega: nenhuma regra, rede
/// ou texto do servidor aqui (D-29). Quando o servidor recusa o token (401) a
/// sessão fica anônima e o login reabre com o aviso, deixando só a vitrine
/// embaixo na pilha (D-22).
class AreaGestorScreen extends StatelessWidget {
  const AreaGestorScreen({
    super.key,
    this.criarCubit,
    this.escolherPeriodo = escolherPeriodoComSeletor,
  });

  /// Cria o Cubit da tela; `null` usa o localizador de serviços. Existe para
  /// os testes de widget não dependerem do DI.
  final AreaGestorCubit Function()? criarCubit;

  /// Abre o seletor de período do chip "Período" (D-16). Injetável para os
  /// testes de widget trocarem o diálogo do Material por um falso.
  final EscolherPeriodo escolherPeriodo;

  @override
  Widget build(BuildContext context) {
    final criar = criarCubit ?? () => getIt<AreaGestorCubit>();
    return BlocProvider<AreaGestorCubit>(
      create: (_) => criar()..carregar(),
      child: _CorpoAreaGestor(escolherPeriodo: escolherPeriodo),
    );
  }
}

/// `StatefulWidget` só para conferir `mounted` depois do `await` do seletor
/// de período (estado efêmero de interface); nenhuma regra mora aqui.
class _CorpoAreaGestor extends StatefulWidget {
  const _CorpoAreaGestor({required this.escolherPeriodo});

  final EscolherPeriodo escolherPeriodo;

  @override
  State<_CorpoAreaGestor> createState() => _CorpoAreaGestorState();
}

class _CorpoAreaGestorState extends State<_CorpoAreaGestor> {
  /// Chip "Período": abre o seletor com o período atual e, se o usuário
  /// escolheu um intervalo, entrega ao Cubit (D-16). O Cubit é lido antes do
  /// await: depois dele o contexto pode já não ser o da tela.
  Future<void> _aoTocarPeriodo() async {
    final cubit = context.read<AreaGestorCubit>();
    final periodo = await widget.escolherPeriodo(context, cubit.state.periodo);
    if (periodo == null || !mounted) return;
    await cubit.aplicarPeriodo(periodo);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AreaGestorCubit>();

    return BlocListener<AreaGestorCubit, AreaGestorState>(
      listenWhen: (anterior, atual) =>
          !anterior.sessaoExpirada && atual.sessaoExpirada,
      listener: (context, _) =>
          unawaited(voltarAoLoginComSessaoTerminada(context)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(tituloAreaGestor),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => confirmarESair(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocSelector<
                AreaGestorCubit,
                AreaGestorState,
                EstadoSecao<TotaisPorSituacao>
              >(
                selector: (estado) => estado.totais,
                builder: (context, totais) => SecaoTotais(
                  estado: totais,
                  aoTentarDeNovo: () =>
                      cubit.tentarNovamente(SecaoDaAreaGestor.totais),
                ),
              ),
              const SizedBox(height: 12),
              BlocSelector<
                AreaGestorCubit,
                AreaGestorState,
                EstadoSecao<AcervoPorCorretor>
              >(
                selector: (estado) => estado.acervo,
                builder: (context, acervo) => SecaoAcervoCorretores(
                  estado: acervo,
                  aoTentarDeNovo: () =>
                      cubit.tentarNovamente(SecaoDaAreaGestor.acervo),
                ),
              ),
              const SizedBox(height: 12),
              BlocSelector<
                AreaGestorCubit,
                AreaGestorState,
                (EstadoSecao<ContatosPorCorretor>, PeriodoContatos?)
              >(
                selector: (estado) => (estado.contatos, estado.periodo),
                builder: (context, contatos) => SecaoContatosCorretores(
                  estado: contatos.$1,
                  periodo: contatos.$2,
                  aoTocarPeriodo: _aoTocarPeriodo,
                  aoLimparPeriodo: () => unawaited(cubit.limparPeriodo()),
                  aoTentarDeNovo: () =>
                      cubit.tentarNovamente(SecaoDaAreaGestor.contatos),
                ),
              ),
              const SizedBox(height: 12),
              BlocSelector<
                AreaGestorCubit,
                AreaGestorState,
                EstadoSecao<MudancasRecentes>
              >(
                selector: (estado) => estado.mudancas,
                builder: (context, mudancas) => SecaoMudancas(
                  estado: mudancas,
                  aoTentarDeNovo: () =>
                      cubit.tentarNovamente(SecaoDaAreaGestor.mudancas),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
