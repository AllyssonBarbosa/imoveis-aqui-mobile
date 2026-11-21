import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/presentation/login/login_cubit.dart';
import 'package:imoveis_aqui/presentation/login/login_screen.dart';
import 'package:imoveis_aqui/presentation/login/login_state.dart';
import 'package:imoveis_aqui/presentation/sessao/botao_sessao_topo.dart';
import 'package:imoveis_aqui/presentation/sessao/entrada_area_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/entrada_area_screen.dart';
import 'package:imoveis_aqui/presentation/sessao/entrada_area_state.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

class _LoginCubitFalso extends MockCubit<LoginState> implements LoginCubit {}

class _EntradaCubitFalso extends MockCubit<EntradaAreaState>
    implements EntradaAreaCubit {}

void main() {
  late _SessaoCubitFalso sessao;

  setUp(() {
    sessao = _SessaoCubitFalso();

    final login = _LoginCubitFalso();
    whenListen(
      login,
      const Stream<LoginState>.empty(),
      initialState: const LoginState.editando(),
    );
    getIt.registerFactory<LoginCubit>(() => login);

    final entrada = _EntradaCubitFalso();
    when(() => entrada.carregar()).thenAnswer((_) async {});
    whenListen(
      entrada,
      const Stream<EntradaAreaState>.empty(),
      initialState: const EntradaAreaState.carregando(),
    );
    getIt.registerFactory<EntradaAreaCubit>(() => entrada);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> montar(
    WidgetTester tester,
    SessaoState estado, {
    Stream<SessaoState> depois = const Stream<SessaoState>.empty(),
  }) async {
    whenListen(sessao, depois, initialState: estado);
    await tester.pumpWidget(
      BlocProvider<SessaoCubit>.value(
        value: sessao,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: BotaoSessaoTopo())),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('verificando ocupa o espaço sem rótulo nem botão', (
    tester,
  ) async {
    await montar(tester, const SessaoState.verificando());

    expect(find.text('Entrar'), findsNothing);
    expect(find.text('Meu acervo'), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(tester.getSize(find.byType(BotaoSessaoTopo)).height, 48);
  });

  testWidgets('anônima mostra Entrar e o toque abre o login', (tester) async {
    await montar(tester, const SessaoState.anonima());

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Meu acervo'), findsNothing);

    await tester.tap(find.text('Entrar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('autenticada mostra Meu acervo e o toque abre a entrada', (
    tester,
  ) async {
    await montar(tester, const SessaoState.autenticada());

    expect(find.text('Meu acervo'), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);

    await tester.tap(find.text('Meu acervo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(EntradaAreaScreen), findsOneWidget);
  });

  testWidgets('o rótulo acompanha a mudança da sessão', (tester) async {
    await montar(
      tester,
      const SessaoState.verificando(),
      depois: Stream.fromIterable(const [SessaoState.anonima()]),
    );
    await tester.pump();

    expect(find.text('Entrar'), findsOneWidget);
  });
}
