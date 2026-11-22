import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/papel.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_cubit.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_screen.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_state.dart';
import 'package:imoveis_aqui/presentation/login/login_cubit.dart';
import 'package:imoveis_aqui/presentation/login/login_screen.dart';
import 'package:imoveis_aqui/presentation/login/login_state.dart';
import 'package:imoveis_aqui/presentation/sessao/aviso_area_screen.dart';
import 'package:imoveis_aqui/presentation/sessao/entrada_area_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/entrada_area_screen.dart';
import 'package:imoveis_aqui/presentation/sessao/entrada_area_state.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

class _EntradaCubitFalso extends MockCubit<EntradaAreaState>
    implements EntradaAreaCubit {}

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

class _AcervoCubitFalso extends MockCubit<AcervoState> implements AcervoCubit {}

class _LoginCubitFalso extends MockCubit<LoginState> implements LoginCubit {}

void main() {
  late _EntradaCubitFalso entrada;
  late _SessaoCubitFalso sessao;

  setUp(() {
    entrada = _EntradaCubitFalso();
    sessao = _SessaoCubitFalso();
    when(() => entrada.carregar()).thenAnswer((_) async {});
    when(() => entrada.tentarNovamente()).thenAnswer((_) async {});
    when(() => sessao.encerrarPorExpiracao()).thenAnswer((_) async {});
    whenListen(
      sessao,
      const Stream<SessaoState>.empty(),
      initialState: const SessaoState.autenticada(),
    );

    final acervo = _AcervoCubitFalso();
    when(() => acervo.carregar()).thenAnswer((_) async {});
    whenListen(
      acervo,
      const Stream<AcervoState>.empty(),
      initialState: const AcervoState(conteudo: ConteudoAcervo.vazio()),
    );
    getIt.registerFactory<AcervoCubit>(() => acervo);

    final login = _LoginCubitFalso();
    whenListen(
      login,
      const Stream<LoginState>.empty(),
      initialState: const LoginState.editando(),
    );
    getIt.registerFactory<LoginCubit>(() => login);
  });

  tearDown(() async {
    await getIt.reset();
  });

  /// Rota inicial falsa que empurra a entrada, para provar o "voltar".
  Future<void> montar(
    WidgetTester tester,
    EntradaAreaState estado, {
    Stream<EntradaAreaState> depois = const Stream<EntradaAreaState>.empty(),
  }) async {
    whenListen(entrada, depois, initialState: estado);
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
                          EntradaAreaScreen(criarCubit: () => entrada),
                    ),
                  ),
                  child: const Text('Abrir entrada'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir entrada'));
    // Sem `pumpAndSettle`: o indicador de progresso nunca assenta.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('carregando mostra o indicador e pede o papel ao abrir', (
    tester,
  ) async {
    await montar(tester, const EntradaAreaState.carregando());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Meu acervo'),
      ),
      findsOneWidget,
    );
    verify(() => entrada.carregar()).called(1);
  });

  testWidgets('erro mostra a mensagem e Tentar de novo refaz a pergunta', (
    tester,
  ) async {
    await montar(tester, const EntradaAreaState.erro());

    expect(find.text('Não foi possível abrir sua área agora.'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    verify(() => entrada.tentarNovamente()).called(1);
  });

  testWidgets(
    'corretor troca a entrada pelo acervo e o voltar leva à vitrine',
    (tester) async {
      await montar(
        tester,
        const EntradaAreaState.carregando(),
        depois: Stream.value(const EntradaAreaState.papel(Papel.corretor)),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AcervoScreen), findsOneWidget);
      expect(find.byType(EntradaAreaScreen), findsNothing);

      final navegador = tester.state<NavigatorState>(find.byType(Navigator));
      navegador.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Abrir entrada'), findsOneWidget);
      expect(find.byType(AcervoScreen), findsNothing);
    },
  );

  for (final papel in [Papel.gestor, Papel.administrador]) {
    testWidgets('$papel troca a entrada pelo aviso', (tester) async {
      await montar(
        tester,
        const EntradaAreaState.carregando(),
        depois: Stream.value(EntradaAreaState.papel(papel)),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AvisoAreaScreen), findsOneWidget);
      expect(find.byType(EntradaAreaScreen), findsNothing);
    });
  }

  testWidgets(
    'sessaoExpirada deixa a sessão anônima e troca a entrada pelo login com '
    'aviso',
    (tester) async {
      await montar(
        tester,
        const EntradaAreaState.carregando(),
        depois: Stream.value(const EntradaAreaState.sessaoExpirada()),
      );
      await tester.pump(const Duration(milliseconds: 500));

      verify(() => sessao.encerrarPorExpiracao()).called(1);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Sua sessão terminou. Entre de novo.'), findsOneWidget);
      expect(find.byType(EntradaAreaScreen), findsNothing);

      final navegador = tester.state<NavigatorState>(find.byType(Navigator));
      navegador.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Abrir entrada'), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    },
  );
}
