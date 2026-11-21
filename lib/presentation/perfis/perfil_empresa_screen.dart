import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/anunciante_ref.dart';
import '../../domain/entities/perfil_empresa.dart';
import '../comum/imagem_rede.dart';
import '../detalhe_imovel/detalhe_imovel_screen.dart';
import 'apresentacao_perfil.dart';
import 'perfil_empresa_cubit.dart';
import 'perfil_state.dart';
import 'vitrine_anunciante_cubit.dart';
import 'widgets/aviso_perfil.dart';
import 'widgets/chips_cidades_atuacao.dart';
import 'widgets/corpo_perfil_com_vitrine.dart';
import 'widgets/secoes_perfil.dart';
import 'widgets/sliver_imoveis_anunciante.dart';

/// Contrato de quem abre a página da empresa a partir do perfil do corretor —
/// recebe só o id (o único dado da empresa que o corretor conhece).
typedef AoAbrirEmpresa = Future<void> Function(
  BuildContext context,
  int empresaId,
);

/// Abre a página da empresa por `Navigator.push` (sem pacote de rotas). É o
/// ÚNICO ponto que resolve o [PerfilEmpresaCubit] e o [VitrineAnuncianteCubit]
/// no DI, e só no toque; [criarPerfilEmpresaCubit] e [criarVitrineCubit]
/// existem para teste. O provider da vitrine é PREGUIÇOSO: o Cubit só nasce
/// quando o sliver da vitrine é montado, isto é, com a empresa carregada — uma
/// empresa 404 nunca consulta imóveis. Não há prévia: só o [empresaId] é
/// conhecido, então a página abre com um indicador de carregamento até a API
/// de perfis responder. [aoAbrirImovel] abre o imóvel tocado na vitrine
/// (padrão [abrirDetalheImovel]).
Future<void> abrirPerfilEmpresa(
  BuildContext context,
  int empresaId, {
  PerfilEmpresaCubit Function()? criarPerfilEmpresaCubit,
  VitrineAnuncianteCubit Function()? criarVitrineCubit,
  AoAbrirImovel aoAbrirImovel = abrirDetalheImovel,
  Widget Function(String url)? construirImagemDeRede,
}) {
  final criarPerfil =
      criarPerfilEmpresaCubit ?? () => getIt<PerfilEmpresaCubit>();
  final criarVitrine =
      criarVitrineCubit ?? () => getIt<VitrineAnuncianteCubit>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<PerfilEmpresaCubit>(
            create: (_) => criarPerfil()..carregar(empresaId),
          ),
          BlocProvider<VitrineAnuncianteCubit>(
            create: (_) =>
                criarVitrine()..carregar(AnuncianteRef.empresa(empresaId)),
          ),
        ],
        child: PerfilEmpresaScreen(
          aoAbrirImovel: aoAbrirImovel,
          construirImagemDeRede: construirImagemDeRede,
        ),
      ),
    ),
  );
}

/// Página pública da empresa anunciante: logomarca, nome, tipo e CRECI,
/// seguidos de Apresentação, Contato (texto selecionável), Cidades de atuação
/// e a vitrine de imóveis da empresa, como a API de perfis informa. Os
/// desfechos 404 e falha reaproveitam o aviso e o erro compartilhados com o
/// perfil do corretor.
class PerfilEmpresaScreen extends StatelessWidget {
  const PerfilEmpresaScreen({
    super.key,
    this.aoAbrirImovel = abrirDetalheImovel,
    @visibleForTesting this.construirImagemDeRede,
  });

  /// Abre a página do imóvel tocado na vitrine da empresa.
  final AoAbrirImovel aoAbrirImovel;

  /// Ponto de extensão só para teste — troca `CachedNetworkImage` por um
  /// builder determinístico (ver `ImagemRede`). Em produção fica `null`.
  @visibleForTesting
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anunciante')),
      body: BlocBuilder<PerfilEmpresaCubit, PerfilState<PerfilEmpresa>>(
        builder: (context, estado) {
          final List<Widget> cabecalho = switch (estado) {
            PerfilCarregando() => const [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
            PerfilCarregado(:final dados) => [
              SliverToBoxAdapter(
                child: _CabecalhoEmpresa(
                  empresa: dados,
                  construirImagemDeRede: construirImagemDeRede,
                ),
              ),
              // O respiro horizontal de 16 já vem do SecaoDetalhe.
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SecaoApresentacao(texto: dados.descricao),
                    SecaoContato(
                      linhas: linhasDeContato(
                        telefone: dados.telefone,
                        whatsapp: dados.whatsapp,
                        email: dados.email,
                      ),
                    ),
                    ChipsCidadesAtuacao(cidades: dados.cidadesAtuacao),
                  ],
                ),
              ),
            ],
            PerfilErro() => [
              SliverToBoxAdapter(
                child: ErroPerfil(
                  mensagem: 'Não foi possível carregar esta página.',
                  aoTentarDeNovo: () =>
                      context.read<PerfilEmpresaCubit>().tentarNovamente(),
                ),
              ),
            ],
            PerfilNaoEncontrado() => const [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AvisoPerfil(
                  icone: Icons.domain_disabled_outlined,
                  mensagem: 'Esta página não está mais disponível',
                ),
              ),
            ],
          };
          // A vitrine só existe com a empresa carregada (um 404 nunca consulta
          // imóveis).
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

/// Logomarca, nome, tipo e CRECI da empresa, centrados. Tipo e CRECI só
/// aparecem quando a API os informou — nada é deduzido no aparelho.
class _CabecalhoEmpresa extends StatelessWidget {
  const _CabecalhoEmpresa({required this.empresa, this.construirImagemDeRede});

  final PerfilEmpresa empresa;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tipo = empresa.tipo;
    final creci = empresa.creci;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _LogomarcaEmpresa(
            logomarca: empresa.logomarca,
            construirImagemDeRede: construirImagemDeRede,
          ),
          const SizedBox(height: 16),
          Text(
            empresa.nome,
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (tipo != null) ...[
            const SizedBox(height: 4),
            Text(
              rotuloTipoEmpresa(tipo),
              style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
              textAlign: TextAlign.center,
            ),
          ],
          if (creci != null) ...[
            const SizedBox(height: 8),
            Text(
              'CRECI $creci',
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

/// Logomarca quadrada de 96 com cantos arredondados; sem logomarca (ou se ela
/// falhar), um ícone de prédio sobre o verde claro do tema.
class _LogomarcaEmpresa extends StatelessWidget {
  const _LogomarcaEmpresa({
    required this.logomarca,
    this.construirImagemDeRede,
  });

  final String? logomarca;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.square(
        dimension: 96,
        child: ImagemRede(
          url: logomarca,
          fit: BoxFit.contain,
          imagemPadrao: ColoredBox(
            color: colorScheme.primaryContainer,
            child: Center(
              child: Icon(
                Icons.apartment_outlined,
                size: 48,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          construirImagemDeRede: construirImagemDeRede,
        ),
      ),
    );
  }
}
