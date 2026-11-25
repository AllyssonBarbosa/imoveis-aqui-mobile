import 'package:flutter/material.dart';

import '../apresentacao_area_gestor.dart';
import '../area_gestor_state.dart';

/// Moldura comum das 4 seções da Área do gestor: um `Card` com o título, um
/// [cabecalho] opcional e o que o [estado] da seção manda mostrar — o
/// indicador de carregamento, a falha com "Tentar de novo" ou o conteúdo (D-07).
///
/// Só apresenta: cada seção carrega e falha sozinha, e o "Tentar de novo"
/// repete só o pedido dela (quem decide é o Cubit). O texto da falha é sempre
/// o fixo de [textoDaFalha], nunca o do servidor (D-23).
class MolduraSecao<T> extends StatelessWidget {
  const MolduraSecao({
    super.key,
    required this.titulo,
    required this.estado,
    required this.aoTentarDeNovo,
    required this.construirConteudo,
    this.cabecalho,
  });

  final String titulo;
  final EstadoSecao<T> estado;

  /// "Tentar de novo" da falha só desta seção.
  final VoidCallback aoTentarDeNovo;

  /// Monta o conteúdo quando a seção está carregada.
  final Widget Function(T dados) construirConteudo;

  /// Faixa logo abaixo do título, visível em qualquer estado (ex.: o chip do
  /// período nos contatos).
  final Widget? cabecalho;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(titulo, style: textTheme.titleMedium),
            if (cabecalho case final cabecalho?) ...[
              const SizedBox(height: 8),
              cabecalho,
            ],
            const SizedBox(height: 12),
            switch (estado) {
              SecaoCarregando<T>() => const Center(
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              SecaoComFalha<T>(:final falha) => Row(
                children: [
                  Expanded(
                    child: Text(
                      textoDaFalha(falha),
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: aoTentarDeNovo,
                    child: const Text(rotuloTentarDeNovoSecao),
                  ),
                ],
              ),
              SecaoCarregada<T>(:final dados) => construirConteudo(dados),
            },
          ],
        ),
      ),
    );
  }
}
