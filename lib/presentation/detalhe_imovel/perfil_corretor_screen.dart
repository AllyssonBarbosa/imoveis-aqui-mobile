import 'package:flutter/material.dart';

import '../../domain/entities/detalhe_imovel.dart';
import 'widgets/cartao_corretor.dart';

/// Abre o perfil do corretor por `Navigator.push` (D-18, sem pacote de
/// rotas). Recebe o [CorretorResponsavel] já carregado pelo detalhe: nem o
/// `id` nem o `slug` (PENDENTE E2) entram em URL nesta fase.
Future<void> abrirPerfilCorretor(
  BuildContext context,
  CorretorResponsavel corretor, {
  Widget Function(String url)? construirImagemDeRede,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PerfilCorretorScreen(
        corretor: corretor,
        construirImagemDeRede: construirImagemDeRede,
      ),
    ),
  );
}

/// Tela de perfil do corretor responsável (DET-05, D-15): mostra apenas o
/// [CorretorResponsavel] que o detalhe já tem em memória — nome e foto. Não
/// faz nenhuma chamada de rede e não tem nenhum campo de contato: o perfil
/// completo (empresa, outros imóveis) é o APP 07 e o contato é o APP 06.
class PerfilCorretorScreen extends StatelessWidget {
  const PerfilCorretorScreen({
    super.key,
    required this.corretor,
    @visibleForTesting this.construirImagemDeRede,
  });

  final CorretorResponsavel corretor;

  /// Ponto de extensão só para teste — troca `CachedNetworkImage` por um
  /// builder determinístico (ver `ImagemRede`). Em produção fica `null`.
  @visibleForTesting
  final Widget Function(String url)? construirImagemDeRede;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Corretor')),
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
