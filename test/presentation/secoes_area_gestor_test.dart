import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/app_theme.dart';
import 'package:imoveis_aqui/data/models/acervo_por_corretor_model.dart';
import 'package:imoveis_aqui/data/models/contatos_por_corretor_model.dart';
import 'package:imoveis_aqui/data/models/mudancas_recentes_model.dart';
import 'package:imoveis_aqui/data/models/totais_por_situacao_model.dart';
import 'package:imoveis_aqui/domain/entities/acervo_por_corretor.dart';
import 'package:imoveis_aqui/domain/entities/contatos_por_corretor.dart';
import 'package:imoveis_aqui/domain/entities/mudancas_recentes.dart';
import 'package:imoveis_aqui/domain/entities/periodo_contatos.dart';
import 'package:imoveis_aqui/domain/entities/totais_por_situacao.dart';
import 'package:imoveis_aqui/presentation/area_gestor/apresentacao_area_gestor.dart';
import 'package:imoveis_aqui/presentation/area_gestor/area_gestor_state.dart';
import 'package:imoveis_aqui/presentation/area_gestor/widgets/moldura_secao.dart';
import 'package:imoveis_aqui/presentation/area_gestor/widgets/secao_acervo_corretores.dart';
import 'package:imoveis_aqui/presentation/area_gestor/widgets/secao_contatos_corretores.dart';
import 'package:imoveis_aqui/presentation/area_gestor/widgets/secao_mudancas.dart';
import 'package:imoveis_aqui/presentation/area_gestor/widgets/secao_totais.dart';
import 'package:imoveis_aqui/presentation/contatos/apresentacao_contatos.dart';

import '../support/api_falsa.dart';

Map<String, Object?> _fixture(String nome) =>
    lerFixtureApi(nome)! as Map<String, Object?>;

TotaisPorSituacao _totais() =>
    TotaisPorSituacaoModel.fromJson(_fixture('relatorio_acervo.json'))
        .paraEntidade();

AcervoPorCorretor _acervo() =>
    AcervoPorCorretorModel.fromJson(
      _fixture('relatorio_acervo_por_corretor.json'),
    ).paraEntidade();

ContatosPorCorretor _contatos() =>
    ContatosPorCorretorModel.fromJson(_fixture('relatorio_contatos.json'))
        .paraEntidade();

MudancasRecentes _mudancas() =>
    MudancasRecentesModel.fromJson(_fixture('relatorio_mudancas.json'))
        .paraEntidade();

class _ObservadorDeRotas extends NavigatorObserver {
  int empurradas = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    empurradas++;
  }
}

void main() {
  late _ObservadorDeRotas observador;

  setUp(() => observador = _ObservadorDeRotas());

  Future<void> montar(WidgetTester tester, Widget secao) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.tema,
        navigatorObservers: [observador],
        home: Scaffold(body: SingleChildScrollView(child: secao)),
      ),
    );
  }

  group('MolduraSecao', () {
    Widget moldura(
      EstadoSecao<int> estado, {
      VoidCallback? aoTentarDeNovo,
      Widget? cabecalho,
    }) => MolduraSecao<int>(
      titulo: 'Título da seção',
      estado: estado,
      aoTentarDeNovo: aoTentarDeNovo ?? () {},
      cabecalho: cabecalho,
      construirConteudo: (dados) => Text('dados $dados'),
    );

    testWidgets('carregando mostra o título e o indicador', (tester) async {
      await montar(tester, moldura(const EstadoSecao<int>.carregando()));

      expect(find.text('Título da seção'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(rotuloTentarDeNovoSecao), findsNothing);
    });

    testWidgets('falha sem permissão mostra o texto fixo e "Tentar de novo"', (
      tester,
    ) async {
      await montar(
        tester,
        moldura(const EstadoSecao<int>.comFalha(FalhaDaSecao.semPermissao)),
      );

      expect(
        find.text('Só o gestor da imobiliária pode ver estes números.'),
        findsOneWidget,
      );
      expect(find.text('Tentar de novo'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('falha indisponível mostra "Não foi possível carregar."', (
      tester,
    ) async {
      await montar(
        tester,
        moldura(const EstadoSecao<int>.comFalha(FalhaDaSecao.indisponivel)),
      );

      expect(find.text('Não foi possível carregar.'), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
    });

    testWidgets('tocar em "Tentar de novo" chama o callback uma vez', (
      tester,
    ) async {
      var chamadas = 0;
      await montar(
        tester,
        moldura(
          const EstadoSecao<int>.comFalha(FalhaDaSecao.indisponivel),
          aoTentarDeNovo: () => chamadas++,
        ),
      );

      await tester.tap(find.text('Tentar de novo'));
      await tester.pump();

      expect(chamadas, 1);
    });

    testWidgets('carregada mostra o conteúdo da seção', (tester) async {
      await montar(tester, moldura(const EstadoSecao<int>.carregada(7)));

      expect(find.text('dados 7'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('o cabeçalho aparece nos três estados', (tester) async {
      const cabecalho = Text('cabeçalho fixo');
      for (final estado in const [
        EstadoSecao<int>.carregando(),
        EstadoSecao<int>.comFalha(FalhaDaSecao.indisponivel),
        EstadoSecao<int>.carregada(1),
      ]) {
        await montar(tester, moldura(estado, cabecalho: cabecalho));
        expect(find.text('cabeçalho fixo'), findsOneWidget);
      }
    });
  });

  group('SecaoTotais (D-10)', () {
    testWidgets('mostra os 4 blocos na ordem e o total do servidor', (
      tester,
    ) async {
      await montar(
        tester,
        SecaoTotais(
          estado: EstadoSecao.carregada(_totais()),
          aoTentarDeNovo: () {},
        ),
      );

      expect(find.text(tituloSecaoTotais), findsOneWidget);
      final disponivel = tester.getTopLeft(find.text('Disponível'));
      final reservado = tester.getTopLeft(find.text('Reservado'));
      final vendido = tester.getTopLeft(find.text('Vendido'));
      final alugado = tester.getTopLeft(find.text('Alugado'));
      // Grade 2x2: Disponível e Reservado na 1ª linha, Vendido e Alugado na 2ª.
      expect(reservado.dx, greaterThan(disponivel.dx));
      expect(reservado.dy, disponivel.dy);
      expect(vendido.dy, greaterThan(disponivel.dy));
      expect(alugado.dx, greaterThan(vendido.dx));
      expect(alugado.dy, vendido.dy);

      expect(find.text('33'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text(textoTotalImoveis(36)), findsOneWidget);
    });

    testWidgets('em falha mostra o título e o "Tentar de novo"', (
      tester,
    ) async {
      await montar(
        tester,
        SecaoTotais(
          estado: const EstadoSecao.comFalha(FalhaDaSecao.indisponivel),
          aoTentarDeNovo: () {},
        ),
      );

      expect(find.text(tituloSecaoTotais), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
    });
  });

  group('SecaoAcervoCorretores (D-14)', () {
    testWidgets('mostra nome, marca de desativado, singular, zero e total', (
      tester,
    ) async {
      await montar(
        tester,
        SecaoAcervoCorretores(
          estado: EstadoSecao.carregada(_acervo()),
          aoTentarDeNovo: () {},
        ),
      );

      expect(find.text(tituloSecaoAcervo), findsOneWidget);
      expect(find.text('Corretor Vitrine Demo'), findsOneWidget);
      expect(find.text('35 imóveis'), findsOneWidget);
      expect(find.text('Corretor Desativado Demo (desativado)'), findsOneWidget);
      expect(find.text('1 imóvel'), findsOneWidget);
      expect(find.text('Corretor Sem Acervo'), findsOneWidget);
      expect(find.text('Nenhum imóvel'), findsOneWidget);
      expect(find.text(textoTotalImoveis(36)), findsOneWidget);
    });

    testWidgets('sem linhas mostra "Nenhum corretor cadastrado."', (
      tester,
    ) async {
      await montar(
        tester,
        SecaoAcervoCorretores(
          estado: EstadoSecao.carregada(AcervoPorCorretor(linhas: [], total: 0)),
          aoTentarDeNovo: () {},
        ),
      );

      expect(find.text(textoNenhumCorretor), findsOneWidget);
    });

    testWidgets('tocar numa linha não empurra nenhuma rota (D-08)', (
      tester,
    ) async {
      await montar(
        tester,
        SecaoAcervoCorretores(
          estado: EstadoSecao.carregada(_acervo()),
          aoTentarDeNovo: () {},
        ),
      );
      final antes = observador.empurradas;

      await tester.tap(find.text('Corretor Vitrine Demo'));
      await tester.pump();

      expect(observador.empurradas, antes);
    });
  });

  group('SecaoContatosCorretores (D-16, D-17)', () {
    Widget secao({
      EstadoSecao<ContatosPorCorretor>? estado,
      PeriodoContatos? periodo,
      VoidCallback? aoTocarPeriodo,
      VoidCallback? aoLimparPeriodo,
    }) => SecaoContatosCorretores(
      estado: estado ?? EstadoSecao.carregada(_contatos()),
      periodo: periodo,
      aoTocarPeriodo: aoTocarPeriodo ?? () {},
      aoLimparPeriodo: aoLimparPeriodo ?? () {},
      aoTentarDeNovo: () {},
    );

    testWidgets('sem período: chip "Período" sem "x", linhas e rodapé', (
      tester,
    ) async {
      await montar(tester, secao());

      expect(find.text(tituloSecaoContatos), findsOneWidget);
      expect(find.text('Período'), findsOneWidget);
      expect(find.byTooltip(tooltipLimparPeriodo), findsNothing);
      expect(find.text('Todo o período.'), findsOneWidget);
      expect(find.text('Corretor Vitrine Demo'), findsOneWidget);
      expect(find.text(textoContatosDoCorretor(3, 2)), findsOneWidget);
      expect(find.text(textoLinhaDaEmpresa), findsOneWidget);
      expect(find.text(textoContatosDoCorretor(1, 1)), findsOneWidget);
      expect(find.text('Corretor Sem Acervo'), findsOneWidget);
      expect(find.text(textoContatosDoCorretor(0, 0)), findsOneWidget);
      expect(find.text(textoTotalContatos(4, 3)), findsOneWidget);
    });

    testWidgets('com período: datas no chip, linha do período e "x"', (
      tester,
    ) async {
      var limpou = 0;
      await montar(
        tester,
        secao(
          periodo: PeriodoContatos(
            de: DateTime(2026, 11),
            ate: DateTime(2026, 11, 25),
          ),
          aoLimparPeriodo: () => limpou++,
        ),
      );

      expect(find.text('01/11/2026 – 25/11/2026'), findsOneWidget);
      expect(find.text('Período: 01/11/2026 a 25/11/2026.'), findsOneWidget);

      await tester.tap(find.byTooltip(tooltipLimparPeriodo));
      await tester.pump();
      expect(limpou, 1);
    });

    testWidgets('tocar no chip chama aoTocarPeriodo', (tester) async {
      var toques = 0;
      await montar(tester, secao(aoTocarPeriodo: () => toques++));

      await tester.tap(find.text('Período'));
      await tester.pump();

      expect(toques, 1);
    });

    testWidgets('com a seção em falha, o chip e a linha do período ficam', (
      tester,
    ) async {
      await montar(
        tester,
        secao(
          estado: const EstadoSecao.comFalha(FalhaDaSecao.indisponivel),
        ),
      );

      expect(find.text('Período'), findsOneWidget);
      expect(find.text('Todo o período.'), findsOneWidget);
      expect(find.text('Não foi possível carregar.'), findsOneWidget);
    });

    testWidgets('sem linhas mostra "Nenhum corretor cadastrado."', (
      tester,
    ) async {
      await montar(
        tester,
        secao(
          estado: EstadoSecao.carregada(
            ContatosPorCorretor(linhas: [], total: 0, pendentes: 0),
          ),
        ),
      );

      expect(find.text(textoNenhumCorretor), findsOneWidget);
    });

    testWidgets('tocar numa linha não empurra nenhuma rota (D-08)', (
      tester,
    ) async {
      await montar(tester, secao());
      final antes = observador.empurradas;

      await tester.tap(find.text('Corretor Vitrine Demo'));
      await tester.tap(find.text(textoLinhaDaEmpresa));
      await tester.pump();

      expect(observador.empurradas, antes);
    });
  });

  group('SecaoMudancas (D-21)', () {
    testWidgets('mostra título com os dias do servidor e cada item', (
      tester,
    ) async {
      final mudancas = _mudancas();
      await montar(
        tester,
        SecaoMudancas(
          estado: EstadoSecao.carregada(mudancas),
          aoTentarDeNovo: () {},
        ),
      );

      expect(find.text(tituloSecaoMudancas(7)), findsOneWidget);
      for (final mudanca in mudancas.mudancas) {
        expect(find.text(rotuloImovelDaMudanca(mudanca)), findsOneWidget);
        expect(find.text(textoQuandoEQuemMudanca(mudanca)), findsOneWidget);
      }
      expect(find.text('Disponível → Vendido'), findsOneWidget);
      expect(find.text('Disponível → Reservado'), findsOneWidget);
      // A observação só aparece quando existe: uma das duas mudanças a tem.
      expect(
        find.text('Captura APP-12: reserva para o relatório do gestor.'),
        findsOneWidget,
      );
    });

    testWidgets('lista vazia mostra a frase do servidor com os dias', (
      tester,
    ) async {
      await montar(
        tester,
        SecaoMudancas(
          estado: EstadoSecao.carregada(MudancasRecentes(dias: 7, mudancas: [])),
          aoTentarDeNovo: () {},
        ),
      );

      expect(find.text(tituloSecaoMudancas(7)), findsOneWidget);
      expect(find.text(textoNenhumaMudanca(7)), findsOneWidget);
    });

    testWidgets('carregando e em falha usam o título sem número', (
      tester,
    ) async {
      await montar(
        tester,
        SecaoMudancas(
          estado: const EstadoSecao.carregando(),
          aoTentarDeNovo: () {},
        ),
      );
      expect(find.text(tituloSecaoMudancas(null)), findsOneWidget);

      await montar(
        tester,
        SecaoMudancas(
          estado: const EstadoSecao.comFalha(FalhaDaSecao.indisponivel),
          aoTentarDeNovo: () {},
        ),
      );
      expect(find.text(tituloSecaoMudancas(null)), findsOneWidget);
      expect(find.text('Tentar de novo'), findsOneWidget);
    });

    testWidgets('tocar num item não empurra nenhuma rota (D-08)', (
      tester,
    ) async {
      final mudancas = _mudancas();
      await montar(
        tester,
        SecaoMudancas(
          estado: EstadoSecao.carregada(mudancas),
          aoTentarDeNovo: () {},
        ),
      );
      final antes = observador.empurradas;

      await tester.tap(find.text(rotuloImovelDaMudanca(mudancas.mudancas[0])));
      await tester.pump();

      expect(observador.empurradas, antes);
    });
  });
}
