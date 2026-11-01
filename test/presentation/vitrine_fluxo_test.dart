import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart';
import 'package:imoveis_aqui/data/repositories/opcoes_filtro_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
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

/// Teste ponta a ponta (VIT-01): pilha REAL
/// `VitrineCubit -> BuscarImoveisUseCase -> ImovelRepositoryImpl ->
/// ImovelMockDataSource` montada dentro de `CidadeSelecaoScreen`, com apenas
/// o `CidadeSelecaoCubit` mockado (para controlar diretamente o desfecho
/// `autorizadaEAtendida`).
class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');

  late _CidadeSelecaoCubitFalso cidadeSelecaoCubit;
  late _SalvarCidadeUseCaseFalso salvarCidade;

  setUpAll(() {
    registerFallbackValue(campinas);
  });

  /// UMA única instância por teste (Task 2, D-14, D-23) — mesmo precedente
  /// do `@lazySingleton` real do DI: sobrevive à troca de cidade mesmo que
  /// `_CorpoVitrine` recrie o `VitrineCubit` do zero (chaveado por
  /// `cidade.chaveNatural`), já que [criarVitrineCubitReal] fecha sobre esta
  /// MESMA variável a cada chamada.
  late SessaoFiltrosVitrine sessaoFiltros;

  VitrineCubit criarVitrineCubitReal({Duration latencia = Duration.zero}) =>
      VitrineCubit(
        BuscarImoveisUseCase(
          ImovelRepositoryImpl(
            ImovelMockDataSource.paraTeste(
              linhas: linhasAcervoFixture(),
              latencia: latencia,
              tamanhoPagina: 10,
            ),
          ),
        ),
        sessaoFiltros,
      );

  /// Pilha real das opções (Task 2, D-20) — mesmas linhas de
  /// `linhasAcervoFixture()`, nunca uma lista fixa paralela.
  OpcoesFiltroCubit criarOpcoesFiltroCubitReal() {
    final repositorio = OpcoesFiltroRepositoryImpl(
      OpcoesFiltroMockDataSource.paraTeste(linhas: linhasAcervoFixture()),
    );
    return OpcoesFiltroCubit(
      ObterBairrosUseCase(repositorio),
      ObterCaracteristicasUseCase(repositorio),
    );
  }

  /// Ids do acervo que pertencem à [cidade], lidos das linhas do próprio mock
  /// (`linha['cidade']`) — o item `Imovel` não carrega cidade (A-06).
  Set<int> idsDaCidade(Cidade cidade) => linhasAcervoFixture()
      .where((linha) {
        final c = linha['cidade']! as Map<String, Object?>;
        return c['nome'] == cidade.nome && c['uf'] == cidade.uf;
      })
      .map((linha) => linha['id']! as int)
      .toSet();

  setUp(() {
    cidadeSelecaoCubit = _CidadeSelecaoCubitFalso();
    salvarCidade = _SalvarCidadeUseCaseFalso();
    sessaoFiltros = SessaoFiltrosVitrine();
  });

  Future<void> pumpVitrineDe(WidgetTester tester, Cidade cidade) async {
    // Viewport moderado: alto o bastante para materializar (via cache
    // extent) alguns ImovelCards do topo da primeira página, mas baixo o
    // bastante para a lista continuar rolável — uma viewport que já
    // renderizasse a página inteira sem rolar dispararia o carregamento
    // automático de "não preenche a tela" (Task 3), o que descaracterizaria
    // o teste de "primeira página" deste bloco.
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    whenListen(
      cidadeSelecaoCubit,
      Stream<CidadeSelecaoState>.value(
        CidadeSelecaoState.autorizadaEAtendida(cidade),
      ),
      initialState: CidadeSelecaoState.autorizadaEAtendida(cidade),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CidadeSelecaoCubit>.value(
          value: cidadeSelecaoCubit,
          child: CidadeSelecaoScreen(
            salvarCidade: salvarCidade,
            criarVitrineCubit: criarVitrineCubitReal,
            criarOpcoesFiltroCubit: criarOpcoesFiltroCubitReal,
          ),
        ),
      ),
    );
    // Nunca pumpAndSettle aqui — o CircularProgressIndicator (estado
    // `carregando`) tem animação indeterminada e pumpAndSettle nunca se
    // estabiliza enquanto ele está de pé.
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'Campinas: tocar Filtros -> Venda -> Ver imóveis filtra pela pilha real '
    '(sheet -> rascunho -> VitrineCubit -> query params -> servidor '
    'simulado); reabrir, escolher Qualquer e aplicar volta à lista completa '
    '(FIL-01, FIL-05, D-02, D-07, D-08, D-11, D-15)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      expect(find.text('Filtros'), findsOneWidget);

      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Venda'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Filtros (1)'), findsOneWidget);

      final idsEsperadosVenda = linhasAcervoFixture()
          .where(
            (l) =>
                (l['cidade']! as Map<String, Object?>)['nome'] ==
                    'Campinas' &&
                (l['finalidade'] == 'VENDA' ||
                    l['finalidade'] == 'VENDA_E_ALUGUEL'),
          )
          .map((l) => l['id']! as int)
          .toSet();

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      // Só a primeira página (10) é carregada sem rolar — a lista de
      // finalidade=VENDA (inclusiva, D-02) tem mais de 10 itens em
      // Campinas, então esta é uma checagem de subconjunto, não de
      // igualdade total.
      final conteudoFiltrado = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudoFiltrado.itens, isNotEmpty);
      expect(
        conteudoFiltrado.itens.every(
          (i) => idsEsperadosVenda.contains(i.id),
        ),
        isTrue,
      );
      for (final card in tester.widgetList<ImovelCard>(
        find.byType(ImovelCard),
      )) {
        expect(idsEsperadosVenda.contains(card.imovel.id), isTrue);
      }

      // Reabre o sheet, escolhe "Qualquer" e aplica — volta a mostrar um
      // imóvel exclusivamente aluguel (id 57, "Casa térrea 3 quartos no
      // Taquaral"). "Qualquer" também rotula a opção padrão dos ChoiceChips
      // de mínimo (Task 2) — escopa ao SegmentedButton de finalidade.
      await tester.tap(find.textContaining('Filtros ('));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byWidgetPredicate((widget) => widget is SegmentedButton),
          matching: find.text('Qualquer'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.text('Filtros'), findsOneWidget);
      expect(find.textContaining('Filtros ('), findsNothing);

      final conteudoCompleto = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudoCompleto.itens.map((i) => i.id).toSet(), hasLength(10));
      expect(
        conteudoCompleto.itens.any((i) => i.id == 57),
        isTrue,
      );
    },
  );

  testWidgets(
    'Campinas: aplicar Venda mostra o chip "Venda"; remover pelo "x" do '
    'chip volta a "Filtros" sem a linha de chips e traz de volta um imóvel '
    'só-aluguel (FIL-06, D-15..D-19)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Venda'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Venda'), findsOneWidget);
      expect(find.text('Limpar filtros'), findsOneWidget);

      await tester.tap(find.byTooltip('Remover filtro Venda'));
      await tester.pumpAndSettle();

      expect(find.text('Filtros'), findsOneWidget);
      expect(find.textContaining('Filtros ('), findsNothing);
      expect(find.byType(InputChip), findsNothing);
      expect(find.text('Limpar filtros'), findsNothing);

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens.any((i) => i.id == 57), isTrue);
    },
  );

  testWidgets(
    'Campinas: aplicar Aluguel e tocar "Limpar filtros" (ActionChip) traz o '
    'mesmo resultado que remover pelo chip (FIL-06, D-18)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aluguel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Aluguel'), findsOneWidget);

      await tester.tap(find.widgetWithText(ActionChip, 'Limpar filtros'));
      await tester.pumpAndSettle();

      expect(find.text('Filtros'), findsOneWidget);
      expect(find.byType(InputChip), findsNothing);

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens.map((i) => i.id).toSet(), hasLength(10));
    },
  );

  testWidgets(
    'Campinas: Filtros -> Casa + Apartamento + "2+" quartos -> Ver imóveis '
    'filtra pela pilha real; chips "Casa, Apto" e "2+ quartos" aparecem, '
    'botão "Filtros (2)" (FIL-02, FIL-03, D-01, D-05, D-10, D-11)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
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
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Filtros (2)'), findsOneWidget);
      expect(find.widgetWithText(InputChip, 'Casa, Apto'), findsOneWidget);
      expect(find.widgetWithText(InputChip, '2+ quartos'), findsOneWidget);

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens, isNotEmpty);
      bool bateComOsFiltros(Imovel imovel) =>
          (imovel.natureza == NaturezaImovel.casa ||
              imovel.natureza == NaturezaImovel.apartamento) &&
          (imovel.quartos ?? 0) >= 2;
      expect(conteudo.itens.every(bateComOsFiltros), isTrue);

      for (final card in tester.widgetList<ImovelCard>(
        find.byType(ImovelCard),
      )) {
        expect(bateComOsFiltros(card.imovel), isTrue);
      }
    },
  );

  testWidgets(
    'Campinas: Filtros -> Terreno + "1+" quartos mostra "Nenhum imóvel com '
    'esses filtros"; "Limpar filtros" (do próprio estado vazio) volta à '
    'lista completa (D-22, FIL-02, FIL-03)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Terreno'));
      await tester.pumpAndSettle();
      final choiceQuartosUmMais = find
          .widgetWithText(ChoiceChip, '1+')
          .at(0);
      await tester.ensureVisible(choiceQuartosUmMais);
      await tester.tap(choiceQuartosUmMais);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.text('Nenhum imóvel com esses filtros'), findsOneWidget);
      expect(find.byType(ImovelCard), findsNothing);

      await tester.tap(find.widgetWithText(TextButton, 'Limpar filtros'));
      await tester.pumpAndSettle();

      expect(find.text('Filtros'), findsOneWidget);
      expect(find.textContaining('Filtros ('), findsNothing);

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens, hasLength(10));
    },
  );

  testWidgets(
    'Campinas: Filtros -> Venda + preço 250.000..300.000 -> Ver imóveis '
    'filtra pela pilha real; todo card tem precoVenda na faixa e o chip '
    '"R\$ 250 mil–300 mil" aparece (FIL-03, D-03, D-09)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
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
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(InputChip, 'R\$ 250 mil–300 mil'),
        findsOneWidget,
      );

      bool dentroDaFaixa(Imovel imovel) {
        final preco = double.tryParse(imovel.precoVenda ?? '');
        return preco != null && preco >= 250000 && preco <= 300000;
      }

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens, isNotEmpty);
      expect(conteudo.itens.every(dentroDaFaixa), isTrue);

      for (final card in tester.widgetList<ImovelCard>(
        find.byType(ImovelCard),
      )) {
        expect(dentroDaFaixa(card.imovel), isTrue);
      }
    },
  );

  testWidgets(
    'Campinas: Filtros -> área 80..120 (sem finalidade) -> Ver imóveis '
    'filtra pela pilha real; todo card mapeia (via fixture) para uma linha '
    'com área na faixa e o chip "80–120 m²" aparece (FIL-04, D-09)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      // A tela cheia da vitrine tem sua própria SearchBar (que também é um
      // TextField) à frente do sheet — localiza os campos de área pelo
      // label (segunda ocorrência de "Mínimo"/"Máximo", depois de Preço),
      // nunca por índice cru (D-09).
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
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, '80–120 m²'), findsOneWidget);

      bool areaNaFaixa(int id) {
        final linha = linhasAcervoFixture().firstWhere((l) => l['id'] == id);
        final area = linha['area'] as String?;
        if (area == null) return false;
        final valor = double.parse(area);
        return valor >= 80 && valor <= 120;
      }

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens, isNotEmpty);
      expect(conteudo.itens.every((i) => areaNaFaixa(i.id)), isTrue);

      for (final card in tester.widgetList<ImovelCard>(
        find.byType(ImovelCard),
      )) {
        expect(areaNaFaixa(card.imovel.id), isTrue);
      }
    },
  );

  testWidgets(
    'Campinas: Filtros -> expandir Bairros -> digitar "camb" -> marcar '
    'Cambuí -> limpar o campo -> marcar Taquaral -> Ver imóveis filtra pela '
    'pilha real (opções do servidor simulado, D-20); chip "Cambuí +1", '
    'botão "Filtros (1)" (FIL-04, D-05, D-21)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      await tester.tap(find.text('Filtros'));
      // As opções (D-20) carregam de forma assíncrona assim que o sheet
      // abre — pumpAndSettle aqui (nenhum spinner indeterminado visível
      // ainda, a seção "Bairros" começa colapsada) dá tempo de sobra para a
      // pilha real (latência zero no helper) resolver antes de expandir.
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bairros'));
      await tester.pumpAndSettle();

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

      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Cambuí +1'), findsOneWidget);
      expect(find.textContaining('Filtros (1)'), findsOneWidget);

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens, isNotEmpty);
      bool bateComOsFiltros(Imovel imovel) =>
          imovel.bairro == 'Cambuí' || imovel.bairro == 'Taquaral';
      expect(conteudo.itens.every(bateComOsFiltros), isTrue);

      for (final card in tester.widgetList<ImovelCard>(
        find.byType(ImovelCard),
      )) {
        expect(bateComOsFiltros(card.imovel), isTrue);
      }
    },
  );

  testWidgets(
    'Campinas: Filtros -> marcar Piscina e Churrasqueira -> Ver imóveis '
    'filtra pela pilha real (E entre as duas, D-04); chip "Piscina +1", '
    'botão "Filtros (1)" (FIL-04, D-16, D-20)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();

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
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InputChip, 'Piscina +1'), findsOneWidget);
      expect(find.textContaining('Filtros (1)'), findsOneWidget);

      bool temAmbasCaracteristicas(int id) {
        final linha = linhasAcervoFixture().firstWhere((l) => l['id'] == id);
        final caracteristicas = (linha['caracteristicas']! as List)
            .cast<String>();
        return caracteristicas.contains('Piscina') &&
            caracteristicas.contains('Churrasqueira');
      }

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens, isNotEmpty);
      expect(
        conteudo.itens.every((i) => temAmbasCaracteristicas(i.id)),
        isTrue,
      );

      for (final card in tester.widgetList<ImovelCard>(
        find.byType(ImovelCard),
      )) {
        expect(temAmbasCaracteristicas(card.imovel.id), isTrue);
      }
    },
  );

  testWidgets(
    'Campinas: aplicar Venda + "2+" quartos + bairro Cambuí, trocar para '
    'Valinhos pelo cabeçalho -> filtros gerais sobrevivem sem o bairro, a '
    'nova cidade já abre filtrada, busca/ordenação voltam ao padrão da F2 '
    '(FIL-06, D-14, D-23)',
    (tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final estados = StreamController<CidadeSelecaoState>.broadcast();
      addTearDown(estados.close);
      final estadoInicial = CidadeSelecaoState.autorizadaEAtendida(campinas);
      whenListen(cidadeSelecaoCubit, estados.stream, initialState: estadoInicial);
      when(() => cidadeSelecaoCubit.carregarLista()).thenAnswer((_) async {
        estados.add(CidadeSelecaoState.recusada([campinas, valinhos]));
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
              criarVitrineCubit: criarVitrineCubitReal,
              criarOpcoesFiltroCubit: criarOpcoesFiltroCubitReal,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Campinas: aplica Venda + "2+" quartos + bairro Cambuí.
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
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
      await tester.tap(find.text('Ver imóveis'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Filtros (3)'), findsOneWidget);

      // Troca de cidade pelo cabeçalho: toque reabre a lista, tocar
      // "Valinhos, SP" entra direto na nova cidade (D-10).
      await tester.tap(find.text('Campinas, SP'));
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Valinhos, SP'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Valinhos, SP'), findsOneWidget);
      // Filtros gerais sobrevivem (Venda, 2+ quartos) — SEM o bairro, que
      // pertencia só a Campinas (D-14).
      expect(find.widgetWithText(InputChip, 'Venda'), findsOneWidget);
      expect(find.widgetWithText(InputChip, '2+ quartos'), findsOneWidget);
      expect(find.byType(InputChip), findsNWidgets(2));
      expect(find.textContaining('Filtros (2)'), findsOneWidget);
      // Busca e ordenação voltam ao padrão da F2 — cidade nova, Cubit novo.
      expect(find.textContaining('Ordenar: Mais recentes'), findsOneWidget);
      final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
      expect(searchBar.controller?.text ?? '', isEmpty);

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens, isNotEmpty);
      final idsValinhos = idsDaCidade(valinhos);
      bool bateComOsFiltros(Imovel imovel) =>
          idsValinhos.contains(imovel.id) &&
          (imovel.finalidade == FinalidadeImovel.venda ||
              imovel.finalidade == FinalidadeImovel.vendaEAluguel) &&
          (imovel.quartos ?? 0) >= 2;
      expect(conteudo.itens.every(bateComOsFiltros), isTrue);

      for (final card in tester.widgetList<ImovelCard>(
        find.byType(ImovelCard),
      )) {
        expect(bateComOsFiltros(card.imovel), isTrue);
      }
    },
  );

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
              criarVitrineCubit: () => VitrineCubit(
                BuscarImoveisUseCase(
                  ImovelRepositoryImpl(
                    ImovelRemoteDataSource(apiFalsa.criarDio()),
                  ),
                ),
                sessaoFiltros,
              ),
              criarOpcoesFiltroCubit: criarOpcoesFiltroCubitReal,
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
  });
}
