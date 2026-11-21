import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sessao_cubit.dart';

/// Pede a confirmação de Sair e, confirmado, encerra a sessão e volta à
/// primeira rota (a vitrine) — AC-2. O [SessaoCubit] sempre termina anônimo,
/// mesmo que o servidor falhe, e a pilha não deixa o "voltar" reabrir uma
/// tela logada (T-08-54).
Future<void> confirmarESair(BuildContext context) async {
  // Capturados antes do `await`: o diálogo e o Sair não dependem de a tela de
  // origem continuar montada.
  final navegador = Navigator.of(context);
  final sessao = context.read<SessaoCubit>();

  final confirmou = await showDialog<bool>(
    context: context,
    builder: (contextoDialogo) => AlertDialog(
      title: const Text('Sair da conta?'),
      content: const Text(
        'Você vai precisar entrar de novo com e-mail e senha.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(contextoDialogo).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(contextoDialogo).pop(true),
          child: const Text('Sair'),
        ),
      ],
    ),
  );
  if (confirmou != true) return;

  await sessao.sair();
  if (!navegador.mounted) return;
  navegador.popUntil((rota) => rota.isFirst);
}
