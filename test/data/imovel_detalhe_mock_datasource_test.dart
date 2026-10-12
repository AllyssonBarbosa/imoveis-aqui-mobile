import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_detalhe_mock_datasource.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';

/// Servidor simulado do detalhe (DET-01, API-06, D-17): cada linha do acervo
/// da lista abre um detalhe coerente com o card, derivado das MESMAS linhas
/// (`linhasAcervoFixture()`), nunca de uma lista paralela (A8). Os ids
/// reservados 338/339 provam à mão os fluxos de falha e de 404.
void main() {
  const camposComuns = [
    'titulo',
    'finalidade',
    'preco_venda',
    'preco_aluguel',
    'descricao',
    'bairro',
    'cidade',
    'caracteristicas',
    'natureza',
  ];

  List<Map<String, Object?>> linhasPublicadas() => linhasAcervoFixture()
      .where((linha) => linha['id'] != idDetalheDespublicadoMock)
      .toList();

  ImovelDetalheMockDataSource construir() =>
      ImovelDetalheMockDataSource.paraTeste(detalhes: detalhesAcervoFixture());

  List<Map<String, Object?>> fotosDe(Map<String, Object?> detalhe) =>
      (detalhe['fotos']! as List<Object?>).cast<Map<String, Object?>>();

  group('ids reservados (D-15 da Fase 2, D-17)', () {
    test('339 e 338 são o último e o penúltimo card de Vinhedo', () {
      expect(idDetalheDespublicadoMock, 339);
      expect(idDetalheFalhaMock, 338);
      final vinhedo = linhasAcervoFixture()
          .where(
            (l) => (l['cidade']! as Map<String, Object?>)['nome'] == 'Vinhedo',
          )
          .toList();
      final porRecencia = [...vinhedo]
        ..sort(
          (a, b) =>
              (b['criado_em']! as String).compareTo(a['criado_em']! as String),
        );
      expect(porRecencia.last['id'], idDetalheDespublicadoMock);
      expect(porRecencia[porRecencia.length - 2]['id'], idDetalheFalhaMock);
    });

    test('339 não tem detalhe e responde 404', () async {
      expect(detalhesAcervoFixture().containsKey(339), isFalse);
      await expectLater(
        construir().buscarDetalhe(idDetalheDespublicadoMock),
        throwsA(isA<ImovelNaoEncontradoException>()),
      );
    });

    test('338 tem detalhe no servidor, mas sempre falha', () async {
      expect(detalhesAcervoFixture().containsKey(338), isTrue);
      final dataSource = construir();
      for (var i = 0; i < 2; i++) {
        await expectLater(
          dataSource.buscarDetalhe(idDetalheFalhaMock),
          throwsA(isA<FalhaSimuladaDoMock>()),
        );
      }
    });

    test('id inexistente (99999) responde 404', () async {
      await expectLater(
        construir().buscarDetalhe(99999),
        throwsA(isA<ImovelNaoEncontradoException>()),
      );
    });
  });

  group('consistência lista <-> detalhe (DET-01, DET-02)', () {
    test('toda linha publicada tem detalhe com os campos comuns iguais', () {
      final detalhes = detalhesAcervoFixture();
      final linhas = linhasPublicadas();
      expect(linhas, isNotEmpty);
      for (final linha in linhas) {
        final id = linha['id']! as int;
        final detalhe = detalhes[id];
        expect(detalhe, isNotNull, reason: 'sem detalhe para o id $id');
        expect(detalhe!['id'], id);
        for (final campo in camposComuns) {
          expect(
            detalhe[campo],
            linha[campo],
            reason: 'detalhe $id diverge da lista em "$campo"',
          );
        }
      }
    });

    test('só o id despublicado fica de fora (nenhum detalhe extra)', () {
      final idsDetalhe = detalhesAcervoFixture().keys.toSet();
      final idsLista = linhasPublicadas().map((l) => l['id']! as int).toSet();
      expect(idsDetalhe, idsLista);
    });

    test('fotos vazias exatamente quando o card não tem capa; senão a '
        'primeira é a capa do card', () {
      final detalhes = detalhesAcervoFixture();
      for (final linha in linhasPublicadas()) {
        final id = linha['id']! as int;
        final fotos = fotosDe(detalhes[id]!);
        final capa = linha['foto_capa'] as String?;
        if (capa == null) {
          expect(fotos, isEmpty, reason: 'detalhe $id deveria ter 0 fotos');
          continue;
        }
        expect(fotos, isNotEmpty, reason: 'detalhe $id sem fotos');
        expect(fotos.first['url'], capa, reason: 'capa do detalhe $id');
        expect(fotos.first['capa'], isTrue);
        expect(
          fotos.where((f) => f['capa'] == true),
          hasLength(1),
          reason: 'detalhe $id deve ter exatamente uma capa',
        );
        final ordens = [for (final f in fotos) f['ordem']! as int];
        for (var i = 1; i < ordens.length; i++) {
          expect(
            ordens[i],
            greaterThan(ordens[i - 1]),
            reason: 'ordem das fotos do detalhe $id não é crescente',
          );
        }
      }
    });

    test(
      'o mock devolve o mesmo que o card mostra, via parsing real',
      () async {
        final dataSource = construir();
        for (final linha in linhasPublicadas()) {
          final id = linha['id']! as int;
          if (id == idDetalheFalhaMock) continue;
          final detalhe = (await dataSource.buscarDetalhe(id)).paraEntidade();
          expect(detalhe.id, id);
          expect(detalhe.titulo, linha['titulo']);
          expect(detalhe.descricao, linha['descricao']);
          expect(detalhe.bairro, linha['bairro']);
          expect(detalhe.caracteristicas, linha['caracteristicas']);
        }
      },
    );
  });

  group('determinismo (D-15 da Fase 2)', () {
    test('duas chamadas devolvem mapas profundamente iguais', () {
      expect(detalhesAcervoFixture(), equals(detalhesAcervoFixture()));
    });

    test('o detalhe 42 continua sendo o exemplo do §11, intocado', () {
      final detalhe = detalhesAcervoFixture()[42]!;
      expect(detalhe['titulo'], 'Apartamento 2 quartos no Cambuí');
      expect(
        (detalhe['corretor']! as Map<String, Object?>)['slug'],
        'marina-lopes',
      );
      expect(fotosDe(detalhe), hasLength(3));
      expect(detalhe['apartamento'], isNotNull);
    });
  });

  group('cobertura de casos (a tela precisa de cada um)', () {
    late Map<int, Map<String, Object?>> detalhes;

    setUp(() => detalhes = detalhesAcervoFixture());

    test('há detalhe sem fotos e detalhe com exatamente uma foto', () {
      expect(detalhes.values.where((d) => fotosDe(d).isEmpty), isNotEmpty);
      expect(detalhes.values.where((d) => fotosDe(d).length == 1), isNotEmpty);
    });

    test('há detalhe com mais de uma foto', () {
      expect(detalhes.values.where((d) => fotosDe(d).length > 1), isNotEmpty);
    });

    test('há detalhe sem corretor', () {
      expect(detalhes.values.where((d) => d['corretor'] == null), isNotEmpty);
    });

    test('há detalhe com corretor sem foto e sem slug (PENDENTE E2)', () {
      final corretores = detalhes.values
          .map((d) => d['corretor'])
          .whereType<Map<String, Object?>>();
      expect(
        corretores.where((c) => c['foto'] == null && c['slug'] == null),
        isNotEmpty,
      );
      expect(corretores.where((c) => c['slug'] != null), isNotEmpty);
    });

    test('há detalhe com preco_condominio e preco_iptu ambos nulos', () {
      expect(
        detalhes.values.where(
          (d) => d['preco_condominio'] == null && d['preco_iptu'] == null,
        ),
        isNotEmpty,
      );
    });

    test('há detalhe com preço de condomínio e IPTU preenchidos', () {
      expect(
        detalhes.values.where(
          (d) => d['preco_condominio'] != null && d['preco_iptu'] != null,
        ),
        isNotEmpty,
      );
    });

    test('há pelo menos um detalhe de cada natureza', () {
      final naturezas = detalhes.values.map((d) => d['natureza']).toSet();
      expect(
        naturezas,
        containsAll(['APARTAMENTO', 'CASA', 'TERRENO', 'LOTE']),
      );
    });

    test('todo detalhe gerado é parseável pelo Model real', () {
      for (final entrada in detalhes.entries) {
        expect(
          () => DetalheImovelModel.fromJson(entrada.value).paraEntidade(),
          returnsNormally,
          reason: 'detalhe ${entrada.key} não parseia',
        );
      }
    });
  });
}
