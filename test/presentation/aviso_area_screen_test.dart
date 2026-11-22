import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/presentation/sessao/aviso_area_screen.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

void main() {
  late _SessaoCubitFalso sessao;

  setUp(() {
    sessao = _SessaoCubitFalso();
    when(() => sessao.sair()).thenAnswer((_) async {});
    whenListen(
      sessao,
      const Stream<SessaoState>.empty(),
      initialState: const SessaoState.autenticada(),
    );
  });

  /// A vitrine falsa é a primeira rota; o aviso é empurrado por cima.
  Future<void> montar(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<SessaoCubit>.value(
        value: sessao,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AvisoAreaScreen(),
                  ),
                ),
                child: const Text('Vitrine'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Vitrine'));
    await tester.pumpAndSettle();
  }

  testWidgets('mostra o título, o aviso e o Sair', (tester) async {
    await montar(tester);

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Área do gestor'),
      ),
      findsOneWidget,
    );
    expect(
      find.text('A área do gestor ainda não está no app.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Sair'), findsOneWidget);
  });

  testWidgets('Sair abre o diálogo e Cancelar fecha sem sair', (tester) async {
    await montar(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
    await tester.pumpAndSettle();
    expect(find.text('Sair da conta?'), findsOneWidget);
    expect(
      find.text('Você vai precisar entrar de novo com e-mail e senha.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Sair da conta?'), findsNothing);
    expect(find.byType(AvisoAreaScreen), findsOneWidget);
    verifyNever(() => sessao.sair());
  });

  testWidgets('confirmar chama sair() e volta à primeira rota', (tester) async {
    await montar(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Sair'),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => sessao.sair()).called(1);
    expect(find.byType(AvisoAreaScreen), findsNothing);
    expect(find.text('Vitrine'), findsOneWidget);
  });
}
