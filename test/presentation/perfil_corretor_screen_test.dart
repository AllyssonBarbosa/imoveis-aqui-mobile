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
  const marinaCompleta = PerfilCorretor(
    id: 7,
    empresaId: 3,
    foto: 'https://exemplo.com/marina-perfil.jpg',
    nome: 'Marina Lopes',
    email: 'marina.lopes@jequitiba.exemplo.com',
    creci: '12345-F',
    telefone: '(19) 3333-4444',
    whatsapp: '19999998888',
    apresentacao: 'Corretora há 10 anos em Campinas.',
  );
  // Autônoma com omissões: sem telefone, apresentação e foto.
  const camila = PerfilCorretor(
    id: 9,
    empresaId: 4,
    nome: 'Camila Duarte',
    email: 'camila.duarte@exemplo.com',
    creci: '34567-F',
    whatsapp: '19977776666',
  );
  const semContato = PerfilCorretor(id: 10, nome: 'Bruno Sales');

  late _PerfilCorretorCubitFalso cubit;

  setUp(() {
    cubit = _PerfilCorretorCubitFalso();
    when(() => cubit.carregar(any())).thenAnswer((_) async {});
    when(() => cubit.tentarNovamente()).thenAnswer((_) async {});
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
      naPagina(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Corretor'),
        ),
      ),
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
    await abrirPerfil(
      tester,
      marina,
      const PerfilState.carregado(perfilMarina),
    );

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
    await abrirPerfil(
      tester,
      marina,
      const PerfilState.carregado(perfilMarina),
    );
    final posicaoCarregado = tester.getTopLeft(
      naPagina(find.text('Marina Lopes')),
    );

    expect(posicaoCarregado, posicaoCarregando);
  });

  testWidgets('erro mantém a prévia, mostra a mensagem e "Tentar de novo" '
      'chama tentarNovamente uma vez', (tester) async {
    await abrirPerfil(tester, marina, const PerfilState.erro());

    expect(
      naPagina(find.text('Não foi possível carregar este perfil.')),
      findsOneWidget,
    );
    expect(naPagina(find.text('Marina Lopes')), findsOneWidget);
    expect(naPagina(find.byType(CircularProgressIndicator)), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(naPagina(find.text('Tentar de novo')));
    await tester.pump();

    verify(() => cubit.tentarNovamente()).called(1);
  });

  testWidgets('naoEncontrado mostra só o aviso e "Voltar", sem nome nem foto '
      'da prévia (PERF-05)', (tester) async {
    await abrirPerfil(tester, marina, const PerfilState.naoEncontrado());

    expect(
      naPagina(find.text('Este corretor não está mais disponível')),
      findsOneWidget,
    );
    expect(naPagina(find.byIcon(Icons.person_off_outlined)), findsOneWidget);
    expect(
      naPagina(find.widgetWithText(FilledButton, 'Voltar')),
      findsOneWidget,
    );
    expect(naPagina(find.text('Marina Lopes')), findsNothing);
    expect(
      find.byKey(const ValueKey('https://exemplo.com/marina.jpg')),
      findsNothing,
    );
    expect(naPagina(find.text('Tentar de novo')), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('"Voltar" do aviso fecha o perfil', (tester) async {
    await abrirPerfil(tester, marina, const PerfilState.naoEncontrado());

    await tester.tap(naPagina(find.widgetWithText(FilledButton, 'Voltar')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PerfilCorretorScreen), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
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

  testWidgets('carregado completo mostra, nesta ordem, nome, Apresentação e '
      'Contato com o contato como texto selecionável (PERF-02)', (
    tester,
  ) async {
    await abrirPerfil(
      tester,
      marina,
      const PerfilState.carregado(marinaCompleta),
    );

    expect(naPagina(find.text('Apresentação')), findsOneWidget);
    expect(
      naPagina(find.text('Corretora há 10 anos em Campinas.')),
      findsOneWidget,
    );
    expect(naPagina(find.text('Contato')), findsOneWidget);
    expect(naPagina(find.byType(SelectableText)), findsNWidgets(3));
    for (final valor in [
      '(19) 3333-4444',
      '19999998888',
      'marina.lopes@jequitiba.exemplo.com',
    ]) {
      expect(
        naPagina(find.widgetWithText(SelectableText, valor)),
        findsOneWidget,
      );
    }
    expect(naPagina(find.byIcon(Icons.phone_outlined)), findsOneWidget);
    expect(naPagina(find.byIcon(Icons.chat_outlined)), findsOneWidget);
    expect(naPagina(find.byIcon(Icons.email_outlined)), findsOneWidget);

    final yNome = tester.getTopLeft(naPagina(find.text('Marina Lopes'))).dy;
    final yApresentacao = tester
        .getTopLeft(naPagina(find.text('Apresentação')))
        .dy;
    final yContato = tester.getTopLeft(naPagina(find.text('Contato'))).dy;
    expect(yNome, lessThan(yApresentacao));
    expect(yApresentacao, lessThan(yContato));
  });

  testWidgets('carregado com omissões (Camila) some Apresentação e a linha '
      'Telefone, mantém WhatsApp e o avatar padrão', (tester) async {
    await abrirPerfil(
      tester,
      semFotoNemSlug,
      const PerfilState.carregado(camila),
    );

    expect(naPagina(find.text('Apresentação')), findsNothing);
    expect(naPagina(find.text('Telefone')), findsNothing);
    expect(naPagina(find.text('Contato')), findsOneWidget);
    expect(naPagina(find.text('WhatsApp')), findsOneWidget);
    expect(
      naPagina(find.widgetWithText(SelectableText, '19977776666')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('perfil sem nenhum contato não mostra o título Contato', (
    tester,
  ) async {
    await abrirPerfil(
      tester,
      marina,
      const PerfilState.carregado(semContato),
    );

    expect(naPagina(find.text('Bruno Sales')), findsOneWidget);
    expect(naPagina(find.text('Contato')), findsNothing);
    expect(naPagina(find.text('Apresentação')), findsNothing);
  });

  testWidgets('o contato é só texto: nenhum toque ou botão na seção (D-10)', (
    tester,
  ) async {
    await abrirPerfil(
      tester,
      marina,
      const PerfilState.carregado(marinaCompleta),
    );

    final secao = find.ancestor(
      of: naPagina(find.text('Contato')),
      matching: find.byType(Column),
    );
    expect(secao, findsWidgets);
    final dentro = secao.first;
    for (final tipo in [InkWell, IconButton, TextButton, FilledButton]) {
      expect(
        find.descendant(of: dentro, matching: find.byType(tipo)),
        findsNothing,
        reason: '$tipo não pode existir na seção de contato',
      );
    }
  });
}
