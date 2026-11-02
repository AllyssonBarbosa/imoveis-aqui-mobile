import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/opcoes_filtro_datasource.dart';
import 'package:imoveis_aqui/data/models/caracteristica_model.dart';
import 'package:imoveis_aqui/data/repositories/opcoes_filtro_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/caracteristica.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:mocktail/mocktail.dart';

class _OpcoesFiltroDataSourceFalso extends Mock
    implements OpcoesFiltroDataSource {}

void main() {
  late _OpcoesFiltroDataSourceFalso dataSource;
  late OpcoesFiltroRepositoryImpl repositorio;

  const campinas = Cidade(nome: 'Campinas', uf: 'SP');

  setUpAll(() {
    registerFallbackValue(campinas);
  });

  setUp(() {
    dataSource = _OpcoesFiltroDataSourceFalso();
    repositorio = OpcoesFiltroRepositoryImpl(dataSource);
  });

  group('bairrosDaCidade', () {
    test(
      'lista do datasource vira Result.success com a mesma lista',
      () async {
        when(
          () => dataSource.bairros(any()),
        ).thenAnswer((_) async => ['Cambuí', 'Taquaral']);

        final resultado = await repositorio.bairrosDaCidade(campinas);

        expect(resultado, isA<Success<List<String>>>());
        expect((resultado as Success<List<String>>).data, [
          'Cambuí',
          'Taquaral',
        ]);
        verify(() => dataSource.bairros(campinas)).called(1);
      },
    );

    test('Exception lançada pelo datasource vira Result.failure', () async {
      when(() => dataSource.bairros(any())).thenThrow(Exception('falhou'));

      final resultado = await repositorio.bairrosDaCidade(campinas);

      expect(resultado, isA<Failure<List<String>>>());
    });

    test('TypeError do datasource vira Failure com FormatException', () async {
      when(() => dataSource.bairros(any())).thenThrow(TypeError());

      final resultado = await repositorio.bairrosDaCidade(campinas);

      expect(resultado, isA<Failure<List<String>>>());
      expect(
        (resultado as Failure<List<String>>).erro,
        isA<FormatException>(),
      );
    });
  });

  group('caracteristicas', () {
    test(
      'modelos {id, nome} do datasource viram entidades Caracteristica na '
      'ordem recebida, sem re-ordenar (D-13, D-14)',
      () async {
        when(() => dataSource.caracteristicas()).thenAnswer(
          (_) async => const [
            CaracteristicaModel(id: 3, nome: 'Piscina'),
            CaracteristicaModel(id: 1, nome: 'Churrasqueira'),
          ],
        );

        final resultado = await repositorio.caracteristicas();

        expect(resultado, isA<Success<List<Caracteristica>>>());
        expect((resultado as Success<List<Caracteristica>>).data, const [
          Caracteristica(id: 3, nome: 'Piscina'),
          Caracteristica(id: 1, nome: 'Churrasqueira'),
        ]);
      },
    );

    test('Exception lançada pelo datasource vira Result.failure', () async {
      when(() => dataSource.caracteristicas()).thenThrow(Exception('falhou'));

      final resultado = await repositorio.caracteristicas();

      expect(resultado, isA<Failure<List<Caracteristica>>>());
    });

    test('TypeError do datasource vira Failure com FormatException', () async {
      when(() => dataSource.caracteristicas()).thenThrow(TypeError());

      final resultado = await repositorio.caracteristicas();

      expect(resultado, isA<Failure<List<Caracteristica>>>());
      expect(
        (resultado as Failure<List<Caracteristica>>).erro,
        isA<FormatException>(),
      );
    });
  });
}
