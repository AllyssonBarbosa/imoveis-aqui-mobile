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
