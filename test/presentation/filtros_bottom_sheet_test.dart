import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/filtros_bottom_sheet.dart';

void main() {
  group('mostrarFiltrosBottomSheet (D-07, D-08, D-11)', () {
    Future<void> abrirSheet(
      WidgetTester tester, {
      required FiltrosVitrine aplicados,
      required ValueChanged<FiltrosVitrine> aoAplicar,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => mostrarFiltrosBottomSheet(
                  context,
                  aplicados: aplicados,
                  aoAplicar: aoAplicar,
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
      'mostra o título "Filtros" e os 3 segmentos de finalidade, com '
      '"Qualquer" selecionado quando aplicados está vazio',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
        );

        expect(find.text('Filtros'), findsOneWidget);
        expect(find.text('Qualquer'), findsOneWidget);
        expect(find.text('Venda'), findsOneWidget);
        expect(find.text('Aluguel'), findsOneWidget);
        expect(find.text('Limpar'), findsOneWidget);
        expect(find.text('Ver imóveis'), findsOneWidget);
      },
    );

    testWidgets(
      'tocar "Venda" sozinho nunca chama aoAplicar (rascunho só aplica no '
      'botão, D-08)',
      (tester) async {
        var chamado = false;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) => chamado = true,
        );

        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();

        expect(chamado, isFalse);
        // Sheet continua aberto — não fechou ao só trocar o rascunho.
        expect(find.text('Filtros'), findsOneWidget);
      },
    );

    testWidgets(
      '"Ver imóveis" depois de escolher "Venda" chama aoAplicar exatamente '
      'uma vez com finalidade venda e fecha o sheet',
      (tester) async {
        FiltrosVitrine? aplicado;
        var chamadas = 0;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (filtros) {
            aplicado = filtros;
            chamadas++;
          },
        );

        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(chamadas, 1);
        expect(aplicado, const FiltrosVitrine(finalidade: FinalidadeFiltro.venda));
        expect(find.text('Filtros'), findsNothing);
      },
    );

    testWidgets(
      '"Fechar" fecha o sheet sem chamar aoAplicar, mesmo com o rascunho '
      'alterado (D-08)',
      (tester) async {
        var chamado = false;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) => chamado = true,
        );

        await tester.tap(find.text('Aluguel'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Fechar'));
        await tester.pumpAndSettle();

        expect(chamado, isFalse);
        expect(find.text('Filtros'), findsNothing);
      },
    );

    testWidgets(
      '"Limpar" seguido de "Ver imóveis", a partir de filtros aplicados '
      'não-vazios, aplica o filtro vazio (D-18)',
      (tester) async {
        FiltrosVitrine? aplicado;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
          aoAplicar: (filtros) => aplicado = filtros,
        );

        await tester.tap(find.text('Limpar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(aplicado, const FiltrosVitrine());
      },
    );

    testWidgets(
      'abrir com aplicados finalidade aluguel e tocar "Ver imóveis" sem '
      'mexer em nada reaplica aluguel — prova que o rascunho já nasce '
      'seedado com os filtros aplicados (D-17)',
      (tester) async {
        FiltrosVitrine? aplicado;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
          aoAplicar: (filtros) => aplicado = filtros,
        );

        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(
          aplicado,
          const FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
        );
      },
    );
  });
}
