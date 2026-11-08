import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/anunciante_ref.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/pagina_imoveis.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_do_anunciante_usecase.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_state.dart';
import 'package:mocktail/mocktail.dart';

class _BuscarImoveisDoAnuncianteUseCaseFalso extends Mock
    implements BuscarImoveisDoAnuncianteUseCase {}

void main() {
  late _BuscarImoveisDoAnuncianteUseCaseFalso buscar;

  const corretor7 = AnuncianteRef.corretor(7);
  const imoveis = [
    Imovel(
      id: 57,
      titulo: 'Casa 57',
      finalidade: FinalidadeImovel.venda,
      bairro: 'Taquaral',
      cidade: Cidade(nome: 'Campinas', uf: 'SP'),
    ),
    Imovel(
      id: 42,
      titulo: 'Apartamento 42',
      finalidade: FinalidadeImovel.venda,
      bairro: 'Cambuí',
      cidade: Cidade(nome: 'Campinas', uf: 'SP'),
    ),
  ];
  const pagina = PaginaImoveis(itens: imoveis, proximaPagina: 'cursor-2');
  const paginaVazia = PaginaImoveis(itens: []);

  setUpAll(() {
    registerFallbackValue(const AnuncianteRef.corretor(0));
  });

  setUp(() {
    buscar = _BuscarImoveisDoAnuncianteUseCaseFalso();
  });

  VitrineAnuncianteCubit construir() => VitrineAnuncianteCubit(buscar);

  test('estado inicial é carregando', () {
    expect(construir().state, const VitrineAnuncianteState.carregando());
  });

  blocTest<VitrineAnuncianteCubit, VitrineAnuncianteState>(
    'carregar com página não vazia emite [carregada(itens, proximaPagina)] '
    'na ordem recebida',
    build: construir,
    setUp: () {
      when(() => buscar(any()))
          .thenAnswer((_) async => const Result.success(pagina));
    },
    act: (cubit) => cubit.carregar(corretor7),
    expect: () => [
      const VitrineAnuncianteState.carregada(
        itens: imoveis,
        proximaPagina: 'cursor-2',
      ),
    ],
    verify: (_) => verify(() => buscar(corretor7)).called(1),
  );

  blocTest<VitrineAnuncianteCubit, VitrineAnuncianteState>(
    'carregar com página vazia emite [vazia]',
    build: construir,
    setUp: () {
      when(() => buscar(any()))
          .thenAnswer((_) async => const Result.success(paginaVazia));
    },
    act: (cubit) => cubit.carregar(corretor7),
    expect: () => [const VitrineAnuncianteState.vazia()],
  );

  blocTest<VitrineAnuncianteCubit, VitrineAnuncianteState>(
    'carregar com falha emite [erro]',
    build: construir,
    setUp: () {
      when(() => buscar(any()))
          .thenAnswer((_) async => Result.failure(Exception('rede')));
    },
    act: (cubit) => cubit.carregar(corretor7),
    expect: () => [const VitrineAnuncianteState.erro()],
  );

  blocTest<VitrineAnuncianteCubit, VitrineAnuncianteState>(
    'do erro, tentarNovamente emite [carregando, carregada] e repete a busca '
    'do mesmo anunciante',
    build: construir,
    setUp: () {
      var chamadas = 0;
      when(() => buscar(any())).thenAnswer((_) async {
        chamadas++;
        return chamadas == 1
            ? Result.failure(Exception('rede'))
            : const Result.success(pagina);
      });
    },
    act: (cubit) async {
      await cubit.carregar(corretor7);
      await cubit.tentarNovamente();
    },
    expect: () => [
      const VitrineAnuncianteState.erro(),
      const VitrineAnuncianteState.carregando(),
      const VitrineAnuncianteState.carregada(
        itens: imoveis,
        proximaPagina: 'cursor-2',
      ),
    ],
    verify: (_) => verify(() => buscar(corretor7)).called(2),
  );

  blocTest<VitrineAnuncianteCubit, VitrineAnuncianteState>(
    'tentarNovamente antes de carregar não emite nem chama o use case',
    build: construir,
    act: (cubit) => cubit.tentarNovamente(),
    expect: () => <VitrineAnuncianteState>[],
    verify: (_) => verifyNever(() => buscar(any())),
  );

  blocTest<VitrineAnuncianteCubit, VitrineAnuncianteState>(
    'tentarNovamente durante o carregando não dispara busca dupla',
    build: construir,
    setUp: () {
      when(() => buscar(any()))
          .thenAnswer((_) => Completer<Result<PaginaImoveis>>().future);
    },
    act: (cubit) {
      unawaited(cubit.carregar(corretor7));
      return cubit.tentarNovamente();
    },
    expect: () => <VitrineAnuncianteState>[],
    verify: (_) => verify(() => buscar(any())).called(1),
  );

  blocTest<VitrineAnuncianteCubit, VitrineAnuncianteState>(
    'tentarNovamente em carregada não emite nem busca de novo',
    build: construir,
    setUp: () {
      when(() => buscar(any()))
          .thenAnswer((_) async => const Result.success(pagina));
    },
    act: (cubit) async {
      await cubit.carregar(corretor7);
      await cubit.tentarNovamente();
    },
    expect: () => [
      const VitrineAnuncianteState.carregada(
        itens: imoveis,
        proximaPagina: 'cursor-2',
      ),
    ],
    verify: (_) => verify(() => buscar(any())).called(1),
  );

  blocTest<VitrineAnuncianteCubit, VitrineAnuncianteState>(
    'tentarNovamente em vazia não emite nem busca de novo',
    build: construir,
    setUp: () {
      when(() => buscar(any()))
          .thenAnswer((_) async => const Result.success(paginaVazia));
    },
    act: (cubit) async {
      await cubit.carregar(corretor7);
      await cubit.tentarNovamente();
    },
    expect: () => [const VitrineAnuncianteState.vazia()],
    verify: (_) => verify(() => buscar(any())).called(1),
  );

  test('fechar antes da resposta e completar depois não lança', () async {
    final resposta = Completer<Result<PaginaImoveis>>();
    when(() => buscar(any())).thenAnswer((_) => resposta.future);
    final cubit = construir();

    final carregamento = cubit.carregar(corretor7);
    await cubit.close();
    resposta.complete(const Result.success(pagina));

    await expectLater(carregamento, completes);
    expect(cubit.state, const VitrineAnuncianteState.carregando());
  });

  test('tentarNovamente com o Cubit fechado não faz nada', () async {
    when(() => buscar(any()))
        .thenAnswer((_) async => Result.failure(Exception('rede')));
    final cubit = construir();
    await cubit.carregar(corretor7);
    await cubit.close();

    await expectLater(cubit.tentarNovamente(), completes);
    verify(() => buscar(any())).called(1);
  });
}
