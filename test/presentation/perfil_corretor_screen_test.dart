import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/domain/entities/perfil_corretor.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_corretor_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_corretor_screen.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_state.dart';
import 'package:mocktail/mocktail.dart';

class _PerfilCorretorCubitFalso extends MockCubit<PerfilState<PerfilCorretor>>
    implements PerfilCorretorCubit {}

/// Imagem determinística: uma caixa com a chave da própria url.
Widget _caixaDaUrl(String url) =>
    ColoredBox(key: ValueKey(url), color: Colors.blue);

void main() {
  const marina = CorretorResponsavel(
    id: 7,
    nome: 'Marina Lopes',
    foto: 'https://exemplo.com/marina.jpg',
    slug: 'marina-lopes',
  );
  const semFotoNemSlug = CorretorResponsavel(id: 9, nome: 'Camila Duarte');
  const perfilMarina = PerfilCorretor(
    id: 7,
    empresaId: 3,
    foto: 'https://exemplo.com/marina-perfil.jpg',
    nome: 'Marina Lopes',
    creci: '12345-F',
  );

  late _PerfilCorretorCubitFalso cubit;

  setUp(() {
    cubit = _PerfilCorretorCubitFalso();
    when(() => cubit.carregar(any())).thenAnswer((_) async {});
  });

  /// Abre o perfil por cima de uma página-base, como o detalhe faz, para que
  /// o botão voltar tenha para onde voltar.
  Future<void> abrirPerfil(
    WidgetTester tester,
    CorretorResponsavel corretor,
    PerfilState<PerfilCorretor> estado,
  ) async {
    whenListen(
      cubit,
      const Stream<PerfilState<PerfilCorretor>>.empty(),
      initialState: estado,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => abrirPerfilCorretor(
                  context,
                  corretor,
                  criarPerfilCubit: () => cubit,
                  construirImagemDeRede: _caixaDaUrl,
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Finder naPagina(Finder alvo) =>
      find.descendant(of: find.byType(PerfilCorretorScreen), matching: alvo);

  testWidgets('carregando mostra a prévia (foto e nome em headlineSmall) e o '
      'spinner, sem CRECI', (tester) async {
    await abrirPerfil(tester, marina, const PerfilState.carregando());

    expect(find.byType(PerfilCorretorScreen), findsOneWidget);
    expect(
      naPagina(find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Corretor'),
      )),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('https://exemplo.com/marina.jpg')),
      findsOneWidget,
    );
    final nome = tester.widget<Text>(naPagina(find.text('Marina Lopes')));
    final tema = Theme.of(tester.element(naPagina(find.text('Marina Lopes'))));
    expect(nome.style, tema.textTheme.headlineSmall);
    expect(naPagina(find.byType(CircularProgressIndicator)), findsOneWidget);
    expect(find.textContaining('CRECI'), findsNothing);
  });

  testWidgets('carregado mostra nome e foto do perfil e "CRECI 12345-F", sem '
      'spinner', (tester) async {
    await abrirPerfil(tester, marina, const PerfilState.carregado(perfilMarina));

    expect(naPagina(find.text('Marina Lopes')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('https://exemplo.com/marina-perfil.jpg')),
      findsOneWidget,
    );
    expect(naPagina(find.text('CRECI 12345-F')), findsOneWidget);
    expect(naPagina(find.byType(CircularProgressIndicator)), findsNothing);
  });

  testWidgets('o nome fica no mesmo lugar em carregando e carregado (sem '
      'pulo)', (tester) async {
    await abrirPerfil(tester, marina, const PerfilState.carregando());
    final posicaoCarregando = tester.getTopLeft(
      naPagina(find.text('Marina Lopes')),
    );

    // Desmonta o app inteiro para reabrir o perfil do zero, já carregado.
    await tester.pumpWidget(const SizedBox.shrink());
    await abrirPerfil(tester, marina, const PerfilState.carregado(perfilMarina));
    final posicaoCarregado = tester.getTopLeft(
      naPagina(find.text('Marina Lopes')),
    );

    expect(posicaoCarregado, posicaoCarregando);
  });

  testWidgets('erro mostra a mensagem e mantém a prévia', (tester) async {
    await abrirPerfil(tester, marina, const PerfilState.erro());

    expect(
      naPagina(find.text('Não foi possível carregar este perfil.')),
      findsOneWidget,
    );
    expect(naPagina(find.text('Marina Lopes')), findsOneWidget);
    expect(naPagina(find.byType(CircularProgressIndicator)), findsNothing);
  });

  testWidgets('prévia sem foto mostra o ícone de pessoa (D-19 a)', (
    tester,
  ) async {
    await abrirPerfil(tester, semFotoNemSlug, const PerfilState.carregando());

    expect(find.byType(PerfilCorretorScreen), findsOneWidget);
    expect(naPagina(find.text('Camila Duarte')), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('abrirPerfilCorretor empilha a tela e pede o perfil do id da '
      'prévia uma vez', (tester) async {
    await abrirPerfil(tester, marina, const PerfilState.carregando());

    expect(find.byType(PerfilCorretorScreen), findsOneWidget);
    verify(() => cubit.carregar(7)).called(1);
  });

  testWidgets('o botão voltar fecha o perfil', (tester) async {
    await abrirPerfil(tester, marina, const PerfilState.carregando());

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PerfilCorretorScreen), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
  });
}
