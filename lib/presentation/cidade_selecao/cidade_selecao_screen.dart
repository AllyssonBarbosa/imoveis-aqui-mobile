import 'package:flutter/material.dart';

import '../../core/result.dart';
import '../../di/injection.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/usecases/obter_cidades_atendidas_usecase.dart';
import '../../domain/usecases/salvar_cidade_usecase.dart';

/// Tela mínima de seleção de cidade — a fatia ponta a ponta do walking
/// skeleton (Plano 01-01). Lista as cidades atendidas via
/// [ObterCidadesAtendidasUseCase] e persiste o toque via [SalvarCidadeUseCase]
/// — a tela NUNCA lê uma fonte de dados diretamente, sempre passa pelo caso
/// de uso. A versão completa com os 5 desfechos de localização (D-07) e o
/// switcher de cidade (LOC-05) chega nos Planos 01-03/01-04.
class CidadeSelecaoScreen extends StatefulWidget {
  const CidadeSelecaoScreen({
    super.key,
    this.cidadeInicial,
    ObterCidadesAtendidasUseCase? obterCidadesAtendidas,
    SalvarCidadeUseCase? salvarCidade,
    // Nomes públicos (`obterCidadesAtendidas`/`salvarCidade`) por design —
    // parâmetros de injeção para teste, mais legíveis que os nomes de campo
    // privados que um "initializing formal" (this._obterCidadesAtendidas)
    // exigiria. `prefer_initializing_formals` não se aplica aqui.
    // ignore: prefer_initializing_formals
  }) : _obterCidadesAtendidas = obterCidadesAtendidas,
       // ignore: prefer_initializing_formals
       _salvarCidade = salvarCidade;

  /// Cidade já salva no aparelho (D-08) — se presente, chega marcada como
  /// selecionada, sem repetir a escolha.
  final Cidade? cidadeInicial;

  final ObterCidadesAtendidasUseCase? _obterCidadesAtendidas;
  final SalvarCidadeUseCase? _salvarCidade;

  @override
  State<CidadeSelecaoScreen> createState() => _CidadeSelecaoScreenState();
}

class _CidadeSelecaoScreenState extends State<CidadeSelecaoScreen> {
  late final ObterCidadesAtendidasUseCase _obterCidadesAtendidas =
      widget._obterCidadesAtendidas ?? getIt<ObterCidadesAtendidasUseCase>();
  late final SalvarCidadeUseCase _salvarCidade =
      widget._salvarCidade ?? getIt<SalvarCidadeUseCase>();

  List<Cidade> _cidades = const [];
  Cidade? _cidadeSelecionada;
  bool _carregando = true;
  bool _erro = false;

  @override
  void initState() {
    super.initState();
    _cidadeSelecionada = widget.cidadeInicial;
    _carregarCidades();
  }

  Future<void> _carregarCidades() async {
    final resultado = await _obterCidadesAtendidas();
    if (!mounted) return;
    switch (resultado) {
      case Success(:final data):
        setState(() {
          _cidades = data;
          _carregando = false;
        });
      case Failure():
        setState(() {
          _erro = true;
          _carregando = false;
        });
      case Loading():
        break;
    }
  }

  Future<void> _aoTocarCidade(Cidade cidade) async {
    await _salvarCidade(cidade);
    if (!mounted) return;
    setState(() => _cidadeSelecionada = cidade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha sua cidade')),
      body: SafeArea(child: _corpo()),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro) {
      return const Center(
        child: Text('Não foi possível carregar as cidades'),
      );
    }
    return ListView.builder(
      itemCount: _cidades.length,
      itemBuilder: (context, index) {
        final cidade = _cidades[index];
        final selecionada = cidade == _cidadeSelecionada;
        return Card(
          child: ListTile(
            leading: const Icon(Icons.location_on),
            title: Text('${cidade.nome}, ${cidade.uf}'),
            trailing: Icon(selecionada ? Icons.check : Icons.chevron_right),
            onTap: () => _aoTocarCidade(cidade),
          ),
        );
      },
    );
  }
}
