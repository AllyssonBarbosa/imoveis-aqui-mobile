import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/contato_recebido.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';
import 'package:imoveis_aqui/presentation/contatos/caixa_contatos_cubit.dart';
import 'package:imoveis_aqui/presentation/contatos/caixa_contatos_screen.dart';
import 'package:imoveis_aqui/presentation/contatos/caixa_contatos_state.dart';
import 'package:imoveis_aqui/presentation/contatos/widgets/item_contato.dart';
import 'package:imoveis_aqui/presentation/login/login_cubit.dart';
import 'package:imoveis_aqui/presentation/login/login_screen.dart';
import 'package:imoveis_aqui/presentation/login/login_state.dart';
import 'package:imoveis_aqui/presentation/perfis/widgets/rodape_paginacao_lista.dart';
import 'package:imoveis_aqui/presentation/sessao/rota_vitrine.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

class _CaixaCubitFalso extends MockCubit<CaixaContatosState>
    implements CaixaContatosCubit {}

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

class _LoginCubitFalso extends MockCubit<LoginState> implements LoginCubit {}

ContatoRecebido _contato(int id) => ContatoRecebido(
  id: id,
  imovelCodigo: 'DEV-$id',
  imovelTitulo: 'Imóvel $id',
  canal: CanalContato.whatsapp,
  criadoEm: DateTime(2026, 11, 20, 9, 30),
  retorno: RetornoContato.pendente,
);

CaixaContatosState _carregada(
  List<ContatoRecebido> itens, {
  int? semRetorno,
  String? proximaPagina,
  bool carregandoMais = false,
  bool erroAoCarregarMais = false,
}) => CaixaContatosState(
  semRetorno: semRetorno,
  conteudo: ConteudoCaixa.carregada(
    itens: itens,
    proximaPagina: proximaPagina,
    carregandoMais: carregandoMais,
    erroAoCarregarMais: erroAoCarregarMais,
  ),
);

void main() {
  late _CaixaCubitFalso cubit;

  setUp(() {
    cubit = _CaixaCubitFalso();
    when(() => cubit.carregarMais()).thenAnswer((_) async {});
    when(() => cubit.tentarNovamente()).thenAnswer((_) async {});
  });

  Future<void> montar(WidgetTester tester, CaixaContatosState estado) async {
    whenListen(
      cubit,
      const Stream<CaixaContatosState>.empty(),
      initialState: estado,
    );
    await tester.pumpWidget(
      MaterialApp(home: CaixaContatosScreen(criarCubit: () => cubit)),
    );
    await tester.pump();
  }

  testWidgets(
    'abre pedindo a carga ao Cubit e mostra o título "Meus contatos"',
    (tester) async {
      await montar(tester, _carregada([_contato(1)]));

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Meus contatos'),
        ),
        findsOneWidget,
      );
      verify(() => cubit.carregar()).called(1);
    },
  );

  group('linha do número (D-04, D-07)', () {
    testWidgets(
      'mostra "2 contatos sem retorno" e os itens na ordem recebida',
      (tester) async {
        await montar(
          tester,
          _carregada([_contato(3), _contato(1), _contato(2)], semRetorno: 2),
        );

        expect(find.text('2 contatos sem retorno'), findsOneWidget);
        final ids = tester
            .widgetList<ItemContato>(find.byType(ItemContato))
            .map((item) => item.contato.id)
            .toList();
        expect(ids, [3, 1, 2]);
      },
    );

    testWidgets('a linha fica logo abaixo da AppBar, acima da lista', (
      tester,
    ) async {
      await montar(tester, _carregada([_contato(1)], semRetorno: 2));

      final base = tester.getBottomLeft(find.byType(AppBar)).dy;
      final linha = tester.getTopLeft(find.text('2 contatos sem retorno')).dy;
      final lista = tester.getTopLeft(find.byType(ItemContato)).dy;
      expect(linha, greaterThanOrEqualTo(base));
      expect(linha, lessThan(lista));
    });

    testWidgets('com 1 mostra o singular', (tester) async {
      await montar(tester, _carregada([_contato(1)], semRetorno: 1));

      expect(find.text('1 contato sem retorno'), findsOneWidget);
    });

    testWidgets('com 0 mostra "Nenhum contato sem retorno"', (tester) async {
      await montar(tester, _carregada([_contato(1)], semRetorno: 0));

      expect(find.text('Nenhum contato sem retorno'), findsOneWidget);
    });

    testWidgets('com null a linha não existe e a lista segue (D-22)', (
      tester,
    ) async {
      await montar(tester, _carregada([_contato(1)]));

      expect(find.textContaining('sem retorno'), findsNothing);
      expect(find.byType(ItemContato), findsOneWidget);
    });
  });

  group('estados explícitos (D-21)', () {
    testWidgets('carregando mostra o indicador de progresso', (tester) async {
      await montar(tester, const CaixaContatosState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('vazio', (tester) async {
      await montar(
        tester,
        const CaixaContatosState(conteudo: ConteudoCaixa.vazio()),
      );

      expect(find.text('Você ainda não recebeu contatos.'), findsOneWidget);
    });

    testWidgets('semResultado', (tester) async {
      await montar(
        tester,
        const CaixaContatosState(conteudo: ConteudoCaixa.semResultado()),
      );

      expect(find.text('Nenhum contato encontrado.'), findsOneWidget);
      expect(find.text('Você ainda não recebeu contatos.'), findsNothing);
    });

    testWidgets(
      'erro mostra a mensagem e "Tentar de novo" chama tentarNovamente',
      (tester) async {
        await montar(
          tester,
          const CaixaContatosState(conteudo: ConteudoCaixa.erro()),
        );

        expect(
          find.text('Não foi possível carregar os contatos.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Tentar de novo'));

        verify(() => cubit.tentarNovamente()).called(1);
      },
    );

    testWidgets('sessaoExpirada mostra o aviso e nenhum botão', (tester) async {
      await montar(
        tester,
        const CaixaContatosState(conteudo: ConteudoCaixa.sessaoExpirada()),
      );

      expect(find.text('Sua sessão terminou. Entre de novo.'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsNothing);
    });
  });

  group('rodapé e rolagem (D-12)', () {
    testWidgets('o último índice é o rodapé, com o fim da lista', (
      tester,
    ) async {
      await montar(tester, _carregada([_contato(1), _contato(2)]));

      expect(find.byType(RodapePaginacaoLista), findsOneWidget);
      expect(find.text('Você chegou ao fim da lista'), findsOneWidget);
    });

    testWidgets(
      'erro ao carregar mais mostra a mensagem dos contatos e o "Tentar de '
      'novo" chama tentarNovamente',
      (tester) async {
        await montar(
          tester,
          _carregada(
            [_contato(1)],
            proximaPagina: 'p2',
            erroAoCarregarMais: true,
          ),
        );

        expect(
          find.text('Não foi possível carregar mais contatos'),
          findsOneWidget,
        );
        expect(
          find.text('Não foi possível carregar mais imóveis'),
          findsNothing,
        );
        await tester.tap(find.text('Tentar de novo'));

        verify(() => cubit.tentarNovamente()).called(1);
      },
    );

    testWidgets('rolar até perto do fim chama carregarMais()', (tester) async {
      final muitos = [for (var i = 1; i <= 20; i++) _contato(i)];
      await montar(tester, _carregada(muitos, proximaPagina: 'p2'));
      verifyNever(() => cubit.carregarMais());

      await tester.drag(find.byType(ListView), const Offset(0, -10000));
      await tester.pump();

      verify(() => cubit.carregarMais()).called(greaterThan(0));
    });

    testWidgets(
      'lista que não preenche a tela pede a próxima página sozinha (Pitfall 7)',
      (tester) async {
        await montar(tester, _carregada([_contato(1)], proximaPagina: 'p2'));

        verify(() => cubit.carregarMais()).called(1);
      },
    );

    testWidgets('sem próxima página nunca chama carregarMais()', (
      tester,
    ) async {
      await montar(tester, _carregada([_contato(1)]));

      verifyNever(() => cubit.carregarMais());
    });
  });

  group('sessão terminada (D-23)', () {
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
          Stream.value(
            const CaixaContatosState(conteudo: ConteudoCaixa.sessaoExpirada()),
          ),
          initialState: _carregada([_contato(1)]),
        );

        // Pilha: [Vitrine (rota da vitrine), Caixa].
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
                                builder: (_) => CaixaContatosScreen(
                                  criarCubit: () => cubit,
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

        verify(() => sessao.encerrarPorExpiracao()).called(1);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(CaixaContatosScreen), findsNothing);
        expect(
          find.text('Sua sessão terminou. Entre de novo.'),
          findsOneWidget,
        );

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Vitrine'), findsOneWidget);
        expect(find.text('Priming'), findsNothing);
        expect(find.byType(CaixaContatosScreen), findsNothing);
      },
    );
  });
}
