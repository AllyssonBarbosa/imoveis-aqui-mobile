import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/widgets/secao_situacao.dart';

import '../support/api_falsa.dart';
import '../support/pilha_real.dart';

/// Fluxo ponta a ponta da gestão do imóvel (SIT-07, D-01, D-02): pela pilha
/// REAL do app (cartão → abridor → Cubit → UseCase → Repository → DataSource
/// no `Dio` autenticado) sobre a `ApiFalsa` com o wire capturado do Django.
/// Nada de `pumpAndSettle` (o indicador de progresso mantém a animação de pé).
void main() {
  tearDown(() async {
    await getIt.reset();
  });

  final gestao =
      lerFixtureApi('imovel_gestao_disponivel.json')! as Map<String, Object?>;
  final codigo = gestao['codigo']! as String;
  final titulo = gestao['titulo']! as String;
  final id = gestao['id']! as int;

  /// Abre o app com sessão guardada, entra em "Meu acervo" e toca no cartão
  /// do primeiro imóvel (`DEV-INDAIATUBA-04`, o primeiro de `acervo_p1.json`).
  Future<PilhaReal> abrirGestao(WidgetTester tester) async {
    final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
    await pilha.entrarNoAcervo(tester);
    await tester.tap(find.text(codigo));
    await assentar(tester);
    return pilha;
  }

  testWidgets('tocar no cartão do acervo abre a gestão com a situação vinda de '
      'GET /api/imoveis/{id}/, só com o token nos pedidos (SIT-07)', (
    tester,
  ) async {
    final pilha = await abrirGestao(tester);

    expect(find.byType(GestaoImovelScreen), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text(codigo)),
      findsOneWidget,
    );
    expect(find.text(titulo), findsOneWidget);
    expect(find.text('Disponível'), findsOneWidget);
    // "desde 22/11/2026 ..." (a situação); o vazio do histórico também diz
    // "desde o cadastro", por isso o padrão exige dígito logo após.
    expect(find.textContaining(RegExp(r'^desde \d')), findsOneWidget);

    final leituras = pilha.api.requisicoesGravadas.where(
      (p) => p.uri.path == '/api/imoveis/$id/',
    );
    expect(leituras, hasLength(1));
    expect(leituras.single.metodo, 'GET');
    expect(
      leituras.single.cabecalho('authorization'),
      'Token $tokenDasFixtures',
    );
    pilha.conferirCabecalhosDeAutorizacao();
  });

  testWidgets(
    'falha na primeira carga mostra o texto fixo e "Tentar de novo" repete o '
    'GET e recupera a tela',
    (tester) async {
      final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
      await pilha.entrarNoAcervo(tester);
      pilha.api.falharProximas('/api/imoveis/$id/', status: 500);

      await tester.tap(find.text(codigo));
      await assentar(tester);

      expect(find.text('Não foi possível carregar o imóvel.'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
      expect(find.text('Disponível'), findsNothing);

      await tester.tap(find.text('Tentar de novo'));
      await assentar(tester);

      expect(find.text('Não foi possível carregar o imóvel.'), findsNothing);
      expect(find.text(titulo), findsOneWidget);
      expect(find.text('Disponível'), findsOneWidget);
      final leituras = pilha.api.requisicoesGravadas.where(
        (p) => p.uri.path == '/api/imoveis/$id/',
      );
      expect(leituras, hasLength(2));
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );

  testWidgets(
    'tocar em um cartão que o servidor diz não estar na vitrine também abre '
    'a gestão (D-02)',
    (tester) async {
      final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/' && uri.queryParameters.isEmpty,
        status: 200,
        corpo: _acervoSemVitrine(),
      );
      await pilha.entrarNoAcervo(tester);

      await tester.tap(find.text(codigo));
      await assentar(tester);

      expect(find.byType(GestaoImovelScreen), findsOneWidget);
      expect(find.text('Disponível'), findsOneWidget);
      pilha.conferirCabecalhosDeAutorizacao();
    },
  );

  testWidgets('a gestão mostra o histórico: vazio na pilha padrão e, com a '
      'mudança servida pelo wire, "Disponível → Reservado" com a observação '
      '(SIT-03)', (tester) async {
    // Tela de celular: com a foto 16:9 na largura padrão do teste o histórico
    // ficaria abaixo da área visível.
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final pilha = await abrirGestao(tester);

    expect(find.text('Histórico'), findsOneWidget);
    expect(
      find.text('Nenhuma mudança ainda — disponível desde o cadastro.'),
      findsOneWidget,
    );
    final leituras = pilha.api.requisicoesGravadas.where(
      (p) => p.uri.path == '/api/imoveis/$id/historico/',
    );
    expect(leituras, hasLength(1));
    pilha.conferirCabecalhosDeAutorizacao();
  });

  testWidgets('histórico com uma mudança do servidor aparece com de → para, '
      'quando, quem e a observação da captura', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
    pilha.api.responder(
      (uri) => uri.path == '/api/imoveis/$id/historico/',
      status: 200,
      fixture: 'historico_um_item.json',
    );
    await pilha.entrarNoAcervo(tester);
    await tester.tap(find.text(codigo));
    await assentar(tester);

    expect(find.text('Disponível → Reservado'), findsOneWidget);
    expect(find.text('Reservado na conversa com o cliente.'), findsOneWidget);
    expect(find.textContaining(' · Corretor Vitrine Demo'), findsOneWidget);
    expect(
      find.text('Nenhuma mudança ainda — disponível desde o cadastro.'),
      findsNothing,
    );
    pilha.conferirCabecalhosDeAutorizacao();
  });

  testWidgets('falha só do histórico mantém o imóvel na tela e "Tentar de '
      'novo" repete só o histórico', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
    await pilha.entrarNoAcervo(tester);
    pilha.api.falharProximas('/api/imoveis/$id/historico/', status: 500);

    await tester.tap(find.text(codigo));
    await assentar(tester);

    expect(find.text(titulo), findsOneWidget);
    expect(find.text('Disponível'), findsOneWidget);
    expect(find.text('Não foi possível carregar o histórico.'), findsOneWidget);
    expect(find.text('Não foi possível carregar o imóvel.'), findsNothing);

    await tester.tap(find.text('Tentar de novo'));
    await assentar(tester);

    expect(find.text('Não foi possível carregar o histórico.'), findsNothing);
    expect(
      find.text('Nenhuma mudança ainda — disponível desde o cadastro.'),
      findsOneWidget,
    );
    final lidosDoImovel = pilha.api.requisicoesGravadas.where(
      (p) => p.uri.path == '/api/imoveis/$id/',
    );
    final lidosDoHistorico = pilha.api.requisicoesGravadas.where(
      (p) => p.uri.path == '/api/imoveis/$id/historico/',
    );
    expect(lidosDoImovel, hasLength(1));
    expect(lidosDoHistorico, hasLength(2));
    pilha.conferirCabecalhosDeAutorizacao();
  });

  testWidgets(
    '401 na leitura do imóvel leva ao login com "Sua sessão terminou. '
    'Entre de novo." e apaga o token (D-10, T-09-08)',
    (tester) async {
      final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
      await pilha.entrarNoAcervo(tester);
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/',
        status: 401,
        fixture: 'erro_401.json',
      );

      await tester.tap(find.text(codigo));
      await assentar(tester, quadros: 12);
      expect(find.text('Sua sessão terminou. Entre de novo.'), findsOneWidget);
      expect(find.byType(GestaoImovelScreen), findsNothing);
      expect(pilha.armazenamento.token, isNull);
    },
  );

  testWidgets('401 só na leitura do histórico também leva ao login e apaga o '
      'token', (tester) async {
    final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
    await pilha.entrarNoAcervo(tester);
    pilha.api.responder(
      (uri) => uri.path == '/api/imoveis/$id/historico/',
      status: 401,
      fixture: 'erro_401.json',
    );

    await tester.tap(find.text(codigo));
    await assentar(tester, quadros: 12);

    expect(find.text('Sua sessão terminou. Entre de novo.'), findsOneWidget);
    expect(pilha.armazenamento.token, isNull);
  });

  testWidgets('404 na leitura do imóvel mostra o texto fixo em português e '
      'nenhum texto em inglês (D-10, T-09-05)', (tester) async {
    final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
    await pilha.entrarNoAcervo(tester);
    pilha.api.responder(
      (uri) => uri.path == '/api/imoveis/$id/',
      status: 404,
      fixture: 'erro_404_imovel.json',
    );

    await tester.tap(find.text(codigo));
    await assentar(tester);

    expect(
      find.text('Este imóvel não está mais no seu acervo.'),
      findsOneWidget,
    );
    expect(find.text('Tentar de novo'), findsNothing);
    expect(find.textContaining('No Imovel'), findsNothing);
    expect(find.textContaining('Not found'), findsNothing);
    expect(pilha.armazenamento.token, tokenDasFixtures);
  });

  group('mudar a situação ponta a ponta (SIT-01, SIT-02, SIT-06, SIT-07)', () {
    testWidgets('"Mudar situação" → chip "Reservado" → "Confirmar": POST com '
        'situacao RESERVADO e token, folha fecha, SnackBar do site, releitura '
        'de imóvel e histórico e a tela mostra a situação lida da API; '
        '"Ver na vitrine" some (D-04, D-10, D-18)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);
      expect(find.text('Ver na vitrine'), findsOneWidget);
      expect(find.text('Disponível'), findsOneWidget);

      await tester.tap(find.text('Mudar situação'));
      await assentar(tester);
      // A atual está desabilitada e o Confirmar só vale com outra escolha.
      expect(
        tester
            .widget<ChoiceChip>(
              find.byKey(const ValueKey('chip-mudar-disponivel')),
            )
            .onSelected,
        isNull,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Confirmar'),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Confirmar'),
            )
            .onPressed,
        isNotNull,
      );

      // O servidor "já mudou": as próximas leituras devolvem a situação nova.
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/',
        status: 200,
        fixture: 'imovel_gestao_reservado.json',
      );
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/historico/',
        status: 200,
        fixture: 'historico_um_item.json',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await assentar(tester, quadros: 12);

      final gravadas = pilha.api.requisicoesGravadas;
      final posicaoDoPost = gravadas.indexWhere((p) => p.metodo == 'POST');
      expect(posicaoDoPost, greaterThan(-1));
      final post = gravadas[posicaoDoPost];
      expect(post.uri.path, '/api/imoveis/$id/situacao/');
      expect(post.cabecalho('authorization'), 'Token $tokenDasFixtures');
      expect(
        pilha.api.chamadas.where((c) => c.metodo == 'POST').single.corpo,
        <String, Object?>{'situacao': 'RESERVADO'},
      );
      // Depois do POST: nova leitura do imóvel e do histórico.
      final depois = gravadas.skip(posicaoDoPost + 1).toList();
      expect(
        depois.where(
          (p) => p.metodo == 'GET' && p.uri.path == '/api/imoveis/$id/',
        ),
        hasLength(1),
      );
      expect(
        depois.where(
          (p) =>
              p.metodo == 'GET' && p.uri.path == '/api/imoveis/$id/historico/',
        ),
        hasLength(1),
      );

      // A folha fechou, o aviso é o do site e a tela mostra o que a API leu.
      expect(find.text('Confirmar'), findsNothing);
      expect(find.text('Situação alterada para reservado.'), findsOneWidget);
      expect(find.text('Reservado'), findsOneWidget);
      expect(find.text('Disponível'), findsNothing);
      expect(find.text('Disponível → Reservado'), findsOneWidget);
      expect(find.text('Ver na vitrine'), findsNothing);
      pilha.conferirCabecalhosDeAutorizacao();
    });

    testWidgets('a observação digitada vai no corpo do POST e, depois da '
        'releitura, aparece no histórico (D-10, AC-1)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);

      await tester.tap(find.text('Mudar situação'));
      await assentar(tester);
      expect(find.text('Observação (opcional)'), findsOneWidget);
      expect(find.text('Data: hoje'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.enterText(
        find.byType(TextField),
        'Reservado na conversa com o cliente.',
      );
      await tester.pump();

      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/',
        status: 200,
        fixture: 'imovel_gestao_reservado.json',
      );
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/historico/',
        status: 200,
        fixture: 'historico_um_item.json',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await assentar(tester, quadros: 12);

      // O app não manda data nem autor: só a situação e a observação (D-05).
      expect(
        pilha.api.chamadas.where((c) => c.metodo == 'POST').single.corpo,
        <String, Object?>{
          'situacao': 'RESERVADO',
          'observacao': 'Reservado na conversa com o cliente.',
        },
      );
      expect(find.text('Confirmar'), findsNothing);
      expect(find.text('Disponível → Reservado'), findsOneWidget);
      expect(find.text('Reservado na conversa com o cliente.'), findsOneWidget);
      pilha.conferirCabecalhosDeAutorizacao();
    });

    testWidgets('toque duplo no Confirmar manda um POST só (T-09-07)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);

      await tester.tap(find.text('Mudar situação'));
      await assentar(tester);
      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      final confirmar = find.widgetWithText(FilledButton, 'Confirmar');
      await tester.tap(confirmar);
      await tester.tap(confirmar, warnIfMissed: false);
      await assentar(tester, quadros: 12);

      expect(pilha.api.chamadas.where((c) => c.metodo == 'POST'), hasLength(1));
    });

    testWidgets('contrato assinado (400): a folha continua aberta com o texto '
        'do servidor e a observação; a tela segue "Disponível" e nada é '
        'relido depois do POST (D-10, AC-4, T-09-03)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/situacao/',
        status: 400,
        fixture: 'erro_400_contrato_assinado.json',
      );

      await tester.tap(find.text('Mudar situação'));
      await assentar(tester);
      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Sinal pago');
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await assentar(tester, quadros: 12);

      expect(
        find.textContaining('Este imóvel tem um contrato assinado (#1)'),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Sinal pago',
      );
      expect(find.text('Situação alterada para reservado.'), findsNothing);
      // Atrás da folha a tela continua com a situação anterior.
      expect(_situacaoNaTela('Disponível'), findsOneWidget);
      expect(_situacaoNaTela('Reservado'), findsNothing);
      final gravadas = pilha.api.requisicoesGravadas;
      final posicaoDoPost = gravadas.indexWhere((p) => p.metodo == 'POST');
      expect(posicaoDoPost, greaterThan(-1));
      expect(
        gravadas.skip(posicaoDoPost + 1),
        isEmpty,
        reason: 'nenhuma releitura de imóvel nem de histórico depois do POST',
      );
    });

    testWidgets('quem força a mudança (403): a folha mostra "Só o corretor '
        'responsável…", não fecha e não troca a situação da tela (SIT-06, '
        'AC-6, T-09-01)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/situacao/',
        status: 403,
        fixture: 'erro_403_situacao.json',
      );

      await tester.tap(find.text('Mudar situação'));
      await assentar(tester);
      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await assentar(tester, quadros: 12);

      expect(
        find.textContaining('Só o corretor responsável por este imóvel'),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.text('Situação alterada para reservado.'), findsNothing);
      expect(_situacaoNaTela('Disponível'), findsOneWidget);
      // Só a leitura inicial: nada foi relido depois da recusa.
      expect(
        pilha.api.requisicoesGravadas.where(
          (p) => p.metodo == 'GET' && p.uri.path == '/api/imoveis/$id/',
        ),
        hasLength(1),
      );
      expect(
        pilha.api.requisicoesGravadas.where(
          (p) =>
              p.metodo == 'GET' && p.uri.path == '/api/imoveis/$id/historico/',
        ),
        hasLength(1),
      );
    });

    testWidgets('falha 5xx no envio: texto fixo na folha; tocar Confirmar de '
        'novo faz um segundo POST (do corretor, não automático) e, com 200, '
        'fecha a folha (D-10, Pitfall 4)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);
      pilha.api.falharProximas('/api/imoveis/$id/situacao/', status: 500);

      await tester.tap(find.text('Mudar situação'));
      await assentar(tester);
      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await assentar(tester, quadros: 12);

      expect(
        find.text('Não foi possível mudar a situação agora. Tente de novo.'),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsOneWidget);
      // Sem reenvio automático: um POST só até aqui.
      expect(pilha.api.chamadas.where((c) => c.metodo == 'POST'), hasLength(1));
      expect(_situacaoNaTela('Disponível'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await assentar(tester, quadros: 12);

      expect(pilha.api.chamadas.where((c) => c.metodo == 'POST'), hasLength(2));
      expect(find.text('Confirmar'), findsNothing);
      expect(find.text('Situação alterada para reservado.'), findsOneWidget);
    });

    testWidgets('404 no envio: a folha mostra o texto fixo em português e o '
        'texto em inglês do servidor não aparece (D-10, T-09-05)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/situacao/',
        status: 404,
        fixture: 'erro_404_imovel.json',
      );

      await tester.tap(find.text('Mudar situação'));
      await assentar(tester);
      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await assentar(tester, quadros: 12);

      expect(
        find.text('Este imóvel não está mais no seu acervo.'),
        findsOneWidget,
      );
      expect(find.textContaining('No Imovel'), findsNothing);
      expect(find.textContaining('matches the given query'), findsNothing);
      expect(pilha.armazenamento.token, tokenDasFixtures);
    });

    testWidgets('401 no envio leva ao login com "Sua sessão terminou. Entre '
        'de novo." e apaga o token (D-10, T-09-08)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/situacao/',
        status: 401,
        fixture: 'erro_401.json',
      );

      await tester.tap(find.text('Mudar situação'));
      await assentar(tester);
      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await assentar(tester, quadros: 12);

      expect(find.text('Sua sessão terminou. Entre de novo.'), findsOneWidget);
      expect(find.byType(GestaoImovelScreen), findsNothing);
      expect(find.text('Confirmar'), findsNothing);
      expect(pilha.armazenamento.token, isNull);
    });

    testWidgets('colega (pode_mudar_situacao falso): sem "Mudar situação" e '
        'com o histórico à vista (SIT-06, AC-6)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/' && uri.queryParameters.isEmpty,
        status: 200,
        corpo: _acervoSoDoColega(),
      );
      await pilha.entrarNoAcervo(tester);

      await tester.tap(find.text('DEV-CAMPINAS-14'));
      await assentar(tester);

      expect(find.byType(GestaoImovelScreen), findsOneWidget);
      expect(find.text('Situação'), findsOneWidget);
      expect(find.text('Mudar situação'), findsNothing);
      expect(find.text('Histórico'), findsOneWidget);
      pilha.conferirCabecalhosDeAutorizacao();
    });
  });

  group('volta ao acervo depois da gestão (D-12, SIT-05, AC-2, AC-5)', () {
    /// GETs da lista do acervo (`/api/imoveis/` exato) até agora.
    Iterable<RequisicaoGravada> listasLidas(PilhaReal pilha) => pilha
        .api
        .requisicoesGravadas
        .where((p) => p.metodo == 'GET' && p.uri.path == '/api/imoveis/');

    /// Reserva o imóvel pela folha e deixa a tela relida (o servidor "já
    /// mudou" para o detalhe e o histórico).
    Future<void> reservar(WidgetTester tester, PilhaReal pilha) async {
      await tester.tap(find.text('Mudar situação'));
      await assentar(tester);
      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/',
        status: 200,
        fixture: 'imovel_gestao_reservado.json',
      );
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/$id/historico/',
        status: 200,
        fixture: 'historico_um_item.json',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await assentar(tester, quadros: 12);
      expect(find.text('Situação alterada para reservado.'), findsOneWidget);
    }

    testWidgets('mudou e voltou pela AppBar: novo GET /api/imoveis/ sem page e '
        'o cartão mostra "Reservado" vindo do corpo do servidor', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);
      expect(listasLidas(pilha), hasLength(1));
      await reservar(tester, pilha);

      // O servidor passa a listar o imóvel como reservado.
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/' && uri.queryParameters.isEmpty,
        status: 200,
        corpo: _acervoComReservado(id),
      );
      await tester.tap(find.byType(BackButton));
      await assentar(tester, quadros: 12);

      expect(find.byType(GestaoImovelScreen), findsNothing);
      final listas = listasLidas(pilha).toList();
      expect(listas, hasLength(2));
      expect(listas.last.uri.queryParameters.containsKey('page'), isFalse);
      expect(find.text(codigo), findsOneWidget);
      expect(_chipDoCartao(id, 'Reservado'), findsOneWidget);
      pilha.conferirCabecalhosDeAutorizacao();
    });

    testWidgets('mudou e voltou pelo botão do sistema (handlePopRoute): o '
        'acervo também recarrega (A4)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);
      await reservar(tester, pilha);
      pilha.api.responder(
        (uri) => uri.path == '/api/imoveis/' && uri.queryParameters.isEmpty,
        status: 200,
        corpo: _acervoComReservado(id),
      );

      await tester.binding.handlePopRoute();
      await assentar(tester, quadros: 12);

      expect(find.byType(GestaoImovelScreen), findsNothing);
      expect(listasLidas(pilha), hasLength(2));
      expect(_chipDoCartao(id, 'Reservado'), findsOneWidget);
      pilha.conferirCabecalhosDeAutorizacao();
    });

    testWidgets('abrir a gestão e voltar sem mudar não gera nenhum GET '
        '/api/imoveis/ novo', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final pilha = await abrirGestao(tester);
      expect(listasLidas(pilha), hasLength(1));

      await tester.tap(find.byType(BackButton));
      await assentar(tester, quadros: 12);

      expect(find.byType(GestaoImovelScreen), findsNothing);
      expect(find.text(codigo), findsOneWidget);
      expect(listasLidas(pilha), hasLength(1));
      pilha.conferirCabecalhosDeAutorizacao();
    });
  });
}

/// O chip de situação do cartão do acervo [idImovel] — escopado ao cartão para
/// não confundir com o chip de filtro "Reservado" da barra do acervo.
Finder _chipDoCartao(int idImovel, String rotulo) => find.descendant(
  of: find.byKey(ValueKey('imovel-acervo-$idImovel')),
  matching: find.text(rotulo),
);

/// A situação que a TELA mostra (seção "Situação"), sem confundir com o chip
/// "Disponível" da folha aberta por cima.
Finder _situacaoNaTela(String rotulo) => find.descendant(
  of: find.byType(SecaoSituacao),
  matching: find.text(rotulo),
);

/// `acervo_p1.json` com `na_vitrine` falso em todos os itens e sem próxima
/// página — o servidor é quem decide a vitrine; aqui só trocamos o wire.
Map<String, Object?> _acervoSemVitrine() {
  final p1 = lerFixtureApi('acervo_p1.json')! as Map<String, Object?>;
  final itens = (p1['results']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .map((item) => <String, Object?>{...item, 'na_vitrine': false})
      .toList();
  return <String, Object?>{...p1, 'next': null, 'results': itens};
}

/// `acervo_p2.json` só com o imóvel de um colega (`DEV-CAMPINAS-14`,
/// `meu_imovel` falso) e sem próxima página.
Map<String, Object?> _acervoSoDoColega() {
  final p2 = lerFixtureApi('acervo_p2.json')! as Map<String, Object?>;
  final itens = (p2['results']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .where((item) => item['codigo'] == 'DEV-CAMPINAS-14')
      .toList();
  return <String, Object?>{...p2, 'next': null, 'count': 1, 'results': itens};
}

/// `acervo_p1.json` com o imóvel [idImovel] em `RESERVADO` e sem próxima
/// página: cópia em memória do wire capturado, como o servidor listaria o
/// acervo depois da mudança.
Map<String, Object?> _acervoComReservado(int idImovel) {
  final p1 = lerFixtureApi('acervo_p1.json')! as Map<String, Object?>;
  final itens = (p1['results']! as List<Object?>)
      .cast<Map<String, Object?>>()
      .map(
        (item) => item['id'] == idImovel
            ? <String, Object?>{...item, 'situacao': 'RESERVADO'}
            : item,
      )
      .toList();
  return <String, Object?>{...p1, 'next': null, 'results': itens};
}
