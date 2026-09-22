import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/cidade.dart';
import '../cidade_selecao_cubit.dart';

/// Cabeçalho tocável "{Cidade}, {UF}" no topo da tela, no desfecho
/// `autorizadaEAtendida` (D-10) — trocar de cidade num toque (LOC-05).
///
/// Ao tocar, reabre a lista de seleção via [CidadeSelecaoCubit.carregarLista]
/// — NUNCA o fluxo de detecção/GPS (`detectarCidade`), preservando D-08 (só
/// a 1ª vez ou pedido explícito de detecção disparam GPS; trocar de cidade
/// não é um desses casos). Alvo de toque mínimo 48dp (UI-SPEC Spacing
/// exception) e rótulo acessível "Trocar cidade" (UI-SPEC Copywriting).
class SeletorCidadeTopo extends StatelessWidget {
  const SeletorCidadeTopo({super.key, required this.cidade});

  final Cidade cidade;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Trocar cidade',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.read<CidadeSelecaoCubit>().carregarLista(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '${cidade.nome}, ${cidade.uf}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, color: colorScheme.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
