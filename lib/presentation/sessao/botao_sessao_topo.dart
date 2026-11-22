import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../login/login_screen.dart';
import 'entrada_area_screen.dart';
import 'sessao_cubit.dart';
import 'sessao_state.dart';

/// Botão do topo da vitrine (D-C): "Entrar" para quem não tem sessão guardada
/// e "Meu acervo" para quem tem. Só decide o rótulo pela sessão guardada no
/// aparelho; o papel é perguntado ao servidor na [EntradaAreaScreen].
///
/// Enquanto o aparelho ainda é lido ele só ocupa o espaço, sem rótulo, para
/// não piscar "Entrar" a quem já tem sessão — e a abertura do app nunca
/// espera por isso (AC-6).
class BotaoSessaoTopo extends StatelessWidget {
  const BotaoSessaoTopo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessaoCubit, SessaoState>(
      builder: (context, estado) {
        return switch (estado) {
          SessaoVerificando() => const SizedBox(height: 48),
          SessaoAnonima() => TextButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Entrar'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
            ),
          ),
          SessaoAutenticada() => TextButton.icon(
            icon: const Icon(Icons.home_work_outlined),
            label: const Text('Meu acervo'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EntradaAreaScreen(),
              ),
            ),
          ),
        };
      },
    );
  }
}
