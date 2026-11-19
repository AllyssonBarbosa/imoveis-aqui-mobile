import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/perfil_corretor_model.dart';
import '../models/perfil_empresa_model.dart';
import 'perfil_datasource.dart';

/// DataSource dos perfis públicos (WEB 02): lê
/// `GET /api/publico/corretores/{id}/` e `GET /api/publico/empresas/{id}/`
/// pelo `Dio` do `modulo_rede.dart` (`API_BASE_URL`). É a implementação ativa
/// de [PerfilDataSource] no DI de produção (D-08): não existe mock de perfil
/// no app.
///
/// Fina de propósito: não captura `DioException` (o Dio 5 lança em 404 e o
/// repositório traduz) e NÃO tem interceptador de log, porque o corpo traz
/// e-mail e telefone do corretor.
@LazySingleton(as: PerfilDataSource)
class PerfilRemoteDataSource implements PerfilDataSource {
  PerfilRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<PerfilCorretorModel> buscarCorretor(int id) async {
    return PerfilCorretorModel.fromJson(
      await _obterObjeto(caminhoPerfilCorretor(id)),
    );
  }

  @override
  Future<PerfilEmpresaModel> buscarEmpresa(int id) async {
    return PerfilEmpresaModel.fromJson(
      await _obterObjeto(caminhoPerfilEmpresa(id)),
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
