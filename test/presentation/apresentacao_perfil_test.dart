import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/presentation/perfis/apresentacao_perfil.dart';

void main() {
  group('linhasDeContato', () {
    test('com os três valores devolve Telefone, WhatsApp e E-mail, na ordem, '
        'com valor exato e ícone', () {
      final linhas = linhasDeContato(
        telefone: '(19) 3333-4444',
        whatsapp: '19999998888',
        email: 'marina.lopes@jequitiba.exemplo.com',
      );

      expect(linhas.map((l) => l.rotulo), ['Telefone', 'WhatsApp', 'E-mail']);
      expect(linhas.map((l) => l.valor), [
        '(19) 3333-4444',
        '19999998888',
        'marina.lopes@jequitiba.exemplo.com',
      ]);
      expect(linhas.map((l) => l.icone), [
        Icons.phone_outlined,
        Icons.chat_outlined,
        Icons.email_outlined,
      ]);
    });

    test('só o WhatsApp devolve uma linha', () {
      final linhas = linhasDeContato(whatsapp: '19977776666');

      expect(linhas, hasLength(1));
      expect(linhas.single.rotulo, 'WhatsApp');
      expect(linhas.single.valor, '19977776666');
    });

    test('sem nenhum valor devolve lista vazia', () {
      expect(linhasDeContato(), isEmpty);
    });

    test('não formata os valores (vão exatamente como vieram)', () {
      final linhas = linhasDeContato(telefone: '1933334444');

      expect(linhas.single.valor, '1933334444');
    });
  });

  group('tituloImoveisDe', () {
    test('monta "Imóveis de {nome}" com o nome como veio', () {
      expect(tituloImoveisDe('Marina Lopes'), 'Imóveis de Marina Lopes');
    });
  });
}
