import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/cartao_corretor.dart';

/// Imagem determinística: uma caixa com a chave da própria url.
Widget _caixaDaUrl(String url) =>
    ColoredBox(key: ValueKey(url), color: Colors.blue);

void main() {
  const fotoMarina = 'https://exemplo.com/marina.jpg';
  const marina = CorretorResponsavel(
    id: 7,
    nome: 'Marina Lopes',
    foto: fotoMarina,
    slug: 'marina-lopes',
  );
  const semFoto = CorretorResponsavel(id: 9, nome: 'Camila Duarte');

  Future<void> pumpCartao(
    WidgetTester tester,
    CorretorResponsavel corretor, {
    VoidCallback? aoTocar,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CartaoCorretor(
            corretor: corretor,
            aoTocar: aoTocar ?? () {},
            construirImagemDeRede: _caixaDaUrl,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('mostra o nome, o subtítulo e a seta', (tester) async {
    await pumpCartao(tester, marina);

    expect(find.text('Marina Lopes'), findsOneWidget);
    expect(find.text('Ver perfil do corretor'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('com foto, o gancho de imagem recebe a url da foto', (
    tester,
  ) async {
    await pumpCartao(tester, marina);

    expect(find.byKey(const ValueKey(fotoMarina)), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsNothing);
  });

  testWidgets('sem foto, mostra o avatar padrão (person_outline)', (
    tester,
  ) async {
    await pumpCartao(tester, semFoto);

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.text('Camila Duarte'), findsOneWidget);
  });

  testWidgets('tocar no cartão chama aoTocar uma vez', (tester) async {
    var toques = 0;
    await pumpCartao(tester, marina, aoTocar: () => toques++);

    await tester.tap(find.byType(CartaoCorretor));
    await tester.pump();

    expect(toques, 1);
  });

  testWidgets('expõe o rótulo de acessibilidade "Ver perfil de <nome>"', (
    tester,
  ) async {
    final semantica = tester.ensureSemantics();
    await pumpCartao(tester, marina);

    expect(
      tester.getSemantics(find.byType(CartaoCorretor)).label,
      contains('Ver perfil de Marina Lopes'),
    );
    semantica.dispose();
  });
}
