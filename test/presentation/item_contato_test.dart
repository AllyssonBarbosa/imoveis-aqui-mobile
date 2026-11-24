import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/app_theme.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/contato_recebido.dart';
import 'package:imoveis_aqui/domain/entities/retorno_contato.dart';
import 'package:imoveis_aqui/presentation/contatos/widgets/item_contato.dart';
import 'package:imoveis_aqui/presentation/perfis/widgets/rodape_paginacao_lista.dart';

ContatoRecebido _contato({
  String titulo = 'Apartamento 2 quartos no Cambuí',
  CanalContato canal = CanalContato.whatsapp,
  RetornoContato retorno = RetornoContato.pendente,
  DateTime? retornoEm,
}) => ContatoRecebido(
  id: 7,
  imovelCodigo: 'DEV-CAMPINAS-14',
  imovelTitulo: titulo,
  canal: canal,
  criadoEm: DateTime(2026, 11, 22, 8, 5),
  retorno: retorno,
  retornoEm: retornoEm,
);

void main() {
  Future<void> montar(
    WidgetTester tester,
    ContatoRecebido contato, {
    VoidCallback? aoTocar,
    bool anotando = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.tema,
        home: Scaffold(
          body: ItemContato(
            contato: contato,
            aoTocar: aoTocar,
            anotando: anotando,
          ),
        ),
      ),
    );
  }

  group('ItemContato', () {
    testWidgets('pendente mostra codigo, titulo, canal, data e chip', (
      tester,
    ) async {
      await montar(tester, _contato());

      expect(
        find.text('DEV-CAMPINAS-14 — Apartamento 2 quartos no Cambuí'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.chat), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('22/11/2026 08:05'), findsOneWidget);
      expect(find.text('Aguardando retorno'), findsOneWidget);
      expect(find.textContaining('anotado em'), findsNothing);
    });

    testWidgets('chip pendente usa a cor de destaque do ColorScheme', (
      tester,
    ) async {
      await montar(tester, _contato());

      final esquema = Theme.of(tester.element(find.byType(ItemContato)))
          .colorScheme;
      final texto = tester.widget<Text>(find.text('Aguardando retorno'));
      expect(texto.style?.color, esquema.onTertiaryContainer);
      final caixa = tester.widget<DecoratedBox>(
        find.ancestor(
          of: find.text('Aguardando retorno'),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        (caixa.decoration as BoxDecoration).color,
        esquema.tertiaryContainer,
      );
    });

    testWidgets('retorno anotado mostra rotulo e "anotado em"', (tester) async {
      await montar(
        tester,
        _contato(
          canal: CanalContato.telefone,
          retorno: RetornoContato.falei,
          retornoEm: DateTime(2026, 11, 23, 9, 0),
        ),
      );

      expect(find.text('Falei'), findsOneWidget);
      expect(find.text('anotado em 23/11/2026 09:00'), findsOneWidget);
      expect(find.byIcon(Icons.call), findsOneWidget);
      expect(find.text('Telefone'), findsOneWidget);
      expect(find.text('Aguardando retorno'), findsNothing);
    });

    testWidgets('titulo longo fica em no maximo 2 linhas com reticencias', (
      tester,
    ) async {
      await montar(tester, _contato(titulo: 'Casa muito grande ' * 20));

      final texto = tester.widget<Text>(
        find.textContaining('DEV-CAMPINAS-14 — Casa muito grande'),
      );
      expect(texto.maxLines, 2);
      expect(texto.overflow, TextOverflow.ellipsis);
    });

    testWidgets('sem aoTocar, tocar nao faz nada; com aoTocar, chama', (
      tester,
    ) async {
      await montar(tester, _contato());
      await tester.tap(find.byType(ItemContato));
      await tester.pump();
      expect(tester.takeException(), isNull);

      var toques = 0;
      await montar(tester, _contato(), aoTocar: () => toques++);
      await tester.tap(find.byType(ItemContato));
      await tester.pump();
      expect(toques, 1);
    });
  });

  group('ItemContato em voo (D-16)', () {
    testWidgets('sem anotando não mostra carregamento', (tester) async {
      await montar(tester, _contato(), aoTocar: () {});

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('anotando mostra o carregamento e ignora o toque', (
      tester,
    ) async {
      var toques = 0;
      await montar(tester, _contato(), aoTocar: () => toques++, anotando: true);

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(ItemContato));
      await tester.pump();
      expect(toques, 0);
    });
  });

  group('RodapePaginacaoLista.mensagemErro', () {
    Future<void> montarRodape(WidgetTester tester, {String? mensagemErro}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: mensagemErro == null
                ? RodapePaginacaoLista(
                    carregandoMais: false,
                    erroAoCarregarMais: true,
                    temProximaPagina: true,
                    aoTentarDeNovo: () {},
                  )
                : RodapePaginacaoLista(
                    carregandoMais: false,
                    erroAoCarregarMais: true,
                    temProximaPagina: true,
                    aoTentarDeNovo: () {},
                    mensagemErro: mensagemErro,
                  ),
          ),
        ),
      );
    }

    testWidgets('sem mensagemErro mantem o texto de imoveis', (tester) async {
      await montarRodape(tester);
      expect(
        find.text('Não foi possível carregar mais imóveis'),
        findsOneWidget,
      );
    });

    testWidgets('com mensagemErro mostra o texto dado', (tester) async {
      await montarRodape(
        tester,
        mensagemErro: 'Não foi possível carregar mais contatos',
      );
      expect(
        find.text('Não foi possível carregar mais contatos'),
        findsOneWidget,
      );
      expect(find.text('Não foi possível carregar mais imóveis'), findsNothing);
    });
  });
}
