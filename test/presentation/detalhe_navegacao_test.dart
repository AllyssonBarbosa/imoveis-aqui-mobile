import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/perfil_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/mocks/perfis_fixture.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
import 'package:imoveis_aqui/data/models/imovel_model.dart';
import 'package:imoveis_aqui/data/repositories/imovel_detalhe_repository_impl.dart';
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart';
import 'package:imoveis_aqui/data/repositories/opcoes_filtro_repository_impl.dart';
import 'package:imoveis_aqui/data/repositories/perfil_repository_impl.dart';
import 'package:imoveis_aqui/data/repositories/vitrine_anunciante_repository_impl.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_do_anunciante_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_bairros_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_caracteristicas_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_detalhe_imovel_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_perfil_corretor_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/perfil_corretor_screen.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_corretor_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/sessao_filtros_vitrine.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/imovel_card.dart';
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
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');

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

  /// Pilha REAL da vitrine do anunciante: nada falso entre o Cubit e o mock
  /// do §12.
  VitrineAnuncianteCubit criarVitrineAnuncianteCubitReal({
    Duration latencia = const Duration(milliseconds: 300),
  }) => VitrineAnuncianteCubit(
    BuscarImoveisDoAnuncianteUseCase(
      VitrineAnuncianteRepositoryImpl(
        VitrineAnuncianteMockDataSource.paraTeste(
          linhas: linhasAcervoFixture(),
          detalhes: detalhesAcervoFixture(),
          corretores: corretoresPerfisFixture(),
          latencia: latencia,
        ),
      ),
    ),
  );

  setUp(() {
    cidadeSelecaoCubit = _CidadeSelecaoCubitFalso();
    salvarCidade = _SalvarCidadeUseCaseFalso();
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

  group('tracer', () {
    setUp(() {
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

  group('fluxo completo (DET-01..05, D-12, D-15)', () {
    testWidgets(
      'vitrine -> detalhe 42 completo -> perfil da Marina Lopes (prévia na '
      'hora, CRECI buscado por id) -> volta ao detalhe -> volta à vitrine '
      'intacta (PERF-06, D-05)',
      (tester) async {
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
        // Pilha REAL do perfil: nada falso entre o toque e o Model.
        getIt.registerFactory<PerfilCorretorCubit>(
          () => PerfilCorretorCubit(
            ObterPerfilCorretorUseCase(
              PerfilRepositoryImpl(
                PerfilMockDataSource.paraTeste(
                  corretores: corretoresPerfisFixture(),
                  latencia: const Duration(seconds: 1),
                ),
              ),
            ),
          ),
        );
        getIt.registerFactory<VitrineAnuncianteCubit>(
          criarVitrineAnuncianteCubitReal,
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(const ValueKey('imovel-42')));
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

        // Prévia na hora: nome do detalhe e spinner, ainda sem o CRECI.
        Finder noPerfil(Finder alvo) => find.descendant(
          of: find.byType(PerfilCorretorScreen),
          matching: alvo,
        );
        expect(find.byType(PerfilCorretorScreen), findsOneWidget);
        expect(noPerfil(find.text('Marina Lopes')), findsOneWidget);
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        expect(noPerfil(find.text('CRECI 12345-F')), findsNothing);

        // O perfil chega pela pilha real, buscado pelo id do corretor.
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        expect(noPerfil(find.text('Marina Lopes')), findsOneWidget);
        expect(noPerfil(find.text('CRECI 12345-F')), findsOneWidget);
        // A vitrine só começa a carregar com o perfil existente: spinner da
        // vitrine de pé durante a segunda latência.
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        expect(noPerfil(find.text('Imóveis de Marina Lopes')), findsOneWidget);

        // A vitrine do anunciante chega pela pilha real do §12.
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(noPerfil(find.byType(CircularProgressIndicator)), findsNothing);

        // Rola até o card do imóvel 42 e abre a página dele.
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('imovel-anunciante-42')),
          300,
          scrollable: noPerfil(find.byType(Scrollable)).first,
        );
        await tester.tap(find.byKey(const ValueKey('imovel-anunciante-42')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        // A página do imóvel cobre o perfil (que fica fora de cena).
        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(find.byType(PerfilCorretorScreen), findsNothing);

        // Voltar do imóvel retorna ao perfil.
        await tester.tap(find.byTooltip('Voltar').last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(PerfilCorretorScreen), findsOneWidget);

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
        expect(find.byKey(const ValueKey('imovel-42')), findsOneWidget);
      },
    );
  });

  group('corretor desativado (PERF-05, D-15)', () {
    testWidgets(
      'imóvel 337 -> Paulo Teixeira (id 99): prévia com spinner, depois só o '
      'aviso "Este corretor não está mais disponível"; "Voltar" devolve o '
      'detalhe 337 ainda carregado',
      (tester) async {
        getIt.registerFactory<DetalheImovelCubit>(
          () => DetalheImovelCubit(
            ObterDetalheImovelUseCase(
              ImovelDetalheRepositoryImpl(
                ImovelDetalheMockDataSource.paraTeste(
                  detalhes: detalhesAcervoFixture(),
                  latencia: const Duration(milliseconds: 300),
                ),
              ),
            ),
          ),
        );
        getIt.registerFactory<PerfilCorretorCubit>(
          () => PerfilCorretorCubit(
            ObterPerfilCorretorUseCase(
              PerfilRepositoryImpl(
                PerfilMockDataSource.paraTeste(
                  corretores: corretoresPerfisFixture(),
                  latencia: const Duration(seconds: 1),
                ),
              ),
            ),
          ),
        );
        // O perfil 404 nunca cria a vitrine: a fábrica não pode ser chamada.
        var vitrinesCriadas = 0;
        getIt.registerFactory<VitrineAnuncianteCubit>(() {
          vitrinesCriadas++;
          return criarVitrineAnuncianteCubitReal();
        });
        tester.view.physicalSize = const Size(400, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final previa = ImovelModel.fromJson(
          linhasAcervoFixture().firstWhere(
            (linha) => linha['id'] == idDetalheCorretorDesativadoMock,
          ),
        ).paraEntidade();
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => abrirDetalheImovel(context, previa),
                    child: const Text('Abrir 337'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir 337'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(naPagina(find.text('Descrição')), findsOneWidget);

        await tester.scrollUntilVisible(
          naPagina(find.text('Paulo Teixeira')),
          200,
          scrollable: naPagina(find.byType(Scrollable)).first,
        );
        await tester.tap(naPagina(find.text('Paulo Teixeira')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        Finder noPerfil(Finder alvo) => find.descendant(
          of: find.byType(PerfilCorretorScreen),
          matching: alvo,
        );
        // Prévia na hora: nome do detalhe e spinner.
        expect(find.byType(PerfilCorretorScreen), findsOneWidget);
        expect(noPerfil(find.text('Paulo Teixeira')), findsOneWidget);
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );

        // O servidor responde 404: some a prévia, fica só o aviso.
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        expect(
          noPerfil(find.text('Este corretor não está mais disponível')),
          findsOneWidget,
        );
        expect(noPerfil(find.text('Paulo Teixeira')), findsNothing);
        expect(noPerfil(find.byType(CircularProgressIndicator)), findsNothing);
        expect(noPerfil(find.textContaining('Imóveis de')), findsNothing);
        expect(vitrinesCriadas, 0);

        await tester.tap(noPerfil(find.text('Voltar')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(PerfilCorretorScreen), findsNothing);
        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(naPagina(find.text('Descrição')), findsOneWidget);
      },
    );
  });

  group('anunciante sem imóveis (D-12)', () {
    testWidgets(
      'corretor 10 (Bruno Sales), perfil válido sem imóveis: depois das duas '
      'latências aparecem o CRECI, "Imóveis de Bruno Sales" e o aviso de '
      'vitrine vazia',
      (tester) async {
        tester.view.physicalSize = const Size(400, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => abrirPerfilCorretor(
                      context,
                      const CorretorResponsavel(id: 10, nome: 'Bruno Sales'),
                      criarPerfilCubit: () => PerfilCorretorCubit(
                        ObterPerfilCorretorUseCase(
                          PerfilRepositoryImpl(
                            PerfilMockDataSource.paraTeste(
                              corretores: corretoresPerfisFixture(),
                              latencia: const Duration(milliseconds: 300),
                            ),
                          ),
                        ),
                      ),
                      criarVitrineCubit: criarVitrineAnuncianteCubitReal,
                    ),
                    child: const Text('Abrir 10'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir 10'));
        await tester.pump();
        // A transição (400 ms) cobre a latência do perfil (300 ms); a vitrine
        // só nasce no frame seguinte, com o perfil carregado.
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        Finder noPerfil(Finder alvo) => find.descendant(
          of: find.byType(PerfilCorretorScreen),
          matching: alvo,
        );
        expect(noPerfil(find.text('CRECI 45678-F')), findsOneWidget);
        expect(noPerfil(find.text('Imóveis de Bruno Sales')), findsOneWidget);
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );

        // Latência da vitrine.
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(
          noPerfil(find.text('Nenhum imóvel anunciado no momento.')),
          findsOneWidget,
        );
        expect(noPerfil(find.byType(CircularProgressIndicator)), findsNothing);
        expect(noPerfil(find.byType(ImovelCard)), findsNothing);
      },
    );
  });

  group('outros cards da vitrine (DET-01, API-06)', () {
    testWidgets(
      'tocar no card 57 abre o detalhe dele e, depois da latência, mostra a '
      'própria descrição (não a do 42)',
      (tester) async {
        getIt.registerFactory<DetalheImovelCubit>(
          () => DetalheImovelCubit(
            ObterDetalheImovelUseCase(
              ImovelDetalheRepositoryImpl(
                ImovelDetalheMockDataSource.paraTeste(
                  detalhes: detalhesAcervoFixture(),
                  latencia: const Duration(milliseconds: 300),
                ),
              ),
            ),
          ),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(const ValueKey('imovel-57')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(
          naPagina(find.text('Casa térrea 3 quartos no Taquaral')),
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
      'servidor sem o imóvel: o card 42 termina em "Este imóvel não está '
      'mais disponível" e "Voltar à vitrine" devolve a vitrine (D-17)',
      (tester) async {
        final semOCard42 = detalhesAcervoFixture()..remove(42);
        getIt.registerFactory<DetalheImovelCubit>(
          () => DetalheImovelCubit(
            ObterDetalheImovelUseCase(
              ImovelDetalheRepositoryImpl(
                ImovelDetalheMockDataSource.paraTeste(
                  detalhes: semOCard42,
                  latencia: const Duration(milliseconds: 300),
                ),
              ),
            ),
          ),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(const ValueKey('imovel-42')));
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
        expect(find.byKey(const ValueKey('imovel-42')), findsOneWidget);
      },
    );
  });

  group('retry', () {
    late _DataSourceFalhaNaPrimeira dataSource;

    setUp(() {
      dataSource = _DataSourceFalhaNaPrimeira(
        ImovelDetalheMockDataSource.paraTeste(
          detalhes: detalhesAcervoFixture(),
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

        await tester.tap(find.byKey(const ValueKey('imovel-42')));
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

    test('resolve VitrineAnuncianteCubit', () async {
      await configureDependencies();

      expect(getIt<VitrineAnuncianteCubit>(), isA<VitrineAnuncianteCubit>());
    });

    testWidgets(
      'abrirPerfilCorretor sem fábrica de teste: o DI de produção serve o '
      'perfil do corretor 7 (prévia com spinner, depois CRECI 12345-F) '
      '(PERF-04, PERF-06, D-03)',
      (tester) async {
        await configureDependencies();
        addTearDown(getIt.reset);
        // Janela alta: a vitrine cai abaixo da dobra e os slivers são lazy.
        tester.view.physicalSize = const Size(400, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => abrirPerfilCorretor(
                      context,
                      const CorretorResponsavel(id: 7, nome: 'Marina Lopes'),
                      construirImagemDeRede: (url) =>
                          ColoredBox(key: ValueKey(url), color: Colors.blue),
                    ),
                    child: const Text('Abrir'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Abrir'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        Finder noPerfil(Finder alvo) => find.descendant(
          of: find.byType(PerfilCorretorScreen),
          matching: alvo,
        );
        expect(noPerfil(find.text('Marina Lopes')), findsOneWidget);
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        expect(noPerfil(find.text('CRECI 12345-F')), findsNothing);

        // Latência padrão de 500 ms do servidor simulado.
        await tester.pump(const Duration(milliseconds: 600));

        expect(noPerfil(find.text('CRECI 12345-F')), findsOneWidget);

        // Vitrine do corretor 7 pela mesma latência padrão (500 ms).
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 600));
        expect(noPerfil(find.byType(CircularProgressIndicator)), findsNothing);
        expect(noPerfil(find.text('Imóveis de Marina Lopes')), findsOneWidget);
      },
    );
  });
}
