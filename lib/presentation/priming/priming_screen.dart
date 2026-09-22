import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cidade_selecao/cidade_selecao_cubit.dart';
import '../cidade_selecao/cidade_selecao_screen.dart';

/// Tela de priming (D-05) — explica o porquê antes de disparar o prompt
/// nativo do OS. O `FilledButton` "Usar minha localização" é o ÚNICO lugar
/// que aciona [CidadeSelecaoCubit.detectarCidade] — nunca em `initState`
/// (RESEARCH Anti-Patterns).
class PrimingScreen extends StatelessWidget {
  const PrimingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              Icon(
                Icons.location_searching,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Vamos te levar direto pra sua cidade',
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Usamos sua localização só para abrir o app já na cidade '
                'certa. Você pode trocar quando quiser.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () => _aoTocarUsarLocalizacao(context),
                child: const Text('Usar minha localização'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _aoTocarUsarLocalizacao(BuildContext context) {
    final cubit = context.read<CidadeSelecaoCubit>();
    // Único ponto de disparo do fluxo de permissão (D-05) — o prompt nativo
    // do OS só aparece a partir daqui, nunca antes.
    unawaited(cubit.detectarCidade());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<CidadeSelecaoCubit>.value(
          value: cubit,
          child: const CidadeSelecaoScreen(),
        ),
      ),
    );
  }
}
