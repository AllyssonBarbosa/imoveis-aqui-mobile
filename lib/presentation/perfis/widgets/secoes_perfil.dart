import 'package:flutter/material.dart';

import '../../detalhe_imovel/widgets/secoes_detalhe.dart';
import '../apresentacao_perfil.dart';

/// Seção "Apresentação" do perfil — texto puro (sem HTML, Markdown nem
/// autolink); some por inteiro quando não há texto.
class SecaoApresentacao extends StatelessWidget {
  const SecaoApresentacao({super.key, required this.texto});

  final String? texto;

  @override
  Widget build(BuildContext context) {
    final conteudo = texto;
    if (conteudo == null) return const SizedBox.shrink();
    return SecaoDetalhe(
      titulo: 'Apresentação',
      conteudo: Text(conteudo, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

/// Seção "Contato": telefone, WhatsApp e e-mail como TEXTO selecionável com
/// ícone — nenhum toque, botão ou link (D-10); contato acionável é o APP 06,
/// com regra no servidor. Some por inteiro quando não há nenhuma linha.
class SecaoContato extends StatelessWidget {
  const SecaoContato({super.key, required this.linhas});

  final List<LinhaContato> linhas;

  @override
  Widget build(BuildContext context) {
    if (linhas.isEmpty) return const SizedBox.shrink();
    return SecaoDetalhe(
      titulo: 'Contato',
      conteudo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final linha in linhas) _ItemContato(linha: linha)],
      ),
    );
  }
}

class _ItemContato extends StatelessWidget {
  const _ItemContato({required this.linha});

  final LinhaContato linha;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(linha.icone, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  linha.rotulo,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SelectableText(linha.valor, style: textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
