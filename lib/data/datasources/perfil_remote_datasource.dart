import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/perfil_corretor_model.dart';
import 'perfil_datasource.dart';

/// DataSource real dos perfis públicos (WEB 02): lê
/// `GET /api/publico/corretores/{id}/` pelo `Dio` do `modulo_rede.dart`
/// (`API_BASE_URL`).
///
/// Registrada com `@lazySingleton` SEM `as:` de propósito: enquanto detalhe e
/// lista forem mock, o DI continua entregando `PerfilMockDataSource` como
/// [PerfilDataSource]. A troca da Phase 5 é mover `as: PerfilDataSource` do
/// mock para esta classe e rodar o build_runner (D-03) — duas anotações com
/// `as:` quebrariam o `getIt`.
///
/// Fina de propósito: não captura `DioException` (o Dio 5 lança em 404 e o
/// repositório traduz) e NÃO tem interceptador de log, porque o corpo traz
/// e-mail e telefone do corretor.
@lazySingleton
class PerfilRemoteDataSource implements PerfilDataSource {
  PerfilRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<PerfilCorretorModel> buscarCorretor(int id) async {
    return PerfilCorretorModel.fromJson(
      await _obterObjeto(caminhoPerfilCorretor(id)),
    );
  }

  /// GET em [caminho] exigindo um objeto JSON; qualquer outro corpo (lista,
  /// texto, nulo) é um contrato quebrado e vira [FormatException].
  Future<Map<String, Object?>> _obterObjeto(String caminho) async {
    final resposta = await _dio.get<Object?>(caminho);
    final corpo = resposta.data;
    if (corpo is! Map<String, dynamic>) {
      throw FormatException('Corpo de GET $caminho não é um objeto JSON.');
    }
    return corpo;
  }
}
