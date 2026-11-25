import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/papel.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_cubit.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_screen.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_state.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_cubit.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_screen.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_state.dart';
import 'package:imoveis_aqui/presentation/login/login_cubit.dart';
import 'package:imoveis_aqui/presentation/login/login_screen.dart';
import 'package:imoveis_aqui/presentation/login/login_state.dart';
import 'package:imoveis_aqui/presentation/sessao/aviso_area_screen.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

class _LoginCubitFalso extends MockCubit<LoginState> implements LoginCubit {}

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

class _AcervoCubitFalso extends MockCubit<AcervoState> implements AcervoCubit {}

class _AreaGestorCubitFalso extends MockCubit<AreaGestorState>
    implements AreaGestorCubit {}

void main() {
  late _LoginCubitFalso login;
  late _SessaoCubitFalso sessao;
  late _AcervoCubitFalso acervo;

  setUp(() {
    login = _LoginCubitFalso();
    sessao = _SessaoCubitFalso();
    acervo = _AcervoCubitFalso();
    when(
      () => login.entrar(
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    ).thenAnswer((_) async {});
    when(() => acervo.carregar()).thenAnswer((_) async {});
    whenListen(
      acervo,
      const Stream<AcervoState>.empty(),
      initialState: const AcervoState(conteudo: ConteudoAcervo.vazio()),
    );
    whenListen(
      sessao,
      const Stream<SessaoState>.empty(),
      initialState: const SessaoState.anonima(),
    );
    getIt.registerFactory<AcervoCubit>(() => acervo);
    final areaGestor = _AreaGestorCubitFalso();
    whenListen(
      areaGestor,
      const Stream<AreaGestorState>.empty(),
      initialState: const AreaGestorState(),
    );
    getIt.registerFactory<AreaGestorCubit>(() => areaGestor);
  });

  tearDown(() async {
    await getIt.reset();
  });

  /// Monta uma rota inicial que empurra o login, para provar o "voltar".
  Future<void> montar(
    WidgetTester tester,
    LoginState estado, {
    Stream<LoginState> depois = const Stream<LoginState>.empty(),
    String? aviso,
  }) async {
    whenListen(login, depois, initialState: estado);
    await tester.pumpWidget(
      BlocProvider<SessaoCubit>.value(
        value: sessao,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          LoginScreen(aviso: aviso, criarCubit: () => login),
                    ),
                  ),
                  child: const Text('Abrir login'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir login'));
    // Sem `pumpAndSettle`: o indicador de progresso de `enviando` nunca assenta.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets(
    'mostra título, e-mail e senha com autofill e teclado de e-mail',
    (tester) async {
      await montar(tester, const LoginState.editando());

      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Entrar')),
        findsOneWidget,
      );
      expect(find.byType(AutofillGroup), findsOneWidget);
      final campos = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(campos, hasLength(2));
      expect(campos[0].keyboardType, TextInputType.emailAddress);
      expect(campos[0].autofillHints, [AutofillHints.email]);
      expect(campos[1].obscureText, isTrue);
      expect(campos[1].autofillHints, [AutofillHints.password]);
      expect(campos[1].enableSuggestions, isFalse);
      expect(campos[1].autocorrect, isFalse);
    },
  );

  testWidgets('o olho alterna a senha entre oculta e visível', (tester) async {
    await montar(tester, const LoginState.editando());

    expect(find.byTooltip('Mostrar senha'), findsOneWidget);
    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pump();

    final senha = tester.widgetList<TextField>(find.byType(TextField)).last;
    expect(senha.obscureText, isFalse);
    expect(find.byTooltip('Ocultar senha'), findsOneWidget);
  });

  testWidgets('campos vazios mostram os avisos e não chamam entrar', (
    tester,
  ) async {
    await montar(tester, const LoginState.editando());

    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);
    verifyNever(
      () => login.entrar(
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    );
  });

  testWidgets('e-mail só com espaços é tratado como vazio', (tester) async {
    await montar(tester, const LoginState.editando());

    await tester.enterText(find.byType(TextFormField).first, '   ');
    await tester.enterText(find.byType(TextFormField).last, 'segredo');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsNothing);
    verifyNever(
      () => login.entrar(
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    );
  });

  testWidgets('preenchido, "Entrar" chama entrar uma vez com os textos', (
    tester,
  ) async {
    await montar(tester, const LoginState.editando());

    await tester.enterText(find.byType(TextFormField).first, 'a@b.com');
    await tester.enterText(find.byType(TextFormField).last, 'segredo');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    verify(() => login.entrar(email: 'a@b.com', senha: 'segredo')).called(1);
  });

  testWidgets('enviando desabilita o botão e mostra o progresso', (
    tester,
  ) async {
    await montar(tester, const LoginState.enviando());

    final botao = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(botao.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('falha mostra a mensagem do estado', (tester) async {
    await montar(
      tester,
      const LoginState.falha(mensagem: 'E-mail ou senha inválidos.'),
    );

    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
    final botao = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(botao.onPressed, isNotNull);
  });

  testWidgets('aviso aparece no topo', (tester) async {
    await montar(
      tester,
      const LoginState.editando(),
      aviso: 'Sua sessão terminou. Entre de novo.',
    );

    expect(find.text('Sua sessão terminou. Entre de novo.'), findsOneWidget);
  });

  testWidgets('sem aviso nada aparece no topo', (tester) async {
    await montar(tester, const LoginState.editando());

    expect(find.text('Sua sessão terminou. Entre de novo.'), findsNothing);
  });

  testWidgets(
    'entrou(corretor) marca autenticada, abre o acervo e o voltar não reabre o login',
    (tester) async {
      await montar(
        tester,
        const LoginState.editando(),
        depois: Stream.value(const LoginState.entrou(Papel.corretor)),
      );
      await tester.pumpAndSettle();

      verify(() => sessao.marcarAutenticada()).called(1);
      expect(find.byType(AcervoScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Abrir login'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );

  testWidgets(
    'entrou(gestor) marca autenticada e abre a Área do gestor (D-01)',
    (tester) async {
      await montar(
        tester,
        const LoginState.editando(),
        depois: Stream.value(const LoginState.entrou(Papel.gestor)),
      );
      await tester.pumpAndSettle();

      verify(() => sessao.marcarAutenticada()).called(1);
      expect(find.byType(AreaGestorScreen), findsOneWidget);
      expect(find.byType(AvisoAreaScreen), findsNothing);
      expect(find.byType(AcervoScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );

  testWidgets(
    'entrou(administrador) marca autenticada e abre o aviso (D-02)',
    (tester) async {
      await montar(
        tester,
        const LoginState.editando(),
        depois: Stream.value(const LoginState.entrou(Papel.administrador)),
      );
      await tester.pumpAndSettle();

      verify(() => sessao.marcarAutenticada()).called(1);
      expect(find.byType(AvisoAreaScreen), findsOneWidget);
      expect(find.byType(AreaGestorScreen), findsNothing);
      expect(find.byType(AcervoScreen), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );
}
