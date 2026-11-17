import 'package:flutter_test/flutter_test.dart';

import '../support/api_falsa.dart';

/// Teste de contrato do POST de contato
/// (`POST /api/publico/imoveis/<id>/contato/`): o app é comparado com as
/// respostas REAIS capturadas (`test/fixtures/api/contato_201_*.json` e
/// `erro_400_canal_contato.json`, 06-03), nunca com JSON escrito à mão. Trava
/// as chaves exatas `{canal, link}`, o esquema do link de cada canal e que o
/// link do servidor sobrevive intacto a `Uri.parse(...).toString()` — o app só
/// abre o link como recebido, nunca reconstrói nem reencoda (C2, C3).
void main() {
  Map<String, Object?> capturado(String nome) =>
      Map<String, Object?>.of(lerFixtureApi(nome)! as Map<String, Object?>);

  String linkDe(String canal) =>
      capturado('contato_201_${canal.toLowerCase()}.json')['link']! as String;

  group('chaves exatas {canal, link} (C2, C3)', () {
    for (final canal in ['WHATSAPP', 'TELEFONE', 'EMAIL']) {
      test('contato_201_${canal.toLowerCase()}.json', () {
        final resposta = capturado('contato_201_${canal.toLowerCase()}.json');

        expect(resposta.keys.toSet(), {'canal', 'link'});
        expect(resposta['canal'], canal);
        expect(resposta['link'], isA<String>());
        expect(resposta['link'], isNotEmpty);
      });
    }
  });

  group('esquema do link por canal (C2, C3)', () {
    test('WhatsApp: https wa.me com text pré-preenchido, %20 e nenhum "+"', () {
      final link = linkDe('WHATSAPP');
      final uri = Uri.parse(link);

      expect(uri.scheme, 'https');
      expect(uri.host, 'wa.me');
      expect(uri.queryParameters['text'], isNotEmpty);
      expect(link, contains('%20'));
      expect(link, isNot(contains('+')));
    });

    test('Telefone: esquema tel', () {
      final uri = Uri.parse(linkDe('TELEFONE'));

      expect(uri.scheme, 'tel');
      expect(uri.path, isNotEmpty);
    });

    test('E-mail: esquema mailto com subject e body não vazios', () {
      final uri = Uri.parse(linkDe('EMAIL'));

      expect(uri.scheme, 'mailto');
      expect(uri.path, isNotEmpty);
      expect(uri.queryParameters['subject'], isNotEmpty);
      expect(uri.queryParameters['body'], isNotEmpty);
    });
  });

  group('o app nunca reencoda o link do servidor (C3)', () {
    for (final canal in ['WHATSAPP', 'TELEFONE', 'EMAIL']) {
      test('$canal: Uri.parse(link).toString() == link', () {
        final link = linkDe(canal);

        expect(Uri.parse(link).toString(), link);
      });
    }
  });

  group('400 de canal inválido', () {
    test('erro_400_canal_contato.json tem a chave canal com lista não vazia', () {
      final erro = capturado('erro_400_canal_contato.json');

      expect(erro.keys, contains('canal'));
      final mensagens = erro['canal'];
      expect(mensagens, isA<List<Object?>>());
      expect(mensagens as List<Object?>, isNotEmpty);
    });
  });
}
