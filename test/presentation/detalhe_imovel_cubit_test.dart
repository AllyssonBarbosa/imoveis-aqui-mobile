import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:imoveis_aqui/domain/usecases/obter_detalhe_imovel_usecase.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_state.dart';
import 'package:mocktail/mocktail.dart';

class _ObterDetalheImovelUseCaseFalso extends Mock
    implements ObterDetalheImovelUseCase {}

void main() {
  late _ObterDetalheImovelUseCaseFalso obterDetalhe;

  const detalhe = DetalheImovel(
    id: 42,
    titulo: 'Apartamento',
    finalidade: FinalidadeImovel.venda,
    descricao: 'Texto',
    bairro: 'Cambuí',
    cidade: Cidade(nome: 'Campinas', uf: 'SP'),
  );

  setUp(() {
    obterDetalhe = _ObterDetalheImovelUseCaseFalso();
  });

  DetalheImovelCubit construir() => DetalheImovelCubit(obterDetalhe);

  test('estado inicial é carregando', () {
    expect(construir().state, const DetalheImovelState.carregando());
  });

  blocTest<DetalheImovelCubit, DetalheImovelState>(
    'carregar(42) com sucesso emite [carregado]',
    build: construir,
    setUp: () {
      when(() => obterDetalhe(42))
          .thenAnswer((_) async => const Result.success(detalhe));
    },
    act: (cubit) => cubit.carregar(42),
    expect: () => [const DetalheImovelState.carregado(detalhe)],
  );

  blocTest<DetalheImovelCubit, DetalheImovelState>(
    'ImovelNaoEncontradoException emite [naoEncontrado] (404, D-17)',
    build: construir,
    setUp: () {
      when(() => obterDetalhe(42)).thenAnswer(
        (_) async => Result.failure(const ImovelNaoEncontradoException()),
      );
    },
    act: (cubit) => cubit.carregar(42),
    expect: () => [const DetalheImovelState.naoEncontrado()],
  );

  blocTest<DetalheImovelCubit, DetalheImovelState>(
    'qualquer outra falha emite [erro]',
    build: construir,
    setUp: () {
      when(() => obterDetalhe(42))
          .thenAnswer((_) async => Result.failure(Exception('rede')));
    },
    act: (cubit) => cubit.carregar(42),
    expect: () => [const DetalheImovelState.erro()],
  );

  blocTest<DetalheImovelCubit, DetalheImovelState>(
    'de erro, tentarNovamente() emite [carregando, carregado] no 2º sucesso',
    build: construir,
    setUp: () {
      var chamadas = 0;
      when(() => obterDetalhe(42)).thenAnswer((_) async {
        chamadas++;
        return chamadas == 1
            ? Result.failure(Exception('rede'))
            : const Result.success(detalhe);
      });
    },
    act: (cubit) async {
      await cubit.carregar(42);
      await cubit.tentarNovamente();
    },
    expect: () => [
      const DetalheImovelState.erro(),
      const DetalheImovelState.carregando(),
      const DetalheImovelState.carregado(detalhe),
    ],
    verify: (_) => verify(() => obterDetalhe(42)).called(2),
  );

  blocTest<DetalheImovelCubit, DetalheImovelState>(
    'tentarNovamente() antes de qualquer carregar não emite nada',
    build: construir,
    act: (cubit) => cubit.tentarNovamente(),
    expect: () => <DetalheImovelState>[],
    verify: (_) => verifyNever(() => obterDetalhe(any())),
  );

  blocTest<DetalheImovelCubit, DetalheImovelState>(
    'tentarNovamente() enquanto carregando não emite nem busca de novo',
    build: construir,
    setUp: () {
      when(() => obterDetalhe(42))
          .thenAnswer((_) => Completer<Result<DetalheImovel>>().future);
    },
    act: (cubit) {
      unawaited(cubit.carregar(42));
      return cubit.tentarNovamente();
    },
    expect: () => <DetalheImovelState>[],
    verify: (_) => verify(() => obterDetalhe(42)).called(1),
  );

  test(
    'fechar o Cubit antes do use case terminar não emite nem falha',
    () async {
      final completer = Completer<Result<DetalheImovel>>();
      when(() => obterDetalhe(42)).thenAnswer((_) => completer.future);
      final cubit = construir();
      final emitidos = <DetalheImovelState>[];
      final inscricao = cubit.stream.listen(emitidos.add);

      final carga = cubit.carregar(42);
      await cubit.close();
      completer.complete(const Result.success(detalhe));
      await carga;

      expect(emitidos, isEmpty);
      await inscricao.cancel();
    },
  );
}
