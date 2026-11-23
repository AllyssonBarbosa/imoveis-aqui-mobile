import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/apresentacao_gestao.dart';
import 'package:intl/intl.dart';

void main() {
  group('formatarDataHora (D-05)', () {
    test('formata dd/MM/yyyy HH:mm com zeros à esquerda', () {
      expect(
        formatarDataHora(DateTime(2026, 11, 22, 14, 30)),
        '22/11/2026 14:30',
      );
      expect(formatarDataHora(DateTime(2026, 1, 5, 9, 7)), '05/01/2026 09:07');
    });

    test('um instante do servidor sai no fuso do aparelho (toLocal)', () {
      final momento = DateTime.parse('2026-11-22T02:00:37.259695-03:00');

      // O esperado é calculado com o mesmo critério (fuso do aparelho), para o
      // teste não depender do fuso da máquina (RESEARCH, Pitfall 8).
      expect(
        formatarDataHora(momento),
        DateFormat('dd/MM/yyyy HH:mm').format(momento.toLocal()),
      );
    });

    test('textoDesde acrescenta o prefixo "desde "', () {
      final momento = DateTime.utc(2026, 11, 22, 15, 25);

      expect(textoDesde(momento), 'desde ${formatarDataHora(momento)}');
    });
  });

  test('textos fixos da seção de situação e do atalho da vitrine', () {
    expect(tituloSecaoSituacao, 'Situação');
    expect(rotuloVerNaVitrine, 'Ver na vitrine');
  });
}
