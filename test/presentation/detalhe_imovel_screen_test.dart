import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/dados_natureza.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/presentation/comum/imagem_rede.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/detalhe_imovel_state.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/perfil_corretor_screen.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/cartao_corretor.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/galeria_imovel.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/widgets/visualizador_fotos.dart';
import 'package:mocktail/mocktail.dart';

class _DetalheImovelCubitFalso extends MockCubit<DetalheImovelState>
    implements DetalheImovelCubit {}

/// Imagem determinística: uma caixa com a chave da própria url.
Widget _caixaDaUrl(String url) =>
    ColoredBox(key: ValueKey(url), color: Colors.blue);

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const previa = Imovel(
    id: 42,
    titulo: 'Apartamento 2 quartos no Cambuí',
    finalidade: FinalidadeImovel.venda,
    precoVenda: '450000.00',
    bairro: 'Cambuí',
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
    Imovel previaUsada = previa,
    Stream<DetalheImovelState> fluxo = const Stream<DetalheImovelState>.empty(),
  }) async {
    tester.view.physicalSize = Size(400, altura);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    whenListen(cubit, fluxo, initialState: estado);
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
                      child: DetalheImovelScreen(
                        previa: previaUsada,
                        construirImagemDeRede: _caixaDaUrl,
                      ),
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

  group('galeria (DET-02)', () {
    const capa = 'https://exemplo.com/capa.jpg';
    const foto2 = 'https://exemplo.com/foto2.jpg';
    const foto3 = 'https://exemplo.com/foto3.jpg';
    final comFotos = detalhe.copyWith(
      fotos: const [
        FotoImovel(url: capa, capa: true),
        FotoImovel(url: foto2, capa: false),
        FotoImovel(url: foto3, capa: false),
      ],
    );
    const previaComCapa = Imovel(
      id: 42,
      titulo: 'Apartamento 2 quartos no Cambuí',
      finalidade: FinalidadeImovel.venda,
      precoVenda: '450000.00',
      bairro: 'Cambuí',
      fotoCapa: capa,
    );

    testWidgets('carregado com 3 fotos mostra a galeria e o contador 1/3', (
      tester,
    ) async {
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(comFotos),
        previaUsada: previaComCapa,
      );

      expect(find.byType(GaleriaImovel), findsOneWidget);
      expect(find.text('1/3'), findsOneWidget);
      expect(find.byKey(const ValueKey(capa)), findsOneWidget);
      expect(find.byTooltip('Voltar'), findsOneWidget);
    });

    testWidgets('carregando mostra a capa da prévia, sem galeria nem '
        'contador (D-16)', (tester) async {
      await pumpEstado(
        tester,
        const DetalheImovelState.carregando(),
        previaUsada: previaComCapa,
      );

      expect(find.byKey(const ValueKey(capa)), findsOneWidget);
      expect(find.byType(GaleriaImovel), findsNothing);
      expect(find.byKey(const ValueKey('contador-fotos')), findsNothing);
      expect(find.byTooltip('Voltar'), findsOneWidget);
    });

    testWidgets('carregado sem fotos mostra a imagem padrão, sem contador '
        '(D-10)', (tester) async {
      await pumpEstado(tester, const DetalheImovelState.carregado(detalhe));

      expect(find.byType(ImagemPadraoImovel), findsOneWidget);
      expect(find.byKey(const ValueKey('contador-fotos')), findsNothing);
      expect(find.byTooltip('Voltar'), findsOneWidget);
    });
  });

  group('visualizador em tela cheia (DET-02, D-08)', () {
    const capa = 'https://exemplo.com/capa.jpg';
    const foto2 = 'https://exemplo.com/foto2.jpg';
    const foto3 = 'https://exemplo.com/foto3.jpg';
    final comFotos = detalhe.copyWith(
      fotos: const [
        FotoImovel(url: capa, capa: true),
        FotoImovel(url: foto2, capa: false),
        FotoImovel(url: foto3, capa: false),
      ],
    );

    testWidgets('tocar na segunda foto da galeria abre o visualizador em '
        '2/3', (tester) async {
      await pumpEstado(tester, DetalheImovelState.carregado(comFotos));

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey(foto2)));
      await tester.pumpAndSettle();

      expect(find.byType(VisualizadorFotos), findsOneWidget);
      expect(find.text('2/3'), findsOneWidget);
    });

    testWidgets('sem fotos não há o que tocar: o visualizador não abre', (
      tester,
    ) async {
      await pumpEstado(tester, const DetalheImovelState.carregado(detalhe));

      await tester.tap(find.byType(ImagemPadraoImovel));
      await tester.pumpAndSettle();

      expect(find.byType(VisualizadorFotos), findsNothing);
    });
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

    testWidgets('apartamento mostra um código desconhecido da posição solar '
        'como veio', (tester) async {
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

    testWidgets('apartamento e terreno mostram rótulos em português, nunca o '
        'código da API (A-04)', (tester) async {
      final apto = detalhe.copyWith(
        dados: const DadosNatureza.apartamento(
          posicaoSolar: 'NASCENTE',
          predio: DadosPredio(nome: 'Edifício Girassol', anoConstrucao: 2013),
        ),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(apto),
        altura: 2400,
      );

      expect(find.text('Nascente'), findsOneWidget);
      expect(find.text('NASCENTE'), findsNothing);
      expect(find.text('Ano de construção'), findsOneWidget);
      expect(find.text('2013'), findsOneWidget);
    });

    testWidgets('terreno mostra as duas laterais e o uso permitido em '
        'português', (tester) async {
      final terreno = detalhe.copyWith(
        dados: const DadosNatureza.terreno(
          lateralEsquerda: '25.00',
          lateralDireita: '24.50',
          usoPermitido: 'COMERCIAL',
        ),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(terreno),
        altura: 2400,
      );

      expect(find.text('Lateral esquerda'), findsOneWidget);
      expect(find.text('25 m'), findsOneWidget);
      expect(find.text('Lateral direita'), findsOneWidget);
      expect(find.text('24,5 m'), findsOneWidget);
      expect(find.text('Comercial'), findsOneWidget);
      expect(find.text('COMERCIAL'), findsNothing);
    });

    testWidgets('lote mostra entrada mínima em moeda e parcelas máximas, sem '
        '"Preço do lote"', (tester) async {
      final comParcelas = detalhe.copyWith(
        dados: const DadosNatureza.lote(
          numero: '9',
          entradaMinima: '23500.00',
          parcelasMaximas: 120,
        ),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(comParcelas),
        altura: 2400,
      );

      expect(find.text('Sobre o lote'), findsOneWidget);
      expect(find.text('Entrada mínima'), findsOneWidget);
      expect(find.text('R\$\u00A023.500'), findsOneWidget);
      expect(find.text('Parcelas máximas'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('Preço do lote'), findsNothing);
    });

    testWidgets('lote sem dados de parcelamento não mostra as linhas', (
      tester,
    ) async {
      final semParcelas = detalhe.copyWith(
        dados: const DadosNatureza.lote(numero: '9'),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(semParcelas),
        altura: 2400,
      );

      expect(find.text('Sobre o lote'), findsOneWidget);
      expect(find.text('Entrada mínima'), findsNothing);
      expect(find.text('Parcelas máximas'), findsNothing);
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

  group('prédio e loteamento (DET-04)', () {
    const predio = DadosPredio(
      nome: 'Edifício Jequitibá',
      andares: 12,
      portaria24h: true,
    );

    testWidgets('apartamento com prédio mostra o card "Prédio"', (
      tester,
    ) async {
      final apto = detalhe.copyWith(
        dados: const DadosNatureza.apartamento(andar: 8, predio: predio),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(apto),
        altura: 2400,
      );

      expect(find.text('Prédio'), findsOneWidget);
      expect(find.text('Edifício Jequitibá'), findsOneWidget);
      expect(find.text('Portaria 24h'), findsOneWidget);
      expect(find.text('Sim'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('apartamento sem prédio não mostra "Prédio"', (tester) async {
      final apto = detalhe.copyWith(
        dados: const DadosNatureza.apartamento(andar: 8),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(apto),
        altura: 2400,
      );

      expect(find.text('Sobre o apartamento'), findsOneWidget);
      expect(find.text('Prédio'), findsNothing);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('prédio sem nenhum campo preenchido não mostra o card', (
      tester,
    ) async {
      final apto = detalhe.copyWith(
        dados: const DadosNatureza.apartamento(andar: 8, predio: DadosPredio()),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(apto),
        altura: 2400,
      );

      expect(find.text('Prédio'), findsNothing);
    });

    testWidgets('apartamento só com prédio ainda mostra a seção e o card', (
      tester,
    ) async {
      final apto = detalhe.copyWith(
        dados: const DadosNatureza.apartamento(predio: predio),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(apto),
        altura: 2400,
      );

      expect(find.text('Prédio'), findsOneWidget);
      expect(find.text('Edifício Jequitibá'), findsOneWidget);
    });

    testWidgets('lote 103 mostra o card "Quadra e loteamento" com um Chip por '
        'item da infraestrutura e as áreas de lazer em texto', (tester) async {
      final lote = detalhe.copyWith(
        dados: const DadosNatureza.lote(
          numero: '9',
          quadra: DadosQuadra(
            identificacao: 'Quadra B',
            loteamento: DadosLoteamento(
              nome: 'Residencial Parque das Flores',
              incorporadora: 'Flores Urbanismo',
              infraestrutura: ['Asfalto', 'Água', 'Energia'],
              areasDeLazer: 'Praça central e playground.',
            ),
          ),
        ),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(lote),
        altura: 2400,
      );

      expect(find.text('Quadra e loteamento'), findsOneWidget);
      expect(find.text('Quadra B'), findsOneWidget);
      expect(find.text('Residencial Parque das Flores'), findsOneWidget);
      expect(find.text('Flores Urbanismo'), findsOneWidget);
      expect(find.text('Infraestrutura'), findsOneWidget);
      expect(find.text('Áreas de lazer'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(3));
      expect(find.widgetWithText(Chip, 'Asfalto'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Energia'), findsOneWidget);
      expect(find.text('Praça central e playground.'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Praça central e playground.'),
          findsNothing);
    });

    testWidgets('loteamento sem infraestrutura nem áreas de lazer não mostra '
        'os títulos', (tester) async {
      final lote = detalhe.copyWith(
        dados: const DadosNatureza.lote(
          quadra: DadosQuadra(
            identificacao: 'Quadra B',
            loteamento: DadosLoteamento(nome: 'Parque das Flores'),
          ),
        ),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(lote),
        altura: 2400,
      );

      expect(find.text('Quadra e loteamento'), findsOneWidget);
      expect(find.text('Infraestrutura'), findsNothing);
      expect(find.text('Áreas de lazer'), findsNothing);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('quadra sem linhas e sem listas não mostra o card', (
      tester,
    ) async {
      final lote = detalhe.copyWith(
        dados: const DadosNatureza.lote(numero: '9', quadra: DadosQuadra()),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(lote),
        altura: 2400,
      );

      expect(find.text('Sobre o lote'), findsOneWidget);
      expect(find.text('Quadra e loteamento'), findsNothing);
    });
  });

  group('cabeçalho do detalhe, preços e características (DET-03, D-11)', () {
    final completo = detalhe.copyWith(
      precoCondominio: '850.00',
      precoIptu: '1200.00',
      caracteristicas: const [
        'Portão eletrônico',
        'Ar-condicionado',
        'Varanda gourmet',
      ],
      dados: const DadosNatureza.apartamento(andar: 8),
    );

    testWidgets('carregado mostra preço, condomínio, IPTU e um Chip por '
        'característica', (tester) async {
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(completo),
        altura: 2400,
      );

      expect(find.text('R\$\u00A0450.000'), findsOneWidget);
      expect(find.text('Condomínio R\$\u00A0850/mês'), findsOneWidget);
      expect(find.text('IPTU R\$\u00A01.200'), findsOneWidget);
      expect(find.text('Características'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Portão eletrônico'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Ar-condicionado'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Varanda gourmet'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(3));
    });

    testWidgets('IPTU nunca carrega "/mês" nem "/ano" (D-19 c)', (
      tester,
    ) async {
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(completo),
        altura: 2400,
      );

      expect(find.textContaining('IPTU'), findsOneWidget);
      expect(find.textContaining('IPTU R\$\u00A01.200/'), findsNothing);
    });

    testWidgets('o título e o preço ficam no mesmo lugar de carregando para '
        'carregado (sem pulo, Pitfall 8)', (tester) async {
      final fluxo = StreamController<DetalheImovelState>();
      addTearDown(fluxo.close);
      await pumpEstado(
        tester,
        const DetalheImovelState.carregando(),
        altura: 2400,
        fluxo: fluxo.stream,
      );
      final tituloAntes = tester.getTopLeft(
        find.text('Apartamento 2 quartos no Cambuí'),
      );
      final precoAntes = tester.getTopLeft(find.text('R\$\u00A0450.000'));
      expect(find.textContaining('Condomínio'), findsNothing);
      expect(find.textContaining('IPTU'), findsNothing);

      fluxo.add(DetalheImovelState.carregado(completo));
      await tester.pump();

      expect(
        tester.getTopLeft(find.text('Apartamento 2 quartos no Cambuí')),
        tituloAntes,
      );
      expect(tester.getTopLeft(find.text('R\$\u00A0450.000')), precoAntes);
      expect(find.text('Condomínio R\$\u00A0850/mês'), findsOneWidget);
      expect(find.text('IPTU R\$\u00A01.200'), findsOneWidget);
    });

    testWidgets('VENDA_E_ALUGUEL mostra "Venda ..." e "Aluguel .../mês"', (
      tester,
    ) async {
      final ambos = detalhe.copyWith(
        finalidade: FinalidadeImovel.vendaEAluguel,
        precoVenda: '220000.00',
        precoAluguel: '1500.00',
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(ambos),
        altura: 2400,
      );

      expect(find.text('Venda R\$\u00A0220.000'), findsOneWidget);
      expect(find.text('Aluguel R\$\u00A01.500/mês'), findsOneWidget);
    });

    testWidgets('condomínio e IPTU nulos não mostram linhas de custo', (
      tester,
    ) async {
      await pumpEstado(tester, const DetalheImovelState.carregado(detalhe));

      expect(find.textContaining('Condomínio'), findsNothing);
      expect(find.textContaining('IPTU'), findsNothing);
    });

    testWidgets('características vazias fazem a seção sumir', (tester) async {
      await pumpEstado(tester, const DetalheImovelState.carregado(detalhe));

      expect(find.text('Características'), findsNothing);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('lote: o cabeçalho usa o preço de venda do imóvel e não há '
        'preço próprio do lote (§11.5 d)', (tester) async {
      final lote = detalhe.copyWith(
        titulo: 'Lote em condomínio fechado',
        precoVenda: '210000.00',
        dados: const DadosNatureza.lote(
          numero: '9',
          entradaMinima: '21000.00',
          parcelasMaximas: 60,
        ),
      );
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(lote),
        altura: 2400,
      );

      expect(find.text('R\$\u00A0210.000'), findsOneWidget);
      expect(find.text('Preço do lote'), findsNothing);
      expect(find.text('R\$\u00A021.000'), findsOneWidget);
      // A prévia (R$ 450.000) não vaza para o cabeçalho do detalhe.
      expect(find.text('R\$\u00A0450.000'), findsNothing);
    });

    testWidgets('ordem vertical: natureza < Descrição < Características', (
      tester,
    ) async {
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(completo),
        altura: 2400,
      );

      final natureza = tester.getTopLeft(find.text('Sobre o apartamento')).dy;
      final descricao = tester.getTopLeft(find.text('Descrição')).dy;
      final caracteristicas = tester
          .getTopLeft(find.text('Características'))
          .dy;
      expect(natureza, lessThan(descricao));
      expect(descricao, lessThan(caracteristicas));
    });
  });

  group('corretor responsável (DET-05, D-15)', () {
    const marina = CorretorResponsavel(
      id: 7,
      nome: 'Marina Lopes',
      foto: 'https://exemplo.com/marina.jpg',
    );
    final comCorretor = detalhe.copyWith(
      caracteristicas: const ['Portão eletrônico'],
      corretor: marina,
    );

    testWidgets('carregado com corretor mostra o título e o cartão depois de '
        '"Características"', (tester) async {
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(comCorretor),
        altura: 2400,
      );

      expect(find.text('Corretor responsável'), findsOneWidget);
      expect(find.byType(CartaoCorretor), findsOneWidget);
      expect(find.text('Marina Lopes'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Características')).dy,
        lessThan(tester.getTopLeft(find.text('Corretor responsável')).dy),
      );
      expect(
        find.byKey(const ValueKey('https://exemplo.com/marina.jpg')),
        findsOneWidget,
      );
    });

    testWidgets('sem corretor a seção some', (tester) async {
      await pumpEstado(tester, const DetalheImovelState.carregado(detalhe));

      expect(find.text('Corretor responsável'), findsNothing);
      expect(find.byType(CartaoCorretor), findsNothing);
    });

    testWidgets('tocar no cartão abre o perfil com o nome do detalhe', (
      tester,
    ) async {
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(comCorretor),
        altura: 2400,
      );

      await tester.tap(find.byType(CartaoCorretor));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(PerfilCorretorScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PerfilCorretorScreen),
          matching: find.text('Marina Lopes'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a página não tem barra inferior fixa (D-12)', (tester) async {
      await pumpEstado(
        tester,
        DetalheImovelState.carregado(comCorretor),
        altura: 2400,
      );

      final scaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(DetalheImovelScreen),
          matching: find.byType(Scaffold),
        ),
      );
      expect(scaffold.bottomNavigationBar, isNull);
      expect(scaffold.persistentFooterButtons, isNull);
      expect(scaffold.bottomSheet, isNull);
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
