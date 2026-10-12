import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_detalhe_fixture.dart';
import 'package:imoveis_aqui/data/models/detalhe_imovel_model.dart';
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
}
