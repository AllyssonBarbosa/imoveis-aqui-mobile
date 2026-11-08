import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/detalhe_imovel.dart';
import '../../domain/entities/perfil_corretor.dart';
import '../detalhe_imovel/widgets/cartao_corretor.dart';
import 'perfil_corretor_cubit.dart';
import 'apresentacao_perfil.dart';
import 'perfil_state.dart';
import 'widgets/aviso_perfil.dart';
import 'widgets/secoes_perfil.dart';

/// Abre o perfil do corretor por `Navigator.push` (sem pacote de rotas). Recebe
/// o [CorretorResponsavel] já carregado pelo detalhe como PRÉVIA (foto + nome
/// aparecem na hora) e busca o perfil completo pelo `id` dele (D-05). É o ÚNICO
/// ponto que resolve o [PerfilCorretorCubit] no DI, e só no toque;
/// [criarPerfilCubit] existe para teste.
Future<void> abrirPerfilCorretor(
  BuildContext context,
  CorretorResponsavel previa, {
  PerfilCorretorCubit Function()? criarPerfilCubit,
  Widget Function(String url)? construirImagemDeRede,
}) {
  final criar = criarPerfilCubit ?? () => getIt<PerfilCorretorCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider<PerfilCorretorCubit>(
        create: (_) => criar()..carregar(previa.id),
        child: PerfilCorretorScreen(
          previa: previa,
          construirImagemDeRede: construirImagemDeRede,
        ),
      ),
    ),
  );
}

/// Página pública do corretor: mostra a [previa] (foto + nome do detalhe) com
/// um indicador de carregamento e, quando o perfil chega, nome e CRECI do
/// corretor buscado por id. Avatar e nome ficam no mesmo lugar nos dois
/// estados (sem pulo).
class PerfilCorretorScreen extends StatelessWidget {
  const PerfilCorretorScreen({
    super.key,
    required this.previa,
    @visibleForTesting this.construirImagemDeRede,
  });

  final CorretorResponsavel previa;

  /// Ponto de extensão só para teste — troca `CachedNetworkImage` por um
  /// builder determinístico (ver `ImagemRede`). Em produção fica `null`.
  @visibleForTesting
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Corretor')),
      body: BlocBuilder<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
        builder: (context, estado) {
          final Widget conteudo = switch (estado) {
            PerfilCarregando() => SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: _CabecalhoCorretor(
                    foto: previa.foto,
                    nome: previa.nome,
                    construirImagemDeRede: construirImagemDeRede,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
            PerfilCarregado(:final dados) => SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: _CabecalhoCorretor(
                    foto: dados.foto,
                    nome: dados.nome,
                    creci: dados.creci,
                    construirImagemDeRede: construirImagemDeRede,
                  ),
                ),
                // O respiro horizontal de 16 já vem do SecaoDetalhe.
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SecaoApresentacao(texto: dados.apresentacao),
                      SecaoContato(
                        linhas: linhasDeContato(
                          telefone: dados.telefone,
                          whatsapp: dados.whatsapp,
                          email: dados.email,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            PerfilErro() => SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: _CabecalhoCorretor(
                    foto: previa.foto,
                    nome: previa.nome,
                    construirImagemDeRede: construirImagemDeRede,
                  ),
                ),
                SliverToBoxAdapter(
                  child: ErroPerfil(
                    mensagem: 'Não foi possível carregar este perfil.',
                    aoTentarDeNovo: () =>
                        context.read<PerfilCorretorCubit>().tentarNovamente(),
                  ),
                ),
              ],
            ),
            PerfilNaoEncontrado() => const SliverFillRemaining(
              hasScrollBody: false,
              child: AvisoPerfil(
                icone: Icons.person_off_outlined,
                mensagem: 'Este corretor não está mais disponível',
              ),
            ),
          };
          return CustomScrollView(
            slivers: [
              conteudo,
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

/// Avatar, nome e (quando já chegou) a linha de CRECI. Avatar e nome ficam na
/// mesma posição com ou sem [creci], para a transição carregando -> carregado
/// não fazer o conteúdo pular.
class _CabecalhoCorretor extends StatelessWidget {
  const _CabecalhoCorretor({
    required this.foto,
    required this.nome,
    this.creci,
    this.construirImagemDeRede,
  });

  final String? foto;
  final String nome;
  final String? creci;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final creciAtual = creci;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          AvatarCorretor(
            foto: foto,
            raio: 56,
            construirImagemDeRede: construirImagemDeRede,
          ),
          const SizedBox(height: 16),
          Text(
            nome,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (creciAtual != null) ...[
            const SizedBox(height: 8),
            Text(
              'CRECI $creciAtual',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
