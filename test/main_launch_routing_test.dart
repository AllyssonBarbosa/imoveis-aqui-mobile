import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/usecases/obter_cidade_salva_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/main.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:imoveis_aqui/presentation/priming/priming_screen.dart';
import 'package:imoveis_aqui/presentation/sessao/botao_sessao_topo.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_state.dart';
import 'package:mocktail/mocktail.dart';

/// Testa APENAS o roteamento/wiring de `main.dart` — QUEM ele chama e com
/// quais argumentos, usando um [CidadeSelecaoCubit] totalmente mockado
/// (`MockCubit`, mesmo padrão de `cidade_selecao_screen_test.dart`). A
/// revalidação real da cidade salva contra a lista atendida (D-08/A2,
/// "nunca tocar GPS") já é provada, com um Cubit REAL + gateways mockados,
/// em `test/presentation/cidade_selecao_cubit_test.dart` e
/// `test/domain/validar_cidade_atendida_usecase_test.dart` — aqui bastaria
/// (e é mais determinístico) verificar que `main.dart` invoca o entrypoint
/// certo, nunca o fluxo de detecção/GPS diretamente.
class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _VitrineCubitFalso extends MockCubit<VitrineState>
    implements VitrineCubit {}

class _ObterCidadeSalvaUseCaseFalso extends Mock
    implements ObterCidadeSalvaUseCase {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

void main() {
  late _CidadeSelecaoCubitFalso cubit;
  late _ObterCidadeSalvaUseCaseFalso obterCidadeSalva;
  late _SessaoCubitFalso sessao;

  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');
  const listaAtendida = [campinas, valinhos];

  setUpAll(() {
    registerFallbackValue(campinas);
  });

  setUp(() {
    cubit = _CidadeSelecaoCubitFalso();
    obterCidadeSalva = _ObterCidadeSalvaUseCaseFalso();
    sessao = _SessaoCubitFalso();
    when(() => sessao.carregar()).thenAnswer((_) async {});
    whenListen(
      sessao,
      const Stream<SessaoState>.empty(),
      initialState: const SessaoState.anonima(),
    );
    getIt.registerSingleton<SessaoCubit>(sessao);

    when(() => cubit.iniciarNaAberturaComCidadeSalva(any()))
        .thenAnswer((_) async {});

    getIt.registerFactory<ObterCidadeSalvaUseCase>(() => obterCidadeSalva);
    getIt.registerFactory<CidadeSelecaoCubit>(() => cubit);
    getIt.registerFactory<SalvarCidadeUseCase>(_SalvarCidadeUseCaseFalso.new);
    // Fake num estado NÃO-animante (`vazioNaCidade`) — os testes deste
    // arquivo usam `pump()` fixo, mas uma nova instância por chamada evita
    // reusar um cubit já fechado quando `_CorpoVitrine` remonta com outra
    // `key` (`Cidade.chaveNatural`).
    getIt.registerFactory<VitrineCubit>(() {
      final vitrineCubit = _VitrineCubitFalso();
      when(() => vitrineCubit.carregar(any())).thenReturn(null);
      whenListen(
        vitrineCubit,
        const Stream<VitrineState>.empty(),
        initialState: const VitrineState(
          conteudo: ConteudoVitrine.vazioNaCidade(),
        ),
      );
      return vitrineCubit;
    });
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('sem cidade salva → rota para PrimingScreen; '
      'iniciarNaAberturaComCidadeSalva nunca é chamado (D-08)', (tester) async {
    when(() => obterCidadeSalva()).thenAnswer((_) async => null);
    whenListen(
      cubit,
      const Stream<CidadeSelecaoState>.empty(),
      initialState: const CidadeSelecaoState.localizando(),
    );

    await tester.pumpWidget(const ImoveisAquiApp());
    await tester.pump();
    await tester.pump();

    expect(find.byType(PrimingScreen), findsOneWidget);
    verifyNever(() => cubit.iniciarNaAberturaComCidadeSalva(any()));
  });

  testWidgets(
    'cidade salva AINDA atendida → chama iniciarNaAberturaComCidadeSalva '
    'com a cidade salva e renderiza o desfecho emitido (D-08)',
    (tester) async {
      when(() => obterCidadeSalva()).thenAnswer((_) async => campinas);
      whenListen(
        cubit,
        Stream<CidadeSelecaoState>.value(
          const CidadeSelecaoState.autorizadaEAtendida(campinas),
        ),
        initialState: const CidadeSelecaoState.autorizadaEAtendida(campinas),
      );

      await tester.pumpWidget(const ImoveisAquiApp());
      await tester.pump();
      await tester.pump();

      expect(find.text('Campinas, SP'), findsOneWidget);
      verify(() => cubit.iniciarNaAberturaComCidadeSalva(campinas)).called(1);
    },
  );

  testWidgets(
    'cidade salva NÃO está mais atendida → main.dart ainda assim delega ao '
    'mesmo entrypoint (a revalidação/fallback para a lista é responsabili'
    'dade do Cubit, RESEARCH Pitfall 5/A2) e renderiza o que ele emitir',
    (tester) async {
      const cidadeRemovida = Cidade(nome: 'Sorocaba', uf: 'SP');
      when(() => obterCidadeSalva()).thenAnswer((_) async => cidadeRemovida);
      whenListen(
        cubit,
        Stream<CidadeSelecaoState>.value(
          const CidadeSelecaoState.autorizadaNaoAtendida(
            'Sorocaba',
            listaAtendida,
          ),
        ),
        initialState: const CidadeSelecaoState.autorizadaNaoAtendida(
          'Sorocaba',
          listaAtendida,
        ),
      );

      await tester.pumpWidget(const ImoveisAquiApp());
      await tester.pump();
      await tester.pump();

      expect(
        find.textContaining('Ainda não atendemos Sorocaba'),
        findsOneWidget,
      );
      expect(find.byType(Card), findsNWidgets(listaAtendida.length));
      verify(() => cubit.iniciarNaAberturaComCidadeSalva(cidadeRemovida))
          .called(1);
    },
  );

  /// Cidade salva ainda atendida: o app entra direto na vitrine de Campinas.
  void prepararVitrine() {
    when(() => obterCidadeSalva()).thenAnswer((_) async => campinas);
    whenListen(
      cubit,
      Stream<CidadeSelecaoState>.value(
        const CidadeSelecaoState.autorizadaEAtendida(campinas),
      ),
      initialState: const CidadeSelecaoState.autorizadaEAtendida(campinas),
    );
  }

  testWidgets(
    'AC-6: com a sessão presa em verificando a vitrine abre igual, sem '
    'rótulo no topo, e a leitura da sessão nunca é esperada',
    (tester) async {
      prepararVitrine();
      // `carregar()` que nunca termina: se a abertura esperasse a sessão, a
      // vitrine jamais apareceria.
      final nuncaTermina = Completer<void>();
      when(() => sessao.carregar()).thenAnswer((_) => nuncaTermina.future);
      whenListen(
        sessao,
        const Stream<SessaoState>.empty(),
        initialState: const SessaoState.verificando(),
      );

      await tester.pumpWidget(const ImoveisAquiApp());
      await tester.pump();
      await tester.pump();

      expect(find.text('Campinas, SP'), findsOneWidget);
      expect(find.byType(BotaoSessaoTopo), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
      expect(find.text('Meu acervo'), findsNothing);
      verify(() => sessao.carregar()).called(1);
    },
  );

  testWidgets('sessão anônima: o topo da vitrine mostra Entrar', (
    tester,
  ) async {
    prepararVitrine();

    await tester.pumpWidget(const ImoveisAquiApp());
    await tester.pump();
    await tester.pump();

    expect(find.text('Campinas, SP'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Meu acervo'), findsNothing);
    // O botão divide a linha do seletor de cidade, no canto direito.
    expect(
      tester.getCenter(find.text('Entrar')).dy,
      closeTo(tester.getCenter(find.text('Campinas, SP')).dy, 24),
    );
    expect(
      tester.getCenter(find.text('Entrar')).dx,
      greaterThan(tester.getCenter(find.text('Campinas, SP')).dx),
    );
    verify(() => sessao.carregar()).called(1);
  });

  testWidgets('sessão autenticada: o topo da vitrine mostra Meu acervo', (
    tester,
  ) async {
    prepararVitrine();
    whenListen(
      sessao,
      const Stream<SessaoState>.empty(),
      initialState: const SessaoState.autenticada(),
    );

    await tester.pumpWidget(const ImoveisAquiApp());
    await tester.pump();
    await tester.pump();

    expect(find.text('Campinas, SP'), findsOneWidget);
    expect(find.text('Meu acervo'), findsOneWidget);
    expect(find.text('Entrar'), findsNothing);
  });

  testWidgets('sem cidade salva o botão do topo é repassado ao PrimingScreen', (
    tester,
  ) async {
    when(() => obterCidadeSalva()).thenAnswer((_) async => null);
    whenListen(
      cubit,
      const Stream<CidadeSelecaoState>.empty(),
      initialState: const CidadeSelecaoState.localizando(),
    );

    await tester.pumpWidget(const ImoveisAquiApp());
    await tester.pump();
    await tester.pump();

    final priming = tester.widget<PrimingScreen>(find.byType(PrimingScreen));
    expect(priming.acaoSessao, isA<BotaoSessaoTopo>());
  });
}
