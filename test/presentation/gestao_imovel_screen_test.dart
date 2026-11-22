import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/imovel_gestao_model.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel_acervo.dart';
import 'package:imoveis_aqui/domain/entities/imovel_gestao.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/apresentacao_gestao.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_state.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/mudar_situacao_cubit.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/mudar_situacao_state.dart';
import 'package:imoveis_aqui/presentation/login/login_cubit.dart';
import 'package:imoveis_aqui/presentation/login/login_screen.dart';
import 'package:imoveis_aqui/presentation/login/login_state.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/apresentacao_imovel.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

class _GestaoImovelCubitFalso extends MockCubit<GestaoImovelState>
    implements GestaoImovelCubit {}

class _MudarSituacaoCubitFalso extends MockCubit<MudarSituacaoState>
    implements MudarSituacaoCubit {}

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

class _LoginCubitFalso extends MockCubit<LoginState> implements LoginCubit {}

/// O imóvel da fixture de um colega (`pode_mudar_situacao: false`).
ImovelGestao _imovelDoColega() => ImovelGestaoModel.fromJson(
  lerFixtureApi('imovel_gestao_sem_permissao.json')! as Map<String, Object?>,
).paraEntidade();

ImovelAcervo _previa({bool naVitrine = true}) => ImovelAcervo(
  id: 36,
  codigo: 'DEV-INDAIATUBA-04',
  titulo: 'Título da prévia',
  finalidade: FinalidadeImovel.venda,
  precoVenda: '90000.00',
  fotoCapa: 'http://exemplo.test/capa.jpg',
  situacao: SituacaoImovel.disponivel,
  meuImovel: true,
  naVitrine: naVitrine,
);

/// O imóvel lido da fixture capturada do Django, pelo Model (wire real).
ImovelGestao _imovelDaFixture() => ImovelGestaoModel.fromJson(
  lerFixtureApi('imovel_gestao_disponivel.json')! as Map<String, Object?>,
).paraEntidade();

/// Deixa a folha inferior terminar de subir. Nunca `pumpAndSettle`: o
/// indicador de progresso do histórico mantém a animação de pé.
Future<void> _deixarAFolhaSubir(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  late _GestaoImovelCubitFalso cubit;
  late _MudarSituacaoCubitFalso mudar;
  late _SessaoCubitFalso sessao;
  late List<Imovel> abertosNaVitrine;

  setUpAll(() {
    registerFallbackValue(SituacaoImovel.disponivel);
  });

  setUp(() {
    cubit = _GestaoImovelCubitFalso();
    mudar = _MudarSituacaoCubitFalso();
    whenListen(
      mudar,
      const Stream<MudarSituacaoState>.empty(),
      initialState: const MudarSituacaoState(),
    );
    when(
      () => mudar.iniciar(
        imovelId: any(named: 'imovelId'),
        atual: any(named: 'atual'),
      ),
    ).thenAnswer((_) {});
    when(() => mudar.escolher(any())).thenAnswer((_) {});
    when(() => mudar.confirmar()).thenAnswer((_) async {});
    when(() => cubit.registrarMudanca()).thenAnswer((_) async {});
    sessao = _SessaoCubitFalso();
    when(() => sessao.encerrarPorExpiracao()).thenAnswer((_) async {});
    whenListen(
      sessao,
      const Stream<SessaoState>.empty(),
      initialState: const SessaoState.autenticada(),
    );
    abertosNaVitrine = [];
    when(() => cubit.tentarNovamente()).thenAnswer((_) async {});
    when(() => cubit.tentarNovamenteHistorico()).thenAnswer((_) async {});
    when(() => cubit.recarregar()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await getIt.reset();
  });

  Future<void> montar(
    WidgetTester tester,
    GestaoImovelState estado, {
    ImovelAcervo? previa,
    Stream<GestaoImovelState> depois = const Stream<GestaoImovelState>.empty(),
  }) async {
    // Tela de celular: com a foto 16:9 na largura padrão do teste (800) o
    // corpo passaria da área visível e o `ListView` não construiria o resto.
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    whenListen(cubit, depois, initialState: estado);
    await tester.pumpWidget(
      BlocProvider<SessaoCubit>.value(
        value: sessao,
        child: MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<GestaoImovelCubit>.value(value: cubit),
              BlocProvider<MudarSituacaoCubit>.value(value: mudar),
            ],
            child: GestaoImovelScreen(
              previa: previa ?? _previa(),
              aoVerNaVitrine: (context, imovel) async =>
                  abertosNaVitrine.add(imovel),
              construirImagemDeRede: (url) => Text('FOTO:$url'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('carregando: AppBar com o código, cabeçalho da prévia e '
      'indicador de progresso', (tester) async {
    await montar(tester, const GestaoImovelState());

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('DEV-INDAIATUBA-04'),
      ),
      findsOneWidget,
    );
    expect(find.text('Título da prévia'), findsOneWidget);
    expect(find.text('FOTO:http://exemplo.test/capa.jpg'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(tituloSecaoSituacao), findsNothing);
  });

  testWidgets('carregado: título, preço, "Situação", rótulo e "desde" do '
      'servidor, sem endereço nem descrição (D-03, D-05)', (tester) async {
    final imovel = _imovelDaFixture();
    await montar(
      tester,
      GestaoImovelState(imovel: ConteudoImovelGestao.carregado(imovel)),
    );

    expect(find.text(imovel.titulo), findsOneWidget);
    for (final linha in linhasDePrecoPorFinalidade(
      finalidade: imovel.finalidade,
      precoVenda: imovel.precoVenda,
      precoAluguel: imovel.precoAluguel,
    )) {
      expect(find.text(linha), findsOneWidget);
    }
    expect(find.text('Situação'), findsOneWidget);
    expect(find.text('Disponível'), findsOneWidget);
    expect(find.text(textoDesde(imovel.situacaoDesde)), findsOneWidget);
    expect(find.textContaining('Rua das Palmeiras'), findsNothing);
    expect(find.textContaining('Lote de demonstração'), findsNothing);
  });

  testWidgets('"Ver na vitrine" só com naVitrine do servidor; tocar abre o '
      'imóvel de mesmo id (D-02)', (tester) async {
    final imovel = _imovelDaFixture();
    await montar(
      tester,
      GestaoImovelState(imovel: ConteudoImovelGestao.carregado(imovel)),
    );

    expect(find.text('Ver na vitrine'), findsOneWidget);
    await tester.tap(find.text('Ver na vitrine'));
    await tester.pump();

    expect(abertosNaVitrine, hasLength(1));
    expect(abertosNaVitrine.single.id, 36);
  });

  testWidgets('sem naVitrine o botão "Ver na vitrine" não existe', (
    tester,
  ) async {
    final imovel = _imovelDaFixture();
    await montar(
      tester,
      GestaoImovelState(imovel: ConteudoImovelGestao.carregado(imovel)),
      previa: _previa(naVitrine: false),
    );

    expect(find.text('Ver na vitrine'), findsNothing);
    expect(find.text('Situação'), findsOneWidget);
  });

  testWidgets('erro: texto fixo e "Tentar de novo" chama tentarNovamente', (
    tester,
  ) async {
    await montar(
      tester,
      const GestaoImovelState(imovel: ConteudoImovelGestao.erro()),
    );

    expect(find.text('Não foi possível carregar o imóvel.'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    verify(() => cubit.tentarNovamente()).called(1);
  });

  testWidgets('imóvel carregado mostra o histórico; a falha só dele mantém o '
      'imóvel e "Tentar de novo" repete só o histórico', (tester) async {
    final imovel = _imovelDaFixture();
    await montar(
      tester,
      GestaoImovelState(
        imovel: ConteudoImovelGestao.carregado(imovel),
        historico: const ConteudoHistorico.erro(),
      ),
    );

    expect(find.text(imovel.titulo), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Não foi possível carregar o histórico.'), findsOneWidget);
    expect(find.text('Não foi possível carregar o imóvel.'), findsNothing);

    await tester.ensureVisible(find.text('Tentar de novo'));
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    verify(() => cubit.tentarNovamenteHistorico()).called(1);
    verifyNever(() => cubit.tentarNovamente());
  });

  testWidgets('não encontrado: texto fixo em português, sem "Tentar de novo" '
      'e sem texto em inglês (D-10, T-09-05)', (tester) async {
    await montar(
      tester,
      const GestaoImovelState(imovel: ConteudoImovelGestao.naoEncontrado()),
    );

    expect(
      find.text('Este imóvel não está mais no seu acervo.'),
      findsOneWidget,
    );
    expect(find.text('Tentar de novo'), findsNothing);
    expect(find.text('Não foi possível carregar o imóvel.'), findsNothing);
    expect(find.textContaining('No Imovel matches'), findsNothing);
    expect(find.textContaining('Not found'), findsNothing);
  });

  testWidgets('transição para sessão expirada chama encerrarPorExpiracao() e '
      'abre o login com o aviso, só com a rota de baixo', (tester) async {
    final login = _LoginCubitFalso();
    whenListen(
      login,
      const Stream<LoginState>.empty(),
      initialState: const LoginState.editando(),
    );
    getIt.registerFactory<LoginCubit>(() => login);

    await montar(
      tester,
      const GestaoImovelState(),
      depois: Stream.value(
        const GestaoImovelState(imovel: ConteudoImovelGestao.sessaoExpirada()),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => sessao.encerrarPorExpiracao()).called(1);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(GestaoImovelScreen), findsNothing);
    expect(find.text('Sua sessão terminou. Entre de novo.'), findsOneWidget);
  });

  testWidgets('sessão já expirada quando a tela abre também volta ao login '
      '(resposta chegou antes do primeiro quadro)', (tester) async {
    final login = _LoginCubitFalso();
    whenListen(
      login,
      const Stream<LoginState>.empty(),
      initialState: const LoginState.editando(),
    );
    getIt.registerFactory<LoginCubit>(() => login);

    await montar(
      tester,
      const GestaoImovelState(imovel: ConteudoImovelGestao.sessaoExpirada()),
    );
    await tester.pumpAndSettle();

    verify(() => sessao.encerrarPorExpiracao()).called(1);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(GestaoImovelScreen), findsNothing);
  });

  testWidgets('falhasAoAtualizar aumentando mostra o SnackBar "Não foi '
      'possível atualizar agora." e o conteúdo continua na tela', (
    tester,
  ) async {
    final imovel = _imovelDaFixture();
    final carregado = GestaoImovelState(
      imovel: ConteudoImovelGestao.carregado(imovel),
    );
    await montar(
      tester,
      carregado,
      depois: Stream.value(carregado.copyWith(falhasAoAtualizar: 1)),
    );
    await tester.pump();

    expect(find.text('Não foi possível atualizar agora.'), findsOneWidget);
    expect(find.text(imovel.titulo), findsOneWidget);
    expect(find.text('Situação'), findsOneWidget);
  });

  testWidgets('sem falha de atualização o SnackBar não aparece', (
    tester,
  ) async {
    await montar(
      tester,
      GestaoImovelState(
        imovel: ConteudoImovelGestao.carregado(_imovelDaFixture()),
      ),
    );

    expect(find.text('Não foi possível atualizar agora.'), findsNothing);
  });

  testWidgets('arrastar para baixo (RefreshIndicator) chama recarregar()', (
    tester,
  ) async {
    await montar(
      tester,
      GestaoImovelState(
        imovel: ConteudoImovelGestao.carregado(_imovelDaFixture()),
      ),
    );

    expect(find.byType(RefreshIndicator), findsOneWidget);
    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    verify(() => cubit.recarregar()).called(1);
  });

  testWidgets('o puxar para atualizar também vale com o imóvel em erro (a '
      'lista é sempre rolável)', (tester) async {
    await montar(
      tester,
      const GestaoImovelState(imovel: ConteudoImovelGestao.erro()),
    );

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    verify(() => cubit.recarregar()).called(1);
  });

  group('mudar situação (D-04, D-09, D-10, D-18)', () {
    testWidgets('com pode_mudar_situacao verdadeiro aparece "Mudar situação"', (
      tester,
    ) async {
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovelDaFixture()),
        ),
      );

      expect(find.text('Mudar situação'), findsOneWidget);
    });

    testWidgets('com pode_mudar_situacao falso o botão não existe e o '
        'histórico continua visível (colega, AC-6)', (tester) async {
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovelDoColega()),
        ),
      );

      expect(find.text('Mudar situação'), findsNothing);
      expect(find.text('Situação'), findsOneWidget);
      expect(find.text('Histórico'), findsOneWidget);
    });

    testWidgets('com mudou verdadeiro "Ver na vitrine" não aparece mesmo '
        'com naVitrine (D-18)', (tester) async {
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovelDaFixture()),
          mudou: true,
        ),
      );

      expect(find.text('Ver na vitrine'), findsNothing);
      expect(find.text('Mudar situação'), findsOneWidget);
    });

    testWidgets('tocar no botão inicia o Cubit da folha com o id e a situação '
        'atual e abre a folha: chip da atual desabilitado, Confirmar '
        'desabilitado', (tester) async {
      whenListen(
        mudar,
        const Stream<MudarSituacaoState>.empty(),
        initialState: const MudarSituacaoState(
          imovelId: 36,
          atual: SituacaoImovel.disponivel,
        ),
      );
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovelDaFixture()),
        ),
      );

      await tester.tap(find.text('Mudar situação'));
      await _deixarAFolhaSubir(tester);

      verify(
        () => mudar.iniciar(imovelId: 36, atual: SituacaoImovel.disponivel),
      ).called(1);
      expect(find.text('Confirmar'), findsOneWidget);
      for (final situacao in SituacaoImovel.values) {
        expect(
          find.byKey(ValueKey('chip-mudar-${situacao.name}')),
          findsOneWidget,
        );
      }
      final chipDaAtual = tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('chip-mudar-disponivel')),
      );
      expect(chipDaAtual.onSelected, isNull);
      final chipReservado = tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('chip-mudar-reservado')),
      );
      expect(chipReservado.onSelected, isNotNull);
      final confirmar = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirmar'),
      );
      expect(confirmar.onPressed, isNull);
    });

    testWidgets('na folha, tocar em outro chip chama escolher(); com escolha '
        'diferente da atual o Confirmar habilita e chama confirmar()', (
      tester,
    ) async {
      whenListen(
        mudar,
        const Stream<MudarSituacaoState>.empty(),
        initialState: const MudarSituacaoState(
          imovelId: 36,
          atual: SituacaoImovel.disponivel,
          escolhida: SituacaoImovel.reservado,
        ),
      );
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovelDaFixture()),
        ),
      );
      await tester.tap(find.text('Mudar situação'));
      await _deixarAFolhaSubir(tester);

      await tester.tap(find.byKey(const ValueKey('chip-mudar-vendido')));
      await tester.pump();
      verify(() => mudar.escolher(SituacaoImovel.vendido)).called(1);

      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));
      await tester.pump();
      verify(() => mudar.confirmar()).called(1);
    });

    testWidgets('envio que falhou mostra "Não foi possível mudar a situação '
        'agora. Tente de novo." na folha', (tester) async {
      whenListen(
        mudar,
        const Stream<MudarSituacaoState>.empty(),
        initialState: const MudarSituacaoState(
          imovelId: 36,
          atual: SituacaoImovel.disponivel,
          escolhida: SituacaoImovel.reservado,
          envio: EnvioSituacao.falhou(),
        ),
      );
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovelDaFixture()),
        ),
      );
      await tester.tap(find.text('Mudar situação'));
      await _deixarAFolhaSubir(tester);

      expect(
        find.text('Não foi possível mudar a situação agora. Tente de novo.'),
        findsOneWidget,
      );
    });

    testWidgets('transição do Cubit da folha para concluído mostra o '
        'SnackBar "Situação alterada para reservado." e pede a releitura '
        'por registrarMudanca()', (tester) async {
      const base = MudarSituacaoState(
        imovelId: 36,
        atual: SituacaoImovel.disponivel,
        escolhida: SituacaoImovel.reservado,
      );
      whenListen(
        mudar,
        Stream.value(
          base.copyWith(
            envio: const EnvioSituacao.concluido(SituacaoImovel.reservado),
          ),
        ),
        initialState: base,
      );
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovelDaFixture()),
        ),
      );
      await tester.pump();

      expect(find.text('Situação alterada para reservado.'), findsOneWidget);
      verify(() => cubit.registrarMudanca()).called(1);
    });

    testWidgets('sem sucesso nenhum SnackBar de mudança aparece nem a '
        'releitura é pedida', (tester) async {
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovelDaFixture()),
        ),
      );

      expect(find.textContaining('Situação alterada'), findsNothing);
      verifyNever(() => cubit.registrarMudanca());
    });
  });

  group('abrirGestaoImovel devolve se mudou (D-12, A4)', () {
    /// Botão que abre a gestão pelo abridor real, com o Cubit falso em
    /// [estado]; o resultado cai em [resultado].
    Future<void> montarAbridor(
      WidgetTester tester,
      GestaoImovelState estado,
      List<bool> resultado,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      whenListen(
        cubit,
        const Stream<GestaoImovelState>.empty(),
        initialState: estado,
      );
      when(() => cubit.carregar(any())).thenAnswer((_) async {});
      when(() => cubit.close()).thenAnswer((_) async {});
      await tester.pumpWidget(
        BlocProvider<SessaoCubit>.value(
          value: sessao,
          child: MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () async => resultado.add(
                  await abrirGestaoImovel(
                    context,
                    _previa(),
                    criarCubit: () => cubit,
                    criarMudarSituacaoCubit: () => mudar,
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(GestaoImovelScreen), findsOneWidget);
    }

    testWidgets('voltar pelo botão da AppBar com mudou devolve true e fecha o '
        'Cubit', (tester) async {
      final resultado = <bool>[];
      await montarAbridor(
        tester,
        const GestaoImovelState(mudou: true),
        resultado,
      );

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(resultado, [true]);
      verify(() => cubit.carregar(36)).called(1);
      verify(() => cubit.close()).called(1);
      expect(find.byType(GestaoImovelScreen), findsNothing);
    });

    testWidgets('voltar pelo botão do sistema (handlePopRoute) com mudou '
        'devolve true e fecha o Cubit', (tester) async {
      final resultado = <bool>[];
      await montarAbridor(
        tester,
        const GestaoImovelState(mudou: true),
        resultado,
      );

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(resultado, [true]);
      verify(() => cubit.close()).called(1);
      expect(find.byType(GestaoImovelScreen), findsNothing);
    });

    testWidgets('sem mudança devolve false e fecha o Cubit', (tester) async {
      final resultado = <bool>[];
      await montarAbridor(tester, const GestaoImovelState(), resultado);

      await tester.tap(find.byType(BackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(resultado, [false]);
      verify(() => cubit.close()).called(1);
    });
  });
}
