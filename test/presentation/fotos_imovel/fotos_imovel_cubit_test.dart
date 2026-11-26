import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/foto_imovel.dart';
import 'package:imoveis_aqui/domain/gateways/preparador_de_foto_gateway.dart';
import 'package:imoveis_aqui/domain/gateways/seletor_de_fotos_gateway.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/repositories/fotos_imovel_repository.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:imoveis_aqui/domain/usecases/apagar_foto_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/definir_capa_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/descartar_foto_preparada_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/enviar_foto_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/escolher_fotos_da_galeria_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/listar_fotos_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/preparar_foto_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/reordenar_fotos_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/tirar_foto_usecase.dart';
import 'package:imoveis_aqui/presentation/fotos_imovel/fotos_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/fotos_imovel/fotos_imovel_state.dart';
import 'package:mocktail/mocktail.dart';

class _Listar extends Mock implements ListarFotosUseCase {}

class _Tirar extends Mock implements TirarFotoUseCase {}

class _Galeria extends Mock implements EscolherFotosDaGaleriaUseCase {}

class _Preparar extends Mock implements PrepararFotoUseCase {}

class _Enviar extends Mock implements EnviarFotoUseCase {}

class _Descartar extends Mock implements DescartarFotoPreparadaUseCase {}

class _Reordenar extends Mock implements ReordenarFotosUseCase {}

class _Capa extends Mock implements DefinirCapaUseCase {}

class _Apagar extends Mock implements ApagarFotoUseCase {}

const _imovel = 36;

FotoImovel _foto(int id, int ordem, {bool capa = false}) => FotoImovel(
  id: id,
  url: 'http://api.test/media/imoveis/fotos/$id.jpg',
  ordem: ordem,
  capa: capa,
);

final _tres = [_foto(10, 0, capa: true), _foto(20, 1), _foto(30, 2)];
final _quatro = [..._tres, _foto(40, 3)];

FotoEscolhida _original(String nome) => FotoEscolhida(caminho: '/camera/$nome');
FotoEscolhida _preparada(String nome) => FotoEscolhida(caminho: '/cache/$nome');

/// Espera as microtarefas e os timers zerados do Cubit rodarem.
Future<void> _esperar() => Future<void>.delayed(Duration.zero);

void main() {
  late _Listar listar;
  late _Tirar tirar;
  late _Galeria galeria;
  late _Preparar preparar;
  late _Enviar enviar;
  late _Descartar descartar;
  late _Reordenar reordenar;
  late _Capa capa;
  late _Apagar apagar;

  setUpAll(() {
    registerFallbackValue(const FotoEscolhida(caminho: '/x'));
  });

  setUp(() {
    listar = _Listar();
    tirar = _Tirar();
    galeria = _Galeria();
    preparar = _Preparar();
    enviar = _Enviar();
    descartar = _Descartar();
    reordenar = _Reordenar();
    capa = _Capa();
    apagar = _Apagar();
    when(() => listar(_imovel)).thenAnswer((_) async => Result.success(_tres));
    // Preparar devolve o "mesmo nome" na pasta de cache.
    when(() => preparar(any())).thenAnswer((invocacao) async {
      final original = invocacao.positionalArguments.first as FotoEscolhida;
      return Result.success(_preparada(original.caminho.split('/').last));
    });
    when(() => descartar(any())).thenAnswer((_) async {});
  });

  FotosImovelCubit criar() => FotosImovelCubit(
    listar,
    tirar,
    galeria,
    preparar,
    enviar,
    descartar,
    reordenar,
    capa,
    apagar,
  );

  Future<FotosImovelCubit> carregado() async {
    final cubit = criar();
    await cubit.carregar(_imovel);
    return cubit;
  }

  void enviarResponde(
    Future<Result<FotoImovel>> Function(FotoEscolhida preparada) resposta,
  ) {
    when(() => enviar(_imovel, any(), aoProgredir: any(named: 'aoProgredir')))
        .thenAnswer(
          (invocacao) =>
              resposta(invocacao.positionalArguments[1] as FotoEscolhida),
        );
  }

  group('leitura da lista', () {
    blocTest<FotosImovelCubit, FotosImovelState>(
      'carregar: carregando → a lista do servidor, na ordem dele',
      build: criar,
      act: (cubit) => cubit.carregar(_imovel),
      expect: () => [
        const FotosImovelState(),
        FotosImovelState(lista: ListaFotos.carregada(_tres)),
      ],
    );

    final desfechos = <String, (Exception, ListaFotos)>{
      'falha genérica → erro': (
        const FalhaDeConexaoException(),
        const ListaFotos.erro(),
      ),
      '404 → fora do acervo': (
        const ImovelNaoEncontradoException(),
        const ListaFotos.naoEncontrado(),
      ),
      '401 → sessão expirada': (
        const SessaoExpiradaException(),
        const ListaFotos.sessaoExpirada(),
      ),
    };
    for (final desfecho in desfechos.entries) {
      blocTest<FotosImovelCubit, FotosImovelState>(
        'carregar: ${desfecho.key}',
        setUp: () =>
            when(() => listar(_imovel))
                .thenAnswer((_) async => Result.failure(desfecho.value.$1)),
        build: criar,
        act: (cubit) => cubit.carregar(_imovel),
        expect: () => [
          const FotosImovelState(),
          FotosImovelState(lista: desfecho.value.$2),
        ],
      );
    }

    test('tentarNovamente relê com o id guardado', () async {
      when(() => listar(_imovel)).thenAnswer(
        (_) async => const Result.failure(FalhaDeConexaoException()),
      );
      final cubit = await carregado();
      when(() => listar(_imovel))
          .thenAnswer((_) async => Result.success(_tres));

      await cubit.tentarNovamente();

      expect(cubit.state.lista, ListaFotos.carregada(_tres));
      await cubit.close();
    });
  });

  group('fila de envio (D-18)', () {
    test('três fotos sobem uma por vez, na ordem da escolha; cada aceita sai '
        'da fila e a lista é relida', () async {
      final pendentes = <String, Completer<Result<FotoImovel>>>{};
      final ordemDeEnvio = <String>[];
      enviarResponde((preparada) {
        final nome = preparada.caminho.split('/').last;
        ordemDeEnvio.add(nome);
        return (pendentes[nome] = Completer()).future;
      });
      final cubit = await carregado();

      cubit.adicionar([
        _original('a.jpg'),
        _original('b.jpg'),
        _original('c.jpg'),
      ]);
      await _esperar();

      // Só a primeira está no ar; as outras aguardam.
      expect(ordemDeEnvio, ['a.jpg']);
      expect(
        [for (final envio in cubit.state.fila) envio.estado.runtimeType],
        [EnvioEnviando, EnvioAguardando, EnvioAguardando],
      );

      when(() => listar(_imovel))
          .thenAnswer((_) async => Result.success(_quatro));
      pendentes['a.jpg']!.complete(Result.success(_foto(40, 3)));
      await _esperar();
      await _esperar();
      expect(ordemDeEnvio, ['a.jpg', 'b.jpg']);
      expect(cubit.state.fila, hasLength(2));
      expect(cubit.state.lista, ListaFotos.carregada(_quatro));
      expect(cubit.state.mudou, isTrue);

      pendentes['b.jpg']!.complete(Result.success(_foto(50, 4)));
      await _esperar();
      await _esperar();
      pendentes['c.jpg']!.complete(Result.success(_foto(60, 5)));
      await _esperar();
      await _esperar();

      expect(ordemDeEnvio, ['a.jpg', 'b.jpg', 'c.jpg']);
      expect(cubit.state.fila, isEmpty);
      expect(cubit.state.haEnviosPendentes, isFalse);
      verify(() => listar(_imovel)).called(4); // 1 carga + 3 releituras
      await cubit.close();
    });

    test('o progresso do envio aparece no item da fila', () async {
      final fim = Completer<Result<FotoImovel>>();
      AoProgredirEnvio? progredir;
      when(
        () => enviar(_imovel, any(), aoProgredir: any(named: 'aoProgredir')),
      ).thenAnswer((invocacao) {
        progredir = invocacao.namedArguments[#aoProgredir] as AoProgredirEnvio?;
        return fim.future;
      });
      final cubit = await carregado();
      cubit.adicionar([_original('a.jpg')]);
      await _esperar();

      progredir!(0.4);
      expect(
        cubit.state.fila.single.estado,
        const EstadoEnvio.enviando(progresso: 0.4),
      );
      progredir!(null);
      expect(cubit.state.fila.single.estado, const EstadoEnvio.enviando());

      fim.complete(Result.success(_foto(40, 3)));
      await _esperar();
      await cubit.close();
    });

    test('a segunda falha com 400: mostra a mensagem do servidor e a terceira '
        'é enviada mesmo assim', () async {
      enviarResponde((preparada) async {
        if (preparada.caminho.endsWith('b.jpg')) {
          return const Result.failure(
            FotoRecusadaException('A imagem não pode passar de 5MB.'),
          );
        }
        return Result.success(_foto(40, 3));
      });
      final cubit = await carregado();

      cubit.adicionar([
        _original('a.jpg'),
        _original('b.jpg'),
        _original('c.jpg'),
      ]);
      for (var i = 0; i < 10; i++) {
        await _esperar();
      }

      final falha = cubit.state.fila.single;
      expect(falha.original, _original('b.jpg'));
      expect(
        falha.estado,
        const EstadoEnvio.falhou(
          mensagemDoServidor: 'A imagem não pode passar de 5MB.',
        ),
      );
      verify(
        () => enviar(
          _imovel,
          _preparada('c.jpg'),
          aoProgredir: any(named: 'aoProgredir'),
        ),
      ).called(1);
      expect(cubit.state.haEnviosPendentes, isFalse);
      await cubit.close();
    });

    test(
      '"Tentar de novo" reenvia o mesmo JPEG, sem preparar de novo',
      () async {
        var tentativas = 0;
        enviarResponde((_) async {
          tentativas++;
          return tentativas == 1
              ? const Result.failure(FalhaDeConexaoException())
              : Result.success(_foto(40, 3));
        });
        final cubit = await carregado();
        cubit.adicionar([_original('a.jpg')]);
        for (var i = 0; i < 5; i++) {
          await _esperar();
        }
        final falha = cubit.state.fila.single;
        expect(falha.estado, const EstadoEnvio.falhou());
        expect(falha.preparada, _preparada('a.jpg'));

        cubit.tentarDeNovoEnvio(falha.id);
        for (var i = 0; i < 5; i++) {
          await _esperar();
        }

        expect(cubit.state.fila, isEmpty);
        verify(() => preparar(_original('a.jpg'))).called(1);
        verify(
          () => enviar(
            _imovel,
            _preparada('a.jpg'),
            aoProgredir: any(named: 'aoProgredir'),
          ),
        ).called(2);
        await cubit.close();
      },
    );

    test(
      'falha genérica no envio relê a lista (o POST pode ter gravado)',
      () async {
        enviarResponde(
          (_) async => const Result.failure(FalhaDeConexaoException()),
        );
        final cubit = await carregado();
        cubit.adicionar([_original('a.jpg')]);
        for (var i = 0; i < 5; i++) {
          await _esperar();
        }

        verify(() => listar(_imovel)).called(2);
        await cubit.close();
      },
    );

    test('falha no preparo marca a foto e a fila segue; "Tentar de novo" '
        'prepara de novo', () async {
      var preparos = 0;
      when(() => preparar(_original('a.jpg'))).thenAnswer((_) async {
        preparos++;
        return preparos == 1
            ? const Result.failure(FalhaAoPrepararFotoException())
            : Result.success(_preparada('a.jpg'));
      });
      enviarResponde((_) async => Result.success(_foto(40, 3)));
      final cubit = await carregado();

      cubit.adicionar([_original('a.jpg'), _original('b.jpg')]);
      for (var i = 0; i < 8; i++) {
        await _esperar();
      }
      final falha = cubit.state.fila.single;
      expect(falha.estado, const EstadoEnvio.falhou(noPreparo: true));
      expect(falha.preparada, isNull);

      cubit.tentarDeNovoEnvio(falha.id);
      for (var i = 0; i < 8; i++) {
        await _esperar();
      }
      expect(cubit.state.fila, isEmpty);
      expect(preparos, 2);
      await cubit.close();
    });

    test('"Remover" tira a foto que falhou e apaga o JPEG preparado', () async {
      enviarResponde(
        (_) async => const Result.failure(
          FotoRecusadaException(
            'Este imóvel já tem 30 fotos, o máximo permitido.',
          ),
        ),
      );
      final cubit = await carregado();
      cubit.adicionar([_original('a.jpg')]);
      for (var i = 0; i < 5; i++) {
        await _esperar();
      }

      await cubit.remover(cubit.state.fila.single.id);

      expect(cubit.state.fila, isEmpty);
      verify(() => descartar(_preparada('a.jpg'))).called(1);
      await cubit.close();
    });

    test('remover não tira foto que ainda está enviando', () async {
      final fim = Completer<Result<FotoImovel>>();
      enviarResponde((_) => fim.future);
      final cubit = await carregado();
      cubit.adicionar([_original('a.jpg')]);
      await _esperar();

      await cubit.remover(cubit.state.fila.single.id);

      expect(cubit.state.fila, hasLength(1));
      fim.complete(Result.success(_foto(40, 3)));
      await _esperar();
      await cubit.close();
    });

    test(
      '401 no meio da fila: sessão expirada e nenhum envio novo começa',
      () async {
        enviarResponde(
          (_) async => const Result.failure(SessaoExpiradaException()),
        );
        final cubit = await carregado();

        cubit.adicionar([_original('a.jpg'), _original('b.jpg')]);
        for (var i = 0; i < 8; i++) {
          await _esperar();
        }

        expect(cubit.state.lista, const ListaFotos.sessaoExpirada());
        verify(
          () => enviar(_imovel, any(), aoProgredir: any(named: 'aoProgredir')),
        ).called(1);
        cubit.adicionar([_original('c.jpg')]);
        await _esperar();
        expect(
          cubit.state.fila,
          hasLength(2),
          reason: 'nada entra depois do 401',
        );
        await cubit.close();
      },
    );

    test('404 no envio: imóvel fora do acervo e a fila para', () async {
      enviarResponde(
        (_) async => const Result.failure(ImovelNaoEncontradoException()),
      );
      final cubit = await carregado();

      cubit.adicionar([_original('a.jpg'), _original('b.jpg')]);
      for (var i = 0; i < 8; i++) {
        await _esperar();
      }

      expect(cubit.state.lista, const ListaFotos.naoEncontrado());
      verify(
        () => enviar(_imovel, any(), aoProgredir: any(named: 'aoProgredir')),
      ).called(1);
      await cubit.close();
    });

    test(
      'fechar a tela apaga os JPEGs preparados que ficaram na fila',
      () async {
        enviarResponde(
          (_) async => const Result.failure(FalhaDeConexaoException()),
        );
        final cubit = await carregado();
        cubit.adicionar([_original('a.jpg')]);
        for (var i = 0; i < 5; i++) {
          await _esperar();
        }

        await cubit.close();

        verify(() => descartar(_preparada('a.jpg'))).called(1);
      },
    );
  });

  group('câmera e galeria', () {
    test('cancelar a câmera não faz nada', () async {
      when(() => tirar()).thenAnswer((_) async => const Result.success(null));
      final cubit = await carregado();

      await cubit.tirarFoto();

      expect(cubit.state.fila, isEmpty);
      expect(cubit.state.falhasAoEscolher, 0);
      await cubit.close();
    });

    test('a foto da câmera entra na fila', () async {
      final fim = Completer<Result<FotoImovel>>();
      enviarResponde((_) => fim.future);
      when(() => tirar())
          .thenAnswer((_) async => Result.success(_original('camera.jpg')));
      final cubit = await carregado();

      await cubit.tirarFoto();

      expect(cubit.state.fila.single.original, _original('camera.jpg'));
      fim.complete(Result.success(_foto(40, 3)));
      await _esperar();
      await cubit.close();
    });

    test('câmera ou galeria que não abre soma uma falha (SnackBar)', () async {
      when(() => tirar()).thenAnswer(
        (_) async => const Result.failure(FalhaAoEscolherFotoException()),
      );
      when(() => galeria()).thenAnswer(
        (_) async => const Result.failure(FalhaAoEscolherFotoException()),
      );
      final cubit = await carregado();

      await cubit.tirarFoto();
      await cubit.escolherDaGaleria();

      expect(cubit.state.falhasAoEscolher, 2);
      expect(cubit.state.fila, isEmpty);
      await cubit.close();
    });

    test('a galeria põe todas as escolhidas na fila, na ordem', () async {
      final fim = Completer<Result<FotoImovel>>();
      enviarResponde((_) => fim.future);
      when(() => galeria()).thenAnswer(
        (_) async => Result.success([_original('1.jpg'), _original('2.jpg')]),
      );
      final cubit = await carregado();

      await cubit.escolherDaGaleria();

      expect(
        [for (final envio in cubit.state.fila) envio.original],
        [_original('1.jpg'), _original('2.jpg')],
      );
      await cubit.close();
    });
  });

  group('ordem, capa e exclusão: o servidor decide (D-20 a D-22)', () {
    test('reordenar não move nada antes da resposta e depois mostra a lista '
        'devolvida', () async {
      final resposta = Completer<Result<List<FotoImovel>>>();
      final devolvida = [_foto(30, 0), _foto(10, 1, capa: true), _foto(20, 2)];
      when(() => reordenar(_imovel, [30, 10, 20]))
          .thenAnswer((_) => resposta.future);
      final cubit = await carregado();

      final pedido = cubit.reordenar(2, 0);
      await _esperar();

      expect(cubit.state.operacao, const OperacaoFotos.reordenando());
      expect(
        cubit.state.lista,
        ListaFotos.carregada(_tres),
        reason: 'sem mudança local',
      );
      expect(cubit.state.podeAlterarFotos, isFalse);

      resposta.complete(Result.success(devolvida));
      await pedido;

      expect(cubit.state.lista, ListaFotos.carregada(devolvida));
      expect(cubit.state.operacao, const OperacaoFotos.nenhuma());
      expect(cubit.state.mudou, isTrue);
      await cubit.close();
    });

    test('soltar no mesmo lugar não chama o servidor', () async {
      final cubit = await carregado();

      await cubit.reordenar(1, 2);

      verifyNever(() => reordenar(any(), any()));
      await cubit.close();
    });

    test(
      'reordenar, capa e apagar são ignorados com envio em andamento',
      () async {
        final fim = Completer<Result<FotoImovel>>();
        enviarResponde((_) => fim.future);
        final cubit = await carregado();
        cubit.adicionar([_original('a.jpg')]);
        await _esperar();

        await cubit.reordenar(2, 0);
        await cubit.definirCapa(20);
        await cubit.apagar(20);

        verifyNever(() => reordenar(any(), any()));
        verifyNever(() => capa(any(), any()));
        verifyNever(() => apagar(any(), any()));
        fim.complete(Result.success(_foto(40, 3)));
        await _esperar();
        await cubit.close();
      },
    );

    test(
      'uma operação por vez: capa durante a reordenação é ignorada',
      () async {
        final resposta = Completer<Result<List<FotoImovel>>>();
        when(() => reordenar(_imovel, any()))
            .thenAnswer((_) => resposta.future);
        final cubit = await carregado();

        final pedido = cubit.reordenar(2, 0);
        await _esperar();
        await cubit.definirCapa(20);

        verifyNever(() => capa(any(), any()));
        resposta.complete(Result.success(_tres));
        await pedido;
        await cubit.close();
      },
    );

    test('definir capa mostra a lista devolvida', () async {
      final devolvida = [_foto(10, 0), _foto(20, 1, capa: true), _foto(30, 2)];
      when(() => capa(_imovel, 20))
          .thenAnswer((_) async => Result.success(devolvida));
      final cubit = await carregado();

      await cubit.definirCapa(20);

      expect(cubit.state.lista, ListaFotos.carregada(devolvida));
      expect(cubit.state.mudou, isTrue);
      await cubit.close();
    });

    test('apagar mostra a lista devolvida e soma "Foto apagada."', () async {
      final devolvida = [_foto(20, 0, capa: true), _foto(30, 1)];
      when(() => apagar(_imovel, 10))
          .thenAnswer((_) async => Result.success(devolvida));
      final cubit = await carregado();

      await cubit.apagar(10);

      expect(cubit.state.lista, ListaFotos.carregada(devolvida));
      expect(cubit.state.fotosApagadas, 1);
      await cubit.close();
    });

    test(
      'recusa do servidor: soma a falha com a mensagem e relê a lista',
      () async {
        when(() => reordenar(_imovel, any())).thenAnswer(
          (_) async => const Result.failure(
            FotoRecusadaException(
              'Envie a lista completa das fotos deste imóvel, sem repetir.',
            ),
          ),
        );
        final cubit = await carregado();

        await cubit.reordenar(0, 3);

        expect(cubit.state.falhasDeOperacao, 1);
        expect(
          cubit.state.mensagemDaUltimaFalha,
          'Envie a lista completa das fotos deste imóvel, sem repetir.',
        );
        expect(cubit.state.operacao, const OperacaoFotos.nenhuma());
        verify(() => listar(_imovel)).called(2);
        await cubit.close();
      },
    );

    test(
      'falha de rede ao apagar: falha sem mensagem, nada apagado na tela',
      () async {
        when(() => apagar(_imovel, 10)).thenAnswer(
          (_) async => const Result.failure(FalhaDeConexaoException()),
        );
        final cubit = await carregado();

        await cubit.apagar(10);

        expect(cubit.state.falhasDeOperacao, 1);
        expect(cubit.state.mensagemDaUltimaFalha, isNull);
        expect(cubit.state.fotosApagadas, 0);
        expect(cubit.state.lista, ListaFotos.carregada(_tres));
        await cubit.close();
      },
    );

    test('401 numa operação: sessão expirada', () async {
      when(() => capa(_imovel, 20)).thenAnswer(
        (_) async => const Result.failure(SessaoExpiradaException()),
      );
      final cubit = await carregado();

      await cubit.definirCapa(20);

      expect(cubit.state.lista, const ListaFotos.sessaoExpirada());
      expect(cubit.state.operacao, const OperacaoFotos.nenhuma());
      await cubit.close();
    });

    test('404 numa operação: fora do acervo', () async {
      when(() => apagar(_imovel, 10)).thenAnswer(
        (_) async => const Result.failure(ImovelNaoEncontradoException()),
      );
      final cubit = await carregado();

      await cubit.apagar(10);

      expect(cubit.state.lista, const ListaFotos.naoEncontrado());
      await cubit.close();
    });
  });
}
