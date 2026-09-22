import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/gateways/geolocator_gateway.dart';
import 'package:imoveis_aqui/domain/usecases/detectar_cidade_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_cidades_atendidas_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/validar_cidade_atendida_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart';
import 'package:mocktail/mocktail.dart';

class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _GeolocatorGatewayFalso extends Mock implements GeolocatorGateway {}

class _ObterCidadesAtendidasUseCaseFalso extends Mock
    implements ObterCidadesAtendidasUseCase {}

class _DetectarCidadeUseCaseFalso extends Mock
    implements DetectarCidadeUseCase {}

class _ValidarCidadeAtendidaUseCaseFalso extends Mock
    implements ValidarCidadeAtendidaUseCase {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');
  const listaAtendida = [campinas, valinhos];

  group('SeletorCidadeTopo isolado (acessibilidade)', () {
    late _CidadeSelecaoCubitFalso cubit;

    setUp(() {
      cubit = _CidadeSelecaoCubitFalso();
      when(() => cubit.carregarLista()).thenAnswer((_) async {});
    });

    testWidgets(
      'expõe alvo de toque mínimo 48dp e rótulo acessível "Trocar cidade" '
      '(UI-SPEC Spacing exception, Copywriting)',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<CidadeSelecaoCubit>.value(
              value: cubit,
              child: const Scaffold(
                body: SeletorCidadeTopo(cidade: campinas),
              ),
            ),
          ),
        );

        expect(find.text('Campinas, SP'), findsOneWidget);
        // O nó de semântica funde o rótulo do botão com o texto do filho
        // (nome da cidade) — busca por substring, não igualdade exata, já
        // que ambos devem continuar anunciáveis por leitor de tela.
        expect(
          find.bySemanticsLabel(RegExp('Trocar cidade')),
          findsOneWidget,
        );
        expect(
          tester.getSize(find.byType(SeletorCidadeTopo)).height,
          greaterThanOrEqualTo(48),
        );

        handle.dispose();
      },
    );
  });

  group('SeletorCidadeTopo integrado à CidadeSelecaoScreen (LOC-05, D-08)', () {
    late _GeolocatorGatewayFalso geolocator;
    late _ObterCidadesAtendidasUseCaseFalso obterCidadesAtendidas;
    late _DetectarCidadeUseCaseFalso detectarCidade;
    late _ValidarCidadeAtendidaUseCaseFalso validarCidadeAtendida;
    late _SalvarCidadeUseCaseFalso salvarCidade;
    late CidadeSelecaoCubit cubit;

    setUpAll(() {
      registerFallbackValue(campinas);
    });

    setUp(() {
      geolocator = _GeolocatorGatewayFalso();
      obterCidadesAtendidas = _ObterCidadesAtendidasUseCaseFalso();
      detectarCidade = _DetectarCidadeUseCaseFalso();
      validarCidadeAtendida = _ValidarCidadeAtendidaUseCaseFalso();
      salvarCidade = _SalvarCidadeUseCaseFalso();
      cubit = CidadeSelecaoCubit(
        geolocator,
        obterCidadesAtendidas,
        detectarCidade,
        validarCidadeAtendida,
      );

      when(
        () => obterCidadesAtendidas(),
      ).thenAnswer((_) async => const Result.success(listaAtendida));
      when(() => salvarCidade(any())).thenAnswer((_) async {});
    });

    tearDown(() => cubit.close());

    Future<void> abrirNaCidadeEntrada(WidgetTester tester) async {
      cubit.entrarDireto(campinas);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CidadeSelecaoCubit>.value(
            value: cubit,
            child: CidadeSelecaoScreen(salvarCidade: salvarCidade),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'toque no seletor reabre a lista de seleção via carregarLista(), '
      'NUNCA o gateway de localização (LOC-05, D-08)',
      (tester) async {
        await abrirNaCidadeEntrada(tester);

        await tester.tap(find.byType(SeletorCidadeTopo));
        await tester.pumpAndSettle();

        expect(find.byType(Card), findsNWidgets(listaAtendida.length));
        verify(() => obterCidadesAtendidas()).called(1);
        verifyNever(() => geolocator.isServicoHabilitado());
        verifyNever(() => geolocator.verificarPermissao());
        verifyNever(() => geolocator.solicitarPermissao());
        verifyNever(() => geolocator.obterPosicaoAtual());
        verifyNever(() => detectarCidade());
      },
    );

    testWidgets(
      'selecionar uma nova cidade na lista reaberta persiste via '
      'SalvarCidadeUseCase e ela vira o cabeçalho (D-15)',
      (tester) async {
        await abrirNaCidadeEntrada(tester);
        await tester.tap(find.byType(SeletorCidadeTopo));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Valinhos, SP'));
        await tester.pumpAndSettle();

        verify(() => salvarCidade(valinhos)).called(1);
        expect(find.text('Valinhos, SP'), findsOneWidget);
      },
    );
  });
}
