import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/acervo_por_corretor_model.dart';
import 'package:imoveis_aqui/data/models/contatos_por_corretor_model.dart';
import 'package:imoveis_aqui/data/models/mudancas_recentes_model.dart';
import 'package:imoveis_aqui/data/models/totais_por_situacao_model.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/presentation/area_gestor/apresentacao_area_gestor.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_cubit.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_screen.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_state.dart';
import 'package:imoveis_aqui/presentation/contatos/apresentacao_contatos.dart';
import 'package:imoveis_aqui/presentation/contatos/widgets/seletor_periodo.dart';
import 'package:imoveis_aqui/presentation/login/login_cubit.dart';
import 'package:imoveis_aqui/presentation/login/login_screen.dart';
import 'package:imoveis_aqui/presentation/login/login_state.dart';
import 'package:imoveis_aqui/presentation/sessao/rota_vitrine.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

class _AreaGestorCubitFalso extends MockCubit<AreaGestorState>
    implements AreaGestorCubit {}

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

class _LoginCubitFalso extends MockCubit<LoginState> implements LoginCubit {}

Map<String, Object?> _fixture(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

/// Estado com as 4 seções carregadas a partir do wire real.
AreaGestorState _carregado({PeriodoContatos? periodo}) => AreaGestorState(
  totais: EstadoSecao.carregada(
    TotaisPorSituacaoModel.fromJson(
      _fixture('relatorio_acervo.json'),
    ).paraEntidade(),
  ),
  acervo: EstadoSecao.carregada(
    AcervoPorCorretorModel.fromJson(
      _fixture('relatorio_acervo_por_corretor.json'),
    ).paraEntidade(),
  ),
  contatos: EstadoSecao.carregada(
    ContatosPorCorretorModel.fromJson(
      _fixture('relatorio_contatos.json'),
    ).paraEntidade(),
  ),
  mudancas: EstadoSecao.carregada(
    MudancasRecentesModel.fromJson(
      _fixture('relatorio_mudancas.json'),
    ).paraEntidade(),
  ),
  periodo: periodo,
);

void main() {
  late _AreaGestorCubitFalso cubit;
  late _SessaoCubitFalso sessaoDaTela;

  setUpAll(() {
    registerFallbackValue(
      PeriodoContatos(de: DateTime(2026), ate: DateTime(2026)),
    );
    registerFallbackValue(SecaoDaAreaGestor.totais);
  });

  setUp(() {
    cubit = _AreaGestorCubitFalso();
    sessaoDaTela = _SessaoCubitFalso();
    whenListen(
      sessaoDaTela,
      const Stream<SessaoState>.empty(),
      initialState: const SessaoState.autenticada(),
    );
    when(() => cubit.tentarNovamente(any())).thenAnswer((_) async {});
    when(() => cubit.aplicarPeriodo(any())).thenAnswer((_) async {});
    when(() => cubit.limparPeriodo()).thenAnswer((_) async {});
  });

  Future<void> montar(
    WidgetTester tester,
    AreaGestorState estado, {
    EscolherPeriodo? escolherPeriodo,
  }) async {
    // Vista alta para as 4 seções caberem sem rolar.
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    whenListen(
      cubit,
      const Stream<AreaGestorState>.empty(),
      initialState: estado,
    );
    await tester.pumpWidget(
      BlocProvider<SessaoCubit>.value(
        value: sessaoDaTela,
        child: MaterialApp(
          home: AreaGestorScreen(
            criarCubit: () => cubit,
            escolherPeriodo: escolherPeriodo ?? (_, _) async => null,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('abre pedindo a carga uma vez, com título e Sair, sem abas', (
    tester,
  ) async {
    await montar(tester, _carregado());

    verify(() => cubit.carregar()).called(1);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Área do gestor'),
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Sair'), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('as 4 seções aparecem de cima para baixo na ordem de D-06', (
    tester,
  ) async {
    await montar(tester, _carregado());

    final totais = tester.getTopLeft(find.text(tituloSecaoTotais)).dy;
    final acervo = tester.getTopLeft(find.text(tituloSecaoAcervo)).dy;
    final contatos = tester.getTopLeft(find.text(tituloSecaoContatos)).dy;
    final mudancas = tester.getTopLeft(find.text(tituloSecaoMudancas(7))).dy;

    expect(totais, lessThan(acervo));
    expect(acervo, lessThan(contatos));
    expect(contatos, lessThan(mudancas));
  });

  testWidgets('falha só do acervo: as outras seguem e o retry é só dele', (
    tester,
  ) async {
    await montar(
      tester,
      _carregado().copyWith(
        acervo: const EstadoSecao.comFalha(FalhaDaSecao.indisponivel),
      ),
    );

    expect(find.text('Não foi possível carregar.'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.text(textoTotalImoveis(36)), findsOneWidget);
    expect(find.text(textoTotalContatos(4, 3)), findsOneWidget);
    expect(find.text('Disponível → Vendido'), findsOneWidget);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    verify(() => cubit.tentarNovamente(SecaoDaAreaGestor.acervo)).called(1);
    verifyNever(() => cubit.tentarNovamente(SecaoDaAreaGestor.totais));
    verifyNever(() => cubit.tentarNovamente(SecaoDaAreaGestor.contatos));
    verifyNever(() => cubit.tentarNovamente(SecaoDaAreaGestor.mudancas));
  });

  testWidgets('"Tentar de novo" de cada seção repete só aquela seção', (
    tester,
  ) async {
    await montar(
      tester,
      const AreaGestorState(
        totais: EstadoSecao.comFalha(FalhaDaSecao.indisponivel),
        acervo: EstadoSecao.carregando(),
        contatos: EstadoSecao.comFalha(FalhaDaSecao.semPermissao),
        mudancas: EstadoSecao.comFalha(FalhaDaSecao.indisponivel),
      ),
    );

    final botoes = find.text('Tentar de novo');
    expect(botoes, findsNWidgets(3));
    await tester.tap(botoes.at(0));
    await tester.tap(botoes.at(1));
    await tester.tap(botoes.at(2));
    await tester.pump();

    verify(() => cubit.tentarNovamente(SecaoDaAreaGestor.totais)).called(1);
    verify(() => cubit.tentarNovamente(SecaoDaAreaGestor.contatos)).called(1);
    verify(() => cubit.tentarNovamente(SecaoDaAreaGestor.mudancas)).called(1);
    verifyNever(() => cubit.tentarNovamente(SecaoDaAreaGestor.acervo));
  });

  group('período (D-16)', () {
    testWidgets('tocar no chip abre o seletor com o período atual (nulo)', (
      tester,
    ) async {
      PeriodoContatos? recebido;
      var chamadas = 0;
      await montar(
        tester,
        _carregado(),
        escolherPeriodo: (_, atual) async {
          chamadas++;
          recebido = atual;
          return null;
        },
      );

      await tester.tap(find.text('Período'));
      await tester.pump();

      expect(chamadas, 1);
      expect(recebido, isNull);
      // Seletor devolvendo nulo: nada é aplicado.
      verifyNever(() => cubit.aplicarPeriodo(any()));
    });

    testWidgets('um período escolhido vai para o Cubit', (tester) async {
      final escolhido = PeriodoContatos(
        de: DateTime(2026, 11),
        ate: DateTime(2026, 11, 25),
      );
      await montar(
        tester,
        _carregado(),
        escolherPeriodo: (_, _) async => escolhido,
      );

      await tester.tap(find.text('Período'));
      await tester.pump();

      verify(() => cubit.aplicarPeriodo(escolhido)).called(1);
    });

    testWidgets('com período no estado, o "x" chama limparPeriodo()', (
      tester,
    ) async {
      final periodo = PeriodoContatos(
        de: DateTime(2026, 11),
        ate: DateTime(2026, 11, 25),
      );
      await montar(tester, _carregado(periodo: periodo));

      expect(find.text('01/11/2026 – 25/11/2026'), findsOneWidget);
      await tester.tap(find.byTooltip(tooltipLimparPeriodo));
      await tester.pump();

      verify(() => cubit.limparPeriodo()).called(1);
    });
  });

  testWidgets('tocar em "Sair" abre o diálogo "Sair da conta?"', (
    tester,
  ) async {
    await montar(tester, _carregado());

    await tester.tap(find.byTooltip('Sair'));
    await tester.pumpAndSettle();

    expect(find.text('Sair da conta?'), findsOneWidget);
  });

  group('sessão terminada (D-22)', () {
    late _SessaoCubitFalso sessao;

    setUp(() {
      sessao = _SessaoCubitFalso();
      when(() => sessao.encerrarPorExpiracao()).thenAnswer((_) async {});
      whenListen(
        sessao,
        const Stream<SessaoState>.empty(),
        initialState: const SessaoState.autenticada(),
      );
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets(
      'sessaoExpirada encerra a sessão e abre o login com o aviso, só com a '
      'vitrine embaixo',
      (tester) async {
        final login = _LoginCubitFalso();
        whenListen(
          login,
          const Stream<LoginState>.empty(),
          initialState: const LoginState.editando(),
        );
        getIt.registerFactory<LoginCubit>(() => login);
        whenListen(
          cubit,
          Stream.value(_carregado().copyWith(sessaoExpirada: true)),
          initialState: _carregado(),
        );

        // Pilha: [Vitrine (rota da vitrine), Área do gestor].
        await tester.pumpWidget(
          BlocProvider<SessaoCubit>.value(
            value: sessao,
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        settings: configuracaoRotaVitrine,
                        builder: (contextoVitrine) => Scaffold(
                          body: TextButton(
                            onPressed: () => Navigator.of(contextoVitrine).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    AreaGestorScreen(criarCubit: () => cubit),
                              ),
                            ),
                            child: const Text('Vitrine'),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('Priming'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Priming'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Vitrine'));
        await tester.pumpAndSettle();

        verify(() => sessao.encerrarPorExpiracao()).called(1);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(AreaGestorScreen), findsNothing);
        expect(
          find.text('Sua sessão terminou. Entre de novo.'),
          findsOneWidget,
        );

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Vitrine'), findsOneWidget);
        expect(find.text('Priming'), findsNothing);
        expect(find.byType(AreaGestorScreen), findsNothing);
      },
    );
  });
}
