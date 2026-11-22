import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/parametros_consulta_acervo.dart';
import 'package:imoveis_aqui/domain/entities/consulta_acervo.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';

void main() {
  group('parametrosDaConsultaAcervo', () {
    test('consulta vazia não gera nenhuma chave', () {
      expect(parametrosDaConsultaAcervo(const ConsultaAcervo()), isEmpty);
    });

    test('busca vai sem espaços nas pontas', () {
      expect(
        parametrosDaConsultaAcervo(
          const ConsultaAcervo(busca: '  DEV-CAMPINAS-14 '),
        ),
        {'busca': 'DEV-CAMPINAS-14'},
      );
    });

    test('busca só de espaços não gera a chave', () {
      expect(
        parametrosDaConsultaAcervo(const ConsultaAcervo(busca: '   ')),
        isEmpty,
      );
    });

    test('situação vira o código do Django', () {
      expect(
        parametrosDaConsultaAcervo(
          const ConsultaAcervo(situacao: SituacaoImovel.reservado),
        ),
        {'situacao': 'RESERVADO'},
      );
    });

    test('busca e situação juntas geram as duas chaves', () {
      expect(
        parametrosDaConsultaAcervo(
          const ConsultaAcervo(
            busca: 'casa',
            situacao: SituacaoImovel.disponivel,
          ),
        ),
        {'busca': 'casa', 'situacao': 'DISPONIVEL'},
      );
    });
  });

  group('codigoDaSituacao', () {
    test('traduz as quatro situações para os códigos do Django', () {
      expect(
        {
          for (final situacao in SituacaoImovel.values)
            situacao: codigoDaSituacao(situacao),
        },
        {
          SituacaoImovel.disponivel: 'DISPONIVEL',
          SituacaoImovel.reservado: 'RESERVADO',
          SituacaoImovel.vendido: 'VENDIDO',
          SituacaoImovel.alugado: 'ALUGADO',
        },
      );
    });
  });
}
