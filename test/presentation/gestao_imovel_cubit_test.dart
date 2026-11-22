import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel_gestao.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/obter_imovel_gestao_usecase.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_state.dart';
import 'package:mocktail/mocktail.dart';

class _ObterImovelGestaoUseCaseFalso extends Mock
    implements ObterImovelGestaoUseCase {}

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

  setUp(() {
    obter = _ObterImovelGestaoUseCaseFalso();
  });

  GestaoImovelCubit construir() => GestaoImovelCubit(obter);

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
      expect: () => [
        const GestaoImovelState(),
        GestaoImovelState(imovel: ConteudoImovelGestao.carregado(_imovel(36))),
      ],
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
        const GestaoImovelState(imovel: ConteudoImovelGestao.erro()),
      ],
    );
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
        const GestaoImovelState(imovel: ConteudoImovelGestao.erro()),
        const GestaoImovelState(),
        GestaoImovelState(imovel: ConteudoImovelGestao.carregado(_imovel(36))),
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

      expect(cubit.state.imovel, ConteudoImovelGestao.carregado(_imovel(37)));
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
