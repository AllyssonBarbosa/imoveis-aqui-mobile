import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/imovel.dart';
import '../vitrine/apresentacao_imovel.dart';
import '../vitrine/widgets/foto_capa_imovel.dart';
import 'detalhe_imovel_cubit.dart';
import 'detalhe_imovel_state.dart';

/// Assinatura de quem abre a página de um imóvel a partir da vitrine —
/// `VitrineScreen` recebe uma por parâmetro (default [abrirDetalheImovel])
/// para que os testes de widget da vitrine não dependam do DI.
typedef AoAbrirImovel =
    Future<void> Function(BuildContext context, Imovel imovel);

/// Abre a página do imóvel por `Navigator.push` (D-18, sem pacote de rotas).
/// [previa] é o `Imovel` que a vitrine já tinha: a página o mostra na hora,
/// enquanto o detalhe carrega. O localizador de serviços só é tocado aqui,
/// no toque — nunca em `build` — e [criarCubit] existe para teste.
Future<void> abrirDetalheImovel(
  BuildContext context,
  Imovel previa, {
  DetalheImovelCubit Function()? criarCubit,
}) {
  final criar = criarCubit ?? () => getIt<DetalheImovelCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<DetalheImovelCubit>(
        create: (_) => criar()..carregar(previa.id),
        child: DetalheImovelScreen(previa: previa),
      ),
    ),
  );
}

/// Página do imóvel (DET-01): `SliverAppBar` fixo com a capa da prévia e o
/// botão voltar sempre visível (D-09), cabeçalho alimentado pela prévia (não
/// "pula" quando o detalhe chega) e, abaixo, o desfecho do carregamento —
/// `switch` exaustivo sobre [DetalheImovelState], sem ramo abrangente. Sem
/// barra inferior fixa (D-12).
class DetalheImovelScreen extends StatelessWidget {
  const DetalheImovelScreen({super.key, required this.previa});

  final Imovel previa;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final largura = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: BlocBuilder<DetalheImovelCubit, DetalheImovelState>(
        builder: (context, state) {
          return CustomScrollView(
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
                  background: FotoCapaImovel(url: previa.fotoCapa),
                ),
              ),
              SliverToBoxAdapter(child: _Cabecalho(previa: previa)),
              switch (state) {
                DetalheCarregando() => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                DetalheCarregado(:final detalhe) => SliverToBoxAdapter(
                  child: _SecaoDescricao(descricao: detalhe.descricao),
                ),
                DetalheErro() => const SliverToBoxAdapter(
                  child: _CorpoErro(),
                ),
              },
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 24,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Título, localização e preço(s) da prévia — fica no mesmo lugar do início
/// ao fim do carregamento (Pitfall 8).
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.previa});

  final Imovel previa;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final localizacao = [
      previa.bairro,
      '${previa.cidade.nome}, ${previa.cidade.uf}',
    ].where((texto) => texto.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(previa.titulo, style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            localizacao,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          for (final linha in linhasDePreco(previa))
            Text(
              linha,
              style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
            ),
        ],
      ),
    );
  }
}

/// Seção "Descrição" (D-14) — texto simples, nunca HTML nem links; some por
/// inteiro quando a descrição vem vazia.
class _SecaoDescricao extends StatelessWidget {
  const _SecaoDescricao({required this.descricao});

  final String descricao;

  @override
  Widget build(BuildContext context) {
    if (descricao.trim().isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Descrição', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(descricao, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Falha ao buscar o detalhe (D-17).
class _CorpoErro extends StatelessWidget {
  const _CorpoErro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'Não foi possível carregar este imóvel.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
