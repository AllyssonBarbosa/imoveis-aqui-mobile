import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_screen.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_state.dart';
import 'package:mocktail/mocktail.dart';

/// Testes de widget da vitrine com um `VitrineCubit` falso (VIT-05) —
/// exercita a renderização de todos os estados de lista e rodapé, sem
/// depender do `ImovelMockDataSource` real (isso fica no e2e de
/// `vitrine_fluxo_test.dart`).
class _VitrineCubitFalso extends MockCubit<VitrineState>
    implements VitrineCubit {}

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  late _VitrineCubitFalso cubit;

  Imovel imovelDe(int id) => Imovel(
    id: id,
    titulo: 'Imóvel $id',
    finalidade: FinalidadeImovel.venda,
    precoVenda: '100000.00',
    bairro: 'Centro',
    cidade: campinas,
  );

  setUp(() {
    cubit = _VitrineCubitFalso();
    when(() => cubit.carregarMais()).thenAnswer((_) async {});
    when(() => cubit.tentarNovamente()).thenReturn(null);
    when(() => cubit.buscar(any())).thenReturn(null);
    when(() => cubit.limparBusca()).thenReturn(null);
  });

  Future<void> pumpEstado(
    WidgetTester tester,
    VitrineState estado, {
    Size? viewport,
  }) async {
    if (viewport != null) {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    whenListen(cubit, Stream<VitrineState>.value(estado), initialState: estado);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<VitrineCubit>.value(
            value: cubit,
            child: VitrineScreen(cidade: campinas),
          ),
        ),
      ),
    );
    // Nunca pumpAndSettle: o CircularProgressIndicator indeterminado (estado
    // `carregando`/`carregandoMais`) nunca se estabiliza.
    await tester.pump();
  }

  testWidgets('carregando mostra o spinner de tela cheia', (tester) async {
    await pumpEstado(
      tester,
      const VitrineState(conteudo: ConteudoVitrine.carregando()),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'vazioNaCidade mostra "Ainda não há imóveis anunciados em Campinas."',
    (tester) async {
      await pumpEstado(
        tester,
        const VitrineState(conteudo: ConteudoVitrine.vazioNaCidade()),
      );

      expect(
        find.text('Ainda não há imóveis anunciados em Campinas.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'semResultado mostra texto próprio + "Limpar busca", distinto do vazio '
    'da cidade (D-09); tocar "Limpar busca" chama limparBusca() e esvazia o '
    'campo de busca',
    (tester) async {
      await pumpEstado(
        tester,
        const VitrineState(conteudo: ConteudoVitrine.semResultado('xyz')),
      );

      expect(find.text('Nenhum imóvel encontrado para "xyz"'), findsOneWidget);
      expect(
        find.text('Ainda não há imóveis anunciados em Campinas.'),
        findsNothing,
      );
      expect(find.text('Limpar busca'), findsOneWidget);

      await tester.enterText(find.byType(SearchBar), 'xyz');
      await tester.pump();
      await tester.tap(find.text('Limpar busca'));
      await tester.pump();

      verify(() => cubit.limparBusca()).called(1);
      final campo = tester.widget<SearchBar>(find.byType(SearchBar));
      expect(campo.controller!.text, isEmpty);
    },
  );

  group('SearchBar (VIT-03, D-07)', () {
    testWidgets(
      'SearchBar aparece abaixo do SeletorCidadeTopo, com o hint esperado',
      (tester) async {
        await pumpEstado(
          tester,
          const VitrineState(conteudo: ConteudoVitrine.carregando()),
        );

        expect(find.byType(SearchBar), findsOneWidget);
        expect(find.text('Buscar por título ou bairro'), findsOneWidget);

        final coluna = tester.widget<Column>(find.byType(Column).first);
        final indiceSeletor = coluna.children.indexWhere(
          (w) => w is SeletorCidadeTopo,
        );
        final indiceBusca = coluna.children.indexWhere((w) => w is SearchBar);
        expect(indiceSeletor, greaterThanOrEqualTo(0));
        expect(indiceBusca, greaterThan(indiceSeletor));
      },
    );

    testWidgets('digitar na SearchBar chama cubit.buscar(texto)', (
      tester,
    ) async {
      await pumpEstado(
        tester,
        const VitrineState(conteudo: ConteudoVitrine.carregando()),
      );

      await tester.enterText(find.byType(SearchBar), 'casa');
      await tester.pump();

      verify(() => cubit.buscar('casa')).called(1);
    });

    testWidgets(
      'botão "X" só aparece com texto digitado; tocar limpa o campo e '
      'chama limparBusca()',
      (tester) async {
        await pumpEstado(
          tester,
          const VitrineState(conteudo: ConteudoVitrine.carregando()),
        );

        expect(find.byIcon(Icons.clear), findsNothing);

        await tester.enterText(find.byType(SearchBar), 'casa');
        await tester.pump();
        expect(find.byIcon(Icons.clear), findsOneWidget);

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        verify(() => cubit.limparBusca()).called(1);
        final campo = tester.widget<SearchBar>(find.byType(SearchBar));
        expect(campo.controller!.text, isEmpty);
      },
    );
  });

  testWidgets(
    'erro mostra "Tentar de novo" e o toque chama tentarNovamente()',
    (tester) async {
      await pumpEstado(
        tester,
        const VitrineState(conteudo: ConteudoVitrine.erro()),
      );

      expect(find.text('Tentar de novo'), findsOneWidget);
      await tester.tap(find.text('Tentar de novo'));
      await tester.pump();

      verify(() => cubit.tentarNovamente()).called(1);
    },
  );

  // Viewport alto o bastante para o `ListView.builder` materializar o card
  // completo (foto 16:9 + textos, bem mais alto que o card mínimo) e o
  // rodapé logo abaixo, dentro do cache extent (mesmo ajuste do
  // vitrine_fluxo_test.dart / 02-01-SUMMARY.md).
  const viewportComRodapeVisivel = Size(400, 1200);

  testWidgets(
    'carregada com carregandoMais mostra o spinner do rodapé',
    (tester) async {
      await pumpEstado(
        tester,
        VitrineState(
          conteudo: ConteudoVitrine.carregada(
            itens: [imovelDe(1)],
            proximaPagina: 'cursor-2',
            carregandoMais: true,
          ),
        ),
        viewport: viewportComRodapeVisivel,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'carregada com erroAoCarregarMais mostra a mensagem e o retry chama '
    'tentarNovamente()',
    (tester) async {
      await pumpEstado(
        tester,
        VitrineState(
          conteudo: ConteudoVitrine.carregada(
            itens: [imovelDe(1)],
            proximaPagina: 'cursor-2',
            erroAoCarregarMais: true,
          ),
        ),
        viewport: viewportComRodapeVisivel,
      );

      expect(
        find.text('Não foi possível carregar mais imóveis'),
        findsOneWidget,
      );
      await tester.tap(find.text('Tentar de novo'));
      await tester.pump();

      verify(() => cubit.tentarNovamente()).called(1);
    },
  );

  testWidgets(
    'carregada com proximaPagina null mostra "Você chegou ao fim da lista"',
    (tester) async {
      await pumpEstado(
        tester,
        VitrineState(
          conteudo: ConteudoVitrine.carregada(itens: [imovelDe(1)]),
        ),
        viewport: viewportComRodapeVisivel,
      );

      expect(find.text('Você chegou ao fim da lista'), findsOneWidget);
    },
  );

  testWidgets(
    'arrastar uma lista longa até o fim chama carregarMais()',
    (tester) async {
      final itens = List.generate(30, imovelDe);
      await pumpEstado(
        tester,
        VitrineState(
          conteudo: ConteudoVitrine.carregada(
            itens: itens,
            proximaPagina: 'cursor-2',
          ),
        ),
        viewport: const Size(400, 800),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -20000));
      await tester.pump();

      verify(() => cubit.carregarMais()).called(greaterThanOrEqualTo(1));
    },
  );
}
