import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/anunciante_ref.dart';
import '../../domain/entities/contato_do_imovel.dart';
import '../../domain/entities/detalhe_imovel.dart';
import '../../domain/entities/perfil_corretor.dart';
import '../contato/contato_cubit.dart';
import '../contato/widgets/barra_contato.dart';
import '../detalhe_imovel/detalhe_imovel_screen.dart';
import '../detalhe_imovel/widgets/cartao_corretor.dart';
import 'perfil_corretor_cubit.dart';
import 'apresentacao_perfil.dart';
import 'perfil_empresa_screen.dart';
import 'perfil_state.dart';
import 'vitrine_anunciante_cubit.dart';
import 'widgets/aviso_perfil.dart';
import 'widgets/cartao_empresa.dart';
import 'widgets/corpo_perfil_com_vitrine.dart';
import 'widgets/secoes_perfil.dart';
import 'widgets/sliver_imoveis_anunciante.dart';

/// Abre o perfil do corretor por `Navigator.push` (sem pacote de rotas). Recebe
/// o [CorretorResponsavel] já carregado pelo detalhe como PRÉVIA (foto + nome
/// aparecem na hora) e busca o perfil completo pelo `id` dele (D-05). É o ÚNICO
/// ponto que resolve o [PerfilCorretorCubit] e o [VitrineAnuncianteCubit] no
/// DI, e só no toque; [criarPerfilCubit] e [criarVitrineCubit] existem para
/// teste. O provider da vitrine é PREGUIÇOSO: o Cubit só nasce quando o
/// sliver da vitrine é montado, isto é, com o perfil carregado — um corretor
/// 404 nunca consulta imóveis. [aoAbrirImovel] abre o imóvel tocado na
/// vitrine (padrão [abrirDetalheImovel]); [aoAbrirEmpresa] abre a página da
/// empresa do corretor (padrão [abrirPerfilEmpresa]).
///
/// Aberto a partir de um imóvel com canais de contato, recebe o [contato]
/// (id, título e canais já carregados) e mostra a mesma barra de contato da
/// página do imóvel (APP 06, D-09, D-10). A rota do perfil é uma subárvore
/// nova e não herda o `ContatoCubit` da página, então ele é criado aqui —
/// [criarContatoCubit] existe para teste — e só nesse caso. Sem [contato] (ou
/// com canais vazios, por exemplo vindo da página da empresa) não há barra.
Future<void> abrirPerfilCorretor(
  BuildContext context,
  CorretorResponsavel previa, {
  PerfilCorretorCubit Function()? criarPerfilCubit,
  VitrineAnuncianteCubit Function()? criarVitrineCubit,
  AoAbrirImovel aoAbrirImovel = abrirDetalheImovel,
  AoAbrirEmpresa aoAbrirEmpresa = abrirPerfilEmpresa,
  ContatoDoImovel? contato,
  ContatoCubit Function()? criarContatoCubit,
  Widget Function(String url)? construirImagemDeRede,
}) {
  final comContato = contato != null && contato.canais.isNotEmpty;
  final criarPerfil = criarPerfilCubit ?? () => getIt<PerfilCorretorCubit>();
  final criarVitrine =
      criarVitrineCubit ?? () => getIt<VitrineAnuncianteCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<PerfilCorretorCubit>(
            create: (_) => criarPerfil()..carregar(previa.id),
          ),
          BlocProvider<VitrineAnuncianteCubit>(
            create: (_) =>
                criarVitrine()..carregar(AnuncianteRef.corretor(previa.id)),
          ),
          if (comContato)
            BlocProvider<ContatoCubit>(
              create: (_) =>
                  (criarContatoCubit ?? () => getIt<ContatoCubit>())(),
            ),
        ],
        child: PerfilCorretorScreen(
          previa: previa,
          aoAbrirImovel: aoAbrirImovel,
          aoAbrirEmpresa: aoAbrirEmpresa,
          contato: comContato ? contato : null,
          construirImagemDeRede: construirImagemDeRede,
        ),
      ),
    ),
  );
}

/// Página pública do corretor: mostra a [previa] (foto + nome do detalhe) com
/// um indicador de carregamento e, quando o perfil chega, nome e CRECI do
/// corretor buscado por id. Avatar e nome ficam no mesmo lugar nos dois
/// estados (sem pulo). Aberta a partir de um imóvel com canais, tem a barra de
/// contato `Sobre: <título>` (APP 06, D-09).
class PerfilCorretorScreen extends StatelessWidget {
  const PerfilCorretorScreen({
    super.key,
    required this.previa,
    this.aoAbrirImovel = abrirDetalheImovel,
    this.aoAbrirEmpresa = abrirPerfilEmpresa,
    this.contato,
    @visibleForTesting this.construirImagemDeRede,
  });

  final CorretorResponsavel previa;

  /// Abre a página do imóvel tocado na vitrine do corretor.
  final AoAbrirImovel aoAbrirImovel;

  /// Abre a página da empresa do corretor, a partir do cartão do perfil.
  final AoAbrirEmpresa aoAbrirEmpresa;

  /// Imóvel de origem; sem ele (ou sem canais) a tela não tem barra de contato.
  /// Requer um `ContatoCubit` acima na árvore quando tem canais.
  final ContatoDoImovel? contato;

  /// Ponto de extensão só para teste — troca `CachedNetworkImage` por um
  /// builder determinístico (ver `ImagemRede`). Em produção fica `null`.
  @visibleForTesting
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final contato = this.contato;
    return Scaffold(
      appBar: AppBar(title: const Text('Corretor')),
      bottomNavigationBar: contato != null && contato.canais.isNotEmpty
          ? BarraContato(
              imovelId: contato.imovelId,
              canais: contato.canais,
              legenda: Text(
                'Sobre: ${contato.titulo}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : null,
      body: BlocBuilder<PerfilCorretorCubit, PerfilState<PerfilCorretor>>(
        builder: (context, estado) {
          // Cabeçalho = slivers do estado do perfil; a vitrine só existe com
          // o perfil carregado (um 404 nunca consulta imóveis).
          final List<Widget> cabecalho = switch (estado) {
            PerfilCarregando() => [
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
            PerfilCarregado(:final dados) => [
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
                    if (dados.empresaId case final empresaId?)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        child: CartaoEmpresa(
                          aoTocar: () => aoAbrirEmpresa(context, empresaId),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            PerfilErro() => [
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
            PerfilNaoEncontrado() => const [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AvisoPerfil(
                  icone: Icons.person_off_outlined,
                  mensagem: 'Este corretor não está mais disponível',
                ),
              ),
            ],
          };
          final Widget? vitrine = switch (estado) {
            PerfilCarregado(:final dados) => SliverImoveisDoAnunciante(
              titulo: tituloImoveisDe(dados.nome),
              aoAbrirImovel: aoAbrirImovel,
            ),
            PerfilCarregando() || PerfilErro() || PerfilNaoEncontrado() => null,
          };
          return CorpoPerfilComVitrine(cabecalho: cabecalho, vitrine: vitrine);
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
