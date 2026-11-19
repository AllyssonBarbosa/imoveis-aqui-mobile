import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/cidade_remote_datasource.dart';

import '../support/api_falsa.dart';

void main() {
  group('CidadeRemoteDataSource', () {
    late ApiFalsa api;

    bool rotaCidades(Uri uri) => uri.path == '/api/publico/cidades/';

    setUp(() {
      api = ApiFalsa();
    });

    test(
      'array de cidades.json -> CidadeModel na ordem, com ids preservados, '
      'requisição única para a rota de cidades',
      () async {
        final datasource = CidadeRemoteDataSource(api.criarDio());

        final cidades = await datasource.obterCidades();

        final esperado = (lerFixtureApi('cidades.json')! as List)
            .cast<Map<String, dynamic>>();
        expect(cidades.map((c) => c.id), esperado.map((c) => c['id']));
        expect(cidades.map((c) => c.nome), esperado.map((c) => c['nome']));
        expect(cidades.map((c) => c.uf), esperado.map((c) => c['uf']));
        expect(cidades.map((c) => c.nome), contains('Campinas'));
        expect(api.requisicoes.map((u) => u.toString()), [
          '$urlBaseApiFalsa/api/publico/cidades/',
        ]);
      },
    );

    test(
      'o modelo vira entidade com o id da API, fora da igualdade',
      () async {
        final datasource = CidadeRemoteDataSource(api.criarDio());

        final cidades = await datasource.obterCidades();
        final campinas = cidades
            .firstWhere((c) => c.nome == 'Campinas')
            .paraEntidade();

        expect(campinas.id, isNotNull);
        expect(campinas.nome, 'Campinas');
      },
    );

    test(
      'linhas sem id inteiro ou com nome/uf vazio ou ausente são descartadas; '
      'as válidas permanecem na ordem',
      () async {
        final linhas = (lerFixtureApi('cidades.json')! as List)
            .cast<Map<String, dynamic>>();
        final validaA = linhas[0];
        final validaB = linhas[1];
        // Linhas malformadas: cópia de uma linha capturada com uma chave
        // alterada/removida.
        final semId = {...validaA}..remove('id');
        final idTexto = {...validaA, 'id': '1'};
        final nomeVazio = {...validaA, 'nome': ''};
        final ufVazia = {...validaA, 'uf': ''};
        final semUf = {...validaA}..remove('uf');
        api.responder(
          rotaCidades,
          status: 200,
          corpo: [
            validaA,
            semId,
            idTexto,
            nomeVazio,
            validaB,
            ufVazia,
            semUf,
            'texto',
          ],
        );
        final dio = api.criarDio();
        final datasource = CidadeRemoteDataSource(dio);

        final cidades = await datasource.obterCidades();

        expect(cidades.map((c) => c.nome), [
          validaA['nome'],
          validaB['nome'],
        ]);
      },
    );

    test(
      'corpo que não é uma lista (objeto de lista paginada) -> '
      'FormatException',
      () async {
        api.responder(
          rotaCidades,
          status: 200,
          fixture: 'lista_campinas_p1.json',
        );
        final datasource = CidadeRemoteDataSource(api.criarDio());

        await expectLater(
          datasource.obterCidades(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('HTTP 500 -> exceção propaga (DioException)', () async {
      api.responder(rotaCidades, status: 500);
      final datasource = CidadeRemoteDataSource(api.criarDio());

      await expectLater(
        datasource.obterCidades(),
        throwsA(isA<DioException>()),
      );
    });
  });
}
