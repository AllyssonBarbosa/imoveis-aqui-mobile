import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/pagina_imoveis.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_usecase.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_state.dart';
import 'package:mocktail/mocktail.dart';

class _BuscarImoveisUseCaseFalso extends Mock
    implements BuscarImoveisUseCase {}

void main() {
  late _BuscarImoveisUseCaseFalso buscarImoveis;

  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');

  Imovel imovelDe(Cidade cidade, int id) => Imovel(
    id: id,
    titulo: 'Imóvel $id',
    finalidade: FinalidadeImovel.venda,
    precoVenda: '100000.00',
    bairro: 'Centro',
    cidade: cidade,
  );

  setUpAll(() {
    registerFallbackValue(const ConsultaImoveis(cidade: campinas));
  });

  setUp(() {
    buscarImoveis = _BuscarImoveisUseCaseFalso();
  });

  VitrineCubit construir() => VitrineCubit(buscarImoveis);

  blocTest<VitrineCubit, VitrineState>(
    'carregar com sucesso não-vazio emite carregando -> carregada',
    build: construir,
    setUp: () {
      when(() => buscarImoveis(any())).thenAnswer(
        (_) async =>
            Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
      );
    },
    act: (cubit) => cubit.carregar(campinas),
    expect: () => [
      const VitrineState(conteudo: ConteudoVitrine.carregando()),
      VitrineState(
        conteudo: ConteudoVitrine.carregada(itens: [imovelDe(campinas, 1)]),
      ),
    ],
  );

  blocTest<VitrineCubit, VitrineState>(
    'carregar com sucesso vazio e sem busca emite vazioNaCidade (D-15)',
    build: construir,
    setUp: () {
      when(() => buscarImoveis(any())).thenAnswer(
        (_) async => const Result.success(PaginaImoveis(itens: [])),
      );
    },
    act: (cubit) => cubit.carregar(campinas),
    expect: () => [
      const VitrineState(conteudo: ConteudoVitrine.carregando()),
      const VitrineState(conteudo: ConteudoVitrine.vazioNaCidade()),
    ],
  );

  blocTest<VitrineCubit, VitrineState>(
    'falha na consulta emite erro',
    build: construir,
    setUp: () {
      when(
        () => buscarImoveis(any()),
      ).thenAnswer((_) async => Result.failure(Exception('falhou')));
    },
    act: (cubit) => cubit.carregar(campinas),
    expect: () => [
      const VitrineState(conteudo: ConteudoVitrine.carregando()),
      const VitrineState(conteudo: ConteudoVitrine.erro()),
    ],
  );

  test(
    'tentarNovamente() a partir do erro re-executa a mesma consulta',
    () async {
      when(
        () => buscarImoveis(any()),
      ).thenAnswer((_) async => Result.failure(Exception('falhou')));

      final cubit = construir();
      final estados = <VitrineState>[];
      final assinatura = cubit.stream.listen(estados.add);

      cubit.carregar(campinas);
      await Future<void>.delayed(Duration.zero);

      when(() => buscarImoveis(any())).thenAnswer(
        (_) async =>
            Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
      );
      cubit.tentarNovamente();
      await Future<void>.delayed(Duration.zero);

      await assinatura.cancel();
      await cubit.close();

      expect(estados, [
        const VitrineState(conteudo: ConteudoVitrine.carregando()),
        const VitrineState(conteudo: ConteudoVitrine.erro()),
        const VitrineState(conteudo: ConteudoVitrine.carregando()),
        VitrineState(
          conteudo: ConteudoVitrine.carregada(itens: [imovelDe(campinas, 1)]),
        ),
      ]);
      verify(() => buscarImoveis(any())).called(2);
    },
  );

  test('tentarNovamente() fora do estado de erro não faz nada', () async {
    when(
      () => buscarImoveis(any()),
    ).thenAnswer((_) async => const Result.success(PaginaImoveis(itens: [])));

    final cubit = construir();
    cubit.carregar(campinas);
    await Future<void>.delayed(Duration.zero);

    cubit.tentarNovamente();
    await Future<void>.delayed(Duration.zero);
    await cubit.close();

    verify(() => buscarImoveis(any())).called(1);
  });

  test(
    'resposta obsoleta é descartada quando a cidade muda com a consulta em '
    'voo (D-13) — só o resultado de Valinhos chega a ser emitido',
    () async {
      final completerCampinas = Completer<Result<PaginaImoveis>>();
      final consultaCampinasIniciada = Completer<void>();
      var chamadas = 0;

      when(() => buscarImoveis(any())).thenAnswer((invocation) {
        chamadas++;
        final consulta =
            invocation.positionalArguments.first as ConsultaImoveis;
        if (consulta.cidade == campinas) {
          consultaCampinasIniciada.complete();
          return completerCampinas.future;
        }
        return Future.value(
          Result.success(PaginaImoveis(itens: [imovelDe(valinhos, 2)])),
        );
      });

      final cubit = construir();
      final estados = <VitrineState>[];
      final assinatura = cubit.stream.listen(estados.add);

      cubit.carregar(campinas);
      await consultaCampinasIniciada.future;
      cubit.carregar(valinhos);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Resposta atrasada de Campinas chega DEPOIS de Valinhos já ter
      // resolvido — precisa ser descartada, nunca sobrescrever a lista
      // atual (D-13).
      completerCampinas.complete(
        Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await assinatura.cancel();
      await cubit.close();

      expect(chamadas, 2);
      final carregadas = estados
          .whereType<VitrineState>()
          .where((estado) => estado.conteudo is VitrineCarregada)
          .toList();
      expect(carregadas, hasLength(1));
      final unica = carregadas.single.conteudo as VitrineCarregada;
      expect(unica.itens.single.cidade, valinhos);
    },
  );

  test(
    'close() durante uma consulta em voo não lança e não emite depois',
    () async {
      final completer = Completer<Result<PaginaImoveis>>();
      when(() => buscarImoveis(any())).thenAnswer((_) => completer.future);

      final cubit = construir();
      cubit.carregar(campinas);
      await Future<void>.delayed(Duration.zero);

      await cubit.close();
      expect(cubit.isClosed, isTrue);

      // Resolver a Future depois do close nunca deve lançar "emit after
      // close" nem qualquer outro erro (T-02-01-04).
      completer.complete(
        Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
      );
      await Future<void>.delayed(Duration.zero);
    },
  );
}
