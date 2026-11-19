import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/perfil_datasource.dart';
import 'package:imoveis_aqui/data/models/perfil_corretor_model.dart';
import 'package:imoveis_aqui/data/repositories/perfil_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/perfil_corretor.dart';
import 'package:imoveis_aqui/domain/repositories/perfil_repository.dart';
import 'package:mocktail/mocktail.dart';

class _PerfilDataSourceFalso extends Mock implements PerfilDataSource {}

/// Falha de teste local: qualquer exceção que não seja 404 vira `Failure`.
class _FalhaDeTeste implements Exception {
  const _FalhaDeTeste();
}

RequestOptions _opcoes() => RequestOptions(path: '/api/publico/corretores/7/');

DioException _erroDio({int? status}) => DioException(
  requestOptions: _opcoes(),
  response: status == null
      ? null
      : Response<Object?>(requestOptions: _opcoes(), statusCode: status),
  type: status == null
      ? DioExceptionType.connectionTimeout
      : DioExceptionType.badResponse,
);

void main() {
  late _PerfilDataSourceFalso dataSource;
  late PerfilRepository repositorio;

  setUp(() {
    dataSource = _PerfilDataSourceFalso();
    repositorio = PerfilRepositoryImpl(dataSource);
  });

  Exception? falhaDe(Result<PerfilCorretor> resultado) => switch (resultado) {
    Failure<PerfilCorretor>(:final erro) => erro,
    _ => null,
  };

  test('sucesso devolve a entidade normalizada pelo Model', () async {
    when(() => dataSource.buscarCorretor(7)).thenAnswer(
      (_) async => const PerfilCorretorModel(
        id: 7,
        nome: 'Marina Lopes',
        telefone: '  ',
        foto: 'javascript:alert(1)',
      ),
    );

    final resultado = await repositorio.buscarCorretor(7);

    expect(resultado, isA<Success<PerfilCorretor>>());
    final perfil = (resultado as Success<PerfilCorretor>).data;
    expect(perfil.nome, 'Marina Lopes');
    expect(perfil.telefone, isNull);
    expect(perfil.foto, isNull);
  });

  test('PerfilNaoEncontradoException vira Failure com ela', () async {
    when(() => dataSource.buscarCorretor(7))
        .thenThrow(const PerfilNaoEncontradoException());

    final resultado = await repositorio.buscarCorretor(7);

    expect(falhaDe(resultado), isA<PerfilNaoEncontradoException>());
  });

  test('DioException 404 vira PerfilNaoEncontradoException', () async {
    when(() => dataSource.buscarCorretor(7)).thenThrow(_erroDio(status: 404));

    final resultado = await repositorio.buscarCorretor(7);

    expect(falhaDe(resultado), isA<PerfilNaoEncontradoException>());
  });

  test('DioException 500 segue como a própria DioException', () async {
    when(() => dataSource.buscarCorretor(7)).thenThrow(_erroDio(status: 500));

    final resultado = await repositorio.buscarCorretor(7);

    expect(falhaDe(resultado), isA<DioException>());
  });

  test('DioException sem resposta (timeout) segue como DioException', () async {
    when(() => dataSource.buscarCorretor(7)).thenThrow(_erroDio());

    final resultado = await repositorio.buscarCorretor(7);

    expect(falhaDe(resultado), isA<DioException>());
  });

  test('TypeError do fromJson vira FormatException', () async {
    when(() => dataSource.buscarCorretor(7)).thenAnswer(
      (_) async => PerfilCorretorModel.fromJson(<String, Object?>{'id': 7}),
    );

    final resultado = await repositorio.buscarCorretor(7);

    expect(falhaDe(resultado), isA<FormatException>());
  });

  test('qualquer outra Exception vira Failure com ela', () async {
    when(() => dataSource.buscarCorretor(7)).thenThrow(const _FalhaDeTeste());

    final resultado = await repositorio.buscarCorretor(7);

    expect(falhaDe(resultado), isA<_FalhaDeTeste>());
  });
}
