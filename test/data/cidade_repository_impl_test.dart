import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/cidade_prefs_datasource.dart';
import 'package:imoveis_aqui/data/datasources/cidade_remote_datasource.dart';
import 'package:imoveis_aqui/data/repositories/cidade_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../support/api_falsa.dart';

void main() {
  group('CidadeRepositoryImpl (ApiFalsa + prefs reais)', () {
    late ApiFalsa api;
    late CidadeRepositoryImpl repositorio;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      api = ApiFalsa();
      repositorio = CidadeRepositoryImpl(
        CidadeRemoteDataSource(api.criarDio()),
        CidadePrefsDataSource(),
      );
    });

    Future<List<Cidade>> listar() async {
      final resultado = await repositorio.obterCidadesAtendidas();
      expect(resultado, isA<Success<List<Cidade>>>());
      return (resultado as Success<List<Cidade>>).data;
    }

    test('lista as cidades de cidades.json com os ids da API', () async {
      final cidades = await listar();

      final esperado = (lerFixtureApi('cidades.json')! as List)
          .cast<Map<String, dynamic>>();
      expect(cidades.map((c) => c.id), esperado.map((c) => c['id']));
      expect(cidades.map((c) => c.nome), esperado.map((c) => c['nome']));
    });

    test('salvar Campinas e ler de volta devolve Campinas com o mesmo id',
        () async {
      final cidades = await listar();
      final campinas = cidades.firstWhere((c) => c.nome == 'Campinas');
      expect(campinas.id, isNotNull);

      await repositorio.salvarCidade(campinas);
      final salva = await repositorio.obterCidadeSalva();

      expect(salva, campinas);
      expect(salva?.id, campinas.id);
    });

    test('invariante: toda cidade de cidades.json faz ida e volta pelo '
        'repositório com o mesmo id e a mesma igualdade', () async {
      final cidades = await listar();
      expect(cidades, isNotEmpty);

      for (final cidade in cidades) {
        await repositorio.salvarCidade(cidade);
        final salva = await repositorio.obterCidadeSalva();

        expect(salva, cidade, reason: 'igualdade de ${cidade.nome}');
        expect(salva?.id, cidade.id, reason: 'id de ${cidade.nome}');
      }
    });

    test('HTTP 500 na rota de cidades -> Result.failure', () async {
      api.responder(
        (uri) => uri.path == '/api/publico/cidades/',
        status: 500,
      );

      final resultado = await repositorio.obterCidadesAtendidas();

      expect(resultado, isA<Failure<List<Cidade>>>());
    });

    test('nenhuma cidade salva -> obterCidadeSalva devolve null', () async {
      expect(await repositorio.obterCidadeSalva(), isNull);
    });
  });
}
