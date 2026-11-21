import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/presentation/acervo/widgets/cartao_imovel_acervo.dart';

import '../support/api_falsa.dart';
import '../support/pilha_real.dart';

/// Fluxos ponta a ponta do acervo do corretor (AC-1, AC-2, AC-4, D-08..D-10):
/// pela pilha REAL do app sobre a `ApiFalsa`, com o token já guardado no
/// aparelho. A entrada é o botão "Meu acervo" do topo da vitrine, como o
/// usuário faz. Nada de `pumpAndSettle` (indicador de progresso animado).
void main() {
  tearDown(() async {
    await getIt.reset();
  });

  List<Map<String, Object?>> itensDa(String fixture) =>
      ((lerFixtureApi(fixture)! as Map<String, Object?>)['results']!
              as List<Object?>)
          .cast<Map<String, Object?>>();

  /// Abre o app com sessão guardada e entra em "Meu acervo" pelo topo.
  Future<PilhaReal> abrirAcervo(WidgetTester tester) async {
    final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
    await pilha.abrirApp(tester);
    expect(find.text('Meu acervo'), findsOneWidget);
    await tester.tap(find.text('Meu acervo'));
    // Entrada pergunta o papel e se substitui pelo acervo (duas transições).
    await assentar(tester, quadros: 12);
    return pilha;
  }

  /// Rola a lista do acervo para baixo até [texto] aparecer (a próxima página
  /// vem do servidor pela URL `next`).
  Future<void> rolarAte(WidgetTester tester, String texto) async {
    var tentativas = 0;
    while (find.text(texto).evaluate().isEmpty && tentativas < 40) {
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      tentativas++;
    }
  }

  testWidgets(
    'Meu acervo mostra os cartões da p1; rolar até o fim traz a p2 pela URL '
    'next, só com o token nos pedidos (AC-1, D-10)',
    (tester) async {
      final pilha = await abrirAcervo(tester);

      final primeiro = itensDa('acervo_p1.json').first['codigo']! as String;
      final ultimoDaP2 = itensDa('acervo_p2.json').last['codigo']! as String;
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Meu acervo'),
        ),
        findsOneWidget,
      );
      expect(find.text(primeiro), findsOneWidget);
      expect(find.text(ultimoDaP2), findsNothing);

      await rolarAte(tester, ultimoDaP2);

      expect(find.text(ultimoDaP2), findsOneWidget);
      final paginas = pilha.api.requisicoes
          .where((u) => u.path == '/api/imoveis/')
          .map((u) => u.queryParameters['page'])
          .toList();
      expect(paginas, [null, '2']);
      final p1 = lerFixtureApi('acervo_p1.json')! as Map<String, Object?>;
      expect(
        pilha.api.requisicoes
            .where((u) => u.path == '/api/imoveis/')
            .last
            .toString(),
        p1['next'],
      );
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );

  testWidgets(
    'buscar DEV-CAMPINAS-14 e esperar o debounce mostra só o cartão do '
    'Barão Geraldo (D-08)',
    (tester) async {
      final pilha = await abrirAcervo(tester);

      await tester.enterText(find.byType(SearchBar), 'DEV-CAMPINAS-14');
      await tester.pump(const Duration(milliseconds: 400));
      await assentar(tester);

      final busca = itensDa('acervo_busca.json').single;
      expect(find.byType(CartaoImovelAcervo), findsOneWidget);
      expect(find.text(busca['titulo']! as String), findsOneWidget);
      expect(find.text('Apartamento no bairro Barão Geraldo'), findsOneWidget);
      final consulta = pilha.api.requisicoes
          .where((u) => u.path == '/api/imoveis/')
          .last;
      expect(consulta.queryParameters['busca'], 'DEV-CAMPINAS-14');
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );

  testWidgets(
    'o chip "Vendido" mostra "Nenhum imóvel encontrado para esta busca ou '
    'situação." (D-09)',
    (tester) async {
      final pilha = await abrirAcervo(tester);

      // A linha de chips rola na horizontal: "Vendido" começa fora da tela.
      final chipVendido = find.widgetWithText(ChoiceChip, 'Vendido');
      await tester.ensureVisible(chipVendido);
      await tester.pump();
      await tester.tap(chipVendido);
      await assentar(tester);

      expect(
        find.text('Nenhum imóvel encontrado para esta busca ou situação.'),
        findsOneWidget,
      );
      expect(find.byType(CartaoImovelAcervo), findsNothing);
      final consulta = pilha.api.requisicoes
          .where((u) => u.path == '/api/imoveis/')
          .last;
      expect(consulta.queryParameters['situacao'], 'VENDIDO');
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );

  /// Toca Sair, confirma no diálogo e deixa a rota voltar à vitrine.
  Future<void> sairConfirmando(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Sair'));
    await assentar(tester);
    expect(find.text('Sair da conta?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Sair'),
      ),
    );
    await assentar(tester);
  }

  testWidgets('Sair com confirmação volta à vitrine com "Entrar", esvazia o '
      'armazenamento e faz POST /api/auth/sair/ com o token (AC-2)', (
    tester,
  ) async {
    final pilha = await abrirAcervo(tester);

    await sairConfirmando(tester);

    expect(find.text('Campinas, SP'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Meu acervo'), findsNothing);
    expect(pilha.armazenamento.token, isNull);
    final sair = pilha.api.requisicoesGravadas.singleWhere(
      (p) => p.uri.path == '/api/auth/sair/',
    );
    expect(sair.metodo, 'POST');
    expect(sair.cabecalho('authorization'), 'Token $tokenDasFixtures');
    pilha.conferirCabecalhosDeAutorizacao();
  });

  testWidgets('Sair com o servidor respondendo 500 termina igual: vitrine com '
      '"Entrar" e armazenamento vazio (AC-2)', (tester) async {
    final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
    pilha.api.falharProximas('/api/auth/sair/', status: 500);
    await pilha.abrirApp(tester);
    await tester.tap(find.text('Meu acervo'));
    await assentar(tester);

    await sairConfirmando(tester);

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Meu acervo'), findsNothing);
    expect(pilha.armazenamento.token, isNull);
    expect(
      pilha.api.requisicoes.where((u) => u.path == '/api/auth/sair/'),
      hasLength(1),
    );
  });

  testWidgets(
    '401 no acervo leva ao login com "Sua sessão terminou. Entre de novo.", '
    'apaga o token e, ao voltar, o topo mostra "Entrar"',
    (tester) async {
      final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/',
        status: 401,
        fixture: 'erro_401.json',
      );
      await pilha.abrirApp(tester);
      expect(find.text('Meu acervo'), findsOneWidget);

      await tester.tap(find.text('Meu acervo'));
      await assentar(tester, quadros: 10);

      expect(find.text('Sua sessão terminou. Entre de novo.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
      expect(pilha.armazenamento.token, isNull);

      await tester.pageBack();
      await assentar(tester);

      expect(find.text('Campinas, SP'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Meu acervo'), findsNothing);
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );
}
