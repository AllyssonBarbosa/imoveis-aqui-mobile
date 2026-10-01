import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/filtros_bottom_sheet.dart';
import 'package:mocktail/mocktail.dart';

/// Fake de `OpcoesFiltroCubit` (Task 2) — todo teste do sheet agora passa
/// um `opcoes:` seedado com o estado desejado, sem depender da pilha real
/// (isso fica no e2e de `vitrine_fluxo_test.dart`).
class _OpcoesFiltroCubitFalso extends MockCubit<OpcoesFiltroState>
    implements OpcoesFiltroCubit {}

void main() {
  late _OpcoesFiltroCubitFalso opcoes;

  setUp(() {
    opcoes = _OpcoesFiltroCubitFalso();
    when(() => opcoes.tentarNovamente()).thenAnswer((_) async {});
  });

  /// Seeda [opcoes] com um estado fixo — bairros e características vazios
  /// por padrão (os testes que não se importam com essas seções continuam
  /// exercitando só o resto do sheet, igual antes dos Tasks 2/3).
  OpcoesFiltroCubit opcoesComEstado({
    List<String> bairros = const [],
    List<String> caracteristicas = const [],
  }) {
    final estado = OpcoesFiltroState(
      bairros: CarregamentoOpcoes.carregadas(bairros),
      caracteristicas: CarregamentoOpcoes.carregadas(caracteristicas),
    );
    whenListen(
      opcoes,
      Stream<OpcoesFiltroState>.value(estado),
      initialState: estado,
    );
    return opcoes;
  }

  group('mostrarFiltrosBottomSheet (D-07, D-08, D-11)', () {
    Future<void> abrirSheet(
      WidgetTester tester, {
      required FiltrosVitrine aplicados,
      required ValueChanged<FiltrosVitrine> aoAplicar,
      OpcoesFiltroCubit? opcoesCubit,
    }) async {
      final cubitDeOpcoes = opcoesCubit ?? opcoesComEstado();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => mostrarFiltrosBottomSheet(
                  context,
                  aplicados: aplicados,
                  aoAplicar: aoAplicar,
                  opcoes: cubitDeOpcoes,
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

    // "Qualquer" também rotula a opção padrão de cada ChoiceChip de mínimo
    // (Quartos/Suítes/Vagas, Task 2) — este finder escopa ao SegmentedButton
    // de finalidade para continuar único.
    final qualquerFinalidade = find.descendant(
      of: find.byWidgetPredicate((widget) => widget is SegmentedButton),
      matching: find.text('Qualquer'),
    );

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
        expect(qualquerFinalidade, findsOneWidget);
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

    testWidgets(
      'mostra "Tipo de imóvel" com 4 FilterChips (Casa, Apartamento, '
      'Terreno, Lote) e as seções Quartos/Suítes/Vagas com 5 ChoiceChips '
      'cada (Qualquer, 1+, 2+, 3+, 4+)',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
        );

        expect(find.text('Tipo de imóvel'), findsOneWidget);
        expect(find.widgetWithText(FilterChip, 'Casa'), findsOneWidget);
        expect(
          find.widgetWithText(FilterChip, 'Apartamento'),
          findsOneWidget,
        );
        expect(find.widgetWithText(FilterChip, 'Terreno'), findsOneWidget);
        expect(find.widgetWithText(FilterChip, 'Lote'), findsOneWidget);

        expect(find.text('Quartos'), findsOneWidget);
        expect(find.text('Suítes'), findsOneWidget);
        expect(find.text('Vagas'), findsOneWidget);
        // "Qualquer" da seção de finalidade é um SegmentedButton, não um
        // ChoiceChip — só as 3 seções de mínimo usam ChoiceChip.
        expect(find.widgetWithText(ChoiceChip, 'Qualquer'), findsNWidgets(3));
        expect(find.widgetWithText(ChoiceChip, '1+'), findsNWidgets(3));
        expect(find.widgetWithText(ChoiceChip, '2+'), findsNWidgets(3));
        expect(find.widgetWithText(ChoiceChip, '3+'), findsNWidgets(3));
        expect(find.widgetWithText(ChoiceChip, '4+'), findsNWidgets(3));
      },
    );

    testWidgets(
      'tocar Casa e Apartamento sozinho nunca chama aoAplicar; "Ver '
      'imóveis" aplica naturezas={casa, apartamento} (D-05, D-08)',
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

        await tester.tap(find.widgetWithText(FilterChip, 'Casa'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, 'Apartamento'));
        await tester.pumpAndSettle();
        expect(chamadas, 0);

        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(chamadas, 1);
        expect(
          aplicado,
          const FiltrosVitrine(
            naturezas: {NaturezaImovel.casa, NaturezaImovel.apartamento},
          ),
        );
      },
    );

    testWidgets(
      'tocar "2+" em Quartos e "Ver imóveis" aplica quartosMin: 2 (D-01, '
      'D-10)',
      (tester) async {
        FiltrosVitrine? aplicado;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (filtros) => aplicado = filtros,
        );

        final choiceQuartosDoisMais = find
            .widgetWithText(ChoiceChip, '2+')
            .at(0);
        await tester.ensureVisible(choiceQuartosDoisMais);
        await tester.tap(choiceQuartosDoisMais);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(aplicado, const FiltrosVitrine(quartosMin: 2));
      },
    );

    testWidgets(
      'tocar "1+" em Suítes e "Ver imóveis" aplica suitesMin: 1',
      (tester) async {
        FiltrosVitrine? aplicado;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (filtros) => aplicado = filtros,
        );

        final choiceSuitesUmMais = find.widgetWithText(ChoiceChip, '1+').at(1);
        await tester.ensureVisible(choiceSuitesUmMais);
        await tester.tap(choiceSuitesUmMais);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(aplicado, const FiltrosVitrine(suitesMin: 1));
      },
    );

    testWidgets(
      'tocar "4+" em Vagas e "Ver imóveis" aplica vagasMin: 4',
      (tester) async {
        FiltrosVitrine? aplicado;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (filtros) => aplicado = filtros,
        );

        final choiceVagasQuatroMais = find
            .widgetWithText(ChoiceChip, '4+')
            .at(2);
        await tester.ensureVisible(choiceVagasQuatroMais);
        await tester.tap(choiceVagasQuatroMais);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(aplicado, const FiltrosVitrine(vagasMin: 4));
      },
    );

    testWidgets(
      'abrir com quartosMin já aplicado mostra "2+" selecionado em Quartos '
      '(D-17, rascunho seedado)',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(quartosMin: 2),
          aoAplicar: (_) {},
        );

        final choiceQuartosDoisMais = tester.widget<ChoiceChip>(
          find.widgetWithText(ChoiceChip, '2+').at(0),
        );
        expect(choiceQuartosDoisMais.selected, isTrue);

        final choiceQuartosQualquer = tester.widget<ChoiceChip>(
          find.widgetWithText(ChoiceChip, 'Qualquer').at(0),
        );
        expect(choiceQuartosQualquer.selected, isFalse);
      },
    );

    testWidgets(
      'sem finalidade escolhida, os campos de preço ficam desabilitados com '
      'a mensagem de ajuda (D-03, Pitfall 5)',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
        );

        expect(find.text('Preço'), findsOneWidget);
        expect(
          find.text('Escolha Venda ou Aluguel para filtrar por preço'),
          findsOneWidget,
        );
        // Os dois primeiros TextFields (seção Preço) ficam desabilitados.
        final precoMinField = tester.widget<TextField>(
          find.byType(TextField).first,
        );
        final precoMaxField = tester.widget<TextField>(
          find.byType(TextField).at(1),
        );
        expect(precoMinField.enabled, isFalse);
        expect(precoMaxField.enabled, isFalse);
      },
    );

    testWidgets(
      'escolher "Venda" habilita os campos de preço com prefixo R\$, sem '
      'sufixo "/mês"',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
        );

        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();

        expect(
          find.text('Escolha Venda ou Aluguel para filtrar por preço'),
          findsNothing,
        );
        final precoMinField = tester.widget<TextField>(
          find.byType(TextField).first,
        );
        expect(precoMinField.enabled, isTrue);
        expect(precoMinField.decoration?.prefixText, 'R\$ ');
        expect(precoMinField.decoration?.suffixText, isNull);
      },
    );

    testWidgets(
      'escolher "Aluguel" habilita os campos de preço com sufixo "/mês"',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
        );

        await tester.tap(find.text('Aluguel'));
        await tester.pumpAndSettle();

        final precoMinField = tester.widget<TextField>(
          find.byType(TextField).first,
        );
        expect(precoMinField.enabled, isTrue);
        expect(precoMinField.decoration?.suffixText, '/mês');
      },
    );

    testWidgets(
      'trocar de Venda para Aluguel limpa o texto já digitado nos campos de '
      'preço (D-13)',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
        );

        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, '250000');
        await tester.pumpAndSettle();
        expect(find.text('250.000'), findsOneWidget);

        await tester.tap(find.text('Aluguel'));
        await tester.pumpAndSettle();

        expect(find.text('250.000'), findsNothing);
      },
    );

    testWidgets(
      'seção "Área" sempre habilitada (sem finalidade) com sufixo "m²"',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
        );

        expect(find.text('Área'), findsOneWidget);
        final todosOsCampos = tester
            .widgetList<TextField>(find.byType(TextField))
            .toList();
        // Preço (2, desabilitados sem finalidade) + Área (2, sempre
        // habilitados) = 4 TextFields.
        expect(todosOsCampos, hasLength(4));
        final camposArea = todosOsCampos.sublist(2);
        expect(camposArea.every((c) => c.enabled != false), isTrue);
        expect(camposArea.every((c) => c.decoration?.suffixText == 'm²'), isTrue);
      },
    );

    testWidgets(
      'mínimo de preço maior que o máximo mostra erro inline no campo '
      'Máximo e desabilita "Ver imóveis"; corrigir reabilita (D-12)',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
        );

        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();

        final campoMinimo = find.byType(TextField).first;
        final campoMaximo = find.byType(TextField).at(1);
        await tester.enterText(campoMinimo, '300000');
        await tester.pumpAndSettle();
        await tester.enterText(campoMaximo, '250000');
        await tester.pumpAndSettle();

        expect(
          find.text('O mínimo não pode ser maior que o máximo'),
          findsOneWidget,
        );
        final botaoVerImoveis = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Ver imóveis'),
        );
        expect(botaoVerImoveis.onPressed, isNull);

        await tester.enterText(campoMaximo, '350000');
        await tester.pumpAndSettle();

        expect(
          find.text('O mínimo não pode ser maior que o máximo'),
          findsNothing,
        );
        final botaoReabilitado = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Ver imóveis'),
        );
        expect(botaoReabilitado.onPressed, isNotNull);
      },
    );

    testWidgets(
      'preencher preço mín/máx após escolher Venda e tocar "Ver imóveis" '
      'aplica precoMin/precoMax (D-09)',
      (tester) async {
        FiltrosVitrine? aplicado;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (filtros) => aplicado = filtros,
        );

        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, '250000');
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(1), '300000');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(
          aplicado,
          const FiltrosVitrine(
            finalidade: FinalidadeFiltro.venda,
            precoMin: 250000,
            precoMax: 300000,
          ),
        );
      },
    );

    testWidgets(
      'preencher área mín/máx sem finalidade e tocar "Ver imóveis" aplica '
      'areaMin/areaMax (D-09)',
      (tester) async {
        FiltrosVitrine? aplicado;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (filtros) => aplicado = filtros,
        );

        final campos = find.byType(TextField);
        await tester.enterText(campos.at(2), '80');
        await tester.pumpAndSettle();
        await tester.enterText(campos.at(3), '120');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(aplicado, const FiltrosVitrine(areaMin: 80, areaMax: 120));
      },
    );

    testWidgets(
      '"Limpar" seguido de "Ver imóveis" zera também as faixas de preço e '
      'área já aplicadas (D-18)',
      (tester) async {
        FiltrosVitrine? aplicado;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(
            finalidade: FinalidadeFiltro.venda,
            precoMin: 250000,
            precoMax: 300000,
            areaMin: 80,
            areaMax: 120,
          ),
          aoAplicar: (filtros) => aplicado = filtros,
        );

        await tester.tap(find.text('Limpar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(aplicado, const FiltrosVitrine());
      },
    );
  });

  group('Seção Bairros (FIL-04, D-05, D-20, D-21)', () {
    Future<void> abrirSheet(
      WidgetTester tester, {
      required FiltrosVitrine aplicados,
      required ValueChanged<FiltrosVitrine> aoAplicar,
      required OpcoesFiltroCubit opcoesCubit,
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
                  opcoes: opcoesCubit,
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
      'carregando: expandir "Bairros" mostra o indicador de progresso',
      (tester) async {
        final estado = const OpcoesFiltroState(
          bairros: CarregamentoOpcoes.carregando(),
          caracteristicas: CarregamentoOpcoes.carregadas([]),
        );
        whenListen(
          opcoes,
          Stream<OpcoesFiltroState>.value(estado),
          initialState: estado,
        );

        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
          opcoesCubit: opcoes,
        );
        await tester.ensureVisible(find.text('Bairros'));
        await tester.tap(find.text('Bairros'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'falha: expandir "Bairros" mostra a mensagem de erro + "Tentar de '
      'novo", que chama tentarNovamente()',
      (tester) async {
        final estado = const OpcoesFiltroState(
          bairros: CarregamentoOpcoes.falha(),
          caracteristicas: CarregamentoOpcoes.carregadas([]),
        );
        whenListen(
          opcoes,
          Stream<OpcoesFiltroState>.value(estado),
          initialState: estado,
        );

        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
          opcoesCubit: opcoes,
        );
        await tester.ensureVisible(find.text('Bairros'));
        await tester.tap(find.text('Bairros'));
        await tester.pumpAndSettle();

        expect(
          find.text('Não foi possível carregar os bairros'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Tentar de novo'));
        await tester.tap(find.text('Tentar de novo'));
        await tester.pump();

        verify(() => opcoes.tentarNovamente()).called(1);
      },
    );

    testWidgets(
      'lista vazia: expandir "Bairros" mostra "Nenhum bairro disponível '
      'nesta cidade"',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
          opcoesCubit: opcoesComEstado(),
        );
        await tester.ensureVisible(find.text('Bairros'));
        await tester.tap(find.text('Bairros'));
        await tester.pumpAndSettle();

        expect(
          find.text('Nenhum bairro disponível nesta cidade'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'com opções: mostra "Filtrar bairros" e um CheckboxListTile por '
      'opção; digitar esconde as que não combinam, sem chamar aoAplicar '
      '(D-21 — filtra só a lista de opções)',
      (tester) async {
        var chamado = false;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) => chamado = true,
          opcoesCubit: opcoesComEstado(
            bairros: ['Cambuí', 'Castelo', 'Centro'],
          ),
        );
        await tester.ensureVisible(find.text('Bairros'));
        await tester.tap(find.text('Bairros'));
        await tester.pumpAndSettle();

        expect(find.text('Filtrar bairros'), findsOneWidget);
        expect(find.widgetWithText(CheckboxListTile, 'Cambuí'), findsOneWidget);
        expect(
          find.widgetWithText(CheckboxListTile, 'Castelo'),
          findsOneWidget,
        );
        expect(find.widgetWithText(CheckboxListTile, 'Centro'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextField, 'Filtrar bairros'),
          'camb',
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(CheckboxListTile, 'Cambuí'), findsOneWidget);
        expect(find.widgetWithText(CheckboxListTile, 'Castelo'), findsNothing);
        expect(find.widgetWithText(CheckboxListTile, 'Centro'), findsNothing);
        expect(chamado, isFalse);
      },
    );

    testWidgets(
      'marcar "Cambuí" e tocar "Ver imóveis" aplica bairros: {Cambuí} '
      '(FIL-04, D-05)',
      (tester) async {
        FiltrosVitrine? aplicado;
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (filtros) => aplicado = filtros,
          opcoesCubit: opcoesComEstado(bairros: ['Cambuí', 'Taquaral']),
        );
        await tester.ensureVisible(find.text('Bairros'));
        await tester.tap(find.text('Bairros'));
        await tester.pumpAndSettle();

        final checkboxCambui = find.widgetWithText(CheckboxListTile, 'Cambuí');
        await tester.ensureVisible(checkboxCambui);
        await tester.tap(checkboxCambui);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(aplicado, const FiltrosVitrine(bairros: {'Cambuí'}));
      },
    );

    testWidgets(
      'seção começa expandida quando o rascunho (aplicados) já tem bairros '
      '(D-17 — rascunho seedado reabre o sheet já expandido)',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(bairros: {'Cambuí'}),
          aoAplicar: (_) {},
          opcoesCubit: opcoesComEstado(bairros: ['Cambuí', 'Taquaral']),
        );

        // Já expandida sem precisar tocar no título — "Filtrar bairros" já
        // visível direto.
        expect(find.text('Filtrar bairros'), findsOneWidget);
      },
    );
  });

  group('Seção Características (FIL-04, D-04, D-16, D-20)', () {
    Future<void> abrirSheet(
      WidgetTester tester, {
      required FiltrosVitrine aplicados,
      required ValueChanged<FiltrosVitrine> aoAplicar,
      required OpcoesFiltroCubit opcoesCubit,
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
                  opcoes: opcoesCubit,
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
      'carregando: mostra o indicador de progresso — sem precisar expandir '
      '(a seção é sempre visível, diferente de Bairros)',
      (tester) async {
        final estado = const OpcoesFiltroState(
          bairros: CarregamentoOpcoes.carregadas([]),
          caracteristicas: CarregamentoOpcoes.carregando(),
        );
        whenListen(
          opcoes,
          Stream<OpcoesFiltroState>.value(estado),
          initialState: estado,
        );

        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
          opcoesCubit: opcoes,
        );
        await tester.ensureVisible(find.text('Características'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'falha: mostra a mensagem de erro + "Tentar de novo", que chama '
      'tentarNovamente()',
      (tester) async {
        final estado = const OpcoesFiltroState(
          bairros: CarregamentoOpcoes.carregadas([]),
          caracteristicas: CarregamentoOpcoes.falha(),
        );
        whenListen(
          opcoes,
          Stream<OpcoesFiltroState>.value(estado),
          initialState: estado,
        );

        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
          opcoesCubit: opcoes,
        );
        await tester.ensureVisible(find.text('Características'));
        await tester.pumpAndSettle();

        expect(
          find.text('Não foi possível carregar as características'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Tentar de novo'));
        await tester.tap(find.text('Tentar de novo'));
        await tester.pump();

        verify(() => opcoes.tentarNovamente()).called(1);
      },
    );

    testWidgets(
      'lista vazia: mostra "Nenhuma característica disponível"',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(),
          aoAplicar: (_) {},
          opcoesCubit: opcoesComEstado(),
        );
        await tester.ensureVisible(find.text('Características'));
        await tester.pump();

        expect(
          find.text('Nenhuma característica disponível'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'com opções: mostra um FilterChip por opção, selecionado a partir do '
      'rascunho (D-17)',
      (tester) async {
        await abrirSheet(
          tester,
          aplicados: const FiltrosVitrine(caracteristicas: {'Piscina'}),
          aoAplicar: (_) {},
          opcoesCubit: opcoesComEstado(
            caracteristicas: ['Churrasqueira', 'Piscina'],
          ),
        );
        await tester.ensureVisible(find.text('Características'));
        await tester.pump();

        expect(
          find.widgetWithText(FilterChip, 'Churrasqueira'),
          findsOneWidget,
        );
        final chipPiscina = tester.widget<FilterChip>(
          find.widgetWithText(FilterChip, 'Piscina'),
        );
        expect(chipPiscina.selected, isTrue);
        final chipChurrasqueira = tester.widget<FilterChip>(
          find.widgetWithText(FilterChip, 'Churrasqueira'),
        );
        expect(chipChurrasqueira.selected, isFalse);
      },
    );

    testWidgets(
      'marcar "Piscina" sozinho nunca chama aoAplicar; "Ver imóveis" aplica '
      'caracteristicas: {Piscina} (FIL-04, D-04)',
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
          opcoesCubit: opcoesComEstado(
            caracteristicas: ['Piscina', 'Churrasqueira'],
          ),
        );
        final chipPiscina = find.widgetWithText(FilterChip, 'Piscina');
        await tester.ensureVisible(chipPiscina);
        await tester.tap(chipPiscina);
        await tester.pumpAndSettle();
        expect(chamadas, 0);

        await tester.tap(find.text('Ver imóveis'));
        await tester.pumpAndSettle();

        expect(chamadas, 1);
        expect(aplicado, const FiltrosVitrine(caracteristicas: {'Piscina'}));
      },
    );
  });
}
