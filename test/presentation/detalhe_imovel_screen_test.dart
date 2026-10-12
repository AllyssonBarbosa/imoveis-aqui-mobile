import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/dados_natureza.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_state.dart';
import 'package:mocktail/mocktail.dart';

class _DetalheImovelCubitFalso extends MockCubit<DetalheImovelState>
    implements DetalheImovelCubit {}

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const previa = Imovel(
    id: 42,
    titulo: 'Apartamento 2 quartos no Cambuí',
    finalidade: FinalidadeImovel.venda,
    precoVenda: '450000.00',
    bairro: 'Cambuí',
    cidade: campinas,
  );
  const detalhe = DetalheImovel(
    id: 42,
    titulo: 'Apartamento 2 quartos no Cambuí',
    finalidade: FinalidadeImovel.venda,
    precoVenda: '450000.00',
    descricao: 'Apartamento reformado.',
    bairro: 'Cambuí',
    cidade: campinas,
  );

  late _DetalheImovelCubitFalso cubit;

  setUp(() {
    cubit = _DetalheImovelCubitFalso();
    when(() => cubit.tentarNovamente()).thenAnswer((_) async {});
  });

  /// Empurra a página por cima de uma página-base, como a vitrine faz, para
  /// que `Navigator.maybePop` tenha para onde voltar.
  Future<void> pumpEstado(
    WidgetTester tester,
    DetalheImovelState estado, {
    double altura = 1200,
  }) async {
    tester.view.physicalSize = Size(400, altura);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    whenListen(
      cubit,
      const Stream<DetalheImovelState>.empty(),
      initialState: estado,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider<DetalheImovelCubit>.value(
                      value: cubit,
                      child: const DetalheImovelScreen(previa: previa),
                    ),
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('carregando mostra o título da prévia e um spinner', (
    tester,
  ) async {
    await pumpEstado(tester, const DetalheImovelState.carregando());

    expect(find.text('Apartamento 2 quartos no Cambuí'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byTooltip('Voltar'), findsOneWidget);
  });

  testWidgets('carregado mostra a seção Descrição', (tester) async {
    await pumpEstado(tester, const DetalheImovelState.carregado(detalhe));

    expect(find.text('Descrição'), findsOneWidget);
    expect(find.text('Apartamento reformado.'), findsOneWidget);
    expect(find.byTooltip('Voltar'), findsOneWidget);
  });

  group('natureza (DET-04)', () {
    final casa57 = detalhe.copyWith(
      id: 57,
      titulo: 'Casa com quintal',
      dados: const DadosNatureza.casa(
        areaTerreno: '300.00',
        areaConstruida: '180.00',
        areaLivre: '100.00',
        quartos: 3,
        suites: 0,
        banheiros: 2,
        vagas: 2,
      ),
    );

    testWidgets('casa 57 mostra "Sobre a casa" e a área livre do servidor '
        '(100 m²), nunca 120 m², acima da Descrição', (tester) async {
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(casa57),
        altura: 2400,
      );

      expect(find.text('Sobre a casa'), findsOneWidget);
      expect(find.text('Área livre'), findsOneWidget);
      expect(find.text('100 m²'), findsOneWidget);
      expect(find.text('300 m²'), findsOneWidget);
      expect(find.text('180 m²'), findsOneWidget);
      expect(find.text('120 m²'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Sobre a casa')).dy,
        lessThan(tester.getTopLeft(find.text('Descrição')).dy),
      );
    });

    testWidgets('sem dados de natureza não há título "Sobre" e a descrição '
        'continua', (tester) async {
      await pumpEstado(tester, const DetalheImovelState.carregado(detalhe));

      expect(find.textContaining('Sobre a'), findsNothing);
      expect(find.textContaining('Sobre o'), findsNothing);
      expect(find.text('Descrição'), findsOneWidget);
    });

    testWidgets('terreno mostra frente, fundo e topografia em PT', (
      tester,
    ) async {
      final terreno = detalhe.copyWith(
        dados: const DadosNatureza.terreno(
          areaTotal: '300.00',
          frente: '12.00',
          fundo: '25.00',
          topografia: Topografia.aclive,
        ),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(terreno),
        altura: 2400,
      );

      expect(find.text('Sobre o terreno'), findsOneWidget);
      expect(find.text('12 m'), findsOneWidget);
      expect(find.text('25 m'), findsOneWidget);
      expect(find.text('Topografia'), findsOneWidget);
      expect(find.text('Aclive'), findsOneWidget);
    });

    testWidgets('apartamento mostra a posição solar exatamente como veio', (
      tester,
    ) async {
      final apto = detalhe.copyWith(
        dados: const DadosNatureza.apartamento(
          andar: 8,
          posicaoSolar: 'Sol da manhã',
        ),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(apto),
        altura: 2400,
      );

      expect(find.text('Sobre o apartamento'), findsOneWidget);
      expect(find.text('Posição solar'), findsOneWidget);
      expect(find.text('Sol da manhã'), findsOneWidget);
      expect(find.text('8º'), findsOneWidget);
    });

    testWidgets('lote com preço próprio mostra "Preço do lote" '
        'formatado', (tester) async {
      final comPreco = detalhe.copyWith(
        dados: const DadosNatureza.lote(numero: '9', preco: '210500.50'),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(comPreco),
        altura: 2400,
      );

      expect(find.text('Sobre o lote'), findsOneWidget);
      expect(find.text('Preço do lote'), findsOneWidget);
      expect(find.text('R\$ 210.500,50'), findsOneWidget);
    });

    testWidgets('lote sem preço próprio não mostra "Preço do lote"', (
      tester,
    ) async {
      final semPreco = detalhe.copyWith(
        dados: const DadosNatureza.lote(numero: '9'),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(semPreco),
        altura: 2400,
      );

      expect(find.text('Sobre o lote'), findsOneWidget);
      expect(find.text('Preço do lote'), findsNothing);
    });

    testWidgets('natureza sem nenhum campo preenchido faz a seção sumir', (
      tester,
    ) async {
      final vazio = detalhe.copyWith(dados: const DadosNatureza.casa());
      await pumpEstado(tester, DetalheImovelState.carregado(vazio));

      expect(find.textContaining('Sobre a'), findsNothing);
      expect(find.text('Descrição'), findsOneWidget);
    });
  });

  testWidgets('erro mostra a mensagem e "Tentar de novo" chama o Cubit', (
    tester,
  ) async {
    await pumpEstado(tester, const DetalheImovelState.erro());

    expect(find.text('Não foi possível carregar este imóvel.'), findsOneWidget);
    expect(find.text('Este imóvel não está mais disponível'), findsNothing);
    expect(find.byTooltip('Voltar'), findsOneWidget);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    verify(() => cubit.tentarNovamente()).called(1);
  });

  testWidgets('naoEncontrado mostra a mensagem própria sem prévia nem "Tentar de novo" '
      'e "Voltar à vitrine" fecha a página', (tester) async {
    await pumpEstado(tester, const DetalheImovelState.naoEncontrado());

    expect(find.text('Este imóvel não está mais disponível'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsNothing);
    expect(find.text('Não foi possível carregar este imóvel.'), findsNothing);
    // A prévia (título e preço) não aparece: o imóvel saiu do ar (T-04-03-02).
    expect(find.text('Apartamento 2 quartos no Cambuí'), findsNothing);
    expect(find.text('R\$ 450.000'), findsNothing);
    expect(find.byTooltip('Voltar'), findsOneWidget);

    await tester.tap(find.text('Voltar à vitrine'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(DetalheImovelScreen), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
  });
}
