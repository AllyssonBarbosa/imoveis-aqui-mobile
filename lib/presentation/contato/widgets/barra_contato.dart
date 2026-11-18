import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/canal_contato.dart';
import '../contato_cubit.dart';
import '../contato_state.dart';
import '../rotulos_contato.dart';
import 'contato_bottom_sheet.dart';

/// Barra de contato — [legenda] à esquerda e o botão do canal principal à
/// direita (D-05). Reutilizável na página do imóvel e no perfil do corretor
/// (D-11); só mostra rótulos de canal, nunca link, número ou e-mail.
///
/// O principal é o primeiro canal na ordem fixa WhatsApp, Telefone, E-mail
/// (D-06): a ordenação aqui é só de exibição, pois o servidor já manda os
/// canais calculados. O botão fica desabilitado enquanto um contato está em
/// andamento (D-13). Requer um `ContatoCubit` acima na árvore.
class BarraContato extends StatelessWidget {
  const BarraContato({
    super.key,
    required this.imovelId,
    required this.canais,
    required this.legenda,
  });

  final int imovelId;
  final List<CanalContato> canais;
  final Widget legenda;

  @override
  Widget build(BuildContext context) {
    final ordenados = CanalContato.values.where(canais.contains).toList();
    if (ordenados.isEmpty) return const SizedBox.shrink();
    final principal = ordenados.first;
    final secundarios = ordenados.skip(1).toList();

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 3,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            Expanded(child: legenda),
            const SizedBox(width: 16),
            BlocBuilder<ContatoCubit, ContatoState>(
              builder: (context, state) {
                final enviando = state is ContatoEnviando;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (secundarios.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'Mais formas de contato',
                        onPressed: enviando
                            ? null
                            : () => _abrirOutrasFormas(context, secundarios),
                      ),
                      const SizedBox(width: 8),
                    ],
                    FilledButton.icon(
                      onPressed: enviando
                          ? null
                          : () => context.read<ContatoCubit>().contatar(
                              imovelId,
                              principal,
                            ),
                      icon: Icon(principal.icone),
                      label: Text(principal.rotulo),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// O Cubit é lido aqui, do contexto da barra (dentro do `BlocProvider` da
  /// tela), antes de abrir o sheet: a rota do modal fica fora do provider
  /// (mesmo cuidado de `mostrarOrdenacaoBottomSheet`).
  void _abrirOutrasFormas(
    BuildContext context,
    List<CanalContato> secundarios,
  ) {
    final cubit = context.read<ContatoCubit>();
    mostrarContatoBottomSheet(
      context,
      canais: secundarios,
      aoEscolher: (canal) => cubit.contatar(imovelId, canal),
    );
  }
}
