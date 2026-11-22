import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../data/network/interceptador_sessao.dart';

/// Base URL da API Django, configurável via `--dart-define=API_BASE_URL=...`
/// (D-17). Padrão `http://10.0.2.2:8000` — alias que o emulador Android usa
/// para o `localhost` da máquina que roda `manage.py runserver`. Simulador
/// iOS: `--dart-define=API_BASE_URL=http://127.0.0.1:8000`; aparelho físico:
/// o IP da rede local da máquina (ver README, seção "API e servidor de
/// desenvolvimento").
const String urlBaseApi = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

/// Monta o [Dio] autenticado: os mesmos `BaseOptions` do [Dio] público (base
/// URL e timeouts de 10s) mais `followRedirects: false` — uma credencial nunca
/// segue um 3xx para outro destino (T-08-11) — e o [interceptador] de sessão.
/// Função de topo para a produção e a `ApiFalsa` dos testes montarem o mesmo
/// cliente, trocando só o adaptador.
Dio construirDioAutenticado({
  required String urlBase,
  required Interceptor interceptador,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: urlBase,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      followRedirects: false,
    ),
  );
  dio.interceptors.add(interceptador);
  return dio;
}

/// Módulo de DI do cliente HTTP (D-17) — dois [Dio] singletons. O [Dio] sem
/// nome continua público, sem interceptors e sem autenticação (vitrine e
/// login); o `@Named('autenticado')` é o único que leva o token da API, só
/// para a origem da base URL. Sem `@Environment` (RESEARCH Pattern 6: não há
/// uma segunda implementação a escolher ainda). Timeouts de 10s garantem que
/// uma falha de rede sempre vire `Result.failure` com "Tentar de novo" em vez
/// de uma tela de carregamento presa (T-02-04-03).
@module
abstract class ModuloRede {
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: urlBaseApi,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  );

  /// Cliente das rotas autenticadas do corretor: leva `Authorization: Token`
  /// pelo [InterceptadorSessao] e transforma todo 401 em
  /// `SessaoExpiradaException`.
  @Named('autenticado')
  @lazySingleton
  Dio dioAutenticado(InterceptadorSessao interceptador) =>
      construirDioAutenticado(urlBase: urlBaseApi, interceptador: interceptador);

  /// Keychain/Keystore do aparelho, onde só o token da API é guardado (D-D).
  /// Opções padrão do 11.x.
  @lazySingleton
  FlutterSecureStorage get armazenamentoSeguro => const FlutterSecureStorage();
}
