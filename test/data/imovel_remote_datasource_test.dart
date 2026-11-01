import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_remote_datasource.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/ordenacao_vitrine.dart';

import '../support/api_falsa.dart';

void main() {
  group('ImovelRemoteDataSource', () {
    late ApiFalsa api;
    late ImovelRemoteDataSource datasource;
    late Cidade campinas;

    bool rotaDaLista(Uri uri) =>
        uri.path.startsWith('/api/publico/cidades/') &&
        uri.path.endsWith('/imoveis/');

    List<Map<String, Object?>> linhasDaFixture(String arquivo) =>
        ((lerFixtureApi(arquivo)! as Map<String, Object?>)['results']!
                as List<Object?>)
            .cast<Map<String, Object?>>();

    setUp(() {
      api = ApiFalsa();
      datasource = ImovelRemoteDataSource(api.criarDio());
      final linha = (lerFixtureApi('cidades.json')! as List<Object?>)
          .cast<Map<String, Object?>>()
          .firstWhere((c) => c['nome'] == 'Campinas');
      campinas = Cidade(
        id: linha['id']! as int,
        nome: linha['nome']! as String,
        uf: linha['uf']! as String,
      );
    });

    test(
      'buscar pede /api/publico/cidades/<id>/imoveis/ com ordenar=recentes, '
      'sem query cidade, e devolve os 20 itens da p1 na ordem',
      () async {
        final envelope = await datasource.buscar(
          ConsultaImoveis(cidade: campinas),
        );

        expect(api.requisicoes, hasLength(1));
        final uri = api.requisicoes.single;
        expect(uri.path, '/api/publico/cidades/${campinas.id}/imoveis/');
        expect(uri.queryParameters['ordenar'], 'recentes');
        expect(uri.queryParameters.containsKey('cidade'), isFalse);

        final linhas = linhasDaFixture('lista_campinas_p1.json');
        expect(envelope.results, hasLength(20));
        expect(
          envelope.results.map((m) => m.id),
          linhas.map((l) => l['id']),
        );
        expect(
          envelope.results.map((m) => m.titulo),
          linhas.map((l) => l['titulo']),
        );
      },
    );

    test('a ordenação escolhida vai como ordenar da W09', () async {
      await datasource.buscar(
        ConsultaImoveis(
          cidade: campinas,
          ordenacao: OrdenacaoVitrine.precoDesc,
        ),
      );

      expect(api.requisicoes.single.queryParameters['ordenar'], '-preco');
    });

    test('seguir(next da p1) pede page=2 na mesma origem e lê a p2', () async {
      final p1 = await datasource.buscar(ConsultaImoveis(cidade: campinas));
      final proxima = p1.next;
      expect(proxima, isNotNull);

      final p2 = await datasource.seguir(proxima!);

      expect(api.requisicoes, hasLength(2));
      final uri = api.requisicoes.last;
      expect(uri.queryParameters['page'], '2');
      expect(
        '${uri.scheme}://${uri.host}:${uri.port}',
        urlBaseApiFalsa,
      );
      expect(
        p2.results.map((m) => m.id),
        linhasDaFixture('lista_campinas_p2.json').map((l) => l['id']),
      );
      expect(p2.next, isNull);
    });

    test(
      'seguir com next de outra origem lança FormatException e nenhuma '
      'requisição sai',
      () async {
        await expectLater(
          datasource.seguir(
            'http://outro-host:8000/api/publico/cidades/1/imoveis/?page=2',
          ),
          throwsFormatException,
        );

        expect(api.requisicoes, isEmpty);
      },
    );

    test(
      'buscar com cidade sem id lança FormatException e nenhuma requisição '
      'sai',
      () async {
        await expectLater(
          datasource.buscar(
            const ConsultaImoveis(
              cidade: Cidade(nome: 'Campinas', uf: 'SP'),
            ),
          ),
          throwsFormatException,
        );

        expect(api.requisicoes, isEmpty);
      },
    );

    test('corpo que não é objeto JSON lança FormatException', () async {
      api.responder(
        rotaDaLista,
        status: 200,
        corpo: lerFixtureApi('cidades.json'),
      );

      await expectLater(
        datasource.buscar(ConsultaImoveis(cidade: campinas)),
        throwsFormatException,
      );
    });
  });
}
