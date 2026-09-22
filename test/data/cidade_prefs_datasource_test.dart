import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/cidade_prefs_datasource.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  group('CidadePrefsDataSource', () {
    setUp(() {
      // Simula o "armazenamento do aparelho" — sobrevive à criação de uma
      // instância nova de CidadePrefsDataSource (cold start), pois é o
      // backing store da plataforma, não estado da própria instância.
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test(
      'cidade salva por uma instância é lida de volta por uma instância nova (cold start)',
      () async {
        final origem = CidadePrefsDataSource();
        await origem.salvar(nome: 'Campinas', uf: 'SP');

        final instanciaFresca = CidadePrefsDataSource();
        final resultado = await instanciaFresca.obterSalva();

        expect(resultado, ('Campinas', 'SP'));
      },
    );

    test('retorna null quando nenhuma cidade foi salva ainda', () async {
      final dataSource = CidadePrefsDataSource();

      final resultado = await dataSource.obterSalva();

      expect(resultado, isNull);
    });
  });
}
