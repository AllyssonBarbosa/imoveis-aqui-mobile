import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:injectable/injectable.dart';

import '../models/cidade_model.dart';

/// Lê `assets/cidades.json` — mesma forma do contrato `GET /cidades`
/// (envelope cursor `{next, previous, results}`, D-13) — e descarta, sem
/// lançar exceção, qualquer linha cujo `nome`/`uf` esteja ausente ou vazio
/// (UI-SPEC E2/E3 partial: a tela continua com as linhas válidas).
///
/// O construtor padrão (o único que o `injectable` enxerga) sempre usa
/// [rootBundle] — nada de `AssetBundle` fica exposto ao contêiner de DI (não
/// há registro para ele, então deixá-lo no construtor padrão quebraria
/// `configureDependencies()` em runtime). Testes usam
/// [CidadeLocalDataSource.comBundle] para injetar um fixture alternativo.
@lazySingleton
class CidadeLocalDataSource {
  CidadeLocalDataSource() : _bundle = rootBundle;

  @visibleForTesting
  CidadeLocalDataSource.comBundle(AssetBundle bundle) : _bundle = bundle;

  final AssetBundle _bundle;

  static const _caminhoAsset = 'assets/cidades.json';

  Future<List<CidadeModel>> obterCidades() async {
    final conteudo = await _bundle.loadString(_caminhoAsset);
    final envelope = jsonDecode(conteudo) as Map<String, dynamic>;
    final linhas = (envelope['results'] as List<dynamic>?) ?? const [];

    final cidades = <CidadeModel>[];
    for (final linha in linhas) {
      final mapa = linha as Map<String, dynamic>;
      final nome = mapa['nome'] as String?;
      final uf = mapa['uf'] as String?;
      if (nome == null || nome.isEmpty || uf == null || uf.isEmpty) {
        // Linha descartada: nome/uf ausente — nunca crash (UI-SPEC partial).
        continue;
      }
      cidades.add(CidadeModel.fromJson(mapa));
    }
    return cidades;
  }
}
