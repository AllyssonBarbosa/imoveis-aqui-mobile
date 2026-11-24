import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/parametros_consulta_contatos.dart';
import 'package:imoveis_aqui/domain/entities/consulta_contatos.dart';
import 'package:imoveis_aqui/domain/entities/imovel_com_contato.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';

void main() {
  const imovel = ImovelComContato(
    id: 7,
    codigo: 'DEV-CAMPINAS-07',
    titulo: 'Casa no Centro',
  );

  group('parametrosDaConsultaContatos', () {
    test('consulta vazia não gera nenhuma chave', () {
      expect(parametrosDaConsultaContatos(const ConsultaContatos()), isEmpty);
    });

    test('imóvel vira imovel=<id>', () {
      expect(
        parametrosDaConsultaContatos(const ConsultaContatos(imovel: imovel)),
        {'imovel': '7'},
      );
    });

    test('período vira de e ate AAAA-MM-DD sem mudar o dia (sem UTC)', () {
      final consulta = ConsultaContatos(
        periodo: PeriodoContatos(
          de: DateTime(2026, 11, 1),
          ate: DateTime(2026, 11, 22, 23, 30),
        ),
      );

      expect(parametrosDaConsultaContatos(consulta), {
        'de': '2026-11-01',
        'ate': '2026-11-22',
      });
    });

    test('imóvel e período juntos dão as três chaves', () {
      final consulta = ConsultaContatos(
        imovel: imovel,
        periodo: PeriodoContatos(
          de: DateTime(2026, 1, 5),
          ate: DateTime(2026, 2, 9),
        ),
      );

      expect(parametrosDaConsultaContatos(consulta), {
        'imovel': '7',
        'de': '2026-01-05',
        'ate': '2026-02-09',
      });
    });
  });
}
