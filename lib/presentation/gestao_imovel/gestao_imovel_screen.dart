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
import 'widgets/cabecalho_gestao.dart';
import 'widgets/historico_situacao.dart';
import 'widgets/secao_situacao.dart';

/// Assinatura de quem abre a gestão de um imóvel a partir do acervo —
/// `AcervoScreen` recebe uma por parâmetro (padrão [abrirGestaoImovel]) para
/// que os testes de widget do acervo não dependam do DI.
typedef AoAbrirGestao = Future<void> Function(
  BuildContext context,
  ImovelAcervo imovel,
);

/// Abre a gestão do imóvel por `Navigator.push` + `MaterialPageRoute` (D-01,
/// sem pacote de rotas). O abridor é o DONO do Cubit da tela: cria, pede a
/// leitura, empurra a rota e fecha o Cubit na volta (RESEARCH, Pattern 5).
///
/// O localizador de serviços só é tocado aqui, no toque — nunca em `build` —
/// e [criarCubit] existe para teste. [imovel] é o do próprio acervo, com
/// `naVitrine` incluso (D-02): é assim que a tela o recebe.
Future<void> abrirGestaoImovel(
  BuildContext context,
  ImovelAcervo imovel, {
  GestaoImovelCubit Function()? criarCubit,
}) async {
  final cubit = (criarCubit ?? () => getIt<GestaoImovelCubit>())()
    ..carregar(imovel.id);
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<GestaoImovelCubit>.value(
        value: cubit,
        child: GestaoImovelScreen(previa: imovel),
      ),
    ),
  );
  await cubit.close();
}

/// Tela de gestão do imóvel (SIT-07): a `AppBar` leva o código do imóvel e o
/// corpo é uma lista com o cabeçalho (foto, código, título, preço — D-03) e,
/// por `switch` exaustivo sobre [ConteudoImovelGestao], o indicador, o erro ou
/// a situação e o histórico. Nenhuma regra, rede ou `try/catch` aqui: só apresenta o que o
/// [GestaoImovelCubit] entrega.
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
      child: Scaffold(
        appBar: AppBar(title: Text(previa.codigo)),
        body: BlocBuilder<GestaoImovelCubit, GestaoImovelState>(
          builder: (context, state) {
            final conteudo = state.imovel;
            return ListView(
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
                      aoTentarDeNovo: () =>
                          context.read<GestaoImovelCubit>().tentarNovamente(),
                    ),
                  ],
                  ImovelGestaoNaoEncontrado() => [
                    const _MensagemDaGestao(texto: textoImovelForaDoAcervo),
                  ],
                  // Enquanto a navegação para o login acontece.
                  ImovelGestaoSessaoExpirada() => [
                    const _MensagemDaGestao(texto: avisoSessaoTerminou),
                  ],
                  ImovelGestaoCarregado(:final imovel) => [
                    SecaoSituacao(imovel: imovel),
                    // D-02: só o que o servidor disse no cartão (na_vitrine);
                    // o app nunca olha publicado nem situação para isso.
                    if (previa.naVitrine) ...[
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
            );
          },
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
