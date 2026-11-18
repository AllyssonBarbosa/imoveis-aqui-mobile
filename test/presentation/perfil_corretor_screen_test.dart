import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/entities/contato_do_imovel.dart';
import 'package:imoveis_aqui/domain/entities/detalhe_imovel.dart';
import 'package:imoveis_aqui/presentation/contato/contato_cubit.dart';
import 'package:imoveis_aqui/presentation/contato/contato_state.dart';
import 'package:imoveis_aqui/presentation/contato/widgets/barra_contato.dart';
import 'package:imoveis_aqui/presentation/detalhe_imovel/perfil_corretor_screen.dart';
import 'package:mocktail/mocktail.dart';

class _ContatoCubitFalso extends MockCubit<ContatoState>
    implements ContatoCubit {}

/// Imagem determinística: uma caixa com a chave da própria url.
Widget _caixaDaUrl(String url) =>
    ColoredBox(key: ValueKey(url), color: Colors.blue);

void main() {
  late _ContatoCubitFalso contatoCubit;

  setUpAll(() {
    registerFallbackValue(CanalContato.whatsapp);
  });

  setUp(() {
    contatoCubit = _ContatoCubitFalso();
    whenListen(
      contatoCubit,
      const Stream<ContatoState>.empty(),
      initialState: const ContatoState.ocioso(),
    );
    when(() => contatoCubit.contatar(any(), any())).thenAnswer((_) async {});
  });

  const marina = CorretorResponsavel(
    id: 7,
    nome: 'Marina Lopes',
    foto: 'https://exemplo.com/marina.jpg',
  );
  const semFoto = CorretorResponsavel(id: 9, nome: 'Camila Duarte');

  /// Abre o perfil por cima de uma página-base, como o detalhe faz, para que
  /// o botão voltar tenha para onde voltar.
  Future<void> abrirPerfil(
    WidgetTester tester,
    CorretorResponsavel corretor, {
    ContatoDoImovel? contato,
    ContatoCubit Function()? criarContatoCubit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => abrirPerfilCorretor(
                  context,
                  corretor,
                  contato: contato,
                  criarContatoCubit: criarContatoCubit,
                  construirImagemDeRede: _caixaDaUrl,
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

  testWidgets('mostra AppBar "Corretor", avatar grande e o nome em '
      'headlineSmall', (tester) async {
    await abrirPerfil(tester, marina);

    expect(find.byType(PerfilCorretorScreen), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Corretor')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('https://exemplo.com/marina.jpg')),
      findsOneWidget,
    );
    final nome = tester.widget<Text>(find.text('Marina Lopes'));
    final tema = Theme.of(tester.element(find.text('Marina Lopes')));
    expect(nome.style, tema.textTheme.headlineSmall);
  });

  testWidgets('não mostra nenhum dado de contato (T-04-08-01)', (tester) async {
    await abrirPerfil(tester, marina);

    final textos = tester
        .widgetList<Text>(find.byType(Text))
        .map((texto) => (texto.data ?? '').toLowerCase())
        .toList();
    for (final proibido in ['@', 'whatsapp', 'telefone', 'creci', 'e-mail']) {
      expect(
        textos.where((texto) => texto.contains(proibido)),
        isEmpty,
        reason: 'a tela de perfil não pode mostrar "$proibido"',
      );
    }
  });

  testWidgets('corretor sem foto abre do mesmo jeito (D-19 a)', (tester) async {
    await abrirPerfil(tester, semFoto);

    expect(find.byType(PerfilCorretorScreen), findsOneWidget);
    expect(find.text('Camila Duarte'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('o botão voltar fecha o perfil', (tester) async {
    await abrirPerfil(tester, marina);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PerfilCorretorScreen), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
  });

  group('barra de contato no perfil (APP 06, D-09, D-10)', () {
    const apartamento = ContatoDoImovel(
      imovelId: 42,
      titulo: 'Apartamento no Cambuí',
      canais: [CanalContato.whatsapp, CanalContato.email],
    );

    testWidgets('sem imóvel de origem não há barra de contato', (tester) async {
      await abrirPerfil(tester, marina);

      expect(find.byType(BarraContato), findsNothing);
      expect(
        find.descendant(
          of: find.byType(PerfilCorretorScreen),
          matching: find.byType(FilledButton),
        ),
        findsNothing,
      );
    });

    testWidgets('com imóvel e canais mostra "Sobre: <título>" na barra, o '
        'WhatsApp principal e o ⋮', (tester) async {
      await abrirPerfil(
        tester,
        marina,
        contato: apartamento,
        criarContatoCubit: () => contatoCubit,
      );

      final barra = find.descendant(
        of: find.byType(PerfilCorretorScreen),
        matching: find.byType(BarraContato),
      );
      expect(barra, findsOneWidget);
      expect(
        find.descendant(
          of: barra,
          matching: find.text('Sobre: Apartamento no Cambuí'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: barra,
          matching: find.widgetWithText(FilledButton, 'WhatsApp'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: barra,
          matching: find.byTooltip('Mais formas de contato'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tocar em WhatsApp chama contatar com o id do imóvel de '
        'origem e o canal', (tester) async {
      await abrirPerfil(
        tester,
        marina,
        contato: apartamento,
        criarContatoCubit: () => contatoCubit,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'WhatsApp'));
      await tester.pump();

      verify(() => contatoCubit.contatar(42, CanalContato.whatsapp)).called(1);
    });

    testWidgets('com a barra o perfil continua sem número, e-mail ou CRECI '
        '(T-06-09-01)', (tester) async {
      await abrirPerfil(
        tester,
        marina,
        contato: apartamento,
        criarContatoCubit: () => contatoCubit,
      );

      final textos = tester
          .widgetList<Text>(find.byType(Text))
          .map((texto) => (texto.data ?? '').toLowerCase())
          .toList();
      for (final proibido in ['@', 'creci', 'tel:', 'wa.me', 'mailto:']) {
        expect(
          textos.where((texto) => texto.contains(proibido)),
          isEmpty,
          reason: 'a tela de perfil não pode mostrar "$proibido"',
        );
      }
    });

    testWidgets('com canais vazios não há barra e o DI não é tocado', (
      tester,
    ) async {
      var criou = false;
      await abrirPerfil(
        tester,
        marina,
        contato: const ContatoDoImovel(
          imovelId: 42,
          titulo: 'Apartamento no Cambuí',
          canais: [],
        ),
        criarContatoCubit: () {
          criou = true;
          return contatoCubit;
        },
      );

      expect(find.byType(PerfilCorretorScreen), findsOneWidget);
      expect(find.byType(BarraContato), findsNothing);
      expect(criou, isFalse);
    });

    testWidgets('título de 200 caracteres em 360 dp de largura não estoura '
        'o layout', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await abrirPerfil(
        tester,
        marina,
        contato: ContatoDoImovel(
          imovelId: 42,
          titulo: 'A' * 200,
          canais: const [CanalContato.whatsapp, CanalContato.email],
        ),
        criarContatoCubit: () => contatoCubit,
      );

      expect(find.byType(BarraContato), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
