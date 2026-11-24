import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/app_localizacao.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/presentation/contatos/widgets/seletor_periodo.dart';

/// Prova o pt-BR do `showDateRangePicker` (D-20) com os mesmos delegates e
/// locales que o `main.dart` usa — sem atalhos de periodo e com os limites
/// `firstDate = DateTime(2024)` e `lastDate` = hoje.
void main() {
  PeriodoContatos? resultado;
  var terminou = false;

  Future<void> abrirSeletor(
    WidgetTester tester, {
    PeriodoContatos? atual,
  }) async {
    resultado = null;
    terminou = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: delegatesDeLocalizacao,
        supportedLocales: localesSuportados,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  resultado = await escolherPeriodoComSeletor(context, atual);
                  terminou = true;
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  // Datas relativas a hoje: o seletor limita o intervalo a [2024, hoje].
  final hoje = DateUtils.dateOnly(DateTime.now());
  final atual = PeriodoContatos(
    de: hoje.subtract(const Duration(days: 20)),
    ate: hoje.subtract(const Duration(days: 1)),
  );

  testWidgets('os limites sao 2024 e hoje, sem hora', (tester) async {
    await abrirSeletor(tester, atual: atual);

    final dialogo = tester.widget<DateRangePickerDialog>(
      find.byType(DateRangePickerDialog),
    );
    expect(dialogo.firstDate, DateTime(2024));
    expect(dialogo.firstDate, primeiraDataDoSeletor);
    expect(dialogo.lastDate, hoje);
  });

  testWidgets('mostra "Salvar" e "Selecione o intervalo", sem "Save"', (
    tester,
  ) async {
    await abrirSeletor(tester, atual: atual);

    expect(find.text('Salvar'), findsOneWidget);
    expect(find.text('Selecione o intervalo'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('nao oferece atalhos de periodo', (tester) async {
    await abrirSeletor(tester, atual: atual);

    expect(find.textContaining('7 dias'), findsNothing);
    expect(find.textContaining('30 dias'), findsNothing);
  });

  testWidgets('Salvar devolve um PeriodoContatos com os mesmos dias', (
    tester,
  ) async {
    await abrirSeletor(tester, atual: atual);

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(terminou, isTrue);
    expect(resultado, isNotNull);
    expect(resultado?.de, atual.de);
    expect(resultado?.ate, atual.ate);
  });

  testWidgets('fechar o dialogo devolve null', (tester) async {
    await abrirSeletor(tester, atual: atual);

    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    expect(terminou, isTrue);
    expect(resultado, isNull);
  });
}
