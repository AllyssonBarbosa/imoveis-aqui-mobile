import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/gateways/link_launcher_gateway.dart';
import 'package:imoveis_aqui/domain/repositories/contato_repository.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:imoveis_aqui/domain/usecases/contatar_corretor_usecase.dart';
import 'package:imoveis_aqui/presentation/contato/contato_cubit.dart';
import 'package:imoveis_aqui/presentation/contato/contato_state.dart';
import 'package:mocktail/mocktail.dart';

class _ContatarCorretorUseCaseFalso extends Mock
    implements ContatarCorretorUseCase {}

void main() {
  const imovelId = 42;

  late _ContatarCorretorUseCaseFalso contatar;

  setUpAll(() {
    registerFallbackValue(CanalContato.whatsapp);
  });

  setUp(() {
    contatar = _ContatarCorretorUseCaseFalso();
  });

  ContatoCubit construir() => ContatoCubit(contatar);

  void respondeCom(Result<void> resultado) {
    when(() => contatar(any(), any())).thenAnswer((_) async => resultado);
  }

  test('estado inicial é ocioso', () {
    expect(construir().state, const ContatoState.ocioso());
  });

  blocTest<ContatoCubit, ContatoState>(
    'sucesso emite enviando(canal) e volta a ocioso',
    build: () {
      respondeCom(const Result.success(null));
      return construir();
    },
    act: (cubit) => cubit.contatar(imovelId, CanalContato.whatsapp),
    expect: () => [
      const ContatoState.enviando(CanalContato.whatsapp),
      const ContatoState.ocioso(),
    ],
    verify: (_) =>
        verify(() => contatar(imovelId, CanalContato.whatsapp)).called(1),
  );

  group('motivo da falha decidido só pelo tipo (D-14, D-15)', () {
    final casos = <String, (Exception, MotivoFalhaContato)>{
      'CanalIndisponivelException': (
        const CanalIndisponivelException(),
        MotivoFalhaContato.canalIndisponivel,
      ),
      'ImovelNaoEncontradoException': (
        const ImovelNaoEncontradoException(),
        MotivoFalhaContato.imovelIndisponivel,
      ),
      'ContatoLimiteExcedidoException': (
        const ContatoLimiteExcedidoException(),
        MotivoFalhaContato.limiteExcedido,
      ),
      'ContatoSemAplicativoException': (
        const ContatoSemAplicativoException(),
        MotivoFalhaContato.semAplicativo,
      ),
      'DioException': (
        DioException(requestOptions: RequestOptions(path: '/contato/')),
        MotivoFalhaContato.generico,
      ),
      'FormatException': (
        const FormatException('json malformado'),
        MotivoFalhaContato.generico,
      ),
      'LinkContatoInvalidoException': (
        const LinkContatoInvalidoException(),
        MotivoFalhaContato.generico,
      ),
    };

    for (final MapEntry(key: nome, value: (erro, motivo)) in casos.entries) {
      blocTest<ContatoCubit, ContatoState>(
        '$nome vira $motivo',
        build: () {
          respondeCom(Result.failure(erro));
          return construir();
        },
        act: (cubit) => cubit.contatar(imovelId, CanalContato.telefone),
        expect: () => [
          const ContatoState.enviando(CanalContato.telefone),
          ContatoState.falhou(motivo),
        ],
      );
    }
  });

  blocTest<ContatoCubit, ContatoState>(
    'toque duplo durante o POST chama o caso de uso uma vez só (D-13)',
    build: () {
      final pendente = Completer<Result<void>>();
      when(() => contatar(any(), any())).thenAnswer((_) => pendente.future);
      // Libera o POST depois do segundo toque.
      Future<void>.delayed(
        const Duration(milliseconds: 10),
        () => pendente.complete(const Result.success(null)),
      );
      return construir();
    },
    act: (cubit) async {
      final primeiro = cubit.contatar(imovelId, CanalContato.whatsapp);
      await cubit.contatar(imovelId, CanalContato.whatsapp);
      await primeiro;
    },
    expect: () => [
      const ContatoState.enviando(CanalContato.whatsapp),
      const ContatoState.ocioso(),
    ],
    verify: (_) =>
        verify(() => contatar(imovelId, CanalContato.whatsapp)).called(1),
  );

  blocTest<ContatoCubit, ContatoState>(
    'duas falhas seguidas emitem de novo (Pitfall 3)',
    build: () {
      respondeCom(const Result.failure(ContatoLimiteExcedidoException()));
      return construir();
    },
    act: (cubit) async {
      await cubit.contatar(imovelId, CanalContato.whatsapp);
      await cubit.contatar(imovelId, CanalContato.whatsapp);
    },
    expect: () => [
      const ContatoState.enviando(CanalContato.whatsapp),
      const ContatoState.falhou(MotivoFalhaContato.limiteExcedido),
      const ContatoState.enviando(CanalContato.whatsapp),
      const ContatoState.falhou(MotivoFalhaContato.limiteExcedido),
    ],
  );

  test('close() com o POST em voo não emite mais nada nem lança', () async {
    final pendente = Completer<Result<void>>();
    when(() => contatar(any(), any())).thenAnswer((_) => pendente.future);
    final cubit = construir();
    final emitidos = <ContatoState>[];
    final assinatura = cubit.stream.listen(emitidos.add);

    final futuro = cubit.contatar(imovelId, CanalContato.email);
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    pendente.complete(const Result.failure(ContatoSemAplicativoException()));

    await expectLater(futuro, completes);
    await assinatura.cancel();
    expect(emitidos, [const ContatoState.enviando(CanalContato.email)]);
    expect(cubit.isClosed, isTrue);
  });

  blocTest<ContatoCubit, ContatoState>(
    'Loading do caso de uso emite enviando e volta a ocioso',
    build: () {
      respondeCom(const Result.loading());
      return construir();
    },
    act: (cubit) => cubit.contatar(imovelId, CanalContato.whatsapp),
    expect: () => [
      const ContatoState.enviando(CanalContato.whatsapp),
      const ContatoState.ocioso(),
    ],
  );
}
