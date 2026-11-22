import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/imovel_acervo.dart';
import '../../domain/entities/imovel_gestao.dart';
import '../acervo/apresentacao_acervo.dart';
import 'apresentacao_gestao.dart';
import 'gestao_imovel_cubit.dart';
import 'gestao_imovel_state.dart';

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
/// corpo mostra o desfecho da leitura — `switch` exaustivo sobre
/// [ConteudoImovelGestao], sem ramo abrangente. Nenhuma regra, rede ou
/// `try/catch` aqui: só apresenta o que o [GestaoImovelCubit] entrega.
class GestaoImovelScreen extends StatelessWidget {
  const GestaoImovelScreen({super.key, required this.previa});

  /// O imóvel como o cartão do acervo o tinha (código para o título da tela).
  final ImovelAcervo previa;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(previa.codigo)),
      body: BlocBuilder<GestaoImovelCubit, GestaoImovelState>(
        builder: (context, state) => switch (state.imovel) {
          ImovelGestaoCarregando() => const Center(
            child: CircularProgressIndicator(),
          ),
          ImovelGestaoErro() => _ErroDaGestao(
            aoTentarDeNovo: () =>
                context.read<GestaoImovelCubit>().tentarNovamente(),
          ),
          ImovelGestaoCarregado(:final imovel) => _CorpoDaGestao(
            imovel: imovel,
          ),
        },
      ),
    );
  }
}

/// Imóvel lido: título e a situação atual que o servidor mandou.
class _CorpoDaGestao extends StatelessWidget {
  const _CorpoDaGestao({required this.imovel});

  final ImovelGestao imovel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final situacao = imovel.situacao;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(imovel.titulo, style: textTheme.titleLarge),
        if (situacao != null) ...[
          const SizedBox(height: 8),
          Text(rotuloSituacao(situacao), style: textTheme.titleMedium),
        ],
      ],
    );
  }
}

/// Falha na primeira carga: texto fixo e "Tentar de novo".
class _ErroDaGestao extends StatelessWidget {
  const _ErroDaGestao({required this.aoTentarDeNovo});

  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }
}
