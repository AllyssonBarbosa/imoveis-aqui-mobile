import 'package:flutter/material.dart';

import '../../comum/imagem_rede.dart';

/// Abre o visualizador de fotos em tela cheia (DET-02, D-08) por
/// `Navigator.push`, já na foto [indiceInicial]. Sem pacote de galeria: o zoom
/// é o `InteractiveViewer` do SDK.
Future<void> abrirVisualizadorFotos(
  BuildContext context, {
  required List<String> urls,
  required int indiceInicial,
  Widget Function(String url)? construirImagemDeRede,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => VisualizadorFotos(
        urls: urls,
        indiceInicial: indiceInicial,
        construirImagemDeRede: construirImagemDeRede,
      ),
    ),
  );
}

/// Fotos em tela cheia sobre fundo preto: swipe entre fotos, pinch-zoom de 1x
/// a 4x e botão fechar. O índice da página e o zoom são estado efêmero deste
/// widget, nunca do Cubit.
///
/// Zoom × swipe (RESEARCH Pitfall 3, A1): enquanto a foto visível está
/// ampliada, o `PageView` fica com `NeverScrollableScrollPhysics`, e o arrasto
/// move a imagem em vez de trocar de foto.
class VisualizadorFotos extends StatefulWidget {
  const VisualizadorFotos({
    super.key,
    required this.urls,
    required this.indiceInicial,
    this.construirImagemDeRede,
  });

  final List<String> urls;
  final int indiceInicial;

  /// Ponto de extensão só para teste (ver `ImagemRede`).
  final Widget Function(String url)? construirImagemDeRede;

  @override
  State<VisualizadorFotos> createState() => _VisualizadorFotosState();
}

class _VisualizadorFotosState extends State<VisualizadorFotos> {
  late final PageController _controlador = PageController(
    initialPage: widget.indiceInicial,
  );
  late int _indice = widget.indiceInicial;
  bool _ampliada = false;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _aoMudarDePagina(int indice) {
    // A página nova começa sem zoom (cada página tem o seu próprio State).
    setState(() {
      _indice = indice;
      _ampliada = false;
    });
  }

  void _aoMudarZoom(int indicePagina, bool ampliada) {
    // Só a foto visível decide se o swipe fica travado.
    if (indicePagina != _indice || ampliada == _ampliada) return;
    setState(() => _ampliada = ampliada);
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.urls;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Fechar',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('${_indice + 1}/${urls.length}'),
      ),
      body: PageView.builder(
        controller: _controlador,
        physics: _ampliada
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        itemCount: urls.length,
        onPageChanged: _aoMudarDePagina,
        itemBuilder: (context, indice) => _FotoAmpliavel(
          key: ValueKey('foto-ampliavel-$indice'),
          url: urls[indice],
          construirImagemDeRede: widget.construirImagemDeRede,
          aoMudarZoom: (ampliada) => _aoMudarZoom(indice, ampliada),
        ),
      ),
    );
  }
}

/// Uma página do visualizador: dona do próprio `TransformationController`,
/// avisa para cima quando a foto passa a estar (ou deixa de estar) ampliada.
class _FotoAmpliavel extends StatefulWidget {
  const _FotoAmpliavel({
    super.key,
    required this.url,
    required this.aoMudarZoom,
    this.construirImagemDeRede,
  });

  final String url;
  final ValueChanged<bool> aoMudarZoom;
  final Widget Function(String url)? construirImagemDeRede;

  @override
  State<_FotoAmpliavel> createState() => _FotoAmpliavelState();
}

class _FotoAmpliavelState extends State<_FotoAmpliavel> {
  final TransformationController _transformacao = TransformationController();
  bool _ampliada = false;

  @override
  void initState() {
    super.initState();
    _transformacao.addListener(_aoTransformar);
  }

  @override
  void dispose() {
    _transformacao
      ..removeListener(_aoTransformar)
      ..dispose();
    super.dispose();
  }

  void _aoTransformar() {
    final ampliada = _transformacao.value.getMaxScaleOnAxis() > 1.01;
    if (ampliada == _ampliada) return;
    _ampliada = ampliada;
    widget.aoMudarZoom(ampliada);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformacao,
      minScale: 1.0,
      maxScale: 4.0,
      child: Center(
        child: ImagemRede(
          url: widget.url,
          fit: BoxFit.contain,
          imagemPadrao: const Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.white70,
          ),
          construirImagemDeRede: widget.construirImagemDeRede,
        ),
      ),
    );
  }
}
