import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/presentation/vitrine/apresentacao_imovel.dart';

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');

  Imovel imovelDe({
    required FinalidadeImovel finalidade,
    String? precoVenda,
    String? precoAluguel,
  }) => Imovel(
    id: 1,
    titulo: 'Imóvel teste',
    finalidade: finalidade,
    precoVenda: precoVenda,
    precoAluguel: precoAluguel,
    bairro: 'Centro',
    cidade: campinas,
  );

  group('formatarPrecoBrl', () {
    test(
      'valor inteiro sem centavos: "R\$ 450.000" (NBSP após o símbolo)',
      () {
        expect(formatarPrecoBrl('450000.00'), 'R\$ 450.000');
      },
    );

    test('valor com centavos: "R\$ 450.000,50"', () {
      expect(formatarPrecoBrl('450000.50'), 'R\$ 450.000,50');
    });

    test('valor não-parseável é devolvido sem alteração, nunca lança', () {
      expect(formatarPrecoBrl('abc'), 'abc');
    });
  });

  group('linhasDePreco', () {
    test('VENDA: só o preço de venda', () {
      final imovel = imovelDe(
        finalidade: FinalidadeImovel.venda,
        precoVenda: '450000.00',
      );
      expect(linhasDePreco(imovel), ['R\$ 450.000']);
    });

    test('ALUGUEL: só o preço de aluguel, com sufixo "/mês"', () {
      final imovel = imovelDe(
        finalidade: FinalidadeImovel.aluguel,
        precoAluguel: '3200.00',
      );
      expect(linhasDePreco(imovel), ['R\$ 3.200/mês']);
    });

    test('VENDA_E_ALUGUEL: os dois preços empilhados, com prefixo', () {
      final imovel = imovelDe(
        finalidade: FinalidadeImovel.vendaEAluguel,
        precoVenda: '220000.00',
        precoAluguel: '1500.00',
      );
      expect(linhasDePreco(imovel), [
        'Venda R\$ 220.000',
        'Aluguel R\$ 1.500/mês',
      ]);
    });

    test('finalidade cujo preço correspondente é nulo omite a linha', () {
      final imovel = imovelDe(
        finalidade: FinalidadeImovel.venda,
        precoVenda: null,
      );
      expect(linhasDePreco(imovel), ['Preço sob consulta']);
    });

    test('nenhum preço disponível -> "Preço sob consulta"', () {
      final imovel = imovelDe(finalidade: FinalidadeImovel.vendaEAluguel);
      expect(linhasDePreco(imovel), ['Preço sob consulta']);
    });
  });

  group('rotuloNatureza', () {
    test('mapeia cada valor conhecido para o rótulo em PT', () {
      expect(rotuloNatureza(NaturezaImovel.casa), 'Casa');
      expect(rotuloNatureza(NaturezaImovel.apartamento), 'Apartamento');
      expect(rotuloNatureza(NaturezaImovel.terreno), 'Terreno');
      expect(rotuloNatureza(NaturezaImovel.lote), 'Lote');
    });

    test('null permanece null', () {
      expect(rotuloNatureza(null), isNull);
    });
  });

  group('rotuloQuartos', () {
    test('null ou zero -> null (nada a mostrar)', () {
      expect(rotuloQuartos(null), isNull);
      expect(rotuloQuartos(0), isNull);
    });

    test('1 -> singular "1 quarto"', () {
      expect(rotuloQuartos(1), '1 quarto');
    });

    test('3 -> plural "3 quartos"', () {
      expect(rotuloQuartos(3), '3 quartos');
    });
  });
}
