import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/cidade_local_datasource.dart';

/// Bundle falso que devolve um JSON fixo para qualquer chave — só para
/// substituir `assets/cidades.json` real em teste.
class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._conteudo);

  final String _conteudo;

  @override
  Future<ByteData> load(String key) async {
    final bytes = utf8.encode(_conteudo);
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

void main() {
  group('CidadeLocalDataSource', () {
    test(
      'linha com nome/uf ausente é descartada; as válidas continuam carregando',
      () async {
        const json = '''
        {
          "next": null,
          "previous": null,
          "results": [
            {"id": 1, "nome": "Campinas", "uf": "SP"},
            {"id": 2, "nome": "", "uf": "SP"},
            {"id": 3, "uf": "SP"},
            {"id": 4, "nome": "Valinhos", "uf": "SP"}
          ]
        }
        ''';
        final dataSource = CidadeLocalDataSource.comBundle(
          _FakeAssetBundle(json),
        );

        final cidades = await dataSource.obterCidades();

        expect(cidades, hasLength(2));
        expect(
          cidades.map((cidade) => cidade.nome),
          containsAll(<String>['Campinas', 'Valinhos']),
        );
      },
    );

    test('envelope cursor sem linhas retorna lista vazia', () async {
      const json = '{"next": null, "previous": null, "results": []}';
      final dataSource = CidadeLocalDataSource.comBundle(
        _FakeAssetBundle(json),
      );

      final cidades = await dataSource.obterCidades();

      expect(cidades, isEmpty);
    });
  });
}
