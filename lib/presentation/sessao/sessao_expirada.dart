import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../login/apresentacao_login.dart';
import '../login/login_screen.dart';
import 'rota_vitrine.dart';
import 'sessao_cubit.dart';

/// A sessão terminou (o servidor recusou o token, 401): descarta o token
/// local, deixa a sessão anônima e abre o login com o aviso "Sua sessão
/// terminou. Entre de novo.", mantendo só a rota da vitrine embaixo na pilha
/// (D-10 da Fase 9, padrão da Fase 8; T-08-54).
///
/// Único caminho de volta ao login por sessão expirada do app — a tela do
/// acervo e a tela de gestão do imóvel o usam. O `Navigator` e o `SessaoCubit`
/// são capturados ANTES do `await`; depois dele só se navega se a rota ainda
/// estiver montada.
Future<void> voltarAoLoginComSessaoTerminada(BuildContext context) async {
  final navegador = Navigator.of(context);
  final sessao = context.read<SessaoCubit>();
  await sessao.encerrarPorExpiracao();
  if (!navegador.mounted) return;
  navegador.pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(aviso: avisoSessaoTerminou),
    ),
    eRotaDaVitrine,
  );
}
