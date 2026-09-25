import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/consulta_imoveis.dart';

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const indaiatuba = Cidade(nome: 'Indaiatuba', uf: 'SP');

  ImovelMockDataSource construir() =>
      ImovelMockDataSource.paraTeste(linhas: linhasAcervoFixture());

  test(
    'buscar(Campinas) devolve só as linhas de Campinas, mais recente '
    'primeiro (criado_em desc)',
    () async {
      final datasource = construir();

      final envelope = await datasource.buscar(
        const ConsultaImoveis(cidade: campinas),
      );

      expect(envelope.results.map((modelo) => modelo.id).toList(), [42, 57]);
      expect(envelope.next, isNull);
      expect(envelope.previous, isNull);
    },
  );

  test(
    'buscar(Indaiatuba) devolve resultados vazios — cidade atendida sem '
    'imóveis na fixture (D-15)',
    () async {
      final datasource = construir();

      final envelope = await datasource.buscar(
        const ConsultaImoveis(cidade: indaiatuba),
      );

      expect(envelope.results, isEmpty);
    },
  );

  test(
    'a resposta atravessa o parsing real de ImoveisEnvelopeModel.fromJson '
    '(forma do contrato, incl. campos PENDENTE E2)',
    () async {
      final datasource = construir();

      final envelope = await datasource.buscar(
        const ConsultaImoveis(cidade: campinas),
      );

      final apartamento = envelope.results.firstWhere(
        (modelo) => modelo.id == 42,
      );
      expect(apartamento.titulo, 'Apartamento 2 quartos no Cambuí');
      expect(apartamento.finalidade, 'VENDA');
      expect(apartamento.cidade.nome, 'Campinas');
      expect(apartamento.cidade.uf, 'SP');
      expect(apartamento.natureza, 'APARTAMENTO');
      expect(apartamento.quartos, 2);
    },
  );

  test(
    'paraTeste com latência configurada respeita o atraso informado',
    () async {
      final datasource = ImovelMockDataSource.paraTeste(
        linhas: linhasAcervoFixture(),
        latencia: const Duration(milliseconds: 20),
      );

      final cronometro = Stopwatch()..start();
      await datasource.buscar(const ConsultaImoveis(cidade: campinas));
      cronometro.stop();

      expect(cronometro.elapsedMilliseconds, greaterThanOrEqualTo(20));
    },
  );

  test(
    'seguir lança FormatException — paginação chega numa fase seguinte',
    () {
      final datasource = construir();

      expect(() => datasource.seguir('cursor-qualquer'), throwsFormatException);
    },
  );
}
