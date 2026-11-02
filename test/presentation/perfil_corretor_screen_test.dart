import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/perfil_corretor_screen.dart';

/// Imagem determinística: uma caixa com a chave da própria url.
Widget _caixaDaUrl(String url) =>
    ColoredBox(key: ValueKey(url), color: Colors.blue);

void main() {
  const marina = CorretorResponsavel(
    id: 7,
    nome: 'Marina Lopes',
    foto: 'https://exemplo.com/marina.jpg',
  );
  const semFoto = CorretorResponsavel(id: 9, nome: 'Camila Duarte');

  /// Abre o perfil por cima de uma página-base, como o detalhe faz, para que
  /// o botão voltar tenha para onde voltar.
  Future<void> abrirPerfil(
    WidgetTester tester,
    CorretorResponsavel corretor,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => abrirPerfilCorretor(
                  context,
                  corretor,
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

  testWidgets('mostra AppBar "Corretor", avatar grande e o nome em '
      'headlineSmall', (tester) async {
    await abrirPerfil(tester, marina);

    expect(find.byType(PerfilCorretorScreen), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Corretor')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('https://exemplo.com/marina.jpg')),
      findsOneWidget,
    );
    final nome = tester.widget<Text>(find.text('Marina Lopes'));
    final tema = Theme.of(tester.element(find.text('Marina Lopes')));
    expect(nome.style, tema.textTheme.headlineSmall);
  });

  testWidgets('não mostra nenhum dado de contato (T-04-08-01)', (tester) async {
    await abrirPerfil(tester, marina);

    final textos = tester
        .widgetList<Text>(find.byType(Text))
        .map((texto) => (texto.data ?? '').toLowerCase())
        .toList();
    for (final proibido in ['@', 'whatsapp', 'telefone', 'creci', 'e-mail']) {
      expect(
        textos.where((texto) => texto.contains(proibido)),
        isEmpty,
        reason: 'a tela de perfil não pode mostrar "$proibido"',
      );
    }
  });

  testWidgets('corretor sem foto abre do mesmo jeito (D-19 a)', (
    tester,
  ) async {
    await abrirPerfil(tester, semFoto);

    expect(find.byType(PerfilCorretorScreen), findsOneWidget);
    expect(find.text('Camila Duarte'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('o botão voltar fecha o perfil', (tester) async {
    await abrirPerfil(tester, marina);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PerfilCorretorScreen), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
  });
}
