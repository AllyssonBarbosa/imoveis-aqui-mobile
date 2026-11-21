import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/presentation/acervo/apresentacao_acervo.dart';
import 'package:imoveis_aqui/presentation/acervo/widgets/chips_situacao.dart';

void main() {
  Future<void> montar(
    WidgetTester tester, {
    SituacaoImovel? selecionada,
    required ValueChanged<SituacaoImovel?> aoEscolher,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChipsSituacao(selecionada: selecionada, aoEscolher: aoEscolher),
        ),
      ),
    );
  }

  testWidgets(
    'mostra Todas, Disponível, Reservado, Vendido, Alugado em ordem',
    (tester) async {
      await montar(tester, aoEscolher: (_) {});

      final rotulos = tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .map((chip) => (chip.label as Text).data)
          .toList();
      expect(rotulos, [
        'Todas',
        'Disponível',
        'Reservado',
        'Vendido',
        'Alugado',
      ]);
    },
  );

  testWidgets('situação nula deixa "Todas" selecionado', (tester) async {
    await montar(tester, aoEscolher: (_) {});

    final selecionados = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .where((chip) => chip.selected)
        .map((chip) => (chip.label as Text).data);
    expect(selecionados, ['Todas']);
  });

  testWidgets('o chip da situação selecionada fica marcado', (tester) async {
    await montar(
      tester,
      selecionada: SituacaoImovel.reservado,
      aoEscolher: (_) {},
    );

    final selecionados = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .where((chip) => chip.selected)
        .map((chip) => (chip.label as Text).data);
    expect(selecionados, ['Reservado']);
  });

  testWidgets('tocar em "Vendido" chama aoEscolher(vendido)', (tester) async {
    final escolhas = <SituacaoImovel?>[];
    await montar(tester, aoEscolher: escolhas.add);

    await tester.tap(find.text('Vendido'));

    expect(escolhas, [SituacaoImovel.vendido]);
  });

  testWidgets('tocar em "Todas" chama aoEscolher(null)', (tester) async {
    final escolhas = <SituacaoImovel?>[SituacaoImovel.vendido];
    await montar(
      tester,
      selecionada: SituacaoImovel.vendido,
      aoEscolher: escolhas.add,
    );

    await tester.tap(find.text('Todas'));

    expect(escolhas, [SituacaoImovel.vendido, null]);
  });

  test('rotulos de apresentação cobrem as quatro situações e "Todas"', () {
    expect(opcoesDeSituacao, hasLength(5));
    expect(rotuloOpcaoDeSituacao(null), 'Todas');
    expect(rotuloSituacao(SituacaoImovel.disponivel), 'Disponível');
    expect(rotuloSituacao(SituacaoImovel.alugado), 'Alugado');
  });
}
