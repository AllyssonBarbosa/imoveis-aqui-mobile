import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/network/mensagem_de_recusa.dart';

import '../support/api_falsa.dart';

void main() {
  group('mensagemDeRecusa', () {
    test('erro_400_mesma_situacao.json vira o texto da lista', () {
      expect(
        mensagemDeRecusa(lerFixtureApi('erro_400_mesma_situacao.json')),
        'O imóvel já está reservado.',
      );
    });

    test('erro_400_contrato_assinado.json traz o texto completo do contrato',
        () {
      expect(
        mensagemDeRecusa(lerFixtureApi('erro_400_contrato_assinado.json')),
        'Este imóvel tem um contrato assinado (#1): a situação não pode ser '
        'mudada à mão enquanto o contrato estiver valendo.',
      );
    });

    test('erro_403_situacao.json vira o detail', () {
      expect(
        mensagemDeRecusa(lerFixtureApi('erro_403_situacao.json')),
        'Só o corretor responsável por este imóvel ou o gestor podem mudar a '
        'situação.',
      );
    });

    test('lista de qualquer chave (observacao) entra', () {
      expect(
        mensagemDeRecusa(<String, Object?>{
          'observacao': ['Este campo pode não ser nulo.'],
        }),
        'Este campo pode não ser nulo.',
      );
    });

    test('non_field_errors entra', () {
      expect(
        mensagemDeRecusa(<String, Object?>{
          'non_field_errors': [
            'Dado inválido. Esperava um dicionário, mas recebeu list.',
          ],
        }),
        'Dado inválido. Esperava um dicionário, mas recebeu list.',
      );
    });

    test('detail em texto simples entra', () {
      expect(
        mensagemDeRecusa(<String, Object?>{
          'detail': 'Este recurso é restrito ao corretor.',
        }),
        'Este recurso é restrito ao corretor.',
      );
    });

    test('junta por espaço, na ordem das chaves, com trim e sem vazios', () {
      expect(
        mensagemDeRecusa(<String, Object?>{
          'situacao': ['  A  ', ''],
          'detail': 'B',
        }),
        'A B',
      );
    });

    test('itens que não são texto são ignorados', () {
      expect(
        mensagemDeRecusa(<String, Object?>{
          'situacao': [1, null, 'A', <String, Object?>{}],
          'outro': 3,
        }),
        'A',
      );
    });

    test('sem texto aproveitável devolve null', () {
      expect(mensagemDeRecusa(<String, Object?>{}), isNull);
      expect(mensagemDeRecusa(<String, Object?>{'situacao': <Object?>[]}),
          isNull);
      expect(mensagemDeRecusa(<String, Object?>{'detail': '   '}), isNull);
      expect(mensagemDeRecusa(null), isNull);
      expect(mensagemDeRecusa('<html>Erro</html>'), isNull);
      expect(mensagemDeRecusa(<Object?>['texto']), isNull);
    });

    test('acima de 300 caracteres corta e acrescenta reticências', () {
      final longo = 'a' * 500;

      final texto = mensagemDeRecusa(<String, Object?>{'detail': longo})!;

      expect(limiteMensagemDeRecusa, 300);
      expect(texto, '${'a' * 300}…');
    });

    test('com exatamente 300 caracteres não corta', () {
      final exato = 'b' * 300;

      expect(mensagemDeRecusa(<String, Object?>{'detail': exato}), exato);
    });
  });
}
