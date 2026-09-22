import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/gateways/geolocator_gateway.dart';
import 'package:imoveis_aqui/domain/usecases/detectar_cidade_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_cidades_atendidas_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/validar_cidade_atendida_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/priming/priming_screen.dart';
import 'package:mocktail/mocktail.dart';

class _GeolocatorGatewayFalso extends Mock implements GeolocatorGateway {}

class _ObterCidadesAtendidasUseCaseFalso extends Mock
    implements ObterCidadesAtendidasUseCase {}

class _DetectarCidadeUseCaseFalso extends Mock
    implements DetectarCidadeUseCase {}

class _ValidarCidadeAtendidaUseCaseFalso extends Mock
    implements ValidarCidadeAtendidaUseCase {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

void main() {
  late _GeolocatorGatewayFalso geolocator;
  late _ObterCidadesAtendidasUseCaseFalso obterCidadesAtendidas;
  late _DetectarCidadeUseCaseFalso detectarCidade;
  late _ValidarCidadeAtendidaUseCaseFalso validarCidadeAtendida;
  late CidadeSelecaoCubit cubit;

  const listaAtendida = <Cidade>[];

  setUp(() {
    geolocator = _GeolocatorGatewayFalso();
    obterCidadesAtendidas = _ObterCidadesAtendidasUseCaseFalso();
    detectarCidade = _DetectarCidadeUseCaseFalso();
    validarCidadeAtendida = _ValidarCidadeAtendidaUseCaseFalso();
    cubit = CidadeSelecaoCubit(
      geolocator,
      obterCidadesAtendidas,
      detectarCidade,
      validarCidadeAtendida,
    );

    // O toque no CTA navega para CidadeSelecaoScreen, que resolve
    // SalvarCidadeUseCase via getIt quando nenhum é injetado por construtor
    // — registramos um fake para o build não quebrar neste teste (o
    // comportamento de seleção/persistência em si é coberto por
    // cidade_selecao_screen_test.dart).
    getIt.registerFactory<SalvarCidadeUseCase>(_SalvarCidadeUseCaseFalso.new);

    when(
      () => geolocator.isServicoHabilitado(),
    ).thenAnswer((_) async => true);
    when(() => geolocator.verificarPermissao()).thenAnswer(
      (_) async => GatewayPermissaoLocalizacao.negada,
    );
    when(() => geolocator.solicitarPermissao()).thenAnswer(
      (_) async => GatewayPermissaoLocalizacao.negada,
    );
    when(
      () => obterCidadesAtendidas(),
    ).thenAnswer((_) async => const Result.success(listaAtendida));
  });

  tearDown(() async {
    await cubit.close();
    await getIt.reset();
  });

  testWidgets(
    'nada do fluxo de permissão dispara antes do toque no CTA (D-05, LOC-01)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CidadeSelecaoCubit>.value(
            value: cubit,
            child: const PrimingScreen(),
          ),
        ),
      );

      verifyNever(() => geolocator.isServicoHabilitado());
      verifyNever(() => geolocator.verificarPermissao());
      verifyNever(() => geolocator.solicitarPermissao());
    },
  );

  testWidgets(
    'toque no CTA "Usar minha localização" aciona o fluxo de detecção — '
    'requestPermission é chamado exatamente uma vez',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CidadeSelecaoCubit>.value(
            value: cubit,
            child: const PrimingScreen(),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Usar minha localização'));
      await tester.pumpAndSettle();

      verify(() => geolocator.isServicoHabilitado()).called(1);
      verify(() => geolocator.verificarPermissao()).called(1);
      verify(() => geolocator.solicitarPermissao()).called(1);
    },
  );
}
