import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/cidade_model.dart';

/// Lê `GET /api/publico/cidades/` (VIT-06, D-16) — mesmo envelope cursor
/// `{next, previous, results}` do antigo asset local, agora a única fonte
/// da verdade. Segue o `next` como URL absoluta (RESEARCH Pattern 5 — nunca
/// reconstrói o cursor a partir de partes), parando em `next == null`.
///
/// Duas defesas de segurança (T-02-04-02): só segue um `next` cujo
/// scheme/host/port batam exatamente com a base URL configurada (nunca uma
/// requisição para outra origem), e nunca percorre mais de [maxPaginas]
/// páginas (nunca um loop infinito por um `next` malformado). Linhas sem
/// `id`/`nome`/`uf` válidos são descartadas silenciosamente, mesmo padrão
/// defensivo da antiga fonte local de cidades (removida nesta fase, D-16).
@lazySingleton
class CidadeRemoteDataSource {
  CidadeRemoteDataSource(this._dio);

  final Dio _dio;

  static const String caminhoCidades = '/api/publico/cidades/';
  static const int maxPaginas = 20;

  Future<List<CidadeModel>> obterCidades() async {
    final cidades = <CidadeModel>[];
    final baseUri = Uri.parse(_dio.options.baseUrl);
    String? proximaUrl = caminhoCidades;
    var paginas = 0;

    while (proximaUrl != null) {
      paginas++;
      if (paginas > maxPaginas) {
        throw const FormatException(
          'Paginação de GET /api/publico/cidades/ excedeu o limite de '
          '$maxPaginas páginas — possível "next" malformado.',
        );
      }

      final resposta = await _dio.get<Object?>(proximaUrl);
      final envelope = resposta.data;
      if (envelope is! Map<String, dynamic>) {
        throw const FormatException(
          'Corpo de GET /api/publico/cidades/ não é um objeto JSON.',
        );
      }

      final linhas = envelope['results'];
      if (linhas is! List) {
        throw const FormatException(
          'Campo "results" de GET /api/publico/cidades/ não é uma lista.',
        );
      }

      for (final linha in linhas) {
        if (linha is! Map<String, dynamic>) continue;
        final id = linha['id'];
        final nome = linha['nome'];
        final uf = linha['uf'];
        if (id is! int ||
            nome is! String ||
            nome.isEmpty ||
            uf is! String ||
            uf.isEmpty) {
          // Linha descartada: campo obrigatório ausente/vazio — nunca crash
          // (mesmo padrão defensivo da antiga fonte local removida, D-16).
          continue;
        }
        cidades.add(CidadeModel(id: id, nome: nome, uf: uf));
      }

      proximaUrl = _resolverProximaUrl(envelope['next'], baseUri);
    }

    return cidades;
  }

  /// Valida e retorna o próximo `next` a seguir, ou `null` se a paginação
  /// terminou. Lança [FormatException] se `next` não for `null`/`String`, ou
  /// se apontar para uma origem (scheme/host/port) diferente da base URL
  /// configurada (T-02-04-02 — nunca seguir um "next" estranho para outro
  /// host).
  String? _resolverProximaUrl(Object? next, Uri baseUri) {
    if (next == null) return null;
    if (next is! String) {
      throw const FormatException(
        'Campo "next" de GET /api/publico/cidades/ não é uma string nem '
        'null.',
      );
    }
    final proximoUri = Uri.parse(next);
    final mesmaOrigem =
        proximoUri.scheme == baseUri.scheme &&
        proximoUri.host == baseUri.host &&
        proximoUri.port == baseUri.port;
    if (!mesmaOrigem) {
      throw const FormatException(
        'Campo "next" de GET /api/publico/cidades/ aponta para uma origem '
        'diferente da base URL configurada.',
      );
    }
    return next;
  }
}
