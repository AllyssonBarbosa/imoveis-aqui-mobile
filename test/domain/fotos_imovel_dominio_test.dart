import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/foto_imovel.dart';
import 'package:imoveis_aqui/domain/gateways/preparador_de_foto_gateway.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/repositories/fotos_imovel_repository.dart';
import 'package:imoveis_aqui/domain/usecases/apagar_foto_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/definir_capa_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/descartar_foto_preparada_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/enviar_foto_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/listar_fotos_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/preparar_foto_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/reordenar_fotos_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _RepositorioFalso extends Mock implements FotosImovelRepository {}

class _PreparadorFalso extends Mock implements PreparadorDeFotoGateway {}

FotoImovel _foto(int id, int ordem, {bool capa = false}) => FotoImovel(
  id: id,
  url: 'http://api.test/media/imoveis/fotos/$id.jpg',
  ordem: ordem,
  capa: capa,
);

final _tres = [_foto(10, 0, capa: true), _foto(20, 1), _foto(30, 2)];

const _original = FotoEscolhida(caminho: '/cache/camera/original.jpg');
const _preparada = FotoEscolhida(caminho: '/cache/fotos/preparada.jpg');

void main() {
  setUpAll(() => registerFallbackValue(_preparada));

  group('idsNaOrdemPedida (posição final do onReorderItem, D-20)', () {
    test('subir: a terceira vai para o topo', () {
      expect(idsNaOrdemPedida(_tres, 2, 0), [30, 10, 20]);
    });

    test('descer: a primeira vai para o fim (destino = último índice)', () {
      expect(idsNaOrdemPedida(_tres, 0, 2), [20, 30, 10]);
    });

    test('descer uma posição', () {
      expect(idsNaOrdemPedida(_tres, 0, 1), [20, 10, 30]);
    });

    test('soltar no mesmo lugar não pede nada', () {
      expect(idsNaOrdemPedida(_tres, 1, 1), isNull);
    });

    test('índice fora da lista não pede nada', () {
      expect(idsNaOrdemPedida(_tres, 3, 0), isNull);
      expect(idsNaOrdemPedida(_tres, -1, 0), isNull);
      expect(idsNaOrdemPedida(_tres, 0, 3), isNull);
      expect(idsNaOrdemPedida(const [], 0, 0), isNull);
    });

    test('não altera a lista do servidor e devolve lista imutável', () {
      final pedido = idsNaOrdemPedida(_tres, 2, 0)!;
      expect([for (final foto in _tres) foto.id], [10, 20, 30]);
      expect(() => pedido.add(40), throwsUnsupportedError);
    });
  });

  test('FotoRecusadaException não põe a mensagem do servidor no toString', () {
    const falha = FotoRecusadaException('A imagem não pode passar de 5MB.');
    expect(falha.mensagem, 'A imagem não pode passar de 5MB.');
    expect(falha.toString(), isNot(contains('5MB')));
  });

  group('use cases delegam sem lógica própria', () {
    late _RepositorioFalso repositorio;
    late _PreparadorFalso preparador;

    setUp(() {
      repositorio = _RepositorioFalso();
      preparador = _PreparadorFalso();
    });

    test(
      'listar, reordenar, capa e apagar devolvem o Result do repositório',
      () async {
        final lista = Result<List<FotoImovel>>.success(_tres);
        when(() => repositorio.listar(7)).thenAnswer((_) async => lista);
        when(() => repositorio.reordenar(7, [30, 10, 20]))
            .thenAnswer((_) async => lista);
        when(() => repositorio.definirCapa(7, 20))
            .thenAnswer((_) async => lista);
        when(() => repositorio.apagar(7, 30)).thenAnswer((_) async => lista);

        expect(await ListarFotosUseCase(repositorio)(7), same(lista));
        expect(
          await ReordenarFotosUseCase(repositorio)(7, [30, 10, 20]),
          same(lista),
        );
        expect(await DefinirCapaUseCase(repositorio)(7, 20), same(lista));
        expect(await ApagarFotoUseCase(repositorio)(7, 30), same(lista));
      },
    );

    test('preparar delega ao preparador', () async {
      const esperado = Result<FotoEscolhida>.success(_preparada);
      when(() => preparador.preparar(_original))
          .thenAnswer((_) async => esperado);

      expect(await PrepararFotoUseCase(preparador)(_original), same(esperado));
    });

    test(
      'enviar aceito descarta o JPEG temporário e repassa o progresso',
      () async {
        final criada = Result<FotoImovel>.success(_foto(40, 3));
        when(
          () => repositorio.enviar(
            7,
            _preparada,
            aoProgredir: any(named: 'aoProgredir'),
          ),
        ).thenAnswer((invocacao) async {
          final aoProgredir =
              invocacao.namedArguments[#aoProgredir] as AoProgredirEnvio?;
          aoProgredir?.call(0.5);
          aoProgredir?.call(1);
          return criada;
        });
        when(() => preparador.descartar(_preparada)).thenAnswer((_) async {});

        final progresso = <double?>[];
        final resultado = await EnviarFotoUseCase(repositorio, preparador)(
          7,
          _preparada,
          aoProgredir: progresso.add,
        );

        expect(resultado, same(criada));
        expect(progresso, [0.5, 1]);
        verify(() => preparador.descartar(_preparada)).called(1);
      },
    );

    test('enviar recusado mantém o JPEG para o "Tentar de novo"', () async {
      const recusa = Result<FotoImovel>.failure(
        FotoRecusadaException(
          'Este imóvel já tem 30 fotos, o máximo permitido.',
        ),
      );
      when(
        () => repositorio.enviar(
          7,
          _preparada,
          aoProgredir: any(named: 'aoProgredir'),
        ),
      ).thenAnswer((_) async => recusa);

      final resultado = await EnviarFotoUseCase(repositorio, preparador)(
        7,
        _preparada,
      );

      expect(resultado, same(recusa));
      verifyNever(() => preparador.descartar(any()));
    });

    test('enviar com sessão expirada também mantém o arquivo', () async {
      const expirada = Result<FotoImovel>.failure(SessaoExpiradaException());
      when(
        () => repositorio.enviar(
          7,
          _preparada,
          aoProgredir: any(named: 'aoProgredir'),
        ),
      ).thenAnswer((_) async => expirada);

      await EnviarFotoUseCase(repositorio, preparador)(7, _preparada);

      verifyNever(() => preparador.descartar(any()));
    });

    test('descartar delega ao preparador', () async {
      when(() => preparador.descartar(_preparada)).thenAnswer((_) async {});

      await DescartarFotoPreparadaUseCase(preparador)(_preparada);

      verify(() => preparador.descartar(_preparada)).called(1);
    });
  });
}
