import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel_acervo.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_cubit.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_screen.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_state.dart';
import 'package:imoveis_aqui/presentation/acervo/widgets/cartao_imovel_acervo.dart';
import 'package:imoveis_aqui/presentation/login/login_cubit.dart';
import 'package:imoveis_aqui/presentation/login/login_screen.dart';
import 'package:imoveis_aqui/presentation/login/login_state.dart';
import 'package:imoveis_aqui/presentation/perfis/widgets/rodape_paginacao_lista.dart';
import 'package:imoveis_aqui/presentation/sessao/rota_vitrine.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

class _AcervoCubitFalso extends MockCubit<AcervoState> implements AcervoCubit {}

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

class _LoginCubitFalso extends MockCubit<LoginState> implements LoginCubit {}

ImovelAcervo _imovel(int id, {bool naVitrine = true, bool meuImovel = true}) =>
    ImovelAcervo(
      id: id,
      codigo: 'DEV-$id',
      titulo: 'Imóvel $id',
      finalidade: FinalidadeImovel.venda,
      precoVenda: '100000.00',
      situacao: SituacaoImovel.disponivel,
      meuImovel: meuImovel,
      naVitrine: naVitrine,
    );

void main() {
  late _AcervoCubitFalso cubit;
  late List<ImovelAcervo> abertos;
  late bool resultadoGestao;

  setUpAll(() {
    registerFallbackValue(SituacaoImovel.disponivel);
  });

  setUp(() {
    cubit = _AcervoCubitFalso();
    abertos = [];
    resultadoGestao = false;
    when(() => cubit.recarregar()).thenReturn(null);
    when(() => cubit.carregarMais()).thenAnswer((_) async {});
    when(() => cubit.tentarNovamente()).thenAnswer((_) async {});
    when(() => cubit.escolherSituacao(any())).thenAnswer((_) async {});
  });

  Future<void> montar(WidgetTester tester, AcervoState estado) async {
    whenListen(cubit, const Stream<AcervoState>.empty(), initialState: estado);
    await tester.pumpWidget(
      MaterialApp(
        home: AcervoScreen(
          criarCubit: () => cubit,
          aoAbrirGestao: (context, imovel) async {
            abertos.add(imovel);
            return resultadoGestao;
          },
        ),
      ),
    );
    await tester.pump();
  }

  AcervoState carregada(
    List<ImovelAcervo> itens, {
    String? proximaPagina,
    bool carregandoMais = false,
    bool erroAoCarregarMais = false,
    SituacaoImovel? situacao,
  }) => AcervoState(
    situacao: situacao,
    conteudo: ConteudoAcervo.carregada(
      itens: itens,
      proximaPagina: proximaPagina,
      carregandoMais: carregandoMais,
      erroAoCarregarMais: erroAoCarregarMais,
    ),
  );

  testWidgets('AppBar "Meu acervo", SearchBar com a dica e chips de situação', (
    tester,
  ) async {
    await montar(tester, carregada([_imovel(1)]));

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Meu acervo'),
      ),
      findsOneWidget,
    );
    expect(find.byType(SearchBar), findsOneWidget);
    expect(find.text('Buscar por código ou título'), findsOneWidget);
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Alugado'), findsOneWidget);
    verify(() => cubit.carregar()).called(1);
  });

  group('estados explícitos', () {
    testWidgets('carregando mostra o indicador de progresso', (tester) async {
      await montar(tester, const AcervoState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('vazio', (tester) async {
      await montar(tester, const AcervoState(conteudo: ConteudoAcervo.vazio()));

      expect(find.text('Nenhum imóvel no acervo ainda.'), findsOneWidget);
    });

    testWidgets('semResultado', (tester) async {
      await montar(
        tester,
        const AcervoState(conteudo: ConteudoAcervo.semResultado()),
      );

      expect(
        find.text('Nenhum imóvel encontrado para esta busca ou situação.'),
        findsOneWidget,
      );
      expect(find.text('Nenhum imóvel no acervo ainda.'), findsNothing);
    });

    testWidgets(
      'erro mostra a mensagem e "Tentar de novo" chama tentarNovamente',
      (tester) async {
        await montar(
          tester,
          const AcervoState(conteudo: ConteudoAcervo.erro()),
        );

        expect(
          find.text('Não foi possível carregar o acervo.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Tentar de novo'));

        verify(() => cubit.tentarNovamente()).called(1);
      },
    );

    testWidgets('sessaoExpirada mostra o aviso', (tester) async {
      await montar(
        tester,
        const AcervoState(conteudo: ConteudoAcervo.sessaoExpirada()),
      );

      expect(find.text('Sua sessão terminou. Entre de novo.'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsNothing);
    });
  });

  group('lista', () {
    testWidgets('um cartão por item, na ordem do estado, e o rodapé no fim', (
      tester,
    ) async {
      await montar(tester, carregada([_imovel(3), _imovel(1), _imovel(2)]));

      final codigos = tester
          .widgetList<CartaoImovelAcervo>(find.byType(CartaoImovelAcervo))
          .map((cartao) => cartao.imovel.id)
          .toList();
      expect(codigos, [3, 1, 2]);
      expect(find.byType(RodapePaginacaoLista), findsOneWidget);
      expect(find.text('Você chegou ao fim da lista'), findsOneWidget);
    });

    testWidgets('rodapé de carregando mais mostra o spinner pequeno', (
      tester,
    ) async {
      await montar(
        tester,
        carregada([_imovel(1)], proximaPagina: 'p2', carregandoMais: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'rodapé de erro ao carregar mais: "Tentar de novo" chama tentarNovamente',
      (tester) async {
        await montar(
          tester,
          carregada(
            [_imovel(1)],
            proximaPagina: 'p2',
            erroAoCarregarMais: true,
          ),
        );

        expect(
          find.text('Não foi possível carregar mais imóveis'),
          findsOneWidget,
        );
        await tester.tap(find.text('Tentar de novo'));

        verify(() => cubit.tentarNovamente()).called(1);
      },
    );
  });

  group('controles', () {
    testWidgets('digitar na SearchBar chama buscar(texto)', (tester) async {
      await montar(tester, carregada([_imovel(1)]));

      await tester.enterText(find.byType(SearchBar), 'DEV');

      verify(() => cubit.buscar('DEV')).called(1);
    });

    testWidgets('"Limpar busca" esvazia o campo e chama limparBusca()', (
      tester,
    ) async {
      await montar(tester, carregada([_imovel(1)]));
      expect(find.byTooltip('Limpar busca'), findsNothing);

      await tester.enterText(find.byType(SearchBar), 'DEV');
      await tester.pump();
      await tester.tap(find.byTooltip('Limpar busca'));
      await tester.pump();

      verify(() => cubit.limparBusca()).called(1);
      final campo = tester.widget<SearchBar>(find.byType(SearchBar));
      expect(campo.controller?.text, isEmpty);
    });

    testWidgets('tocar num chip chama escolherSituacao(...)', (tester) async {
      await montar(tester, carregada([_imovel(1)]));

      await tester.tap(find.text('Vendido'));
      verify(() => cubit.escolherSituacao(SituacaoImovel.vendido)).called(1);

      await tester.tap(find.text('Todas'));
      verify(() => cubit.escolherSituacao(null)).called(1);
    });
  });

  group('paginação (D-10)', () {
    final muitos = [for (var i = 1; i <= 20; i++) _imovel(i)];

    testWidgets('rolar até 90% chama carregarMais()', (tester) async {
      await montar(tester, carregada(muitos, proximaPagina: 'p2'));
      verifyNever(() => cubit.carregarMais());

      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pump();

      verify(() => cubit.carregarMais()).called(greaterThan(0));
    });

    testWidgets('primeira página que não enche a tela chama carregarMais() '
        'depois do primeiro quadro', (tester) async {
      await montar(tester, carregada([_imovel(1)], proximaPagina: 'p2'));

      verify(() => cubit.carregarMais()).called(1);
    });

    testWidgets('sem próxima página nunca chama carregarMais()', (
      tester,
    ) async {
      await montar(tester, carregada([_imovel(1)]));

      verifyNever(() => cubit.carregarMais());
    });
  });

  group('toque no cartão (D-02 da Fase 9)', () {
    testWidgets('naVitrine chama aoAbrirGestao com o ImovelAcervo do item', (
      tester,
    ) async {
      await montar(tester, carregada([_imovel(7)]));

      await tester.tap(find.byType(CartaoImovelAcervo));

      expect(abertos, hasLength(1));
      expect(abertos.single.id, 7);
      expect(abertos.single.codigo, 'DEV-7');
      expect(abertos.single.naVitrine, isTrue);
    });

    testWidgets('sem naVitrine também chama aoAbrirGestao com o item', (
      tester,
    ) async {
      await montar(tester, carregada([_imovel(8, naVitrine: false)]));

      await tester.tap(find.byType(CartaoImovelAcervo));

      expect(abertos, hasLength(1));
      expect(abertos.single.id, 8);
      expect(abertos.single.codigo, 'DEV-8');
      expect(abertos.single.naVitrine, isFalse);
    });
  });

  group('volta da gestão (D-12)', () {
    testWidgets('gestão devolvendo true: recarregar() uma vez', (tester) async {
      resultadoGestao = true;
      await montar(tester, carregada([_imovel(7)]));

      await tester.tap(find.byType(CartaoImovelAcervo));
      await tester.pump();

      verify(() => cubit.recarregar()).called(1);
    });

    testWidgets('gestão devolvendo false: nenhuma chamada nova ao Cubit', (
      tester,
    ) async {
      resultadoGestao = false;
      await montar(tester, carregada([_imovel(7)]));

      await tester.tap(find.byType(CartaoImovelAcervo));
      await tester.pump();

      verifyNever(() => cubit.recarregar());
    });
  });

  group('Sair e sessão terminada (08-10)', () {
    late _SessaoCubitFalso sessao;

    setUp(() {
      sessao = _SessaoCubitFalso();
      when(() => sessao.sair()).thenAnswer((_) async {});
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

    /// A vitrine falsa é a primeira rota; o acervo é empurrado por cima, com a
    /// sessão falsa provida acima do `MaterialApp`.
    Future<void> montarEmpilhado(
      WidgetTester tester,
      Stream<AcervoState> depois,
    ) async {
      whenListen(cubit, depois, initialState: carregada([_imovel(1)]));
      await tester.pumpWidget(
        BlocProvider<SessaoCubit>.value(
          value: sessao,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AcervoScreen(
                        criarCubit: () => cubit,
                        aoAbrirGestao: (context, imovel) async => false,
                      ),
                    ),
                  ),
                  child: const Text('Vitrine'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Vitrine'));
      await tester.pumpAndSettle();
    }

    /// Primeiro uso, sem cidade salva: a primeira rota é o priming e a vitrine
    /// (rota nomeada, como o `PrimingScreen` a empurra) vem por cima; o acervo
    /// fecha a pilha `[Priming, Vitrine, Acervo]`.
    Future<void> montarEmpilhadoComPriming(
      WidgetTester tester,
      Stream<AcervoState> depois,
    ) async {
      whenListen(cubit, depois, initialState: carregada([_imovel(1)]));
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
                              builder: (_) => AcervoScreen(
                                criarCubit: () => cubit,
                                aoAbrirGestao: (context, imovel) async => false,
                              ),
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
    }

    testWidgets('a AppBar tem a ação Sair com tooltip', (tester) async {
      await montarEmpilhado(tester, const Stream<AcervoState>.empty());

      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byTooltip('Sair'), findsOneWidget);
    });

    testWidgets('Sair pede confirmação e Cancelar não encerra a sessão', (
      tester,
    ) async {
      await montarEmpilhado(tester, const Stream<AcervoState>.empty());

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();
      expect(find.text('Sair da conta?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => sessao.sair());
      expect(find.byType(AcervoScreen), findsOneWidget);
    });

    testWidgets('confirmar chama sair() e volta à primeira rota', (
      tester,
    ) async {
      await montarEmpilhado(tester, const Stream<AcervoState>.empty());

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Sair'),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => sessao.sair()).called(1);
      expect(find.byType(AcervoScreen), findsNothing);
      expect(find.text('Vitrine'), findsOneWidget);
    });

    testWidgets(
      'Sair no primeiro uso volta à vitrine, não ao priming (WR-01)',
      (tester) async {
        await montarEmpilhadoComPriming(
          tester,
          const Stream<AcervoState>.empty(),
        );

        await tester.tap(find.byTooltip('Sair'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.widgetWithText(FilledButton, 'Sair'),
          ),
        );
        await tester.pumpAndSettle();

        verify(() => sessao.sair()).called(1);
        expect(find.byType(AcervoScreen), findsNothing);
        expect(find.text('Vitrine'), findsOneWidget);
        expect(find.text('Priming'), findsNothing);
      },
    );

    testWidgets(
      'sessaoExpirada no primeiro uso deixa a vitrine, e não o priming, '
      'embaixo do login (WR-01)',
      (tester) async {
        final login = _LoginCubitFalso();
        whenListen(
          login,
          const Stream<LoginState>.empty(),
          initialState: const LoginState.editando(),
        );
        getIt.registerFactory<LoginCubit>(() => login);

        await montarEmpilhadoComPriming(
          tester,
          Stream.value(
            const AcervoState(conteudo: ConteudoAcervo.sessaoExpirada()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Vitrine'), findsOneWidget);
        expect(find.text('Priming'), findsNothing);
        expect(find.byType(AcervoScreen), findsNothing);
      },
    );

    testWidgets(
      'sessaoExpirada marca anônima e abre o login com o aviso, só com a vitrine embaixo',
      (tester) async {
        final login = _LoginCubitFalso();
        whenListen(
          login,
          const Stream<LoginState>.empty(),
          initialState: const LoginState.editando(),
        );
        getIt.registerFactory<LoginCubit>(() => login);

        await montarEmpilhado(
          tester,
          Stream.value(
            const AcervoState(conteudo: ConteudoAcervo.sessaoExpirada()),
          ),
        );
        await tester.pumpAndSettle();

        verify(() => sessao.encerrarPorExpiracao()).called(1);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(AcervoScreen), findsNothing);
        expect(
          find.text('Sua sessão terminou. Entre de novo.'),
          findsOneWidget,
        );

        // O "voltar" do login leva direto à vitrine: nada logado sobrou.
        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Vitrine'), findsOneWidget);
        expect(find.byType(AcervoScreen), findsNothing);
      },
    );
  });
}
