import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/perfil_remote_datasource.dart';
import 'package:imoveis_aqui/data/mocks/perfis_fixture.dart';
import 'package:imoveis_aqui/data/repositories/perfil_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/perfil_corretor.dart';
import 'package:imoveis_aqui/domain/repositories/perfil_repository.dart';

const _baseUrl = 'http://10.0.2.2:8000';

const _caminhoExemploCorretor =
    '.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/'
    'contrato/perfil_corretor.example.json';

/// Resposta fake pronta para um dado URI — status HTTP + corpo (mapa/lista que
/// vira JSON).
class _RespostaFalsa {
  const _RespostaFalsa({required this.status, required this.corpo});

  final int status;
  final Object? corpo;
}

/// `HttpClientAdapter` de teste (mesma técnica de
/// `cidade_remote_datasource_test.dart`, sem pacote novo): resolve cada URI
/// por um callback e registra todas as URIs pedidas.
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
    return ResponseBody.fromString(
      jsonEncode(resposta.corpo),
      resposta.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

({Dio dio, _HttpClientAdapterFalso adaptador}) _criarDio(
  _RespostaFalsa Function(String uri) resolver,
) {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final adaptador = _HttpClientAdapterFalso(resolver);
  dio.httpClientAdapter = adaptador;
  return (dio: dio, adaptador: adaptador);
}

Exception? _falhaDe(Result<PerfilCorretor> resultado) => switch (resultado) {
  Failure<PerfilCorretor>(:final erro) => erro,
  _ => null,
};

void main() {
  late Map<String, Object?> exemploCorretor;

  setUpAll(() {
    exemploCorretor =
        jsonDecode(File(_caminhoExemploCorretor).readAsStringSync())
            as Map<String, Object?>;
  });

  test('buscarCorretor(7) chama a URL exata e devolve o model da Marina', () async {
    final (:dio, :adaptador) = _criarDio(
      (_) => _RespostaFalsa(status: 200, corpo: exemploCorretor),
    );
    final remota = PerfilRemoteDataSource(dio);

    final modelo = await remota.buscarCorretor(7);

    expect(adaptador.uris, ['$_baseUrl/api/publico/corretores/7/']);
    expect(modelo.id, 7);
    expect(modelo.nome, 'Marina Lopes');
    expect(modelo.empresaId, 3);
  });

  group('pela pilha PerfilRepositoryImpl(PerfilRemoteDataSource(dio))', () {
    PerfilRepository pilha(_RespostaFalsa resposta) {
      final (:dio, adaptador: _) = _criarDio((_) => resposta);
      return PerfilRepositoryImpl(PerfilRemoteDataSource(dio));
    }

    test('200 válido vira Success com a entidade', () async {
      final repositorio = pilha(
        _RespostaFalsa(status: 200, corpo: exemploCorretor),
      );

      final resultado = await repositorio.buscarCorretor(7);

      expect(resultado, isA<Success<PerfilCorretor>>());
      expect((resultado as Success<PerfilCorretor>).data.nome, 'Marina Lopes');
    });

    test('404 vira PerfilNaoEncontradoException', () async {
      final repositorio = pilha(
        const _RespostaFalsa(status: 404, corpo: {'detail': 'Não encontrado.'}),
      );

      final resultado = await repositorio.buscarCorretor(7);

      expect(_falhaDe(resultado), isA<PerfilNaoEncontradoException>());
    });

    test('500 vira DioException', () async {
      final repositorio = pilha(
        const _RespostaFalsa(status: 500, corpo: {'detail': 'erro'}),
      );

      final resultado = await repositorio.buscarCorretor(7);

      expect(_falhaDe(resultado), isA<DioException>());
    });

    test('corpo que é uma lista JSON vira FormatException', () async {
      final repositorio = pilha(
        const _RespostaFalsa(status: 200, corpo: <Object?>[]),
      );

      final resultado = await repositorio.buscarCorretor(7);

      expect(_falhaDe(resultado), isA<FormatException>());
    });

    test('corpo sem nome vira FormatException', () async {
      final semNome = {...exemploCorretor}..remove('nome');
      final repositorio = pilha(_RespostaFalsa(status: 200, corpo: semNome));

      final resultado = await repositorio.buscarCorretor(7);

      expect(_falhaDe(resultado), isA<FormatException>());
    });
  });

  test('duas buscas simultâneas resolvem cada uma com o próprio corpo', () async {
    final fixture = corretoresPerfisFixture();
    final (:dio, :adaptador) = _criarDio((uri) {
      final id = int.parse(Uri.parse(uri).pathSegments[3]);
      return _RespostaFalsa(status: 200, corpo: fixture[id]);
    });
    final repositorio = PerfilRepositoryImpl(PerfilRemoteDataSource(dio));

    final resultados = await Future.wait([
      repositorio.buscarCorretor(7),
      repositorio.buscarCorretor(9),
    ]);

    expect((resultados[0] as Success<PerfilCorretor>).data.nome, 'Marina Lopes');
    expect(
      (resultados[1] as Success<PerfilCorretor>).data.nome,
      'Camila Duarte',
    );
    expect(
      adaptador.uris,
      unorderedEquals([
        '$_baseUrl/api/publico/corretores/7/',
        '$_baseUrl/api/publico/corretores/9/',
      ]),
    );
  });
}
