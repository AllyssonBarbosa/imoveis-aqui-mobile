import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_theme.dart';
import 'di/injection.dart';
import 'domain/entities/cidade.dart';
import 'domain/usecases/obter_cidade_salva_usecase.dart';
import 'presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'presentation/priming/priming_screen.dart';

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

class ImoveisAquiApp extends StatelessWidget {
  const ImoveisAquiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imóveis Aqui',
      theme: AppTheme.tema,
      home: const _TelaInicial(),
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
          child: const PrimingScreen(),
        );
      case DestinoInicial.entraDireto:
        return BlocProvider<CidadeSelecaoCubit>(
          create: (_) => getIt<CidadeSelecaoCubit>()
            ..iniciarNaAberturaComCidadeSalva(cidadeSalva!),
          child: const CidadeSelecaoScreen(),
        );
    }
  }
}
