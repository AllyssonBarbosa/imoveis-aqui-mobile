import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/armazenamento_token.dart';
import 'package:imoveis_aqui/data/datasources/armazenamento_token_seguro.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/data/network/mesma_origem.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/di/modulo_rede.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';
import '../support/armazenamento_token_em_memoria.dart';

class _ArmazenamentoFalso extends Mock implements ArmazenamentoToken {}

const _rotaAutenticada = '/api/auth/eu/';

/// Chama [chamada] e devolve a [DioException] que ela lançou.
Future<DioException> _falhaDe(Future<Object?> Function() chamada) async {
  try {
    await chamada();
  } on DioException catch (erro) {
    return erro;
  }
  fail('A chamada deveria ter falhado com DioException.');
}

void main() {
  group('mesmaOrigem', () {
    final base = Uri.parse('http://127.0.0.1:8000');

    test('mesmo scheme, host e porta', () {
      expect(mesmaOrigem(Uri.parse('http://127.0.0.1:8000/x'), base), isTrue);
    });

    test('host, porta ou scheme diferentes não são a mesma origem', () {
      expect(
        mesmaOrigem(Uri.parse('http://outro.exemplo:8000/x'), base),
        isFalse,
      );
      expect(mesmaOrigem(Uri.parse('http://127.0.0.1:9000/x'), base), isFalse);
      expect(mesmaOrigem(Uri.parse('https://127.0.0.1:8000/x'), base), isFalse);
    });
  });

  group('InterceptadorSessao', () {
    late ApiFalsa api;
    late ArmazenamentoTokenEmMemoria armazenamento;

    setUp(() {
      api = ApiFalsa();
      armazenamento = ArmazenamentoTokenEmMemoria();
      api.responder(
        (uri) => uri.path == _rotaAutenticada || uri.host == 'outro.exemplo',
        status: 200,
        corpo: const <String, Object?>{},
      );
    });

    Dio dioAutenticado([ArmazenamentoToken? armazenamentoUsado]) =>
        api.criarDioAutenticado(
          InterceptadorSessao(armazenamentoUsado ?? armazenamento),
        );

    String? authorizationDaUltima() =>
        api.requisicoesGravadas.last.cabecalho('Authorization');

    test('anexa Authorization: Token <chave> quando há token', () async {
      armazenamento.token = 't1';

      await dioAutenticado().get<Object?>(_rotaAutenticada);

      expect(authorizationDaUltima(), 'Token t1');
    });

    test('sem token, o pedido segue sem Authorization', () async {
      await dioAutenticado().get<Object?>(_rotaAutenticada);

      expect(authorizationDaUltima(), isNull);
    });

    test('o Dio público nunca envia Authorization, mesmo com token', () async {
      armazenamento.token = 't1';

      await api.criarDio().get<Object?>(_rotaAutenticada);

      expect(authorizationDaUltima(), isNull);
    });

    test('pedido para outra origem não leva Authorization', () async {
      armazenamento.token = 't1';

      await dioAutenticado().get<Object?>('http://outro.exemplo:8000/x');

      expect(api.requisicoesGravadas.last.uri.host, 'outro.exemplo');
      expect(authorizationDaUltima(), isNull);
    });

    test('Authorization posto à mão para outra origem é removido', () async {
      armazenamento.token = 't1';

      await dioAutenticado().get<Object?>(
        'http://outro.exemplo:8000/x',
        options: Options(headers: {'Authorization': 'Token roubado'}),
      );

      expect(authorizationDaUltima(), isNull);
    });

    test(
      '401 com o token atual apaga o token e vira SessaoExpiradaException',
      () async {
        armazenamento.token = 't1';
        api.responder((uri) => uri.path == '/api/401/', status: 401);

        final erro = await _falhaDe(
          () => dioAutenticado().get<Object?>('/api/401/'),
        );

        expect(erro.error, isA<SessaoExpiradaException>());
        expect(armazenamento.token, isNull);
      },
    );

    test('401 atrasado de um token antigo não apaga o token novo', () async {
      final lenta = ApiFalsa(latencia: const Duration(milliseconds: 120));
      lenta.responder((uri) => uri.path == '/api/401/', status: 401);
      armazenamento.token = 't1';
      final dio = lenta.criarDioAutenticado(InterceptadorSessao(armazenamento));

      final futuro = _falhaDe(() => dio.get<Object?>('/api/401/'));
      // O pedido já leu 't1' e está esperando a resposta quando o login novo
      // guarda 't2'.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await armazenamento.salvar('t2');
      final erro = await futuro;

      expect(erro.error, isA<SessaoExpiradaException>());
      expect(armazenamento.token, 't2');
    });

    test('PlatformException ao apagar não impede a falha tipada', () async {
      final falso = _ArmazenamentoFalso();
      when(() => falso.ler()).thenAnswer((_) async => 't1');
      when(() => falso.apagar()).thenThrow(PlatformException(code: 'falhou'));
      api.responder((uri) => uri.path == '/api/401/', status: 401);

      final erro = await _falhaDe(
        () => dioAutenticado(falso).get<Object?>('/api/401/'),
      );

      expect(erro.error, isA<SessaoExpiradaException>());
      verify(() => falso.apagar()).called(1);
    });

    test('500 passa sem SessaoExpiradaException e sem apagar o token',
        () async {
      armazenamento.token = 't1';
      api.responder((uri) => uri.path == '/api/500/', status: 500);

      final erro = await _falhaDe(
        () => dioAutenticado().get<Object?>('/api/500/'),
      );

      expect(erro.error, isNot(isA<SessaoExpiradaException>()));
      expect(erro.response?.statusCode, 500);
      expect(armazenamento.token, 't1');
    });

    test(
      'construirDioAutenticado: sem redirecionamento, base e timeouts do '
      'Dio público',
      () {
        final dio = construirDioAutenticado(
          urlBase: urlBaseApiFalsa,
          interceptador: InterceptadorSessao(armazenamento),
        );

        expect(dio.options.followRedirects, isFalse);
        expect(dio.options.baseUrl, urlBaseApiFalsa);
        expect(dio.options.connectTimeout, const Duration(seconds: 10));
        expect(dio.options.receiveTimeout, const Duration(seconds: 10));
        expect(dio.interceptors.whereType<InterceptadorSessao>(), hasLength(1));
      },
    );
  });

  group('registro no DI de produção', () {
    setUp(() async {
      await configureDependencies();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('o Dio público não tem InterceptadorSessao nem log', () {
      final dio = getIt<Dio>();

      expect(dio.interceptors.whereType<InterceptadorSessao>(), isEmpty);
      expect(dio.interceptors.whereType<LogInterceptor>(), isEmpty);
    });

    test(
      'o Dio autenticado tem exatamente um InterceptadorSessao e não segue '
      'redirecionamento',
      () {
        final dio = getIt<Dio>(instanceName: 'autenticado');

        expect(dio.interceptors.whereType<InterceptadorSessao>(), hasLength(1));
        expect(dio.interceptors.whereType<LogInterceptor>(), isEmpty);
        expect(dio.options.followRedirects, isFalse);
        expect(identical(dio, getIt<Dio>()), isFalse);
      },
    );

    test('ArmazenamentoToken de produção é o seguro', () {
      expect(getIt<ArmazenamentoToken>(), isA<ArmazenamentoTokenSeguro>());
    });
  });
}
