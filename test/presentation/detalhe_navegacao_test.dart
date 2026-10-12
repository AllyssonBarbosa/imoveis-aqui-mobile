import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/repositories/imovel_detalhe_repository_impl.dart';
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart';
import 'package:imoveis_aqui/data/repositories/opcoes_filtro_repository_impl.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_bairros_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_caracteristicas_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_detalhe_imovel_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/sessao_filtros_vitrine.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
import 'package:mocktail/mocktail.dart';

/// Teste ponta a ponta do tracer da Fase 4 (DET-01, critério 6): tocar num
/// card da vitrine abre a página do imóvel pelo caminho de produção
/// (`abrirDetalheImovel`, que resolve o Cubit no DI só no toque), mostra a
/// prévia na hora e, quando o detalhe chega pela pilha REAL
/// `DetalheImovelCubit -> ObterDetalheImovelUseCase ->
/// ImovelDetalheRepositoryImpl -> ImovelDetalheMockDataSource`, a seção
/// "Descrição".
class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');

  group('tracer', () {
    late _CidadeSelecaoCubitFalso cidadeSelecaoCubit;
    late _SalvarCidadeUseCaseFalso salvarCidade;

    VitrineCubit criarVitrineCubitReal() => VitrineCubit(
      BuscarImoveisUseCase(
        ImovelRepositoryImpl(
          ImovelMockDataSource.paraTeste(
            linhas: linhasAcervoFixture(),
            tamanhoPagina: 10,
          ),
        ),
      ),
      SessaoFiltrosVitrine(),
    );

    OpcoesFiltroCubit criarOpcoesFiltroCubitReal() {
      final repositorio = OpcoesFiltroRepositoryImpl(
        OpcoesFiltroMockDataSource.paraTeste(linhas: linhasAcervoFixture()),
      );
      return OpcoesFiltroCubit(
        ObterBairrosUseCase(repositorio),
        ObterCaracteristicasUseCase(repositorio),
      );
    }

    setUp(() {
      cidadeSelecaoCubit = _CidadeSelecaoCubitFalso();
      salvarCidade = _SalvarCidadeUseCaseFalso();
      getIt.registerFactory<DetalheImovelCubit>(
        () => DetalheImovelCubit(
          ObterDetalheImovelUseCase(
            ImovelDetalheRepositoryImpl(
              ImovelDetalheMockDataSource.paraTeste(
                detalhes: detalhesAcervoFixture(),
                latencia: const Duration(seconds: 1),
              ),
            ),
          ),
        ),
      );
    });

    tearDown(() async {
      await getIt.reset();
    });

    Future<void> pumpVitrine(WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      whenListen(
        cidadeSelecaoCubit,
        Stream<CidadeSelecaoState>.value(
          const CidadeSelecaoState.autorizadaEAtendida(campinas),
        ),
        initialState: const CidadeSelecaoState.autorizadaEAtendida(campinas),
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
      // Nunca pumpAndSettle com spinner de pé: a animação indeterminada
      // nunca se estabiliza.
      await tester.pump();
      await tester.pump();
    }

    Finder naPagina(Finder alvo) =>
        find.descendant(of: find.byType(DetalheImovelScreen), matching: alvo);

    testWidgets(
      'tocar no card 42 mostra a prévia com spinner na hora, depois a '
      'Descrição do detalhe do mock, e voltar devolve a vitrine (DET-01, '
      'D-09, D-11, D-16)',
      (tester) async {
        await pumpVitrine(tester);

        await tester.tap(find.byKey(const ValueKey('imovel-42')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(
          naPagina(find.text('Apartamento 2 quartos no Cambuí')),
          findsOneWidget,
        );
        expect(naPagina(find.text('Cambuí · Campinas, SP')), findsOneWidget);
        expect(naPagina(find.text('R\$ 450.000')), findsOneWidget);
        expect(naPagina(find.byType(CircularProgressIndicator)), findsOneWidget);
        expect(naPagina(find.text('Descrição')), findsNothing);

        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(
          naPagina(
            find.text(
              'Apartamento reformado, próximo ao centro, com varanda '
              'gourmet.',
            ),
          ),
          findsOneWidget,
        );
        expect(naPagina(find.byType(CircularProgressIndicator)), findsNothing);
        // O cabeçalho da prévia continua no mesmo lugar.
        expect(
          naPagina(find.text('Apartamento 2 quartos no Cambuí')),
          findsOneWidget,
        );

        await tester.tap(find.byTooltip('Voltar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(DetalheImovelScreen), findsNothing);
        expect(find.byKey(const ValueKey('imovel-42')), findsOneWidget);
      },
    );
  });

  group('DI real', () {
    tearDown(() async {
      await getIt.reset();
    });

    test('resolve DetalheImovelCubit e a DataSource do detalhe (mock)', () async {
      await configureDependencies();

      expect(getIt<DetalheImovelCubit>(), isA<DetalheImovelCubit>());
      expect(
        getIt<ImovelDetalheDataSource>(),
        isA<ImovelDetalheMockDataSource>(),
      );
    });
  });
}
