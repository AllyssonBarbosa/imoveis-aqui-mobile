import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/eu_model.dart';
import 'autenticacao_datasource.dart';

/// Fala com `/api/auth/login/`, `/api/auth/eu/` e `/api/auth/sair/`.
///
/// O login usa o [Dio] público de propósito: nunca leva um `Authorization`
/// velho (T-08-27). `eu` e `sair` usam o [Dio] `'autenticado'`. O pedido de
/// Sair não passa de 5 s porque a saída local acontece de qualquer jeito: os
/// `Options` abaixo cobrem só enviar e receber; o limite total (inclusive o
/// `connectTimeout` de 10 s do `Dio`) é imposto por quem chama, em
/// `AutenticacaoRepositoryImpl.sair` (`esperaMaximaSair`).
///
/// Fina de propósito: não captura `DioException` (o repositório traduz por
/// status) e não loga — e-mail e senha nunca passam por log.
@LazySingleton(as: AutenticacaoDataSource)
class AutenticacaoRemoteDataSource implements AutenticacaoDataSource {
  AutenticacaoRemoteDataSource(
    this._dioPublico,
    @Named('autenticado') this._dioAutenticado,
  );

  final Dio _dioPublico;
  final Dio _dioAutenticado;

  @override
  Future<String> entrar({required String email, required String senha}) async {
    // A senha vai sem `trim`: o servidor usa `trim_whitespace=False`.
    final resposta = await _dioPublico.post<Object?>(
      '/api/auth/login/',
      data: {'email': email, 'password': senha},
    );
    final corpo = resposta.data;
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException('Corpo do login não é um objeto JSON.');
    }
    final token = corpo['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Resposta do login sem token.');
    }
    return token;
  }

  @override
  Future<EuModel> obterEu() async {
    final resposta = await _dioAutenticado.get<Object?>('/api/auth/eu/');
    final corpo = resposta.data;
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException('Corpo de /eu não é um objeto JSON.');
    }
    return EuModel.fromJson(corpo);
  }

  @override
  Future<void> sair() async {
    await _dioAutenticado.post<Object?>(
      '/api/auth/sair/',
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
  }
}
