import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel_acervo.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/presentation/acervo/widgets/cartao_imovel_acervo.dart';
import 'package:imoveis_aqui/presentation/comum/imagem_rede.dart';

/// Imagem determinística: uma caixa com a chave da própria url.
Widget _caixaDaUrl(String url) =>
    ColoredBox(key: ValueKey(url), color: Colors.blue);

ImovelAcervo _imovel({
  String titulo = 'Apartamento 2 quartos no Cambuí',
  FinalidadeImovel finalidade = FinalidadeImovel.venda,
  String? precoVenda = '450000.00',
  String? precoAluguel,
  String? fotoCapa,
  SituacaoImovel? situacao = SituacaoImovel.disponivel,
  bool meuImovel = false,
  bool naVitrine = true,
}) => ImovelAcervo(
  id: 14,
  codigo: 'DEV-CAMPINAS-14',
  titulo: titulo,
  finalidade: finalidade,
  precoVenda: precoVenda,
  precoAluguel: precoAluguel,
  fotoCapa: fotoCapa,
  situacao: situacao,
  meuImovel: meuImovel,
  naVitrine: naVitrine,
);

void main() {
  Future<void> montar(
    WidgetTester tester,
    ImovelAcervo imovel, {
    VoidCallback? aoTocar,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CartaoImovelAcervo(
            imovel: imovel,
            aoTocar: aoTocar,
            construirImagemDeRede: _caixaDaUrl,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('mostra código, título, preço e a miniatura da capa', (
    tester,
  ) async {
    await montar(tester, _imovel(fotoCapa: 'https://exemplo.com/capa.jpg'));

    expect(find.text('DEV-CAMPINAS-14'), findsOneWidget);
    expect(find.text('Apartamento 2 quartos no Cambuí'), findsOneWidget);
    expect(find.text('R\$ 450.000'), findsOneWidget);
    expect(find.byType(ImagemRede), findsOneWidget);
    expect(
      find.byKey(const ValueKey('https://exemplo.com/capa.jpg')),
      findsOneWidget,
    );
    expect(tester.getSize(find.byType(ImagemRede)), const Size.square(96));
  });

  testWidgets('sem capa mostra a imagem padrão (placeholder)', (tester) async {
    await montar(tester, _imovel());

    expect(find.byType(ImagemPadraoImovel), findsOneWidget);
  });

  testWidgets('título longo fica em no máximo 2 linhas com reticências', (
    tester,
  ) async {
    await montar(tester, _imovel(titulo: 'Casa ' * 60));

    final texto = tester.widget<Text>(find.textContaining('Casa'));
    expect(texto.maxLines, 2);
    expect(texto.overflow, TextOverflow.ellipsis);
  });

  testWidgets('VENDA_E_ALUGUEL mostra as duas linhas de preço', (tester) async {
    await montar(
      tester,
      _imovel(
        finalidade: FinalidadeImovel.vendaEAluguel,
        precoVenda: '220000.00',
        precoAluguel: '1500.00',
      ),
    );

    expect(find.text('Venda R\$ 220.000'), findsOneWidget);
    expect(find.textContaining('R\$ 1.500'), findsOneWidget);
  });

  group('marcas (D-06)', () {
    for (final (situacao, rotulo) in [
      (SituacaoImovel.disponivel, 'Disponível'),
      (SituacaoImovel.reservado, 'Reservado'),
      (SituacaoImovel.vendido, 'Vendido'),
      (SituacaoImovel.alugado, 'Alugado'),
    ]) {
      testWidgets('situação $situacao mostra "$rotulo"', (tester) async {
        await montar(tester, _imovel(situacao: situacao));

        expect(find.text(rotulo), findsOneWidget);
      });
    }

    testWidgets('situação nula não mostra chip de situação', (tester) async {
      await montar(tester, _imovel(situacao: null));

      for (final rotulo in ['Disponível', 'Reservado', 'Vendido', 'Alugado']) {
        expect(find.text(rotulo), findsNothing);
      }
    });

    testWidgets('meuImovel mostra "Seu"; falso não mostra', (tester) async {
      await montar(tester, _imovel(meuImovel: true));
      expect(find.text('Seu'), findsOneWidget);

      await montar(tester, _imovel(meuImovel: false));
      expect(find.text('Seu'), findsNothing);
    });

    testWidgets('nenhuma outra marca aparece, nem "Não publicado"', (
      tester,
    ) async {
      await montar(tester, _imovel(naVitrine: false, meuImovel: true));

      expect(find.textContaining('publicado'), findsNothing);
      expect(find.textContaining('vitrine'), findsNothing);
      // Só: código, título, preço, situação e "Seu".
      expect(find.byType(Text), findsNWidgets(5));
    });
  });

  group('toque (D-07)', () {
    testWidgets('naVitrine: tocar chama aoTocar uma vez', (tester) async {
      var toques = 0;
      await montar(tester, _imovel(naVitrine: true), aoTocar: () => toques++);

      await tester.tap(find.byType(CartaoImovelAcervo));

      expect(toques, 1);
    });

    testWidgets('sem naVitrine: não há InkWell e tocar não chama nada', (
      tester,
    ) async {
      var toques = 0;
      await montar(tester, _imovel(naVitrine: false), aoTocar: () => toques++);

      expect(
        find.descendant(
          of: find.byType(CartaoImovelAcervo),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
      await tester.tap(find.byType(CartaoImovelAcervo));
      expect(toques, 0);
    });

    testWidgets('naVitrine sem aoTocar não tem InkWell', (tester) async {
      await montar(tester, _imovel(naVitrine: true));

      expect(
        find.descendant(
          of: find.byType(CartaoImovelAcervo),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
    });
  });
}
