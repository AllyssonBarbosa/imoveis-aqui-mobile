import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/acervo_por_corretor.dart';
import 'package:imoveis_aqui/domain/entities/contatos_por_corretor.dart';
import 'package:imoveis_aqui/domain/entities/mudancas_recentes.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/entities/totais_por_situacao.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/obter_acervo_por_corretor_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_contatos_por_corretor_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_mudancas_recentes_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_totais_por_situacao_usecase.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_cubit.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_state.dart';
import 'package:mocktail/mocktail.dart';

class _TotaisFalso extends Mock implements ObterTotaisPorSituacaoUseCase {}

class _AcervoFalso extends Mock implements ObterAcervoPorCorretorUseCase {}

class _ContatosFalso extends Mock implements ObterContatosPorCorretorUseCase {}

class _MudancasFalso extends Mock implements ObterMudancasRecentesUseCase {}

void main() {
  late _TotaisFalso totais;
  late _AcervoFalso acervo;
  late _ContatosFalso contatos;
  late _MudancasFalso mudancas;

  // Números de propósito diferentes da soma das linhas: o app não confere.
  final dadosTotais = TotaisPorSituacao(
    porSituacao: const {
      SituacaoImovel.disponivel: 5,
      SituacaoImovel.reservado: 2,
      SituacaoImovel.vendido: 1,
      SituacaoImovel.alugado: 0,
    },
    total: 9,
  );
  final dadosAcervo = AcervoPorCorretor(
    linhas: const [
      AcervoDoCorretor(corretorId: 1, nome: 'Ana', ativo: true, total: 4),
      AcervoDoCorretor(corretorId: 2, nome: 'Beto', ativo: false, total: 3),
    ],
    total: 99,
  );
  final dadosContatos = ContatosPorCorretor(
    linhas: const [
      ContatosDoCorretor(
        corretorId: 1,
        nome: 'Ana',
        ativo: true,
        total: 3,
        pendentes: 2,
      ),
      ContatosDoCorretor(total: 1, pendentes: 1),
    ],
    total: 50,
    pendentes: 40,
  );
  final dadosContatosA = ContatosPorCorretor(
    linhas: const [],
    total: 11,
    pendentes: 1,
  );
  final dadosContatosB = ContatosPorCorretor(
    linhas: const [],
    total: 22,
    pendentes: 2,
  );
  final dadosMudancas = MudancasRecentes(dias: 7, mudancas: const []);

  final periodoA = PeriodoContatos(
    de: DateTime(2026, 11, 1),
    ate: DateTime(2026, 11, 10),
  );
  final periodoB = PeriodoContatos(
    de: DateTime(2026, 11, 11),
    ate: DateTime(2026, 11, 20),
  );

  setUpAll(() {
    registerFallbackValue(periodoA);
  });

  setUp(() {
    totais = _TotaisFalso();
    acervo = _AcervoFalso();
    contatos = _ContatosFalso();
    mudancas = _MudancasFalso();
  });

  AreaGestorCubit construir() =>
      AreaGestorCubit(totais, acervo, contatos, mudancas);

  void tudoResponde() {
    when(() => totais()).thenAnswer((_) async => Result.success(dadosTotais));
    when(() => acervo()).thenAnswer((_) async => Result.success(dadosAcervo));
    when(() => contatos(any()))
        .thenAnswer((_) async => Result.success(dadosContatos));
    when(() => mudancas())
        .thenAnswer((_) async => Result.success(dadosMudancas));
  }

  group('carregar (D-07)', () {
    test(
      'pede os 4 relatórios uma vez cada, o de contatos sem período',
      () async {
        tudoResponde();
        final cubit = construir();

        cubit.carregar();
        await pumpEventQueue();

        verify(() => totais()).called(1);
        verify(() => acervo()).called(1);
        verify(() => contatos(null)).called(1);
        verify(() => mudancas()).called(1);
        await cubit.close();
      },
    );

    test('pede os 4 sem esperar um pelo outro', () async {
      final totaisPendente = Completer<Result<TotaisPorSituacao>>();
      when(() => totais()).thenAnswer((_) => totaisPendente.future);
      when(() => acervo()).thenAnswer((_) async => Result.success(dadosAcervo));
      when(() => contatos(any()))
          .thenAnswer((_) async => Result.success(dadosContatos));
      when(() => mudancas())
          .thenAnswer((_) async => Result.success(dadosMudancas));
      final cubit = construir();

      cubit.carregar();
      await pumpEventQueue();

      expect(cubit.state.totais, isA<SecaoCarregando<TotaisPorSituacao>>());
      expect(cubit.state.acervo, EstadoSecao.carregada(dadosAcervo));
      expect(cubit.state.contatos, EstadoSecao.carregada(dadosContatos));
      expect(cubit.state.mudancas, EstadoSecao.carregada(dadosMudancas));
      await cubit.close();
    });

    test('as 4 seções ficam com exatamente as entidades do servidor', () async {
      tudoResponde();
      final cubit = construir();

      cubit.carregar();
      await pumpEventQueue();

      expect(cubit.state.totais, EstadoSecao.carregada(dadosTotais));
      expect(cubit.state.acervo, EstadoSecao.carregada(dadosAcervo));
      expect(cubit.state.contatos, EstadoSecao.carregada(dadosContatos));
      expect(cubit.state.mudancas, EstadoSecao.carregada(dadosMudancas));
      expect(cubit.state.periodo, isNull);
      expect(cubit.state.sessaoExpirada, isFalse);
      // Nenhuma conta no aparelho: os totais seguem os do servidor.
      final carregado = cubit.state.acervo as SecaoCarregada<AcervoPorCorretor>;
      expect(carregado.dados.total, 99);
      await cubit.close();
    });
  });

  group('falha isolada (D-07, D-23, D-24)', () {
    Future<AreaGestorCubit> comAcervoFalhando(Exception erro) async {
      tudoResponde();
      when(() => acervo()).thenAnswer((_) async => Result.failure(erro));
      final cubit = construir();
      cubit.carregar();
      await pumpEventQueue();
      return cubit;
    }

    test(
      'falha genérica do acervo vira indisponivel e não toca nas outras',
      () async {
        final cubit = await comAcervoFalhando(Exception('boom'));

        expect(
          cubit.state.acervo,
          const EstadoSecao<AcervoPorCorretor>.comFalha(
            FalhaDaSecao.indisponivel,
          ),
        );
        expect(cubit.state.totais, EstadoSecao.carregada(dadosTotais));
        expect(cubit.state.contatos, EstadoSecao.carregada(dadosContatos));
        expect(cubit.state.mudancas, EstadoSecao.carregada(dadosMudancas));
        expect(cubit.state.sessaoExpirada, isFalse);
        await cubit.close();
      },
    );

    test('SemPermissaoException vira semPermissao', () async {
      final cubit = await comAcervoFalhando(SemPermissaoException());

      expect(
        cubit.state.acervo,
        const EstadoSecao<AcervoPorCorretor>.comFalha(
          FalhaDaSecao.semPermissao,
        ),
      );
      expect(cubit.state.sessaoExpirada, isFalse);
      await cubit.close();
    });

    test('FormatException (wire malformado) vira indisponivel', () async {
      final cubit = await comAcervoFalhando(const FormatException('wire'));

      expect(
        cubit.state.acervo,
        const EstadoSecao<AcervoPorCorretor>.comFalha(
          FalhaDaSecao.indisponivel,
        ),
      );
      await cubit.close();
    });
  });

  group('tentarNovamente (D-07)', () {
    test('repete só a seção pedida e não mexe nas outras', () async {
      tudoResponde();
      final falhaDoAcervo = Exception('boom');
      when(() => acervo())
          .thenAnswer((_) async => Result.failure(falhaDoAcervo));
      final cubit = construir();
      cubit.carregar();
      await pumpEventQueue();

      final reposta = Completer<Result<AcervoPorCorretor>>();
      when(() => acervo()).thenAnswer((_) => reposta.future);
      final emitidos = <AreaGestorState>[];
      final assinatura = cubit.stream.listen(emitidos.add);

      unawaited(cubit.tentarNovamente(SecaoDaAreaGestor.acervo));
      await pumpEventQueue();

      expect(cubit.state.acervo, isA<SecaoCarregando<AcervoPorCorretor>>());
      expect(cubit.state.totais, EstadoSecao.carregada(dadosTotais));
      expect(cubit.state.contatos, EstadoSecao.carregada(dadosContatos));
      expect(cubit.state.mudancas, EstadoSecao.carregada(dadosMudancas));

      reposta.complete(Result.success(dadosAcervo));
      await pumpEventQueue();

      expect(cubit.state.acervo, EstadoSecao.carregada(dadosAcervo));
      verify(() => acervo()).called(2);
      verify(() => totais()).called(1);
      verify(() => contatos(null)).called(1);
      verify(() => mudancas()).called(1);
      expect(emitidos, hasLength(2));
      await assinatura.cancel();
      await cubit.close();
    });

    test('cada seção repete o seu próprio use case', () async {
      tudoResponde();
      final cubit = construir();
      cubit.carregar();
      await pumpEventQueue();

      await cubit.tentarNovamente(SecaoDaAreaGestor.totais);
      await cubit.tentarNovamente(SecaoDaAreaGestor.contatos);
      await cubit.tentarNovamente(SecaoDaAreaGestor.mudancas);

      verify(() => totais()).called(2);
      verify(() => acervo()).called(1);
      verify(() => contatos(null)).called(2);
      verify(() => mudancas()).called(2);
      await cubit.close();
    });

    test('dois "Tentar de novo" seguidos: vale a resposta do último', () async {
      tudoResponde();
      final cubit = construir();
      cubit.carregar();
      await pumpEventQueue();

      final primeira = Completer<Result<AcervoPorCorretor>>();
      final segunda = Completer<Result<AcervoPorCorretor>>();
      final respostas = [primeira, segunda];
      when(() => acervo()).thenAnswer((_) => respostas.removeAt(0).future);
      final antigo = AcervoPorCorretor(linhas: const [], total: 1);
      final novo = AcervoPorCorretor(linhas: const [], total: 2);

      unawaited(cubit.tentarNovamente(SecaoDaAreaGestor.acervo));
      unawaited(cubit.tentarNovamente(SecaoDaAreaGestor.acervo));
      await pumpEventQueue();

      segunda.complete(Result.success(novo));
      await pumpEventQueue();
      primeira.complete(Result.success(antigo));
      await pumpEventQueue();

      expect(cubit.state.acervo, EstadoSecao.carregada(novo));
      await cubit.close();
    });
  });

  group('período só nos contatos (D-16)', () {
    test(
      'aplicarPeriodo guarda o período e recarrega só os contatos',
      () async {
        tudoResponde();
        final cubit = construir();
        cubit.carregar();
        await pumpEventQueue();

        final resposta = Completer<Result<ContatosPorCorretor>>();
        when(() => contatos(periodoA)).thenAnswer((_) => resposta.future);

        unawaited(cubit.aplicarPeriodo(periodoA));
        await pumpEventQueue();

        expect(cubit.state.periodo, periodoA);
        expect(
          cubit.state.contatos,
          isA<SecaoCarregando<ContatosPorCorretor>>(),
        );
        expect(cubit.state.totais, EstadoSecao.carregada(dadosTotais));
        expect(cubit.state.acervo, EstadoSecao.carregada(dadosAcervo));
        expect(cubit.state.mudancas, EstadoSecao.carregada(dadosMudancas));

        resposta.complete(Result.success(dadosContatosA));
        await pumpEventQueue();

        expect(cubit.state.contatos, EstadoSecao.carregada(dadosContatosA));
        verify(() => contatos(periodoA)).called(1);
        verify(() => totais()).called(1);
        verify(() => acervo()).called(1);
        verify(() => mudancas()).called(1);
        await cubit.close();
      },
    );

    test('limparPeriodo volta a nulo e pede os contatos sem período', () async {
      tudoResponde();
      when(() => contatos(periodoA))
          .thenAnswer((_) async => Result.success(dadosContatosA));
      final cubit = construir();
      cubit.carregar();
      await pumpEventQueue();
      await cubit.aplicarPeriodo(periodoA);

      await cubit.limparPeriodo();

      expect(cubit.state.periodo, isNull);
      expect(cubit.state.contatos, EstadoSecao.carregada(dadosContatos));
      verify(() => contatos(null)).called(2);
      await cubit.close();
    });

    test('o mesmo período, ou limpar sem período, não chama a API', () async {
      tudoResponde();
      when(() => contatos(periodoA))
          .thenAnswer((_) async => Result.success(dadosContatosA));
      final cubit = construir();
      cubit.carregar();
      await pumpEventQueue();

      await cubit.limparPeriodo();
      verify(() => contatos(null)).called(1);

      await cubit.aplicarPeriodo(periodoA);
      await cubit.aplicarPeriodo(periodoA);
      verify(() => contatos(periodoA)).called(1);
      await cubit.close();
    });

    test('"Tentar de novo" dos contatos mantém o período aplicado', () async {
      tudoResponde();
      when(() => contatos(periodoA))
          .thenAnswer((_) async => Result.success(dadosContatosA));
      final cubit = construir();
      cubit.carregar();
      await pumpEventQueue();
      await cubit.aplicarPeriodo(periodoA);

      await cubit.tentarNovamente(SecaoDaAreaGestor.contatos);

      verify(() => contatos(periodoA)).called(2);
      await cubit.close();
    });

    test(
      'resposta do período A que chega depois da de B é descartada',
      () async {
        tudoResponde();
        final respostaA = Completer<Result<ContatosPorCorretor>>();
        final respostaB = Completer<Result<ContatosPorCorretor>>();
        when(() => contatos(periodoA)).thenAnswer((_) => respostaA.future);
        when(() => contatos(periodoB)).thenAnswer((_) => respostaB.future);
        final cubit = construir();
        cubit.carregar();
        await pumpEventQueue();

        unawaited(cubit.aplicarPeriodo(periodoA));
        unawaited(cubit.aplicarPeriodo(periodoB));
        await pumpEventQueue();

        respostaB.complete(Result.success(dadosContatosB));
        await pumpEventQueue();
        respostaA.complete(Result.success(dadosContatosA));
        await pumpEventQueue();

        expect(cubit.state.periodo, periodoB);
        expect(cubit.state.contatos, EstadoSecao.carregada(dadosContatosB));
        await cubit.close();
      },
    );
  });

  group('401 terminal (D-22)', () {
    test(
      'SessaoExpiradaException em qualquer seção marca sessaoExpirada',
      () async {
        tudoResponde();
        when(() => mudancas())
            .thenAnswer((_) async => Result.failure(SessaoExpiradaException()));
        final cubit = construir();

        cubit.carregar();
        await pumpEventQueue();

        expect(cubit.state.sessaoExpirada, isTrue);
        await cubit.close();
      },
    );

    test('depois do 401 nada mais é emitido nem pedido', () async {
      tudoResponde();
      final totaisPendente = Completer<Result<TotaisPorSituacao>>();
      when(() => totais()).thenAnswer((_) => totaisPendente.future);
      when(() => acervo())
          .thenAnswer((_) async => Result.failure(SessaoExpiradaException()));
      final cubit = construir();
      cubit.carregar();
      await pumpEventQueue();
      expect(cubit.state.sessaoExpirada, isTrue);

      final emitidos = <AreaGestorState>[];
      final assinatura = cubit.stream.listen(emitidos.add);

      // Resposta atrasada de outra seção.
      totaisPendente.complete(Result.success(dadosTotais));
      await pumpEventQueue();
      expect(cubit.state.totais, isA<SecaoCarregando<TotaisPorSituacao>>());

      await cubit.tentarNovamente(SecaoDaAreaGestor.mudancas);
      await cubit.aplicarPeriodo(periodoA);
      await cubit.limparPeriodo();
      await pumpEventQueue();

      expect(emitidos, isEmpty);
      verify(() => totais()).called(1);
      verify(() => acervo()).called(1);
      verify(() => contatos(null)).called(1);
      verify(() => mudancas()).called(1);
      verifyNever(() => contatos(periodoA));
      await assinatura.cancel();
      await cubit.close();
    });
  });

  group('close (T-12)', () {
    test('resposta que chega depois de close() não lança', () async {
      final pendente = Completer<Result<TotaisPorSituacao>>();
      when(() => totais()).thenAnswer((_) => pendente.future);
      when(() => acervo()).thenAnswer((_) async => Result.success(dadosAcervo));
      when(() => contatos(any()))
          .thenAnswer((_) async => Result.success(dadosContatos));
      when(() => mudancas())
          .thenAnswer((_) async => Result.success(dadosMudancas));
      final cubit = construir();
      cubit.carregar();
      await pumpEventQueue();

      await cubit.close();
      pendente.complete(Result.success(dadosTotais));
      await pumpEventQueue();

      expect(cubit.isClosed, isTrue);
    });
  });
}
