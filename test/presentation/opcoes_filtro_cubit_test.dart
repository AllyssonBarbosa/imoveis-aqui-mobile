import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/usecases/obter_bairros_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_caracteristicas_usecase.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/opcoes_filtro_state.dart';
import 'package:mocktail/mocktail.dart';

class _ObterBairrosUseCaseFalso extends Mock implements ObterBairrosUseCase {}

class _ObterCaracteristicasUseCaseFalso extends Mock
    implements ObterCaracteristicasUseCase {}

void main() {
  late _ObterBairrosUseCaseFalso obterBairros;
  late _ObterCaracteristicasUseCaseFalso obterCaracteristicas;

  const campinas = Cidade(nome: 'Campinas', uf: 'SP');

  setUpAll(() {
    registerFallbackValue(campinas);
  });

  setUp(() {
    obterBairros = _ObterBairrosUseCaseFalso();
    obterCaracteristicas = _ObterCaracteristicasUseCaseFalso();
  });

  OpcoesFiltroCubit construir() =>
      OpcoesFiltroCubit(obterBairros, obterCaracteristicas);

  blocTest<OpcoesFiltroCubit, OpcoesFiltroState>(
    'carregar(cidade): começa com os dois carregando e termina com os dois '
    'carregadas, preservando a ordem devolvida pelo use case (sem re-sort)',
    build: construir,
    setUp: () {
      when(
        () => obterBairros(any()),
      ).thenAnswer((_) async => const Result.success(['Taquaral', 'Cambuí']));
      when(() => obterCaracteristicas()).thenAnswer(
        (_) async => const Result.success(['Piscina', 'Churrasqueira']),
      );
    },
    act: (cubit) => cubit.carregar(campinas),
    expect: () => [
      const OpcoesFiltroState(
        bairros: CarregamentoOpcoes.carregando(),
        caracteristicas: CarregamentoOpcoes.carregando(),
      ),
      const OpcoesFiltroState(
        bairros: CarregamentoOpcoes.carregadas(['Taquaral', 'Cambuí']),
        caracteristicas: CarregamentoOpcoes.carregando(),
      ),
      const OpcoesFiltroState(
        bairros: CarregamentoOpcoes.carregadas(['Taquaral', 'Cambuí']),
        caracteristicas: CarregamentoOpcoes.carregadas([
          'Piscina',
          'Churrasqueira',
        ]),
      ),
    ],
  );

  blocTest<OpcoesFiltroCubit, OpcoesFiltroState>(
    'uma falha numa dimensão não impede a outra de carregar — a dimensão '
    'falha fica "falha" enquanto a outra fica "carregadas"',
    build: construir,
    setUp: () {
      when(
        () => obterBairros(any()),
      ).thenAnswer((_) async => Result.failure(Exception('falhou')));
      when(
        () => obterCaracteristicas(),
      ).thenAnswer((_) async => const Result.success(['Piscina']));
    },
    act: (cubit) => cubit.carregar(campinas),
    expect: () => [
      const OpcoesFiltroState(
        bairros: CarregamentoOpcoes.carregando(),
        caracteristicas: CarregamentoOpcoes.carregando(),
      ),
      const OpcoesFiltroState(
        bairros: CarregamentoOpcoes.falha(),
        caracteristicas: CarregamentoOpcoes.carregando(),
      ),
      const OpcoesFiltroState(
        bairros: CarregamentoOpcoes.falha(),
        caracteristicas: CarregamentoOpcoes.carregadas(['Piscina']),
      ),
    ],
  );

  test(
    'tentarNovamente() recarrega SÓ a dimensão em falha, passando por '
    'carregando, sem tocar na dimensão já carregada',
    () async {
      when(
        () => obterBairros(any()),
      ).thenAnswer((_) async => Result.failure(Exception('falhou')));
      when(
        () => obterCaracteristicas(),
      ).thenAnswer((_) async => const Result.success(['Piscina']));

      final cubit = construir();
      await cubit.carregar(campinas);

      expect(cubit.state.bairros, isA<OpcoesFalha>());
      expect(cubit.state.caracteristicas, isA<OpcoesCarregadas>());

      when(
        () => obterBairros(any()),
      ).thenAnswer((_) async => const Result.success(['Cambuí']));

      final estados = <OpcoesFiltroState>[];
      final assinatura = cubit.stream.listen(estados.add);
      await cubit.tentarNovamente();
      await assinatura.cancel();

      expect(estados, [
        OpcoesFiltroState(
          bairros: const CarregamentoOpcoes.carregando(),
          caracteristicas: const CarregamentoOpcoes.carregadas(['Piscina']),
        ),
        const OpcoesFiltroState(
          bairros: CarregamentoOpcoes.carregadas(['Cambuí']),
          caracteristicas: CarregamentoOpcoes.carregadas(['Piscina']),
        ),
      ]);
      verify(() => obterCaracteristicas()).called(1);
      verify(() => obterBairros(any())).called(2);
      await cubit.close();
    },
  );

  test(
    'close() durante carregar() em voo não lança e não emite depois',
    () async {
      final completer = Completer<Result<List<String>>>();
      when(() => obterBairros(any())).thenAnswer((_) => completer.future);
      when(
        () => obterCaracteristicas(),
      ).thenAnswer((_) async => const Result.success(['Piscina']));

      final cubit = construir();
      final futuro = cubit.carregar(campinas);
      await Future<void>.delayed(Duration.zero);

      await cubit.close();
      expect(cubit.isClosed, isTrue);

      completer.complete(const Result.success(['Cambuí']));
      await futuro;
    },
  );
}
