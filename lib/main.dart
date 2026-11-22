import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_theme.dart';
import 'di/injection.dart';
import 'domain/entities/cidade.dart';
import 'domain/usecases/obter_cidade_salva_usecase.dart';
import 'presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'presentation/priming/priming_screen.dart';
import 'presentation/sessao/botao_sessao_topo.dart';
import 'presentation/sessao/sessao_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ImoveisAquiApp());
}

/// Destino inicial do app, decidido a partir da cidade salva no aparelho
/// (D-08: nunca re-pedir GPS se já existe cidade guardada).
enum DestinoInicial { entraDireto, mostraLista }

DestinoInicial decidirDestinoInicial(Cidade? cidadeSalva) {
  return cidadeSalva != null
      ? DestinoInicial.entraDireto
      : DestinoInicial.mostraLista;
}

/// Raiz do app. Provê o [SessaoCubit] singleton ACIMA do `MaterialApp` para
/// todas as rotas empurradas (login, acervo, Sair) enxergarem a mesma sessão.
///
/// `StatefulWidget` só para chamar `carregar()` uma única vez no `initState`
/// (nunca no `build`) e sem `await`: a leitura do aparelho nunca atrasa a
/// vitrine (AC-6) — o botão do topo fica sem rótulo até ela terminar.
class ImoveisAquiApp extends StatefulWidget {
  const ImoveisAquiApp({super.key});

  @override
  State<ImoveisAquiApp> createState() => _ImoveisAquiAppState();
}

class _ImoveisAquiAppState extends State<ImoveisAquiApp> {
  late final SessaoCubit _sessao;

  @override
  void initState() {
    super.initState();
    _sessao = getIt<SessaoCubit>();
    unawaited(_sessao.carregar());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessaoCubit>.value(
      value: _sessao,
      child: MaterialApp(
        title: 'Imóveis Aqui',
        theme: AppTheme.tema,
        home: const _TelaInicial(),
      ),
    );
  }
}

/// Decide, no lançamento, o destino inicial (D-08):
/// - Sem cidade salva → [PrimingScreen] (LOC-01, o prompt de localização só
///   dispara a partir do toque no CTA — nunca aqui).
/// - Com cidade salva → entra direto na [CidadeSelecaoScreen] via
///   [CidadeSelecaoCubit.iniciarNaAberturaComCidadeSalva], que revalida a
///   cidade salva contra a lista atendida ATUAL antes de confiar nela (D-08
///   + RESEARCH Pitfall 5/A2) — sem re-pedir GPS em nenhum dos dois
///   desfechos (servida ou não mais servida).
class _TelaInicial extends StatefulWidget {
  const _TelaInicial();

  @override
  State<_TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<_TelaInicial> {
  final ObterCidadeSalvaUseCase _obterCidadeSalva =
      getIt<ObterCidadeSalvaUseCase>();

  Cidade? _cidadeSalva;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final salva = await _obterCidadeSalva();
    if (!mounted) return;
    setState(() {
      _cidadeSalva = salva;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cidadeSalva = _cidadeSalva;
    switch (decidirDestinoInicial(cidadeSalva)) {
      case DestinoInicial.mostraLista:
        return BlocProvider<CidadeSelecaoCubit>(
          create: (_) => getIt<CidadeSelecaoCubit>(),
          child: const PrimingScreen(acaoSessao: BotaoSessaoTopo()),
        );
      case DestinoInicial.entraDireto:
        return BlocProvider<CidadeSelecaoCubit>(
          create: (_) =>
              getIt<CidadeSelecaoCubit>()
                ..iniciarNaAberturaComCidadeSalva(cidadeSalva!),
          child: const CidadeSelecaoScreen(acaoSessao: BotaoSessaoTopo()),
        );
    }
  }
}
