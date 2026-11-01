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

class _Falha {
  _Falha(this.caminho, this.status, this.restantes);

  final String caminho;
  final int status;
  int restantes;
}

/// API pública falsa: um [Dio] sobre um `HttpClientAdapter` de teste que serve
/// as fixtures de `test/fixtures/api/` por rota e grava as requisições. Sem
/// pacote novo. Rotas: cidades e `/api/publico/cidades/<id>/imoveis/` (página
/// 2 com `page=2`; só Campinas tem imóveis capturados, as outras cidades
/// recebem a lista vazia). Rota ainda não servida responde 404 com um objeto JSON vazio.
class ApiFalsa {
  ApiFalsa({this.latencia = Duration.zero});

  /// Atraso aplicado antes de cada resposta (para testar estados de loading).
  final Duration latencia;

  final List<Uri> _requisicoes = [];
  final List<_Sobrescrita> _sobrescritas = [];
  final List<_Falha> _falhas = [];

  /// Todas as URIs requisitadas, na ordem.
  List<Uri> get requisicoes => List.unmodifiable(_requisicoes);

  /// Última requisição à lista de imóveis de uma cidade
  /// (`/api/publico/cidades/<id>/imoveis/`), ou nulo se ainda não houve.
  Uri? get ultimaRequisicaoDaLista {
    for (final uri in _requisicoes.reversed) {
      if (_idDaListaDeImoveis(uri.path) != null) return uri;
    }
    return null;
  }

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

  /// As próximas [vezes] requisições cujo caminho começa com [caminho]
  /// respondem [status] com um objeto JSON vazio no corpo; depois disso a rota
  /// volta a responder normalmente.
  void falharProximas(String caminho, {int status = 500, int vezes = 1}) {
    _falhas.add(_Falha(caminho, status, vezes));
  }

  Dio criarDio() {
    final dio = Dio(BaseOptions(baseUrl: urlBaseApiFalsa));
    dio.httpClientAdapter = _AdaptadorApiFalsa(this);
    return dio;
  }

  Future<ResponseBody> _atender(Uri uri) async {
    _requisicoes.add(uri);
    if (latencia > Duration.zero) await Future<void>.delayed(latencia);

    for (final falha in _falhas) {
      if (falha.restantes > 0 && uri.path.startsWith(falha.caminho)) {
        falha.restantes--;
        return _corpoJson(const <String, Object?>{}, falha.status);
      }
    }

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
    final cidadeDaLista = _idDaListaDeImoveis(uri.path);
    if (cidadeDaLista != null) {
      final String fixture;
      if (cidadeDaLista != _idDeCampinas()) {
        fixture = 'lista_campinas_vazia.json';
      } else if (uri.queryParameters['page'] == '2') {
        fixture = 'lista_campinas_p2.json';
      } else {
        fixture = 'lista_campinas_p1.json';
      }
      return _corpoJson(lerFixtureApi(fixture), 200);
    }
    return _corpoJson(const <String, Object?>{}, 404);
  }

  /// Id da cidade de `/api/publico/cidades/<id>/imoveis/`, ou nulo se [caminho]
  /// não é essa rota.
  int? _idDaListaDeImoveis(String caminho) {
    final casamento = RegExp(
      r'^/api/publico/cidades/(\d+)/imoveis/$',
    ).firstMatch(caminho);
    if (casamento == null) return null;
    return int.parse(casamento.group(1)!);
  }

  /// Id de Campinas lido de `cidades.json` (as listas capturadas são dela).
  int _idDeCampinas() {
    final cidades = lerFixtureApi('cidades.json')! as List<Object?>;
    final campinas = cidades.cast<Map<String, Object?>>().firstWhere(
      (cidade) => cidade['nome'] == 'Campinas',
    );
    return campinas['id']! as int;
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
