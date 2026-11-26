import 'dart:io';

import 'package:flutter/material.dart';

import '../../gestao_imovel/apresentacao_gestao.dart';
import '../apresentacao_fotos.dart';
import '../fotos_imovel_state.dart';

/// A fila de envio (D-18): cada foto escolhida com a miniatura local, o estado
/// e a barra de progresso; a que falhou mostra o erro (a mensagem do servidor,
/// se houver, senão o texto fixo) com "Tentar de novo" e "Remover", sem travar
/// as outras. Só apresenta o que vem do estado.
class FilaEnvio extends StatelessWidget {
  const FilaEnvio({
    super.key,
    required this.fila,
    required this.aoTentarDeNovo,
    required this.aoRemover,
    this.construirMiniaturaLocal,
  });

  final List<EnvioDeFoto> fila;
  final void Function(int idLocal) aoTentarDeNovo;
  final void Function(int idLocal) aoRemover;
  final Widget Function(String caminho)? construirMiniaturaLocal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final envio in fila)
          Card(
            key: ValueKey('envio-${envio.id}'),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child:
                          construirMiniaturaLocal?.call(
                            envio.original.caminho,
                          ) ??
                          _MiniaturaLocal(caminho: envio.original.caminho),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EstadoDoEnvio(
                      envio: envio,
                      aoTentarDeNovo: () => aoTentarDeNovo(envio.id),
                      aoRemover: () => aoRemover(envio.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EstadoDoEnvio extends StatelessWidget {
  const _EstadoDoEnvio({
    required this.envio,
    required this.aoTentarDeNovo,
    required this.aoRemover,
  });

  final EnvioDeFoto envio;
  final VoidCallback aoTentarDeNovo;
  final VoidCallback aoRemover;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget comBarra(String texto, double? valor) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texto, style: textTheme.bodyMedium),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: valor),
      ],
    );

    return switch (envio.estado) {
      EnvioAguardando() => Text(textoAguardando, style: textTheme.bodyMedium),
      EnvioPreparando() => comBarra(textoPreparando, null),
      EnvioEnviando(:final progresso) => comBarra(textoEnviando, progresso),
      EnvioFalhou(:final mensagemDoServidor, :final noPreparo) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mensagemDoServidor ??
                (noPreparo ? textoFalhaPreparo : textoFalhaEnvio),
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: aoTentarDeNovo,
                icon: const Icon(Icons.refresh),
                label: const Text(rotuloTentarDeNovo),
              ),
              TextButton(
                onPressed: aoRemover,
                child: const Text(rotuloRemover),
              ),
            ],
          ),
        ],
      ),
    };
  }
}

/// Miniatura do arquivo no aparelho, decodificada pequena (não carrega a foto
/// de 12 MP inteira na memória). Arquivo ilegível vira um ícone.
class _MiniaturaLocal extends StatelessWidget {
  const _MiniaturaLocal({required this.caminho});

  final String caminho;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Image.file(
      File(caminho),
      fit: BoxFit.cover,
      cacheWidth: 160,
      errorBuilder: (_, _, _) => ColoredBox(
        color: colorScheme.primaryContainer,
        child: Icon(
          Icons.image_outlined,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
