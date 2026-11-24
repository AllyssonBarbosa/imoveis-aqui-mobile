import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/consulta_contatos.dart';
import 'package:imoveis_aqui/domain/entities/contato_recebido.dart';
import 'package:imoveis_aqui/domain/entities/imovel_com_contato.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
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

  setUpAll(() {
    registerFallbackValue(
      PeriodoContatos(de: DateTime(2026), ate: DateTime(2026)),
    );
    registerFallbackValue(
      const ImovelComContato(id: 0, codigo: '', titulo: ''),
    );
  });

  setUp(() {
    cubit = _CaixaCubitFalso();
    when(() => cubit.carregarMais()).thenAnswer((_) async {});
    when(() => cubit.tentarNovamente()).thenAnswer((_) async {});
    when(() => cubit.carregarOpcoesDeImovel()).thenAnswer((_) async {});
    when(() => cubit.limparImovel()).thenAnswer((_) async {});
    when(() => cubit.limparPeriodo()).thenAnswer((_) async {});
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

  group('chips de filtro (D-18)', () {
    const imovel = ImovelComContato(
      id: 7,
      codigo: 'DEV-7',
      titulo: 'Casa de 7 quartos',
    );
    final periodo = PeriodoContatos(
      de: DateTime(2026, 11, 1),
      ate: DateTime(2026, 11, 22),
    );

    Finder chip(String rotulo) => find.widgetWithText(InputChip, rotulo);

    testWidgets('sem filtro: "Imóvel" e "Período" não selecionados e sem "x"', (
      tester,
    ) async {
      await montar(tester, _carregada([_contato(1)]));

      expect(tester.widget<InputChip>(chip('Imóvel')).selected, isFalse);
      expect(tester.widget<InputChip>(chip('Período')).selected, isFalse);
      expect(find.byTooltip('Limpar filtro de imóvel'), findsNothing);
      expect(find.byTooltip('Limpar filtro de período'), findsNothing);
    });

    testWidgets('os chips ficam entre a linha do número e a lista', (
      tester,
    ) async {
      await montar(tester, _carregada([_contato(1)], semRetorno: 2));

      final linha = tester
          .getBottomLeft(find.text('2 contatos sem retorno'))
          .dy;
      final chips = tester.getTopLeft(chip('Imóvel')).dy;
      final lista = tester.getTopLeft(find.byType(ItemContato)).dy;
      expect(chips, greaterThanOrEqualTo(linha));
      expect(chips, lessThan(lista));
    });

    testWidgets('com imóvel: o chip mostra o código, selecionado, e o "x" '
        'chama limparImovel()', (tester) async {
      await montar(
        tester,
        CaixaContatosState(
          consulta: const ConsultaContatos(imovel: imovel),
          conteudo: ConteudoCaixa.carregada(itens: [_contato(1)]),
        ),
      );

      expect(tester.widget<InputChip>(chip('DEV-7')).selected, isTrue);
      expect(chip('Imóvel'), findsNothing);
      await tester.tap(find.byTooltip('Limpar filtro de imóvel'));

      verify(() => cubit.limparImovel()).called(1);
      verifyNever(() => cubit.limparPeriodo());
    });

    testWidgets('com período: o chip mostra as datas, selecionado, e o "x" '
        'chama limparPeriodo()', (tester) async {
      await montar(
        tester,
        CaixaContatosState(
          consulta: ConsultaContatos(periodo: periodo),
          conteudo: ConteudoCaixa.carregada(itens: [_contato(1)]),
        ),
      );

      expect(
        tester.widget<InputChip>(chip('01/11/2026 – 22/11/2026')).selected,
        isTrue,
      );
      await tester.tap(find.byTooltip('Limpar filtro de período'));

      verify(() => cubit.limparPeriodo()).called(1);
      verifyNever(() => cubit.limparImovel());
    });

    testWidgets('os dois filtros aparecem juntos', (tester) async {
      await montar(
        tester,
        CaixaContatosState(
          consulta: ConsultaContatos(imovel: imovel, periodo: periodo),
          conteudo: ConteudoCaixa.carregada(itens: [_contato(1)]),
        ),
      );

      expect(chip('DEV-7'), findsOneWidget);
      expect(chip('01/11/2026 – 22/11/2026'), findsOneWidget);
    });

    for (final conteudo in <ConteudoCaixa>[
      const ConteudoCaixa.semResultado(),
      const ConteudoCaixa.erro(),
      const ConteudoCaixa.carregando(),
      const ConteudoCaixa.vazio(),
    ]) {
      testWidgets('os chips aparecem em $conteudo', (tester) async {
        await montar(
          tester,
          CaixaContatosState(
            consulta: const ConsultaContatos(imovel: imovel),
            conteudo: conteudo,
          ),
        );

        expect(chip('DEV-7'), findsOneWidget);
        expect(chip('Período'), findsOneWidget);
      });
    }

    testWidgets('sessaoExpirada não mostra os chips', (tester) async {
      await montar(
        tester,
        const CaixaContatosState(conteudo: ConteudoCaixa.sessaoExpirada()),
      );

      expect(find.byType(InputChip), findsNothing);
    });
  });

  group('chip "Período" (D-20)', () {
    final escolhido = PeriodoContatos(
      de: DateTime(2026, 11, 1),
      ate: DateTime(2026, 11, 22),
    );

    testWidgets('tocar abre o seletor com a consulta atual e aplica o '
        'intervalo escolhido', (tester) async {
      PeriodoContatos? recebidoComoAtual = escolhido;
      var chamadas = 0;
      whenListen(
        cubit,
        const Stream<CaixaContatosState>.empty(),
        initialState: _carregada([_contato(1)]),
      );
      when(() => cubit.aplicarPeriodo(any())).thenAnswer((_) async {});
      await tester.pumpWidget(
        MaterialApp(
          home: CaixaContatosScreen(
            criarCubit: () => cubit,
            escolherPeriodo: (context, atual) async {
              chamadas++;
              recebidoComoAtual = atual;
              return escolhido;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(InputChip, 'Período'));
      await tester.pump();

      expect(chamadas, 1);
      expect(recebidoComoAtual, isNull);
      verify(() => cubit.aplicarPeriodo(escolhido)).called(1);
    });

    testWidgets('com período aplicado o seletor recebe o período atual', (
      tester,
    ) async {
      PeriodoContatos? recebidoComoAtual;
      whenListen(
        cubit,
        const Stream<CaixaContatosState>.empty(),
        initialState: CaixaContatosState(
          consulta: ConsultaContatos(periodo: escolhido),
          conteudo: ConteudoCaixa.carregada(itens: [_contato(1)]),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: CaixaContatosScreen(
            criarCubit: () => cubit,
            escolherPeriodo: (context, atual) async {
              recebidoComoAtual = atual;
              return null;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.widgetWithText(InputChip, '01/11/2026 – 22/11/2026'),
      );
      await tester.pump();

      expect(recebidoComoAtual, escolhido);
    });

    testWidgets('fechar o seletor sem escolher não chama nada', (tester) async {
      whenListen(
        cubit,
        const Stream<CaixaContatosState>.empty(),
        initialState: _carregada([_contato(1)]),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: CaixaContatosScreen(
            criarCubit: () => cubit,
            escolherPeriodo: (context, atual) async => null,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(InputChip, 'Período'));
      await tester.pump();

      verifyNever(() => cubit.aplicarPeriodo(any()));
      verifyNever(() => cubit.limparPeriodo());
    });
  });

  group('folha "Filtrar por imóvel" (D-19, D-23)', () {
    const opcaoA = ImovelComContato(
      id: 34,
      codigo: 'DEV-34',
      titulo: 'Apartamento A',
    );
    const opcaoB = ImovelComContato(
      id: 35,
      codigo: 'DEV-35',
      titulo: 'Terreno B',
    );

    CaixaContatosState comOpcoes(
      OpcoesDeImovel opcoes, {
      ImovelComContato? escolhido,
    }) => CaixaContatosState(
      consulta: ConsultaContatos(imovel: escolhido),
      conteudo: ConteudoCaixa.carregada(itens: [_contato(1)]),
      opcoesDeImovel: opcoes,
    );

    Future<void> abrirFolha(WidgetTester tester) async {
      await tester.tap(find.byType(InputChip).first);
      await tester.pumpAndSettle();
    }

    testWidgets('abrir pede as opções ao Cubit e mostra título, "Todos os '
        'imóveis" e "código — título" na ordem recebida', (tester) async {
      await montar(
        tester,
        comOpcoes(const OpcoesDeImovel.carregadas([opcaoA, opcaoB])),
      );

      await abrirFolha(tester);

      verify(() => cubit.carregarOpcoesDeImovel()).called(1);
      expect(find.text('Filtrar por imóvel'), findsOneWidget);
      expect(find.text('Todos os imóveis'), findsOneWidget);
      final rotuloA = find.text('DEV-34 — Apartamento A');
      final rotuloB = find.text('DEV-35 — Terreno B');
      expect(rotuloA, findsOneWidget);
      expect(rotuloB, findsOneWidget);
      expect(
        tester.getTopLeft(rotuloA).dy,
        lessThan(tester.getTopLeft(rotuloB).dy),
      );
    });

    testWidgets('sem imóvel escolhido, "Todos os imóveis" leva o check', (
      tester,
    ) async {
      await montar(
        tester,
        comOpcoes(const OpcoesDeImovel.carregadas([opcaoA, opcaoB])),
      );

      await abrirFolha(tester);

      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Todos os imóveis'),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('o imóvel escolhido leva o check e fica selecionado', (
      tester,
    ) async {
      await montar(
        tester,
        comOpcoes(
          const OpcoesDeImovel.carregadas([opcaoA, opcaoB]),
          escolhido: opcaoB,
        ),
      );

      await abrirFolha(tester);

      final itemB = find.widgetWithText(ListTile, 'DEV-35 — Terreno B');
      expect(tester.widget<ListTile>(itemB).selected, isTrue);
      expect(
        find.descendant(of: itemB, matching: find.byIcon(Icons.check)),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tocar uma opção fecha a folha e chama aplicarImovel(opção)', (
      tester,
    ) async {
      when(() => cubit.aplicarImovel(opcaoA)).thenAnswer((_) async {});
      await montar(
        tester,
        comOpcoes(const OpcoesDeImovel.carregadas([opcaoA, opcaoB])),
      );
      await abrirFolha(tester);

      await tester.tap(find.text('DEV-34 — Apartamento A'));
      await tester.pumpAndSettle();

      expect(find.text('Filtrar por imóvel'), findsNothing);
      verify(() => cubit.aplicarImovel(opcaoA)).called(1);
    });

    testWidgets('tocar "Todos os imóveis" fecha a folha e chama '
        'limparImovel()', (tester) async {
      await montar(
        tester,
        comOpcoes(
          const OpcoesDeImovel.carregadas([opcaoA, opcaoB]),
          escolhido: opcaoA,
        ),
      );
      await abrirFolha(tester);

      await tester.tap(find.text('Todos os imóveis'));
      await tester.pumpAndSettle();

      expect(find.text('Filtrar por imóvel'), findsNothing);
      verify(() => cubit.limparImovel()).called(1);
      verifyNever(() => cubit.aplicarImovel(any()));
    });

    testWidgets('carregando mostra um indicador e nenhuma opção', (
      tester,
    ) async {
      await montar(tester, comOpcoes(const OpcoesDeImovel.carregando()));

      await tester.tap(find.widgetWithText(InputChip, 'Imóvel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Filtrar por imóvel'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(find.text('Todos os imóveis'), findsNothing);
    });

    testWidgets('a folha acompanha o Cubit: carregando e depois as opções', (
      tester,
    ) async {
      final controle = StreamController<CaixaContatosState>.broadcast();
      addTearDown(controle.close);
      whenListen(
        cubit,
        controle.stream,
        initialState: comOpcoes(const OpcoesDeImovel.carregando()),
      );
      await tester.pumpWidget(
        MaterialApp(home: CaixaContatosScreen(criarCubit: () => cubit)),
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(InputChip, 'Imóvel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Todos os imóveis'), findsNothing);

      controle.add(
        comOpcoes(const OpcoesDeImovel.carregadas([opcaoA, opcaoB])),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Todos os imóveis'), findsOneWidget);
      expect(find.text('DEV-34 — Apartamento A'), findsOneWidget);
    });

    testWidgets('erro mostra o texto fixo e "Tentar de novo" pede as opções '
        'outra vez', (tester) async {
      await montar(tester, comOpcoes(const OpcoesDeImovel.erro()));
      await abrirFolha(tester);

      expect(
        find.text('Não foi possível carregar os imóveis.'),
        findsOneWidget,
      );
      verify(() => cubit.carregarOpcoesDeImovel()).called(1);

      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      // O mocktail só conta as chamadas ainda não verificadas: a da abertura
      // já foi conferida acima, sobra a do "Tentar de novo".
      verify(() => cubit.carregarOpcoesDeImovel()).called(1);
      expect(find.text('Todos os imóveis'), findsNothing);
    });
  });

  group('volta ao topo ao trocar de filtro (D-18)', () {
    testWidgets('carregando depois de rolar recomeça a lista no topo', (
      tester,
    ) async {
      final muitos = [for (var i = 1; i <= 30; i++) _contato(i)];
      final controle = StreamController<CaixaContatosState>.broadcast();
      addTearDown(controle.close);
      whenListen(cubit, controle.stream, initialState: _carregada(muitos));
      await tester.pumpWidget(
        MaterialApp(home: CaixaContatosScreen(criarCubit: () => cubit)),
      );
      await tester.pump();
      await tester.drag(find.byType(ListView), const Offset(0, -1500));
      await tester.pump();
      expect(find.byKey(const ValueKey('contato-1')), findsNothing);

      controle.add(const CaixaContatosState());
      await tester.pump();
      controle.add(_carregada(muitos));
      await tester.pump();

      expect(find.byKey(const ValueKey('contato-1')), findsOneWidget);
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
