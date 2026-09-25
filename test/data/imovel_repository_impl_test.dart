import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/imovel_datasource.dart';
import 'package:imoveis_aqui/data/models/imoveis_envelope_model.dart';
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';
import 'package:imoveis_aqui/domain/entities/pagina_imoveis.dart';
import 'package:mocktail/mocktail.dart';

class _ImovelDataSourceFalso extends Mock implements ImovelDataSource {}

const _linhaValida = {
  'id': 42,
  'titulo': 'Apartamento 2 quartos no Cambuí',
  'finalidade': 'VENDA',
  'preco_venda': '450000.00',
  'preco_aluguel': null,
  'descricao': 'Apartamento reformado.',
  'bairro': 'Cambuí',
  'cidade': {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
  'foto_capa': null,
  'caracteristicas': <String>[],
  'criado_em': '2026-08-14T10:32:00Z',
  'natureza': 'APARTAMENTO',
  'quartos': 2,
  'suites': 1,
  'vagas': 1,
  'area': '68.50',
};

void main() {
  late _ImovelDataSourceFalso dataSource;
  late ImovelRepositoryImpl repositorio;

  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const consulta = ConsultaImoveis(cidade: campinas);

  setUpAll(() {
    registerFallbackValue(consulta);
  });

  setUp(() {
    dataSource = _ImovelDataSourceFalso();
    repositorio = ImovelRepositoryImpl(dataSource);
  });

  test(
    'buscarImoveis: envelope do datasource vira Result.success(PaginaImoveis) '
    'com entidades mapeadas e proximaPagina == envelope.next',
    () async {
      when(() => dataSource.buscar(any())).thenAnswer(
        (_) async => ImoveisEnvelopeModel.fromJson({
          'next': 'https://api.exemplo.com/imoveis?cursor=abc',
          'previous': null,
          'results': [_linhaValida],
        }),
      );

      final resultado = await repositorio.buscarImoveis(consulta);

      expect(resultado, isA<Success<PaginaImoveis>>());
      final pagina = (resultado as Success<PaginaImoveis>).data;
      expect(pagina.itens, hasLength(1));
      expect(pagina.itens.single.id, 42);
      expect(pagina.itens.single.titulo, 'Apartamento 2 quartos no Cambuí');
      expect(
        pagina.proximaPagina,
        'https://api.exemplo.com/imoveis?cursor=abc',
      );
    },
  );

  test(
    'buscarImoveis: Exception lançada pelo datasource vira Result.failure',
    () async {
      when(() => dataSource.buscar(any())).thenThrow(Exception('falhou'));

      final resultado = await repositorio.buscarImoveis(consulta);

      expect(resultado, isA<Failure<PaginaImoveis>>());
    },
  );

  test(
    'buscarImoveis: finalidade desconhecida vira FormatException -> '
    'Result.failure (T-02-01-01)',
    () async {
      when(() => dataSource.buscar(any())).thenAnswer(
        (_) async => ImoveisEnvelopeModel.fromJson({
          'next': null,
          'previous': null,
          'results': [
            {..._linhaValida, 'finalidade': 'DESCONHECIDA'},
          ],
        }),
      );

      final resultado = await repositorio.buscarImoveis(consulta);

      expect(resultado, isA<Failure<PaginaImoveis>>());
    },
  );

  test(
    'buscarProximaPagina: delega a datasource.seguir e mapeia igual a '
    'buscarImoveis',
    () async {
      when(() => dataSource.seguir(any())).thenAnswer(
        (_) async => ImoveisEnvelopeModel.fromJson({
          'next': null,
          'previous': null,
          'results': [_linhaValida],
        }),
      );

      final resultado = await repositorio.buscarProximaPagina('cursor-x');

      expect(resultado, isA<Success<PaginaImoveis>>());
      verify(() => dataSource.seguir('cursor-x')).called(1);
    },
  );
}
