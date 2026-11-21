import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/consulta_acervo.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel_acervo.dart';
import 'package:imoveis_aqui/domain/entities/pagina_acervo.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_acervo_usecase.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_cubit.dart';
import 'package:imoveis_aqui/presentation/acervo/acervo_state.dart';
import 'package:mocktail/mocktail.dart';

class _BuscarAcervoUseCaseFalso extends Mock implements BuscarAcervoUseCase {}

ImovelAcervo _imovel(int id) => ImovelAcervo(
  id: id,
  codigo: 'DEV-$id',
  titulo: 'Imóvel $id',
  finalidade: FinalidadeImovel.venda,
  precoVenda: '100000.00',
  situacao: SituacaoImovel.disponivel,
  meuImovel: true,
  naVitrine: true,
);

void main() {
  late _BuscarAcervoUseCaseFalso buscar;

  final itensPagina1 = [_imovel(1), _imovel(2)];
  final pagina1 = PaginaAcervo(itens: itensPagina1, proximaPagina: 'pagina-2');
  final pagina2 = PaginaAcervo(itens: [_imovel(2), _imovel(3)]);
  final paginaVazia = PaginaAcervo(itens: const []);

  setUpAll(() {
    registerFallbackValue(const ConsultaAcervo());
  });

  setUp(() {
    buscar = _BuscarAcervoUseCaseFalso();
  });

  AcervoCubit construir() => AcervoCubit(buscar);

  void respondeSempre(PaginaAcervo pagina) {
    when(() => buscar(any())).thenAnswer((_) async => Result.success(pagina));
  }

  test('estado inicial é carregando, sem busca e sem situação', () {
    expect(construir().state, const AcervoState());
  });

  group('carregar', () {
    blocTest<AcervoCubit, AcervoState>(
      'com itens emite [carregando, carregada(itens, proximaPagina)]',
      build: construir,
      setUp: () => respondeSempre(pagina1),
      act: (cubit) => cubit.carregar(),
      expect: () => [
        const AcervoState(),
        AcervoState(
          conteudo: ConteudoAcervo.carregada(
            itens: itensPagina1,
            proximaPagina: 'pagina-2',
          ),
        ),
      ],
      verify: (_) => verify(() => buscar(const ConsultaAcervo())).called(1),
    );

    blocTest<AcervoCubit, AcervoState>(
      'página vazia sem busca e sem situação emite vazio',
      build: construir,
      setUp: () => respondeSempre(paginaVazia),
      act: (cubit) => cubit.carregar(),
      expect: () => [
        const AcervoState(),
        const AcervoState(conteudo: ConteudoAcervo.vazio()),
      ],
    );

    blocTest<AcervoCubit, AcervoState>(
      'página vazia com situação emite semResultado',
      build: construir,
      setUp: () => respondeSempre(paginaVazia),
      act: (cubit) => cubit.escolherSituacao(SituacaoImovel.vendido),
      expect: () => [
        const AcervoState(situacao: SituacaoImovel.vendido),
        const AcervoState(
          situacao: SituacaoImovel.vendido,
          conteudo: ConteudoAcervo.semResultado(),
        ),
      ],
    );
  });

  group('buscar (D-08)', () {
    test(
      'não chama antes de 400 ms; chama aos 400 ms com a situação atual',
      () {
        fakeAsync((async) {
          respondeSempre(pagina1);
          final cubit = construir();
          cubit.carregar();
          async.flushMicrotasks();
          clearInteractions(buscar);

          cubit.buscar('DEV');
          async.elapse(const Duration(milliseconds: 399));
          verifyNever(() => buscar(any()));

          async.elapse(const Duration(milliseconds: 1));
          verify(() => buscar(const ConsultaAcervo(busca: 'DEV'))).called(1);
          expect(cubit.state.termoBusca, 'DEV');

          unawaited(cubit.close());
        });
      },
    );

    test('duas teclas seguidas resultam numa só chamada', () {
      fakeAsync((async) {
        respondeSempre(pagina1);
        final cubit = construir();
        cubit.carregar();
        async.flushMicrotasks();
        clearInteractions(buscar);

        cubit.buscar('D');
        async.elapse(const Duration(milliseconds: 100));
        cubit.buscar('DE');
        async.elapse(const Duration(milliseconds: 400));

        verify(() => buscar(const ConsultaAcervo(busca: 'DE'))).called(1);
        verifyNever(() => buscar(const ConsultaAcervo(busca: 'D')));

        unawaited(cubit.close());
      });
    });

    test('um único caractere também dispara', () {
      fakeAsync((async) {
        respondeSempre(pagina1);
        final cubit = construir();
        cubit.carregar();
        async.flushMicrotasks();
        clearInteractions(buscar);

        cubit.buscar('D');
        async.elapse(const Duration(milliseconds: 400));

        verify(() => buscar(const ConsultaAcervo(busca: 'D'))).called(1);

        unawaited(cubit.close());
      });
    });

    test('espaços ao redor são descartados do termo', () {
      fakeAsync((async) {
        respondeSempre(pagina1);
        final cubit = construir();
        cubit.carregar();
        async.flushMicrotasks();
        clearInteractions(buscar);

        cubit.buscar('  DEV-1  ');
        async.elapse(const Duration(milliseconds: 400));

        verify(() => buscar(const ConsultaAcervo(busca: 'DEV-1'))).called(1);

        unawaited(cubit.close());
      });
    });

    test('apagar tudo com busca aplicada volta à lista completa na hora', () {
      fakeAsync((async) {
        respondeSempre(pagina1);
        final cubit = construir();
        cubit.carregar();
        async.flushMicrotasks();
        cubit.buscar('DEV');
        async.elapse(const Duration(milliseconds: 400));
        async.flushMicrotasks();
        clearInteractions(buscar);

        cubit.buscar('   ');
        async.flushMicrotasks();

        verify(() => buscar(const ConsultaAcervo())).called(1);
        expect(cubit.state.termoBusca, isEmpty);

        unawaited(cubit.close());
      });
    });

    test('apagar o campo sem busca aplicada não chama nada', () {
      fakeAsync((async) {
        respondeSempre(pagina1);
        final cubit = construir();
        cubit.carregar();
        async.flushMicrotasks();
        clearInteractions(buscar);

        cubit.buscar('');
        async.elapse(const Duration(seconds: 1));

        verifyNever(() => buscar(any()));

        unawaited(cubit.close());
      });
    });

    test('o mesmo termo já aplicado não gera nova chamada', () {
      fakeAsync((async) {
        respondeSempre(pagina1);
        final cubit = construir();
        cubit.carregar();
        async.flushMicrotasks();
        cubit.buscar('DEV');
        async.elapse(const Duration(milliseconds: 400));
        async.flushMicrotasks();
        clearInteractions(buscar);

        cubit.buscar('DEV');
        async.elapse(const Duration(milliseconds: 400));

        verifyNever(() => buscar(any()));

        unawaited(cubit.close());
      });
    });

    test('limparBusca cancela o atraso pendente e volta à lista completa', () {
      fakeAsync((async) {
        respondeSempre(pagina1);
        final cubit = construir();
        cubit.carregar();
        async.flushMicrotasks();
        cubit.buscar('DEV');
        async.elapse(const Duration(milliseconds: 400));
        async.flushMicrotasks();
        clearInteractions(buscar);

        cubit.buscar('XYZ'); // pendente
        cubit.limparBusca();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        verify(() => buscar(const ConsultaAcervo())).called(1);
        verifyNever(() => buscar(const ConsultaAcervo(busca: 'XYZ')));

        unawaited(cubit.close());
      });
    });

    test('close cancela o atraso pendente sem emitir depois de fechado', () {
      fakeAsync((async) {
        respondeSempre(pagina1);
        final cubit = construir();
        cubit.carregar();
        async.flushMicrotasks();
        clearInteractions(buscar);

        cubit.buscar('DEV');
        unawaited(cubit.close());
        async.elapse(const Duration(seconds: 1));

        verifyNever(() => buscar(any()));
      });
    });
  });

  group('escolherSituacao (D-09)', () {
    blocTest<AcervoCubit, AcervoState>(
      'chama na hora com a situação e o termo atual',
      build: construir,
      setUp: () => respondeSempre(pagina1),
      act: (cubit) async {
        cubit.carregar();
        await Future<void>.delayed(Duration.zero);
        await cubit.escolherSituacao(SituacaoImovel.vendido);
      },
      verify: (_) {
        verify(
          () => buscar(const ConsultaAcervo(situacao: SituacaoImovel.vendido)),
        ).called(1);
      },
    );

    blocTest<AcervoCubit, AcervoState>(
      'escolher a mesma situação de novo não chama',
      build: construir,
      setUp: () => respondeSempre(pagina1),
      act: (cubit) async {
        await cubit.escolherSituacao(SituacaoImovel.vendido);
        await cubit.escolherSituacao(SituacaoImovel.vendido);
      },
      verify: (_) => verify(() => buscar(any())).called(1),
    );

    blocTest<AcervoCubit, AcervoState>(
      'escolherSituacao(null) é "Todas": chama sem situação',
      build: construir,
      setUp: () => respondeSempre(pagina1),
      act: (cubit) async {
        await cubit.escolherSituacao(SituacaoImovel.reservado);
        await cubit.escolherSituacao(null);
      },
      verify: (cubit) {
        verify(() => buscar(const ConsultaAcervo())).called(1);
        expect(cubit.state.situacao, isNull);
      },
    );

    test('mantém o termo de busca aplicado ao trocar a situação', () {
      fakeAsync((async) {
        respondeSempre(pagina1);
        final cubit = construir();
        cubit.buscar('DEV');
        async.elapse(const Duration(milliseconds: 400));
        async.flushMicrotasks();
        clearInteractions(buscar);

        unawaited(cubit.escolherSituacao(SituacaoImovel.alugado));
        async.flushMicrotasks();

        verify(
          () => buscar(
            const ConsultaAcervo(
              busca: 'DEV',
              situacao: SituacaoImovel.alugado,
            ),
          ),
        ).called(1);

        unawaited(cubit.close());
      });
    });
  });

  group('consulta obsoleta', () {
    test('resposta antiga que chega depois de uma nova é descartada', () {
      fakeAsync((async) {
        final antiga = Completer<Result<PaginaAcervo>>();
        final nova = Completer<Result<PaginaAcervo>>();
        when(() => buscar(const ConsultaAcervo()))
            .thenAnswer((_) => antiga.future);
        when(
          () => buscar(const ConsultaAcervo(situacao: SituacaoImovel.vendido)),
        ).thenAnswer((_) => nova.future);

        final cubit = construir();
        cubit.carregar();
        unawaited(cubit.escolherSituacao(SituacaoImovel.vendido));

        nova.complete(Result.success(PaginaAcervo(itens: [_imovel(9)])));
        async.flushMicrotasks();
        antiga.complete(Result.success(pagina1));
        async.flushMicrotasks();

        expect(
          cubit.state.conteudo,
          ConteudoAcervo.carregada(itens: [_imovel(9)]),
        );
        expect(cubit.state.situacao, SituacaoImovel.vendido);

        unawaited(cubit.close());
      });
    });
  });

  group('carregarMais (D-10)', () {
    blocTest<AcervoCubit, AcervoState>(
      'anexa a próxima página descartando ids já listados',
      build: construir,
      setUp: () {
        respondeSempre(pagina1);
        when(() => buscar.seguir('pagina-2'))
            .thenAnswer((_) async => Result.success(pagina2));
      },
      act: (cubit) async {
        cubit.carregar();
        await Future<void>.delayed(Duration.zero);
        await cubit.carregarMais();
      },
      skip: 2,
      expect: () => [
        AcervoState(
          conteudo: ConteudoAcervo.carregada(
            itens: itensPagina1,
            proximaPagina: 'pagina-2',
            carregandoMais: true,
          ),
        ),
        AcervoState(
          conteudo: ConteudoAcervo.carregada(
            itens: [_imovel(1), _imovel(2), _imovel(3)],
          ),
        ),
      ],
    );

    blocTest<AcervoCubit, AcervoState>(
      'falha mantém os itens com erroAoCarregarMais; carregarMais não repete '
      'sozinho e tentarNovamente refaz a mesma página',
      build: construir,
      setUp: () {
        respondeSempre(pagina1);
        var chamadas = 0;
        when(() => buscar.seguir('pagina-2')).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result.failure(Exception('rede'))
              : Result.success(pagina2);
        });
      },
      act: (cubit) async {
        cubit.carregar();
        await Future<void>.delayed(Duration.zero);
        await cubit.carregarMais();
        await cubit.carregarMais(); // ignorado: erroAoCarregarMais
        await cubit.tentarNovamente();
      },
      verify: (cubit) {
        verify(() => buscar.seguir('pagina-2')).called(2);
        expect(
          cubit.state.conteudo,
          ConteudoAcervo.carregada(itens: [_imovel(1), _imovel(2), _imovel(3)]),
        );
      },
    );

    blocTest<AcervoCubit, AcervoState>(
      'ignora sem proximaPagina e enquanto já está carregando',
      build: construir,
      setUp: () {
        when(() => buscar(any())).thenAnswer(
          (_) async => Result.success(PaginaAcervo(itens: [_imovel(1)])),
        );
      },
      act: (cubit) async {
        cubit.carregar();
        await Future<void>.delayed(Duration.zero);
        await cubit.carregarMais();
      },
      verify: (_) => verifyNever(() => buscar.seguir(any())),
    );

    blocTest<AcervoCubit, AcervoState>(
      'sessão expirada ao carregar mais vira sessaoExpirada',
      build: construir,
      setUp: () {
        respondeSempre(pagina1);
        when(() => buscar.seguir('pagina-2')).thenAnswer(
          (_) async => Result.failure(const SessaoExpiradaException()),
        );
      },
      act: (cubit) async {
        cubit.carregar();
        await Future<void>.delayed(Duration.zero);
        await cubit.carregarMais();
      },
      verify: (cubit) =>
          expect(cubit.state.conteudo, const ConteudoAcervo.sessaoExpirada()),
    );
  });

  group('falhas na primeira página', () {
    blocTest<AcervoCubit, AcervoState>(
      'SessaoExpiradaException vira sessaoExpirada',
      build: construir,
      setUp: () {
        when(() => buscar(any())).thenAnswer(
          (_) async => Result.failure(const SessaoExpiradaException()),
        );
      },
      act: (cubit) => cubit.carregar(),
      expect: () => [
        const AcervoState(),
        const AcervoState(conteudo: ConteudoAcervo.sessaoExpirada()),
      ],
    );

    blocTest<AcervoCubit, AcervoState>(
      'qualquer outra falha vira erro e tentarNovamente refaz a consulta atual',
      build: construir,
      setUp: () {
        var chamadas = 0;
        when(() => buscar(any())).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result.failure(const SemPermissaoException())
              : Result.success(pagina1);
        });
      },
      act: (cubit) async {
        await cubit.escolherSituacao(SituacaoImovel.reservado);
        expect(cubit.state.conteudo, const ConteudoAcervo.erro());
        await cubit.tentarNovamente();
      },
      verify: (cubit) {
        verify(
          () =>
              buscar(const ConsultaAcervo(situacao: SituacaoImovel.reservado)),
        ).called(2);
        expect(
          cubit.state.conteudo,
          ConteudoAcervo.carregada(
            itens: itensPagina1,
            proximaPagina: 'pagina-2',
          ),
        );
      },
    );
  });
}
