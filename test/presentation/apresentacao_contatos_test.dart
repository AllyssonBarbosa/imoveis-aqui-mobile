import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/contato_recebido.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';
import 'package:imoveis_aqui/presentation/contatos/apresentacao_contatos.dart';

void main() {
  group('textos fixos da caixa (D-07, D-21)', () {
    test('constantes de texto', () {
      expect(tituloCaixaContatos, 'Meus contatos');
      expect(textoCaixaVazia, 'Você ainda não recebeu contatos.');
      expect(textoCaixaSemResultado, 'Nenhum contato encontrado.');
      expect(textoErroCaixa, 'Não foi possível carregar os contatos.');
      expect(
        textoErroAoCarregarMaisContatos,
        'Não foi possível carregar mais contatos',
      );
    });

    test('textoSemRetorno trata zero, singular e plural', () {
      expect(textoSemRetorno(0), 'Nenhum contato sem retorno');
      expect(textoSemRetorno(1), '1 contato sem retorno');
      expect(textoSemRetorno(25), '25 contatos sem retorno');
    });
  });

  group('data dd/MM/yyyy HH:mm sem locale (Pitfall 4)', () {
    test('formatarDataHoraContato preenche dia, mes e hora com zero', () {
      expect(
        formatarDataHoraContato(DateTime(2026, 1, 9, 22, 30)),
        '09/01/2026 22:30',
      );
    });

    test('textoAnotadoEm prefixa "anotado em"', () {
      expect(
        textoAnotadoEm(DateTime(2026, 11, 22, 8, 5)),
        'anotado em 22/11/2026 08:05',
      );
    });
  });

  group('rotulos fixos (D-09, D-10)', () {
    test('nomeExibicao do canal', () {
      expect(CanalContato.whatsapp.nomeExibicao, 'WhatsApp');
      expect(CanalContato.telefone.nomeExibicao, 'Telefone');
      expect(CanalContato.email.nomeExibicao, 'E-mail');
    });

    test('rotulo do retorno', () {
      expect(RetornoContato.pendente.rotulo, 'Aguardando retorno');
      expect(RetornoContato.falei.rotulo, 'Falei');
      expect(RetornoContato.visitaAgendada.rotulo, 'Visita agendada');
      expect(RetornoContato.semResposta.rotulo, 'Sem resposta');
      expect(RetornoContato.descartado.rotulo, 'Descartado');
    });

    test('rotuloImovelDoContato junta codigo e titulo com travessao', () {
      final contato = ContatoRecebido(
        id: 1,
        imovelCodigo: 'DEV-CAMPINAS-14',
        imovelTitulo: 'Apartamento 2 quartos',
        canal: CanalContato.whatsapp,
        criadoEm: DateTime(2026, 11, 22, 8, 5),
        retorno: RetornoContato.pendente,
      );
      expect(
        rotuloImovelDoContato(contato),
        'DEV-CAMPINAS-14 — Apartamento 2 quartos',
      );
    });
  });
}
