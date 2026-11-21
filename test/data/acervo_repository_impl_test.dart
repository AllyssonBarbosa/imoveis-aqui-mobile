import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/acervo_datasource.dart';
import 'package:imoveis_aqui/data/datasources/acervo_remote_datasource.dart';
import 'package:imoveis_aqui/data/models/acervo_envelope_model.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/data/repositories/acervo_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/consulta_acervo.dart';
import 'package:imoveis_aqui/domain/entities/pagina_acervo.dart';
import 'package:imoveis_aqui/domain/repositories/acervo_repository.dart';
import 'package:imoveis_aqui/domain/repositories/falhas_autenticacao.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_acervo_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';
import '../support/armazenamento_token_em_memoria.dart';

class _AcervoDataSourceFalso extends Mock implements AcervoDataSource {}

class _AcervoRepositoryFalso extends Mock implements AcervoRepository {}

class _FalhaDeTeste implements Exception {
  const _FalhaDeTeste();
}

RequestOptions _opcoes() => RequestOptions(path: '/api/imoveis/');

DioException _erroDio({int? status}) => DioException(
  requestOptions: _opcoes(),
  response: status == null
      ? null
      : Response<Object?>(requestOptions: _opcoes(), statusCode: status),
  type: status == null
      ? DioExceptionType.connectionTimeout
      : DioExceptionType.badResponse,
);

AcervoEnvelopeModel _envelope(String arquivo) => AcervoEnvelopeModel.fromJson(
  lerFixtureApi(arquivo)! as Map<String, Object?>,
);

Exception? _falhaDe(Result<PaginaAcervo> resultado) => switch (resultado) {
  Failure<PaginaAcervo>(:final erro) => erro,
  _ => null,
};

void main() {
  setUpAll(() => registerFallbackValue(const ConsultaAcervo()));

  group('AcervoRepositoryImpl', () {
    late _AcervoDataSourceFalso dataSource;
    late AcervoRepository repositorio;

    setUp(() {
      dataSource = _AcervoDataSourceFalso();
      repositorio = AcervoRepositoryImpl(dataSource);
    });

    test('buscar devolve a página de domínio com 20 itens e o next', () async {
      final envelope = _envelope('acervo_p1.json');
      when(() => dataSource.buscar(any())).thenAnswer((_) async => envelope);

      final resultado = await repositorio.buscar(const ConsultaAcervo());

      expect(resultado, isA<Success<PaginaAcervo>>());
      final pagina = (resultado as Success<PaginaAcervo>).data;
      expect(pagina.itens, hasLength(20));
      expect(pagina.proximaPagina, envelope.next);
    });

    test('seguir repassa o next à DataSource e devolve a página', () async {
      final p1 = _envelope('acervo_p1.json');
      when(() => dataSource.seguir(p1.next!))
          .thenAnswer((_) async => _envelope('acervo_p2.json'));

      final resultado = await repositorio.seguir(p1.next!);

      expect(resultado, isA<Success<PaginaAcervo>>());
      expect((resultado as Success<PaginaAcervo>).data.ehUltima, isTrue);
    });

    test('SessaoExpiradaException direta vira Failure com ela', () async {
      when(() => dataSource.buscar(any()))
          .thenThrow(const SessaoExpiradaException());

      final resultado = await repositorio.buscar(const ConsultaAcervo());

      expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
    });

    test('DioException com error SessaoExpiradaException vira Failure com '
        'ela', () async {
      when(() => dataSource.buscar(any())).thenThrow(
        _erroDio(status: 401).copyWith(error: const SessaoExpiradaException()),
      );

      final resultado = await repositorio.buscar(const ConsultaAcervo());

      expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
    });

    test('DioException 403 vira SemPermissaoException', () async {
      when(() => dataSource.buscar(any())).thenThrow(_erroDio(status: 403));

      final resultado = await repositorio.buscar(const ConsultaAcervo());

      expect(_falhaDe(resultado), isA<SemPermissaoException>());
    });

    test('DioException 500 segue como a própria DioException', () async {
      when(() => dataSource.buscar(any())).thenThrow(_erroDio(status: 500));

      final resultado = await repositorio.buscar(const ConsultaAcervo());

      expect(_falhaDe(resultado), isA<DioException>());
    });

    test('outra Exception passa como está', () async {
      when(() => dataSource.buscar(any())).thenThrow(const _FalhaDeTeste());

      final resultado = await repositorio.buscar(const ConsultaAcervo());

      expect(_falhaDe(resultado), isA<_FalhaDeTeste>());
    });

    test('TypeError do Model vira FormatException', () async {
      when(() => dataSource.buscar(any())).thenThrow(TypeError());

      final resultado = await repositorio.buscar(const ConsultaAcervo());

      expect(_falhaDe(resultado), isA<FormatException>());
    });

    test('FormatException da guarda de origem em seguir vira Failure com '
        'ela', () async {
      when(() => dataSource.seguir(any()))
          .thenThrow(const FormatException('origem diferente'));

      final resultado = await repositorio.seguir('http://outro.exemplo/x');

      expect(_falhaDe(resultado), isA<FormatException>());
    });

    test('finalidade desconhecida (FormatException do Model) vira Failure '
        'tipada, sem escapar', () async {
      final corpo = lerFixtureApi('acervo_p1.json')! as Map<String, Object?>;
      final itens = [
        for (final item in corpo['results']! as List<Object?>)
          Map<String, Object?>.of(item! as Map<String, Object?>),
      ];
      itens.first['finalidade'] = 'PERMUTA';
      final envelope = AcervoEnvelopeModel.fromJson({
        ...corpo,
        'results': itens,
      });
      when(() => dataSource.buscar(any())).thenAnswer((_) async => envelope);

      final resultado = await repositorio.buscar(const ConsultaAcervo());

      expect(_falhaDe(resultado), isA<FormatException>());
    });

    test('pilha real sem token: o 401 da ApiFalsa vira '
        'SessaoExpiradaException', () async {
      final api = ApiFalsa();
      final real = AcervoRepositoryImpl(
        AcervoRemoteDataSource(
          api.criarDioAutenticado(
            InterceptadorSessao(ArmazenamentoTokenEmMemoria()),
          ),
        ),
      );

      final resultado = await real.buscar(const ConsultaAcervo());

      expect(_falhaDe(resultado), isA<SessaoExpiradaException>());
    });
  });

  group('BuscarAcervoUseCase', () {
    late _AcervoRepositoryFalso repositorio;
    late BuscarAcervoUseCase useCase;

    setUp(() {
      repositorio = _AcervoRepositoryFalso();
      useCase = BuscarAcervoUseCase(repositorio);
    });

    test('call repassa a consulta ao repositório e devolve o mesmo '
        'Result', () async {
      final esperado = Result<PaginaAcervo>.success(PaginaAcervo(itens: []));
      const consulta = ConsultaAcervo(busca: 'casa');
      when(() => repositorio.buscar(consulta))
          .thenAnswer((_) async => esperado);

      final resultado = await useCase(consulta);

      expect(resultado, same(esperado));
    });

    test('seguir repassa o cursor ao repositório e devolve o mesmo '
        'Result', () async {
      final esperado = Result<PaginaAcervo>.failure(const _FalhaDeTeste());
      when(() => repositorio.seguir('proxima'))
          .thenAnswer((_) async => esperado);

      final resultado = await useCase.seguir('proxima');

      expect(resultado, same(esperado));
    });
  });
}
