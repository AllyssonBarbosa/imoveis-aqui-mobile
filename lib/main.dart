import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'di/injection.dart';
import 'domain/entities/cidade.dart';
import 'domain/usecases/obter_cidade_salva_usecase.dart';
import 'presentation/cidade_selecao/cidade_selecao_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ImoveisAquiApp());
}

/// Destino inicial do app, decidido a partir da cidade salva no aparelho
/// (D-08: nunca re-pedir GPS se já existe cidade guardada).
///
/// Função pura e testável sem inicializar a árvore de widgets
/// (`test/skeleton_flow_test.dart`) — o seam que os Planos 01-03/01-04
/// expandem com priming/detecção/roteamento por localização.
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

/// Decide, no lançamento, se entra direto na cidade guardada (D-08) ou mostra
/// a lista de cidades. Nesta fatia mínima (walking skeleton) os dois casos
/// renderizam a mesma [CidadeSelecaoScreen], com a cidade salva já marcada
/// quando existir — a UI totalmente diferenciada por [DestinoInicial] chega
/// nos Planos 01-03/01-04.
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
    // decidirDestinoInicial(_cidadeSalva) define a intenção — ver docstring.
    return CidadeSelecaoScreen(cidadeInicial: _cidadeSalva);
  }
}
