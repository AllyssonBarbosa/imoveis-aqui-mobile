import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/repositories/gestao_imovel_repository.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:imoveis_aqui/domain/usecases/mudar_situacao_usecase.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/mudar_situacao_cubit.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/mudar_situacao_state.dart';
import 'package:mocktail/mocktail.dart';

class _MudarSituacaoUseCaseFalso extends Mock implements MudarSituacaoUseCase {}

void main() {
  const imovelId = 36;

  late _MudarSituacaoUseCaseFalso mudar;

  setUpAll(() {
    registerFallbackValue(SituacaoImovel.disponivel);
  });

  setUp(() {
    mudar = _MudarSituacaoUseCaseFalso();
  });

  MudarSituacaoCubit construir() => MudarSituacaoCubit(mudar);

  void respondeCom(Result<void> resultado) {
    when(() => mudar(any(), any(), observacao: any(named: 'observacao')))
        .thenAnswer((_) async => resultado);
  }

  MudarSituacaoCubit iniciado() =>
      construir()
        ..iniciar(imovelId: imovelId, atual: SituacaoImovel.disponivel);

  test('estado inicial: sem imóvel, sem escolha e não pode confirmar', () {
    final cubit = construir();

    expect(cubit.state, const MudarSituacaoState());
    expect(cubit.state.podeConfirmar, isFalse);
    expect(cubit.state.envio, const EnvioSituacao.ocioso());
  });

  group('escolha (D-09)', () {
    test('iniciar guarda o imóvel e a situação atual, sem escolha: '
        'podeConfirmar é falso', () {
      final cubit = iniciado();

      expect(cubit.state.imovelId, imovelId);
      expect(cubit.state.atual, SituacaoImovel.disponivel);
      expect(cubit.state.escolhida, isNull);
      expect(cubit.state.podeConfirmar, isFalse);
    });

    test('escolher a situação ATUAL não muda nada', () {
      final cubit = iniciado();
      final emitidos = <MudarSituacaoState>[];
      final inscricao = cubit.stream.listen(emitidos.add);

      cubit.escolher(SituacaoImovel.disponivel);

      expect(cubit.state.escolhida, isNull);
      expect(cubit.state.podeConfirmar, isFalse);
      expect(emitidos, isEmpty);
      unawaited(inscricao.cancel());
    });

    test('escolher uma situação diferente da atual habilita o Confirmar', () {
      final cubit = iniciado()..escolher(SituacaoImovel.reservado);

      expect(cubit.state.escolhida, SituacaoImovel.reservado);
      expect(cubit.state.podeConfirmar, isTrue);
    });

    test('iniciar de novo descarta a escolha e o envio anteriores', () {
      final cubit = iniciado()..escolher(SituacaoImovel.reservado);

      cubit.iniciar(imovelId: 14, atual: SituacaoImovel.vendido);

      expect(cubit.state.imovelId, 14);
      expect(cubit.state.atual, SituacaoImovel.vendido);
      expect(cubit.state.escolhida, isNull);
      expect(cubit.state.envio, const EnvioSituacao.ocioso());
    });
  });

  group('confirmar', () {
    blocTest<MudarSituacaoCubit, MudarSituacaoState>(
      'sucesso emite enviando e concluido(reservado); o UseCase recebe '
      '(36, reservado, observacao: "")',
      build: () {
        respondeCom(const Result.success(null));
        return iniciado()..escolher(SituacaoImovel.reservado);
      },
      act: (cubit) => cubit.confirmar(),
      expect: () => [
        isA<MudarSituacaoState>().having(
          (e) => e.envio,
          'envio',
          const EnvioSituacao.enviando(),
        ),
        isA<MudarSituacaoState>().having(
          (e) => e.envio,
          'envio',
          const EnvioSituacao.concluido(SituacaoImovel.reservado),
        ),
      ],
      verify: (_) => verify(
        () => mudar(imovelId, SituacaoImovel.reservado, observacao: ''),
      ).called(1),
    );

    blocTest<MudarSituacaoCubit, MudarSituacaoState>(
      'falha emite enviando e falhou, mantendo a escolha',
      build: () {
        respondeCom(Result.failure(Exception('sem rede')));
        return iniciado()..escolher(SituacaoImovel.reservado);
      },
      act: (cubit) => cubit.confirmar(),
      expect: () => [
        isA<MudarSituacaoState>().having(
          (e) => e.envio,
          'envio',
          const EnvioSituacao.enviando(),
        ),
        isA<MudarSituacaoState>()
            .having((e) => e.envio, 'envio', const EnvioSituacao.falhou())
            .having((e) => e.escolhida, 'escolhida', SituacaoImovel.reservado),
      ],
      verify: (cubit) => expect(cubit.state.podeConfirmar, isTrue),
    );

    blocTest<MudarSituacaoCubit, MudarSituacaoState>(
      'recusa do servidor (400/403) emite enviando e recusado(mensagem), '
      'mantendo a escolha e Confirmar habilitado (D-10)',
      build: () {
        respondeCom(
          Result.failure(
            const MudancaSituacaoRecusadaException(
              'O imóvel já está reservado.',
            ),
          ),
        );
        return iniciado()..escolher(SituacaoImovel.reservado);
      },
      act: (cubit) => cubit.confirmar(),
      expect: () => [
        isA<MudarSituacaoState>().having(
          (e) => e.envio,
          'envio',
          const EnvioSituacao.enviando(),
        ),
        isA<MudarSituacaoState>()
            .having(
              (e) => e.envio,
              'envio',
              const EnvioSituacao.recusado('O imóvel já está reservado.'),
            )
            .having((e) => e.escolhida, 'escolhida', SituacaoImovel.reservado),
      ],
      verify: (cubit) => expect(cubit.state.podeConfirmar, isTrue),
    );

    blocTest<MudarSituacaoCubit, MudarSituacaoState>(
      'escolher outra situação depois de uma recusa volta o envio a ocioso '
      '(some a mensagem)',
      build: () {
        respondeCom(
          Result.failure(const MudancaSituacaoRecusadaException('Recusado.')),
        );
        return iniciado()..escolher(SituacaoImovel.reservado);
      },
      act: (cubit) async {
        await cubit.confirmar();
        cubit.escolher(SituacaoImovel.vendido);
      },
      verify: (cubit) {
        expect(cubit.state.escolhida, SituacaoImovel.vendido);
        expect(cubit.state.envio, const EnvioSituacao.ocioso());
      },
    );

    for (final (nome, erro, esperado) in <(String, Exception, EnvioSituacao)>[
      (
        '404 (ImovelNaoEncontradoException)',
        const ImovelNaoEncontradoException(),
        const EnvioSituacao.naoEncontrado(),
      ),
      (
        '401 (SessaoExpiradaException)',
        const SessaoExpiradaException(),
        const EnvioSituacao.sessaoExpirada(),
      ),
      (
        'rede, tempo esgotado ou 5xx (FalhaDeConexaoException)',
        const FalhaDeConexaoException(),
        const EnvioSituacao.falhou(),
      ),
    ]) {
      blocTest<MudarSituacaoCubit, MudarSituacaoState>(
        '$nome: emite enviando e o desfecho do tipo, com UMA chamada ao '
        'UseCase (sem nova tentativa automática, D-10)',
        build: () {
          respondeCom(Result.failure(erro));
          return iniciado()..escolher(SituacaoImovel.reservado);
        },
        act: (cubit) => cubit.confirmar(),
        expect: () => [
          isA<MudarSituacaoState>().having(
            (e) => e.envio,
            'envio',
            const EnvioSituacao.enviando(),
          ),
          isA<MudarSituacaoState>()
              .having((e) => e.envio, 'envio', esperado)
              .having(
                (e) => e.escolhida,
                'escolhida',
                SituacaoImovel.reservado,
              ),
        ],
        verify: (cubit) {
          verify(
            () => mudar(imovelId, SituacaoImovel.reservado, observacao: ''),
          ).called(1);
          expect(cubit.state.podeConfirmar, isTrue);
        },
      );
    }

    blocTest<MudarSituacaoCubit, MudarSituacaoState>(
      'confirmar(observacao: "Sinal pago") entrega o texto ao UseCase',
      build: () {
        respondeCom(const Result.success(null));
        return iniciado()..escolher(SituacaoImovel.reservado);
      },
      act: (cubit) => cubit.confirmar(observacao: 'Sinal pago'),
      verify: (_) => verify(
        () =>
            mudar(imovelId, SituacaoImovel.reservado, observacao: 'Sinal pago'),
      ).called(1),
    );

    blocTest<MudarSituacaoCubit, MudarSituacaoState>(
      'sem escolha, confirmar não chama o UseCase nem emite',
      build: iniciado,
      act: (cubit) => cubit.confirmar(),
      expect: () => <MudarSituacaoState>[],
      verify: (_) => verifyNever(
        () => mudar(any(), any(), observacao: any(named: 'observacao')),
      ),
    );

    blocTest<MudarSituacaoCubit, MudarSituacaoState>(
      'toque duplo com o UseCase em voo gera UMA chamada (D-10, T-09-07) e '
      'escolher durante o envio é ignorado',
      build: () {
        final pendente = Completer<Result<void>>();
        when(() => mudar(any(), any(), observacao: any(named: 'observacao')))
            .thenAnswer((_) => pendente.future);
        // Libera o POST depois do segundo toque.
        Future<void>.delayed(
          const Duration(milliseconds: 10),
          () => pendente.complete(const Result.success(null)),
        );
        return iniciado()..escolher(SituacaoImovel.reservado);
      },
      act: (cubit) async {
        final primeiro = cubit.confirmar();
        await cubit.confirmar();
        cubit.escolher(SituacaoImovel.vendido);
        await primeiro;
      },
      expect: () => [
        isA<MudarSituacaoState>().having(
          (e) => e.envio,
          'envio',
          const EnvioSituacao.enviando(),
        ),
        isA<MudarSituacaoState>()
            .having(
              (e) => e.envio,
              'envio',
              const EnvioSituacao.concluido(SituacaoImovel.reservado),
            )
            .having((e) => e.escolhida, 'escolhida', SituacaoImovel.reservado),
      ],
      verify: (_) => verify(
        () => mudar(imovelId, SituacaoImovel.reservado, observacao: ''),
      ).called(1),
    );

    test('com o envio em voo podeConfirmar é falso', () async {
      final pendente = Completer<Result<void>>();
      when(() => mudar(any(), any(), observacao: any(named: 'observacao')))
          .thenAnswer((_) => pendente.future);
      final cubit = iniciado()..escolher(SituacaoImovel.reservado);

      final envio = cubit.confirmar();

      expect(cubit.state.envio, const EnvioSituacao.enviando());
      expect(cubit.state.podeConfirmar, isFalse);
      pendente.complete(const Result.success(null));
      await envio;
    });

    test('nunca emite depois de close(): a resposta chega com o Cubit '
        'fechado', () async {
      final pendente = Completer<Result<void>>();
      when(() => mudar(any(), any(), observacao: any(named: 'observacao')))
          .thenAnswer((_) => pendente.future);
      final cubit = iniciado()..escolher(SituacaoImovel.reservado);

      final envio = cubit.confirmar();
      await cubit.close();
      pendente.complete(const Result.success(null));

      await expectLater(envio, completes);
    });

    blocTest<MudarSituacaoCubit, MudarSituacaoState>(
      'escolher depois de uma falha volta o envio a ocioso',
      build: () {
        respondeCom(Result.failure(Exception('sem rede')));
        return iniciado()..escolher(SituacaoImovel.reservado);
      },
      act: (cubit) async {
        await cubit.confirmar();
        cubit.escolher(SituacaoImovel.vendido);
      },
      verify: (cubit) {
        expect(cubit.state.escolhida, SituacaoImovel.vendido);
        expect(cubit.state.envio, const EnvioSituacao.ocioso());
      },
    );
  });
}
