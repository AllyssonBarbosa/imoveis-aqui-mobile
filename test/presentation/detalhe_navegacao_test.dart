import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_remote_datasource.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_remote_datasource.dart';
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
import 'package:imoveis_aqui/presentation/comum/imagem_rede.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/perfil_corretor_screen.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/cartao_corretor.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/galeria_imovel.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/sessao_filtros_vitrine.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
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
  final nomeCorretor =
      (casa['corretor_responsavel']! as Map<String, Object?>)['nome']!
          as String;

  final cardsDaP1 =
      ((lerFixtureApi('lista_campinas_p1.json')!
                  as Map<String, Object?>)['results']!
              as List<Object?>)
          .cast<Map<String, Object?>>();
  final cardDaCasa = cardsDaP1.firstWhere((c) => c['id'] == idCasa);
  final bairroDaCasa = cardDaCasa['bairro']! as String;

  // Um segundo detalhe capturado, de outro imóvel, para provar que cada card
  // abre o próprio detalhe.
  final terreno = lerFixtureApi('detalhe_terreno.json')! as Map<String, Object?>;
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
      'vitrine -> detalhe da casa completo -> perfil do corretor -> volta ao '
      'detalhe -> volta à vitrine intacta',
      (tester) async {
        registrarDetalhe(
          ImovelDetalheRemoteDataSource(
            ApiFalsa(latencia: const Duration(seconds: 1)).criarDio(),
          ),
        );
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idCasa')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(seconds: 1));

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

        // Rola até o corretor e abre o perfil; só nome e foto (D-16).
        await tester.scrollUntilVisible(
          naPagina(find.text(nomeCorretor)),
          200,
          scrollable: naPagina(find.byType(Scrollable)).first,
        );
        expect(naPagina(find.textContaining('example.com')), findsNothing);
        expect(naPagina(find.textContaining('12345-F')), findsNothing);
        await tester.tap(naPagina(find.text(nomeCorretor)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.byType(PerfilCorretorScreen), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(PerfilCorretorScreen),
            matching: find.text(nomeCorretor),
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
        expect(find.byKey(ValueKey('imovel-$idCasa')), findsOneWidget);
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
        registrarDetalhe(ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()));
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
      'o perfil do corretor de outro imóvel abre com o objeto em memória '
      '(nome e foto) e nenhuma chamada a /api/publico/corretores/',
      (tester) async {
        final apiDoDetalhe = ApiFalsa(
          latencia: const Duration(milliseconds: 300),
        );
        registrarDetalhe(ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()));
        await pumpVitrine(tester);

        await tester.tap(find.byKey(ValueKey('imovel-$idCasa')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await esperarDetalhe(tester, const Duration(milliseconds: 300));
        final requisicoesAteAqui = apiDoDetalhe.requisicoes.length;

        await tester.scrollUntilVisible(
          naPagina(find.text(nomeCorretor)),
          200,
          scrollable: naPagina(find.byType(Scrollable)).first,
        );
        await tester.tap(naPagina(find.text(nomeCorretor)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 50));

        final noPerfil = find.byType(PerfilCorretorScreen);
        expect(noPerfil, findsOneWidget);
        expect(
          find.descendant(of: noPerfil, matching: find.text(nomeCorretor)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: noPerfil, matching: find.byType(AvatarCorretor)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: noPerfil, matching: find.textContaining('@')),
          findsNothing,
        );
        expect(apiDoDetalhe.requisicoes, hasLength(requisicoesAteAqui));
        expect(
          apiDoDetalhe.requisicoes.where(
            (uri) => uri.path.startsWith('/api/publico/corretores/'),
          ),
          isEmpty,
        );
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
        expect(naPagina(find.text(blocoLote['numero']! as String)),
            findsOneWidget);
        expect(naPagina(find.text('Entrada mínima')), findsOneWidget);
        expect(naPagina(find.text('R\$\u00A023.500')), findsOneWidget);
        expect(naPagina(find.text('Parcelas máximas')), findsOneWidget);
        expect(naPagina(find.text('120')), findsOneWidget);
        expect(naPagina(find.text('Condições de parcelamento')),
            findsOneWidget);
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
      expect(naPagina(find.text('${predio['ano_construcao']}')), findsOneWidget);
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
        expect(naPagina(find.text(terreno['descricao']! as String)), findsOneWidget);
        expect(naPagina(find.text(descricaoCasa)), findsNothing);
      },
    );

    testWidgets(
      'servidor sem o imóvel (404): termina em "Este imóvel não está mais '
      'disponível" e "Voltar à vitrine" devolve a vitrine (D-17)',
      (tester) async {
        final apiDoDetalhe = ApiFalsa(latencia: const Duration(milliseconds: 300))
          ..responder(
            (uri) => uri.path == '/api/publico/imoveis/$idCasa/',
            status: 404,
            fixture: 'erro_404_detalhe.json',
          );
        registrarDetalhe(ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()));
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
        expect(naPagina(find.byKey(const ValueKey('contador-fotos'))), findsNothing);
        expect(naPagina(find.byType(PageView)), findsNothing);
      },
    );

    testWidgets(
      'imóvel que saiu da vitrine entre a lista e o toque (404 no detalhe): '
      'mostra "Este imóvel não está mais disponível" e nunca o dado velho',
      (tester) async {
        final apiDoDetalhe = ApiFalsa(latencia: const Duration(milliseconds: 300))
          ..responder(
            (uri) => uri.path == '/api/publico/imoveis/$idCasa/',
            status: 404,
            fixture: 'erro_404_detalhe.json',
          );
        registrarDetalhe(ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()));
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
        registrarDetalhe(ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()));
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
        final apiDoDetalhe = ApiFalsa(latencia: const Duration(milliseconds: 300))
          ..falharProximas('/api/publico/imoveis/', status: 500);
        registrarDetalhe(ImovelDetalheRemoteDataSource(apiDoDetalhe.criarDio()));
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
