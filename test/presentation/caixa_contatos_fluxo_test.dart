import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:intl/intl.dart';

import '../support/api_falsa.dart';
import '../support/pilha_real.dart';

/// Fluxos ponta a ponta da caixa "Meus contatos" (CXA-01, CXA-05, CXA-06,
/// D-01, D-06, D-12, D-23): pela pilha REAL do app (DI de produção) sobre a
/// `ApiFalsa` com o wire capturado, com o token já guardado no aparelho. A
/// entrada é o ícone "Meus contatos" da `AppBar` do acervo, como o usuário
/// faz. Os valores esperados saem das fixtures, nunca escritos à mão. Nada de
/// `pumpAndSettle` (o indicador de progresso mantém a animação de pé).
///
/// O 10-09 acrescenta o filtro e o 10-10 a anotação neste mesmo arquivo.
void main() {
  tearDown(() async {
    await getIt.reset();
  });

  List<Map<String, Object?>> contatosDa(String fixture) =>
      ((lerFixtureApi(fixture)! as Map<String, Object?>)['results']!
              as List<Object?>)
          .cast<Map<String, Object?>>();

  /// "código — título" como a lista mostra (travessão com espaços).
  String rotuloDe(Map<String, Object?> contato) =>
      '${contato['imovel_codigo']} — ${contato['imovel_titulo']}';

  /// A chave de cada item da lista (id do contato, único entre as páginas).
  Finder itemDoContato(Map<String, Object?> contato) =>
      find.byKey(ValueKey('contato-${contato['id']}'));

  /// Abre o app com sessão guardada e entra em "Meu acervo" pelo topo.
  Future<PilhaReal> abrirAcervo(
    WidgetTester tester, {
    PilhaReal? pilhaPronta,
  }) async {
    final pilha =
        pilhaPronta ?? await PilhaReal.preparar(token: tokenDasFixtures);
    await pilha.abrirApp(tester);
    expect(find.text('Meu acervo'), findsOneWidget);
    await tester.tap(find.text('Meu acervo'));
    // Entrada pergunta o papel e se substitui pelo acervo (duas transições).
    await assentar(tester, quadros: 12);
    return pilha;
  }

  /// Toca o ícone "Meus contatos" do acervo e deixa a caixa carregar.
  Future<void> abrirCaixa(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Meus contatos'));
    await assentar(tester, quadros: 10);
  }

  /// Rola a lista da caixa para baixo até [alvo] aparecer (a próxima página
  /// vem do servidor pela URL `next`).
  Future<void> rolarAte(WidgetTester tester, Finder alvo) async {
    var tentativas = 0;
    while (alvo.evaluate().isEmpty && tentativas < 60) {
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      tentativas++;
    }
  }

  group('Caixa de contatos ponta a ponta', () {
    testWidgets(
      'acervo -> ícone "Meus contatos" mostra o primeiro contato e o número '
      'do servidor; voltar retorna ao "Meu acervo" (CXA-01, CXA-05, D-01)',
      (tester) async {
        final pilha = await abrirAcervo(tester);

        await abrirCaixa(tester);

        final primeiro = contatosDa('contatos_p1.json').first;
        final semRetorno =
            (lerFixtureApi('contatos_resumo.json')!
                    as Map<String, Object?>)['sem_retorno']!
                as int;
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Meus contatos'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: itemDoContato(primeiro),
            matching: find.text(rotuloDe(primeiro)),
          ),
          findsOneWidget,
        );
        expect(find.text('$semRetorno contatos sem retorno'), findsOneWidget);
        pilha.conferirCabecalhosDeAutorizacao();

        await tester.pageBack();
        await assentar(tester);

        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Meu acervo'),
          ),
          findsOneWidget,
        );
        expect(find.text('Meus contatos'), findsNothing);
      },
    );

    testWidgets(
      'rolar até o fim pede a página 2 pela URL next e mostra o último '
      'contato dela (D-12)',
      (tester) async {
        final pilha = await abrirAcervo(tester);
        await abrirCaixa(tester);

        final ultimoDaP2 = contatosDa('contatos_p2.json').last;
        expect(itemDoContato(ultimoDaP2), findsNothing);

        await rolarAte(tester, itemDoContato(ultimoDaP2));

        expect(itemDoContato(ultimoDaP2), findsOneWidget);
        final paginas = pilha.api.requisicoes
            .where((u) => u.path == '/api/contatos/')
            .map((u) => u.queryParameters['page'])
            .toList();
        expect(paginas, [null, '2']);
        final p1 = lerFixtureApi('contatos_p1.json')! as Map<String, Object?>;
        expect(
          pilha.api.requisicoes
              .where((u) => u.path == '/api/contatos/')
              .last
              .toString(),
          p1['next'],
        );
        // O número do servidor segue o mesmo depois da paginação (D-06).
        expect(find.textContaining('contatos sem retorno'), findsOneWidget);
        pilha.conferirCabecalhosDeAutorizacao();
      },
    );

    testWidgets(
      '401 na lista leva ao login com "Sua sessão terminou. Entre de novo.", '
      'apaga o token e, ao voltar, o topo mostra "Entrar" (D-23)',
      (tester) async {
        final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
        await abrirAcervo(tester, pilhaPronta: pilha);
        // O acervo carregou com o token; só a caixa passa a responder 401.
        pilha.api.responder(
          (uri) => uri.path == '/api/contatos/',
          status: 401,
          fixture: 'erro_401.json',
        );

        await abrirCaixa(tester);

        expect(
          find.text('Sua sessão terminou. Entre de novo.'),
          findsOneWidget,
        );
        expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
        expect(pilha.armazenamento.token, isNull);

        await tester.pageBack();
        await assentar(tester);

        expect(find.text('Campinas, SP'), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('Meu acervo'), findsNothing);
        expect(find.text('Meus contatos'), findsNothing);
      },
    );

    testWidgets(
      'toda requisição da caixa leva Authorization: Token <token>, na lista, '
      'na contagem e na página seguinte',
      (tester) async {
        final pilha = await abrirAcervo(tester);
        await abrirCaixa(tester);
        await rolarAte(
          tester,
          itemDoContato(contatosDa('contatos_p2.json').last),
        );

        final daCaixa = pilha.api.requisicoesGravadas
            .where((p) => p.uri.path.startsWith('/api/contatos/'))
            .toList();
        expect(
          daCaixa.map((p) => p.uri.path).toSet(),
          containsAll(<String>['/api/contatos/', '/api/contatos/resumo/']),
        );
        expect(daCaixa.length, greaterThanOrEqualTo(3)); // lista, p2, resumo
        for (final pedido in daCaixa) {
          expect(
            pedido.cabecalho('authorization'),
            'Token $tokenDasFixtures',
            reason: '${pedido.metodo} ${pedido.uri} deveria levar o token',
          );
          expect(pedido.metodo, 'GET');
        }
      },
    );

    testWidgets(
      'chip "Imóvel" -> folha com as opções do servidor -> escolher manda '
      '?imovel=<id>, mostra os itens do servidor e não pede o resumo de novo '
      '(CXA-02, D-05, D-19)',
      (tester) async {
        final pilha = await abrirAcervo(tester);
        await abrirCaixa(tester);
        final resumosAntes = pilha.api.requisicoes
            .where((u) => u.path == '/api/contatos/resumo/')
            .length;

        await tester.tap(find.widgetWithText(InputChip, 'Imóvel'));
        await assentar(tester, quadros: 10);

        final opcoes =
            (lerFixtureApi('contatos_imoveis.json')! as List<Object?>)
                .cast<Map<String, Object?>>();
        expect(find.text('Filtrar por imóvel'), findsOneWidget);
        expect(find.text('Todos os imóveis'), findsOneWidget);
        // A lista de baixo repete "código — título" nos itens: as opções são
        // procuradas só dentro da folha.
        Finder naFolha(Map<String, Object?> opcao) => find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('${opcao['codigo']} — ${opcao['titulo']}'),
        );
        for (final opcao in opcoes) {
          expect(naFolha(opcao), findsOneWidget);
        }

        final escolhida = opcoes.first;
        await tester.tap(naFolha(escolhida));
        await assentar(tester, quadros: 10);

        final pedidos = pilha.api.requisicoes
            .where((u) => u.path == '/api/contatos/')
            .toList();
        expect(pedidos.last.queryParameters['imovel'], '${escolhida['id']}');
        final primeiro = contatosDa('contatos_imovel.json').first;
        expect(itemDoContato(primeiro), findsOneWidget);
        expect(
          find.widgetWithText(InputChip, '${escolhida['codigo']}'),
          findsOneWidget,
        );
        expect(
          pilha.api.requisicoes
              .where((u) => u.path == '/api/contatos/resumo/')
              .length,
          resumosAntes,
        );
        pilha.conferirCabecalhosDeAutorizacao();
      },
    );

    testWidgets(
      'tocar o item -> "Falei" grava o PATCH, o item mostra o retorno do '
      'servidor e o número vem de novo do servidor (CXA-03, D-06, D-16)',
      (tester) async {
        final pilha = await abrirAcervo(tester);
        await abrirCaixa(tester);
        final anotado =
            lerFixtureApi('contato_patch_200.json')! as Map<String, Object?>;
        final item = contatosDa('contatos_p1.json')
            .firstWhere((contato) => contato['id'] == anotado['id']);
        final semRetornoAntes =
            (lerFixtureApi('contatos_resumo.json')!
                    as Map<String, Object?>)['sem_retorno']!
                as int;
        final semRetornoDepois =
            (lerFixtureApi('contatos_resumo_apos.json')!
                    as Map<String, Object?>)['sem_retorno']!
                as int;
        expect(
          find.text('$semRetornoAntes contatos sem retorno'),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: itemDoContato(item),
            matching: find.text('Aguardando retorno'),
          ),
          findsOneWidget,
        );
        final resumosAntes = pilha.api.requisicoes
            .where((u) => u.path == '/api/contatos/resumo/')
            .length;

        await tester.tap(itemDoContato(item));
        await assentar(tester, quadros: 10);
        expect(find.text('Anotar retorno'), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.text('Falei'),
          ),
        );
        await assentar(tester, quadros: 12);

        final patches = pilha.api.chamadas
            .where((chamada) => chamada.metodo == 'PATCH')
            .toList();
        expect(patches, hasLength(1));
        expect(patches.single.uri.path, '/api/contatos/${anotado['id']}/');
        expect(patches.single.corpo, {'retorno': 'FALEI'});
        final anotadoEm = DateTime.parse(anotado['retorno_em']! as String)
            .toLocal();
        expect(
          find.descendant(
            of: itemDoContato(item),
            matching: find.text('Falei'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: itemDoContato(item),
            matching: find.text(
              'anotado em ${DateFormat('dd/MM/yyyy HH:mm').format(anotadoEm)}',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: itemDoContato(item),
            matching: find.text('Aguardando retorno'),
          ),
          findsNothing,
        );
        expect(
          find.text('$semRetornoDepois contatos sem retorno'),
          findsOneWidget,
        );
        expect(
          pilha.api.requisicoes
              .where((u) => u.path == '/api/contatos/resumo/')
              .length,
          resumosAntes + 1,
        );
        expect(find.byType(SnackBar), findsNothing);
        pilha.conferirCabecalhosDeAutorizacao();
      },
    );

    testWidgets(
      '404 ao anotar mostra "Este contato não está mais na sua caixa." e '
      'pede de novo a lista (sem page) e o número (D-17)',
      (tester) async {
        final pilha = await abrirAcervo(tester);
        await abrirCaixa(tester);
        final idAceito =
            (lerFixtureApi('contato_patch_200.json')!
                    as Map<String, Object?>)['id']!
                as int;
        final outro = contatosDa('contatos_p1.json')
            .firstWhere((contato) => contato['id'] != idAceito);
        int pedidosDaLista() => pilha.api.requisicoes
            .where(
              (u) =>
                  u.path == '/api/contatos/' &&
                  !u.queryParameters.containsKey('page'),
            )
            .length;
        int pedidosDoResumo() => pilha.api.requisicoes
            .where((u) => u.path == '/api/contatos/resumo/')
            .length;
        final listasAntes = pedidosDaLista();
        final resumosAntes = pedidosDoResumo();

        await tester.tap(itemDoContato(outro));
        await assentar(tester, quadros: 10);
        await tester.tap(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.text('Descartado'),
          ),
        );
        await assentar(tester, quadros: 12);

        final patches = pilha.api.chamadas
            .where((chamada) => chamada.metodo == 'PATCH')
            .toList();
        expect(patches, hasLength(1));
        expect(patches.single.uri.path, '/api/contatos/${outro['id']}/');
        expect(patches.single.corpo, {'retorno': 'DESCARTADO'});
        expect(
          find.text('Este contato não está mais na sua caixa.'),
          findsOneWidget,
        );
        expect(pedidosDaLista(), listasAntes + 1);
        expect(pedidosDoResumo(), resumosAntes + 1);
        // O item segue como o servidor listou: nada foi anotado no aparelho.
        expect(
          find.descendant(
            of: itemDoContato(outro),
            matching: find.text('Aguardando retorno'),
          ),
          findsOneWidget,
        );
        pilha.conferirCabecalhosDeAutorizacao();
      },
    );
  });
}
