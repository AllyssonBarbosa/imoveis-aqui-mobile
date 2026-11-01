import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_remote_datasource.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';

import '../support/api_falsa.dart';

void main() {
  group('OpcoesFiltroRemoteDataSource', () {
    late ApiFalsa api;

    // Campinas como a API devolve (com id), lida da fixture capturada.
    final campinas = () {
      final linha = (lerFixtureApi('cidades.json')! as List<Object?>)
          .cast<Map<String, Object?>>()
          .firstWhere((c) => c['nome'] == 'Campinas');
      return Cidade(
        id: linha['id']! as int,
        nome: linha['nome']! as String,
        uf: linha['uf']! as String,
      );
    }();

    bool rotaCaracteristicas(Uri uri) =>
        uri.path == '/api/publico/caracteristicas/';
    bool rotaBairros(Uri uri) => uri.path.endsWith('/bairros/');

    final catalogo = (lerFixtureApi('caracteristicas.json')! as List<Object?>)
        .cast<Map<String, Object?>>();

    setUp(() {
      api = ApiFalsa();
    });

    group('bairros', () {
      test(
        'GET no caminho do id da cidade e devolve o array de '
        'bairros_campinas.json na ordem recebida',
        () async {
          final datasource = OpcoesFiltroRemoteDataSource(api.criarDio());

          final bairros = await datasource.bairros(campinas);

          expect(
            bairros,
            (lerFixtureApi('bairros_campinas.json')! as List<Object?>)
                .cast<String>(),
          );
          expect(api.requisicoes.map((u) => u.toString()), [
            '$urlBaseApiFalsa/api/publico/cidades/${campinas.id}/bairros/',
          ]);
        },
      );

      test('cidade sem id: FormatException e nenhuma requisição', () async {
        final datasource = OpcoesFiltroRemoteDataSource(api.criarDio());

        await expectLater(
          datasource.bairros(const Cidade(nome: 'Campinas', uf: 'SP')),
          throwsA(isA<FormatException>()),
        );
        expect(api.requisicoes, isEmpty);
      });

      test('corpo que não é uma lista -> FormatException', () async {
        api.responder(
          rotaBairros,
          status: 200,
          fixture: 'lista_campinas_p1.json',
        );
        final datasource = OpcoesFiltroRemoteDataSource(api.criarDio());

        await expectLater(
          datasource.bairros(campinas),
          throwsA(isA<FormatException>()),
        );
      });

      test('itens que não são texto ou são vazios são descartados', () async {
        api.responder(
          rotaBairros,
          status: 200,
          corpo: ['Cambuí', 3, '', null, 'Centro', <String, Object?>{}],
        );
        final datasource = OpcoesFiltroRemoteDataSource(api.criarDio());

        expect(await datasource.bairros(campinas), ['Cambuí', 'Centro']);
      });

      test('HTTP 500 -> DioException propaga', () async {
        api.responder(rotaBairros, status: 500);
        final datasource = OpcoesFiltroRemoteDataSource(api.criarDio());

        await expectLater(
          datasource.bairros(campinas),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('caracteristicas', () {
      test(
        'caracteristicas.json parseia para os mesmos ids e nomes, na mesma '
        'ordem, com uma requisição ao catálogo',
        () async {
          final datasource = OpcoesFiltroRemoteDataSource(api.criarDio());

          final modelos = await datasource.caracteristicas();

          expect(modelos.map((m) => m.id), catalogo.map((c) => c['id']));
          expect(modelos.map((m) => m.nome), catalogo.map((c) => c['nome']));
          expect(api.requisicoes.map((u) => u.toString()), [
            '$urlBaseApiFalsa/api/publico/caracteristicas/',
          ]);
        },
      );

      test(
        'linhas sem id inteiro ou com nome vazio/ausente são descartadas; '
        'as válidas permanecem na ordem',
        () async {
          final validaA = catalogo[0];
          final validaB = catalogo[1];
          api.responder(
            rotaCaracteristicas,
            status: 200,
            corpo: [
              validaA,
              {...validaA}..remove('id'),
              {...validaA, 'id': '1'},
              {...validaA, 'nome': ''},
              validaB,
              {...validaB}..remove('nome'),
              {...validaB, 'nome': 7},
              'Piscina',
            ],
          );
          final datasource = OpcoesFiltroRemoteDataSource(api.criarDio());

          final modelos = await datasource.caracteristicas();

          expect(modelos.map((m) => m.nome), [
            validaA['nome'],
            validaB['nome'],
          ]);
        },
      );

      test('corpo que não é uma lista -> FormatException', () async {
        api.responder(
          rotaCaracteristicas,
          status: 200,
          fixture: 'lista_campinas_p1.json',
        );
        final datasource = OpcoesFiltroRemoteDataSource(api.criarDio());

        await expectLater(
          datasource.caracteristicas(),
          throwsA(isA<FormatException>()),
        );
      });

      test('HTTP 500 -> DioException propaga', () async {
        api.responder(rotaCaracteristicas, status: 500);
        final datasource = OpcoesFiltroRemoteDataSource(api.criarDio());

        await expectLater(
          datasource.caracteristicas(),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
