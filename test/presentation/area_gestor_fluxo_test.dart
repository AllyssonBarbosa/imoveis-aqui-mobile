import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/mudancas_recentes_model.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/presentation/acervo/widgets/cartao_imovel_acervo.dart';
import 'package:imoveis_aqui/presentation/area_gestor/apresentacao_area_gestor.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_cubit.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_screen.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_state.dart';
import 'package:imoveis_aqui/presentation/area_gestor/widgets/secao_contatos_corretores.dart';

import '../support/api_falsa.dart';
import '../support/pilha_real.dart';

/// Fluxos ponta a ponta da Área do gestor (GES-01..GES-06, D-01, D-03, D-04,
/// D-07, D-16, D-22, D-23, critério 5): a pilha REAL do app (DI de produção)
/// sobre a `ApiFalsa` com o wire capturado, com o token já guardado no
/// aparelho e o papel do gestor vindo de `/api/auth/eu/` (`eu_gestor.json`). A
/// entrada é o botão do topo da vitrine, como o usuário faz. Os valores
/// esperados saem das fixtures e dos textos de `apresentacao_area_gestor.dart`,
/// nunca escritos à mão. Nada de `pumpAndSettle` (o indicador de progresso
/// mantém a animação de pé).
void main() {
  tearDown(() async {
    await getIt.reset();
  });

  const caminhoTotais = '/api/relatorios/acervo/';
  const caminhoAcervo = '/api/relatorios/acervo-por-corretor/';
  const caminhoContatos = '/api/relatorios/contatos/';
  const caminhoMudancas = '/api/relatorios/mudancas-situacao/';

  Map<String, Object?> fixture(String nome) =>
      lerFixtureApi(nome)! as Map<String, Object?>;

  /// Linhas (`linhas`) de um relatório capturado.
  List<Map<String, Object?>> linhasDe(String nome) =>
      (fixture(nome)['linhas']! as List<Object?>).cast<Map<String, Object?>>();

  /// Vista alta: as 4 seções cabem sem rolar.
  void vistaAlta(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Abre o app como gestor (`eu_gestor.json`) e entra pelo botão do topo, que
  /// continua dizendo "Meu acervo" (D-04). [configurar] prepara as respostas
  /// da API antes de a tela abrir.
  Future<PilhaReal> abrirAreaDoGestor(
    WidgetTester tester, {
    void Function(ApiFalsa api)? configurar,
  }) async {
    final pilha = await PilhaReal.preparar(token: tokenDasFixtures);
    pilha.api.responder(
      (uri) => uri.path == '/api/auth/eu/',
      status: 200,
      fixture: 'eu_gestor.json',
    );
    configurar?.call(pilha.api);
    await pilha.abrirApp(tester);
    vistaAlta(tester);
    expect(find.text('Meu acervo'), findsOneWidget);
    await tester.tap(find.text('Meu acervo'));
    // A entrada pergunta o papel e se substitui pela área (duas transições).
    await assentar(tester, quadros: 12);
    return pilha;
  }

  /// O cartão da seção de título [titulo].
  Finder cartaoDaSecao(String titulo) =>
      find.ancestor(of: find.text(titulo), matching: find.byType(Card));

  /// Texto [texto] dentro do cartão da seção de título [titulo].
  Finder naSecao(String titulo, String texto) =>
      find.descendant(of: cartaoDaSecao(titulo), matching: find.text(texto));

  /// Pedidos já feitos a [caminho].
  int pedidosA(PilhaReal pilha, String caminho) =>
      pilha.api.requisicoesDosRelatorios.where((u) => u.path == caminho).length;

  group('Área do gestor ponta a ponta', () {
    testWidgets(
      'gestor: "Meu acervo" abre a Área do gestor, as 4 rotas são pedidas uma '
      'vez com o token, a tela mostra os números do servidor e o voltar leva '
      'à vitrine (D-01, D-04, critério 5)',
      (tester) async {
        final pilha = await abrirAreaDoGestor(tester);

        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(tituloAreaGestor),
          ),
          findsOneWidget,
        );
        // Cada relatório uma vez, e nenhum pedido ao acervo do corretor.
        expect(pilha.api.requisicoesDosRelatorios.map((u) => u.path).toList(), [
          caminhoTotais,
          caminhoAcervo,
          caminhoContatos,
          caminhoMudancas,
        ]);
        expect(
          pilha.api.requisicoes.where((u) => u.path == '/api/imoveis/'),
          isEmpty,
        );
        for (final pedido in pilha.api.requisicoesGravadas.where(
          (p) => p.uri.path.startsWith('/api/relatorios/'),
        )) {
          expect(
            pedido.cabecalho('authorization'),
            'Token $tokenDasFixtures',
            reason: '${pedido.metodo} ${pedido.uri} deveria levar o token',
          );
        }

        // 1. Totais da empresa: o total do servidor.
        final totalDoAcervo = fixture('relatorio_acervo.json')['total']! as int;
        expect(
          naSecao(tituloSecaoTotais, textoTotalImoveis(totalDoAcervo)),
          findsOneWidget,
        );

        // 2. Acervo por corretor: nome, "(desativado)" e "Nenhum imóvel".
        final corretores = linhasDe('relatorio_acervo_por_corretor.json');
        final desativado = corretores.firstWhere((c) => c['ativo'] == false);
        final semAcervo = corretores.firstWhere((c) => c['total'] == 0);
        expect(
          naSecao(
            tituloSecaoAcervo,
            nomeDoCorretor(desativado['corretor']! as String, ativo: false),
          ),
          findsOneWidget,
        );
        expect(
          naSecao(tituloSecaoAcervo, textoImoveisDoCorretor(0)),
          findsOneWidget,
        );
        expect(
          naSecao(tituloSecaoAcervo, semAcervo['corretor']! as String),
          findsOneWidget,
        );
        final totalPorCorretor =
            fixture('relatorio_acervo_por_corretor.json')['total']! as int;
        expect(
          naSecao(tituloSecaoAcervo, textoTotalImoveis(totalPorCorretor)),
          findsOneWidget,
        );

        // 3. Contatos por corretor: a linha da empresa e o total do servidor.
        final contatos = fixture('relatorio_contatos.json');
        expect(
          naSecao(tituloSecaoContatos, textoLinhaDaEmpresa),
          findsOneWidget,
        );
        expect(
          naSecao(
            tituloSecaoContatos,
            textoTotalContatos(
              contatos['total']! as int,
              contatos['pendentes']! as int,
            ),
          ),
          findsOneWidget,
        );
        expect(
          naSecao(tituloSecaoContatos, textoDoPeriodo(null)),
          findsOneWidget,
        );

        // 4. Mudanças: o título com os dias do servidor e o primeiro imóvel.
        final mudancas = MudancasRecentesModel.fromJson(
          fixture('relatorio_mudancas.json'),
        ).paraEntidade();
        final titulo = tituloSecaoMudancas(mudancas.dias);
        expect(find.text(titulo), findsOneWidget);
        expect(
          naSecao(titulo, rotuloImovelDaMudanca(mudancas.mudancas.first)),
          findsOneWidget,
        );
        pilha.conferirCabecalhosDeAutorizacao();

        // O voltar leva à vitrine, com o botão do topo ainda "Meu acervo".
        await tester.pageBack();
        await assentar(tester);

        expect(find.text('Campinas, SP'), findsOneWidget);
        expect(find.text('Meu acervo'), findsOneWidget);
        expect(find.byType(AreaGestorScreen), findsNothing);
      },
    );

    testWidgets(
      'período: aplicar pede só os contatos com de/ate, limpar pede de novo '
      'só os contatos sem query, e as outras 3 rotas ficam quietas (D-16)',
      (tester) async {
        final pilha = await abrirAreaDoGestor(tester);
        final cubit = BlocProvider.of<AreaGestorCubit>(
          tester.element(find.byType(SecaoContatosCorretores)),
        );
        final antes = pilha.api.requisicoesDosRelatorios.length;
        final periodo = PeriodoContatos(
          de: DateTime(2024),
          ate: DateTime(2024, 1, 31),
        );

        unawaited(cubit.aplicarPeriodo(periodo));
        await assentar(tester);

        final aplicados = pilha.api.requisicoesDosRelatorios.skip(antes);
        expect(aplicados, hasLength(1));
        expect(aplicados.single.path, caminhoContatos);
        expect(aplicados.single.queryParameters, {
          'de': '2024-01-01',
          'ate': '2024-01-31',
        });
        final doPeriodo = fixture('relatorio_contatos_periodo.json');
        expect(
          naSecao(tituloSecaoContatos, textoDoPeriodo(periodo)),
          findsOneWidget,
        );
        expect(
          naSecao(
            tituloSecaoContatos,
            textoTotalContatos(
              doPeriodo['total']! as int,
              doPeriodo['pendentes']! as int,
            ),
          ),
          findsOneWidget,
        );

        final depoisDeAplicar = pilha.api.requisicoesDosRelatorios.length;
        unawaited(cubit.limparPeriodo());
        await assentar(tester);

        final limpos = pilha.api.requisicoesDosRelatorios.skip(depoisDeAplicar);
        expect(limpos, hasLength(1));
        expect(limpos.single.path, caminhoContatos);
        expect(limpos.single.hasQuery, isFalse);
        expect(
          naSecao(tituloSecaoContatos, textoDoPeriodo(null)),
          findsOneWidget,
        );
        expect(pedidosA(pilha, caminhoTotais), 1);
        expect(pedidosA(pilha, caminhoAcervo), 1);
        expect(pedidosA(pilha, caminhoMudancas), 1);
        pilha.conferirCabecalhosDeAutorizacao();
      },
    );

    testWidgets(
      'falha de uma seção não derruba as outras e "Tentar de novo" repete só '
      'o pedido dela (D-07)',
      (tester) async {
        final pilha = await abrirAreaDoGestor(
          tester,
          configurar: (api) => api.falharProximas(caminhoTotais, status: 500),
        );

        final totalDoAcervo = fixture('relatorio_acervo.json')['total']! as int;
        expect(
          naSecao(tituloSecaoTotais, textoDaFalha(FalhaDaSecao.indisponivel)),
          findsOneWidget,
        );
        expect(
          find.text(textoDaFalha(FalhaDaSecao.indisponivel)),
          findsOneWidget,
        );
        expect(
          naSecao(tituloSecaoTotais, textoTotalImoveis(totalDoAcervo)),
          findsNothing,
        );
        // As outras três seguem com os dados do servidor.
        expect(
          naSecao(tituloSecaoContatos, textoLinhaDaEmpresa),
          findsOneWidget,
        );
        expect(find.text(tituloSecaoAcervo), findsOneWidget);

        final tentar = find.descendant(
          of: cartaoDaSecao(tituloSecaoTotais),
          matching: find.text(rotuloTentarDeNovoSecao),
        );
        await tester.ensureVisible(tentar);
        await tester.tap(tentar);
        await assentar(tester);

        expect(pedidosA(pilha, caminhoTotais), 2);
        expect(pedidosA(pilha, caminhoAcervo), 1);
        expect(pedidosA(pilha, caminhoContatos), 1);
        expect(pedidosA(pilha, caminhoMudancas), 1);
        expect(
          naSecao(tituloSecaoTotais, textoTotalImoveis(totalDoAcervo)),
          findsOneWidget,
        );
        expect(
          find.text(textoDaFalha(FalhaDaSecao.indisponivel)),
          findsNothing,
        );
        pilha.conferirCabecalhosDeAutorizacao();
      },
    );

    testWidgets(
      '403 numa seção mostra "Só o gestor da imobiliária pode ver estes '
      'números." e as outras 3 mostram os dados (D-23)',
      (tester) async {
        await abrirAreaDoGestor(
          tester,
          configurar: (api) => api.responder(
            (uri) => uri.path == caminhoAcervo,
            status: 403,
            fixture: 'erro_403_relatorio.json',
          ),
        );

        expect(
          naSecao(tituloSecaoAcervo, textoDaFalha(FalhaDaSecao.semPermissao)),
          findsOneWidget,
        );
        expect(
          find.text(textoDaFalha(FalhaDaSecao.semPermissao)),
          findsOneWidget,
        );
        final totalDoAcervo = fixture('relatorio_acervo.json')['total']! as int;
        expect(
          naSecao(tituloSecaoTotais, textoTotalImoveis(totalDoAcervo)),
          findsOneWidget,
        );
        expect(
          naSecao(tituloSecaoContatos, textoLinhaDaEmpresa),
          findsOneWidget,
        );
        final dias = fixture('relatorio_mudancas.json')['dias']! as int;
        expect(find.text(tituloSecaoMudancas(dias)), findsOneWidget);
        // O texto do servidor ("restrito ao gestor") nunca chega à tela.
        expect(find.textContaining('restrito'), findsNothing);
      },
    );

    testWidgets(
      '401 numa seção abre o login com "Sua sessão terminou. Entre de novo.", '
      'apaga o token e o voltar do login leva à vitrine (D-22)',
      (tester) async {
        final pilha = await abrirAreaDoGestor(
          tester,
          configurar: (api) => api.responder(
            (uri) => uri.path == caminhoMudancas,
            status: 401,
            fixture: 'erro_401.json',
          ),
        );

        expect(
          find.text('Sua sessão terminou. Entre de novo.'),
          findsOneWidget,
        );
        expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
        expect(find.byType(AreaGestorScreen), findsNothing);
        expect(pilha.armazenamento.token, isNull);

        await tester.pageBack();
        await assentar(tester);

        expect(find.text('Campinas, SP'), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('Meu acervo'), findsNothing);
        expect(find.byType(AreaGestorScreen), findsNothing);
      },
    );

    testWidgets('corretor: "Meu acervo" abre o acervo e nenhum pedido vai a '
        '/api/relatorios/ (D-03, critério 6)', (tester) async {
      final pilha = await PilhaReal.preparar(token: tokenDasFixtures);

      await pilha.entrarNoAcervo(tester);

      expect(find.byType(CartaoImovelAcervo), findsWidgets);
      expect(find.byType(AreaGestorScreen), findsNothing);
      expect(find.text(tituloAreaGestor), findsNothing);
      expect(pilha.api.requisicoesDosRelatorios, isEmpty);
      pilha.conferirCabecalhosDeAutorizacao();
    });
  });
}
