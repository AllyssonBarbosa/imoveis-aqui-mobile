import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/parametros_consulta_acervo.dart';
import 'package:imoveis_aqui/data/models/codigos_imovel_api.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';

void main() {
  group('finalidadeDoCodigo', () {
    test('traduz os três códigos da finalidade', () {
      expect(finalidadeDoCodigo('VENDA'), FinalidadeImovel.venda);
      expect(finalidadeDoCodigo('ALUGUEL'), FinalidadeImovel.aluguel);
      expect(
        finalidadeDoCodigo('VENDA_E_ALUGUEL'),
        FinalidadeImovel.vendaEAluguel,
      );
    });

    test('código desconhecido lança FormatException com a mensagem do acervo', () {
      expect(
        () => finalidadeDoCodigo('PERMUTA'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            'finalidade desconhecida: PERMUTA',
          ),
        ),
      );
    });

    test('código vazio também lança FormatException', () {
      expect(() => finalidadeDoCodigo(''), throwsFormatException);
    });
  });

  group('situacaoDoCodigo', () {
    test('traduz os quatro códigos da situação', () {
      expect(situacaoDoCodigo('DISPONIVEL'), SituacaoImovel.disponivel);
      expect(situacaoDoCodigo('RESERVADO'), SituacaoImovel.reservado);
      expect(situacaoDoCodigo('VENDIDO'), SituacaoImovel.vendido);
      expect(situacaoDoCodigo('ALUGADO'), SituacaoImovel.alugado);
    });

    test('código desconhecido vira null (T-09-10)', () {
      expect(situacaoDoCodigo('EM_OBRA'), isNull);
    });

    test('código nulo vira null', () {
      expect(situacaoDoCodigo(null), isNull);
    });

    test('minúsculas viram null: o app não normaliza o que o servidor manda', () {
      expect(situacaoDoCodigo('reservado'), isNull);
    });
  });

  group('ida e volta com codigoDaSituacao (T-09-14)', () {
    for (final situacao in SituacaoImovel.values) {
      test('${situacao.name}: o código enviado é o mesmo que é entendido', () {
        expect(situacaoDoCodigo(codigoDaSituacao(situacao)), situacao);
      });
    }
  });
}
