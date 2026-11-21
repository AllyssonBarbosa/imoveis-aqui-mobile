import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/armazenamento_token.dart';
import 'package:imoveis_aqui/data/datasources/autenticacao_datasource.dart';
import 'package:imoveis_aqui/data/models/eu_model.dart';
import 'package:imoveis_aqui/data/repositories/autenticacao_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/papel.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:mocktail/mocktail.dart';

import '../support/armazenamento_token_em_memoria.dart';

class _DataSourceMock extends Mock implements AutenticacaoDataSource {}

class _ArmazenamentoMock extends Mock implements ArmazenamentoToken {}

/// `DioException` sintética com [status] e, opcionalmente, [cabecalhos].
DioException _erroHttp(int status, {Map<String, List<String>>? cabecalhos}) {
  final opcoes = RequestOptions(path: '/api/auth/login/');
  return DioException(
    requestOptions: opcoes,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: opcoes,
      statusCode: status,
      // Texto do servidor que NUNCA pode aparecer nas falhas do app.
      data: const {'detail': 'TEXTO-SECRETO-DO-SERVIDOR'},
      headers: Headers.fromMap(cabecalhos ?? const {}),
    ),
  );
}

DioException _erroDeTipo(DioExceptionType tipo) => DioException(
  requestOptions: RequestOptions(path: '/api/auth/login/'),
  type: tipo,
);

Exception _falha(Result<Object?> resultado) =>
    (resultado as Failure<Object?>).erro;

void main() {
  late _DataSourceMock datasource;
  late ArmazenamentoTokenEmMemoria armazenamento;
  late AutenticacaoRepositoryImpl repositorio;

  setUp(() {
    datasource = _DataSourceMock();
    armazenamento = ArmazenamentoTokenEmMemoria();
    repositorio = AutenticacaoRepositoryImpl(datasource, armazenamento);
  });

  void entrarFalhaCom(Object erro) {
    when(
      () => datasource.entrar(
        email: any(named: 'email'),
        senha: any(named: 'senha'),
      ),
    ).thenThrow(erro);
  }

  Future<Result<void>> entrar() =>
      repositorio.entrar(email: 'a@b.com', senha: 'x');

  group('entrar', () {
    test('sucesso salva só o token devolvido e devolve Success', () async {
      when(
        () => datasource.entrar(email: 'a@b.com', senha: 'x'),
      ).thenAnswer((_) async => 'token-novo');

      final resultado = await entrar();

      expect(resultado, isA<Success<void>>());
      expect(armazenamento.token, 'token-novo');
    });

    test('400 vira CredenciaisInvalidasException e nada é salvo', () async {
      entrarFalhaCom(_erroHttp(400));

      final resultado = await entrar();

      expect(_falha(resultado), isA<CredenciaisInvalidasException>());
      expect(armazenamento.token, isNull);
    });

    test('429 com retry-after: 120 traz aguardar de 120 s', () async {
      entrarFalhaCom(
        _erroHttp(
          429,
          cabecalhos: {
            'retry-after': ['120'],
          },
        ),
      );

      final falha = _falha(await entrar()) as LimiteTentativasException;

      expect(falha.aguardar, const Duration(seconds: 120));
    });

    test('429 sem retry-after, não numérico ou negativo traz aguardar nulo',
        () async {
      for (final valor in <List<String>?>[
        null,
        ['logo'],
        ['-5'],
        ['1.5'],
        [''],
      ]) {
        entrarFalhaCom(
          _erroHttp(
            429,
            cabecalhos: valor == null ? null : {'retry-after': valor},
          ),
        );

        final falha = _falha(await entrar()) as LimiteTentativasException;

        expect(falha.aguardar, isNull, reason: 'valor: $valor');
      }
    });

    test('retry-after hostil (enorme) é limitado a 24 h', () async {
      entrarFalhaCom(
        _erroHttp(
          429,
          cabecalhos: {
            'retry-after': ['9223372036854775807'],
          },
        ),
      );

      final falha = _falha(await entrar()) as LimiteTentativasException;

      expect(falha.aguardar, const Duration(days: 1));
    });

    test('esperaDoLimite lê o cabeçalho com espaços', () {
      final erro = _erroHttp(
        429,
        cabecalhos: {
          'retry-after': [' 3600 '],
        },
      );

      expect(esperaDoLimite(erro), const Duration(hours: 1));
    });

    test('403 vira SemPermissaoException', () async {
      entrarFalhaCom(_erroHttp(403));

      expect(_falha(await entrar()), isA<SemPermissaoException>());
    });

    test('DioException com SessaoExpiradaException vira SessaoExpirada',
        () async {
      entrarFalhaCom(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          response: Response<Object?>(
            requestOptions: RequestOptions(path: '/x'),
            statusCode: 401,
          ),
          error: const SessaoExpiradaException(),
        ),
      );

      expect(_falha(await entrar()), isA<SessaoExpiradaException>());
    });

    test('SessaoExpiradaException direta vira SessaoExpirada', () async {
      entrarFalhaCom(const SessaoExpiradaException());

      expect(_falha(await entrar()), isA<SessaoExpiradaException>());
    });

    test('timeouts, sem conexão, 500 e 404 viram FalhaDeConexaoException',
        () async {
      final erros = <DioException>[
        _erroDeTipo(DioExceptionType.connectionTimeout),
        _erroDeTipo(DioExceptionType.connectionError),
        _erroDeTipo(DioExceptionType.receiveTimeout),
        _erroHttp(500),
        _erroHttp(404),
      ];
      for (final erro in erros) {
        entrarFalhaCom(erro);

        expect(
          _falha(await entrar()),
          isA<FalhaDeConexaoException>(),
          reason: '$erro',
        );
      }
    });

    test('TypeError do fromJson vira FormatException', () async {
      entrarFalhaCom(TypeError());

      expect(_falha(await entrar()), isA<FormatException>());
    });

    test('FormatException da DataSource passa como está', () async {
      const original = FormatException('sem token');
      entrarFalhaCom(original);

      expect(_falha(await entrar()), same(original));
    });

    test('PlatformException ao salvar vira Failure', () async {
      final armazenamentoQuebrado = _ArmazenamentoMock();
      when(
        () => armazenamentoQuebrado.salvar(any()),
      ).thenThrow(PlatformException(code: 'falha'));
      when(
        () => datasource.entrar(email: 'a@b.com', senha: 'x'),
      ).thenAnswer((_) async => 'token');
      final repo = AutenticacaoRepositoryImpl(datasource, armazenamentoQuebrado);

      final resultado = await repo.entrar(email: 'a@b.com', senha: 'x');

      expect(_falha(resultado), isA<PlatformException>());
    });

    test('nenhuma falha traduzida carrega o texto do servidor', () async {
      final erros = <Object>[
        _erroHttp(400),
        _erroHttp(429),
        _erroHttp(403),
        _erroHttp(500),
        _erroHttp(401),
        _erroDeTipo(DioExceptionType.connectionTimeout),
      ];
      for (final erro in erros) {
        entrarFalhaCom(erro);

        final falha = _falha(await entrar());

        expect(falha.toString(), isNot(contains('SECRETO')));
        expect(falha.toString(), isNot(contains('a@b.com')));
      }
    });
  });

  group('obterPapel', () {
    test('devolve o Papel do EuModel', () async {
      when(
        () => datasource.obterEu(),
      ).thenAnswer((_) async => const EuModel(perfil: 'GESTOR'));

      final resultado = await repositorio.obterPapel();

      expect((resultado as Success<Papel>).data, Papel.gestor);
    });

    test('perfil desconhecido vira FormatException', () async {
      when(
        () => datasource.obterEu(),
      ).thenAnswer((_) async => const EuModel(perfil: 'DONO'));

      expect(_falha(await repositorio.obterPapel()), isA<FormatException>());
    });

    test('401 do interceptador vira SessaoExpiradaException', () async {
      when(() => datasource.obterEu()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/auth/eu/'),
          error: const SessaoExpiradaException(),
        ),
      );

      expect(
        _falha(await repositorio.obterPapel()),
        isA<SessaoExpiradaException>(),
      );
    });
  });

  group('sair', () {
    setUp(() => armazenamento.token = 'token-guardado');

    test('apaga o token quando a DataSource conclui', () async {
      when(() => datasource.sair()).thenAnswer((_) async {});

      await repositorio.sair();

      verify(() => datasource.sair()).called(1);
      expect(armazenamento.token, isNull);
    });

    test('apaga o token mesmo com DioException (rede, 500, 401)', () async {
      for (final erro in <DioException>[
        _erroDeTipo(DioExceptionType.connectionError),
        _erroDeTipo(DioExceptionType.receiveTimeout),
        _erroHttp(500),
        _erroHttp(401),
      ]) {
        armazenamento.token = 'token-guardado';
        when(() => datasource.sair()).thenThrow(erro);

        await repositorio.sair();

        expect(armazenamento.token, isNull, reason: '$erro');
      }
    });

    test('apaga o token mesmo com uma Exception qualquer', () async {
      when(() => datasource.sair()).thenThrow(Exception('estranho'));

      await repositorio.sair();

      expect(armazenamento.token, isNull);
    });

    test('apagar() lançando PlatformException: sair() não lança', () async {
      final armazenamentoQuebrado = _ArmazenamentoMock();
      when(
        () => armazenamentoQuebrado.apagar(),
      ).thenThrow(PlatformException(code: 'falha'));
      when(() => datasource.sair()).thenAnswer((_) async {});
      final repo = AutenticacaoRepositoryImpl(datasource, armazenamentoQuebrado);

      await repo.sair();

      verify(() => datasource.sair()).called(1);
      verify(() => armazenamentoQuebrado.apagar()).called(1);
    });

    test('DataSource e apagar() falhando juntos: sair() não lança', () async {
      final armazenamentoQuebrado = _ArmazenamentoMock();
      when(
        () => armazenamentoQuebrado.apagar(),
      ).thenThrow(PlatformException(code: 'falha'));
      when(
        () => datasource.sair(),
      ).thenThrow(_erroDeTipo(DioExceptionType.connectionError));
      final repo = AutenticacaoRepositoryImpl(datasource, armazenamentoQuebrado);

      await repo.sair();

      verify(() => datasource.sair()).called(1);
      verify(() => armazenamentoQuebrado.apagar()).called(1);
    });
  });

  group('sessão local', () {
    test('temSessaoGuardada só é verdadeiro com token não vazio', () async {
      expect(await repositorio.temSessaoGuardada(), isFalse);

      armazenamento.token = '';
      expect(await repositorio.temSessaoGuardada(), isFalse);

      armazenamento.token = 'abc';
      expect(await repositorio.temSessaoGuardada(), isTrue);
    });

    test('descartarSessaoLocal apaga o token', () async {
      armazenamento.token = 'abc';

      await repositorio.descartarSessaoLocal();

      expect(armazenamento.token, isNull);
    });

    test('descartarSessaoLocal com apagar() lançando não lança', () async {
      final armazenamentoQuebrado = _ArmazenamentoMock();
      when(
        () => armazenamentoQuebrado.apagar(),
      ).thenThrow(PlatformException(code: 'falha'));
      final repo = AutenticacaoRepositoryImpl(datasource, armazenamentoQuebrado);

      await repo.descartarSessaoLocal();

      verify(() => armazenamentoQuebrado.apagar()).called(1);
    });
  });
}
