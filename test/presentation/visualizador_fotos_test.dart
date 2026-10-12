import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/visualizador_fotos.dart';

void main() {
  const a = 'https://exemplo.com/a.jpg';
  const b = 'https://exemplo.com/b.jpg';
  const c = 'https://exemplo.com/c.jpg';

  /// Imagem determinística: uma caixa com a chave da própria url.
  Widget caixa(String url) =>
      ColoredBox(key: ValueKey(url), color: Colors.blue);

  /// Abre o visualizador por cima de uma página-base, como a página do imóvel
  /// faz, para que o botão fechar tenha para onde voltar.
  Future<void> abrir(WidgetTester tester, {int indiceInicial = 1}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => abrirVisualizadorFotos(
                  context,
                  urls: const [a, b, c],
                  indiceInicial: indiceInicial,
                  construirImagemDeRede: caixa,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  /// O `InteractiveViewer` da página [indice] (cada página tem a sua chave).
  InteractiveViewer visualizadorDaPagina(WidgetTester tester, int indice) {
    return tester.widget<InteractiveViewer>(
      find.descendant(
        of: find.byKey(ValueKey('foto-ampliavel-$indice')),
        matching: find.byType(InteractiveViewer),
      ),
    );
  }

  /// Arrasto de dedo real: vários movimentos curtos (como no aparelho, onde o
  /// `InteractiveViewer` e o `PageView` disputam o gesto) passando de meia
  /// página para o `PageView` assentar na página seguinte.
  Future<void> deslizarParaEsquerda(WidgetTester tester) async {
    final gesto = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    for (var i = 0; i < 30; i++) {
      await gesto.moveBy(const Offset(-20, 0));
      await tester.pump(const Duration(milliseconds: 8));
    }
    await gesto.up();
    await tester.pumpAndSettle();
  }

  PageView paginas(WidgetTester tester) =>
      tester.widget<PageView>(find.byType(PageView));

  testWidgets('abre na foto pedida com o título 2/3 e o swipe vai para a '
      'próxima (D-08)', (tester) async {
    await abrir(tester);

    expect(find.byType(VisualizadorFotos), findsOneWidget);
    expect(find.byKey(const ValueKey(b)), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);

    await deslizarParaEsquerda(tester);

    expect(find.byKey(const ValueKey(c)), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
  });

  testWidgets('cada página tem um InteractiveViewer com zoom de 1x a 4x', (
    tester,
  ) async {
    await abrir(tester);

    final visualizador = visualizadorDaPagina(tester, 1);
    expect(visualizador.minScale, 1.0);
    expect(visualizador.maxScale, 4.0);
    expect(visualizador.transformationController, isNotNull);
  });

  testWidgets('ampliada, a página trava o swipe; ao voltar a 1x, destrava', (
    tester,
  ) async {
    await abrir(tester);
    expect(paginas(tester).physics, isA<PageScrollPhysics>());

    final controlador = visualizadorDaPagina(
      tester,
      1,
    ).transformationController!;
    controlador.value = Matrix4.diagonal3Values(2, 2, 1);
    await tester.pump();

    expect(paginas(tester).physics, isA<NeverScrollableScrollPhysics>());

    controlador.value = Matrix4.identity();
    await tester.pump();

    expect(paginas(tester).physics, isA<PageScrollPhysics>());
  });

  testWidgets('trocar de página destrava o swipe e a nova página começa sem '
      'zoom', (tester) async {
    await abrir(tester);
    visualizadorDaPagina(tester, 1).transformationController!.value =
        Matrix4.diagonal3Values(3, 3, 1);
    await tester.pump();
    expect(paginas(tester).physics, isA<NeverScrollableScrollPhysics>());

    paginas(tester).controller!.jumpToPage(2);
    await tester.pumpAndSettle();

    expect(paginas(tester).physics, isA<PageScrollPhysics>());
    expect(
      visualizadorDaPagina(
        tester,
        2,
      ).transformationController!.value.getMaxScaleOnAxis(),
      1.0,
    );
    expect(find.text('3/3'), findsOneWidget);
  });

  testWidgets('o botão "Fechar" volta para a página de baixo', (tester) async {
    await abrir(tester);

    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    expect(find.byType(VisualizadorFotos), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
  });
}
