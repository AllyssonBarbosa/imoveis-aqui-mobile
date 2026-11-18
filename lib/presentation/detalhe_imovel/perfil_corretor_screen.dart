import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/contato_do_imovel.dart';
import '../../domain/entities/detalhe_imovel.dart';
import '../contato/contato_cubit.dart';
import '../contato/widgets/barra_contato.dart';
import 'widgets/cartao_corretor.dart';

/// Abre o perfil do corretor por `Navigator.push` (D-18, sem pacote de
/// rotas). Recebe o [CorretorResponsavel] já carregado pelo detalhe e abre
/// com o nome e a foto em memória (D-16): nenhum dado do corretor entra em URL
/// nem há chamada de rede.
///
/// Aberto a partir de um imóvel com canais de contato, recebe o [contato]
/// (id, título e canais já carregados) e mostra a mesma barra de contato da
/// página do imóvel (D-09, D-10). A rota do perfil é uma subárvore nova e não
/// herda o `ContatoCubit` da página, então ele é criado aqui — [criarContatoCubit]
/// existe para teste — e o localizador de serviços só é tocado neste caso.
/// Sem [contato] (ou com canais vazios) a tela é montada como antes, sem
/// botões e sem DI.
Future<void> abrirPerfilCorretor(
  BuildContext context,
  CorretorResponsavel corretor, {
  ContatoDoImovel? contato,
  ContatoCubit Function()? criarContatoCubit,
  Widget Function(String url)? construirImagemDeRede,
}) {
  final comContato = contato != null && contato.canais.isNotEmpty;
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) {
        final tela = PerfilCorretorScreen(
          corretor: corretor,
          contato: comContato ? contato : null,
          construirImagemDeRede: construirImagemDeRede,
        );
        if (!comContato) return tela;
        return BlocProvider<ContatoCubit>(
          create: (_) => (criarContatoCubit ?? () => getIt<ContatoCubit>())(),
          child: tela,
        );
      },
    ),
  );
}

/// Tela de perfil do corretor responsável (DET-05, D-15): mostra o
/// [CorretorResponsavel] que o detalhe já tem em memória — nome e foto — sem
/// chamada de rede. Aberta a partir de um imóvel com canais, tem a barra de
/// contato `Sobre: <título>` (APP 06, D-09); aberta sem imóvel (por exemplo,
/// pela página da empresa do APP 07) não tem botões. Nunca mostra número,
/// e-mail ou CRECI do corretor.
class PerfilCorretorScreen extends StatelessWidget {
  const PerfilCorretorScreen({
    super.key,
    required this.corretor,
    this.contato,
    @visibleForTesting this.construirImagemDeRede,
  });

  final CorretorResponsavel corretor;

  /// Imóvel de origem; sem ele (ou sem canais) a tela não tem barra de contato.
  /// Requer um `ContatoCubit` acima na árvore quando tem canais.
  final ContatoDoImovel? contato;

  /// Ponto de extensão só para teste — troca `CachedNetworkImage` por um
  /// builder determinístico (ver `ImagemRede`). Em produção fica `null`.
  @visibleForTesting
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                style: textTheme.bodyMedium,
              ),
            )
          : null,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: AvatarCorretor(
                foto: corretor.foto,
                raio: 56,
                construirImagemDeRede: construirImagemDeRede,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              corretor.nome,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Corretor responsável por este imóvel',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
