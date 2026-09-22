import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:mocktail/mocktail.dart';

class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

void main() {
  late _CidadeSelecaoCubitFalso cubit;
  late _SalvarCidadeUseCaseFalso salvarCidade;

  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');
  const listaAtendida = [campinas, valinhos];

  setUpAll(() {
    registerFallbackValue(campinas);
  });

  setUp(() {
    cubit = _CidadeSelecaoCubitFalso();
    salvarCidade = _SalvarCidadeUseCaseFalso();
    when(() => salvarCidade(any())).thenAnswer((_) async {});
    when(
      () => cubit.abrirConfiguracoesDoSistema(),
    ).thenAnswer((_) async {});
    when(() => cubit.carregarLista()).thenAnswer((_) async {});
    when(() => cubit.entrarDireto(any())).thenAnswer((_) {});
  });

  Future<void> pumpEstado(
    WidgetTester tester,
    CidadeSelecaoState estado,
  ) async {
    whenListen(cubit, Stream<CidadeSelecaoState>.value(estado), initialState: estado);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CidadeSelecaoCubit>.value(
          value: cubit,
          child: CidadeSelecaoScreen(salvarCidade: salvarCidade),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'localizando: indicador + "Localizando você…", nenhum ErrorWidget',
    (tester) async {
      await pumpEstado(tester, const CidadeSelecaoState.localizando());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Localizando você…'), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
    },
  );

  testWidgets(
    'autorizadaEAtendida: "{Cidade}, {UF}" no topo, sem passo de confirmação',
    (tester) async {
      await pumpEstado(
        tester,
        const CidadeSelecaoState.autorizadaEAtendida(campinas),
      );

      expect(find.text('Campinas, SP'), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
    },
  );

  testWidgets(
    'autorizadaNaoAtendida: aviso leve + lista completa de cidades atendidas',
    (tester) async {
      await pumpEstado(
        tester,
        const CidadeSelecaoState.autorizadaNaoAtendida(
          'Sorocaba',
          listaAtendida,
        ),
      );

      expect(
        find.textContaining('Ainda não atendemos Sorocaba'),
        findsOneWidget,
      );
      expect(find.byType(Card), findsNWidgets(listaAtendida.length));
      expect(find.byType(ErrorWidget), findsNothing);
    },
  );

  testWidgets(
    'recusada: heading normal, sem pedido de desculpas (LOC-03)',
    (tester) async {
      await pumpEstado(tester, const CidadeSelecaoState.recusada(listaAtendida));

      expect(find.text('Escolha sua cidade'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(listaAtendida.length));
      expect(find.byType(ErrorWidget), findsNothing);
    },
  );

  testWidgets(
    'bloqueadaParaSempre: CTA "Ativar localização nas Ajustes" + lista (D-06)',
    (tester) async {
      await pumpEstado(
        tester,
        const CidadeSelecaoState.bloqueadaParaSempre(listaAtendida),
      );

      expect(
        find.widgetWithText(TextButton, 'Ativar localização nas Ajustes'),
        findsOneWidget,
      );
      expect(find.byType(Card), findsNWidgets(listaAtendida.length));
      expect(find.byType(ErrorWidget), findsNothing);

      await tester.tap(
        find.widgetWithText(TextButton, 'Ativar localização nas Ajustes'),
      );
      await tester.pump();
      verify(() => cubit.abrirConfiguracoesDoSistema()).called(1);
    },
  );

  testWidgets(
    'servicoDesligado: heading próprio + lista, distinto dos demais desfechos',
    (tester) async {
      await pumpEstado(
        tester,
        const CidadeSelecaoState.servicoDesligado(listaAtendida),
      );

      expect(
        find.textContaining('Ative a localização do aparelho'),
        findsOneWidget,
      );
      expect(find.byType(Card), findsNWidgets(listaAtendida.length));
      expect(find.byType(ErrorWidget), findsNothing);
    },
  );

  testWidgets(
    'falhaGeocodificacao: aviso leve + lista (D-12), sem tela de erro',
    (tester) async {
      await pumpEstado(
        tester,
        const CidadeSelecaoState.falhaGeocodificacao(listaAtendida),
      );

      expect(
        find.textContaining('Não conseguimos identificar sua localização'),
        findsOneWidget,
      );
      expect(find.byType(Card), findsNWidgets(listaAtendida.length));
      expect(find.byType(ErrorWidget), findsNothing);
    },
  );

  testWidgets(
    'erroCarregarCidades: estado defensivo + "Tentar de novo", nunca fatal',
    (tester) async {
      await pumpEstado(tester, const CidadeSelecaoState.erroCarregarCidades());

      expect(
        find.text('Não foi possível carregar as cidades'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextButton, 'Tentar de novo'),
        findsOneWidget,
      );
      expect(find.byType(ErrorWidget), findsNothing);

      await tester.tap(find.widgetWithText(TextButton, 'Tentar de novo'));
      await tester.pump();
      verify(() => cubit.carregarLista()).called(1);
    },
  );

  testWidgets(
    'tocar uma cidade da lista persiste via SalvarCidadeUseCase e entra '
    'direto (D-10 aplicado à seleção manual)',
    (tester) async {
      await pumpEstado(tester, const CidadeSelecaoState.recusada(listaAtendida));

      await tester.tap(find.text('Campinas, SP'));
      await tester.pumpAndSettle();

      verify(() => salvarCidade(campinas)).called(1);
      verify(() => cubit.entrarDireto(campinas)).called(1);
    },
  );
}
