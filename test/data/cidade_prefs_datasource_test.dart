import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/cidade_prefs_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    Future<void> gravarCru(String valor) {
      return SharedPreferencesAsync().setString('cidade_selecionada', valor);
    }

    test(
      'cidade salva por uma instância é lida de volta por uma instância nova '
      '(cold start), com o id',
      () async {
        final origem = CidadePrefsDataSource();
        await origem.salvar(nome: 'Campinas', uf: 'SP', id: 3);

        final instanciaFresca = CidadePrefsDataSource();
        final resultado = await instanciaFresca.obterSalva();

        expect(resultado, ('Campinas', 'SP', 3));
      },
    );

    test('salvar sem id grava nome|uf e lê com id nulo', () async {
      final dataSource = CidadePrefsDataSource();
      await dataSource.salvar(nome: 'Campinas', uf: 'SP');

      expect(await dataSource.obterSalva(), ('Campinas', 'SP', null));
    });

    test('retorna null quando nenhuma cidade foi salva ainda', () async {
      final dataSource = CidadePrefsDataSource();

      final resultado = await dataSource.obterSalva();

      expect(resultado, isNull);
    });

    test('valor no formato antigo nome|uf lê com id nulo', () async {
      await gravarCru('Campinas|SP');

      expect(
        await CidadePrefsDataSource().obterSalva(),
        ('Campinas', 'SP', null),
      );
    });

    test('id que não é inteiro lê com id nulo, sem crash', () async {
      await gravarCru('Campinas|SP|abc');

      expect(
        await CidadePrefsDataSource().obterSalva(),
        ('Campinas', 'SP', null),
      );
    });

    test('valor com 1 ou 4+ partes lê como sem cidade', () async {
      await gravarCru('Campinas');
      expect(await CidadePrefsDataSource().obterSalva(), isNull);

      await gravarCru('Campinas|SP|3|extra');
      expect(await CidadePrefsDataSource().obterSalva(), isNull);
    });
  });
}
