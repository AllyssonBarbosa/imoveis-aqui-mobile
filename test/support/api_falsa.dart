import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Base URL do servidor de captura das fixtures (os `next`/`previous` das
/// fixtures de lista são absolutos nesta origem — 05-06).
const String urlBaseApiFalsa = 'http://127.0.0.1:8000';

/// Lê e decodifica `test/fixtures/api/<nomeArquivo>` (JSON capturado da API
/// real — nunca escrito à mão).
Object? lerFixtureApi(String nomeArquivo) {
  final arquivo = File('test/fixtures/api/$nomeArquivo');
  return jsonDecode(arquivo.readAsStringSync());
}

class _Sobrescrita {
  const _Sobrescrita(this.quando, this.status, this.fixture, this.corpo);

  final bool Function(Uri uri) quando;
  final int status;
  final String? fixture;
  final Object? corpo;
}

/// API pública falsa: um [Dio] sobre um `HttpClientAdapter` de teste que serve
/// as fixtures de `test/fixtures/api/` por rota e grava as requisições. Sem
/// pacote novo. Rota ainda não servida responde 404 com um objeto JSON vazio.
class ApiFalsa {
  ApiFalsa({this.latencia = Duration.zero});

  /// Atraso aplicado antes de cada resposta (para testar estados de loading).
  final Duration latencia;

  final List<Uri> _requisicoes = [];
  final List<_Sobrescrita> _sobrescritas = [];

  /// Todas as URIs requisitadas, na ordem.
  List<Uri> get requisicoes => List.unmodifiable(_requisicoes);

  /// Registra uma resposta que vale para as URIs em que [quando] é verdadeiro.
  /// Vale a última registrada. [fixture] é o nome do arquivo em
  /// `test/fixtures/api/`; [corpo] serve um valor JSON derivado de uma
  /// fixture (ex.: uma cópia com uma chave alterada para simular wire
  /// malformado). Sem nenhum dos dois o corpo é um objeto JSON vazio.
  void responder(
    bool Function(Uri uri) quando, {
    required int status,
    String? fixture,
    Object? corpo,
  }) {
    _sobrescritas.add(_Sobrescrita(quando, status, fixture, corpo));
  }

  Dio criarDio() {
    final dio = Dio(BaseOptions(baseUrl: urlBaseApiFalsa));
    dio.httpClientAdapter = _AdaptadorApiFalsa(this);
    return dio;
  }

  Future<ResponseBody> _atender(Uri uri) async {
    _requisicoes.add(uri);
    if (latencia > Duration.zero) await Future<void>.delayed(latencia);

    for (final sobrescrita in _sobrescritas.reversed) {
      if (sobrescrita.quando(uri)) {
        return _corpoJson(
          sobrescrita.fixture != null
              ? lerFixtureApi(sobrescrita.fixture!)
              : sobrescrita.corpo ?? const <String, Object?>{},
          sobrescrita.status,
        );
      }
    }

    if (uri.path == '/api/publico/cidades/') {
      return _corpoJson(lerFixtureApi('cidades.json'), 200);
    }
    return _corpoJson(const <String, Object?>{}, 404);
  }

  ResponseBody _corpoJson(Object? corpo, int status) {
    return ResponseBody.fromString(
      jsonEncode(corpo),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _AdaptadorApiFalsa implements HttpClientAdapter {
  _AdaptadorApiFalsa(this._api);

  final ApiFalsa _api;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _api._atender(options.uri);
  }

  @override
  void close({bool force = false}) {}
}
