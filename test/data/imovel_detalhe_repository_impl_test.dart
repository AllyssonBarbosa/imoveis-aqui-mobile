import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
import 'package:imoveis_aqui/data/repositories/imovel_detalhe_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:mocktail/mocktail.dart';

class _ImovelDetalheDataSourceFalso extends Mock
    implements ImovelDetalheDataSource {}

/// `HttpClientAdapter` de teste (mesma técnica de
/// `cidade_remote_datasource_test.dart`, sem pacote novo): responde com um
/// status e um corpo fixos.
class _HttpClientAdapterFalso implements HttpClientAdapter {
  _HttpClientAdapterFalso({required this.status, required this.corpo});

  final int status;
  final Object? corpo;
  final List<String> uris = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    uris.add(options.uri.toString());
    return ResponseBody.fromString(
      jsonEncode(corpo),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// DataSource só de teste que imita o que a DataSource remota da Fase 5
/// fará: `dio.get` + `fromJson`, deixando a `DioException` e o `TypeError`
/// subirem sem tratamento.
class _DataSourceDioDeTeste implements ImovelDetalheDataSource {
  _DataSourceDioDeTeste(this._dio);

  final Dio _dio;

  @override
  Future<DetalheImovelModel> buscarDetalhe(int id) async {
    final resposta = await _dio.get<Map<String, Object?>>(
      caminhoDetalheImovelPublico(id),
    );
    return DetalheImovelModel.fromJson(resposta.data!);
  }
}

void main() {
  late _ImovelDetalheDataSourceFalso dataSource;
  late ImovelDetalheRepositoryImpl repositorio;

  DetalheImovelModel modeloDe42() =>
      DetalheImovelModel.fromJson(detalhesAcervoFixture()[42]!);

  DioException dioException(int? status) {
    final opcoes = RequestOptions(path: caminhoDetalheImovelPublico(339));
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
      when(() => dataSource.buscarDetalhe(42))
          .thenAnswer((_) async => modeloDe42());

      final resultado = await repositorio.buscarDetalhe(42);

      expect(resultado, isA<Success<DetalheImovel>>());
      final detalhe = (resultado as Success<DetalheImovel>).data;
      expect(detalhe.id, 42);
      expect(detalhe.titulo, 'Apartamento 2 quartos no Cambuí');
      verify(() => dataSource.buscarDetalhe(42)).called(1);
    });

    test('ImovelNaoEncontradoException do mock vira Failure com ela', () async {
      when(() => dataSource.buscarDetalhe(any()))
          .thenThrow(const ImovelNaoEncontradoException());

      final resultado = await repositorio.buscarDetalhe(999);

      expect(erroDe(resultado), isA<ImovelNaoEncontradoException>());
    });

    test(
      'DioException 404 vira Failure(ImovelNaoEncontradoException)',
      () async {
        when(() => dataSource.buscarDetalhe(any()))
            .thenThrow(dioException(404));

        final resultado = await repositorio.buscarDetalhe(999);

        expect(erroDe(resultado), isA<ImovelNaoEncontradoException>());
      },
    );

    test(
      'DioException 500 vira Failure carregando a própria DioException',
      () async {
        final erro = dioException(500);
        when(() => dataSource.buscarDetalhe(any())).thenThrow(erro);

        final resultado = await repositorio.buscarDetalhe(42);

        expect(erroDe(resultado), same(erro));
      },
    );

    test('DioException sem resposta (timeout) vira Failure com ela', () async {
      final erro = dioException(null);
      when(() => dataSource.buscarDetalhe(any())).thenThrow(erro);

      final resultado = await repositorio.buscarDetalhe(42);

      final falha = erroDe(resultado);
      expect(falha, same(erro));
      expect(falha, isNot(isA<ImovelNaoEncontradoException>()));
    });

    test('TypeError do parse vira Failure(FormatException)', () async {
      when(() => dataSource.buscarDetalhe(any()))
          .thenAnswer((_) async => throw TypeError());

      final resultado = await repositorio.buscarDetalhe(42);

      expect(erroDe(resultado), isA<FormatException>());
    });

    test('finalidade desconhecida (FormatException) vira Failure', () async {
      final mapa = Map<String, Object?>.of(detalhesAcervoFixture()[42]!)
        ..['finalidade'] = 'PERMUTA';
      when(() => dataSource.buscarDetalhe(any()))
          .thenAnswer((_) async => DetalheImovelModel.fromJson(mapa));

      final resultado = await repositorio.buscarDetalhe(42);

      expect(erroDe(resultado), isA<FormatException>());
    });

    test('FalhaSimuladaDoMock vira Failure com ela', () async {
      when(() => dataSource.buscarDetalhe(any()))
          .thenThrow(const FalhaSimuladaDoMock());

      final resultado = await repositorio.buscarDetalhe(42);

      expect(erroDe(resultado), isA<FalhaSimuladaDoMock>());
    });
  });

  group('cadeia Dio real com adaptador falso (A5)', () {
    ImovelDetalheRepositoryImpl repositorioComAdaptador(
      _HttpClientAdapterFalso adaptador,
    ) {
      final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'))
        ..httpClientAdapter = adaptador;
      return ImovelDetalheRepositoryImpl(_DataSourceDioDeTeste(dio));
    }

    test(
      '404 do servidor chega como Failure(ImovelNaoEncontradoException)',
      () async {
        final adaptador = _HttpClientAdapterFalso(
          status: 404,
          corpo: {'detail': 'Não encontrado.'},
        );

        final resultado = await repositorioComAdaptador(adaptador)
            .buscarDetalhe(339);

        expect(erroDe(resultado), isA<ImovelNaoEncontradoException>());
        expect(adaptador.uris, [
          'http://10.0.2.2:8000${caminhoDetalheImovelPublico(339)}',
        ]);
      },
    );

    test(
      '500 do servidor chega como Failure que não é "não encontrado"',
      () async {
        final adaptador = _HttpClientAdapterFalso(
          status: 500,
          corpo: {'detail': 'erro'},
        );

        final resultado = await repositorioComAdaptador(adaptador)
            .buscarDetalhe(339);

        final erro = erroDe(resultado);
        expect(erro, isA<DioException>());
        expect(erro, isNot(isA<ImovelNaoEncontradoException>()));
      },
    );

    test('200 com corpo válido chega como Success', () async {
      final adaptador = _HttpClientAdapterFalso(
        status: 200,
        corpo: {...detalhesAcervoFixture()[42]!, 'id': 339},
      );

      final resultado = await repositorioComAdaptador(adaptador)
          .buscarDetalhe(339);

      expect(resultado, isA<Success<DetalheImovel>>());
      expect((resultado as Success<DetalheImovel>).data.id, 339);
    });

    test('200 com JSON malformado (sem titulo) chega como Failure(FormatException)', () async {
      final corpo = Map<String, Object?>.of(detalhesAcervoFixture()[42]!)
        ..remove('titulo');
      final adaptador = _HttpClientAdapterFalso(status: 200, corpo: corpo);

      final resultado = await repositorioComAdaptador(adaptador)
          .buscarDetalhe(42);

      expect(erroDe(resultado), isA<FormatException>());
    });
  });
}
