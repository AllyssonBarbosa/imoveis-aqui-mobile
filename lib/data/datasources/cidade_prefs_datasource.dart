import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste a cidade escolhida no aparelho via a nova API
/// [SharedPreferencesAsync] (NÃO a `SharedPreferences.getInstance()` legada —
/// CLAUDE.md "What NOT to Use"). Chave única `cidade_selecionada`, valor
/// codificado `nome|uf` (chave natural, D-15) ou `nome|uf|id`, com o id da
/// API como atributo auxiliar de rota (A-01): a identidade continua sendo
/// nome+uf, o id só permite montar as rotas da cidade quando a lista de
/// cidades falhou na abertura.
///
/// Sem conta, sem senha, sem dado sensível (LOC-04) — não precisa de
/// `flutter_secure_storage`.
@lazySingleton
class CidadePrefsDataSource {
  static const _chave = 'cidade_selecionada';

  final SharedPreferencesAsync _preferencias = SharedPreferencesAsync();

  Future<void> salvar({required String nome, required String uf, int? id}) {
    final valor = id == null ? '$nome|$uf' : '$nome|$uf|$id';
    return _preferencias.setString(_chave, valor);
  }

  /// Retorna `(nome, uf, id)` da cidade salva, ou `null` se nenhuma foi salva
  /// ainda (ou se o valor persistido estiver corrompido). O valor antigo
  /// `nome|uf` continua sendo lido (id nulo); um id que não seja inteiro
  /// também vira id nulo, nunca um crash (A-01).
  Future<(String nome, String uf, int? id)?> obterSalva() async {
    final valor = await _preferencias.getString(_chave);
    if (valor == null) return null;
    final partes = valor.split('|');
    if (partes.length == 2) return (partes[0], partes[1], null);
    if (partes.length == 3) {
      return (partes[0], partes[1], int.tryParse(partes[2]));
    }
    return null;
  }
}
