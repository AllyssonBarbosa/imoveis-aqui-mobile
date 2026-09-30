import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/filtros_vitrine.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/ordenacao_vitrine.dart';
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

  group('buscar (VIT-03, D-08, D-09, D-13)', () {
    late List<ConsultaImoveis> consultas;

    /// Registra toda [ConsultaImoveis] enviada ao use case, para asserções
    /// sobre a SEQUÊNCIA de chamadas (não apenas a última) — fica claro que
    /// o debounce coalesceu digitações rápidas numa única chamada.
    VitrineCubit construirComRegistro({
      PaginaImoveis Function(ConsultaImoveis)? respostaPara,
    }) {
      consultas = [];
      when(() => buscarImoveis(any())).thenAnswer((invocation) async {
        final consulta =
            invocation.positionalArguments.first as ConsultaImoveis;
        consultas.add(consulta);
        final pagina =
            respostaPara?.call(consulta) ?? const PaginaImoveis(itens: []);
        return Result.success(pagina);
      });
      return VitrineCubit(buscarImoveis);
    }

    test(
      'buscar("c") (1 caractere) nunca dispara nada, mesmo após 1s de tempo '
      'virtual — a lista atual continua (D-08)',
      () {
        fakeAsync((async) {
          final cubit = construirComRegistro();
          cubit.carregar(campinas);
          async.flushMicrotasks();
          expect(consultas, hasLength(1)); // só o carregar() inicial

          cubit.buscar('c');
          async.elapse(const Duration(seconds: 1));

          expect(consultas, hasLength(1));
          unawaited(cubit.close());
        });
      },
    );

    test(
      'buscar("ca"): nada aos 399 ms, exatamente uma chamada aos 400 ms com '
      'termoBusca "ca" (D-08)',
      () {
        fakeAsync((async) {
          final cubit = construirComRegistro();
          cubit.carregar(campinas);
          async.flushMicrotasks();

          cubit.buscar('ca');
          async.elapse(const Duration(milliseconds: 399));
          expect(consultas, hasLength(1));

          async.elapse(const Duration(milliseconds: 1));
          expect(consultas, hasLength(2));
          expect(consultas.last.busca, 'ca');

          unawaited(cubit.close());
        });
      },
    );

    test(
      'digitar "ca" -> "cas" -> "casa" dentro de 400 ms gera exatamente uma '
      'chamada, com o termo final "casa" (coalescência do debounce)',
      () {
        fakeAsync((async) {
          final cubit = construirComRegistro();
          cubit.carregar(campinas);
          async.flushMicrotasks();

          cubit.buscar('ca');
          async.elapse(const Duration(milliseconds: 100));
          cubit.buscar('cas');
          async.elapse(const Duration(milliseconds: 100));
          cubit.buscar('casa');
          async.elapse(const Duration(milliseconds: 400));

          expect(consultas, hasLength(2)); // carregar() + a única busca
          expect(consultas.last.busca, 'casa');

          unawaited(cubit.close());
        });
      },
    );

    test(
      'buscar("") com termo aplicado recarrega IMEDIATAMENTE com busca '
      'null (sem esperar debounce); buscar("") sem termo aplicado não '
      'dispara nada (D-08)',
      () {
        fakeAsync((async) {
          final cubit = construirComRegistro();
          cubit.carregar(campinas);
          async.flushMicrotasks();

          cubit.buscar(''); // sem termo aplicado ainda
          expect(consultas, hasLength(1));

          cubit.buscar('casa');
          async.elapse(const Duration(milliseconds: 400));
          expect(consultas, hasLength(2));
          expect(cubit.state.termoBusca, 'casa');

          cubit.buscar(''); // termo aplicado — dispara na hora
          expect(consultas, hasLength(3));
          expect(consultas.last.busca, isNull);
          expect(cubit.state.termoBusca, isNull);

          unawaited(cubit.close());
        });
      },
    );

    test(
      'buscar(termo já aplicado) nunca gera uma nova chamada (idempotência)',
      () {
        fakeAsync((async) {
          final cubit = construirComRegistro();
          cubit.carregar(campinas);
          async.flushMicrotasks();

          cubit.buscar('casa');
          async.elapse(const Duration(milliseconds: 400));
          expect(consultas, hasLength(2));

          cubit.buscar('casa');
          async.elapse(const Duration(milliseconds: 400));
          expect(consultas, hasLength(2));

          unawaited(cubit.close());
        });
      },
    );

    test(
      'sucesso vazio com termo aplicado emite semResultado(termo) (D-09); '
      'limparBusca() recarrega imediatamente sem termo',
      () {
        fakeAsync((async) {
          final cubit = construirComRegistro();
          cubit.carregar(campinas);
          async.flushMicrotasks();

          cubit.buscar('casa');
          async.elapse(const Duration(milliseconds: 400));

          expect(
            cubit.state.conteudo,
            const ConteudoVitrine.semResultado('casa'),
          );

          cubit.limparBusca();
          expect(cubit.state.termoBusca, isNull);
          expect(consultas.last.busca, isNull);

          unawaited(cubit.close());
        });
      },
    );

    test(
      'termo A em voo (Completer) é descartado quando o termo B já resolveu '
      '— nunca sobrescreve a lista mais nova (D-13)',
      () {
        fakeAsync((async) {
          final completerA = Completer<Result<PaginaImoveis>>();
          when(() => buscarImoveis(any())).thenAnswer((invocation) {
            final consulta =
                invocation.positionalArguments.first as ConsultaImoveis;
            if (consulta.busca == 'aaaa') return completerA.future;
            return Future.value(
              Result.success(PaginaImoveis(itens: [imovelDe(campinas, 9)])),
            );
          });

          final cubit = VitrineCubit(buscarImoveis);
          cubit.carregar(campinas);
          async.flushMicrotasks();

          cubit.buscar('aaaa');
          async.elapse(const Duration(milliseconds: 400)); // A em voo

          cubit.buscar('bbbb');
          async.elapse(const Duration(milliseconds: 400)); // B resolve

          completerA.complete(
            Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
          );
          async.flushMicrotasks();

          final conteudo = cubit.state.conteudo as VitrineCarregada;
          expect(conteudo.itens.single.id, 9);

          unawaited(cubit.close());
        });
      },
    );

    test('close() com debounce pendente nunca dispara a chamada', () {
      fakeAsync((async) {
        final cubit = construirComRegistro();
        cubit.carregar(campinas);
        async.flushMicrotasks();

        cubit.buscar('casa');
        unawaited(cubit.close());
        async.elapse(const Duration(milliseconds: 500));

        expect(consultas, hasLength(1)); // só o carregar() inicial
      });
    });
  });

  group('ordenarPor (VIT-04, D-13)', () {
    blocTest<VitrineCubit, VitrineState>(
      'ordenarPor(precoAsc) a partir de mais_recentes emite UM reinício '
      '(carregando com a nova ordenacao) e depois o resultado, mantendo o '
      'termoBusca',
      build: () => VitrineCubit(buscarImoveis),
      setUp: () {
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async =>
              Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
        );
      },
      act: (cubit) async {
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);
        await cubit.ordenarPor(OrdenacaoVitrine.precoAsc);
      },
      expect: () => [
        const VitrineState(conteudo: ConteudoVitrine.carregando()),
        VitrineState(
          conteudo: ConteudoVitrine.carregada(itens: [imovelDe(campinas, 1)]),
        ),
        const VitrineState(
          ordenacao: OrdenacaoVitrine.precoAsc,
          conteudo: ConteudoVitrine.carregando(),
        ),
        VitrineState(
          ordenacao: OrdenacaoVitrine.precoAsc,
          conteudo: ConteudoVitrine.carregada(itens: [imovelDe(campinas, 1)]),
        ),
      ],
      verify: (_) {
        verify(
          () => buscarImoveis(
            const ConsultaImoveis(
              cidade: campinas,
              ordenacao: OrdenacaoVitrine.precoAsc,
            ),
          ),
        ).called(1);
      },
    );

    test(
      'ordenarPor(ordenacao já atual) não emite nada e não chama o use case '
      'de novo (idempotência)',
      () async {
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async =>
              Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
        );
        final cubit = VitrineCubit(buscarImoveis);
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);
        final estadoAntes = cubit.state;

        await cubit.ordenarPor(OrdenacaoVitrine.maisRecentes);

        expect(cubit.state, estadoAntes);
        verify(() => buscarImoveis(any())).called(1);
        await cubit.close();
      },
    );

    test(
      'resposta atrasada de uma ordenacao anterior é descartada quando '
      'ordenarPor troca de novo antes dela resolver (D-13)',
      () async {
        final completerAntiga = Completer<Result<PaginaImoveis>>();
        when(() => buscarImoveis(any())).thenAnswer((invocation) {
          final consulta =
              invocation.positionalArguments.first as ConsultaImoveis;
          if (consulta.ordenacao == OrdenacaoVitrine.precoAsc) {
            return completerAntiga.future;
          }
          return Future.value(
            Result.success(PaginaImoveis(itens: [imovelDe(campinas, 2)])),
          );
        });

        final cubit = VitrineCubit(buscarImoveis);
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);

        unawaited(cubit.ordenarPor(OrdenacaoVitrine.precoAsc));
        await Future<void>.delayed(Duration.zero); // precoAsc fica em voo

        await cubit.ordenarPor(OrdenacaoVitrine.areaAsc);

        completerAntiga.complete(
          Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
        );
        await Future<void>.delayed(Duration.zero);

        final conteudo = cubit.state.conteudo as VitrineCarregada;
        expect(conteudo.itens.single.id, 2);
        expect(cubit.state.ordenacao, OrdenacaoVitrine.areaAsc);
        await cubit.close();
      },
    );
  });

  group('carregarMais (VIT-05, D-13)', () {
    Future<VitrineCubit> construirCarregada({
      required List<Imovel> itens,
      String? proximaPagina,
    }) async {
      when(() => buscarImoveis(any())).thenAnswer(
        (_) async => Result.success(PaginaImoveis(itens: itens)),
      );
      final cubit = construir();
      cubit.carregar(campinas);
      await Future<void>.delayed(Duration.zero);
      final atual = cubit.state.conteudo as VitrineCarregada;
      // Substitui o proximaPagina direto no estado para testar carregarMais
      // isoladamente, sem depender da forma exata do cursor.
      cubit.emit(
        cubit.state.copyWith(
          conteudo: atual.copyWith(proximaPagina: proximaPagina),
        ),
      );
      return cubit;
    }

    blocTest<VitrineCubit, VitrineState>(
      'de VitrineCarregada(10, next=p2), carregarMais() emite carregandoMais '
      'true e depois anexa os novos itens (20 no total) com o cursor da nova '
      'página',
      build: () => VitrineCubit(buscarImoveis),
      setUp: () {
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async => Result.success(
            PaginaImoveis(itens: [imovelDe(campinas, 1)], proximaPagina: 'p2'),
          ),
        );
        when(() => buscarImoveis.proximaPagina('p2')).thenAnswer(
          (_) async => Result.success(
            PaginaImoveis(itens: [imovelDe(campinas, 2)]),
          ),
        );
      },
      act: (cubit) async {
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);
        await cubit.carregarMais();
      },
      expect: () => [
        const VitrineState(conteudo: ConteudoVitrine.carregando()),
        VitrineState(
          conteudo: ConteudoVitrine.carregada(
            itens: [imovelDe(campinas, 1)],
            proximaPagina: 'p2',
          ),
        ),
        VitrineState(
          conteudo: ConteudoVitrine.carregada(
            itens: [imovelDe(campinas, 1)],
            proximaPagina: 'p2',
            carregandoMais: true,
          ),
        ),
        VitrineState(
          conteudo: ConteudoVitrine.carregada(
            itens: [imovelDe(campinas, 1), imovelDe(campinas, 2)],
          ),
        ),
      ],
      verify: (_) {
        verify(() => buscarImoveis.proximaPagina('p2')).called(1);
      },
    );

    test(
      'duas chamadas de carregarMais() com a primeira em voo -> '
      'proximaPagina chamado exatamente uma vez',
      () async {
        final completer = Completer<Result<PaginaImoveis>>();
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async => Result.success(
            PaginaImoveis(itens: [imovelDe(campinas, 1)], proximaPagina: 'p2'),
          ),
        );
        when(
          () => buscarImoveis.proximaPagina('p2'),
        ).thenAnswer((_) => completer.future);

        final cubit = construir();
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);

        final futuro1 = cubit.carregarMais();
        final futuro2 = cubit.carregarMais();

        completer.complete(
          Result.success(PaginaImoveis(itens: [imovelDe(campinas, 2)])),
        );
        await Future.wait([futuro1, futuro2]);

        verify(() => buscarImoveis.proximaPagina('p2')).called(1);
        final conteudo = cubit.state.conteudo as VitrineCarregada;
        expect(conteudo.itens, hasLength(2));
        await cubit.close();
      },
    );

    test(
      'proximaPagina nulo (fim da lista) -> carregarMais() não chama nada '
      'e não emite',
      () async {
        final cubit = await construirCarregada(
          itens: [imovelDe(campinas, 1)],
        );
        final estadoAntes = cubit.state;

        await cubit.carregarMais();

        expect(cubit.state, estadoAntes);
        verifyNever(() => buscarImoveis.proximaPagina(any()));
        await cubit.close();
      },
    );

    test(
      'conteudo diferente de VitrineCarregada (ex.: erro) -> carregarMais() '
      'não chama nada',
      () async {
        when(
          () => buscarImoveis(any()),
        ).thenAnswer((_) async => Result.failure(Exception('falhou')));
        final cubit = construir();
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.conteudo, isA<VitrineErro>());

        await cubit.carregarMais();

        verifyNever(() => buscarImoveis.proximaPagina(any()));
        await cubit.close();
      },
    );

    test(
      'falha ao carregar mais mantém os itens, liga erroAoCarregarMais; um '
      'novo carregarMais() (scroll) não refaz a chamada; tentarNovamente() '
      'refaz com o mesmo cursor e anexa em caso de sucesso',
      () async {
        final cubit = await construirCarregada(
          itens: [imovelDe(campinas, 1)],
          proximaPagina: 'p2',
        );
        when(
          () => buscarImoveis.proximaPagina('p2'),
        ).thenAnswer((_) async => Result.failure(Exception('falhou')));

        await cubit.carregarMais();

        final depoisDaFalha = cubit.state.conteudo as VitrineCarregada;
        expect(depoisDaFalha.itens, hasLength(1));
        expect(depoisDaFalha.carregandoMais, isFalse);
        expect(depoisDaFalha.erroAoCarregarMais, isTrue);

        // Scroll novamente enquanto erroAoCarregarMais == true: sem retry
        // automático (T-02-03-01).
        await cubit.carregarMais();
        verify(() => buscarImoveis.proximaPagina('p2')).called(1);

        when(() => buscarImoveis.proximaPagina('p2')).thenAnswer(
          (_) async => Result.success(
            PaginaImoveis(itens: [imovelDe(campinas, 2)]),
          ),
        );
        cubit.tentarNovamente();
        await Future<void>.delayed(Duration.zero);

        final depoisDoRetry = cubit.state.conteudo as VitrineCarregada;
        expect(depoisDoRetry.itens.map((i) => i.id), [1, 2]);
        expect(depoisDoRetry.erroAoCarregarMais, isFalse);
        verify(() => buscarImoveis.proximaPagina('p2')).called(1);
        await cubit.close();
      },
    );

    test(
      'carregarMais em voo, depois carregar(outra cidade) -> a página '
      'atrasada é descartada; o estado final tem só a primeira página da '
      'outra cidade (D-13)',
      () async {
        final completer = Completer<Result<PaginaImoveis>>();
        final cubit = await construirCarregada(
          itens: [imovelDe(campinas, 1)],
          proximaPagina: 'p2',
        );
        when(
          () => buscarImoveis.proximaPagina('p2'),
        ).thenAnswer((_) => completer.future);
        when(() => buscarImoveis(any())).thenAnswer((invocation) async {
          final consulta =
              invocation.positionalArguments.first as ConsultaImoveis;
          if (consulta.cidade == valinhos) {
            return Result.success(
              PaginaImoveis(itens: [imovelDe(valinhos, 9)]),
            );
          }
          return Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)]));
        });

        final futuroCarregarMais = cubit.carregarMais();
        cubit.carregar(valinhos);
        await Future<void>.delayed(Duration.zero);

        completer.complete(
          Result.success(PaginaImoveis(itens: [imovelDe(campinas, 2)])),
        );
        await futuroCarregarMais;
        await Future<void>.delayed(Duration.zero);

        final conteudoFinal = cubit.state.conteudo as VitrineCarregada;
        expect(conteudoFinal.itens.single.cidade, valinhos);
        await cubit.close();
      },
    );

    test(
      'close() durante carregarMais() em voo não lança e não emite depois',
      () async {
        final completer = Completer<Result<PaginaImoveis>>();
        final cubit = await construirCarregada(
          itens: [imovelDe(campinas, 1)],
          proximaPagina: 'p2',
        );
        when(
          () => buscarImoveis.proximaPagina('p2'),
        ).thenAnswer((_) => completer.future);

        final futuro = cubit.carregarMais();
        await cubit.close();
        expect(cubit.isClosed, isTrue);

        completer.complete(
          Result.success(PaginaImoveis(itens: [imovelDe(campinas, 2)])),
        );
        await futuro;
      },
    );
  });

  group('aplicarFiltros / removerFiltro / limparFiltros (FIL-06, D-17..D-19)', () {
    blocTest<VitrineCubit, VitrineState>(
      'aplicarFiltros(finalidade venda) emite UM reinício (carregando com o '
      'novo filtros) e depois o resultado, mantendo ordenacao/termoBusca',
      build: () => VitrineCubit(buscarImoveis),
      setUp: () {
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async =>
              Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
        );
      },
      act: (cubit) async {
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);
        await cubit.aplicarFiltros(
          const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
        );
      },
      expect: () => [
        const VitrineState(conteudo: ConteudoVitrine.carregando()),
        VitrineState(
          conteudo: ConteudoVitrine.carregada(itens: [imovelDe(campinas, 1)]),
        ),
        const VitrineState(
          filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
          conteudo: ConteudoVitrine.carregando(),
        ),
        VitrineState(
          filtros: const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
          conteudo: ConteudoVitrine.carregada(itens: [imovelDe(campinas, 1)]),
        ),
      ],
      verify: (_) {
        verify(
          () => buscarImoveis(
            const ConsultaImoveis(
              cidade: campinas,
              filtros: FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'aplicarFiltros(mesmo filtro já aplicado) não emite nada e não chama '
      'o use case de novo (idempotência)',
      () async {
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async =>
              Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
        );
        final cubit = VitrineCubit(buscarImoveis);
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);

        await cubit.aplicarFiltros(const FiltrosVitrine());

        verify(() => buscarImoveis(any())).called(1);
        await cubit.close();
      },
    );

    test(
      'removerFiltro(finalidade) a partir de {finalidade, precoMin} aplica '
      'o filtro já sem finalidade NEM preço (D-03), mantendo termoBusca',
      () async {
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async => const Result.success(PaginaImoveis(itens: [])),
        );
        final cubit = VitrineCubit(buscarImoveis);
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);
        await cubit.aplicarFiltros(
          const FiltrosVitrine(
            finalidade: FinalidadeFiltro.venda,
            precoMin: 1000,
          ),
        );

        await cubit.removerFiltro(FiltroAtivo.finalidade);

        // Sem finalidade NEM preço — a remoção de "finalidade" também limpa
        // a faixa de preço (D-03). A consulta final volta a bater com o
        // carregar() inicial (mesma ConsultaImoveis default) — por isso 2
        // chamadas totais casam com esse argumento, não 1.
        expect(cubit.state.filtros, const FiltrosVitrine());
        verify(
          () => buscarImoveis(const ConsultaImoveis(cidade: campinas)),
        ).called(2);
        await cubit.close();
      },
    );

    test(
      'limparFiltros() a partir de filtros ativos aplica FiltrosVitrine() '
      'vazio sem mexer em ordenacao/termoBusca',
      () async {
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async =>
              Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
        );
        final cubit = VitrineCubit(buscarImoveis);
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);
        await cubit.ordenarPor(OrdenacaoVitrine.precoAsc);
        await cubit.aplicarFiltros(
          const FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
        );

        await cubit.limparFiltros();

        expect(cubit.state.filtros, const FiltrosVitrine());
        expect(cubit.state.ordenacao, OrdenacaoVitrine.precoAsc);
        await cubit.close();
      },
    );

    test(
      'limparBuscaEFiltros() faz exatamente UMA consulta, com busca null e '
      'filtros vazios, cancelando um debounce de busca pendente',
      () {
        fakeAsync((async) {
          final consultas = <ConsultaImoveis>[];
          when(() => buscarImoveis(any())).thenAnswer((invocation) async {
            final consulta =
                invocation.positionalArguments.first as ConsultaImoveis;
            consultas.add(consulta);
            return const Result.success(PaginaImoveis(itens: []));
          });

          final cubit = VitrineCubit(buscarImoveis);
          cubit.carregar(campinas);
          async.flushMicrotasks();
          cubit.buscar('casa'); // debounce pendente — deve ser cancelado

          cubit.limparBuscaEFiltros();
          async.flushMicrotasks();

          expect(cubit.state.termoBusca, isNull);
          expect(cubit.state.filtros, const FiltrosVitrine());

          async.elapse(const Duration(milliseconds: 500));
          // carregar() + limparBuscaEFiltros() — o debounce cancelado nunca
          // dispara uma terceira chamada.
          expect(consultas, hasLength(2));

          unawaited(cubit.close());
        });
      },
    );

    test(
      'filtros A em voo é descartado quando filtros B já resolveu — só o '
      'resultado de B chega a ser emitido (D-19)',
      () async {
        final completerA = Completer<Result<PaginaImoveis>>();
        when(() => buscarImoveis(any())).thenAnswer((invocation) {
          final consulta =
              invocation.positionalArguments.first as ConsultaImoveis;
          if (consulta.filtros.finalidade == FinalidadeFiltro.venda) {
            return completerA.future;
          }
          return Future.value(
            Result.success(PaginaImoveis(itens: [imovelDe(campinas, 9)])),
          );
        });

        final cubit = VitrineCubit(buscarImoveis);
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);

        unawaited(
          cubit.aplicarFiltros(
            const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await cubit.aplicarFiltros(
          const FiltrosVitrine(finalidade: FinalidadeFiltro.aluguel),
        );

        completerA.complete(
          Result.success(PaginaImoveis(itens: [imovelDe(campinas, 1)])),
        );
        await Future<void>.delayed(Duration.zero);

        final conteudo = cubit.state.conteudo as VitrineCarregada;
        expect(conteudo.itens.single.id, 9);
        expect(cubit.state.filtros.finalidade, FinalidadeFiltro.aluguel);
        await cubit.close();
      },
    );

    test(
      'carregarMais() em voo é descartado quando os filtros mudam antes de '
      'resolver — nenhuma página extra é anexada',
      () async {
        final completer = Completer<Result<PaginaImoveis>>();
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async => Result.success(
            PaginaImoveis(itens: [imovelDe(campinas, 1)], proximaPagina: 'p2'),
          ),
        );
        when(
          () => buscarImoveis.proximaPagina('p2'),
        ).thenAnswer((_) => completer.future);

        final cubit = VitrineCubit(buscarImoveis);
        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);

        final futuroCarregarMais = cubit.carregarMais();
        await cubit.aplicarFiltros(
          const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
        );

        completer.complete(
          Result.success(PaginaImoveis(itens: [imovelDe(campinas, 2)])),
        );
        await futuroCarregarMais;
        await Future<void>.delayed(Duration.zero);

        final conteudo = cubit.state.conteudo as VitrineCarregada;
        expect(conteudo.itens.map((i) => i.id), [1]);
        await cubit.close();
      },
    );
  });

  group('Decisão de vazio com 4 combinações (D-22)', () {
    test('filtros ativos, sem busca -> semResultadoComFiltros(termo: null)', () async {
      when(() => buscarImoveis(any())).thenAnswer(
        (_) async => const Result.success(PaginaImoveis(itens: [])),
      );
      final cubit = VitrineCubit(buscarImoveis);
      cubit.carregar(campinas);
      await Future<void>.delayed(Duration.zero);

      await cubit.aplicarFiltros(
        const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
      );

      expect(
        cubit.state.conteudo,
        const ConteudoVitrine.semResultadoComFiltros(),
      );
      await cubit.close();
    });

    test(
      'filtros ativos + busca -> semResultadoComFiltros(termo: busca)',
      () {
        fakeAsync((async) {
          when(() => buscarImoveis(any())).thenAnswer(
            (_) async => const Result.success(PaginaImoveis(itens: [])),
          );
          final cubit = VitrineCubit(buscarImoveis);
          cubit.carregar(campinas);
          async.flushMicrotasks();

          unawaited(
            cubit.aplicarFiltros(
              const FiltrosVitrine(finalidade: FinalidadeFiltro.venda),
            ),
          );
          async.flushMicrotasks();
          cubit.buscar('xyz');
          async.elapse(const Duration(milliseconds: 400));

          expect(
            cubit.state.conteudo,
            const ConteudoVitrine.semResultadoComFiltros(termo: 'xyz'),
          );
          unawaited(cubit.close());
        });
      },
    );

    test('só busca, sem filtros -> semResultado(termo) (regressão F2/D-09)', () {
      fakeAsync((async) {
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async => const Result.success(PaginaImoveis(itens: [])),
        );
        final cubit = VitrineCubit(buscarImoveis);
        cubit.carregar(campinas);
        async.flushMicrotasks();

        cubit.buscar('xyz');
        async.elapse(const Duration(milliseconds: 400));

        expect(cubit.state.conteudo, const ConteudoVitrine.semResultado('xyz'));
        unawaited(cubit.close());
      });
    });

    test(
      'nem busca nem filtros -> vazioNaCidade (regressão F2/D-15)',
      () async {
        when(() => buscarImoveis(any())).thenAnswer(
          (_) async => const Result.success(PaginaImoveis(itens: [])),
        );
        final cubit = VitrineCubit(buscarImoveis);

        cubit.carregar(campinas);
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state.conteudo, const ConteudoVitrine.vazioNaCidade());
        await cubit.close();
      },
    );
  });
}
