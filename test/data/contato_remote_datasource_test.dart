import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/contato_datasource.dart';
import 'package:imoveis_aqui/data/datasources/contato_remote_datasource.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';

import '../support/api_falsa.dart';

/// O POST de contato sobre a ApiFalsa (W11): método, caminho e corpo certos, sem
/// credencial (C4, C6), resposta lida do JSON capturado e falhas do servidor
/// subindo como `DioException`.
void main() {
  late ApiFalsa apiFalsa;
  late ContatoRemoteDataSource dataSource;

  final idCasa =
      (lerFixtureApi('detalhe_casa.json')! as Map<String, Object?>)['id']!
          as int;

  const valorDoCanal = {
    CanalContato.whatsapp: 'WHATSAPP',
    CanalContato.telefone: 'TELEFONE',
    CanalContato.email: 'EMAIL',
  };

  setUp(() {
    apiFalsa = ApiFalsa();
    dataSource = ContatoRemoteDataSource(apiFalsa.criarDio());
  });

  group('registrar', () {
    for (final entrada in valorDoCanal.entries) {
      final canal = entrada.key;
      final valor = entrada.value;

      test('$valor: modelo igual ao contato_201 capturado e POST sem '
          'credencial', () async {
        final capturado =
            lerFixtureApi('contato_201_${valor.toLowerCase()}.json')!
                as Map<String, Object?>;

        final modelo = await dataSource.registrar(idCasa, canal);

        expect(modelo.canal, capturado['canal']);
        expect(modelo.link, capturado['link']);

        final chamada = apiFalsa.chamadas.single;
        expect(chamada.metodo, 'POST');
        expect(chamada.uri.path, caminhoContatoImovelPublico(idCasa));
        expect(chamada.uri.path, '/api/publico/imoveis/$idCasa/contato/');
        expect(chamada.corpo, {'canal': valor});
        final nomes = chamada.cabecalhos.keys.map((n) => n.toLowerCase());
        expect(nomes, isNot(contains('authorization')));
        expect(nomes, isNot(contains('cookie')));
      });
    }

    test('requisicoes continua guardando URIs simples', () async {
      await dataSource.registrar(idCasa, CanalContato.whatsapp);

      expect(apiFalsa.requisicoes, isA<List<Uri>>());
      expect(
        apiFalsa.requisicoes.single.path,
        '/api/publico/imoveis/$idCasa/contato/',
      );
    });

    test('400 do servidor sobe como DioException 400', () async {
      apiFalsa.responder(
        (uri) => uri.path == caminhoContatoImovelPublico(idCasa),
        status: 400,
        fixture: 'erro_400_canal_contato.json',
      );

      await expectLater(
        dataSource.registrar(idCasa, CanalContato.whatsapp),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            400,
          ),
        ),
      );
    });

    test('id fora das fixtures sobe como DioException 404', () async {
      await expectLater(
        dataSource.registrar(999999, CanalContato.whatsapp),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            404,
          ),
        ),
      );
    });

    test('201 com corpo que não é objeto vira FormatException', () async {
      apiFalsa.responder(
        (uri) => uri.path == caminhoContatoImovelPublico(idCasa),
        status: 201,
        corpo: <Object?>[],
      );

      await expectLater(
        dataSource.registrar(idCasa, CanalContato.email),
        throwsA(isA<FormatException>()),
      );
    });
  });

  test('GET na rota de contato responde 405', () async {
    final dio = apiFalsa.criarDio();

    await expectLater(
      dio.get<Object?>(caminhoContatoImovelPublico(idCasa)),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          405,
        ),
      ),
    );
    expect(apiFalsa.chamadas.single.metodo, 'GET');
  });
}
