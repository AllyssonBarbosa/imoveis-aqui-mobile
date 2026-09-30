import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/texto_normalizado.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_usecase.dart';
import 'package:imoveis_aqui/domain/entities/ordenacao_vitrine.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/imovel_card.dart';
import 'package:mocktail/mocktail.dart';

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
  const indaiatuba = Cidade(nome: 'Indaiatuba', uf: 'SP');

  late _CidadeSelecaoCubitFalso cidadeSelecaoCubit;
  late _SalvarCidadeUseCaseFalso salvarCidade;

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
      );

  setUp(() {
    cidadeSelecaoCubit = _CidadeSelecaoCubitFalso();
    salvarCidade = _SalvarCidadeUseCaseFalso();
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
    'Campinas: cabeçalho "Campinas, SP" + cards só de Campinas, pela pilha '
    'real Cubit -> UseCase -> Repository -> DataSource (VIT-01, API-04)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      expect(find.text('Campinas, SP'), findsOneWidget);
      // Primeira página (tamanhoPagina 10) — só os imóveis de Campinas
      // aparecem antes de rolar (VIT-05, scroll infinito); a contagem exata
      // materializada depende do cache extent do ListView, não é o que este
      // teste verifica (isso é papel do teste de scroll dedicado abaixo).
      final cards = tester.widgetList<ImovelCard>(find.byType(ImovelCard));
      expect(cards, isNotEmpty);
      for (final card in cards) {
        expect(card.imovel.cidade, campinas);
      }

      expect(find.text('Apartamento 2 quartos no Cambuí'), findsOneWidget);
      expect(find.text('Casa térrea 3 quartos no Taquaral'), findsOneWidget);
      expect(
        find.text('Terreno no Loteamento Jardim das Palmeiras'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Indaiatuba (atendida, sem imóveis na fixture): estado vazio próprio '
    '(D-15), distinto de erro',
    (tester) async {
      await pumpVitrineDe(tester, indaiatuba);

      expect(
        find.text('Ainda não há imóveis anunciados em Indaiatuba.'),
        findsOneWidget,
      );
      expect(find.byType(ImovelCard), findsNothing);
      expect(find.byType(ErrorWidget), findsNothing);
    },
  );

  testWidgets(
    'Campinas: rolar até o fim mostra as 40 linhas, ids únicos, mesma ordem '
    'da pilha real do mock (VIT-05, critério 4 da fase)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

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

      expect(conteudo.itens, hasLength(40));
      expect(conteudo.itens.map((i) => i.id).toSet(), hasLength(40));
      expect(conteudo.itens.every((i) => i.cidade == campinas), isTrue);

      // Mesma ordem que andar o mock diretamente, sem passar pela UI.
      final mockDireto = ImovelMockDataSource.paraTeste(
        linhas: linhasAcervoFixture(),
        tamanhoPagina: 10,
      );
      final idsEsperados = <int>[];
      var envelope = await mockDireto.buscar(
        const ConsultaImoveis(cidade: campinas),
      );
      idsEsperados.addAll(envelope.results.map((m) => m.id));
      while (envelope.next != null) {
        envelope = await mockDireto.seguir(envelope.next!);
        idsEsperados.addAll(envelope.results.map((m) => m.id));
      }

      expect(conteudo.itens.map((i) => i.id).toList(), idsEsperados);
    },
  );

  testWidgets(
    'Campinas: digitar "cambui" na SearchBar e aguardar 400 ms mostra só os '
    'imóveis cujo título ou bairro contém "Cambuí" (VIT-03, D-06, D-08)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      await tester.enterText(find.byType(SearchBar), 'cambui');
      await tester.pump(const Duration(milliseconds: 400));
      // Latência da DataSource é zero neste helper — mais um pump assenta a
      // resposta que chega no microtask seguinte ao disparo do debounce.
      await tester.pump();

      bool linhaContemTermo(Map<String, Object?> linha) {
        final tituloNormalizado = normalizarTexto(linha['titulo']! as String);
        final bairroNormalizado = normalizarTexto(linha['bairro']! as String);
        return tituloNormalizado.contains('cambui') ||
            bairroNormalizado.contains('cambui');
      }

      final idsEsperados =
          linhasAcervoFixture()
              .where(
                (l) =>
                    (l['cidade']! as Map<String, Object?>)['nome'] ==
                        'Campinas' &&
                    linhaContemTermo(l),
              )
              .map((l) => l['id']! as int)
              .toSet();
      expect(idsEsperados, isNotEmpty);

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens.map((i) => i.id).toSet(), idsEsperados);

      final cards = tester.widgetList<ImovelCard>(find.byType(ImovelCard));
      expect(cards, isNotEmpty);
      for (final card in cards) {
        expect(idsEsperados.contains(card.imovel.id), isTrue);
      }
    },
  );

  testWidgets(
    'Campinas: escolher "Menor preço" no bottom sheet reordena pelo menor '
    'preco_venda (nulls-last, D-12) e volta o scroll ao topo (VIT-04, D-13)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      // Rola para longe do topo ANTES de trocar a ordenação (D-13: a troca
      // precisa voltar ao topo).
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      final buscaLista = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      );
      final scrollableAntes = tester.state<ScrollableState>(buscaLista);
      expect(scrollableAntes.position.pixels, greaterThan(0));

      await tester.tap(find.textContaining('Ordenar:'));
      await tester.pumpAndSettle();
      expect(find.text('Ordenar por'), findsOneWidget);

      await tester.tap(find.text('Menor preço'));
      await tester.pumpAndSettle();

      final vitrineCubit = BlocProvider.of<VitrineCubit>(
        tester.element(find.byType(ListView)),
      );
      expect(vitrineCubit.state.ordenacao, OrdenacaoVitrine.precoAsc);
      expect(find.textContaining('Ordenar: Menor preço'), findsOneWidget);

      // Menor preco_venda entre as linhas de Campinas — nulls-last (D-12),
      // desempate por id ascendente, derivado da própria fixture.
      final linhasComPreco =
          linhasAcervoFixture()
              .where(
                (l) =>
                    (l['cidade']! as Map<String, Object?>)['nome'] ==
                        'Campinas' &&
                    l['preco_venda'] != null,
              )
              .toList()
            ..sort((a, b) {
              final precoA = double.parse(a['preco_venda']! as String);
              final precoB = double.parse(b['preco_venda']! as String);
              final comparacao = precoA.compareTo(precoB);
              if (comparacao != 0) return comparacao;
              return (a['id']! as int).compareTo(b['id']! as int);
            });
      final idEsperado = linhasComPreco.first['id']! as int;

      final conteudo = vitrineCubit.state.conteudo as VitrineCarregada;
      expect(conteudo.itens.first.id, idEsperado);

      final scrollableDepois = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(scrollableDepois.position.pixels, 0);
    },
  );
}
