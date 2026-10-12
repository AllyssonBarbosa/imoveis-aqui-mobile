import 'package:flutter/material.dart';

import '../../comum/imagem_rede.dart';

/// Galeria do topo da página do imóvel (DET-02, D-07): todas as fotos na
/// ordem recebida — o servidor manda a capa primeiro e o app nunca reordena —
/// num `PageView`, com o contador "N/M" no canto. Sem fotos, mostra só a
/// imagem padrão, sem contador e sem toque (D-10).
///
/// O índice da página é estado efêmero de UI e vive neste `State`, nunca no
/// Cubit.
class GaleriaImovel extends StatefulWidget {
  const GaleriaImovel({
    super.key,
    required this.urls,
    this.aoTocarFoto,
    this.construirImagemDeRede,
  });

  final List<String> urls;

  /// Chamado com o índice da foto tocada; `null` desliga o toque.
  final ValueChanged<int>? aoTocarFoto;

  /// Ponto de extensão só para teste (ver `ImagemRede`) — repassado à foto.
  final Widget Function(String url)? construirImagemDeRede;

  @override
  State<GaleriaImovel> createState() => _GaleriaImovelState();
}

class _GaleriaImovelState extends State<GaleriaImovel> {
  late final PageController _controlador = PageController();
  int _indice = 0;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    if (urls.isEmpty) return const ImagemPadraoImovel();

    final aoTocarFoto = widget.aoTocarFoto;
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controlador,
          itemCount: urls.length,
          onPageChanged: (indice) => setState(() => _indice = indice),
          itemBuilder: (context, indice) => GestureDetector(
            onTap: aoTocarFoto == null ? null : () => aoTocarFoto(indice),
            child: Semantics(
              label: 'Foto ${indice + 1} de ${urls.length}',
              image: true,
              child: ImagemRede(
                url: urls[indice],
                fit: BoxFit.cover,
                construirImagemDeRede: widget.construirImagemDeRede,
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: _ContadorFotos(texto: '${_indice + 1}/${urls.length}'),
        ),
      ],
    );
  }
}

/// Contador "N/M" sobre a foto, em pílula escura translúcida para ler sobre
/// qualquer imagem.
class _ContadorFotos extends StatelessWidget {
  const _ContadorFotos({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      key: const ValueKey('contador-fotos'),
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          texto,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: colorScheme.onInverseSurface),
        ),
      ),
    );
  }
}
