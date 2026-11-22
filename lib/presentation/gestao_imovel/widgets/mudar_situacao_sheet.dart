import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/situacao_imovel.dart';
import '../../acervo/apresentacao_acervo.dart';
import '../apresentacao_gestao.dart';
import '../mudar_situacao_cubit.dart';
import '../mudar_situacao_state.dart';

/// Abre a folha inferior de mudança de situação (D-09, sem diálogo extra).
///
/// [cubit] deve vir capturado do contexto da TELA (`context.read`) antes de
/// abrir a folha: a rota do modal fica fora do `BlocProvider` da tela, então a
/// folha recebe o mesmo Cubit por `BlocProvider.value` dentro do `builder`
/// (mesmo aviso de `mostrarContatoBottomSheet`). O Cubit não é fechado aqui —
/// quem o criou é dono dele.
Future<void> mostrarMudarSituacaoSheet(
  BuildContext context, {
  required MudarSituacaoCubit cubit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider<MudarSituacaoCubit>.value(
      value: cubit,
      child: const _FolhaMudarSituacao(),
    ),
  );
}

/// Corpo da folha: título, chips de escolha única das quatro situações (a atual
/// desabilitada), a observação opcional com limite de [limiteObservacao]
/// caracteres (D-06, D-17), o "Data: hoje" informativo (D-05) e o
/// `FilledButton` "Confirmar".
///
/// É dona do `TextEditingController` da observação, que só existe em memória:
/// nada vai para disco nem para log (T-09-06). Como a folha não fecha numa
/// falha, o texto digitado sobrevive para a nova tentativa (D-10).
class _FolhaMudarSituacao extends StatefulWidget {
  const _FolhaMudarSituacao();

  @override
  State<_FolhaMudarSituacao> createState() => _FolhaMudarSituacaoState();
}

class _FolhaMudarSituacaoState extends State<_FolhaMudarSituacao> {
  final TextEditingController _controleObservacao = TextEditingController();

  @override
  void dispose() {
    _controleObservacao.dispose();
    super.dispose();
  }

  /// Pede a mudança com a observação como o corretor digitou (o `trim` e a
  /// omissão da observação vazia ficam no DataSource, 09-09).
  void _confirmar(BuildContext context) {
    final cubit = context.read<MudarSituacaoCubit>();
    cubit.confirmar(observacao: _controleObservacao.text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<MudarSituacaoCubit, MudarSituacaoState>(
      // Sucesso: a folha fecha; quem avisa e relê é a tela (D-10).
      listenWhen: (anterior, atual) =>
          anterior.envio is! EnvioConcluido && atual.envio is EnvioConcluido,
      listener: (context, state) => Navigator.of(context).pop(),
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tituloFolhaMudarSituacao, style: textTheme.titleLarge),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final situacao in SituacaoImovel.values)
                      ChoiceChip(
                        key: ValueKey('chip-mudar-${situacao.name}'),
                        label: Text(rotuloSituacao(situacao)),
                        selected: situacao == state.escolhida,
                        // A situação atual não pode ser escolhida (D-09).
                        onSelected: situacao == state.atual
                            ? null
                            : (_) => context
                                  .read<MudarSituacaoCubit>()
                                  .escolher(situacao),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controleObservacao,
                  maxLength: limiteObservacao,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: rotuloObservacao,
                    hintText: dicaObservacao,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  textoDataHoje,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (state.envio is EnvioFalhou) ...[
                  const SizedBox(height: 12),
                  Text(
                    textoFalhaAoMudar,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.podeConfirmar
                        ? () => _confirmar(context)
                        : null,
                    child: const Text(rotuloConfirmar),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
