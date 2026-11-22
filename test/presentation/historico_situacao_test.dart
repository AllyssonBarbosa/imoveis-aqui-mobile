import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/mudanca_situacao_model.dart';
import 'package:imoveis_aqui/domain/entities/mudanca_situacao.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/apresentacao_gestao.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_state.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/widgets/historico_situacao.dart';

import '../support/api_falsa.dart';

/// Itens lidos da fixture capturada do Django, pelo Model (wire real).
List<MudancaSituacao> _daFixture(String nome) =>
    (lerFixtureApi(nome)! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((json) => MudancaSituacaoModel.fromJson(json).paraEntidade())
        .toList();

void main() {
  int toques = 0;

  Future<void> montar(WidgetTester tester, ConteudoHistorico conteudo) async {
    toques = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HistoricoSituacao(
              conteudo: conteudo,
              aoTentarDeNovo: () => toques++,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('carregando mostra o título e um indicador pequeno', (
    tester,
  ) async {
    await montar(tester, const ConteudoHistorico.carregando());

    expect(find.text('Histórico'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('lista vazia mostra o texto de vazio do site (D-11)', (
    tester,
  ) async {
    await montar(tester, const ConteudoHistorico.carregado([]));

    expect(
      find.text('Nenhuma mudança ainda — disponível desde o cadastro.'),
      findsOneWidget,
    );
  });

  testWidgets('item mostra "Anterior → Nova", quando e quem, e a observação', (
    tester,
  ) async {
    final item = _daFixture('historico_contrato.json').single;
    await montar(tester, ConteudoHistorico.carregado([item]));

    expect(find.text('Disponível → Vendido'), findsOneWidget);
    expect(
      find.text('${formatarDataHora(item.alteradoEm)} · Gestor Demo'),
      findsOneWidget,
    );
    expect(
      find.text('Contrato #1 de venda assinado em 01/07/2026.'),
      findsOneWidget,
    );
  });

  testWidgets('a ordem é a da lista recebida, sem reordenar (D-11)', (
    tester,
  ) async {
    // Servidor: o contrato (mais antigo) vem ANTES do item mais novo.
    final itens = [
      ..._daFixture('historico_contrato.json'),
      ..._daFixture('historico_um_item.json'),
    ];
    await montar(tester, ConteudoHistorico.carregado(itens));

    final primeiro = tester.getTopLeft(find.text('Disponível → Vendido'));
    final segundo = tester.getTopLeft(find.text('Disponível → Reservado'));
    expect(primeiro.dy, lessThan(segundo.dy));
  });

  testWidgets('sem nome só a data; sem observação nada além do de → para; '
      'situação nula vira "—"', (tester) async {
    final quando = DateTime.utc(2026, 11, 22, 15, 25);
    final item = MudancaSituacao(
      id: 9,
      situacaoAnterior: null,
      situacaoNova: SituacaoImovel.alugado,
      alteradoEm: quando,
      observacao: '',
    );
    await montar(tester, ConteudoHistorico.carregado([item]));

    expect(find.text('— → Alugado'), findsOneWidget);
    expect(find.text(formatarDataHora(quando)), findsOneWidget);
    expect(find.textContaining(' · '), findsNothing);
  });

  testWidgets('erro mostra o texto fixo e "Tentar de novo" chama o callback', (
    tester,
  ) async {
    await montar(tester, const ConteudoHistorico.erro());

    expect(find.text('Não foi possível carregar o histórico.'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));

    expect(toques, 1);
  });

  testWidgets('observação é texto simples: marcação do servidor aparece como '
      'veio (T-09-13)', (tester) async {
    final item = MudancaSituacao(
      id: 3,
      situacaoAnterior: SituacaoImovel.disponivel,
      situacaoNova: SituacaoImovel.reservado,
      alteradoPor: 'Fulano',
      alteradoEm: DateTime.utc(2026, 11, 22, 15, 25),
      observacao: '<b>oi</b> [link](http://x.test)',
    );
    await montar(tester, ConteudoHistorico.carregado([item]));

    expect(find.text('<b>oi</b> [link](http://x.test)'), findsOneWidget);
    expect(find.byType(RichText), findsWidgets);
  });
}
