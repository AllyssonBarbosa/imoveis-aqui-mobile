import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/imovel.dart';
import '../vitrine/apresentacao_imovel.dart';
import '../comum/imagem_rede.dart';
import '../contato/contato_cubit.dart';
import '../contato/widgets/barra_contato.dart';
import 'detalhe_imovel_cubit.dart';
import 'detalhe_imovel_state.dart';
import 'perfil_corretor_screen.dart';
import 'widgets/cartao_corretor.dart';
import 'widgets/galeria_imovel.dart';
import 'widgets/secao_natureza.dart';
import 'widgets/secoes_detalhe.dart';
import 'widgets/visualizador_fotos.dart';

/// Assinatura de quem abre a página de um imóvel a partir da vitrine —
/// `VitrineScreen` recebe uma por parâmetro (default [abrirDetalheImovel])
/// para que os testes de widget da vitrine não dependam do DI.
typedef AoAbrirImovel = Future<void> Function(
  BuildContext context,
  Imovel imovel,
);

/// Abre a página do imóvel por `Navigator.push` (D-18, sem pacote de rotas).
/// [previa] é o `Imovel` que a vitrine já tinha: a página o mostra na hora,
/// enquanto o detalhe carrega. O localizador de serviços só é tocado aqui,
/// no toque — nunca em `build` — e [criarCubit] e [criarContatoCubit] existem
/// para teste.
Future<void> abrirDetalheImovel(
  BuildContext context,
  Imovel previa, {
  DetalheImovelCubit Function()? criarCubit,
  ContatoCubit Function()? criarContatoCubit,
}) {
  final criar = criarCubit ?? () => getIt<DetalheImovelCubit>();
  final criarContato = criarContatoCubit ?? () => getIt<ContatoCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<DetalheImovelCubit>(
            create: (_) => criar()..carregar(previa.id),
          ),
          BlocProvider<ContatoCubit>(create: (_) => criarContato()),
        ],
        child: DetalheImovelScreen(previa: previa),
      ),
    ),
  );
}

/// Página do imóvel (DET-01): `SliverAppBar` fixo com a galeria de fotos (a
/// capa da prévia enquanto carrega) e o botão voltar sempre visível (D-09), cabeçalho alimentado pela prévia (não
/// "pula" quando o detalhe chega) e, abaixo, o desfecho do carregamento —
/// `switch` exaustivo sobre [DetalheImovelState], sem ramo abrangente. A barra
/// de contato inferior fixa (APP 06, D-05) só existe com o detalhe carregado e
/// ao menos um canal de contato; nos demais estados não há barra (D-03, D-08).
class DetalheImovelScreen extends StatelessWidget {
  const DetalheImovelScreen({
    super.key,
    required this.previa,
    @visibleForTesting this.construirImagemDeRede,
  });

  final Imovel previa;

  /// Ponto de extensão só para teste — troca `CachedNetworkImage` por um
  /// builder determinístico (ver `ImagemRede`). Em produção fica `null`.
  @visibleForTesting
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final largura = MediaQuery.sizeOf(context).width;
    return BlocBuilder<DetalheImovelCubit, DetalheImovelState>(
      builder: (context, state) {
        return Scaffold(
          bottomNavigationBar: switch (state) {
            DetalheCarregado(:final detalhe)
                when detalhe.canaisContato.isNotEmpty =>
              BarraContato(
                imovelId: detalhe.id,
                canais: detalhe.canaisContato,
                legenda: _LegendaPrecoDaBarra(
                  linhas: linhasDePrecoPorFinalidade(
                    finalidade: detalhe.finalidade,
                    precoVenda: detalhe.precoVenda,
                    precoAluguel: detalhe.precoAluguel,
                  ),
                ),
              ),
            _ => null,
          },
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                expandedHeight: math.min(largura * 3 / 4, 420),
                leading: Padding(
                  padding: const EdgeInsets.all(4),
                  child: IconButton.filled(
                    tooltip: 'Voltar',
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surface.withValues(
                        alpha: 0.8,
                      ),
                      foregroundColor: colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  // Carregado: galeria com todas as fotos (DET-02). Nos demais
                  // estados, a capa da prévia, sem contador (D-16).
                  background: switch (state) {
                    DetalheCarregado(:final detalhe) => GaleriaImovel(
                      urls: [for (final foto in detalhe.fotos) foto.url],
                      aoTocarFoto: (indice) => abrirVisualizadorFotos(
                        context,
                        urls: [for (final foto in detalhe.fotos) foto.url],
                        indiceInicial: indice,
                        construirImagemDeRede: construirImagemDeRede,
                      ),
                      construirImagemDeRede: construirImagemDeRede,
                    ),
                    _ => ImagemRede(
                      url: previa.fotoCapa,
                      construirImagemDeRede: construirImagemDeRede,
                    ),
                  },
                ),
              ),
              // No 404 o imóvel saiu do ar: o preço da prévia não é mostrado.
              if (state is! DetalheNaoEncontrado)
                SliverToBoxAdapter(
                  child: switch (state) {
                    // Carregado: o mesmo cabeçalho, agora alimentado pelo
                    // detalhe (preços completos e custos), no mesmo lugar.
                    DetalheCarregado(:final detalhe) => _Cabecalho(
                      titulo: detalhe.titulo,
                      localizacao: rotuloLocalizacao(
                        detalhe.bairro,
                        detalhe.cidade,
                      ),
                      linhasPreco: linhasDePrecoPorFinalidade(
                        finalidade: detalhe.finalidade,
                        precoVenda: detalhe.precoVenda,
                        precoAluguel: detalhe.precoAluguel,
                      ),
                      linhasCustos: linhasDeCustos(
                        precoCondominio: detalhe.precoCondominio,
                        precoIptu: detalhe.precoIptu,
                      ),
                    ),
                    _ => _Cabecalho(
                      titulo: previa.titulo,
                      localizacao: rotuloLocalizacao(previa.bairro, null),
                      linhasPreco: linhasDePreco(previa),
                    ),
                  },
                ),
              switch (state) {
                DetalheCarregando() => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                // Natureza antes da descrição (D-11).
                DetalheCarregado(:final detalhe) => SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (detalhe.dados case final dados?)
                        SecaoNatureza(dados: dados),
                      SecaoDescricao(descricao: detalhe.descricao),
                      SecaoCaracteristicas(
                        caracteristicas: detalhe.caracteristicas,
                      ),
                      if (detalhe.corretor case final corretor?)
                        SecaoDetalhe(
                          titulo: 'Corretor responsável',
                          conteudo: CartaoCorretor(
                            corretor: corretor,
                            aoTocar: () => abrirPerfilCorretor(
                              context,
                              corretor,
                              construirImagemDeRede: construirImagemDeRede,
                            ),
                            construirImagemDeRede: construirImagemDeRede,
                          ),
                        ),
                    ],
                  ),
                ),
                DetalheErro() => const SliverToBoxAdapter(child: _CorpoErro()),
                DetalheNaoEncontrado() => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _CorpoNaoEncontrado(),
                ),
              },
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 24,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Preço(s) na barra de contato (D-07): as mesmas linhas do cabeçalho, sem
/// formatação nova. Mostra todas quando cada uma cabe na largura da legenda;
/// em `VENDA_E_ALUGUEL` longo demais mostra só a principal (a primeira) e o
/// resto fica no cabeçalho. É só layout de exibição — nunca reformata nem
/// recalcula as linhas.
class _LegendaPrecoDaBarra extends StatelessWidget {
  const _LegendaPrecoDaBarra({required this.linhas});

  final List<String> linhas;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.titleMedium
        ?.copyWith(color: Theme.of(context).colorScheme.primary);
    final base = DefaultTextStyle.of(context).style.merge(estilo);
    final direcao = Directionality.of(context);
    final escala = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool cabe(String linha) {
          final medidor = TextPainter(
            text: TextSpan(text: linha, style: base),
            maxLines: 1,
            textDirection: direcao,
            textScaler: escala,
          )..layout();
          final largura = medidor.width;
          medidor.dispose();
          return largura <= constraints.maxWidth;
        }

        final visiveis = linhas.every(cabe) ? linhas : [linhas.first];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final linha in visiveis)
              Text(
                linha,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: estilo,
              ),
          ],
        );
      },
    );
  }
}

/// Título, localização, preço(s) e custos — alimentado pela prévia enquanto o
/// detalhe carrega e pelo próprio detalhe depois; é o mesmo widget no mesmo
/// lugar do início ao fim (Pitfall 8). Só apresenta strings já prontas.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.titulo,
    required this.localizacao,
    required this.linhasPreco,
    this.linhasCustos = const [],
  });

  final String titulo;
  final String localizacao;
  final List<String> linhasPreco;
  final List<String> linhasCustos;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            localizacao,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          for (final linha in linhasPreco)
            Text(
              linha,
              style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
            ),
          for (final linha in linhasCustos)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                linha,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Falha ao buscar o detalhe (D-17): mensagem + "Tentar de novo".
class _CorpoErro extends StatelessWidget {
  const _CorpoErro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Não foi possível carregar este imóvel.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () =>
                  context.read<DetalheImovelCubit>().tentarNovamente(),
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 404 (D-17): imóvel inexistente ou despublicado — repetir não resolve, então
/// só oferece o caminho de volta à vitrine.
class _CorpoNaoEncontrado extends StatelessWidget {
  const _CorpoNaoEncontrado();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_work_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'Este imóvel não está mais disponível',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Voltar à vitrine'),
            ),
          ],
        ),
      ),
    );
  }
}
