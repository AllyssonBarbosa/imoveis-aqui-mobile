import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_state.dart';
import 'package:imoveis_aqui/presentation/perfis/widgets/corpo_perfil_com_vitrine.dart';
import 'package:imoveis_aqui/presentation/perfis/widgets/rodape_paginacao_lista.dart';
import 'package:imoveis_aqui/presentation/perfis/widgets/sliver_imoveis_anunciante.dart';
import 'package:mocktail/mocktail.dart';

class _VitrineAnuncianteCubitFalso extends MockCubit<VitrineAnuncianteState>
    implements VitrineAnuncianteCubit {}

List<Imovel> _imoveis(int quantidade, {int primeiroId = 1}) => [
  for (var i = 0; i < quantidade; i++)
    Imovel(
      id: primeiroId + i,
      titulo: 'Imóvel ${primeiroId + i}',
      finalidade: FinalidadeImovel.venda,
      bairro: 'Cambuí',
    ),
];

void main() {
  group('RodapePaginacaoLista', () {
    Future<void> montar(
      WidgetTester tester, {
      bool carregandoMais = false,
      bool erroAoCarregarMais = false,
      bool temProximaPagina = true,
      VoidCallback? aoTentarDeNovo,
    }) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RodapePaginacaoLista(
            carregandoMais: carregandoMais,
            erroAoCarregarMais: erroAoCarregarMais,
            temProximaPagina: temProximaPagina,
            aoTentarDeNovo: aoTentarDeNovo ?? () {},
          ),
        ),
      ),
    );

    testWidgets('carregando mais mostra o spinner de 24x24 com strokeWidth 2', (
      tester,
    ) async {
      await montar(tester, carregandoMais: true);

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(spinner.strokeWidth, 2);
      expect(
        tester.getSize(
          find.ancestor(
            of: find.byType(CircularProgressIndicator),
            matching: find.byType(SizedBox),
          ),
        ),
        const Size(24, 24),
      );
      expect(find.text('Você chegou ao fim da lista'), findsNothing);
    });

    testWidgets('erro mostra a mensagem e "Tentar de novo" chama o callback '
        'uma vez', (tester) async {
      var chamadas = 0;
      await montar(
        tester,
        erroAoCarregarMais: true,
        aoTentarDeNovo: () => chamadas++,
      );

      expect(
        find.text('Não foi possível carregar mais imóveis'),
        findsOneWidget,
      );
      await tester.tap(find.text('Tentar de novo'));
      expect(chamadas, 1);
    });

    testWidgets('sem próxima página mostra o fim da lista', (tester) async {
      await montar(tester, temProximaPagina: false);

      expect(find.text('Você chegou ao fim da lista'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('com próxima página e sem estado especial não mostra nada', (
      tester,
    ) async {
      await montar(tester);

      expect(find.byType(Text), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('carregando tem prioridade sobre erro e sobre o fim', (
      tester,
    ) async {
      await montar(
        tester,
        carregandoMais: true,
        erroAoCarregarMais: true,
        temProximaPagina: false,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Tentar de novo'), findsNothing);
      expect(find.text('Você chegou ao fim da lista'), findsNothing);
    });

    testWidgets('erro tem prioridade sobre o fim', (tester) async {
      await montar(tester, erroAoCarregarMais: true, temProximaPagina: false);

      expect(find.text('Tentar de novo'), findsOneWidget);
      expect(find.text('Você chegou ao fim da lista'), findsNothing);
    });
  });

  group('CorpoPerfilComVitrine', () {
    late _VitrineAnuncianteCubitFalso vitrine;
    var cubitsCriados = 0;

    setUp(() {
      vitrine = _VitrineAnuncianteCubitFalso();
      cubitsCriados = 0;
      when(() => vitrine.carregarMais()).thenAnswer((_) async {});
      when(() => vitrine.tentarNovamente()).thenAnswer((_) async {});
    });

    void ajustarViewport(WidgetTester tester, Size tamanho) {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    /// Cabeçalho alto o bastante para o perfil, sozinho, já ser rolável.
    const cabecalhoAlto = <Widget>[
      SliverToBoxAdapter(child: SizedBox(height: 1500)),
    ];

    /// Cabeçalho baixo: nada para rolar sem a vitrine.
    const cabecalhoBaixo = <Widget>[
      SliverToBoxAdapter(child: SizedBox(height: 100)),
    ];

    Widget app({required List<Widget> cabecalho, required bool comVitrine}) =>
        MaterialApp(
          home: Scaffold(
            // Provider preguiçoso, como o de `abrirPerfilCorretor`: o Cubit só
            // nasce na primeira leitura.
            body: BlocProvider<VitrineAnuncianteCubit>(
              create: (_) {
                cubitsCriados++;
                return vitrine;
              },
              child: CorpoPerfilComVitrine(
                cabecalho: cabecalho,
                vitrine: comVitrine
                    ? SliverImoveisDoAnunciante(
                        titulo: 'Imóveis de Marina Lopes',
                        aoAbrirImovel: (context, imovel) async {},
                      )
                    : null,
              ),
            ),
          ),
        );

    Future<void> arrastarAteOFim(WidgetTester tester) async {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -6000));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('arrastar até o fim chama carregarMais() (gatilho a 90%)', (
      tester,
    ) async {
      ajustarViewport(tester, const Size(400, 800));
      whenListen(
        vitrine,
        const Stream<VitrineAnuncianteState>.empty(),
        initialState: VitrineAnuncianteState.carregada(
          itens: _imoveis(10),
          proximaPagina: 'proxima',
        ),
      );
      await tester.pumpWidget(app(cabecalho: cabecalhoBaixo, comVitrine: true));
      await tester.pump();
      verifyNever(() => vitrine.carregarMais());

      await arrastarAteOFim(tester);

      verify(() => vitrine.carregarMais()).called(greaterThanOrEqualTo(1));
    });

    testWidgets('com vitrine nula, arrastar nunca lê o Cubit da vitrine', (
      tester,
    ) async {
      ajustarViewport(tester, const Size(400, 800));
      await tester.pumpWidget(app(cabecalho: cabecalhoAlto, comVitrine: false));
      await tester.pump();

      await arrastarAteOFim(tester);

      expect(cubitsCriados, 0);
      verifyNever(() => vitrine.carregarMais());
    });

    testWidgets('com erroAoCarregarMais, arrastar não chama carregarMais() '
        '(retry só pelo botão)', (tester) async {
      ajustarViewport(tester, const Size(400, 800));
      whenListen(
        vitrine,
        const Stream<VitrineAnuncianteState>.empty(),
        initialState: VitrineAnuncianteState.carregada(
          itens: _imoveis(10),
          proximaPagina: 'proxima',
          erroAoCarregarMais: true,
        ),
      );
      await tester.pumpWidget(app(cabecalho: cabecalhoBaixo, comVitrine: true));
      await tester.pump();

      await arrastarAteOFim(tester);

      verifyNever(() => vitrine.carregarMais());
      // O retry é só pelo botão do rodapé.
      await tester.scrollUntilVisible(
        find.text('Tentar de novo'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Tentar de novo'), findsOneWidget);
      await tester.tap(find.text('Tentar de novo'));
      verify(() => vitrine.tentarNovamente()).called(1);
    });

    testWidgets('página curta (1 item com próxima página): pede a próxima '
        'sozinho, uma vez, depois do primeiro frame', (tester) async {
      ajustarViewport(tester, const Size(400, 2400));
      whenListen(
        vitrine,
        const Stream<VitrineAnuncianteState>.empty(),
        initialState: VitrineAnuncianteState.carregada(
          itens: _imoveis(1),
          proximaPagina: 'proxima',
        ),
      );

      await tester.pumpWidget(app(cabecalho: cabecalhoBaixo, comVitrine: true));
      await tester.pump();
      await tester.pump();

      verify(() => vitrine.carregarMais()).called(1);
    });

    testWidgets('página curta sem próxima página não pede nada', (
      tester,
    ) async {
      ajustarViewport(tester, const Size(400, 2400));
      whenListen(
        vitrine,
        const Stream<VitrineAnuncianteState>.empty(),
        initialState: VitrineAnuncianteState.carregada(itens: _imoveis(1)),
      );

      await tester.pumpWidget(app(cabecalho: cabecalhoBaixo, comVitrine: true));
      await tester.pump();
      await tester.pump();

      verifyNever(() => vitrine.carregarMais());
      expect(find.text('Você chegou ao fim da lista'), findsOneWidget);
    });

    testWidgets('a checagem se repete a cada novo estado: carregando -> '
        'carregada curta pede a próxima página', (tester) async {
      ajustarViewport(tester, const Size(400, 2400));
      final estados = StreamController<VitrineAnuncianteState>();
      addTearDown(estados.close);
      whenListen(
        vitrine,
        estados.stream,
        initialState: const VitrineAnuncianteState.carregando(),
      );

      await tester.pumpWidget(app(cabecalho: cabecalhoBaixo, comVitrine: true));
      await tester.pump();
      await tester.pump();
      verifyNever(() => vitrine.carregarMais());

      estados.add(
        VitrineAnuncianteState.carregada(
          itens: _imoveis(1),
          proximaPagina: 'proxima',
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();

      verify(() => vitrine.carregarMais()).called(1);
    });

    testWidgets('a vitrine surge depois (perfil termina de carregar): a '
        'checagem de página curta roda na transição', (tester) async {
      ajustarViewport(tester, const Size(400, 2400));
      whenListen(
        vitrine,
        const Stream<VitrineAnuncianteState>.empty(),
        initialState: VitrineAnuncianteState.carregada(
          itens: _imoveis(1),
          proximaPagina: 'proxima',
        ),
      );

      await tester.pumpWidget(
        app(cabecalho: cabecalhoBaixo, comVitrine: false),
      );
      await tester.pump();
      expect(cubitsCriados, 0);
      verifyNever(() => vitrine.carregarMais());

      await tester.pumpWidget(app(cabecalho: cabecalhoBaixo, comVitrine: true));
      await tester.pump();
      await tester.pump();

      expect(cubitsCriados, 1);
      verify(() => vitrine.carregarMais()).called(1);
    });
  });
}
