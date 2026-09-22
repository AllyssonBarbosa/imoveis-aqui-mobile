import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/usecases/salvar_cidade_usecase.dart';
import 'cidade_selecao_cubit.dart';
import 'cidade_selecao_state.dart';
import 'widgets/seletor_cidade_topo.dart';

/// Tela de seleção de cidade — projeção exaustiva do [CidadeSelecaoCubit]
/// (D-07): cada uma das 8 variantes seladas de [CidadeSelecaoState] tem sua
/// própria UI, nunca um `default`/catch-all (LOC-06). O `switch` do Dart 3
/// sobre uma classe selada é checado em tempo de compilação — se um novo
/// desfecho for adicionado ao estado sem um `case` aqui, o build falha.
class CidadeSelecaoScreen extends StatelessWidget {
  const CidadeSelecaoScreen({
    super.key,
    SalvarCidadeUseCase? salvarCidade,
    // ignore: prefer_initializing_formals
  }) : _salvarCidade = salvarCidade;

  final SalvarCidadeUseCase? _salvarCidade;

  @override
  Widget build(BuildContext context) {
    final salvarCidade = _salvarCidade ?? getIt<SalvarCidadeUseCase>();
    return BlocBuilder<CidadeSelecaoCubit, CidadeSelecaoState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: switch (state) {
              Localizando() => const _CorpoCarregando(),
              AutorizadaEAtendida(:final cidade) => _CorpoCidadeEntrada(
                cidade: cidade,
              ),
              AutorizadaNaoAtendida(
                :final cidadeDetectada,
                :final cidadesAtendidas,
              ) =>
                _CorpoLista(
                  aviso:
                      'Ainda não atendemos $cidadeDetectada — escolha uma '
                      'das disponíveis',
                  cidades: cidadesAtendidas,
                  onTocarCidade: (cidade) =>
                      _selecionarCidade(context, salvarCidade, cidade),
                ),
              Recusada(:final cidadesAtendidas) => _CorpoLista(
                titulo: 'Escolha sua cidade',
                cidades: cidadesAtendidas,
                onTocarCidade: (cidade) =>
                    _selecionarCidade(context, salvarCidade, cidade),
              ),
              BloqueadaParaSempre(:final cidadesAtendidas) => _CorpoLista(
                titulo:
                    'Permissão de localização bloqueada. Ative nas Ajustes '
                    'do aparelho, ou escolha sua cidade abaixo.',
                cidades: cidadesAtendidas,
                onTocarCidade: (cidade) =>
                    _selecionarCidade(context, salvarCidade, cidade),
                onAtivarNasAjustes: () => context
                    .read<CidadeSelecaoCubit>()
                    .abrirConfiguracoesDoSistema(),
              ),
              ServicoDesligado(:final cidadesAtendidas) => _CorpoLista(
                titulo:
                    'Ative a localização do aparelho para entrarmos direto '
                    'na sua cidade, ou escolha abaixo.',
                cidades: cidadesAtendidas,
                onTocarCidade: (cidade) =>
                    _selecionarCidade(context, salvarCidade, cidade),
              ),
              FalhaGeocodificacao(:final cidadesAtendidas) => _CorpoLista(
                aviso:
                    'Não conseguimos identificar sua localização '
                    'automaticamente. Escolha sua cidade abaixo.',
                cidades: cidadesAtendidas,
                onTocarCidade: (cidade) =>
                    _selecionarCidade(context, salvarCidade, cidade),
              ),
              ErroCarregarCidades() => _CorpoErro(
                onTentarNovamente: () =>
                    context.read<CidadeSelecaoCubit>().carregarLista(),
              ),
            },
          ),
        );
      },
    );
  }

  Future<void> _selecionarCidade(
    BuildContext context,
    SalvarCidadeUseCase salvarCidade,
    Cidade cidade,
  ) async {
    // Toque na lista entra direto na cidade escolhida, sem passo de
    // confirmação (D-10 aplicado por analogia à seleção manual).
    await salvarCidade(cidade);
    if (!context.mounted) return;
    context.read<CidadeSelecaoCubit>().entrarDireto(cidade);
  }
}

class _CorpoCarregando extends StatelessWidget {
  const _CorpoCarregando();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Localizando você…',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _CorpoCidadeEntrada extends StatelessWidget {
  const _CorpoCidadeEntrada({required this.cidade});

  final Cidade cidade;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          // Cabeçalho tocável — trocar de cidade num toque, sem GPS (LOC-05,
          // D-08).
          SeletorCidadeTopo(cidade: cidade),
        ],
      ),
    );
  }
}

class _CorpoLista extends StatelessWidget {
  const _CorpoLista({
    this.titulo,
    this.aviso,
    required this.cidades,
    required this.onTocarCidade,
    this.onAtivarNasAjustes,
  }) : assert(
         titulo != null || aviso != null,
         'titulo ou aviso deve ser informado',
       );

  /// Heading sem tom de desculpa (ex.: `recusada`, `servicoDesligado`,
  /// `bloqueadaParaSempre`) — caminho normal (LOC-03).
  final String? titulo;

  /// Aviso leve (ex.: `autorizadaNaoAtendida`, `falhaGeocodificacao`) — tom
  /// mais suave, transparente, sem beco (D-11/D-12).
  final String? aviso;

  final List<Cidade> cidades;
  final ValueChanged<Cidade> onTocarCidade;

  /// Presente apenas no desfecho `bloqueadaParaSempre` (D-06).
  final VoidCallback? onAtivarNasAjustes;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo ?? aviso!,
                style: titulo != null
                    ? textTheme.titleLarge
                    : textTheme.labelLarge,
              ),
              if (onAtivarNasAjustes != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onAtivarNasAjustes,
                    child: const Text('Ativar localização nas Ajustes'),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cidades.length,
            itemBuilder: (context, index) {
              final cidade = cidades[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  // Long-city-name backstop: Text sem maxLines quebra em
                  // múltiplas linhas em vez de estourar o layout do Card.
                  title: Text('${cidade.nome}, ${cidade.uf}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onTocarCidade(cidade),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CorpoErro extends StatelessWidget {
  const _CorpoErro({required this.onTentarNovamente});

  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Não foi possível carregar as cidades',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onTentarNovamente,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}
