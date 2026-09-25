import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/foto_capa_imovel.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/imovel_card.dart';

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');

  Future<void> pumpCard(WidgetTester tester, Imovel imovel) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ImovelCard(imovel: imovel))),
    );
    await tester.pump();
  }

  testWidgets(
    'VENDA: título, preço formatado e "Apartamento · Cambuí · 2 quartos", '
    'nessa ordem (VIT-02, D-01)',
    (tester) async {
      final imovel = Imovel(
        id: 42,
        titulo: 'Apartamento 2 quartos no Cambuí',
        finalidade: FinalidadeImovel.venda,
        precoVenda: '450000.00',
        bairro: 'Cambuí',
        cidade: campinas,
        natureza: NaturezaImovel.apartamento,
        quartos: 2,
      );

      await pumpCard(tester, imovel);

      expect(find.byType(FotoCapaImovel), findsOneWidget);
      expect(find.text('Apartamento 2 quartos no Cambuí'), findsOneWidget);
      expect(find.text('R\$ 450.000'), findsOneWidget);
      expect(find.text('Apartamento · Cambuí · 2 quartos'), findsOneWidget);
    },
  );

  testWidgets(
    'VENDA_E_ALUGUEL: mostra as duas linhas de preço empilhadas (D-02)',
    (tester) async {
      final imovel = Imovel(
        id: 63,
        titulo: 'Terreno no Loteamento Jardim das Palmeiras',
        finalidade: FinalidadeImovel.vendaEAluguel,
        precoVenda: '220000.00',
        precoAluguel: '1500.00',
        bairro: 'Jardim das Palmeiras',
        cidade: campinas,
        natureza: NaturezaImovel.terreno,
      );

      await pumpCard(tester, imovel);

      expect(find.text('Venda R\$ 220.000'), findsOneWidget);
      expect(find.text('Aluguel R\$ 1.500/mês'), findsOneWidget);
    },
  );

  testWidgets(
    'foto nula mostra o placeholder (Icons.home_outlined) dentro de um '
    'AspectRatio 16:9 (D-04)',
    (tester) async {
      final imovel = Imovel(
        id: 1,
        titulo: 'Casa sem foto',
        finalidade: FinalidadeImovel.venda,
        precoVenda: '300000.00',
        bairro: 'Centro',
        cidade: campinas,
      );

      await pumpCard(tester, imovel);

      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      final aspectRatio = tester.widget<AspectRatio>(
        find.descendant(
          of: find.byType(FotoCapaImovel),
          matching: find.byType(AspectRatio),
        ),
      );
      expect(aspectRatio.aspectRatio, 16 / 9);
    },
  );

  testWidgets(
    'altura do slot de foto é igual para foto nula e para uma URL, no '
    'primeiro frame — nunca pumpAndSettle (D-04, RESEARCH Pitfall 6)',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 300, child: FotoCapaImovel(url: null)),
          ),
        ),
      );
      await tester.pump();
      final alturaSemFoto = tester.getSize(find.byType(FotoCapaImovel)).height;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: FotoCapaImovel(
                url: 'https://exemplo.com/foto.jpg',
                construirImagemDeRede: (_) =>
                    const ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final alturaComFoto = tester.getSize(find.byType(FotoCapaImovel)).height;

      expect(alturaSemFoto, alturaComFoto);
    },
  );
}
