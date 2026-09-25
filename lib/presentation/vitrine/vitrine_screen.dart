import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cidade.dart';
import '../cidade_selecao/widgets/seletor_cidade_topo.dart';
import 'vitrine_cubit.dart';
import 'vitrine_state.dart';
import 'widgets/imovel_card.dart';

/// Tela da vitrine (VIT-01) — sem `Scaffold` próprio: vive dentro do
/// `Scaffold`/`SafeArea` de `CidadeSelecaoScreen` no desfecho
/// `autorizadaEAtendida`. `switch` exaustivo sobre [ConteudoVitrine], sem
/// ramo abrangente, igual à convenção de `CidadeSelecaoScreen`.
class VitrineScreen extends StatelessWidget {
  const VitrineScreen({super.key, required this.cidade});

  final Cidade cidade;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SeletorCidadeTopo(cidade: cidade),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<VitrineCubit, VitrineState>(
              builder: (context, state) {
                return switch (state.conteudo) {
                  VitrineCarregando() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  VitrineVaziaNaCidade() => Center(
                    child: Text(
                      'Ainda não há imóveis anunciados em ${cidade.nome}.',
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VitrineSemResultado(:final termo) => Center(
                    child: Text(
                      'Nenhum imóvel encontrado para "$termo"',
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  VitrineErro() => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Não foi possível carregar os imóveis',
                            style: textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context
                                .read<VitrineCubit>()
                                .tentarNovamente(),
                            child: const Text('Tentar de novo'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  VitrineCarregada(:final itens) => ListView.builder(
                    itemCount: itens.length,
                    itemBuilder: (context, index) {
                      final imovel = itens[index];
                      return ImovelCard(
                        key: ValueKey('imovel-${imovel.id}'),
                        imovel: imovel,
                      );
                    },
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
