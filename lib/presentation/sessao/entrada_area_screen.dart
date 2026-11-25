import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/papel.dart';
import '../acervo/acervo_screen.dart';
import '../area_gestor/area_gestor_screen.dart';
import '../login/apresentacao_login.dart';
import '../login/login_screen.dart';
import 'aviso_area_screen.dart';
import 'entrada_area_cubit.dart';
import 'entrada_area_state.dart';
import 'sessao_cubit.dart';

/// Rota de "Meu acervo" (D-02, D-B): o papel sempre vem do servidor ao tocar
/// no botão do topo, nunca do aparelho. Enquanto pergunta, mostra um
/// indicador; ao responder, a própria rota é substituída (`pushReplacement`)
/// pela área do papel, então o "voltar" leva à vitrine: o corretor vai ao
/// acervo, o gestor à Área do gestor (APP-12, D-01) e o administrador ao
/// aviso (D-02). Se o servidor recusar o token (401), a sessão fica anônima e
/// o login abre com o aviso.
class EntradaAreaScreen extends StatelessWidget {
  const EntradaAreaScreen({super.key, this.criarCubit});

  /// Cria o Cubit da tela; `null` usa o localizador de serviços. Existe para
  /// os testes de widget não dependerem do DI.
  final EntradaAreaCubit Function()? criarCubit;

  @override
  Widget build(BuildContext context) {
    final criar = criarCubit ?? () => getIt<EntradaAreaCubit>();
    return BlocProvider<EntradaAreaCubit>(
      create: (_) => criar()..carregar(),
      child: const _CorpoEntradaArea(),
    );
  }
}

class _CorpoEntradaArea extends StatelessWidget {
  const _CorpoEntradaArea();

  void _aoMudar(BuildContext context, EntradaAreaState estado) {
    final navegador = Navigator.of(context);
    final sessao = context.read<SessaoCubit>();
    switch (estado) {
      case EntradaAreaPapel(:final papel):
        navegador.pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => switch (papel) {
              Papel.corretor => const AcervoScreen(),
              Papel.gestor => const AreaGestorScreen(),
              Papel.administrador => const AvisoAreaScreen(),
            },
          ),
        );
      case EntradaAreaSessaoExpirada():
        unawaited(_encerrarPorExpiracao(navegador, sessao));
      case EntradaAreaCarregando() || EntradaAreaErro():
        break;
    }
  }

  /// Descarta o token local, deixa a sessão anônima e só então troca a rota
  /// pelo login com o aviso.
  Future<void> _encerrarPorExpiracao(
    NavigatorState navegador,
    SessaoCubit sessao,
  ) async {
    await sessao.encerrarPorExpiracao();
    if (!navegador.mounted) return;
    unawaited(
      navegador.pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(aviso: avisoSessaoTerminou),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Meu acervo')),
      body: BlocConsumer<EntradaAreaCubit, EntradaAreaState>(
        listenWhen: (anterior, atual) =>
            atual is EntradaAreaPapel || atual is EntradaAreaSessaoExpirada,
        listener: _aoMudar,
        builder: (context, estado) {
          if (estado is! EntradaAreaErro) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Não foi possível abrir sua área agora.',
                    style: tema.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<EntradaAreaCubit>().tentarNovamente(),
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
