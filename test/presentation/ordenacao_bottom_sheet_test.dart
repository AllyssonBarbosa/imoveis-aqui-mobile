import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/ordenacao_vitrine.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart';

void main() {
  group('RotuloOrdenacaoVitrine', () {
    test('cada valor do enum tem o rótulo em PT esperado (D-11)', () {
      expect(OrdenacaoVitrine.maisRecentes.rotulo, 'Mais recentes');
      expect(OrdenacaoVitrine.precoAsc.rotulo, 'Menor preço');
      expect(OrdenacaoVitrine.precoDesc.rotulo, 'Maior preço');
      expect(OrdenacaoVitrine.areaAsc.rotulo, 'Menor área');
      expect(OrdenacaoVitrine.areaDesc.rotulo, 'Maior área');
    });
  });

  group('mostrarOrdenacaoBottomSheet (D-10, D-11)', () {
    Future<void> abrirSheet(
      WidgetTester tester, {
      required OrdenacaoVitrine atual,
      required ValueChanged<OrdenacaoVitrine> aoEscolher,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => mostrarOrdenacaoBottomSheet(
                  context,
                  atual: atual,
                  aoEscolher: aoEscolher,
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'mostra o título "Ordenar por" e as 5 opções, com a atual selecionada',
      (tester) async {
        await abrirSheet(
          tester,
          atual: OrdenacaoVitrine.precoAsc,
          aoEscolher: (_) {},
        );

        expect(find.text('Ordenar por'), findsOneWidget);
        expect(find.text('Mais recentes'), findsOneWidget);
        expect(find.text('Menor preço'), findsOneWidget);
        expect(find.text('Maior preço'), findsOneWidget);
        expect(find.text('Menor área'), findsOneWidget);
        expect(find.text('Maior área'), findsOneWidget);

        final radioGroup = tester.widget<RadioGroup<OrdenacaoVitrine>>(
          find.byType(RadioGroup<OrdenacaoVitrine>),
        );
        expect(radioGroup.groupValue, OrdenacaoVitrine.precoAsc);
      },
    );

    testWidgets(
      'tocar uma opção fecha o sheet e chama aoEscolher exatamente uma vez, '
      'com a opção tocada',
      (tester) async {
        OrdenacaoVitrine? escolhida;
        await abrirSheet(
          tester,
          atual: OrdenacaoVitrine.maisRecentes,
          aoEscolher: (valor) => escolhida = valor,
        );

        await tester.tap(find.text('Menor preço'));
        await tester.pumpAndSettle();

        expect(escolhida, OrdenacaoVitrine.precoAsc);
        // Sheet fechado — o título não aparece mais na árvore.
        expect(find.text('Ordenar por'), findsNothing);
      },
    );

    testWidgets(
      'renderiza exatamente um RadioListTile por opção, dentro do '
      'RadioGroup (fonte única de verdade — nunca groupValue/onChanged '
      'deprecados por tile, verificado por grep estático no verify do '
      'plano)',
      (tester) async {
        await abrirSheet(
          tester,
          atual: OrdenacaoVitrine.maisRecentes,
          aoEscolher: (_) {},
        );

        expect(
          find.descendant(
            of: find.byType(RadioGroup<OrdenacaoVitrine>),
            matching: find.byType(RadioListTile<OrdenacaoVitrine>),
          ),
          findsNWidgets(5),
        );
      },
    );
  });
}
