import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/imovel_acervo.dart';
import '../detalhe_imovel/detalhe_imovel_screen.dart';
import 'apresentacao_gestao.dart';
import 'gestao_imovel_cubit.dart';
import 'gestao_imovel_state.dart';
import 'widgets/cabecalho_gestao.dart';
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
/// a situação. Nenhuma regra, rede ou `try/catch` aqui: só apresenta o que o
/// [GestaoImovelCubit] entrega.
class GestaoImovelScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
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
                  ImovelGestaoCarregando() || ImovelGestaoErro() => null,
                },
                construirImagemDeRede: construirImagemDeRede,
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
                ImovelGestaoCarregado(:final imovel) => [
                  SecaoSituacao(imovel: imovel),
                  // D-02: só o que o servidor disse no cartão (na_vitrine);
                  // o app nunca olha publicado nem situação para isso.
                  if (previa.naVitrine) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            aoVerNaVitrine(context, previa.paraPrevia()),
                        icon: const Icon(Icons.storefront),
                        label: const Text(rotuloVerNaVitrine),
                      ),
                    ),
                  ],
                ],
              },
            ],
          );
        },
      ),
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
