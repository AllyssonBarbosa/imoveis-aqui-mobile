import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/presentation/contato/contato_cubit.dart';
import 'package:imoveis_aqui/presentation/contato/contato_state.dart';
import 'package:imoveis_aqui/presentation/contato/rotulos_contato.dart';
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

  Future<void> pumpBarra(
    WidgetTester tester,
    List<CanalContato> canais, {
    ContatoState inicial = const ContatoState.ocioso(),
    Stream<ContatoState> fluxo = const Stream<ContatoState>.empty(),
  }) async {
    whenListen(cubit, fluxo, initialState: inicial);
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

  group('loading e bloqueio durante o POST (D-13)', () {
    testWidgets(
      'enviando(whatsapp): spinner no principal e tudo desabilitado',
      (tester) async {
        await pumpBarra(
          tester,
          CanalContato.values,
          inicial: const ContatoState.enviando(CanalContato.whatsapp),
        );

        final principal = find.byType(FilledButton);
        expect(
          find.descendant(
            of: principal,
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
        expect(tester.widget<FilledButton>(principal).onPressed, isNull);
        expect(find.byIcon(Icons.chat), findsNothing);
        // O ⋮ segue visível, porém desabilitado e sem spinner.
        final ponto = find.ancestor(
          of: find.byIcon(Icons.more_vert),
          matching: find.byType(IconButton),
        );
        expect(tester.widget<IconButton>(ponto).onPressed, isNull);
        expect(
          find.descendant(
            of: find.byType(IconButton),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'enviando(telefone): spinner no lugar do ⋮ e tudo desabilitado',
      (tester) async {
        await pumpBarra(
          tester,
          CanalContato.values,
          inicial: const ContatoState.enviando(CanalContato.telefone),
        );

        final botaoMais = find.byType(IconButton);
        expect(
          find.descendant(
            of: botaoMais,
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.more_vert), findsNothing);
        expect(tester.widget<IconButton>(botaoMais).onPressed, isNull);

        final principal = find.byType(FilledButton);
        expect(tester.widget<FilledButton>(principal).onPressed, isNull);
        expect(
          find.descendant(
            of: principal,
            matching: find.byType(CircularProgressIndicator),
          ),
          findsNothing,
        );
        expect(find.byIcon(Icons.chat), findsOneWidget);

        await tester.tap(principal, warnIfMissed: false);
        await tester.tap(botaoMais, warnIfMissed: false);
        await tester.pump();
        verifyNever(() => cubit.contatar(any(), any()));
        expect(find.byType(BottomSheet), findsNothing);
      },
    );

    testWidgets('enviando(email) com só e-mail: spinner no principal', (
      tester,
    ) async {
      await pumpBarra(tester, [
        CanalContato.email,
      ], inicial: const ContatoState.enviando(CanalContato.email));

      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });
  });

  group('SnackBar por motivo de falha (D-14, D-15, Pitfall 3)', () {
    for (final motivo in MotivoFalhaContato.values) {
      testWidgets('falhou($motivo) mostra exatamente a mensagem do motivo', (
        tester,
      ) async {
        final controle = StreamController<ContatoState>();
        addTearDown(controle.close);
        await pumpBarra(tester, CanalContato.values, fluxo: controle.stream);
        expect(find.byType(SnackBar), findsNothing);

        controle.add(ContatoState.falhou(motivo));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text(motivo.mensagem),
          ),
          findsOneWidget,
        );
      });
    }

    test('as cinco mensagens são exatamente as de D-14 e D-15', () {
      expect(MotivoFalhaContato.values.map((m) => m.mensagem).toList(), [
        'Não foi possível abrir o contato. Tente de novo.',
        'Este canal não está disponível para este imóvel.',
        'Este imóvel não está mais disponível.',
        'Muitas tentativas. Aguarde um pouco e tente de novo.',
        'Nenhum aplicativo para abrir este contato.',
      ]);
    });

    testWidgets('falhas seguidas mostram a SnackBar de novo', (tester) async {
      final controle = StreamController<ContatoState>();
      addTearDown(controle.close);
      await pumpBarra(tester, CanalContato.values, fluxo: controle.stream);
      final mensagem = MotivoFalhaContato.generico.mensagem;

      controle
        ..add(const ContatoState.enviando(CanalContato.whatsapp))
        ..add(const ContatoState.falhou(MotivoFalhaContato.generico));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(mensagem), findsOneWidget);

      // A primeira SnackBar some sozinha antes da nova tentativa.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);

      controle
        ..add(const ContatoState.enviando(CanalContato.whatsapp))
        ..add(const ContatoState.falhou(MotivoFalhaContato.generico));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(mensagem), findsOneWidget);
    });

    testWidgets('falha nova substitui a SnackBar anterior (uma só na tela)', (
      tester,
    ) async {
      final controle = StreamController<ContatoState>();
      addTearDown(controle.close);
      await pumpBarra(tester, CanalContato.values, fluxo: controle.stream);

      controle.add(const ContatoState.falhou(MotivoFalhaContato.generico));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      controle
        ..add(const ContatoState.enviando(CanalContato.telefone))
        ..add(const ContatoState.falhou(MotivoFalhaContato.semAplicativo));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(MotivoFalhaContato.semAplicativo.mensagem),
        findsOneWidget,
      );
      expect(find.text(MotivoFalhaContato.generico.mensagem), findsNothing);
    });

    testWidgets('estados que não são falha não mostram SnackBar', (
      tester,
    ) async {
      final controle = StreamController<ContatoState>();
      addTearDown(controle.close);
      await pumpBarra(tester, CanalContato.values, fluxo: controle.stream);

      controle
        ..add(const ContatoState.enviando(CanalContato.whatsapp))
        ..add(const ContatoState.ocioso());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('sem dado de contato na tela (D-14, D-15)', () {
    const proibidos = ['wa.me', 'tel:', 'mailto:', '@'];

    void naoTemDadoDeContato(WidgetTester tester) {
      final textos = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
          .toList();
      expect(textos, isNotEmpty);
      for (final texto in textos) {
        for (final proibido in proibidos) {
          expect(
            texto.contains(proibido),
            isFalse,
            reason: '"$texto" contém "$proibido"',
          );
        }
      }
    }

    testWidgets('barra, sheet e SnackBar só têm rótulos e mensagens fixos', (
      tester,
    ) async {
      final controle = StreamController<ContatoState>();
      addTearDown(controle.close);
      await pumpBarra(tester, CanalContato.values, fluxo: controle.stream);

      naoTemDadoDeContato(tester);

      await tester.tap(maisFormas);
      await tester.pumpAndSettle();
      naoTemDadoDeContato(tester);

      await tester.tap(
        find.descendant(of: itensDoSheet, matching: find.text('Ligar')),
      );
      await tester.pumpAndSettle();

      for (final motivo in MotivoFalhaContato.values) {
        controle.add(ContatoState.falhou(motivo));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(SnackBar), findsOneWidget);
        naoTemDadoDeContato(tester);
        controle.add(const ContatoState.ocioso());
        await tester.pump();
      }
    });
  });
}
