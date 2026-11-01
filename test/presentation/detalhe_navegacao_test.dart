import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_remote_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
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
import 'package:imoveis_aqui/presentation/detalhe_imovel/perfil_corretor_screen.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/sessao_filtros_vitrine.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

/// Teste ponta a ponta do tracer da Fase 4 (DET-01, critério 6): tocar num
/// card da vitrine (lista REAL: `ImovelRemoteDataSource` sobre o JSON
/// capturado da `ApiFalsa`) abre a página do imóvel pelo caminho de produção
/// (`abrirDetalheImovel`, que resolve o Cubit no DI só no toque), mostra a
/// prévia na hora e, quando o detalhe chega pela pilha
/// `DetalheImovelCubit -> ObterDetalheImovelUseCase ->
/// ImovelDetalheRepositoryImpl -> ImovelDetalheMockDataSource`, a seção
/// "Descrição". O detalhe ainda é o dublê da Fase 4 (sai no plano 05-14): os
/// mapas dele são reindexados para os ids dos cards capturados.
class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

/// DataSource de teste que falha na primeira chamada e depois delega ao mock
/// real — simula uma falha de rede transitória (D-17).
class _DataSourceFalhaNaPrimeira implements ImovelDetalheDataSource {
  _DataSourceFalhaNaPrimeira(this._real);

  final ImovelDetalheDataSource _real;
  int chamadas = 0;

  @override
  Future<DetalheImovelModel> buscarDetalhe(int id) async {
    chamadas++;
    if (chamadas == 1) throw Exception('falha simulada');
    return _real.buscarDetalhe(id);
  }
}

void main() {
  // Campinas como a API devolve (com id), lida da fixture capturada.
  final campinas = () {
    final linha = (lerFixtureApi('cidades.json')! as List<Object?>)
        .cast<Map<String, Object?>>()
        .firstWhere((c) => c['nome'] == 'Campinas');
    return Cidade(
      id: linha['id']! as int,
      nome: linha['nome']! as String,
      uf: linha['uf']! as String,
    );
  }();

  // Os dois primeiros cards da p1 capturada: os que os testes tocam.
  final cardsDaP1 =
      ((lerFixtureApi('lista_campinas_p1.json')!
                  as Map<String, Object?>)['results']!
              as List<Object?>)
          .cast<Map<String, Object?>>();
  final idPrimeiro = cardsDaP1[0]['id']! as int;
  final tituloPrimeiro = cardsDaP1[0]['titulo']! as String;
  final bairroPrimeiro = cardsDaP1[0]['bairro']! as String;
  final idSegundo = cardsDaP1[1]['id']! as int;
  final tituloSegundo = cardsDaP1[1]['titulo']! as String;

  /// Mapas do dublê do detalhe reindexados para os cards capturados: o
  /// primeiro leva o detalhe completo do 42 da fixture antiga, o segundo o do
  /// 57; título do card capturado mantido para o cabeçalho não mudar quando o
  /// detalhe chega. Sai no plano 05-14.
  Map<int, Map<String, Object?>> detalhesDosCards() {
    final antigos = detalhesAcervoFixture();
    return {
      idPrimeiro: {...antigos[42]!, 'id': idPrimeiro, 'titulo': tituloPrimeiro},
      idSegundo: {...antigos[57]!, 'id': idSegundo, 'titulo': tituloSegundo},
    };
  }

  late _CidadeSelecaoCubitFalso cidadeSelecaoCubit;
  late _SalvarCidadeUseCaseFalso salvarCidade;
  late ApiFalsa apiFalsa;

  VitrineCubit criarVitrineCubitReal() => VitrineCubit(
    BuscarImoveisUseCase(
      ImovelRepositoryImpl(ImovelRemoteDataSource(apiFalsa.criarDio())),
    ),
    SessaoFiltrosVitrine(),
  );

  OpcoesFiltroCubit criarOpcoesFiltroCubitReal() {
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
    apiFalsa = ApiFalsa();
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
        CidadeSelecaoState.autorizadaEAtendida(campinas),
      ),
      initialState: CidadeSelecaoState.autorizadaEAtendida(campinas),
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
    // O dio leva alguns turnos do event loop a mais que um dublê em memória
    // para entregar a resposta.
    await tester.pump(const Duration(milliseconds: 50));
  }

  Finder naPagina(Finder alvo) =>
      find.descendant(of: find.byType(DetalheImovelScreen), matching: alvo);

  group('tracer', () {
    setUp(() {
      getIt.registerFactory<DetalheImovelCubit>(
        () => DetalheImovelCubit(
          ObterDetalheImovelUseCase(
            ImovelDetalheRepositoryImpl(
              ImovelDetalheMockDataSource.paraTeste(
                detalhes: detalhesDosCards(),
                latencia: const Duration(seconds: 1),
              ),
            ),
          ),
        ),
      );
    });

    testWidgets(
      'tocar no primeiro card da lista real mostra a prévia com spinner na '
      'hora, depois a Descrição do detalhe do mock, e voltar devolve a '
      'vitrine (DET-01, '
      'D-09, D-11, D-16)',
      (tester) async {
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idPrimeiro')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(
          naPagina(find.text(tituloPrimeiro)),
          findsOneWidget,
        );
        // A prévia vem do item da lista, que não traz cidade (A-06): só o
        // bairro até o detalhe chegar.
        expect(naPagina(find.text(bairroPrimeiro)), findsOneWidget);
        expect(naPagina(find.textContaining(', SP')), findsNothing);
        expect(naPagina(find.text('R\$ 235.000')), findsOneWidget);
        expect(
          naPagina(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
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
        // Com o detalhe, o cabeçalho completa a localização com a cidade.
        expect(naPagina(find.text('Cambuí · Campinas, SP')), findsOneWidget);
        // O cabeçalho da prévia continua no mesmo lugar.
        expect(
          naPagina(find.text(tituloPrimeiro)),
          findsOneWidget,
        );

        await tester.tap(find.byTooltip('Voltar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(DetalheImovelScreen), findsNothing);
        expect(find.byKey(ValueKey('imovel-$idPrimeiro')), findsOneWidget);
      },
    );
  });

  group('fluxo completo (DET-01..05, D-12, D-15)', () {
    testWidgets(
      'vitrine -> detalhe do primeiro card completo -> perfil da Marina Lopes '
      '-> volta ao '
      'detalhe -> volta à vitrine intacta',
      (tester) async {
        getIt.registerFactory<DetalheImovelCubit>(
          () => DetalheImovelCubit(
            ObterDetalheImovelUseCase(
              ImovelDetalheRepositoryImpl(
                ImovelDetalheMockDataSource.paraTeste(
                  detalhes: detalhesDosCards(),
                  latencia: const Duration(seconds: 1),
                ),
              ),
            ),
          ),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idPrimeiro')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        // Cabeçalho alimentado pelo detalhe, com custos e características.
        expect(naPagina(find.text('R\$\u00A0450.000')), findsOneWidget);
        expect(
          naPagina(find.text('Condomínio R\$\u00A0850/mês')),
          findsOneWidget,
        );
        expect(naPagina(find.text('IPTU R\$\u00A01.200')), findsOneWidget);
        expect(naPagina(find.text('Características')), findsOneWidget);
        expect(naPagina(find.byType(Chip)), findsNWidgets(3));

        // Sem barra inferior fixa (D-12).
        final scaffold = tester.widget<Scaffold>(
          naPagina(find.byType(Scaffold)),
        );
        expect(scaffold.bottomNavigationBar, isNull);
        expect(scaffold.persistentFooterButtons, isNull);

        // Rola até o corretor e abre o perfil.
        await tester.scrollUntilVisible(
          naPagina(find.text('Marina Lopes')),
          200,
          scrollable: naPagina(find.byType(Scrollable)).first,
        );
        await tester.tap(naPagina(find.text('Marina Lopes')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(PerfilCorretorScreen), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(PerfilCorretorScreen),
            matching: find.text('Marina Lopes'),
          ),
          findsOneWidget,
        );

        // Volta ao detalhe, ainda carregado.
        await tester.tap(find.byType(BackButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(PerfilCorretorScreen), findsNothing);
        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(naPagina(find.text('Descrição')), findsOneWidget);

        // Volta à vitrine, intacta.
        await tester.tap(find.byTooltip('Voltar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(DetalheImovelScreen), findsNothing);
        expect(find.byKey(ValueKey('imovel-$idPrimeiro')), findsOneWidget);
      },
    );
  });

  group('outros cards da vitrine (DET-01, API-06)', () {
    testWidgets(
      'tocar no segundo card abre o detalhe dele e, depois da latência, mostra '
      'a própria descrição (não a do primeiro)',
      (tester) async {
        getIt.registerFactory<DetalheImovelCubit>(
          () => DetalheImovelCubit(
            ObterDetalheImovelUseCase(
              ImovelDetalheRepositoryImpl(
                ImovelDetalheMockDataSource.paraTeste(
                  detalhes: detalhesDosCards(),
                  latencia: const Duration(milliseconds: 300),
                ),
              ),
            ),
          ),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idSegundo')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(
          naPagina(find.text(tituloSegundo)),
          findsOneWidget,
        );

        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(
          naPagina(
            find.text(
              'Casa térrea com quintal amplo, próxima à Lagoa do Taquaral.',
            ),
          ),
          findsOneWidget,
        );
        expect(
          naPagina(
            find.text(
              'Apartamento reformado, próximo ao centro, com '
              'varanda gourmet.',
            ),
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'servidor sem o imóvel: o primeiro card termina em "Este imóvel não está '
      'mais disponível" e "Voltar à vitrine" devolve a vitrine (D-17)',
      (tester) async {
        final semOPrimeiro = detalhesDosCards()..remove(idPrimeiro);
        getIt.registerFactory<DetalheImovelCubit>(
          () => DetalheImovelCubit(
            ObterDetalheImovelUseCase(
              ImovelDetalheRepositoryImpl(
                ImovelDetalheMockDataSource.paraTeste(
                  detalhes: semOPrimeiro,
                  latencia: const Duration(milliseconds: 300),
                ),
              ),
            ),
          ),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idPrimeiro')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(
          naPagina(find.text('Este imóvel não está mais disponível')),
          findsOneWidget,
        );

        await tester.tap(naPagina(find.text('Voltar à vitrine')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(DetalheImovelScreen), findsNothing);
        expect(find.byKey(ValueKey('imovel-$idPrimeiro')), findsOneWidget);
      },
    );
  });

  group('retry', () {
    late _DataSourceFalhaNaPrimeira dataSource;

    setUp(() {
      dataSource = _DataSourceFalhaNaPrimeira(
        ImovelDetalheMockDataSource.paraTeste(
          detalhes: detalhesDosCards(),
          latencia: const Duration(milliseconds: 300),
        ),
      );
      getIt.registerFactory<DetalheImovelCubit>(
        () => DetalheImovelCubit(
          ObterDetalheImovelUseCase(ImovelDetalheRepositoryImpl(dataSource)),
        ),
      );
    });

    testWidgets(
      'falha ao abrir mostra a mensagem com "Tentar de novo"; tocar repete '
      'a busca (spinner) e mostra a Descrição quando dá certo (D-17)',
      (tester) async {
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idPrimeiro')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(
          naPagina(find.text('Não foi possível carregar este imóvel.')),
          findsOneWidget,
        );
        expect(naPagina(find.text('Tentar de novo')), findsOneWidget);
        expect(naPagina(find.byType(CircularProgressIndicator)), findsNothing);
        expect(dataSource.chamadas, 1);

        await tester.tap(naPagina(find.text('Tentar de novo')));
        await tester.pump();

        expect(
          naPagina(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        expect(naPagina(find.text('Tentar de novo')), findsNothing);

        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(
          naPagina(find.text('Não foi possível carregar este imóvel.')),
          findsNothing,
        );
        expect(dataSource.chamadas, 2);
      },
    );
  });

  group('DI real', () {
    tearDown(() async {
      await getIt.reset();
    });

    test(
      'resolve DetalheImovelCubit e a DataSource do detalhe (mock)',
      () async {
        await configureDependencies();

        expect(getIt<DetalheImovelCubit>(), isA<DetalheImovelCubit>());
        expect(
          getIt<ImovelDetalheDataSource>(),
          isA<ImovelDetalheMockDataSource>(),
        );
      },
    );
  });
}
