import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste a cidade escolhida no aparelho via a nova API
/// [SharedPreferencesAsync] (NÃO a `SharedPreferences.getInstance()` legada —
/// CLAUDE.md "What NOT to Use"). Chave única `cidade_selecionada`, valor
/// codificado `nome|uf` — chave natural (D-15), nunca o `id` numérico, que
/// não é estável entre a fixture local e a futura API real.
///
/// Sem conta, sem senha, sem dado sensível (LOC-04) — não precisa de
/// `flutter_secure_storage`.
@lazySingleton
class CidadePrefsDataSource {
  static const _chave = 'cidade_selecionada';

  final SharedPreferencesAsync _preferencias = SharedPreferencesAsync();

  Future<void> salvar({required String nome, required String uf}) {
    return _preferencias.setString(_chave, '$nome|$uf');
  }

  /// Retorna `(nome, uf)` da cidade salva, ou `null` se nenhuma foi salva
  /// ainda (ou se o valor persistido estiver corrompido).
  Future<(String nome, String uf)?> obterSalva() async {
    final valor = await _preferencias.getString(_chave);
    if (valor == null) return null;
    final partes = valor.split('|');
    if (partes.length != 2) return null;
    return (partes[0], partes[1]);
  }
}
