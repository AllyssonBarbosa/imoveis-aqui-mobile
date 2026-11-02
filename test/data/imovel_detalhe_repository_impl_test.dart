import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_remote_datasource.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
import 'package:imoveis_aqui/data/repositories/imovel_detalhe_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

class _ImovelDetalheDataSourceFalso extends Mock
    implements ImovelDetalheDataSource {}

/// Os gatilhos de erro dos ids 338/339 do servidor simulado (D-17) viraram
/// testes com DataSource mockada (D-18, DET-06): 404 -> não encontrado, 500 ->
/// o erro do dio, TypeError -> FormatException.
void main() {
  late _ImovelDetalheDataSourceFalso dataSource;
  late ImovelDetalheRepositoryImpl repositorio;

  Map<String, Object?> casaCapturada() =>
      Map<String, Object?>.of(
        lerFixtureApi('detalhe_casa.json')! as Map<String, Object?>,
      );

  DetalheImovelModel modeloDaCasa() =>
      DetalheImovelModel.fromJson(casaCapturada());

  DioException dioException(int? status) {
    final opcoes = RequestOptions(path: caminhoDetalheImovelPublico(21));
    return DioException(
      requestOptions: opcoes,
      type: status == null
          ? DioExceptionType.connectionTimeout
          : DioExceptionType.badResponse,
      response: status == null
          ? null
          : Response<Object?>(requestOptions: opcoes, statusCode: status),
    );
  }

  setUp(() {
    dataSource = _ImovelDetalheDataSourceFalso();
    repositorio = ImovelDetalheRepositoryImpl(dataSource);
  });

  Exception erroDe(Result<DetalheImovel> resultado) {
    expect(resultado, isA<Failure<DetalheImovel>>());
    return (resultado as Failure<DetalheImovel>).erro;
  }

  group('buscarDetalhe', () {
    test('modelo do datasource vira Success com a entidade mapeada', () async {
      when(
        () => dataSource.buscarDetalhe(21),
      ).thenAnswer((_) async => modeloDaCasa());

      final resultado = await repositorio.buscarDetalhe(21);

      expect(resultado, isA<Success<DetalheImovel>>());
      final detalhe = (resultado as Success<DetalheImovel>).data;
      expect(detalhe.id, 21);
      expect(detalhe.titulo, casaCapturada()['titulo']);
      expect(detalhe.corretor?.nome, 'Corretor Vitrine Demo');
      verify(() => dataSource.buscarDetalhe(21)).called(1);
    });

    test(
      'DioException 404 vira Failure(ImovelNaoEncontradoException)',
      () async {
        when(
          () => dataSource.buscarDetalhe(any()),
        ).thenThrow(dioException(404));

        final resultado = await repositorio.buscarDetalhe(999);

        expect(erroDe(resultado), isA<ImovelNaoEncontradoException>());
      },
    );

    test(
      'DioException 500 vira Failure carregando a própria DioException',
      () async {
        final erro = dioException(500);
        when(() => dataSource.buscarDetalhe(any())).thenThrow(erro);

        final resultado = await repositorio.buscarDetalhe(21);

        expect(erroDe(resultado), same(erro));
        expect(erroDe(resultado), isNot(isA<ImovelNaoEncontradoException>()));
      },
    );

    test('DioException sem resposta (timeout) vira Failure com ela', () async {
      final erro = dioException(null);
      when(() => dataSource.buscarDetalhe(any())).thenThrow(erro);

      final resultado = await repositorio.buscarDetalhe(21);

      final falha = erroDe(resultado);
      expect(falha, same(erro));
      expect(falha, isNot(isA<ImovelNaoEncontradoException>()));
    });

    test('TypeError do parse vira Failure(FormatException)', () async {
      when(
        () => dataSource.buscarDetalhe(any()),
      ).thenAnswer((_) async => throw TypeError());

      final resultado = await repositorio.buscarDetalhe(21);

      expect(erroDe(resultado), isA<FormatException>());
    });

    test('finalidade desconhecida (FormatException) vira Failure', () async {
      final mapa = casaCapturada()..['finalidade'] = 'PERMUTA';
      when(
        () => dataSource.buscarDetalhe(any()),
      ).thenAnswer((_) async => DetalheImovelModel.fromJson(mapa));

      final resultado = await repositorio.buscarDetalhe(21);

      expect(erroDe(resultado), isA<FormatException>());
    });
  });

  group('cadeia real: ImovelDetalheRemoteDataSource sobre a ApiFalsa', () {
    late ApiFalsa apiFalsa;

    setUp(() {
      apiFalsa = ApiFalsa();
      repositorio = ImovelDetalheRepositoryImpl(
        ImovelDetalheRemoteDataSource(apiFalsa.criarDio()),
      );
    });

    test('200 do JSON capturado chega como Success', () async {
      final resultado = await repositorio.buscarDetalhe(21);

      expect(resultado, isA<Success<DetalheImovel>>());
      expect((resultado as Success<DetalheImovel>).data.id, 21);
      expect(apiFalsa.requisicoes.single.path, '/api/publico/imoveis/21/');
    });

    test('id sem detalhe capturado: 404 vira ImovelNaoEncontrado', () async {
      final resultado = await repositorio.buscarDetalhe(99999);

      expect(erroDe(resultado), isA<ImovelNaoEncontradoException>());
    });

    test('500 do servidor chega como Failure(DioException)', () async {
      apiFalsa.falharProximas('/api/publico/imoveis/');

      final resultado = await repositorio.buscarDetalhe(21);

      final erro = erroDe(resultado);
      expect(erro, isA<DioException>());
      expect(erro, isNot(isA<ImovelNaoEncontradoException>()));
    });

    test('200 com JSON malformado chega como Failure(FormatException)', () async {
      final corpo = casaCapturada()..remove('titulo');
      apiFalsa.responder(
        (uri) => uri.path == '/api/publico/imoveis/21/',
        status: 200,
        corpo: corpo,
      );

      final resultado = await repositorio.buscarDetalhe(21);

      expect(erroDe(resultado), isA<FormatException>());
    });

    test(
      '200 com foto sem ordem (cópia da captura) chega como '
      'Failure(FormatException)',
      () async {
        final corpo = casaCapturada();
        final fotos = (corpo['fotos']! as List<Object?>)
            .cast<Map<String, Object?>>();
        corpo['fotos'] = [
          Map<String, Object?>.of(fotos.first)..remove('ordem'),
          ...fotos.skip(1),
        ];
        apiFalsa.responder(
          (uri) => uri.path == '/api/publico/imoveis/21/',
          status: 200,
          corpo: corpo,
        );

        final resultado = await repositorio.buscarDetalhe(21);

        expect(erroDe(resultado), isA<FormatException>());
      },
    );

    test('200 com endereco sem logradouro, número e CEP ainda é Success', () async {
      final corpo = casaCapturada();
      corpo['endereco'] = {
        ...(corpo['endereco']! as Map<String, Object?>),
        'logradouro': null,
        'numero': null,
        'cep': null,
      };
      apiFalsa.responder(
        (uri) => uri.path == '/api/publico/imoveis/21/',
        status: 200,
        corpo: corpo,
      );

      final resultado = await repositorio.buscarDetalhe(21);

      expect(resultado, isA<Success<DetalheImovel>>());
      expect((resultado as Success<DetalheImovel>).data.cidade?.nome, 'Campinas');
    });

    test('200 com corpo que não é objeto chega como FormatException', () async {
      apiFalsa.responder(
        (uri) => uri.path == '/api/publico/imoveis/21/',
        status: 200,
        corpo: <Object?>[],
      );

      final resultado = await repositorio.buscarDetalhe(21);

      expect(erroDe(resultado), isA<FormatException>());
    });
  });
}
