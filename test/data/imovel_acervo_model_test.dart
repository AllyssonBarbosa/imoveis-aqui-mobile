import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/acervo_envelope_model.dart';
import 'package:imoveis_aqui/data/models/imovel_acervo_model.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';

import '../support/api_falsa.dart';

Map<String, Object?> _fixture(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

Map<String, Object?> _primeiroItem(String nome) =>
    ((_fixture(nome)['results']! as List<Object?>).first!
        as Map<String, Object?>);

/// Cópia do primeiro item de `acervo_busca.json` com chaves trocadas.
Map<String, Object?> _itemCom(Map<String, Object?> alteracoes) => {
  ..._primeiroItem('acervo_busca.json'),
  ...alteracoes,
};

void main() {
  group('AcervoEnvelopeModel.paraPagina', () {
    test('a primeira página tem 20 itens e o next capturado', () {
      final bruto = _fixture('acervo_p1.json');
      final pagina = AcervoEnvelopeModel.fromJson(bruto).paraPagina();

      expect(pagina.itens, hasLength(20));
      expect(pagina.proximaPagina, bruto['next']);
      expect(pagina.proximaPagina, 'http://127.0.0.1:8000/api/imoveis/?page=2');
      expect(pagina.ehUltima, isFalse);
    });

    test('a segunda página tem 16 itens e é a última', () {
      final pagina = AcervoEnvelopeModel.fromJson(_fixture('acervo_p2.json'))
          .paraPagina();

      expect(pagina.itens, hasLength(16));
      expect(pagina.proximaPagina, isNull);
    });

    test('a situação sem resultado é uma página vazia', () {
      final pagina = AcervoEnvelopeModel.fromJson(
        _fixture('acervo_situacao_vazia.json'),
      ).paraPagina();

      expect(pagina.itens, isEmpty);
      expect(pagina.proximaPagina, isNull);
    });
  });

  group('ImovelAcervoModel.paraEntidade com as fixtures', () {
    test('o imóvel de outra empresa traz vendido e fora da vitrine', () {
      final item = AcervoEnvelopeModel.fromJson(
        _fixture('acervo_outra_empresa.json'),
      ).paraPagina().itens.single;

      expect(item.codigo, 'DEMO-CASA-01');
      expect(item.situacao, SituacaoImovel.vendido);
      expect(item.naVitrine, isFalse);
      expect(item.meuImovel, isTrue);
      expect(item.finalidade, FinalidadeImovel.venda);
      expect(item.precoVenda, '350000.00');
      expect(item.precoAluguel, isNull);
      expect(item.fotoCapa, isNull);
    });

    test('o imóvel da busca não é "meu" (corretor desativado)', () {
      final item = AcervoEnvelopeModel.fromJson(_fixture('acervo_busca.json'))
          .paraPagina()
          .itens
          .single;

      expect(item.codigo, 'DEV-CAMPINAS-14');
      expect(item.meuImovel, isFalse);
      expect(item.naVitrine, isTrue);
      expect(item.finalidade, FinalidadeImovel.aluguel);
      expect(item.precoAluguel, '2550.00');
      expect(
        item.fotoCapa,
        'http://127.0.0.1:8000/media/imoveis/fotos/dev-campinas-14-1.jpg',
      );
    });
  });

  group('ImovelAcervoModel defensivo (T-08-31, T-08-33)', () {
    test('mapeia as quatro situações conhecidas', () {
      const esperado = {
        'DISPONIVEL': SituacaoImovel.disponivel,
        'RESERVADO': SituacaoImovel.reservado,
        'VENDIDO': SituacaoImovel.vendido,
        'ALUGADO': SituacaoImovel.alugado,
      };

      for (final par in esperado.entries) {
        final modelo = ImovelAcervoModel.fromJson(
          _itemCom({'situacao': par.key}),
        );

        expect(modelo.paraEntidade().situacao, par.value, reason: par.key);
      }
    });

    test('situação desconhecida ou nula vira null, sem quebrar', () {
      expect(
        ImovelAcervoModel.fromJson(_itemCom({'situacao': 'XYZ'}))
            .paraEntidade()
            .situacao,
        isNull,
      );
      expect(
        ImovelAcervoModel.fromJson(_itemCom({'situacao': null}))
            .paraEntidade()
            .situacao,
        isNull,
      );
    });

    test('finalidade desconhecida lança FormatException', () {
      final modelo = ImovelAcervoModel.fromJson(
        _itemCom({'finalidade': 'TROCA'}),
      );

      expect(modelo.paraEntidade, throwsFormatException);
    });

    test('mapeia as três finalidades conhecidas', () {
      const esperado = {
        'VENDA': FinalidadeImovel.venda,
        'ALUGUEL': FinalidadeImovel.aluguel,
        'VENDA_E_ALUGUEL': FinalidadeImovel.vendaEAluguel,
      };

      for (final par in esperado.entries) {
        final modelo = ImovelAcervoModel.fromJson(
          _itemCom({'finalidade': par.key}),
        );

        expect(modelo.paraEntidade().finalidade, par.value, reason: par.key);
      }
    });

    test('foto_capa com esquema hostil vira null', () {
      final modelo = ImovelAcervoModel.fromJson(
        _itemCom({'foto_capa': 'javascript:alert(1)'}),
      );

      expect(modelo.paraEntidade().fotoCapa, isNull);
    });

    test('meu_imovel e na_vitrine são só lidos, sem dedução local', () {
      final entidade = ImovelAcervoModel.fromJson(
        _itemCom({
          'meu_imovel': false,
          'na_vitrine': false,
          'situacao': 'DISPONIVEL',
        }),
      ).paraEntidade();

      expect(entidade.meuImovel, isFalse);
      expect(entidade.naVitrine, isFalse);
    });
  });
}
