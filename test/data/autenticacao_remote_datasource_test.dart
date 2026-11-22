import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/autenticacao_remote_datasource.dart';
import 'package:imoveis_aqui/data/models/eu_model.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/domain/entities/papel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';

import '../support/api_falsa.dart';
import '../support/armazenamento_token_em_memoria.dart';

void main() {
  group('AutenticacaoRemoteDataSource', () {
    late ApiFalsa api;
    late ArmazenamentoTokenEmMemoria armazenamento;
    late AutenticacaoRemoteDataSource datasource;

    setUp(() {
      api = ApiFalsa();
      armazenamento = ArmazenamentoTokenEmMemoria();
      datasource = AutenticacaoRemoteDataSource(
        api.criarDio(),
        api.criarDioAutenticado(InterceptadorSessao(armazenamento)),
      );
    });

    group('entrar', () {
      test('faz POST /api/auth/login/ com {email, password} e devolve o token '
          'de login_200.json', () async {
        final token = await datasource.entrar(email: 'a@b.com', senha: 'x');

        expect(
          token,
          (lerFixtureApi('login_200.json')! as Map<String, Object?>)['token'],
        );
        final pedido = api.requisicoesGravadas.single;
        expect(pedido.metodo, 'POST');
        expect(pedido.uri.path, '/api/auth/login/');
        expect(pedido.corpo, {'email': 'a@b.com', 'password': 'x'});
      });

      test('login sem Authorization com token guardado', () async {
        armazenamento.token = 'token-antigo';

        await datasource.entrar(email: 'a@b.com', senha: 'x');

        expect(api.requisicoesGravadas.single.cabecalho('authorization'),
            isNull);
      });

      test('a senha vai sem trim', () async {
        await datasource.entrar(email: 'a@b.com', senha: '  senha  ');

        final corpo = api.requisicoesGravadas.single.corpo!
            as Map<String, Object?>;
        expect(corpo['password'], '  senha  ');
      });

      test('resposta sem token string não vazia lança FormatException',
          () async {
        for (final corpo in <Object?>[
          <String, Object?>{},
          {'token': ''},
          {'token': 7},
          <Object?>['x'],
        ]) {
          api.responder(
            (uri) => uri.path == '/api/auth/login/',
            status: 200,
            corpo: corpo,
          );
          await expectLater(
            datasource.entrar(email: 'a@b.com', senha: 'x'),
            throwsFormatException,
            reason: 'corpo: $corpo',
          );
        }
      });

      test('400 sobe como DioException (o repositório traduz)', () async {
        api.responder(
          (uri) => uri.path == '/api/auth/login/',
          status: 400,
          fixture: 'erro_400_login.json',
        );

        await expectLater(
          datasource.entrar(email: 'a@b.com', senha: 'x'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'status',
              400,
            ),
          ),
        );
      });
    });

    group('obterEu', () {
      test('com token guardado envia Authorization e devolve CORRETOR',
          () async {
        armazenamento.token = 'abc123';

        final eu = await datasource.obterEu();

        expect(eu, const EuModel(perfil: 'CORRETOR'));
        expect(eu.paraPapel(), Papel.corretor);
        final pedido = api.requisicoesGravadas.single;
        expect(pedido.uri.path, '/api/auth/eu/');
        expect(pedido.cabecalho('authorization'), 'Token abc123');
      });

      test('GESTOR e ADMINISTRADOR viram os papéis certos', () {
        expect(const EuModel(perfil: 'GESTOR').paraPapel(), Papel.gestor);
        expect(
          const EuModel(perfil: 'ADMINISTRADOR').paraPapel(),
          Papel.administrador,
        );
      });

      test('eu_gestor.json vira Papel.gestor', () async {
        armazenamento.token = 'abc123';
        api.responder(
          (uri) => uri.path == '/api/auth/eu/',
          status: 200,
          fixture: 'eu_gestor.json',
        );

        final eu = await datasource.obterEu();

        expect(eu.paraPapel(), Papel.gestor);
      });

      test('perfil desconhecido lança FormatException', () {
        expect(
          () => const EuModel(perfil: 'DONO').paraPapel(),
          throwsFormatException,
        );
        expect(
          () => const EuModel(perfil: 'corretor').paraPapel(),
          throwsFormatException,
        );
      });

      test('sem token a rota responde 401 e a falha é SessaoExpirada',
          () async {
        await expectLater(
          datasource.obterEu(),
          throwsA(
            isA<DioException>().having(
              (e) => e.error,
              'error',
              isA<SessaoExpiradaException>(),
            ),
          ),
        );
      });

      test('corpo que não é objeto lança FormatException', () async {
        armazenamento.token = 'abc123';
        api.responder(
          (uri) => uri.path == '/api/auth/eu/',
          status: 200,
          corpo: <Object?>[],
        );

        await expectLater(datasource.obterEu(), throwsFormatException);
      });
    });

    group('sair', () {
      test('faz POST /api/auth/sair/ com Authorization e aceita o 204',
          () async {
        armazenamento.token = 'abc123';

        await datasource.sair();

        final pedido = api.requisicoesGravadas.single;
        expect(pedido.metodo, 'POST');
        expect(pedido.uri.path, '/api/auth/sair/');
        expect(pedido.cabecalho('authorization'), 'Token abc123');
      });
    });
  });
}
