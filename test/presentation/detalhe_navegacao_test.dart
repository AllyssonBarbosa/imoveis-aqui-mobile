import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/perfil_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_remote_datasource.dart';
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
import 'package:imoveis_aqui/domain/usecases/obter_perfil_empresa_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:imoveis_aqui/presentation/comum/imagem_rede.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/cartao_corretor.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/galeria_imovel.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_corretor_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_corretor_screen.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_empresa_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_empresa_screen.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/sessao_filtros_vitrine.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/imovel_card.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

/// Teste ponta a ponta do detalhe na API real (DET-01, API-07, critério 6):
/// tocar num card da vitrine (lista REAL: `ImovelRemoteDataSource` sobre o
/// JSON capturado da `ApiFalsa`) abre a página do imóvel pelo caminho de
/// produção (`abrirDetalheImovel`, que resolve o Cubit no DI só no toque),
/// mostra a prévia na hora e, quando o detalhe chega pela pilha
/// `DetalheImovelCubit -> ObterDetalheImovelUseCase ->
/// ImovelDetalheRepositoryImpl -> ImovelDetalheRemoteDataSource` (dio sobre o
/// `detalhe_*.json` capturado), a seção "Descrição". Fixtures = só JSON
/// capturado (D-18).
class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

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

  // O detalhe completo capturado (a casa) e o card da lista com o mesmo id.
  final casa = lerFixtureApi('detalhe_casa.json')! as Map<String, Object?>;
  final idCasa = casa['id']! as int;
  final tituloCasa = casa['titulo']! as String;
  final descricaoCasa = casa['descricao']! as String;
  final corretorDaCasa = casa['corretor_responsavel']! as Map<String, Object?>;
  final nomeCorretor = corretorDaCasa['nome']! as String;
  final idCorretor = corretorDaCasa['id']! as int;

  // Os perfis e as vitrines dos anunciantes, como o Django devolveu (corretor
  // 1 e empresa 1 do seed de desenvolvimento). Nenhum nome, CRECI ou id vem de
  // texto escrito à mão: tudo é lido do JSON capturado.
  final perfilCorretor =
      lerFixtureApi('perfil_corretor.json')! as Map<String, Object?>;
  final creciCorretor = perfilCorretor['creci']! as String;
  final perfilEmpresa =
      lerFixtureApi('perfil_empresa.json')! as Map<String, Object?>;
  final idEmpresa = perfilEmpresa['id']! as int;
  final nomeEmpresa = perfilEmpresa['razao_social_ou_nome']! as String;
  final creciEmpresa = perfilEmpresa['creci']! as String;
  final cidadesDeAtuacao = (perfilEmpresa['cidades_atuacao']! as List<Object?>)
      .cast<Map<String, Object?>>();

  List<Map<String, Object?>> resultadosDe(String fixture) =>
      ((lerFixtureApi(fixture)! as Map<String, Object?>)['results']!
              as List<Object?>)
          .cast<Map<String, Object?>>();
  final vitrineCorretorP1 = resultadosDe('vitrine_corretor_p1.json');
  final vitrineCorretorP2 = resultadosDe('vitrine_corretor_p2.json');
  final vitrineEmpresaP1 = resultadosDe('vitrine_empresa_p1.json');
  final totalDaVitrineDoCorretor =
      (lerFixtureApi('vitrine_corretor_p1.json')!
              as Map<String, Object?>)['count']!
          as int;

  // Um imóvel da p1 do corretor que tem detalhe capturado (o lote): é o imóvel
  // que o teste abre a partir da vitrine do anunciante. Os ids com detalhe vêm
  // dos próprios detalhe_*.json capturados.
  final idsComDetalhe = {
    for (final nome in [
      'detalhe_casa.json',
      'detalhe_apartamento.json',
      'detalhe_lote.json',
      'detalhe_terreno.json',
    ])
      (lerFixtureApi(nome)! as Map<String, Object?>)['id']! as int,
  };
  final imovelDaVitrineDoCorretor = vitrineCorretorP1.firstWhere(
    (imovel) => idsComDetalhe.contains(imovel['id']),
  );
  final idDoImovelDaVitrine = imovelDaVitrineDoCorretor['id']! as int;
  final tituloDoImovelDaVitrine =
      imovelDaVitrineDoCorretor['titulo']! as String;

  final cardsDaP1 =
      ((lerFixtureApi('lista_campinas_p1.json')!
                  as Map<String, Object?>)['results']!
              as List<Object?>)
          .cast<Map<String, Object?>>();
  final cardDaCasa = cardsDaP1.firstWhere((c) => c['id'] == idCasa);
  final bairroDaCasa = cardDaCasa['bairro']! as String;

  // Um segundo detalhe capturado, de outro imóvel, para provar que cada card
  // abre o próprio detalhe.
  final terreno =
      lerFixtureApi('detalhe_terreno.json')! as Map<String, Object?>;
  final idTerreno = terreno['id']! as int;
  final tituloTerreno = terreno['titulo']! as String;

  final apartamento =
      lerFixtureApi('detalhe_apartamento.json')! as Map<String, Object?>;
  final idApartamento = apartamento['id']! as int;

  // O lote capturado (D-17, A-03): números e frases vêm do JSON, não escritos
  // à mão no teste.
  final lote = lerFixtureApi('detalhe_lote.json')! as Map<String, Object?>;
  final idLote = lote['id']! as int;
  final blocoLote = lote['lote']! as Map<String, Object?>;
  final loteamentoDoLote =
      (blocoLote['quadra']! as Map<String, Object?>)['loteamento']!
          as Map<String, Object?>;

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

  /// Registra o Cubit do detalhe sobre [dataSource]. O detalhe usa a própria
  /// `ApiFalsa` (com [latencia]) para a prévia ficar de pé o tempo de testar.
  void registrarDetalhe(ImovelDetalheDataSource dataSource) {
    getIt.registerFactory<DetalheImovelCubit>(
      () => DetalheImovelCubit(
        ObterDetalheImovelUseCase(ImovelDetalheRepositoryImpl(dataSource)),
      ),
    );
  }

  /// Registra os Cubits dos perfis (corretor, empresa) e da vitrine do
  /// anunciante sobre [dio], com a pilha REAL (Cubit -> UseCase ->
  /// RepositoryImpl -> RemoteDataSource): nada falso entre o toque e o JSON
  /// capturado. Passe o `Dio` da MESMA `ApiFalsa` do detalhe para as
  /// requisições ficarem todas num só `requisicoes`.
  void registrarCubitsDosPerfis(Dio dio) {
    getIt.registerFactory<PerfilCorretorCubit>(
      () => PerfilCorretorCubit(
        ObterPerfilCorretorUseCase(
          PerfilRepositoryImpl(PerfilRemoteDataSource(dio)),
        ),
      ),
    );
    getIt.registerFactory<PerfilEmpresaCubit>(
      () => PerfilEmpresaCubit(
        ObterPerfilEmpresaUseCase(
          PerfilRepositoryImpl(PerfilRemoteDataSource(dio)),
        ),
      ),
    );
    getIt.registerFactory<VitrineAnuncianteCubit>(
      () => VitrineAnuncianteCubit(
        BuscarImoveisDoAnuncianteUseCase(
          VitrineAnuncianteRepositoryImpl(
            VitrineAnuncianteRemoteDataSource(dio),
          ),
        ),
      ),
    );
  }

  /// Registra o detalhe E os perfis sobre a mesma [api].
  void registrarDetalheEPerfis(ApiFalsa api) {
    final dio = api.criarDio();
    registrarDetalhe(ImovelDetalheRemoteDataSource(dio));
    registrarCubitsDosPerfis(dio);
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

  Finder noPerfil(Finder alvo) =>
      find.descendant(of: find.byType(PerfilCorretorScreen), matching: alvo);

  Finder naEmpresa(Finder alvo) =>
      find.descendant(of: find.byType(PerfilEmpresaScreen), matching: alvo);

  /// A rolagem externa (a primeira da árvore) da tela [tela]; as seguintes
  /// são de campos de texto selecionáveis.
  Finder rolavelDe(Type tela) => find
      .descendant(of: find.byType(tela), matching: find.byType(Scrollable))
      .first;

  /// Toca em [botao] e deixa a transição de volta terminar.
  Future<void> voltar(WidgetTester tester, Finder botao) async {
    await tester.tap(botao);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Rola a lista da vitrine até o card [id] (a lista é preguiçosa e há cards
  /// abaixo da dobra) e toca nele.
  Future<void> tocarNoCard(WidgetTester tester, int id) async {
    final card = find.byKey(ValueKey('imovel-$id'));
    await tester.scrollUntilVisible(
      card,
      300,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    await tester.ensureVisible(card);
    await tester.pump();
    await tester.tap(card);
  }

  /// Deixa a resposta do dio (com [latencia]) chegar e a página redesenhar.
  Future<void> esperarDetalhe(WidgetTester tester, Duration latencia) async {
    await tester.pump(latencia);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// Da vitrine ao detalhe da casa (carregado) e ao toque no corretor: ao
  /// terminar, o perfil está aberto com a prévia (um `pump` depois do toque).
  /// O detalhe e os perfis precisam estar registrados sobre uma `ApiFalsa`
  /// com [latencia].
  Future<void> abrirPerfilDoCorretorDaCasa(
    WidgetTester tester,
    Duration latencia,
  ) async {
    await pumpVitrine(tester);
    await tester.tap(find.byKey(ValueKey('imovel-$idCasa')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await esperarDetalhe(tester, latencia);
    await tester.scrollUntilVisible(
      naPagina(find.text(nomeCorretor)),
      200,
      scrollable: naPagina(find.byType(Scrollable)).first,
    );
    await tester.tap(naPagina(find.text(nomeCorretor)));
    await tester.pump();
  }

  group('tracer', () {
    setUp(() {
      registrarDetalhe(
        ImovelDetalheRemoteDataSource(
          ApiFalsa(latencia: const Duration(seconds: 1)).criarDio(),
        ),
      );
    });

    testWidgets(
      'tocar no card da casa mostra a prévia com spinner na hora, depois a '
      'Descrição do detalhe da API, e voltar devolve a vitrine (DET-01, '
      'API-07, D-09, D-11, D-16)',
      (tester) async {
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idCasa')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(naPagina(find.text(tituloCasa)), findsOneWidget);
        // A prévia vem do item da lista, que não traz cidade (A-06): só o
        // bairro até o detalhe chegar.
        expect(naPagina(find.text(bairroDaCasa)), findsOneWidget);
        expect(naPagina(find.textContaining(', SP')), findsNothing);
        expect(
          naPagina(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        expect(naPagina(find.text('Descrição')), findsNothing);

        await esperarDetalhe(tester, const Duration(seconds: 1));

        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(naPagina(find.text(descricaoCasa)), findsOneWidget);
        expect(naPagina(find.byType(CircularProgressIndicator)), findsNothing);
        // Com o detalhe, o cabeçalho completa a localização com a cidade
        // (do endereco) e mostra só "bairro · cidade, UF" (D-01).
        expect(
          naPagina(find.text('$bairroDaCasa · Campinas, SP')),
          findsOneWidget,
        );
        expect(naPagina(find.textContaining('Rua dos Ipês')), findsNothing);
        expect(naPagina(find.textContaining('13030-000')), findsNothing);
        // O cabeçalho da prévia continua no mesmo lugar.
        expect(naPagina(find.text(tituloCasa)), findsOneWidget);

        await tester.tap(find.byTooltip('Voltar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(DetalheImovelScreen), findsNothing);
        expect(find.byKey(ValueKey('imovel-$idCasa')), findsOneWidget);
      },
    );
  });

  group('fluxo completo (DET-01..05, D-12, D-15)', () {
    testWidgets(
      'vitrine -> detalhe da casa completo -> perfil do corretor (prévia na '
      'hora, CRECI buscado por id) -> imóvel da vitrine do corretor -> volta '
      'ao perfil, ao detalhe e à vitrine intacta (PERF-06, PERF-04, PERF-03, '
      'D-05)',
      (tester) async {
        final api = ApiFalsa(latencia: const Duration(milliseconds: 300));
        registrarDetalheEPerfis(api);
        await pumpVitrine(tester);
        final posicaoDoCard = tester.getTopLeft(
          find.byKey(ValueKey('imovel-$idCasa')),
        );

        await tester.tap(find.byKey(ValueKey('imovel-$idCasa')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(milliseconds: 300));

        // Cabeçalho alimentado pelo detalhe, com as características pelo nome.
        expect(naPagina(find.textContaining('495.000')), findsOneWidget);
        expect(naPagina(find.text('Características')), findsOneWidget);
        expect(naPagina(find.byType(Chip)), findsNWidgets(2));
        for (final nome in ['Churrasqueira', 'Varanda gourmet']) {
          expect(
            naPagina(
              find.descendant(of: find.byType(Chip), matching: find.text(nome)),
            ),
            findsOneWidget,
          );
        }

        // Sem barra inferior fixa (D-12).
        final scaffold = tester.widget<Scaffold>(
          naPagina(find.byType(Scaffold)),
        );
        expect(scaffold.bottomNavigationBar, isNull);
        expect(scaffold.persistentFooterButtons, isNull);

        // O cartão do corretor mostra só nome e foto: nenhum contato (D-16).
        await tester.scrollUntilVisible(
          naPagina(find.text(nomeCorretor)),
          200,
          scrollable: naPagina(find.byType(Scrollable)).first,
        );
        expect(
          naPagina(find.textContaining(perfilCorretor['email']! as String)),
          findsNothing,
        );
        expect(naPagina(find.textContaining(creciCorretor)), findsNothing);
        await tester.tap(naPagina(find.text(nomeCorretor)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Prévia na hora (nome e foto do detalhe) e spinner, ainda sem o CRECI.
        expect(find.byType(PerfilCorretorScreen), findsOneWidget);
        expect(noPerfil(find.text(nomeCorretor)), findsOneWidget);
        expect(noPerfil(find.byType(AvatarCorretor)), findsOneWidget);
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        expect(noPerfil(find.text('CRECI $creciCorretor')), findsNothing);

        // O perfil chega pela pilha real, buscado pelo id do corretor.
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(noPerfil(find.text(nomeCorretor)), findsOneWidget);
        expect(noPerfil(find.text('CRECI $creciCorretor')), findsOneWidget);
        expect(noPerfil(find.text('Apresentação')), findsOneWidget);
        expect(noPerfil(find.text('Contato')), findsOneWidget);
        expect(
          noPerfil(find.text('Imóveis de ${perfilCorretor['nome']}')),
          findsOneWidget,
        );
        // A vitrine só começa a carregar com o perfil existente: spinner da
        // vitrine de pé durante a segunda latência.
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );

        // A vitrine do corretor chega pela rota aninhada do Django (p1).
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(noPerfil(find.byType(CircularProgressIndicator)), findsNothing);
        final cardDoImovel = find.byKey(
          ValueKey('imovel-anunciante-$idDoImovelDaVitrine'),
        );
        await tester.scrollUntilVisible(
          cardDoImovel,
          300,
          scrollable: rolavelDe(PerfilCorretorScreen),
        );
        expect(
          find.descendant(
            of: cardDoImovel,
            matching: find.text(tituloDoImovelDaVitrine),
          ),
          findsOneWidget,
        );

        // Abre o imóvel da vitrine do corretor: o detalhe dele chega.
        await tester.tap(cardDoImovel);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(milliseconds: 300));
        // A página do imóvel cobre o perfil (que fica fora de cena).
        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(find.byType(PerfilCorretorScreen), findsNothing);
        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(naPagina(find.text(tituloDoImovelDaVitrine)), findsOneWidget);

        // Voltar do imóvel retorna ao perfil.
        await voltar(tester, find.byTooltip('Voltar').last);
        expect(find.byType(PerfilCorretorScreen), findsOneWidget);

        // Volta ao detalhe da casa, ainda carregado.
        await voltar(tester, find.byType(BackButton));
        expect(find.byType(PerfilCorretorScreen), findsNothing);
        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(naPagina(find.text(tituloCasa)), findsOneWidget);

        // Volta à vitrine, intacta e na mesma posição.
        await voltar(tester, find.byTooltip('Voltar'));
        expect(find.byType(DetalheImovelScreen), findsNothing);
        expect(find.byKey(ValueKey('imovel-$idCasa')), findsOneWidget);
        expect(
          tester.getTopLeft(find.byKey(ValueKey('imovel-$idCasa'))),
          posicaoDoCard,
        );
      },
    );

    testWidgets(
      'perfil do corretor -> "Ver página do anunciante" -> página da empresa '
      'capturada (spinner, depois nome, tipo, CRECI, cidades de atuação e '
      '"Imóveis de <empresa>") -> imóvel da vitrine da empresa -> volta ao '
      'perfil do corretor carregado (PERF-01, PERF-04, PERF-06, D-06, D-09)',
      (tester) async {
        registrarDetalheEPerfis(
          ApiFalsa(latencia: const Duration(milliseconds: 300)),
        );
        await abrirPerfilDoCorretorDaCasa(
          tester,
          const Duration(milliseconds: 300),
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        expect(noPerfil(find.text('CRECI $creciCorretor')), findsOneWidget);

        // O cartão fica depois do contato, antes da vitrine do anunciante.
        await tester.scrollUntilVisible(
          noPerfil(find.text('Ver página do anunciante')),
          100,
          scrollable: rolavelDe(PerfilCorretorScreen),
        );
        await tester.tap(noPerfil(find.text('Ver página do anunciante')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Página da empresa aberta: só o spinner, sem prévia.
        expect(find.byType(PerfilEmpresaScreen), findsOneWidget);
        expect(
          naEmpresa(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        expect(naEmpresa(find.text(nomeEmpresa)), findsNothing);

        // A transição (400 ms) cobre a latência da API de perfis (300 ms).
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        expect(naEmpresa(find.text(nomeEmpresa)), findsOneWidget);
        expect(naEmpresa(find.text('Imobiliária')), findsOneWidget);
        expect(naEmpresa(find.text('CRECI $creciEmpresa')), findsOneWidget);
        // Logomarca nula na captura: placeholder de prédio.
        expect(perfilEmpresa['logomarca'], isNull);
        expect(
          naEmpresa(find.byIcon(Icons.apartment_outlined)),
          findsOneWidget,
        );
        expect(naEmpresa(find.text('Cidades de atuação')), findsOneWidget);
        expect(
          naEmpresa(find.byType(Chip)),
          findsNWidgets(cidadesDeAtuacao.length),
        );
        for (final cidade in cidadesDeAtuacao) {
          expect(
            naEmpresa(find.text('${cidade['nome']}, ${cidade['uf']}')),
            findsOneWidget,
          );
        }
        expect(naEmpresa(find.text('Imóveis de $nomeEmpresa')), findsOneWidget);
        // Só resta o spinner da vitrine da empresa, que nasce com a empresa
        // carregada; a latência dela (300 ms) o resolve.
        expect(
          naEmpresa(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(naEmpresa(find.byType(CircularProgressIndicator)), findsNothing);

        // O primeiro card da vitrine da empresa é o primeiro da p1 capturada.
        final primeiro = vitrineEmpresaP1.first;
        final cardDaEmpresa = naEmpresa(
          find.byKey(ValueKey('imovel-anunciante-${primeiro['id']}')),
        );
        expect(cardDaEmpresa, findsOneWidget);
        expect(
          find.descendant(
            of: cardDaEmpresa,
            matching: find.text(primeiro['titulo']! as String),
          ),
          findsOneWidget,
        );
        expect(naEmpresa(find.byType(ImovelCard)), findsWidgets);

        // Voltar devolve o perfil do corretor, ainda carregado.
        await voltar(tester, find.byType(BackButton));
        expect(find.byType(PerfilEmpresaScreen), findsNothing);
        expect(find.byType(PerfilCorretorScreen), findsOneWidget);
        expect(noPerfil(find.text('Ver página do anunciante')), findsOneWidget);
        await tester.scrollUntilVisible(
          noPerfil(find.text('CRECI $creciCorretor')),
          -200,
          scrollable: rolavelDe(PerfilCorretorScreen),
        );
        expect(noPerfil(find.text(nomeCorretor)), findsOneWidget);
        expect(noPerfil(find.text('CRECI $creciCorretor')), findsOneWidget);
      },
    );
  });

  group('corretor ausente e perfil em memória (D-16, D-17)', () {
    final semCorretor =
        lerFixtureApi('detalhe_sem_corretor.json')! as Map<String, Object?>;
    final idSemCorretor = semCorretor['id']! as int;

    testWidgets(
      'imóvel cujo corretor foi desativado (corretor_responsavel nulo) abre '
      'sem a seção "Corretor responsável"',
      (tester) async {
        final apiDoDetalhe = ApiFalsa(
          latencia: const Duration(milliseconds: 300),
        );
        registrarDetalheEPerfis(apiDoDetalhe);
        await pumpVitrine(tester);

        await tocarNoCard(tester, idSemCorretor);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(milliseconds: 300));

        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(
          naPagina(find.text(semCorretor['descricao']! as String)),
          findsOneWidget,
        );
        expect(naPagina(find.text('Corretor responsável')), findsNothing);
        expect(naPagina(find.byType(CartaoCorretor)), findsNothing);
        expect(
          apiDoDetalhe.requisicoes.where(
            (uri) => uri.path.startsWith('/api/publico/corretores/'),
          ),
          isEmpty,
        );
      },
    );

    testWidgets(
      'o perfil do corretor abre com a prévia (nome e foto do detalhe) na '
      'hora e depois busca o perfil por id: exatamente uma requisição a '
      '/api/publico/corretores/<id>/ (PERF-04, D-05)',
      (tester) async {
        final apiDoDetalhe = ApiFalsa(
          latencia: const Duration(milliseconds: 300),
        );
        registrarDetalheEPerfis(apiDoDetalhe);
        await abrirPerfilDoCorretorDaCasa(
          tester,
          const Duration(milliseconds: 300),
        );
        await tester.pump(const Duration(milliseconds: 100));

        bool ehOPerfil(Uri uri) =>
            uri.path == '/api/publico/corretores/$idCorretor/';
        bool ehAVitrine(Uri uri) =>
            uri.path == '/api/publico/corretores/$idCorretor/imoveis/';

        // Prévia na hora: nome e foto vêm do detalhe, o perfil ainda a caminho.
        expect(find.byType(PerfilCorretorScreen), findsOneWidget);
        expect(noPerfil(find.text(nomeCorretor)), findsOneWidget);
        expect(noPerfil(find.byType(AvatarCorretor)), findsOneWidget);
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        expect(noPerfil(find.text('CRECI $creciCorretor')), findsNothing);
        expect(noPerfil(find.textContaining('@')), findsNothing);
        expect(apiDoDetalhe.requisicoes.where(ehOPerfil), hasLength(1));
        expect(apiDoDetalhe.requisicoes.where(ehAVitrine), isEmpty);

        // O perfil chega: CRECI e dados do corretor capturado.
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(noPerfil(find.text('CRECI $creciCorretor')), findsOneWidget);
        expect(
          noPerfil(find.text(perfilCorretor['apresentacao']! as String)),
          findsOneWidget,
        );
        expect(apiDoDetalhe.requisicoes.where(ehOPerfil), hasLength(1));

        // Só depois do perfil a vitrine do corretor é pedida (uma vez, p1).
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();
        expect(apiDoDetalhe.requisicoes.where(ehAVitrine), hasLength(1));
        expect(noPerfil(find.byType(ImovelCard)), findsWidgets);
      },
    );
  });

  group('natureza no wire real (D-17, A-03)', () {
    testWidgets(
      'o card do lote capturado abre "Sobre o lote" com parcelamento e o card '
      '"Quadra e loteamento" com infraestrutura em chips e áreas de lazer em '
      'texto corrido',
      (tester) async {
        registrarDetalhe(
          ImovelDetalheRemoteDataSource(
            ApiFalsa(latencia: const Duration(milliseconds: 300)).criarDio(),
          ),
        );
        await pumpVitrine(tester);

        await tocarNoCard(tester, idLote);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(milliseconds: 300));

        expect(naPagina(find.text('Sobre o lote')), findsOneWidget);
        expect(naPagina(find.text('Número do lote')), findsOneWidget);
        expect(
          naPagina(find.text(blocoLote['numero']! as String)),
          findsOneWidget,
        );
        expect(naPagina(find.text('Entrada mínima')), findsOneWidget);
        expect(naPagina(find.text('R\$\u00A023.500')), findsOneWidget);
        expect(naPagina(find.text('Parcelas máximas')), findsOneWidget);
        expect(naPagina(find.text('120')), findsOneWidget);
        expect(
          naPagina(find.text('Condições de parcelamento')),
          findsOneWidget,
        );
        expect(
          naPagina(find.text(blocoLote['condicoes_parcelamento']! as String)),
          findsOneWidget,
        );
        // O lote não tem preço próprio: o cabeçalho mostra o de venda.
        expect(naPagina(find.text('Preço do lote')), findsNothing);
        expect(naPagina(find.textContaining('235.000')), findsOneWidget);

        expect(naPagina(find.text('Quadra e loteamento')), findsOneWidget);
        expect(naPagina(find.text('Infraestrutura')), findsOneWidget);
        for (final rotulo in [
          'Asfalto',
          'Água',
          'Energia',
          'Esgoto',
          'Iluminação pública',
        ]) {
          expect(
            naPagina(
              find.descendant(
                of: find.byType(Chip),
                matching: find.text(rotulo),
              ),
            ),
            findsOneWidget,
          );
        }
        // As áreas de lazer são um Text com a frase inteira, nunca chips.
        final frase = loteamentoDoLote['areas_de_lazer']! as String;
        expect(naPagina(find.text('Áreas de lazer')), findsOneWidget);
        expect(naPagina(find.text(frase)), findsOneWidget);
        expect(
          naPagina(
            find.descendant(of: find.byType(Chip), matching: find.text(frase)),
          ),
          findsNothing,
        );
      },
    );
  });

  group('natureza no wire real: terreno, apartamento e casa (D-17, A-04)', () {
    /// Abre o card [id] da vitrine e deixa o detalhe capturado chegar.
    Future<void> abrirDetalhe(WidgetTester tester, int id) async {
      registrarDetalhe(
        ImovelDetalheRemoteDataSource(
          ApiFalsa(latencia: const Duration(milliseconds: 300)).criarDio(),
        ),
      );
      await pumpVitrine(tester);
      await tocarNoCard(tester, id);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await esperarDetalhe(tester, const Duration(milliseconds: 300));
    }

    testWidgets('terreno capturado: duas laterais, topografia e uso permitido '
        'em português, sem o código em maiúsculas', (tester) async {
      await abrirDetalhe(tester, idTerreno);

      final bloco = terreno['terreno']! as Map<String, Object?>;
      expect(bloco['lateral_esquerda'], '25.00');
      expect(bloco['lateral_direita'], '25.00');
      expect(naPagina(find.text('Sobre o terreno')), findsOneWidget);
      expect(naPagina(find.text('Lateral esquerda')), findsOneWidget);
      expect(naPagina(find.text('Lateral direita')), findsOneWidget);
      expect(naPagina(find.text('Laterais')), findsNothing);
      expect(naPagina(find.text('Topografia')), findsOneWidget);
      expect(naPagina(find.text('Aclive')), findsOneWidget);
      expect(naPagina(find.text('Murado')), findsOneWidget);
      expect(naPagina(find.text('Esquina')), findsOneWidget);
      expect(naPagina(find.text('Uso permitido')), findsOneWidget);
      expect(naPagina(find.text('Comercial')), findsOneWidget);
      expect(naPagina(find.text('COMERCIAL')), findsNothing);
      expect(naPagina(find.text('ACLIVE')), findsNothing);
    });

    testWidgets('apartamento capturado: posição solar em português, sem '
        '"Unidade", prédio com "Ano de construção"', (tester) async {
      await abrirDetalhe(tester, idApartamento);

      final predio =
          (apartamento['apartamento']! as Map<String, Object?>)['predio']!
              as Map<String, Object?>;
      expect(naPagina(find.text('Sobre o apartamento')), findsOneWidget);
      expect(naPagina(find.text('Posição solar')), findsOneWidget);
      expect(naPagina(find.text('Poente')), findsOneWidget);
      expect(naPagina(find.text('POENTE')), findsNothing);
      expect(naPagina(find.text('Unidade')), findsNothing);
      expect(naPagina(find.text('Prédio')), findsOneWidget);
      expect(naPagina(find.text(predio['nome']! as String)), findsOneWidget);
      expect(naPagina(find.text('Ano de construção')), findsOneWidget);
      expect(
        naPagina(find.text('${predio['ano_construcao']}')),
        findsOneWidget,
      );
      expect(naPagina(find.text('Unidades por andar')), findsNothing);
    });

    testWidgets('casa capturada: banheiros, salas, pavimentos, piscina, '
        'quintal, churrasqueira e mobiliada entram como no JSON', (
      tester,
    ) async {
      await abrirDetalhe(tester, idCasa);

      final bloco = casa['casa']! as Map<String, Object?>;
      expect(naPagina(find.text('Sobre a casa')), findsOneWidget);
      expect(naPagina(find.text('${bloco['banheiros']}')), findsWidgets);
      expect(naPagina(find.text('banheiros')), findsOneWidget);
      expect(naPagina(find.text('Salas')), findsOneWidget);
      expect(naPagina(find.text('Pavimentos')), findsOneWidget);
      expect(naPagina(find.text('Piscina')), findsOneWidget);
      expect(naPagina(find.text('Quintal')), findsOneWidget);
      expect(naPagina(find.text('Churrasqueira')), findsWidgets);
      expect(naPagina(find.text('Mobiliada')), findsOneWidget);
    });
  });

  group('empresa indisponível (PERF-01, D-15, Pitfall 3)', () {
    /// Do detalhe da casa ao perfil do corretor carregado e ao toque no cartão
    /// "Ver página do anunciante" (a empresa sobe com a latência de [api]).
    Future<void> abrirPaginaDaEmpresa(WidgetTester tester, ApiFalsa api) async {
      registrarDetalheEPerfis(api);
      await abrirPerfilDoCorretorDaCasa(
        tester,
        const Duration(milliseconds: 300),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(noPerfil(find.text('CRECI $creciCorretor')), findsOneWidget);

      await tester.scrollUntilVisible(
        noPerfil(find.text('Ver página do anunciante')),
        100,
        scrollable: rolavelDe(PerfilCorretorScreen),
      );
      await tester.tap(noPerfil(find.text('Ver página do anunciante')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
    }

    testWidgets(
      'empresa que a API não serve mais (404, lacuna da WEB 02): corretor -> '
      '"Ver página do anunciante" -> "Esta página não está mais disponível" '
      'sem consultar a vitrine da empresa -> "Voltar" devolve o perfil do '
      'corretor carregado',
      (tester) async {
        final api = ApiFalsa(latencia: const Duration(milliseconds: 300))
          ..responder(
            (uri) => uri.path == '/api/publico/empresas/$idEmpresa/',
            status: 404,
            fixture: 'erro_404_perfil.json',
          );
        await abrirPaginaDaEmpresa(tester, api);

        expect(find.byType(PerfilEmpresaScreen), findsOneWidget);
        expect(
          naEmpresa(find.text('Esta página não está mais disponível')),
          findsOneWidget,
        );
        expect(naEmpresa(find.text(nomeEmpresa)), findsNothing);
        expect(naEmpresa(find.byType(CircularProgressIndicator)), findsNothing);
        expect(naEmpresa(find.textContaining('Imóveis de')), findsNothing);
        // A empresa 404 nunca consulta a vitrine dela.
        expect(
          api.requisicoes.where(
            (uri) => uri.path == '/api/publico/empresas/$idEmpresa/imoveis/',
          ),
          isEmpty,
        );

        await voltar(tester, naEmpresa(find.text('Voltar')));

        expect(find.byType(PerfilEmpresaScreen), findsNothing);
        expect(find.byType(PerfilCorretorScreen), findsOneWidget);
        expect(noPerfil(find.text('Ver página do anunciante')), findsOneWidget);
        await tester.scrollUntilVisible(
          noPerfil(find.text('CRECI $creciCorretor')),
          -200,
          scrollable: rolavelDe(PerfilCorretorScreen),
        );
        expect(noPerfil(find.text(nomeCorretor)), findsOneWidget);
        expect(noPerfil(find.text('CRECI $creciCorretor')), findsOneWidget);
      },
    );

    testWidgets('falha do servidor (500) ao abrir a empresa: "Não foi possível '
        'carregar esta página." com "Tentar de novo", e o toque carrega a '
        'empresa capturada', (tester) async {
      final api = ApiFalsa(latencia: const Duration(milliseconds: 300))
        ..falharProximas('/api/publico/empresas/$idEmpresa/', status: 500);
      await abrirPaginaDaEmpresa(tester, api);

      expect(
        naEmpresa(find.text('Não foi possível carregar esta página.')),
        findsOneWidget,
      );
      expect(naEmpresa(find.text('Tentar de novo')), findsOneWidget);
      expect(naEmpresa(find.text(nomeEmpresa)), findsNothing);

      await tester.tap(naEmpresa(find.text('Tentar de novo')));
      await tester.pump();
      expect(naEmpresa(find.byType(CircularProgressIndicator)), findsOneWidget);
      expect(naEmpresa(find.text('Tentar de novo')), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(naEmpresa(find.text(nomeEmpresa)), findsOneWidget);
      expect(naEmpresa(find.text('CRECI $creciEmpresa')), findsOneWidget);
      expect(
        naEmpresa(find.text('Não foi possível carregar esta página.')),
        findsNothing,
      );

      // A vitrine da empresa só nasce com a empresa carregada.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(naEmpresa(find.text('Imóveis de $nomeEmpresa')), findsOneWidget);
      expect(naEmpresa(find.byType(ImovelCard)), findsWidgets);
    });
  });

  group('rolagem infinita da vitrine do corretor (PERF-03, D-09, D-12)', () {
    /// Abre o perfil do corretor capturado direto (`abrirPerfilCorretor`, o
    /// caminho de produção) sobre [api], numa tela de 400x800 que obriga a
    /// rolar, e deixa o perfil e a primeira página da vitrine chegarem.
    Future<void> abrirPerfilDireto(WidgetTester tester, ApiFalsa api) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      registrarCubitsDosPerfis(api.criarDio());

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => abrirPerfilCorretor(
                    context,
                    CorretorResponsavel(id: idCorretor, nome: nomeCorretor),
                  ),
                  child: const Text('Abrir perfil'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir perfil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // O dio leva alguns turnos do event loop a mais que um dublê em memória:
      // um para o perfil, outro para a primeira página da vitrine.
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
    }

    VitrineAnuncianteCarregada estadoDaVitrine(WidgetTester tester) {
      final contexto = tester.element(find.byType(PerfilCorretorScreen));
      return BlocProvider.of<VitrineAnuncianteCubit>(contexto).state
          as VitrineAnuncianteCarregada;
    }

    bool ehAVitrine(Uri uri) =>
        uri.path == '/api/publico/corretores/$idCorretor/imoveis/';

    testWidgets('rolar até "Você chegou ao fim da lista": a segunda requisição segue o '
        '`next` capturado (page=2) e a lista final tem `count` imóveis '
        'distintos, na ordem do servidor', (tester) async {
      final api = ApiFalsa();
      await abrirPerfilDireto(tester, api);
      // A p1 chegou, uma única vez (o título da vitrine fica abaixo da dobra).
      expect(
        estadoDaVitrine(tester).itens,
        hasLength(vitrineCorretorP1.length),
      );
      expect(api.requisicoes.where(ehAVitrine), hasLength(1));

      await tester.scrollUntilVisible(
        find.text('Você chegou ao fim da lista'),
        500,
        scrollable: rolavelDe(PerfilCorretorScreen),
        maxScrolls: 300,
      );

      final paginas = api.requisicoes.where(ehAVitrine).toList();
      expect(paginas, hasLength(2));
      expect(paginas.first.queryParameters.containsKey('page'), isFalse);
      expect(paginas.last.queryParameters['page'], '2');

      final estado = estadoDaVitrine(tester);
      final ids = estado.itens.map((imovel) => imovel.id).toList();
      expect(estado.proximaPagina, isNull);
      expect(estado.carregandoMais, isFalse);
      expect(estado.erroAoCarregarMais, isFalse);
      expect(ids.toSet().length, ids.length, reason: 'sem duplicatas');
      expect(ids.length, totalDaVitrineDoCorretor);
      expect(ids, [
        for (final imovel in [...vitrineCorretorP1, ...vitrineCorretorP2])
          imovel['id']! as int,
      ]);
    });

    testWidgets(
      'falha ao carregar mais (D-09): rodapé "Não foi possível carregar mais '
      'imóveis" com "Tentar de novo"; rolar de novo não repete sozinho e o '
      'toque anexa a página 2 sem repetir imóvel (T-07.1-20)',
      (tester) async {
        final api = ApiFalsa();
        await abrirPerfilDireto(tester, api);
        expect(
          estadoDaVitrine(tester).itens,
          hasLength(vitrineCorretorP1.length),
        );

        // A p1 já chegou: a próxima requisição à vitrine falha uma vez.
        api.falharProximas(
          '/api/publico/corretores/$idCorretor/imoveis/',
          status: 500,
        );
        await tester.scrollUntilVisible(
          find.text('Não foi possível carregar mais imóveis'),
          500,
          scrollable: rolavelDe(PerfilCorretorScreen),
          maxScrolls: 300,
        );
        expect(find.text('Tentar de novo'), findsOneWidget);
        expect(api.requisicoes.where(ehAVitrine), hasLength(2));
        expect(estadoDaVitrine(tester).erroAoCarregarMais, isTrue);
        expect(
          estadoDaVitrine(tester).itens,
          hasLength(vitrineCorretorP1.length),
        );

        // Rolar de novo depois da falha não dispara requisição sozinho.
        final rolavel = rolavelDe(PerfilCorretorScreen);
        await tester.drag(rolavel, const Offset(0, 300));
        await tester.pump();
        await tester.drag(rolavel, const Offset(0, -600));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(api.requisicoes.where(ehAVitrine), hasLength(2));

        // O retry é explícito: o toque anexa a p2 (e só ela).
        await tester.ensureVisible(find.text('Tentar de novo'));
        await tester.pump();
        await tester.tap(find.text('Tentar de novo'));
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final paginas = api.requisicoes.where(ehAVitrine).toList();
        expect(paginas, hasLength(3));
        expect(paginas.last.queryParameters['page'], '2');
        final estado = estadoDaVitrine(tester);
        final ids = estado.itens.map((imovel) => imovel.id).toList();
        expect(estado.erroAoCarregarMais, isFalse);
        expect(ids.toSet().length, ids.length, reason: 'sem duplicatas');
        expect(ids.length, totalDaVitrineDoCorretor);

        await tester.scrollUntilVisible(
          find.text('Você chegou ao fim da lista'),
          500,
          scrollable: rolavelDe(PerfilCorretorScreen),
          maxScrolls: 300,
        );
        expect(
          find.text('Não foi possível carregar mais imóveis'),
          findsNothing,
        );
      },
    );
  });

  group('corretor desativado (PERF-05, D-07, D-15)', () {
    testWidgets(
      'a API responde 404 ao perfil do corretor do detalhe: prévia com '
      'spinner, depois só o aviso "Este corretor não está mais disponível"; '
      'nenhuma requisição à vitrine dele e "Voltar" devolve o detalhe '
      '(T-07.1-19)',
      (tester) async {
        final api = ApiFalsa(latencia: const Duration(milliseconds: 300))
          ..responder(
            (uri) => uri.path == '/api/publico/corretores/$idCorretor/',
            status: 404,
            fixture: 'erro_404_perfil.json',
          );
        registrarDetalheEPerfis(api);
        await abrirPerfilDoCorretorDaCasa(
          tester,
          const Duration(milliseconds: 300),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Prévia na hora: nome e foto do detalhe e spinner.
        expect(find.byType(PerfilCorretorScreen), findsOneWidget);
        expect(noPerfil(find.text(nomeCorretor)), findsOneWidget);
        expect(noPerfil(find.byType(AvatarCorretor)), findsOneWidget);
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );

        // O servidor responde 404: some a prévia, fica só o aviso.
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(
          noPerfil(find.text('Este corretor não está mais disponível')),
          findsOneWidget,
        );
        expect(noPerfil(find.text(nomeCorretor)), findsNothing);
        expect(noPerfil(find.byType(AvatarCorretor)), findsNothing);
        expect(noPerfil(find.byType(CircularProgressIndicator)), findsNothing);
        expect(noPerfil(find.textContaining('Imóveis de')), findsNothing);
        expect(
          api.requisicoes.where(
            (uri) => uri.path == '/api/publico/corretores/$idCorretor/imoveis/',
          ),
          isEmpty,
        );

        await voltar(tester, noPerfil(find.text('Voltar')));

        expect(find.byType(PerfilCorretorScreen), findsNothing);
        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(naPagina(find.text('Descrição')), findsOneWidget);
      },
    );
  });

  group('anunciante sem imóveis e vitrine com erro (D-12)', () {
    testWidgets(
      'corretor válido sem imóveis anunciados (vitrine vazia): aparecem o '
      'CRECI, "Imóveis de <nome>" e "Nenhum imóvel anunciado no momento."',
      (tester) async {
        // Derivada de `vitrine_corretor_p1.json`: a mesma resposta com
        // `results` vazio, `count` 0 e sem próxima página — o que o Django
        // devolve para um corretor sem imóveis.
        final vitrineVazia = {
          ...(lerFixtureApi('vitrine_corretor_p1.json')!
              as Map<String, Object?>),
          'count': 0,
          'next': null,
          'previous': null,
          'results': <Object?>[],
        };
        final api = ApiFalsa(latencia: const Duration(milliseconds: 300))
          ..responder(
            (uri) => uri.path == '/api/publico/corretores/$idCorretor/imoveis/',
            status: 200,
            corpo: vitrineVazia,
          );
        registrarDetalheEPerfis(api);
        await abrirPerfilDoCorretorDaCasa(
          tester,
          const Duration(milliseconds: 300),
        );
        // A transição (400 ms) cobre a latência do perfil (300 ms); a vitrine
        // só nasce com o perfil carregado.
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();

        expect(noPerfil(find.text('CRECI $creciCorretor')), findsOneWidget);
        expect(
          noPerfil(find.text('Imóveis de ${perfilCorretor['nome']}')),
          findsOneWidget,
        );
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

    testWidgets(
      'falha do servidor (500) na vitrine do corretor: "Não foi possível '
      'carregar os imóveis." com "Tentar de novo", e o toque carrega a p1',
      (tester) async {
        var vitrineComFalha = true;
        final api = ApiFalsa(latencia: const Duration(milliseconds: 300))
          ..responder(
            (uri) =>
                vitrineComFalha &&
                uri.path == '/api/publico/corretores/$idCorretor/imoveis/',
            status: 500,
          );
        registrarDetalheEPerfis(api);
        await abrirPerfilDoCorretorDaCasa(
          tester,
          const Duration(milliseconds: 300),
        );
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(noPerfil(find.text('CRECI $creciCorretor')), findsOneWidget);
        expect(
          noPerfil(find.text('Não foi possível carregar os imóveis.')),
          findsOneWidget,
        );
        expect(noPerfil(find.byType(ImovelCard)), findsNothing);

        // O servidor volta ao normal: o toque repete a busca e traz a p1.
        vitrineComFalha = false;
        await tester.scrollUntilVisible(
          noPerfil(find.text('Tentar de novo')),
          100,
          scrollable: rolavelDe(PerfilCorretorScreen),
        );
        await tester.tap(noPerfil(find.text('Tentar de novo')));
        await tester.pump();
        expect(
          noPerfil(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );

        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(
          noPerfil(find.text('Não foi possível carregar os imóveis.')),
          findsNothing,
        );
        expect(noPerfil(find.byType(ImovelCard)), findsWidgets);
      },
    );
  });

  group('outros cards da vitrine (DET-01, API-07)', () {
    testWidgets(
      'tocar em outro card abre o detalhe dele e, depois da latência, mostra '
      'a própria descrição (não a da casa)',
      (tester) async {
        registrarDetalhe(
          ImovelDetalheRemoteDataSource(
            ApiFalsa(latencia: const Duration(milliseconds: 300)).criarDio(),
          ),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idTerreno')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(naPagina(find.text(tituloTerreno)), findsOneWidget);

        await esperarDetalhe(tester, const Duration(milliseconds: 300));

        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(
          naPagina(find.text(terreno['descricao']! as String)),
          findsOneWidget,
        );
        expect(naPagina(find.text(descricaoCasa)), findsNothing);
      },
    );

    testWidgets(
      'servidor sem o imóvel (404): termina em "Este imóvel não está mais '
      'disponível" e "Voltar à vitrine" devolve a vitrine (D-17)',
      (tester) async {
        final apiDoDetalhe =
            ApiFalsa(latencia: const Duration(milliseconds: 300))..responder(
              (uri) => uri.path == '/api/publico/imoveis/$idCasa/',
              status: 404,
              fixture: 'erro_404_detalhe.json',
            );
        registrarDetalhe(
          ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idCasa')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(milliseconds: 300));

        expect(
          naPagina(find.text('Este imóvel não está mais disponível')),
          findsOneWidget,
        );

        await tester.tap(naPagina(find.text('Voltar à vitrine')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(DetalheImovelScreen), findsNothing);
        expect(find.byKey(ValueKey('imovel-$idCasa')), findsOneWidget);
      },
    );
  });

  group('bordas do detalhe real (D-15, D-18, DET-06)', () {
    final semFotos =
        lerFixtureApi('detalhe_sem_fotos.json')! as Map<String, Object?>;
    final idSemFotos = semFotos['id']! as int;

    testWidgets(
      'imóvel sem fotos mostra o placeholder da galeria, sem o contador N/M',
      (tester) async {
        registrarDetalhe(
          ImovelDetalheRemoteDataSource(
            ApiFalsa(latencia: const Duration(milliseconds: 300)).criarDio(),
          ),
        );
        await pumpVitrine(tester);

        await tocarNoCard(tester, idSemFotos);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(milliseconds: 300));

        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(naPagina(find.byType(ImagemPadraoImovel)), findsOneWidget);
        expect(naPagina(find.byType(GaleriaImovel)), findsOneWidget);
        expect(
          naPagina(find.byKey(const ValueKey('contador-fotos'))),
          findsNothing,
        );
        expect(naPagina(find.byType(PageView)), findsNothing);
      },
    );

    testWidgets(
      'imóvel que saiu da vitrine entre a lista e o toque (404 no detalhe): '
      'mostra "Este imóvel não está mais disponível" e nunca o dado velho',
      (tester) async {
        final apiDoDetalhe =
            ApiFalsa(latencia: const Duration(milliseconds: 300))..responder(
              (uri) => uri.path == '/api/publico/imoveis/$idCasa/',
              status: 404,
              fixture: 'erro_404_detalhe.json',
            );
        registrarDetalhe(
          ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idCasa')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(milliseconds: 300));

        expect(
          naPagina(find.text('Este imóvel não está mais disponível')),
          findsOneWidget,
        );
        expect(naPagina(find.text('Descrição')), findsNothing);
        expect(naPagina(find.text(descricaoCasa)), findsNothing);
        expect(naPagina(find.text('Tentar de novo')), findsNothing);
      },
    );

    testWidgets(
      'página fechada com a requisição em voo: o Cubit fechado não emite '
      'nada depois (guarda isClosed, sem exceção)',
      (tester) async {
        final apiDoDetalhe = ApiFalsa(latencia: const Duration(seconds: 2));
        registrarDetalhe(
          ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idCasa')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(DetalheImovelScreen), findsOneWidget);
        expect(apiDoDetalhe.requisicoes, hasLength(1));

        // Fecha a página com a resposta ainda a caminho.
        await tester.tap(find.byTooltip('Voltar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(DetalheImovelScreen), findsNothing);

        // A resposta (2 s de latência) chega depois do close(): nada a emitir
        // nem a lançar.
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(milliseconds: 50));

        expect(tester.takeException(), isNull);
        expect(find.byType(DetalheImovelScreen), findsNothing);
        expect(find.byKey(ValueKey('imovel-$idCasa')), findsOneWidget);
      },
    );
  });

  group('retry', () {
    testWidgets(
      'erro 500 ao abrir mostra a mensagem com "Tentar de novo"; tocar repete '
      'a busca (spinner) e mostra a Descrição quando dá certo (D-17)',
      (tester) async {
        final apiDoDetalhe = ApiFalsa(
          latencia: const Duration(milliseconds: 300),
        )..falharProximas('/api/publico/imoveis/', status: 500);
        registrarDetalhe(
          ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idCasa')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(milliseconds: 300));

        expect(
          naPagina(find.text('Não foi possível carregar este imóvel.')),
          findsOneWidget,
        );
        expect(naPagina(find.text('Tentar de novo')), findsOneWidget);
        expect(naPagina(find.byType(CircularProgressIndicator)), findsNothing);
        expect(apiDoDetalhe.requisicoes, hasLength(1));

        await tester.tap(naPagina(find.text('Tentar de novo')));
        await tester.pump();

        expect(
          naPagina(find.byType(CircularProgressIndicator)),
          findsOneWidget,
        );
        expect(naPagina(find.text('Tentar de novo')), findsNothing);

        await esperarDetalhe(tester, const Duration(milliseconds: 300));

        expect(naPagina(find.text('Descrição')), findsOneWidget);
        expect(
          naPagina(find.text('Não foi possível carregar este imóvel.')),
          findsNothing,
        );
        expect(apiDoDetalhe.requisicoes, hasLength(2));
      },
    );
  });

  group('DI real', () {
    tearDown(() async {
      await getIt.reset();
    });

    test(
      'resolve DetalheImovelCubit e a DataSource remota do detalhe',
      () async {
        await configureDependencies();

        expect(getIt<DetalheImovelCubit>(), isA<DetalheImovelCubit>());
        expect(
          getIt<ImovelDetalheDataSource>(),
          isA<ImovelDetalheRemoteDataSource>(),
        );
      },
    );
  });
}
