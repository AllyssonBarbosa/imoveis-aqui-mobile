import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/presentation/acervo/widgets/cartao_imovel_acervo.dart';
import 'package:imoveis_aqui/presentation/area_gestor/apresentacao_area_gestor.dart';

import '../support/api_falsa.dart';
import '../support/pilha_real.dart';

/// Fluxos ponta a ponta da abertura e do login (AC-1, AC-3, AC-6, D-02, D-04,
/// D-B): a pilha REAL do app (DI de produção, Cubits, use cases, repositórios,
/// DataSources e `InterceptadorSessao`) sobre a `ApiFalsa` com o wire capturado
/// do Django. Só o `Dio` público, o `Dio` `'autenticado'` e o armazenamento do
/// token são trocados. Nada de `pumpAndSettle`: o indicador de progresso
/// mantém a animação de pé.
void main() {
  tearDown(() async {
    await getIt.reset();
  });

  /// Código do primeiro imóvel de uma página de acervo capturada.
  String codigoDoPrimeiro(String fixture) =>
      ((lerFixtureApi(fixture)! as Map<String, Object?>)['results']!
                  as List<Object?>)
              .cast<Map<String, Object?>>()
              .first['codigo']!
          as String;

  /// Entra pelo botão do topo, preenche e envia o formulário.
  Future<void> entrar(
    WidgetTester tester, {
    String email = 'corretor@exemplo.com',
    String senha = 'senha-de-teste',
  }) async {
    await tester.tap(find.text('Entrar'));
    await assentar(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), email);
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), senha);
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await assentar(tester);
  }

  test(
    'o DI de produção tem o Dio público e o Dio autenticado separados',
    () async {
      await PilhaReal.preparar();

      expect(
        getIt<Dio>(instanceName: 'autenticado'),
        isNot(same(getIt<Dio>())),
      );
    },
  );

  testWidgets(
    'abertura sem sessão: a vitrine aparece com "Entrar" e nenhum pedido vai '
    'a /api/auth/ nem a /api/imoveis/ (AC-6)',
    (tester) async {
      final pilha = await PilhaReal.preparar();

      await pilha.abrirApp(tester);

      expect(find.text('Campinas, SP'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Meu acervo'), findsNothing);
      final caminhos = pilha.api.requisicoes.map((uri) => uri.path).toList();
      expect(caminhos, isNotEmpty);
      expect(caminhos.where((c) => c.startsWith('/api/auth/')), isEmpty);
      expect(caminhos.where((c) => c == '/api/imoveis/'), isEmpty);
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );

  testWidgets(
    'corretor: Entrar, e-mail e senha levam a "Meu acervo" com os cartões da '
    'p1; o login vai sem Authorization, eu e acervo com o token, e o voltar '
    'mostra a vitrine com "Meu acervo" (AC-1, D-02)',
    (tester) async {
      final pilha = await PilhaReal.preparar();
      await pilha.abrirApp(tester);

      await entrar(tester);

      expect(find.text('Meu acervo'), findsOneWidget);
      expect(find.text(codigoDoPrimeiro('acervo_p1.json')), findsOneWidget);
      expect(find.byType(CartaoImovelAcervo), findsWidgets);
      expect(pilha.armazenamento.token, tokenDasFixtures);

      final pedidos = pilha.api.requisicoesGravadas;
      final login = pedidos.singleWhere(
        (p) => p.uri.path == '/api/auth/login/',
      );
      expect(login.metodo, 'POST');
      expect(login.cabecalho('authorization'), isNull);
      final eu = pedidos.firstWhere((p) => p.uri.path == '/api/auth/eu/');
      expect(eu.cabecalho('authorization'), 'Token $tokenDasFixtures');
      final acervo = pedidos.firstWhere((p) => p.uri.path == '/api/imoveis/');
      expect(acervo.cabecalho('authorization'), 'Token $tokenDasFixtures');

      await tester.pageBack();
      await assentar(tester);

      expect(find.text('Campinas, SP'), findsOneWidget);
      expect(find.text('Meu acervo'), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );

  testWidgets('depois do login, as rotas públicas da vitrine continuam sem '
      'Authorization (T-08-45)', (tester) async {
    final pilha = await PilhaReal.preparar();
    await pilha.abrirApp(tester);
    await entrar(tester);
    await tester.pageBack();
    await assentar(tester);
    final antes = pilha.api.requisicoesGravadas.length;

    // Uma consulta nova da vitrine, já com sessão.
    await tester.enterText(find.byType(SearchBar), 'Cambuí');
    await tester.pump(const Duration(milliseconds: 400));
    await assentar(tester);

    final novos = pilha.api.requisicoesGravadas.skip(antes).toList();
    expect(
      novos.where((p) => p.uri.path.startsWith('/api/publico/')),
      isNotEmpty,
    );
    pilha.conferirCabecalhosDeAutorizacao();
  });

  testWidgets(
    'gestor: depois do login cai na Área do gestor, com as 4 seções, e nenhum '
    'pedido vai a /api/imoveis/ (D-01)',
    (tester) async {
      final pilha = await PilhaReal.preparar();
      pilha.api.responder(
        (uri) => uri.path == '/api/auth/eu/',
        status: 200,
        fixture: 'eu_gestor.json',
      );
      await pilha.abrirApp(tester);

      await entrar(tester);

      expect(find.text(tituloAreaGestor), findsOneWidget);
      expect(find.text(tituloSecaoTotais), findsOneWidget);
      expect(find.text(tituloSecaoAcervo), findsOneWidget);
      expect(find.text(tituloSecaoContatos), findsOneWidget);
      expect(find.text(tituloSecaoMudancas(7)), findsOneWidget);
      expect(pilha.api.requisicoesDosRelatorios.map((u) => u.path).toSet(), {
        '/api/relatorios/acervo/',
        '/api/relatorios/acervo-por-corretor/',
        '/api/relatorios/contatos/',
        '/api/relatorios/mudancas-situacao/',
      });
      expect(
        pilha.api.requisicoes.where((u) => u.path == '/api/imoveis/'),
        isEmpty,
      );
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );

  testWidgets(
    'login com 400 mostra "E-mail ou senha inválidos." e não guarda token '
    '(AC-3)',
    (tester) async {
      final pilha = await PilhaReal.preparar();
      pilha.api.responder(
        (uri) => uri.path == '/api/auth/login/',
        status: 400,
        fixture: 'erro_400_login.json',
      );
      await pilha.abrirApp(tester);

      await entrar(tester, senha: 'senha-errada');

      expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
      expect(pilha.armazenamento.token, isNull);
      expect(find.text('Meu acervo'), findsNothing);
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );

  testWidgets(
    '429 com Retry-After: 120 mostra "Muitas tentativas. Tente de novo em 2 '
    'minutos." (D-04)',
    (tester) async {
      final pilha = await PilhaReal.preparar();
      pilha.api.responder(
        (uri) => uri.path == '/api/auth/login/',
        status: 429,
        cabecalhos: {
          'retry-after': ['120'],
        },
      );
      await pilha.abrirApp(tester);

      await entrar(tester);

      expect(
        find.text('Muitas tentativas. Tente de novo em 2 minutos.'),
        findsOneWidget,
      );
      expect(pilha.armazenamento.token, isNull);
    },
  );
}
