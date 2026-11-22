import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/vitrine_anunciante_remote_datasource.dart';
import 'package:imoveis_aqui/data/repositories/vitrine_anunciante_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/anunciante_ref.dart';
import 'package:imoveis_aqui/domain/entities/pagina_imoveis.dart';

import '../support/api_falsa.dart';

void main() {
  group('VitrineAnuncianteRemoteDataSource', () {
    late ApiFalsa api;
    late VitrineAnuncianteRemoteDataSource datasource;

    Map<String, Object?> fixture(String arquivo) =>
        lerFixtureApi(arquivo)! as Map<String, Object?>;

    List<int> idsDosItens(Map<String, Object?> pagina) => [
      for (final item in pagina['results']! as List<Object?>)
        (item! as Map<String, Object?>)['id']! as int,
    ];

    /// Id capturado do perfil (o mesmo da vitrine capturada do anunciante).
    int idCapturado(String recurso) =>
        fixture('perfil_$recurso.json')['id']! as int;

    bool rotaDaVitrine(Uri uri) => uri.path.endsWith('/imoveis/');

    setUp(() {
      api = ApiFalsa();
      datasource = VitrineAnuncianteRemoteDataSource(api.criarDio());
    });

    test(
      'buscar(corretor) pede /api/publico/corretores/<id>/imoveis/ sem query '
      'e devolve a p1 capturada com o next da fixture',
      () async {
        final id = idCapturado('corretor');

        final envelope = await datasource.buscar(AnuncianteRef.corretor(id));

        expect(api.requisicoes, hasLength(1));
        final uri = api.requisicoes.single;
        expect(uri.path, '/api/publico/corretores/$id/imoveis/');
        expect(uri.queryParameters, isEmpty);

        final p1 = fixture('vitrine_corretor_p1.json');
        expect(envelope.results, hasLength((p1['results']! as List).length));
        expect(envelope.results.map((m) => m.id), idsDosItens(p1));
        expect(envelope.next, p1['next']);
        expect(envelope.next, isNotNull);
      },
    );

    test('seguir(next) pede page=2 na mesma origem, devolve a p2 sem next e '
        'p1 + p2 são ids distintos em número igual ao count', () async {
      final id = idCapturado('corretor');
      final p1 = await datasource.buscar(AnuncianteRef.corretor(id));

      final p2 = await datasource.seguir(p1.next!);

      expect(api.requisicoes, hasLength(2));
      final uri = api.requisicoes.last;
      expect(uri.path, '/api/publico/corretores/$id/imoveis/');
      expect(uri.queryParameters['page'], '2');
      expect('${uri.scheme}://${uri.host}:${uri.port}', urlBaseApiFalsa);
      expect(p2.next, isNull);

      final ids = [
        ...p1.results.map((m) => m.id),
        ...p2.results.map((m) => m.id),
      ];
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, hasLength(fixture('vitrine_corretor_p1.json')['count']));
      expect(
        p2.results.map((m) => m.id),
        idsDosItens(fixture('vitrine_corretor_p2.json')),
      );
    });

    test('a vitrine da empresa pede /api/publico/empresas/<id>/imoveis/, segue '
        'o next e fecha o count com ids distintos', () async {
      final id = idCapturado('empresa');

      final p1 = await datasource.buscar(AnuncianteRef.empresa(id));

      final uri = api.requisicoes.single;
      expect(uri.path, '/api/publico/empresas/$id/imoveis/');
      expect(uri.queryParameters, isEmpty);
      expect(p1.next, fixture('vitrine_empresa_p1.json')['next']);

      final p2 = await datasource.seguir(p1.next!);

      expect(api.requisicoes.last.queryParameters['page'], '2');
      expect(p2.next, isNull);
      final ids = [
        ...p1.results.map((m) => m.id),
        ...p2.results.map((m) => m.id),
      ];
      expect(ids.toSet(), hasLength(ids.length));
      expect(ids, hasLength(fixture('vitrine_empresa_p1.json')['count']));
    });

    for (final urlEstranha in [
      'http://evil.example/api/publico/corretores/1/imoveis/?page=2',
      'http://127.0.0.1:9999/api/publico/corretores/1/imoveis/?page=2',
    ]) {
      test(
        'seguir com next de outra origem ($urlEstranha) lança FormatException '
        'e nenhuma requisição sai',
        () async {
          await expectLater(
            datasource.seguir(urlEstranha),
            throwsFormatException,
          );

          expect(api.requisicoes, isEmpty);
        },
      );
    }

    test('corpo que é uma lista JSON lança FormatException', () async {
      api.responder(rotaDaVitrine, status: 200, corpo: <Object?>[]);

      await expectLater(
        datasource.buscar(AnuncianteRef.corretor(idCapturado('corretor'))),
        throwsFormatException,
      );
    });

    test(
      'id sem fixture vira DioException 404 (a DataSource não captura)',
      () async {
        await expectLater(
          datasource.buscar(const AnuncianteRef.corretor(999999)),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'status',
              404,
            ),
          ),
        );
      },
    );

    test(
      'pelo repositório, um 429 servido pela API vira Failure (falha comum)',
      () async {
        api.responder(
          rotaDaVitrine,
          status: 429,
          fixture: 'erro_404_perfil.json',
        );
        final repositorio = VitrineAnuncianteRepositoryImpl(datasource);

        final resultado = await repositorio.buscarPrimeiraPagina(
          AnuncianteRef.corretor(idCapturado('corretor')),
        );

        expect(resultado, isA<Failure<PaginaImoveis>>());
        expect(
          (resultado as Failure<PaginaImoveis>).erro,
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            429,
          ),
        );
      },
    );
  });
}
