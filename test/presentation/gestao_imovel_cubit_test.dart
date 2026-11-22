import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel_gestao.dart';
import 'package:imoveis_aqui/domain/entities/mudanca_situacao.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:imoveis_aqui/domain/usecases/obter_historico_situacao_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_imovel_gestao_usecase.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_state.dart';
import 'package:mocktail/mocktail.dart';

class _ObterImovelGestaoUseCaseFalso extends Mock
    implements ObterImovelGestaoUseCase {}

class _ObterHistoricoSituacaoUseCaseFalso extends Mock
    implements ObterHistoricoSituacaoUseCase {}

MudancaSituacao _mudanca(int id) => MudancaSituacao(
  id: id,
  situacaoAnterior: SituacaoImovel.disponivel,
  situacaoNova: SituacaoImovel.reservado,
  alteradoPor: 'Corretor Demo',
  alteradoEm: DateTime.utc(2026, 11, 22, 15, 25),
  observacao: 'Reservado na conversa.',
);

ImovelGestao _imovel(int id) => ImovelGestao(
  id: id,
  codigo: 'DEV-$id',
  titulo: 'Imóvel $id',
  finalidade: FinalidadeImovel.venda,
  precoVenda: '100000.00',
  situacao: SituacaoImovel.disponivel,
  situacaoDesde: DateTime.utc(2026, 11, 22, 15, 25),
  podeMudarSituacao: true,
);

void main() {
  late _ObterImovelGestaoUseCaseFalso obter;
  late _ObterHistoricoSituacaoUseCaseFalso obterHistorico;

  setUp(() {
    obter = _ObterImovelGestaoUseCaseFalso();
    obterHistorico = _ObterHistoricoSituacaoUseCaseFalso();
    // Por padrão o servidor responde histórico vazio; os casos do histórico
    // trocam esta resposta.
    when(() => obterHistorico(any()))
        .thenAnswer((_) async => Result.success(const <MudancaSituacao>[]));
  });

  GestaoImovelCubit construir() => GestaoImovelCubit(obter, obterHistorico);

  GestaoImovelState carregado(
    int id, {
    ConteudoHistorico historico = const ConteudoHistorico.carregado([]),
  }) => GestaoImovelState(
    imovel: ConteudoImovelGestao.carregado(_imovel(id)),
    historico: historico,
  );

  test('estado inicial é o imóvel carregando', () {
    expect(construir().state, const GestaoImovelState());
    expect(construir().state.imovel, const ConteudoImovelGestao.carregando());
  });

  group('carregar', () {
    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'emite [carregando, carregado(imovel)] com o que o servidor entregou',
      build: () {
        when(() => obter(36))
            .thenAnswer((_) async => Result.success(_imovel(36)));
        return construir();
      },
      act: (cubit) => cubit.carregar(36),
      expect: () => [const GestaoImovelState(), carregado(36)],
      verify: (_) => verify(() => obter(36)).called(1),
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'com Failure emite [carregando, erro]',
      build: () {
        when(() => obter(36)).thenAnswer(
          (_) async => Result.failure(const FalhaDeConexaoException()),
        );
        return construir();
      },
      act: (cubit) => cubit.carregar(36),
      expect: () => [
        const GestaoImovelState(),
        const GestaoImovelState(
          imovel: ConteudoImovelGestao.erro(),
          historico: ConteudoHistorico.carregado([]),
        ),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'imóvel e histórico carregados juntos num único estado (D-11)',
      build: () {
        when(() => obter(36))
            .thenAnswer((_) async => Result.success(_imovel(36)));
        when(
          () => obterHistorico(36),
        ).thenAnswer((_) async => Result.success([_mudanca(2), _mudanca(1)]));
        return construir();
      },
      act: (cubit) => cubit.carregar(36),
      expect: () => [
        const GestaoImovelState(),
        carregado(
          36,
          historico: ConteudoHistorico.carregado([_mudanca(2), _mudanca(1)]),
        ),
      ],
      verify: (_) {
        verify(() => obter(36)).called(1);
        verify(() => obterHistorico(36)).called(1);
      },
    );

    test(
      'as duas leituras partem juntas, antes de qualquer resposta',
      () async {
        final imovel = Completer<Result<ImovelGestao>>();
        final historico = Completer<Result<List<MudancaSituacao>>>();
        when(() => obter(36)).thenAnswer((_) => imovel.future);
        when(() => obterHistorico(36)).thenAnswer((_) => historico.future);
        final cubit = construir();

        final leitura = cubit.carregar(36);
        await Future<void>.delayed(Duration.zero);

        verify(() => obter(36)).called(1);
        verify(() => obterHistorico(36)).called(1);
        imovel.complete(Result.success(_imovel(36)));
        historico.complete(Result.success(const <MudancaSituacao>[]));
        await leitura;
        await cubit.close();
      },
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'falha só do histórico mantém o imóvel carregado e o histórico vira erro',
      build: () {
        when(() => obter(36))
            .thenAnswer((_) async => Result.success(_imovel(36)));
        when(() => obterHistorico(36)).thenAnswer(
          (_) async => Result.failure(const FalhaDeConexaoException()),
        );
        return construir();
      },
      act: (cubit) => cubit.carregar(36),
      expect: () => [
        const GestaoImovelState(),
        carregado(36, historico: const ConteudoHistorico.erro()),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      '404 no imóvel emite não encontrado, sem erro genérico (D-10)',
      build: () {
        when(() => obter(36)).thenAnswer(
          (_) async => Result.failure(const ImovelNaoEncontradoException()),
        );
        return construir();
      },
      act: (cubit) => cubit.carregar(36),
      expect: () => [
        const GestaoImovelState(),
        const GestaoImovelState(
          imovel: ConteudoImovelGestao.naoEncontrado(),
          historico: ConteudoHistorico.carregado([]),
        ),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      '401 no imóvel emite sessão expirada (D-10)',
      build: () {
        when(() => obter(36)).thenAnswer(
          (_) async => Result.failure(const SessaoExpiradaException()),
        );
        return construir();
      },
      act: (cubit) => cubit.carregar(36),
      expect: () => [
        const GestaoImovelState(),
        const GestaoImovelState(
          imovel: ConteudoImovelGestao.sessaoExpirada(),
          historico: ConteudoHistorico.carregado([]),
        ),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      '401 só no histórico leva a tela toda para sessão expirada',
      build: () {
        when(() => obter(36))
            .thenAnswer((_) async => Result.success(_imovel(36)));
        when(() => obterHistorico(36)).thenAnswer(
          (_) async => Result.failure(const SessaoExpiradaException()),
        );
        return construir();
      },
      act: (cubit) => cubit.carregar(36),
      expect: () => [
        const GestaoImovelState(),
        const GestaoImovelState(
          imovel: ConteudoImovelGestao.sessaoExpirada(),
          historico: ConteudoHistorico.erro(),
        ),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      '404 só no histórico vira falha do histórico, com o imóvel carregado',
      build: () {
        when(() => obter(36))
            .thenAnswer((_) async => Result.success(_imovel(36)));
        when(() => obterHistorico(36)).thenAnswer(
          (_) async => Result.failure(const ImovelNaoEncontradoException()),
        );
        return construir();
      },
      act: (cubit) => cubit.carregar(36),
      expect: () => [
        const GestaoImovelState(),
        carregado(36, historico: const ConteudoHistorico.erro()),
      ],
    );
  });

  group('tentarNovamenteHistorico', () {
    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'repete só o histórico e recupera a seção, sem reler o imóvel',
      build: () {
        when(() => obter(36))
            .thenAnswer((_) async => Result.success(_imovel(36)));
        var chamadas = 0;
        when(() => obterHistorico(36)).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result<List<MudancaSituacao>>.failure(
                  const FalhaDeConexaoException(),
                )
              : Result.success([_mudanca(1)]);
        });
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.tentarNovamenteHistorico();
      },
      expect: () => [
        const GestaoImovelState(),
        carregado(36, historico: const ConteudoHistorico.erro()),
        carregado(36, historico: const ConteudoHistorico.carregando()),
        carregado(36, historico: ConteudoHistorico.carregado([_mudanca(1)])),
      ],
      verify: (_) {
        verify(() => obter(36)).called(1);
        verify(() => obterHistorico(36)).called(2);
      },
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      '401 ao repetir o histórico leva a tela toda para sessão expirada',
      build: () {
        when(() => obter(36))
            .thenAnswer((_) async => Result.success(_imovel(36)));
        var chamadas = 0;
        when(() => obterHistorico(36)).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result<List<MudancaSituacao>>.failure(
                  const FalhaDeConexaoException(),
                )
              : Result<List<MudancaSituacao>>.failure(
                  const SessaoExpiradaException(),
                );
        });
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.tentarNovamenteHistorico();
      },
      skip: 2,
      expect: () => [
        carregado(36, historico: const ConteudoHistorico.carregando()),
        const GestaoImovelState(
          imovel: ConteudoImovelGestao.sessaoExpirada(),
          historico: ConteudoHistorico.erro(),
        ),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'sem leitura anterior não faz nada',
      build: construir,
      act: (cubit) => cubit.tentarNovamenteHistorico(),
      expect: () => <GestaoImovelState>[],
      verify: (_) => verifyNever(() => obterHistorico(any())),
    );

    test('resposta do histórico de uma carga antiga é descartada', () async {
      final antiga = Completer<Result<List<MudancaSituacao>>>();
      when(() => obter(any())).thenAnswer(
        (invocacao) async =>
            Result.success(_imovel(invocacao.positionalArguments.first as int)),
      );
      when(() => obterHistorico(36)).thenAnswer((_) => antiga.future);
      when(() => obterHistorico(37))
          .thenAnswer((_) async => Result.success([_mudanca(7)]));
      final cubit = construir();

      final primeira = cubit.carregar(36);
      await cubit.carregar(37);
      antiga.complete(Result.success([_mudanca(1)]));
      await primeira;

      expect(
        cubit.state,
        carregado(37, historico: ConteudoHistorico.carregado([_mudanca(7)])),
      );
      await cubit.close();
    });
  });

  group('tentarNovamente', () {
    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'chama o use case de novo com o id guardado e recupera a tela',
      build: () {
        var chamadas = 0;
        when(() => obter(36)).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result<ImovelGestao>.failure(const FalhaDeConexaoException())
              : Result.success(_imovel(36));
        });
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.tentarNovamente();
      },
      expect: () => [
        const GestaoImovelState(),
        const GestaoImovelState(
          imovel: ConteudoImovelGestao.erro(),
          historico: ConteudoHistorico.carregado([]),
        ),
        const GestaoImovelState(),
        carregado(36),
      ],
      verify: (_) => verify(() => obter(36)).called(2),
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'sem leitura anterior não faz nada',
      build: construir,
      act: (cubit) => cubit.tentarNovamente(),
      expect: () => <GestaoImovelState>[],
      verify: (_) => verifyNever(() => obter(any())),
    );
  });

  group('recarregar (puxar para atualizar)', () {
    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'com conteúdo carregado não emite carregando e troca imóvel e histórico '
      'pelos lidos da API',
      build: () {
        var chamadas = 0;
        when(() => obter(36)).thenAnswer((_) async {
          chamadas++;
          return Result.success(_imovel(chamadas == 1 ? 36 : 360));
        });
        when(() => obterHistorico(36))
            .thenAnswer((_) async => Result.success([_mudanca(1)]));
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.recarregar();
      },
      skip: 2,
      expect: () => [
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovel(360)),
          historico: ConteudoHistorico.carregado([_mudanca(1)]),
        ),
      ],
      verify: (_) {
        verify(() => obter(36)).called(2);
        verify(() => obterHistorico(36)).called(2);
      },
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'falha genérica mantém o conteúdo e soma 1 em falhasAoAtualizar',
      build: () {
        var chamadas = 0;
        when(() => obter(36)).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result.success(_imovel(36))
              : Result<ImovelGestao>.failure(const FalhaDeConexaoException());
        });
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.recarregar();
        await cubit.recarregar();
      },
      skip: 2,
      expect: () => [
        carregado(36).copyWith(falhasAoAtualizar: 1),
        carregado(36).copyWith(falhasAoAtualizar: 2),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'falha só do histórico troca o imóvel, mantém o histórico anterior e '
      'conta a falha',
      build: () {
        when(() => obter(36))
            .thenAnswer((_) async => Result.success(_imovel(36)));
        var chamadas = 0;
        when(() => obterHistorico(36)).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result.success([_mudanca(1)])
              : Result<List<MudancaSituacao>>.failure(
                  const FalhaDeConexaoException(),
                );
        });
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.recarregar();
      },
      skip: 2,
      expect: () => [
        carregado(
          36,
          historico: ConteudoHistorico.carregado([_mudanca(1)]),
        ).copyWith(falhasAoAtualizar: 1),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'sem conteúdo anterior aplica o desfecho normal (erro vira carregado)',
      build: () {
        var chamadas = 0;
        when(() => obter(36)).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result<ImovelGestao>.failure(const FalhaDeConexaoException())
              : Result.success(_imovel(36));
        });
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.recarregar();
      },
      skip: 2,
      expect: () => [carregado(36)],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'sem conteúdo anterior e com nova falha aplica o erro, sem contar '
      'falha de atualização',
      build: () {
        when(() => obter(36)).thenAnswer(
          (_) async => Result.failure(const FalhaDeConexaoException()),
        );
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.recarregar();
      },
      skip: 2,
      expect: () => <GestaoImovelState>[],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      '401 em recarregar vira sessão expirada',
      build: () {
        var chamadas = 0;
        when(() => obter(36)).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result.success(_imovel(36))
              : Result<ImovelGestao>.failure(const SessaoExpiradaException());
        });
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.recarregar();
      },
      skip: 2,
      expect: () => [
        const GestaoImovelState(
          imovel: ConteudoImovelGestao.sessaoExpirada(),
          historico: ConteudoHistorico.carregado([]),
        ),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      '404 em recarregar vira não encontrado',
      build: () {
        var chamadas = 0;
        when(() => obter(36)).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result.success(_imovel(36))
              : Result<ImovelGestao>.failure(
                  const ImovelNaoEncontradoException(),
                );
        });
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.recarregar();
      },
      skip: 2,
      expect: () => [
        const GestaoImovelState(
          imovel: ConteudoImovelGestao.naoEncontrado(),
          historico: ConteudoHistorico.carregado([]),
        ),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'sem leitura anterior não faz nada',
      build: construir,
      act: (cubit) => cubit.recarregar(),
      expect: () => <GestaoImovelState>[],
      verify: (_) => verifyNever(() => obter(any())),
    );

    test('depois de close() nenhuma emissão acontece', () async {
      final resposta = Completer<Result<ImovelGestao>>();
      var chamadas = 0;
      when(() => obter(36)).thenAnswer((_) {
        chamadas++;
        return chamadas == 1
            ? Future.value(Result.success(_imovel(36)))
            : resposta.future;
      });
      final cubit = construir();
      await cubit.carregar(36);
      final estados = <GestaoImovelState>[];
      cubit.stream.listen(estados.add);

      final leitura = cubit.recarregar();
      await cubit.close();
      resposta.complete(Result.success(_imovel(360)));
      await leitura;

      expect(estados, isEmpty);
    });
  });

  group('registrarMudanca (depois de mudar a situação, D-10, D-18)', () {
    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'marca mudou com a MESMA situação ainda na tela e só troca imóvel e '
      'histórico quando a releitura devolve os novos (T-09-03)',
      build: () {
        final releitura = Completer<Result<ImovelGestao>>();
        var chamadas = 0;
        when(() => obter(36)).thenAnswer((_) {
          chamadas++;
          return chamadas == 1
              ? Future.value(Result.success(_imovel(36)))
              : releitura.future;
        });
        Future<void>.delayed(
          const Duration(milliseconds: 10),
          () => releitura.complete(Result.success(_imovel(360))),
        );
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.registrarMudanca();
      },
      skip: 2,
      expect: () => [
        // 1º: mudou verdadeiro, imóvel antigo ainda na tela.
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovel(36)),
          historico: const ConteudoHistorico.carregado([]),
          mudou: true,
        ),
        // 2º: só agora o imóvel relido entra.
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovel(360)),
          historico: const ConteudoHistorico.carregado([]),
          mudou: true,
        ),
      ],
      verify: (_) => verify(() => obter(36)).called(2),
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'se a releitura falhar, mudou continua verdadeiro e o conteúdo anterior '
      'fica (Pitfall 3)',
      build: () {
        var chamadas = 0;
        when(() => obter(36)).thenAnswer((_) async {
          chamadas++;
          return chamadas == 1
              ? Result.success(_imovel(36))
              : Result<ImovelGestao>.failure(const FalhaDeConexaoException());
        });
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.registrarMudanca();
      },
      skip: 2,
      expect: () => [
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovel(36)),
          historico: const ConteudoHistorico.carregado([]),
          mudou: true,
        ),
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovel(36)),
          historico: const ConteudoHistorico.carregado([]),
          mudou: true,
          falhasAoAtualizar: 1,
        ),
      ],
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'tentarNovamente depois de uma mudança mantém mudou verdadeiro',
      build: () {
        when(() => obter(36))
            .thenAnswer((_) async => Result.success(_imovel(36)));
        return construir();
      },
      act: (cubit) async {
        await cubit.carregar(36);
        await cubit.registrarMudanca();
        await cubit.tentarNovamente();
      },
      verify: (cubit) {
        expect(cubit.state.mudou, isTrue);
        expect(cubit.state.imovel, isA<ImovelGestaoCarregado>());
      },
    );

    blocTest<GestaoImovelCubit, GestaoImovelState>(
      'depois de close() não emite nada',
      build: construir,
      act: (cubit) async {
        await cubit.close();
        await cubit.registrarMudanca();
      },
      expect: () => <GestaoImovelState>[],
    );
  });

  group('versão de leitura e isClosed', () {
    test('a resposta de uma carga antiga é descartada', () async {
      final antiga = Completer<Result<ImovelGestao>>();
      final nova = Completer<Result<ImovelGestao>>();
      when(() => obter(36)).thenAnswer((_) => antiga.future);
      when(() => obter(37)).thenAnswer((_) => nova.future);
      final cubit = construir();

      final primeira = cubit.carregar(36);
      final segunda = cubit.carregar(37);
      nova.complete(Result.success(_imovel(37)));
      await segunda;
      antiga.complete(Result.success(_imovel(36)));
      await primeira;

      expect(cubit.state, carregado(37));
      await cubit.close();
    });

    test('depois de close() nenhuma emissão acontece', () async {
      final resposta = Completer<Result<ImovelGestao>>();
      when(() => obter(36)).thenAnswer((_) => resposta.future);
      final cubit = construir();
      final estados = <GestaoImovelState>[];
      cubit.stream.listen(estados.add);

      final leitura = cubit.carregar(36);
      await cubit.close();
      resposta.complete(Result.success(_imovel(36)));
      await leitura;

      expect(estados, [const GestaoImovelState()]);
      expect(cubit.isClosed, isTrue);
    });
  });
}
