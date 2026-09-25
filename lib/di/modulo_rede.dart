import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

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

/// Módulo de DI do cliente HTTP (D-17) — expõe um único [Dio] singleton para
/// todo o app. Sem interceptors e sem autenticação (endpoints públicos, sem
/// login) e sem `@Environment` (RESEARCH Pattern 6: não há uma segunda
/// implementação a escolher ainda). Timeouts de 10s garantem que uma falha
/// de rede sempre vire `Result.failure` com "Tentar de novo" em vez de uma
/// tela de carregamento presa (T-02-04-03).
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
}
