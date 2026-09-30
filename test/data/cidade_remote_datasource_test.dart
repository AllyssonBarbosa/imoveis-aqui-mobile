import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/cidade_prefs_datasource.dart';
import 'package:imoveis_aqui/data/datasources/cidade_remote_datasource.dart';
import 'package:imoveis_aqui/data/repositories/cidade_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:mocktail/mocktail.dart';

const _baseUrl = 'http://10.0.2.2:8000';

/// Resposta fake pronta para um dado URI — status HTTP + corpo (mapa/lista
/// que vira JSON, ou `String` já pronta para simular corpo não-JSON).
class _RespostaFalsa {
  const _RespostaFalsa({required this.status, required this.corpo});

  final int status;
  final Object? corpo;
}

/// `HttpClientAdapter` de teste (RESEARCH — "hand-written fake
/// HttpClientAdapter", sem pacote novo): resolve cada URI requisitada via um
/// callback, registrando todas as URIs pedidas para provar quantas
/// requisições de fato saíram (guarda de paginação/origem).
class _HttpClientAdapterFalso implements HttpClientAdapter {
  _HttpClientAdapterFalso(this._resolver);

  final _RespostaFalsa Function(String uri) _resolver;
  final List<String> uris = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final uri = options.uri.toString();
    uris.add(uri);
    final resposta = _resolver(uri);
    final corpoTexto = resposta.corpo is String
        ? resposta.corpo as String
        : jsonEncode(resposta.corpo);
    return ResponseBody.fromString(
      corpoTexto,
      resposta.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CidadePrefsDataSourceFalso extends Mock
    implements CidadePrefsDataSource {}

Dio _criarDio(
  _RespostaFalsa Function(String uri) resolver, {
  String baseUrl = _baseUrl,
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.httpClientAdapter = _HttpClientAdapterFalso(resolver);
  return dio;
}

Dio _criarDioComRespostas(
  Map<String, _RespostaFalsa> respostas, {
  String baseUrl = _baseUrl,
}) {
  return _criarDio((uri) {
    final resposta = respostas[uri];
    if (resposta == null) {
      throw StateError('Nenhuma resposta configurada para $uri');
    }
    return resposta;
  }, baseUrl: baseUrl);
}

void main() {
  group('CidadeRemoteDataSource', () {
    test(
      'uma página (next null) com 4 linhas válidas -> 4 CidadeModel na ordem, '
      'requisição única para baseUrl + /api/publico/cidades/',
      () async {
        final dio = _criarDioComRespostas({
          '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
            status: 200,
            corpo: {
              'next': null,
              'previous': null,
              'results': [
                {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
                {'id': 2, 'nome': 'Valinhos', 'uf': 'SP'},
                {'id': 3, 'nome': 'Vinhedo', 'uf': 'SP'},
                {'id': 4, 'nome': 'Indaiatuba', 'uf': 'SP'},
              ],
            },
          ),
        });
        final adapter = dio.httpClientAdapter as _HttpClientAdapterFalso;
        final datasource = CidadeRemoteDataSource(dio);

        final cidades = await datasource.obterCidades();

        expect(cidades.map((c) => c.nome), [
          'Campinas',
          'Valinhos',
          'Vinhedo',
          'Indaiatuba',
        ]);
        expect(adapter.uris, ['$_baseUrl/api/publico/cidades/']);
      },
    );

    test(
      'duas páginas: URI da segunda requisição é exatamente o next absoluto '
      'da primeira; resultados concatenados na ordem',
      () async {
        const proximaUrl = '$_baseUrl/api/publico/cidades/?cursor=abc';
        final dio = _criarDioComRespostas({
          '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
            status: 200,
            corpo: {
              'next': proximaUrl,
              'previous': null,
              'results': [
                {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
              ],
            },
          ),
          proximaUrl: const _RespostaFalsa(
            status: 200,
            corpo: {
              'next': null,
              'previous': '$_baseUrl/api/publico/cidades/',
              'results': [
                {'id': 2, 'nome': 'Valinhos', 'uf': 'SP'},
              ],
            },
          ),
        });
        final adapter = dio.httpClientAdapter as _HttpClientAdapterFalso;
        final datasource = CidadeRemoteDataSource(dio);

        final cidades = await datasource.obterCidades();

        expect(cidades.map((c) => c.nome), ['Campinas', 'Valinhos']);
        expect(adapter.uris, ['$_baseUrl/api/publico/cidades/', proximaUrl]);
      },
    );

    test(
      'linhas sem id/nome/uf válidos (ou nome/uf vazio) são descartadas; as '
      'válidas permanecem',
      () async {
        final dio = _criarDioComRespostas({
          '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
            status: 200,
            corpo: {
              'next': null,
              'previous': null,
              'results': [
                {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
                {'id': 2, 'nome': '', 'uf': 'SP'},
                {'nome': 'SemId', 'uf': 'SP'},
                {'id': 4, 'nome': 'Valinhos', 'uf': ''},
                {'id': 5, 'nome': 'Vinhedo'},
              ],
            },
          ),
        });
        final datasource = CidadeRemoteDataSource(dio);

        final cidades = await datasource.obterCidades();

        expect(cidades.map((c) => c.nome), ['Campinas']);
      },
    );

    test(
      'next com origem (scheme/host/port) diferente da base URL -> '
      'FormatException, sem seguir para uma segunda requisição',
      () async {
        final dio = _criarDioComRespostas({
          '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
            status: 200,
            corpo: {
              'next': 'http://evil.example.com/api/publico/cidades/',
              'previous': null,
              'results': <Map<String, Object?>>[],
            },
          ),
        });
        final adapter = dio.httpClientAdapter as _HttpClientAdapterFalso;
        final datasource = CidadeRemoteDataSource(dio);

        await expectLater(
          datasource.obterCidades(),
          throwsA(isA<FormatException>()),
        );
        expect(adapter.uris, ['$_baseUrl/api/publico/cidades/']);
      },
    );

    test(
      'mais de 20 páginas -> FormatException, sem uma 21ª requisição',
      () async {
        var contador = 0;
        final dio = _criarDio((uri) {
          contador++;
          return _RespostaFalsa(
            status: 200,
            corpo: {
              'next': '$_baseUrl/api/publico/cidades/?cursor=$contador',
              'previous': null,
              'results': <Map<String, Object?>>[],
            },
          );
        });
        final datasource = CidadeRemoteDataSource(dio);

        await expectLater(
          datasource.obterCidades(),
          throwsA(isA<FormatException>()),
        );
        expect(contador, 20);
      },
    );

    test('HTTP 500 na página 1 -> exceção propaga (DioException)', () async {
      final dio = _criarDioComRespostas({
        '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
          status: 500,
          corpo: {'detail': 'erro interno'},
        ),
      });
      final datasource = CidadeRemoteDataSource(dio);

      await expectLater(
        datasource.obterCidades(),
        throwsA(isA<DioException>()),
      );
    });

    test('HTTP 500 na página 2 -> exceção propaga (DioException)', () async {
      const proximaUrl = '$_baseUrl/api/publico/cidades/?cursor=abc';
      final dio = _criarDioComRespostas({
        '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
          status: 200,
          corpo: {
            'next': proximaUrl,
            'previous': null,
            'results': [
              {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
            ],
          },
        ),
        proximaUrl: const _RespostaFalsa(
          status: 500,
          corpo: {'detail': 'erro interno'},
        ),
      });
      final datasource = CidadeRemoteDataSource(dio);

      await expectLater(
        datasource.obterCidades(),
        throwsA(isA<DioException>()),
      );
    });

    test(
      'corpo que não é um objeto JSON (ex.: lista na raiz) -> FormatException',
      () async {
        final dio = _criarDioComRespostas({
          '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
            status: 200,
            corpo: [1, 2, 3],
          ),
        });
        final datasource = CidadeRemoteDataSource(dio);

        await expectLater(
          datasource.obterCidades(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('"results" que não é uma lista -> FormatException', () async {
      final dio = _criarDioComRespostas({
        '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
          status: 200,
          corpo: {'next': null, 'previous': null, 'results': 'nao-e-lista'},
        ),
      });
      final datasource = CidadeRemoteDataSource(dio);

      await expectLater(
        datasource.obterCidades(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('CidadeRepositoryImpl (sobre CidadeRemoteDataSource)', () {
    late _CidadePrefsDataSourceFalso prefs;

    setUp(() {
      prefs = _CidadePrefsDataSourceFalso();
    });

    test(
      'sucesso do datasource remoto -> Result.success(List<Cidade>) mapeada',
      () async {
        final dio = _criarDioComRespostas({
          '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
            status: 200,
            corpo: {
              'next': null,
              'previous': null,
              'results': [
                {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
              ],
            },
          ),
        });
        final repositorio = CidadeRepositoryImpl(
          CidadeRemoteDataSource(dio),
          prefs,
        );

        final resultado = await repositorio.obterCidadesAtendidas();

        expect(resultado, isA<Success<List<Cidade>>>());
        final cidades = (resultado as Success<List<Cidade>>).data;
        expect(cidades.single, const Cidade(nome: 'Campinas', uf: 'SP'));
      },
    );

    test('HTTP 500 do datasource remoto -> Result.failure', () async {
      final dio = _criarDioComRespostas({
        '$_baseUrl/api/publico/cidades/': const _RespostaFalsa(
          status: 500,
          corpo: {'detail': 'erro interno'},
        ),
      });
      final repositorio = CidadeRepositoryImpl(
        CidadeRemoteDataSource(dio),
        prefs,
      );

      final resultado = await repositorio.obterCidadesAtendidas();

      expect(resultado, isA<Failure<List<Cidade>>>());
    });
  });
}
