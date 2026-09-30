import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../di/injection.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/usecases/salvar_cidade_usecase.dart';
import '../vitrine/vitrine_cubit.dart';
import '../vitrine/vitrine_screen.dart';
import 'cidade_selecao_cubit.dart';
import 'cidade_selecao_state.dart';

/// Tela de seleção de cidade — projeção exaustiva do [CidadeSelecaoCubit]
/// (D-07): cada uma das 8 variantes seladas de [CidadeSelecaoState] tem sua
/// própria UI, nunca um ramo abrangente/coringa (LOC-06). O `switch` do
/// Dart 3 sobre uma classe selada é checado em tempo de compilação — se um
/// novo desfecho for adicionado ao estado sem um `case` aqui, o build falha.
class CidadeSelecaoScreen extends StatelessWidget {
  const CidadeSelecaoScreen({
    super.key,
    SalvarCidadeUseCase? salvarCidade,
    VitrineCubit Function()? criarVitrineCubit,
    // ignore: prefer_initializing_formals
  }) : _salvarCidade = salvarCidade,
       // ignore: prefer_initializing_formals
       _criarVitrineCubit = criarVitrineCubit;

  final SalvarCidadeUseCase? _salvarCidade;
  final VitrineCubit Function()? _criarVitrineCubit;

  @override
  Widget build(BuildContext context) {
    final salvarCidade = _salvarCidade ?? getIt<SalvarCidadeUseCase>();
    final criarVitrineCubit =
        _criarVitrineCubit ?? () => getIt<VitrineCubit>();
    return BlocBuilder<CidadeSelecaoCubit, CidadeSelecaoState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: switch (state) {
              Localizando() => const _CorpoCarregando(),
              AutorizadaEAtendida(:final cidade) => _CorpoVitrine(
                cidade: cidade,
                criarVitrineCubit: criarVitrineCubit,
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
                  onRecarregar: () =>
                      context.read<CidadeSelecaoCubit>().carregarLista(),
                ),
              Recusada(:final cidadesAtendidas) => _CorpoLista(
                titulo: 'Escolha sua cidade',
                cidades: cidadesAtendidas,
                onTocarCidade: (cidade) =>
                    _selecionarCidade(context, salvarCidade, cidade),
                onRecarregar: () =>
                    context.read<CidadeSelecaoCubit>().carregarLista(),
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
                onRecarregar: () =>
                    context.read<CidadeSelecaoCubit>().carregarLista(),
              ),
              ServicoDesligado(:final cidadesAtendidas) => _CorpoLista(
                titulo:
                    'Ative a localização do aparelho para entrarmos direto '
                    'na sua cidade, ou escolha abaixo.',
                cidades: cidadesAtendidas,
                onTocarCidade: (cidade) =>
                    _selecionarCidade(context, salvarCidade, cidade),
                onRecarregar: () =>
                    context.read<CidadeSelecaoCubit>().carregarLista(),
              ),
              FalhaGeocodificacao(:final cidadesAtendidas) => _CorpoLista(
                aviso:
                    'Não conseguimos identificar sua localização '
                    'automaticamente. Escolha sua cidade abaixo.',
                cidades: cidadesAtendidas,
                onTocarCidade: (cidade) =>
                    _selecionarCidade(context, salvarCidade, cidade),
                onRecarregar: () =>
                    context.read<CidadeSelecaoCubit>().carregarLista(),
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

/// Desfecho `autorizadaEAtendida` (D-10): monta a vitrine da cidade
/// escolhida, com o próprio `SeletorCidadeTopo` (LOC-05, D-08) já embutido
/// dentro de [VitrineScreen] — substitui o antigo placeholder
/// `_CorpoCidadeEntrada`.
class _CorpoVitrine extends StatelessWidget {
  const _CorpoVitrine({required this.cidade, required this.criarVitrineCubit});

  final Cidade cidade;
  final VitrineCubit Function() criarVitrineCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VitrineCubit>(
      key: ValueKey(cidade.chaveNatural),
      create: (_) => criarVitrineCubit()..carregar(cidade),
      child: VitrineScreen(cidade: cidade),
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
    this.onRecarregar,
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

  /// Refaz a chamada a `GET /api/publico/cidades/` — usado pelo "Tentar de
  /// novo" do estado de lista vazia (D-16: servidor devolveu zero cidades
  /// atendidas, nunca uma lista vazia muda).
  final VoidCallback? onRecarregar;

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
          child: cidades.isEmpty
              ? _CorpoListaVazia(onRecarregar: onRecarregar)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cidades.length,
                  itemBuilder: (context, index) {
                    final cidade = cidades[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        // Long-city-name backstop: Text sem maxLines quebra
                        // em múltiplas linhas em vez de estourar o layout
                        // do Card.
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

/// Servidor devolveu zero cidades atendidas (D-16) — distinto de uma lista
/// vazia muda: mensagem própria + CTA para tentar de novo.
class _CorpoListaVazia extends StatelessWidget {
  const _CorpoListaVazia({required this.onRecarregar});

  final VoidCallback? onRecarregar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nenhuma cidade atendida no momento.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRecarregar,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
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
