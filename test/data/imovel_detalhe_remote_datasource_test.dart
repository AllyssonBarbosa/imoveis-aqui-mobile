import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_remote_datasource.dart';

import '../support/api_falsa.dart';

/// `ImovelDetalheRemoteDataSource` sobre o JSON REAL capturado (D-18, DET-06):
/// a rota do detalhe, o 404 de imóvel indisponível e o corpo que não é objeto.
void main() {
  group('ImovelDetalheRemoteDataSource', () {
    late ApiFalsa api;
    late ImovelDetalheRemoteDataSource datasource;

    final casa = lerFixtureApi('detalhe_casa.json')! as Map<String, Object?>;
    final idCasa = casa['id']! as int;

    setUp(() {
      api = ApiFalsa();
      datasource = ImovelDetalheRemoteDataSource(api.criarDio());
    });

    test(
      'buscarDetalhe pede /api/publico/imoveis/<id>/ e devolve o detalhe '
      'capturado',
      () async {
        final modelo = await datasource.buscarDetalhe(idCasa);

        expect(api.requisicoes, hasLength(1));
        expect(api.requisicoes.single.path, '/api/publico/imoveis/$idCasa/');
        expect(modelo.id, idCasa);
        expect(modelo.titulo, casa['titulo']);
      },
    );

    test('imóvel indisponível: o 404 sobe como DioException 404', () async {
      api.responder(
        (uri) => uri.path == '/api/publico/imoveis/$idCasa/',
        status: 404,
        fixture: 'erro_404_detalhe.json',
      );

      await expectLater(
        datasource.buscarDetalhe(idCasa),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            404,
          ),
        ),
      );
    });

    test('id sem detalhe capturado responde 404 (DioException)', () async {
      await expectLater(
        datasource.buscarDetalhe(999999),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            404,
          ),
        ),
      );
    });

    test('corpo que não é um objeto JSON lança FormatException', () async {
      api.responder(
        (uri) => uri.path == '/api/publico/imoveis/$idCasa/',
        status: 200,
        corpo: const <Object?>[],
      );

      await expectLater(
        datasource.buscarDetalhe(idCasa),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
