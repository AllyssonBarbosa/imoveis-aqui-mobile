import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
import 'package:imoveis_aqui/data/models/imovel_model.dart';
import 'package:imoveis_aqui/data/models/url_segura.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';

/// Contrato de parse de `DetalheImovelModel` (DET-06, T-04-03-01): um campo
/// obrigatório ausente é `TypeError` (que o repositório traduz), valores
/// desconhecidos de enum são tratados na `paraEntidade()`.
void main() {
  Map<String, Object?> mapaCompleto() =>
      Map<String, Object?>.of(detalhesAcervoFixture()[42]!);

  test('mapa completo do contrato é lido e mapeado para a entidade', () {
    final detalhe = DetalheImovelModel.fromJson(mapaCompleto()).paraEntidade();

    expect(detalhe.id, 42);
    expect(detalhe.titulo, 'Apartamento 2 quartos no Cambuí');
    expect(detalhe.finalidade, FinalidadeImovel.venda);
    expect(detalhe.fotos, isNotEmpty);
    expect(detalhe.caracteristicas, isNotEmpty);
  });

  test('mapa sem titulo lança TypeError em fromJson', () {
    final mapa = mapaCompleto()..remove('titulo');

    expect(() => DetalheImovelModel.fromJson(mapa), throwsA(isA<TypeError>()));
  });

  test('finalidade PERMUTA faz paraEntidade lançar FormatException', () {
    final mapa = mapaCompleto()..['finalidade'] = 'PERMUTA';
    final modelo = DetalheImovelModel.fromJson(mapa);

    expect(modelo.paraEntidade, throwsA(isA<FormatException>()));
  });

  test('natureza CHALE (desconhecida) vira null', () {
    final mapa = mapaCompleto()..['natureza'] = 'CHALE';

    final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

    expect(detalhe.natureza, isNull);
  });

  test('fotos e caracteristicas ausentes viram listas vazias', () {
    final mapa = mapaCompleto()
      ..remove('fotos')
      ..remove('caracteristicas');

    final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

    expect(detalhe.fotos, isEmpty);
    expect(detalhe.caracteristicas, isEmpty);
  });

  group('URLs seguras (DET-02, segurança V12/V13)', () {
    group('urlHttpOuNula', () {
      test('http e https passam sem alteração', () {
        expect(urlHttpOuNula('https://a.b/c.jpg'), 'https://a.b/c.jpg');
        expect(urlHttpOuNula('http://a.b/c.jpg'), 'http://a.b/c.jpg');
      });

      test('qualquer outro esquema, relativo, vazio ou nulo vira null', () {
        expect(urlHttpOuNula('javascript:alert(1)'), isNull);
        expect(urlHttpOuNula('file:///etc/passwd'), isNull);
        expect(urlHttpOuNula('/media/x.jpg'), isNull);
        expect(urlHttpOuNula('ftp://a.b/c.jpg'), isNull);
        expect(urlHttpOuNula('data:image/png;base64,AAAA'), isNull);
        expect(urlHttpOuNula('https://'), isNull);
        expect(urlHttpOuNula(''), isNull);
        expect(urlHttpOuNula(null), isNull);
      });

      test('espaços ao redor são aparados antes de validar', () {
        expect(urlHttpOuNula('  https://a.b/c.jpg '), 'https://a.b/c.jpg');
        expect(urlHttpOuNula('  javascript:x '), isNull);
      });
    });

    test(
      'DetalheImovelModel descarta fotos inseguras sem reordenar as demais',
      () {
        final mapa = mapaCompleto()
          ..['fotos'] = [
            {'url': 'https://a.b/A.jpg', 'capa': true, 'ordem': 0},
            {'url': 'javascript:alert(1)', 'capa': false, 'ordem': 1},
            {'url': 'https://a.b/C.jpg', 'capa': false, 'ordem': 2},
          ];

        final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

        expect(detalhe.fotos.map((f) => f.url), [
          'https://a.b/A.jpg',
          'https://a.b/C.jpg',
        ]);
      },
    );

    test('DetalheImovelModel zera a foto do corretor fora de http(s)', () {
      final mapa = mapaCompleto()
        ..['corretor'] = {
          'id': 7,
          'nome': 'Marina Lopes',
          'foto': 'file:///x',
          'slug': 'marina-lopes',
        };

      final detalhe = DetalheImovelModel.fromJson(mapa).paraEntidade();

      expect(detalhe.corretor?.foto, isNull);
      expect(detalhe.corretor?.nome, 'Marina Lopes');
    });

    test('DetalheImovelModel mantém a foto https do corretor', () {
      final detalhe = DetalheImovelModel.fromJson(mapaCompleto())
          .paraEntidade();

      expect(detalhe.corretor?.foto, startsWith('https://'));
    });

    test('ImovelModel descarta a capa da lista com esquema inseguro', () {
      final linha = Map<String, Object?>.of(linhasAcervoFixture().first)
        ..['foto_capa'] = 'javascript:x';

      final imovel = ImovelModel.fromJson(linha).paraEntidade();

      expect(imovel.fotoCapa, isNull);
    });

    test('ImovelModel mantém a capa https', () {
      final linha = Map<String, Object?>.of(linhasAcervoFixture().first)
        ..['foto_capa'] = 'https://a.b/capa.jpg';

      final imovel = ImovelModel.fromJson(linha).paraEntidade();

      expect(imovel.fotoCapa, 'https://a.b/capa.jpg');
    });
  });
}
