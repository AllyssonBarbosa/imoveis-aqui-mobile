import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/presentation/contato/contato_cubit.dart';
import 'package:imoveis_aqui/presentation/contato/contato_state.dart';
import 'package:imoveis_aqui/presentation/contato/widgets/barra_contato.dart';
import 'package:mocktail/mocktail.dart';

class _ContatoCubitFalso extends MockCubit<ContatoState>
    implements ContatoCubit {}

void main() {
  late _ContatoCubitFalso cubit;

  setUpAll(() {
    registerFallbackValue(CanalContato.whatsapp);
  });

  setUp(() {
    cubit = _ContatoCubitFalso();
    when(() => cubit.contatar(any(), any())).thenAnswer((_) async {});
  });

  Future<void> pumpBarra(WidgetTester tester, List<CanalContato> canais) async {
    whenListen(
      cubit,
      const Stream<ContatoState>.empty(),
      initialState: const ContatoState.ocioso(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BlocProvider<ContatoCubit>.value(
            value: cubit,
            child: BarraContato(
              imovelId: 42,
              canais: canais,
              legenda: const Text('R\$ 450.000'),
            ),
          ),
        ),
      ),
    );
  }

  final maisFormas = find.byTooltip('Mais formas de contato');
  final itensDoSheet = find.descendant(
    of: find.byType(BottomSheet),
    matching: find.byType(ListTile),
  );

  group('canais e sheet (D-05, D-06, C3)', () {
    testWidgets('com os três canais: principal WhatsApp e ⋮ com Ligar e '
        'Enviar e-mail', (tester) async {
      await pumpBarra(tester, CanalContato.values);

      final principal = find.widgetWithText(FilledButton, 'WhatsApp');
      expect(principal, findsOneWidget);
      expect(
        find.descendant(of: principal, matching: find.byIcon(Icons.chat)),
        findsOneWidget,
      );
      expect(maisFormas, findsOneWidget);

      await tester.tap(maisFormas);
      await tester.pumpAndSettle();

      expect(find.text('Outras formas de contato'), findsOneWidget);
      expect(itensDoSheet, findsNWidgets(2));
      expect(
        find.descendant(of: itensDoSheet, matching: find.text('Ligar')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: itensDoSheet, matching: find.text('Enviar e-mail')),
        findsOneWidget,
      );
    });

    testWidgets('tocar em Ligar fecha o sheet e contata por telefone', (
      tester,
    ) async {
      await pumpBarra(tester, CanalContato.values);

      await tester.tap(maisFormas);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: itensDoSheet, matching: find.text('Ligar')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      verify(() => cubit.contatar(42, CanalContato.telefone)).called(1);
      verifyNever(() => cubit.contatar(any(), CanalContato.whatsapp));
    });

    testWidgets('tocar em Enviar e-mail contata por e-mail', (tester) async {
      await pumpBarra(tester, CanalContato.values);

      await tester.tap(maisFormas);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: itensDoSheet, matching: find.text('Enviar e-mail')),
      );
      await tester.pumpAndSettle();

      verify(() => cubit.contatar(42, CanalContato.email)).called(1);
    });

    testWidgets('tocar no principal contata pelo canal principal', (
      tester,
    ) async {
      await pumpBarra(tester, CanalContato.values);

      await tester.tap(find.widgetWithText(FilledButton, 'WhatsApp'));
      await tester.pump();

      verify(() => cubit.contatar(42, CanalContato.whatsapp)).called(1);
    });

    testWidgets('só telefone: principal Ligar e nenhum ⋮', (tester) async {
      await pumpBarra(tester, [CanalContato.telefone]);

      expect(find.widgetWithText(FilledButton, 'Ligar'), findsOneWidget);
      expect(maisFormas, findsNothing);
    });

    testWidgets('telefone e e-mail: principal Ligar e sheet só com Enviar '
        'e-mail', (tester) async {
      await pumpBarra(tester, [CanalContato.telefone, CanalContato.email]);

      expect(find.widgetWithText(FilledButton, 'Ligar'), findsOneWidget);
      await tester.tap(maisFormas);
      await tester.pumpAndSettle();

      expect(itensDoSheet, findsOneWidget);
      expect(
        find.descendant(of: itensDoSheet, matching: find.text('Enviar e-mail')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: itensDoSheet, matching: find.text('Ligar')),
        findsNothing,
      );
    });

    testWidgets('ordem fixa: [email, whatsapp] tem WhatsApp como principal', (
      tester,
    ) async {
      await pumpBarra(tester, [CanalContato.email, CanalContato.whatsapp]);

      expect(find.widgetWithText(FilledButton, 'WhatsApp'), findsOneWidget);
      await tester.tap(maisFormas);
      await tester.pumpAndSettle();
      expect(itensDoSheet, findsOneWidget);
      expect(
        find.descendant(of: itensDoSheet, matching: find.text('Enviar e-mail')),
        findsOneWidget,
      );
    });

    testWidgets('só WhatsApp: nenhum ⋮', (tester) async {
      await pumpBarra(tester, [CanalContato.whatsapp]);

      expect(find.widgetWithText(FilledButton, 'WhatsApp'), findsOneWidget);
      expect(maisFormas, findsNothing);
    });
  });
}
