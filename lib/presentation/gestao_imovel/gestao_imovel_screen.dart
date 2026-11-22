import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/imovel_acervo.dart';
import '../detalhe_imovel/detalhe_imovel_screen.dart';
import '../login/apresentacao_login.dart';
import '../sessao/sessao_expirada.dart';
import 'apresentacao_gestao.dart';
import 'gestao_imovel_cubit.dart';
import 'gestao_imovel_state.dart';
import 'mudar_situacao_cubit.dart';
import 'mudar_situacao_state.dart';
import 'widgets/cabecalho_gestao.dart';
import 'widgets/historico_situacao.dart';
import 'widgets/mudar_situacao_sheet.dart';
import 'widgets/secao_situacao.dart';

/// Assinatura de quem abre a gestão de um imóvel a partir do acervo —
/// `AcervoScreen` recebe uma por parâmetro (padrão [abrirGestaoImovel]) para
/// que os testes de widget do acervo não dependam do DI. Devolve `true` quando
/// a situação do imóvel mudou durante a visita (D-12): o acervo relê a API.
typedef AoAbrirGestao = Future<bool> Function(
  BuildContext context,
  ImovelAcervo imovel,
);

/// Abre a gestão do imóvel por `Navigator.push` + `MaterialPageRoute` (D-01,
/// sem pacote de rotas). O abridor é o DONO do Cubit da tela: cria, pede a
/// leitura, empurra a rota e fecha o Cubit na volta (RESEARCH, Pattern 5).
///
/// O localizador de serviços só é tocado aqui, no toque — nunca em `build` —
/// e [criarCubit] e [criarMudarSituacaoCubit] existem para teste. [imovel] é o
/// do próprio acervo, com `naVitrine` incluso (D-02): é assim que a tela o
/// recebe. O Cubit da folha de mudança de situação é criado e fechado pelo
/// próprio `BlocProvider(create:)` da rota.
///
/// Devolve `cubit.state.mudou` lido DEPOIS da volta (D-12): vale para o botão
/// da `AppBar`, o botão voltar do sistema e o gesto do iOS, que não passam
/// resultado pelo `pop` (RESEARCH, Pattern 5). A tela não usa `PopScope` —
/// ele desligaria o gesto de voltar do iOS.
Future<bool> abrirGestaoImovel(
  BuildContext context,
  ImovelAcervo imovel, {
  GestaoImovelCubit Function()? criarCubit,
  MudarSituacaoCubit Function()? criarMudarSituacaoCubit,
}) async {
  final cubit = (criarCubit ?? () => getIt<GestaoImovelCubit>())()
    ..carregar(imovel.id);
  final criarMudar =
      criarMudarSituacaoCubit ?? () => getIt<MudarSituacaoCubit>();
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<GestaoImovelCubit>.value(value: cubit),
          BlocProvider<MudarSituacaoCubit>(create: (_) => criarMudar()),
        ],
        child: GestaoImovelScreen(previa: imovel),
      ),
    ),
  );
  final mudou = cubit.state.mudou;
  await cubit.close();
  return mudou;
}

/// Tela de gestão do imóvel (SIT-07): a `AppBar` leva o código do imóvel e o
/// corpo é uma lista com o cabeçalho (foto, código, título, preço — D-03) e,
/// por `switch` exaustivo sobre [ConteudoImovelGestao], o indicador, o erro ou
/// a situação e o histórico. Nenhuma regra, rede ou `try/catch` aqui: só
/// apresenta o que o [GestaoImovelCubit] entrega. O botão "Mudar situação" só
/// existe quando o servidor disse `pode_mudar_situacao` (D-04); depois de uma
/// mudança aceita, avisa e relê a API (D-10) e "Ver na vitrine" some (D-18).
class GestaoImovelScreen extends StatefulWidget {
  const GestaoImovelScreen({
    super.key,
    required this.previa,
    this.aoVerNaVitrine = abrirDetalheImovel,
    @visibleForTesting this.construirImagemDeRede,
  });

  /// O imóvel como o cartão do acervo o tinha: código, foto de capa, título,
  /// preço (enquanto o servidor responde) e `naVitrine` (D-02).
  final ImovelAcervo previa;

  /// Abre a página pública do imóvel (padrão [abrirDetalheImovel]); só é
  /// chamada a partir de "Ver na vitrine".
  final AoAbrirImovel aoVerNaVitrine;

  /// Ponto de extensão só para teste (ver `ImagemRede`); em produção `null`.
  final Widget Function(String url)? construirImagemDeRede;

  @override
  State<GestaoImovelScreen> createState() => _GestaoImovelScreenState();
}

/// `StatefulWidget` só para conferir o estado já presente quando a tela abre: o
/// abridor pede a leitura antes de empurrar a rota, então um 401 pode ter
/// chegado antes de o `BlocListener` existir — e ele só enxerga transições
/// (D-10).
class _GestaoImovelScreenState extends State<GestaoImovelScreen> {
  @override
  void initState() {
    super.initState();
    final jaExpirada =
        context.read<GestaoImovelCubit>().state.imovel
            is ImovelGestaoSessaoExpirada;
    if (!jaExpirada) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(voltarAoLoginComSessaoTerminada(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final previa = widget.previa;
    return BlocListener<GestaoImovelCubit, GestaoImovelState>(
      // 401 em qualquer das duas leituras: sessão terminada, volta ao login
      // pelo helper único do app (D-10).
      listenWhen: (anterior, atual) =>
          anterior.imovel is! ImovelGestaoSessaoExpirada &&
          atual.imovel is ImovelGestaoSessaoExpirada,
      listener: (context, state) =>
          unawaited(voltarAoLoginComSessaoTerminada(context)),
      child: BlocListener<GestaoImovelCubit, GestaoImovelState>(
        // Atualização que falhou com conteúdo na tela: o conteúdo fica e um
        // SnackBar avisa (D-10, AC-2).
        listenWhen: (anterior, atual) =>
            atual.falhasAoAtualizar > anterior.falhasAoAtualizar,
        listener: (context, state) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text(textoFalhaAoAtualizar))),
        child: BlocListener<MudarSituacaoCubit, MudarSituacaoState>(
          // 401 no envio da folha: sessão terminada, volta ao login pelo helper
          // único; o `pushAndRemoveUntil` do helper tira a folha também (D-10).
          listenWhen: (anterior, atual) =>
              anterior.envio is! EnvioSessaoExpirada &&
              atual.envio is EnvioSessaoExpirada,
          listener: (context, state) =>
              unawaited(voltarAoLoginComSessaoTerminada(context)),
          child: BlocListener<MudarSituacaoCubit, MudarSituacaoState>(
            // O servidor aceitou a mudança (a folha fecha sozinha): avisa com o
            // texto do site e relê imóvel e histórico — a tela só mostra o que
            // a API devolver (D-10, T-09-03).
            listenWhen: (anterior, atual) =>
                anterior.envio is! EnvioConcluido &&
                atual.envio is EnvioConcluido,
            listener: (context, state) {
              final envio = state.envio;
              if (envio is! EnvioConcluido) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(textoSituacaoAlterada(envio.situacao))),
              );
              unawaited(context.read<GestaoImovelCubit>().registrarMudanca());
            },
            child: Scaffold(
              appBar: AppBar(title: Text(previa.codigo)),
              body: BlocBuilder<GestaoImovelCubit, GestaoImovelState>(
                builder: (context, state) {
                  final conteudo = state.imovel;
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<GestaoImovelCubit>().recarregar(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        CabecalhoGestao(
                          previa: previa,
                          imovel: switch (conteudo) {
                            ImovelGestaoCarregado(:final imovel) => imovel,
                            ImovelGestaoCarregando() ||
                            ImovelGestaoErro() ||
                            ImovelGestaoNaoEncontrado() ||
                            ImovelGestaoSessaoExpirada() => null,
                          },
                          construirImagemDeRede: widget.construirImagemDeRede,
                        ),
                        const SizedBox(height: 16),
                        ...switch (conteudo) {
                          ImovelGestaoCarregando() => const [
                            Center(child: CircularProgressIndicator()),
                          ],
                          ImovelGestaoErro() => [
                            _ErroDaGestao(
                              aoTentarDeNovo: () => context
                                  .read<GestaoImovelCubit>()
                                  .tentarNovamente(),
                            ),
                          ],
                          ImovelGestaoNaoEncontrado() => [
                            const _MensagemDaGestao(
                              texto: textoImovelForaDoAcervo,
                            ),
                          ],
                          // Enquanto a navegação para o login acontece.
                          ImovelGestaoSessaoExpirada() => [
                            const _MensagemDaGestao(texto: avisoSessaoTerminou),
                          ],
                          ImovelGestaoCarregado(:final imovel) => [
                            SecaoSituacao(imovel: imovel),
                            // D-04: só o que o servidor disse (pode_mudar_situacao);
                            // nenhum widget decide quem pode mudar.
                            if (imovel.podeMudarSituacao) ...[
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    final mudar =
                                        context.read<MudarSituacaoCubit>()
                                          ..iniciar(
                                            imovelId: imovel.id,
                                            atual: imovel.situacao,
                                          );
                                    unawaited(
                                      mostrarMudarSituacaoSheet(
                                        context,
                                        cubit: mudar,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.swap_horiz),
                                  label: const Text(rotuloBotaoMudarSituacao),
                                ),
                              ),
                            ],
                            // D-02: só o que o servidor disse no cartão (na_vitrine);
                            // o app nunca olha publicado nem situação para isso.
                            // D-18: depois de uma mudança o botão some até reabrir.
                            if (previa.naVitrine && !state.mudou) ...[
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: OutlinedButton.icon(
                                  onPressed: () => widget.aoVerNaVitrine(
                                    context,
                                    previa.paraPrevia(),
                                  ),
                                  icon: const Icon(Icons.storefront),
                                  label: const Text(rotuloVerNaVitrine),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            HistoricoSituacao(
                              conteudo: state.historico,
                              aoTentarDeNovo: () => context
                                  .read<GestaoImovelCubit>()
                                  .tentarNovamenteHistorico(),
                            ),
                          ],
                        },
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mensagem fixa de um desfecho sem conteúdo e sem nova tentativa (imóvel fora
/// do acervo, sessão terminada).
class _MensagemDaGestao extends StatelessWidget {
  const _MensagemDaGestao({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }
}

/// Falha na primeira carga: texto fixo e "Tentar de novo".
class _ErroDaGestao extends StatelessWidget {
  const _ErroDaGestao({required this.aoTentarDeNovo});

  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          textoErroGestao,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: aoTentarDeNovo,
          child: const Text(rotuloTentarDeNovo),
        ),
      ],
    );
  }
}
