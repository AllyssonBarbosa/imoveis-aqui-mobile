import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/contato_recebido_model.dart';
import 'package:imoveis_aqui/data/models/contatos_envelope_model.dart';
import 'package:imoveis_aqui/data/models/imovel_com_contato_model.dart';
import 'package:imoveis_aqui/data/models/resumo_contatos_model.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';

import '../support/api_falsa.dart';

Map<String, Object?> _fixture(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

Map<String, Object?> _primeiroItem(String nome) =>
    ((_fixture(nome)['results']! as List<Object?>).first!
        as Map<String, Object?>);

/// Cópia do primeiro item de `contatos_p1.json` com chaves trocadas.
Map<String, Object?> _itemCom(Map<String, Object?> alteracoes) => {
  ..._primeiroItem('contatos_p1.json'),
  ...alteracoes,
};

void main() {
  group('ContatosEnvelopeModel.paraPagina', () {
    test('a primeira página tem 20 itens e o next capturado', () {
      final bruto = _fixture('contatos_p1.json');
      final pagina = ContatosEnvelopeModel.fromJson(bruto).paraPagina();

      expect(pagina.itens, hasLength(20));
      expect(pagina.proximaPagina, bruto['next']);
      expect(pagina.ehUltima, isFalse);
    });

    test('a segunda página tem 5 itens e é a última', () {
      final pagina = ContatosEnvelopeModel.fromJson(
        _fixture('contatos_p2.json'),
      ).paraPagina();

      expect(pagina.itens, hasLength(5));
      expect(pagina.proximaPagina, isNull);
      expect(pagina.ehUltima, isTrue);
    });

    test('o período sem resultado vira página vazia', () {
      final pagina = ContatosEnvelopeModel.fromJson(
        _fixture('contatos_periodo_vazio.json'),
      ).paraPagina();

      expect(pagina.itens, isEmpty);
      expect(pagina.ehUltima, isTrue);
    });

    test('a ordem do servidor é preservada', () {
      final bruto = _fixture('contatos_p1.json');
      final idsDoWire = [
        for (final item in bruto['results']! as List<Object?>)
          (item! as Map<String, Object?>)['id']! as int,
      ];
      final pagina = ContatosEnvelopeModel.fromJson(bruto).paraPagina();

      expect([for (final item in pagina.itens) item.id], idsDoWire);
    });
  });

  group('ContatoRecebidoModel.paraEntidade', () {
    test('mapeia o primeiro item da primeira página', () {
      final bruto = _primeiroItem('contatos_p1.json');
      final contato = ContatoRecebidoModel.fromJson(bruto).paraEntidade();

      expect(contato.id, bruto['id']);
      expect(contato.imovelCodigo, bruto['imovel_codigo']);
      expect(contato.imovelTitulo, bruto['imovel_titulo']);
      expect(contato.canal, CanalContato.email);
      expect(contato.retorno, RetornoContato.pendente);
      expect(contato.retornoEm, isNull);
    });

    test('criado_em vira a hora local do aparelho (calculada, não fixa)', () {
      final bruto = _primeiroItem('contatos_p1.json');
      final contato = ContatoRecebidoModel.fromJson(bruto).paraEntidade();
      final esperado = DateTime.parse(bruto['criado_em']! as String).toLocal();

      expect(contato.criadoEm, esperado);
      expect(contato.criadoEm.isUtc, isFalse);
    });

    test('o PATCH 200 vira retorno falei com retorno_em local', () {
      final bruto = _fixture('contato_patch_200.json');
      final contato = ContatoRecebidoModel.fromJson(bruto).paraEntidade();
      final esperado = DateTime.parse(bruto['retorno_em']! as String).toLocal();

      expect(contato.retorno, RetornoContato.falei);
      expect(contato.retornoEm, isNotNull);
      expect(contato.retornoEm, esperado);
      expect(contato.retornoEm!.isUtc, isFalse);
    });

    test('canal desconhecido lança FormatException', () {
      final modelo = ContatoRecebidoModel.fromJson(_itemCom({'canal': 'FAX'}));

      expect(modelo.paraEntidade, throwsFormatException);
    });

    test('retorno desconhecido lança FormatException', () {
      final modelo = ContatoRecebidoModel.fromJson(
        _itemCom({'retorno': 'ARQUIVADO'}),
      );

      expect(modelo.paraEntidade, throwsFormatException);
    });

    test('chaves de exibição e do corretor são ignoradas (D-09, D-10)', () {
      final contato = ContatoRecebidoModel.fromJson(
        _itemCom({
          'canal_exibicao': 'texto do servidor',
          'retorno_exibicao': 'outro texto',
          'corretor_nome': 'Fulano',
        }),
      ).paraEntidade();

      expect(contato.toString(), isNot(contains('texto do servidor')));
      expect(contato.toString(), isNot(contains('Fulano')));
    });
  });

  group('ResumoContatosModel', () {
    test('lê sem_retorno como o inteiro da fixture', () {
      final bruto = _fixture('contatos_resumo.json');

      expect(
        ResumoContatosModel.fromJson(bruto).semRetorno,
        bruto['sem_retorno'],
      );
    });

    test('depois de anotar, a contagem é uma a menos', () {
      final antes = ResumoContatosModel.fromJson(
        _fixture('contatos_resumo.json'),
      ).semRetorno;
      final depois = ResumoContatosModel.fromJson(
        _fixture('contatos_resumo_apos.json'),
      ).semRetorno;

      expect(depois, antes - 1);
    });
  });

  group('ImovelComContatoModel.paraEntidade', () {
    test('lê toda a lista de opções na ordem recebida', () {
      final bruto = lerFixtureApi('contatos_imoveis.json')! as List<Object?>;
      final opcoes = [
        for (final item in bruto)
          ImovelComContatoModel.fromJson(item! as Map<String, Object?>)
              .paraEntidade(),
      ];

      expect(opcoes, hasLength(bruto.length));
      for (var i = 0; i < bruto.length; i++) {
        final item = bruto[i]! as Map<String, Object?>;
        expect(opcoes[i].id, item['id']);
        expect(opcoes[i].codigo, item['codigo']);
        expect(opcoes[i].titulo, item['titulo']);
      }
    });
  });
}
