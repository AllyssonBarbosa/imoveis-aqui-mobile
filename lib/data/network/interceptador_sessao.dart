import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/falhas_autenticacao.dart';
import '../datasources/armazenamento_token.dart';
import 'mesma_origem.dart';

/// Interceptor do `Dio` `@Named('autenticado')`: é o único lugar do app que
/// leva o token da API.
///
/// - **Origem única:** `Authorization: Token <chave>` só é anexado a pedidos
///   para a mesma origem da base URL; para qualquer outra origem (ou sem
///   token) qualquer `Authorization` é removido (T-08-07).
/// - **401 tipado:** todo 401 vira [DioException] com `error` =
///   [SessaoExpiradaException], para ninguém acima precisar de `try/catch`
///   genérico na UI.
/// - **Compare-and-delete:** o token usado no pedido fica em
///   `RequestOptions.extra['token_usado']`; no 401 só se apaga o token
///   guardado se ele ainda for o mesmo — um 401 atrasado de uma sessão antiga
///   não derruba o login novo (T-08-10).
///
/// Nunca loga nem imprime o token (T-08-09).
@injectable
class InterceptadorSessao extends Interceptor {
  InterceptadorSessao(this._armazenamento);

  /// Chave de `RequestOptions.extra` com o token que o pedido levou.
  static const chaveTokenUsado = 'token_usado';

  final ArmazenamentoToken _armazenamento;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.remove('Authorization');
    if (mesmaOrigem(options.uri, Uri.parse(options.baseUrl))) {
      final token = await _armazenamento.ler();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Token $token';
        options.extra[chaveTokenUsado] = token;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final tokenUsado = err.requestOptions.extra[chaveTokenUsado];
    if (tokenUsado is String && tokenUsado == await _armazenamento.ler()) {
      try {
        await _armazenamento.apagar();
      } on PlatformException {
        // Camada de dados, não UI: o armazenamento seguro pode falhar ao
        // apagar. A sessão expirada é reportada do mesmo jeito, e quem a
        // recebe (acervo, entrada) chama `SessaoCubit.encerrarPorExpiracao`,
        // que descarta a sessão local de novo (T-08-49).
      }
    }
    handler.reject(err.copyWith(error: const SessaoExpiradaException()));
  }
}
