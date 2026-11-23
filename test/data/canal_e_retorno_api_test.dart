import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/canal_contato_api.dart';
import 'package:imoveis_aqui/data/models/retorno_contato_api.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';

void main() {
  group('canalContatoDaApi', () {
    test('lê os três canais do wire', () {
      expect(canalContatoDaApi('WHATSAPP'), CanalContato.whatsapp);
      expect(canalContatoDaApi('TELEFONE'), CanalContato.telefone);
      expect(canalContatoDaApi('EMAIL'), CanalContato.email);
    });

    test('valor desconhecido lança FormatException', () {
      for (final valor in ['FAX', '', 'whatsapp']) {
        expect(
          () => canalContatoDaApi(valor),
          throwsFormatException,
          reason: 'valor "$valor"',
        );
      }
    });

    test('valorApi e canalContatoDaApi fazem ida e volta', () {
      for (final canal in CanalContato.values) {
        expect(canalContatoDaApi(canal.valorApi), canal);
      }
    });
  });

  group('retornoContatoDaApi', () {
    test('lê os cinco retornos do wire', () {
      expect(retornoContatoDaApi('PENDENTE'), RetornoContato.pendente);
      expect(retornoContatoDaApi('FALEI'), RetornoContato.falei);
      expect(
        retornoContatoDaApi('VISITA_AGENDADA'),
        RetornoContato.visitaAgendada,
      );
      expect(retornoContatoDaApi('SEM_RESPOSTA'), RetornoContato.semResposta);
      expect(retornoContatoDaApi('DESCARTADO'), RetornoContato.descartado);
    });

    test('valor desconhecido lança FormatException', () {
      for (final valor in ['ARQUIVADO', '', 'falei']) {
        expect(
          () => retornoContatoDaApi(valor),
          throwsFormatException,
          reason: 'valor "$valor"',
        );
      }
    });

    test('valorApi e retornoContatoDaApi fazem ida e volta', () {
      for (final retorno in RetornoContato.values) {
        expect(retornoContatoDaApi(retorno.valorApi), retorno);
      }
    });

    test('valorApi usa os nomes do wire', () {
      expect(RetornoContato.visitaAgendada.valorApi, 'VISITA_AGENDADA');
      expect(RetornoContato.semResposta.valorApi, 'SEM_RESPOSTA');
    });
  });
}
