import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'armazenamento_token.dart';

/// [ArmazenamentoToken] sobre o Keychain (iOS) e o Keystore (Android) via
/// `flutter_secure_storage` (D-D). Chave única `token_api`.
///
/// Fail-closed na leitura: uma chave do Keystore que não decifra mais (backup
/// restaurado, aparelho trocado) vira "sem sessão", nunca um erro na tela
/// (T-08-12). `salvar` e `apagar` deixam a [PlatformException] subir: quem
/// chama decide (o repositório transforma em falha ou tolera).
@LazySingleton(as: ArmazenamentoToken)
class ArmazenamentoTokenSeguro implements ArmazenamentoToken {
  ArmazenamentoTokenSeguro(this._armazenamento);

  static const _chave = 'token_api';

  final FlutterSecureStorage _armazenamento;

  @override
  Future<String?> ler() async {
    try {
      return await _armazenamento.read(key: _chave);
    } on PlatformException {
      // Camada de dados: o armazenamento do SO pode estar ilegível; sem
      // token legível não há sessão.
      return null;
    }
  }

  @override
  Future<void> salvar(String token) =>
      _armazenamento.write(key: _chave, value: token);

  @override
  Future<void> apagar() => _armazenamento.delete(key: _chave);
}
