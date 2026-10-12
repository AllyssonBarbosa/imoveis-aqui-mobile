import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/presentation/comum/imagem_rede.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/galeria_imovel.dart';

void main() {
  const a = 'https://exemplo.com/a.jpg';
  const b = 'https://exemplo.com/b.jpg';
  const c = 'https://exemplo.com/c.jpg';

  /// Imagem determinística: uma caixa com a chave da própria url.
  Widget caixa(String url) =>
      ColoredBox(key: ValueKey(url), color: Colors.blue);

  Future<void> pumpGaleria(
    WidgetTester tester,
    List<String> urls, {
    ValueChanged<int>? aoTocarFoto,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: GaleriaImovel(
              urls: urls,
              aoTocarFoto: aoTocarFoto,
              construirImagemDeRede: caixa,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('3 fotos: mostra a primeira e o contador 1/3 (D-07)', (
    tester,
  ) async {
    await pumpGaleria(tester, [a, b, c]);

    expect(find.byKey(const ValueKey(a)), findsOneWidget);
    expect(find.byKey(const ValueKey('contador-fotos')), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
  });

  testWidgets('arrastar para a esquerda troca a foto e o contador (2/3)', (
    tester,
  ) async {
    await pumpGaleria(tester, [a, b, c]);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey(b)), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('1/3'), findsNothing);
  });

  testWidgets('uma única foto ainda mostra 1/1 (A7)', (tester) async {
    await pumpGaleria(tester, [a]);

    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('sem fotos: imagem padrão verde, sem contador (D-10)', (
    tester,
  ) async {
    await pumpGaleria(tester, const []);

    expect(find.byType(ImagemPadraoImovel), findsOneWidget);
    expect(find.byKey(const ValueKey('contador-fotos')), findsNothing);
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('cada slide expõe a semântica "Foto N de M"', (tester) async {
    final semantica = tester.ensureSemantics();
    await pumpGaleria(tester, [a, b, c]);

    expect(find.bySemanticsLabel('Foto 1 de 3'), findsOneWidget);

    semantica.dispose();
  });

  testWidgets('tocar na foto avisa o índice da foto visível', (tester) async {
    final toques = <int>[];
    await pumpGaleria(tester, [a, b, c], aoTocarFoto: toques.add);

    await tester.tap(find.byKey(const ValueKey(a)));
    await tester.pump();
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey(b)));
    await tester.pump();

    expect(toques, [0, 1]);
  });

  testWidgets('sem aoTocarFoto o toque não faz nada e não quebra', (
    tester,
  ) async {
    await pumpGaleria(tester, [a, b]);

    await tester.tap(find.byKey(const ValueKey(a)));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('1/2'), findsOneWidget);
  });
}
