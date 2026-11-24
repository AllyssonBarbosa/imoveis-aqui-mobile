import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/imovel_com_contato.dart';
import '../apresentacao_contatos.dart';
import '../caixa_contatos_cubit.dart';
import '../caixa_contatos_state.dart';

/// Folha "Filtrar por imóvel" (D-19): pede as opções ao servidor a CADA
/// abertura (R3), então um imóvel que acabou de receber contato já aparece, e
/// lista "Todos os imóveis" mais "código — título" de cada opção, com o
/// escolhido marcado. Escolher fecha a folha e filtra; "Todos os imóveis" tira
/// o filtro. O app não monta a lista: só mostra o que o servidor devolveu.
///
/// O [cubit] vai por valor porque a rota do modal fica fora do `BlocProvider`
/// da tela. Se um 401 mandar a tela ao login, o `pushAndRemoveUntil` dela
/// remove a folha junto.
Future<void> mostrarFolhaFiltroImovel(
  BuildContext context, {
  required CaixaContatosCubit cubit,
}) {
  cubit.carregarOpcoesDeImovel();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (contextoDaFolha) {
      return BlocProvider<CaixaContatosCubit>.value(
        value: cubit,
        child: _ConteudoDaFolhaDeImovel(contextoDaFolha: contextoDaFolha),
      );
    },
  );
}

class _ConteudoDaFolhaDeImovel extends StatelessWidget {
  const _ConteudoDaFolhaDeImovel({required this.contextoDaFolha});

  final BuildContext contextoDaFolha;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  tituloFolhaFiltroImovel,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            BlocBuilder<CaixaContatosCubit, CaixaContatosState>(
              buildWhen: (anterior, atual) =>
                  anterior.opcoesDeImovel != atual.opcoesDeImovel ||
                  anterior.consulta.imovel != atual.consulta.imovel,
              builder: (context, state) => switch (state.opcoesDeImovel) {
                OpcoesNaoCarregadas() || OpcoesCarregando() => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                OpcoesComErro() => _ErroDasOpcoes(
                  aoTentarDeNovo: () => context
                      .read<CaixaContatosCubit>()
                      .carregarOpcoesDeImovel(),
                ),
                OpcoesCarregadas(:final imoveis) => _OpcoesDeImovel(
                  imoveis: imoveis,
                  escolhido: state.consulta.imovel,
                  contextoDaFolha: contextoDaFolha,
                ),
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OpcoesDeImovel extends StatelessWidget {
  const _OpcoesDeImovel({
    required this.imoveis,
    required this.escolhido,
    required this.contextoDaFolha,
  });

  final List<ImovelComContato> imoveis;
  final ImovelComContato? escolhido;
  final BuildContext contextoDaFolha;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CaixaContatosCubit>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text(textoTodosOsImoveis),
          selected: escolhido == null,
          trailing: escolhido == null ? const Icon(Icons.check) : null,
          onTap: () {
            Navigator.of(contextoDaFolha).pop();
            cubit.limparImovel();
          },
        ),
        for (final imovel in imoveis)
          ListTile(
            title: Text(rotuloOpcaoDeImovel(imovel)),
            selected: imovel == escolhido,
            trailing: imovel == escolhido ? const Icon(Icons.check) : null,
            onTap: () {
              Navigator.of(contextoDaFolha).pop();
              cubit.aplicarImovel(imovel);
            },
          ),
      ],
    );
  }
}

class _ErroDasOpcoes extends StatelessWidget {
  const _ErroDasOpcoes({required this.aoTentarDeNovo});

  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            textoErroOpcoesDeImovel,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: aoTentarDeNovo,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }
}
