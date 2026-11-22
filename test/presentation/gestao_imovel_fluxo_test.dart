import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_screen.dart';

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
    expect(find.textContaining('desde '), findsOneWidget);

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
}

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
