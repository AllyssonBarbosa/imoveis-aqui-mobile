import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_remote_datasource.dart';
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart';
import 'package:imoveis_aqui/data/repositories/opcoes_filtro_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_usecase.dart';
import 'package:imoveis_aqui/domain/entities/ordenacao_vitrine.dart';
import 'package:imoveis_aqui/domain/usecases/obter_bairros_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_caracteristicas_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/sessao_filtros_vitrine.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/imovel_card.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

/// Teste ponta a ponta da vitrine (VIT-01): pilha REAL
/// `VitrineCubit -> BuscarImoveisUseCase -> ImovelRepositoryImpl ->
/// ImovelRemoteDataSource -> Dio` sobre a `ApiFalsa` (JSON capturado da API
/// real), montada dentro de `CidadeSelecaoScreen`, com apenas o
/// `CidadeSelecaoCubit` mockado (para controlar diretamente o desfecho
/// `autorizadaEAtendida`). Os testes afirmam a requisição enviada e o que a
/// tela mostra da resposta; filtrar, ordenar e paginar é do servidor (FIL-05).
class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');

  late _CidadeSelecaoCubitFalso cidadeSelecaoCubit;
  late _SalvarCidadeUseCaseFalso salvarCidade;

  setUpAll(() {
    registerFallbackValue(campinas);
  });

  /// UMA única instância por teste (Task 2, D-14, D-23) — mesmo precedente
  /// do `@lazySingleton` real do DI: sobrevive à troca de cidade mesmo que
  /// `_CorpoVitrine` recrie o `VitrineCubit` do zero (chaveado por
  /// `cidade.chaveNatural`), já que a fábrica de `VitrineCubit` do grupo
  /// fecha sobre esta MESMA variável a cada chamada.
  late SessaoFiltrosVitrine sessaoFiltros;

  /// Opções de bairro/característica pela pilha REAL
  /// `OpcoesFiltroCubit -> use cases -> OpcoesFiltroRepositoryImpl ->
  /// OpcoesFiltroRemoteDataSource -> Dio` sobre a mesma [ApiFalsa] da lista.
  OpcoesFiltroCubit criarOpcoesFiltroCubitApi(ApiFalsa apiFalsa) {
    final repositorio = OpcoesFiltroRepositoryImpl(
      OpcoesFiltroRemoteDataSource(apiFalsa.criarDio()),
    );
    return OpcoesFiltroCubit(
      ObterBairrosUseCase(repositorio),
      ObterCaracteristicasUseCase(repositorio),
    );
  }

  setUp(() {
    cidadeSelecaoCubit = _CidadeSelecaoCubitFalso();
    salvarCidade = _SalvarCidadeUseCaseFalso();
    sessaoFiltros = SessaoFiltrosVitrine();
  });

  group('API real (JSON capturado)', () {
    // Campinas como a API devolve (com id), lida da fixture capturada.
    final campinasDaApi = () {
      final linhas = lerFixtureApi('cidades.json')! as List<Object?>;
      final linha = linhas.cast<Map<String, Object?>>().firstWhere(
        (c) => c['nome'] == 'Campinas',
      );
      return Cidade(
        id: linha['id']! as int,
        nome: linha['nome']! as String,
        uf: linha['uf']! as String,
      );
    }();

    List<int> idsDaFixture(String arquivo) =>
        ((lerFixtureApi(arquivo)! as Map<String, Object?>)['results']!
                as List<Object?>)
            .cast<Map<String, Object?>>()
            .map((linha) => linha['id']! as int)
            .toList();

    /// Um `VitrineCubit` real sobre `ImovelRemoteDataSource(apiFalsa)`,
    /// compartilhando a sessão de filtros do teste.
    VitrineCubit criarVitrineCubitApi(ApiFalsa apiFalsa) => VitrineCubit(
      BuscarImoveisUseCase(
        ImovelRepositoryImpl(ImovelRemoteDataSource(apiFalsa.criarDio())),
      ),
      sessaoFiltros,
    );

    /// Monta a vitrine REAL sobre `ImovelRemoteDataSource(apiFalsa)`. Nunca
    /// `pumpAndSettle` aqui: o spinner de carregamento mantém a animação de pé.
    Future<void> pumpVitrineApi(
      WidgetTester tester,
      ApiFalsa apiFalsa, {
      Cidade? cidade,
    }) async {
      final cidadeAtual = cidade ?? campinasDaApi;
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      whenListen(
        cidadeSelecaoCubit,
        Stream<CidadeSelecaoState>.value(
          CidadeSelecaoState.autorizadaEAtendida(cidadeAtual),
        ),
        initialState: CidadeSelecaoState.autorizadaEAtendida(cidadeAtual),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CidadeSelecaoCubit>.value(
            value: cidadeSelecaoCubit,
            child: CidadeSelecaoScreen(
              salvarCidade: salvarCidade,
              criarVitrineCubit: () => criarVitrineCubitApi(apiFalsa),
              criarOpcoesFiltroCubit: () => criarOpcoesFiltroCubitApi(apiFalsa),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      // O dio leva alguns turnos do event loop a mais que o mock em memória
      // para entregar a resposta.
      await tester.pump(const Duration(milliseconds: 50));
    }

    VitrineCubit vitrineCubitDe(WidgetTester tester) =>
        BlocProvider.of<VitrineCubit>(tester.element(find.byType(ListView)));

    testWidgets(
      'Campinas: p1 da API aparece e, rolando até o fim, a p2 vem pela URL '
      'next (D-11, API-04)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        final idsP1 = idsDaFixture('lista_campinas_p1.json');
        final idsP2 = idsDaFixture('lista_campinas_p2.json');

        await pumpVitrineApi(tester, apiFalsa);

        expect(find.text('Campinas, SP'), findsOneWidget);
        final primeiros = tester
            .widgetList<ImovelCard>(find.byType(ImovelCard))
            .map((card) => card.imovel.id)
            .toList();
        expect(primeiros, isNotEmpty);
        expect(primeiros.first, idsP1.first);
        expect(idsP1, containsAll(primeiros));
        final primeiraRequisicao = apiFalsa.requisicoes.first;
        expect(
          primeiraRequisicao.path,
          '/api/publico/cidades/${campinasDaApi.id}/imoveis/',
        );
        expect(primeiraRequisicao.queryParameters['ordenar'], 'recentes');

        var tentativas = 0;
        while (find.text('Você chegou ao fim da lista').evaluate().isEmpty &&
            tentativas < 60) {
          await tester.drag(find.byType(ListView), const Offset(0, -3000));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 20));
          tentativas++;
        }

        expect(find.text('Você chegou ao fim da lista'), findsOneWidget);
        final vitrineCubit = BlocProvider.of<VitrineCubit>(
          tester.element(find.byType(ListView)),
        );
        final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
        expect(conteudo.itens.map((i) => i.id).toList(), [
          ...idsP1,
          ...idsP2,
        ]);
        expect(
          apiFalsa.requisicoes.map((u) => u.queryParameters['page']).toList(),
          [null, '2'],
        );
        // A segunda requisição é a URL `next` da p1, como o servidor mandou.
        final p1 = lerFixtureApi('lista_campinas_p1.json')! as Map<String, Object?>;
        expect(apiFalsa.requisicoes[1].toString(), p1['next']);
        expect(conteudo.itens.map((i) => i.id).toSet(), hasLength(idsP1.length + idsP2.length));
      },
    );

    testWidgets(
      'Indaiatuba (outra cidade, lista vazia do servidor): estado vazio '
      'próprio da cidade, distinto de erro (D-15)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        final indaiatubaDaApi = () {
          final linhas = lerFixtureApi('cidades.json')! as List<Object?>;
          final linha = linhas.cast<Map<String, Object?>>().firstWhere(
            (c) => c['nome'] == 'Indaiatuba',
          );
          return Cidade(
            id: linha['id']! as int,
            nome: linha['nome']! as String,
            uf: linha['uf']! as String,
          );
        }();

        await pumpVitrineApi(tester, apiFalsa, cidade: indaiatubaDaApi);

        expect(
          apiFalsa.ultimaRequisicaoDaLista!.path,
          '/api/publico/cidades/${indaiatubaDaApi.id}/imoveis/',
        );
        expect(
          find.text('Ainda não há imóveis anunciados em Indaiatuba.'),
          findsOneWidget,
        );
        expect(find.byType(ImovelCard), findsNothing);
        expect(find.text('Tentar de novo'), findsNothing);
      },
    );

    testWidgets(
      'primeira página com 500: "Tentar de novo" no corpo; tocar repete a '
      'mesma requisição e mostra a p1 (VIT-05)',
      (tester) async {
        final apiFalsa = ApiFalsa()
          ..falharProximas(
            '/api/publico/cidades/${campinasDaApi.id}/imoveis/',
          );
        final idsP1 = idsDaFixture('lista_campinas_p1.json');

        await pumpVitrineApi(tester, apiFalsa);

        expect(find.text('Não foi possível carregar os imóveis'), findsOneWidget);
        expect(find.text('Tentar de novo'), findsOneWidget);
        expect(find.byType(ImovelCard), findsNothing);

        await tester.tap(find.text('Tentar de novo'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(apiFalsa.requisicoes, hasLength(2));
        expect(apiFalsa.requisicoes[1], apiFalsa.requisicoes[0]);
        expect(find.text('Tentar de novo'), findsNothing);
        final primeiros = tester
            .widgetList<ImovelCard>(find.byType(ImovelCard))
            .map((card) => card.imovel.id)
            .toList();
        expect(primeiros.first, idsP1.first);
        expect(idsP1, containsAll(primeiros));
      },
    );

    testWidgets(
      'carregar mais com 500: "Tentar de novo" no rodapé mantendo a lista; '
      'tocar repete a requisição e traz a p2 (VIT-05)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        final idsP1 = idsDaFixture('lista_campinas_p1.json');
        final idsP2 = idsDaFixture('lista_campinas_p2.json');
        await pumpVitrineApi(tester, apiFalsa);
        apiFalsa.falharProximas(
          '/api/publico/cidades/${campinasDaApi.id}/imoveis/',
        );

        var tentativas = 0;
        while (find
                .text('Não foi possível carregar mais imóveis')
                .evaluate()
                .isEmpty &&
            tentativas < 20) {
          await tester.drag(find.byType(ListView), const Offset(0, -3000));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 50));
          tentativas++;
        }

        expect(
          find.text('Não foi possível carregar mais imóveis'),
          findsOneWidget,
        );
        expect(find.text('Tentar de novo'), findsOneWidget);
        expect(
          (vitrineCubitDe(tester).state.conteudo as VitrineCarregada).itens
              .map((i) => i.id)
              .toList(),
          idsP1,
        );

        await tester.tap(find.text('Tentar de novo'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(apiFalsa.requisicoes, hasLength(3));
        expect(apiFalsa.requisicoes[2], apiFalsa.requisicoes[1]);
        expect(
          (vitrineCubitDe(tester).state.conteudo as VitrineCarregada).itens
              .map((i) => i.id)
              .toList(),
          [...idsP1, ...idsP2],
        );
      },
    );

    testWidgets(
      'JSON da lista malformado (titulo numérico) mostra "Tentar de novo", '
      'nunca fica preso no carregando (Pitfall 1)',
      (tester) async {
        final malformada = Map<String, Object?>.from(
          lerFixtureApi('lista_campinas_p1.json')! as Map<String, Object?>,
        );
        final itens = (malformada['results']! as List<Object?>)
            .cast<Map<String, Object?>>()
            .map(Map<String, Object?>.from)
            .toList();
        itens.first['titulo'] = 123;
        malformada['results'] = itens;
        final apiFalsa = ApiFalsa()
          ..responder((_) => true, status: 200, corpo: malformada);

        await pumpVitrineApi(tester, apiFalsa);

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Tentar de novo'), findsOneWidget);
        expect(find.byType(ImovelCard), findsNothing);
      },
    );

    testWidgets(
      'escolher "Menor preço" envia ordenar=preco (D-12, VIT-04)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        await tester.tap(find.textContaining('Ordenar:'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Menor preço'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 50));

        expect(
          apiFalsa.ultimaRequisicaoDaLista!.queryParameters['ordenar'],
          'preco',
        );
        expect(find.textContaining('Ordenar: Menor preço'), findsOneWidget);
        expect(
          vitrineCubitDe(tester).state.ordenacao,
          OrdenacaoVitrine.precoAsc,
        );
      },
    );

    testWidgets(
      'digitar "Cambuí" e aguardar o debounce envia busca=Cambuí e '
      'ordenar=recentes no caminho da cidade pelo id (D-12, VIT-03)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        await tester.enterText(find.byType(SearchBar), 'Cambuí');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final requisicao = apiFalsa.ultimaRequisicaoDaLista!;
        expect(
          requisicao.path,
          '/api/publico/cidades/${campinasDaApi.id}/imoveis/',
        );
        expect(requisicao.queryParameters['busca'], 'Cambuí');
        expect(requisicao.queryParameters['ordenar'], 'recentes');
        expect(requisicao.queryParameters.containsKey('cidade'), isFalse);
        // O app mostra o que o servidor devolveu (aqui a p1 da fixture).
        expect(
          vitrineCubitDe(tester).state.conteudo,
          isA<VitrineCarregada>(),
        );
        expect(find.byType(ImovelCard), findsWidgets);
      },
    );

    testWidgets(
      'busca sem resultado no servidor mostra o estado "nenhum resultado" '
      'da busca, sem filtrar nada no app (D-14, FIL-05)',
      (tester) async {
        final apiFalsa = ApiFalsa()
          ..responder(
            (uri) => uri.queryParameters['busca'] == 'nada-encontrado-zzz',
            status: 200,
            fixture: 'lista_campinas_vazia.json',
          );
        await pumpVitrineApi(tester, apiFalsa);

        await tester.enterText(find.byType(SearchBar), 'nada-encontrado-zzz');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(
          apiFalsa.ultimaRequisicaoDaLista!.queryParameters['busca'],
          'nada-encontrado-zzz',
        );
        expect(
          find.text('Nenhum imóvel encontrado para "nada-encontrado-zzz"'),
          findsOneWidget,
        );
        expect(find.byType(ImovelCard), findsNothing);
      },
    );

    testWidgets(
      'escolher "Maior preço" envia ordenar=-preco e volta a lista ao topo '
      '(D-12, VIT-04)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        // Rola para longe do topo ANTES de trocar a ordem.
        await tester.drag(find.byType(ListView), const Offset(0, -3000));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 20));
        final posicaoAntes = tester
            .state<ScrollableState>(
              find.descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              ),
            )
            .position
            .pixels;
        expect(posicaoAntes, greaterThan(0));

        await tester.tap(find.textContaining('Ordenar:'));
        await tester.pumpAndSettle();
        expect(find.text('Ordenar por'), findsOneWidget);
        await tester.tap(find.text('Maior preço'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 50));

        expect(
          apiFalsa.ultimaRequisicaoDaLista!.queryParameters['ordenar'],
          '-preco',
        );
        expect(find.textContaining('Ordenar: Maior preço'), findsOneWidget);
        final posicaoDepois = tester
            .state<ScrollableState>(
              find.descendant(
                of: find.byType(ListView),
                matching: find.byType(Scrollable),
              ),
            )
            .position
            .pixels;
        expect(posicaoDepois, 0);
      },
    );

    testWidgets(
      'Filtros -> Casa + Lote -> Ver imóveis envia natureza=CASA,LOTE e a '
      'tela mostra exatamente os cards da resposta capturada (FIL-02, D-07, '
      'D-12, D-14)',
      (tester) async {
        final apiFalsa = ApiFalsa()
          ..responder(
            (uri) => uri.queryParameters['natureza'] == 'CASA,LOTE',
            status: 200,
            fixture: 'lista_campinas_casa_lote.json',
          );
        final idsCasaLote = idsDaFixture('lista_campinas_casa_lote.json');
        await pumpVitrineApi(tester, apiFalsa);

        await tester.tap(find.text('Filtros'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, 'Casa'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, 'Lote'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ver imóveis'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        final requisicao = apiFalsa.ultimaRequisicaoDaLista!;
        expect(
          requisicao.path,
          '/api/publico/cidades/${campinasDaApi.id}/imoveis/',
        );
        expect(requisicao.queryParameters['natureza'], 'CASA,LOTE');
        expect(requisicao.queryParameters['ordenar'], 'recentes');
        expect(requisicao.queryParameters.containsKey('cidade'), isFalse);

        expect(find.widgetWithText(InputChip, 'Casa, Lote'), findsOneWidget);
        expect(find.textContaining('Filtros (1)'), findsOneWidget);

        // O app mostra o que o servidor devolveu, na ordem em que devolveu.
        final conteudo = vitrineCubitDe(tester).state.conteudo
            as VitrineCarregada;
        expect(conteudo.itens.map((i) => i.id).toList(), idsCasaLote);
        final idsNosCards = tester
            .widgetList<ImovelCard>(find.byType(ImovelCard))
            .map((card) => card.imovel.id)
            .toList();
        expect(idsNosCards, isNotEmpty);
        expect(idsNosCards.first, idsCasaLote.first);
        expect(idsCasaLote, containsAll(idsNosCards));
      },
    );

    // ---- Fluxos de filtro (FIL-01..06): afirmam a requisição enviada e o
    // que a tela mostra da resposta do servidor, nunca uma regra de filtro
    // calculada no app (FIL-05, D-14). ----

    final idsP1 = idsDaFixture('lista_campinas_p1.json');

    Future<void> abrirFiltros(WidgetTester tester) async {
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
    }

    /// Toca "Ver imóveis" e deixa a nova primeira página chegar. Nunca
    /// `pumpAndSettle` aqui: o spinner da recarga mantém a animação de pé.
    Future<void> verImoveis(WidgetTester tester) async {
      await tester.tap(find.text('Ver imóveis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();
    }

    Map<String, String> consultaEnviada(ApiFalsa apiFalsa) =>
        apiFalsa.ultimaRequisicaoDaLista!.queryParameters;

    List<int> idsNaTela(WidgetTester tester) => tester
        .widgetList<ImovelCard>(find.byType(ImovelCard))
        .map((card) => card.imovel.id)
        .toList();

    testWidgets(
      'Filtros -> Venda -> Ver imóveis envia finalidade=VENDA e mostra o '
      'chip; reabrir, escolher Qualquer e aplicar volta a pedir sem '
      'finalidade (FIL-01, D-02, D-12)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        await abrirFiltros(tester);
        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();
        await verImoveis(tester);

        expect(consultaEnviada(apiFalsa)['finalidade'], 'VENDA');
        expect(find.widgetWithText(InputChip, 'Venda'), findsOneWidget);
        expect(find.textContaining('Filtros (1)'), findsOneWidget);
        // O app mostra o que o servidor devolveu (aqui a p1 da fixture).
        expect(idsNaTela(tester).first, idsP1.first);

        // "Qualquer" também rotula a opção padrão dos ChoiceChips de
        // mínimo — escopa ao SegmentedButton de finalidade.
        await tester.tap(find.textContaining('Filtros ('));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byWidgetPredicate((widget) => widget is SegmentedButton),
            matching: find.text('Qualquer'),
          ),
        );
        await tester.pumpAndSettle();
        await verImoveis(tester);

        expect(consultaEnviada(apiFalsa).containsKey('finalidade'), isFalse);
        expect(find.text('Filtros'), findsOneWidget);
        expect(find.textContaining('Filtros ('), findsNothing);
      },
    );

    testWidgets(
      'aplicar Venda mostra o chip "Venda"; remover pelo "x" do chip volta a '
      '"Filtros" e a próxima requisição sai sem finalidade (FIL-06, D-15)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        await abrirFiltros(tester);
        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();
        await verImoveis(tester);

        expect(find.widgetWithText(InputChip, 'Venda'), findsOneWidget);
        expect(find.text('Limpar filtros'), findsOneWidget);
        final antes = apiFalsa.requisicoes.length;

        await tester.tap(find.byTooltip('Remover filtro Venda'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        expect(apiFalsa.requisicoes.length, antes + 1);
        expect(consultaEnviada(apiFalsa).containsKey('finalidade'), isFalse);
        expect(find.text('Filtros'), findsOneWidget);
        expect(find.textContaining('Filtros ('), findsNothing);
        expect(find.byType(InputChip), findsNothing);
        expect(find.text('Limpar filtros'), findsNothing);
      },
    );

    testWidgets(
      'aplicar Aluguel e tocar "Limpar filtros" (ActionChip) pede de novo só '
      'com ordenar (FIL-06, D-18)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        await abrirFiltros(tester);
        await tester.tap(find.text('Aluguel'));
        await tester.pumpAndSettle();
        await verImoveis(tester);

        expect(consultaEnviada(apiFalsa)['finalidade'], 'ALUGUEL');
        expect(find.widgetWithText(InputChip, 'Aluguel'), findsOneWidget);

        await tester.tap(find.widgetWithText(ActionChip, 'Limpar filtros'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        expect(consultaEnviada(apiFalsa), {'ordenar': 'recentes'});
        expect(find.text('Filtros'), findsOneWidget);
        expect(find.byType(InputChip), findsNothing);
      },
    );

    testWidgets(
      'Filtros -> Casa + Apartamento + "2+" quartos envia '
      'natureza=CASA,APARTAMENTO e quartos=2; chips "Casa, Apto" e "2+ '
      'quartos", botão "Filtros (2)" (FIL-02, FIL-03, D-01, D-05, D-07)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        await abrirFiltros(tester);
        await tester.tap(find.widgetWithText(FilterChip, 'Casa'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, 'Apartamento'));
        await tester.pumpAndSettle();
        final choiceQuartosDoisMais = find
            .widgetWithText(ChoiceChip, '2+')
            .at(0);
        await tester.ensureVisible(choiceQuartosDoisMais);
        await tester.tap(choiceQuartosDoisMais);
        await tester.pumpAndSettle();
        await verImoveis(tester);

        final consulta = consultaEnviada(apiFalsa);
        expect(consulta['natureza'], 'CASA,APARTAMENTO');
        expect(consulta['quartos'], '2');
        expect(consulta.containsKey('quartos_min'), isFalse);
        expect(find.textContaining('Filtros (2)'), findsOneWidget);
        expect(find.widgetWithText(InputChip, 'Casa, Apto'), findsOneWidget);
        expect(find.widgetWithText(InputChip, '2+ quartos'), findsOneWidget);
        expect(idsNaTela(tester).first, idsP1.first);
      },
    );

    testWidgets(
      'Filtros -> Terreno + "1+" quartos com resposta vazia do servidor '
      'mostra "Nenhum imóvel com esses filtros"; "Limpar filtros" volta à '
      'p1 (D-22, FIL-02, FIL-03)',
      (tester) async {
        final apiFalsa = ApiFalsa()
          ..responder(
            (uri) => uri.queryParameters['natureza'] == 'TERRENO',
            status: 200,
            fixture: 'lista_campinas_vazia.json',
          );
        await pumpVitrineApi(tester, apiFalsa);

        await abrirFiltros(tester);
        await tester.tap(find.widgetWithText(FilterChip, 'Terreno'));
        await tester.pumpAndSettle();
        final choiceQuartosUmMais = find
            .widgetWithText(ChoiceChip, '1+')
            .at(0);
        await tester.ensureVisible(choiceQuartosUmMais);
        await tester.tap(choiceQuartosUmMais);
        await tester.pumpAndSettle();
        await verImoveis(tester);

        expect(consultaEnviada(apiFalsa)['natureza'], 'TERRENO');
        expect(consultaEnviada(apiFalsa)['quartos'], '1');
        expect(find.text('Nenhum imóvel com esses filtros'), findsOneWidget);
        expect(find.byType(ImovelCard), findsNothing);

        await tester.tap(find.widgetWithText(TextButton, 'Limpar filtros'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        expect(consultaEnviada(apiFalsa), {'ordenar': 'recentes'});
        expect(find.text('Filtros'), findsOneWidget);
        expect(find.textContaining('Filtros ('), findsNothing);
        expect(
          (vitrineCubitDe(tester).state.conteudo as VitrineCarregada).itens
              .map((i) => i.id)
              .toList(),
          idsP1,
        );
      },
    );

    testWidgets(
      'Filtros -> Venda + preço 250.000..300.000 envia '
      'finalidade=VENDA&preco_min=250000&preco_max=300000 e mostra o chip '
      '"R\$ 250 mil–300 mil" (FIL-03, D-03, D-09)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        await abrirFiltros(tester);
        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();
        // A tela cheia da vitrine tem sua própria SearchBar (que também é um
        // TextField) à frente do sheet — localiza os campos de preço pelo
        // label, nunca por índice cru (D-09).
        await tester.enterText(
          find.widgetWithText(TextField, 'Mínimo').at(0),
          '250000',
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Máximo').at(0),
          '300000',
        );
        await tester.pumpAndSettle();
        await verImoveis(tester);

        final consulta = consultaEnviada(apiFalsa);
        expect(consulta['finalidade'], 'VENDA');
        expect(consulta['preco_min'], '250000');
        expect(consulta['preco_max'], '300000');
        expect(
          find.widgetWithText(InputChip, 'R\$ 250 mil–300 mil'),
          findsOneWidget,
        );
        expect(idsNaTela(tester).first, idsP1.first);
      },
    );

    testWidgets(
      'Filtros -> área 80..120 (sem finalidade) envia area_min=80&area_max='
      '120 e mostra o chip "80–120 m²" (FIL-04, D-09)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        await abrirFiltros(tester);
        // Os campos de área são a segunda ocorrência de "Mínimo"/"Máximo",
        // depois de Preço — localizados pelo label, nunca por índice cru.
        await tester.enterText(
          find.widgetWithText(TextField, 'Mínimo').at(1),
          '80',
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Máximo').at(1),
          '120',
        );
        await tester.pumpAndSettle();
        await verImoveis(tester);

        final consulta = consultaEnviada(apiFalsa);
        expect(consulta['area_min'], '80');
        expect(consulta['area_max'], '120');
        expect(consulta.containsKey('finalidade'), isFalse);
        expect(find.widgetWithText(InputChip, '80–120 m²'), findsOneWidget);
        expect(idsNaTela(tester).first, idsP1.first);
      },
    );

    testWidgets(
      'Filtros -> expandir Bairros -> digitar "camb" -> marcar Cambuí -> '
      'limpar o campo -> marcar Taquaral envia bairro=Cambuí,Taquaral; chip '
      '"Cambuí +1", botão "Filtros (1)" (FIL-04, D-05, D-07, D-21)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);

        // As opções carregam de forma assíncrona assim que o sheet abre —
        // pumpAndSettle (nenhum spinner visível, a seção "Bairros" começa
        // colapsada) dá tempo de sobra para resolverem antes de expandir.
        await abrirFiltros(tester);
        await tester.tap(find.text('Bairros'));
        await tester.pumpAndSettle();

        // A seção lista exatamente os bairros de bairros_campinas.json, na
        // ordem recebida (D-08), lidos do caminho do id da cidade.
        final bairrosDoServidor = (lerFixtureApi('bairros_campinas.json')!
                as List<Object?>)
            .cast<String>();
        final titulosListados = tester
            .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
            .map((item) => (item.title! as Text).data);
        expect(titulosListados, bairrosDoServidor);
        expect(
          apiFalsa.requisicoes.map((uri) => uri.path),
          contains('/api/publico/cidades/${campinasDaApi.id}/bairros/'),
        );

        await tester.enterText(
          find.widgetWithText(TextField, 'Filtrar bairros'),
          'camb',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(CheckboxListTile, 'Cambuí'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Filtrar bairros'),
          '',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(CheckboxListTile, 'Taquaral'));
        await tester.pumpAndSettle();
        await verImoveis(tester);

        expect(consultaEnviada(apiFalsa)['bairro'], 'Cambuí,Taquaral');
        expect(find.widgetWithText(InputChip, 'Cambuí +1'), findsOneWidget);
        expect(find.textContaining('Filtros (1)'), findsOneWidget);
        expect(idsNaTela(tester).first, idsP1.first);
      },
    );

    testWidgets(
      'Filtros -> marcar Piscina e Churrasqueira mostra o chip "Piscina +1" '
      'e pede de novo a primeira página da nova consulta; os ids de '
      'características viajam no plano 05-15 (FIL-04, D-16)',
      (tester) async {
        final apiFalsa = ApiFalsa();
        await pumpVitrineApi(tester, apiFalsa);
        int requisicoesDaLista() => apiFalsa.requisicoes
            .where((uri) => uri.path.endsWith('/imoveis/'))
            .length;
        final antes = requisicoesDaLista();

        await abrirFiltros(tester);
        // As opções vêm do catálogo real (nomes de caracteristicas.json).
        final nomesDoCatalogo = (lerFixtureApi('caracteristicas.json')!
                as List<Object?>)
            .cast<Map<String, Object?>>()
            .map((linha) => linha['nome']! as String);
        for (final nome in nomesDoCatalogo) {
          await tester.ensureVisible(find.widgetWithText(FilterChip, nome));
          expect(find.widgetWithText(FilterChip, nome), findsOneWidget);
        }
        final chipPiscina = find.widgetWithText(FilterChip, 'Piscina');
        await tester.ensureVisible(chipPiscina);
        await tester.tap(chipPiscina);
        await tester.pumpAndSettle();
        final chipChurrasqueira = find.widgetWithText(
          FilterChip,
          'Churrasqueira',
        );
        await tester.ensureVisible(chipChurrasqueira);
        await tester.tap(chipChurrasqueira);
        await tester.pumpAndSettle();
        await verImoveis(tester);

        expect(find.widgetWithText(InputChip, 'Piscina +1'), findsOneWidget);
        expect(find.textContaining('Filtros (1)'), findsOneWidget);
        expect(requisicoesDaLista(), antes + 1);
        final requisicao = apiFalsa.ultimaRequisicaoDaLista!;
        expect(
          requisicao.path,
          '/api/publico/cidades/${campinasDaApi.id}/imoveis/',
        );
        expect(requisicao.queryParameters.containsKey('page'), isFalse);
        expect(idsNaTela(tester).first, idsP1.first);
      },
    );

    testWidgets(
      'aplicar Venda + "2+" quartos + bairro Cambuí em Campinas e trocar '
      'para Valinhos: a requisição do id de Valinhos mantém finalidade e '
      'quartos, sem bairro; busca/ordenação voltam ao padrão (FIL-06, '
      'F3/D-19)',
      (tester) async {
        tester.view.physicalSize = const Size(400, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final cidadesDaApi = (lerFixtureApi('cidades.json')! as List<Object?>)
            .cast<Map<String, Object?>>()
            .map(
              (c) => Cidade(
                id: c['id']! as int,
                nome: c['nome']! as String,
                uf: c['uf']! as String,
              ),
            )
            .toList();
        final valinhosDaApi = cidadesDaApi.firstWhere(
          (c) => c.nome == 'Valinhos',
        );

        final apiFalsa = ApiFalsa();
        final estados = StreamController<CidadeSelecaoState>.broadcast();
        addTearDown(estados.close);
        whenListen(
          cidadeSelecaoCubit,
          estados.stream,
          initialState: CidadeSelecaoState.autorizadaEAtendida(campinasDaApi),
        );
        when(() => cidadeSelecaoCubit.carregarLista()).thenAnswer((_) async {
          estados.add(CidadeSelecaoState.recusada(cidadesDaApi));
        });
        when(() => cidadeSelecaoCubit.entrarDireto(any())).thenAnswer((
          invocation,
        ) {
          final cidade = invocation.positionalArguments.first as Cidade;
          estados.add(CidadeSelecaoState.autorizadaEAtendida(cidade));
        });
        when(() => salvarCidade(any())).thenAnswer((_) async {});

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CidadeSelecaoCubit>.value(
              value: cidadeSelecaoCubit,
              child: CidadeSelecaoScreen(
                salvarCidade: salvarCidade,
                criarVitrineCubit: () => criarVitrineCubitApi(apiFalsa),
                criarOpcoesFiltroCubit: () =>
                    criarOpcoesFiltroCubitApi(apiFalsa),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Campinas: aplica Venda + "2+" quartos + bairro Cambuí.
        await abrirFiltros(tester);
        await tester.tap(find.text('Venda'));
        await tester.pumpAndSettle();
        final choiceQuartosDoisMais = find
            .widgetWithText(ChoiceChip, '2+')
            .at(0);
        await tester.ensureVisible(choiceQuartosDoisMais);
        await tester.tap(choiceQuartosDoisMais);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Bairros'));
        await tester.tap(find.text('Bairros'));
        await tester.pumpAndSettle();
        final checkboxCambui = find.widgetWithText(CheckboxListTile, 'Cambuí');
        await tester.ensureVisible(checkboxCambui);
        await tester.tap(checkboxCambui);
        await tester.pumpAndSettle();
        await verImoveis(tester);

        expect(find.textContaining('Filtros (3)'), findsOneWidget);
        final emCampinas = apiFalsa.ultimaRequisicaoDaLista!;
        expect(
          emCampinas.path,
          '/api/publico/cidades/${campinasDaApi.id}/imoveis/',
        );
        expect(emCampinas.queryParameters['bairro'], 'Cambuí');

        // Troca de cidade pelo cabeçalho: toque reabre a lista, tocar
        // "Valinhos, SP" entra direto na nova cidade (D-10).
        await tester.tap(find.text('Campinas, SP'));
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('Valinhos, SP'));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump();

        final emValinhos = apiFalsa.ultimaRequisicaoDaLista!;
        expect(
          emValinhos.path,
          '/api/publico/cidades/${valinhosDaApi.id}/imoveis/',
        );
        expect(emValinhos.queryParameters['finalidade'], 'VENDA');
        expect(emValinhos.queryParameters['quartos'], '2');
        expect(emValinhos.queryParameters.containsKey('bairro'), isFalse);
        expect(emValinhos.queryParameters['ordenar'], 'recentes');
        expect(emValinhos.queryParameters.containsKey('busca'), isFalse);

        expect(find.text('Valinhos, SP'), findsOneWidget);
        // Filtros gerais sobrevivem (Venda, 2+ quartos) — SEM o bairro, que
        // pertencia só a Campinas (D-14, F3/D-19).
        expect(find.widgetWithText(InputChip, 'Venda'), findsOneWidget);
        expect(find.widgetWithText(InputChip, '2+ quartos'), findsOneWidget);
        expect(find.byType(InputChip), findsNWidgets(2));
        expect(find.textContaining('Filtros (2)'), findsOneWidget);
        // Busca e ordenação voltam ao padrão da F2 — cidade nova, Cubit novo.
        expect(find.textContaining('Ordenar: Mais recentes'), findsOneWidget);
        final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
        expect(searchBar.controller?.text ?? '', isEmpty);
        // O servidor respondeu vazio para Valinhos: o app só mostra isso.
        expect(find.byType(ImovelCard), findsNothing);
        expect(find.text('Nenhum imóvel com esses filtros'), findsOneWidget);
      },
    );
  });
}
