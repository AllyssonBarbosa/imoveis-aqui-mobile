import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/anunciante_ref.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/perfil_empresa.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_empresa_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_empresa_screen.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_state.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/vitrine_anunciante_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/imovel_card.dart';
import 'package:mocktail/mocktail.dart';

class _PerfilEmpresaCubitFalso extends MockCubit<PerfilState<PerfilEmpresa>>
    implements PerfilEmpresaCubit {}

class _VitrineAnuncianteCubitFalso extends MockCubit<VitrineAnuncianteState>
    implements VitrineAnuncianteCubit {}

/// Imagem determinística: uma caixa com a chave da própria url.
Widget _caixaDaUrl(String url) =>
    ColoredBox(key: ValueKey(url), color: Colors.blue);

void main() {
  // Entidades montadas direto no teste — nunca a fixture do servidor simulado.
  const jequitiba = PerfilEmpresa(
    id: 3,
    tipo: TipoEmpresa.imobiliaria,
    nome: 'Imobiliária Jequitibá',
    creci: 'J-1234',
    logomarca: 'https://exemplo.com/jequitiba.png',
  );
  const camila = PerfilEmpresa(
    id: 4,
    tipo: TipoEmpresa.autonomo,
    nome: 'Camila Duarte',
  );

  // Empresa completa (como a 3 do servidor simulado), montada no teste.
  const jequitibaCompleta = PerfilEmpresa(
    id: 3,
    tipo: TipoEmpresa.imobiliaria,
    nome: 'Imobiliária Jequitibá',
    creci: 'J-1234',
    telefone: '(19) 3333-0000',
    whatsapp: '19988880000',
    email: 'contato@jequitiba.exemplo.com',
    descricao: 'Imobiliária com 20 anos de atuação.',
    cidadesAtuacao: [
      Cidade(nome: 'Campinas', uf: 'SP'),
      Cidade(nome: 'Valinhos', uf: 'SP'),
      Cidade(nome: 'Vinhedo', uf: 'SP'),
    ],
  );
  // Autônoma com omissões: sem descrição nem telefone, uma cidade.
  const camilaCompleta = PerfilEmpresa(
    id: 4,
    tipo: TipoEmpresa.autonomo,
    nome: 'Camila Duarte',
    creci: '34567-F',
    whatsapp: '19977776666',
    email: 'contato@camiladuarte.exemplo.com',
    cidadesAtuacao: [Cidade(nome: 'Vinhedo', uf: 'SP')],
  );

  late _PerfilEmpresaCubitFalso cubit;
  late _VitrineAnuncianteCubitFalso vitrine;
  var vitrinesCriadas = 0;
  final imoveisAbertos = <int>[];

  setUp(() {
    registerFallbackValue(const AnuncianteRef.empresa(0));
    vitrine = _VitrineAnuncianteCubitFalso();
    vitrinesCriadas = 0;
    imoveisAbertos.clear();
    when(() => vitrine.carregar(any())).thenAnswer((_) async {});
    when(() => vitrine.tentarNovamente()).thenAnswer((_) async {});
    cubit = _PerfilEmpresaCubitFalso();
    when(() => cubit.carregar(any())).thenAnswer((_) async {});
    when(() => cubit.tentarNovamente()).thenAnswer((_) async {});
  });

  /// Abre a página por cima de uma página-base, como o perfil do corretor
  /// faz, para o botão voltar ter para onde voltar.
  Future<void> abrirEmpresa(
    WidgetTester tester,
    PerfilState<PerfilEmpresa> estado, {
    int empresaId = 3,
    // Padrão `vazia`: sem spinner da vitrine nos testes do perfil em si.
    VitrineAnuncianteState estadoVitrine = const VitrineAnuncianteState.vazia(),
  }) async {
    // Janela alta: os slivers são lazy e a vitrine cai abaixo da dobra.
    tester.view.physicalSize = const Size(400, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    whenListen(
      cubit,
      const Stream<PerfilState<PerfilEmpresa>>.empty(),
      initialState: estado,
    );
    whenListen(
      vitrine,
      const Stream<VitrineAnuncianteState>.empty(),
      initialState: estadoVitrine,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => abrirPerfilEmpresa(
                  context,
                  empresaId,
                  criarPerfilEmpresaCubit: () => cubit,
                  criarVitrineCubit: () {
                    vitrinesCriadas++;
                    return vitrine;
                  },
                  aoAbrirImovel: (context, imovel) async {
                    imoveisAbertos.add(imovel.id);
                  },
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

  Finder naPagina(Finder alvo) =>
      find.descendant(of: find.byType(PerfilEmpresaScreen), matching: alvo);

  testWidgets('abrirPerfilEmpresa empilha a página e carrega a empresa uma vez '
      'pelo id; o botão voltar fecha a página', (tester) async {
    await abrirEmpresa(tester, const PerfilState.carregando(), empresaId: 3);

    expect(find.byType(PerfilEmpresaScreen), findsOneWidget);
    expect(
      naPagina(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Anunciante'),
        ),
      ),
      findsOneWidget,
    );
    verify(() => cubit.carregar(3)).called(1);

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PerfilEmpresaScreen), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
  });

  testWidgets('carregando mostra só o spinner, sem nome nem tipo', (
    tester,
  ) async {
    await abrirEmpresa(tester, const PerfilState.carregando());

    expect(naPagina(find.byType(CircularProgressIndicator)), findsOneWidget);
    expect(naPagina(find.text('Imobiliária Jequitibá')), findsNothing);
    expect(naPagina(find.text('Imobiliária')), findsNothing);
    expect(naPagina(find.textContaining('CRECI')), findsNothing);
  });

  testWidgets('imobiliária carregada: logomarca pela url, nome em '
      'headlineSmall, tipo e CRECI', (tester) async {
    await abrirEmpresa(tester, const PerfilState.carregado(jequitiba));

    expect(
      naPagina(find.byKey(const ValueKey('https://exemplo.com/jequitiba.png'))),
      findsOneWidget,
    );
    expect(naPagina(find.byIcon(Icons.apartment_outlined)), findsNothing);
    final nome = tester.widget<Text>(
      naPagina(find.text('Imobiliária Jequitibá')),
    );
    expect(
      nome.style,
      Theme.of(tester.element(naPagina(find.byType(Scaffold))))
          .textTheme
          .headlineSmall,
    );
    expect(naPagina(find.text('Imobiliária')), findsOneWidget);
    expect(naPagina(find.text('CRECI J-1234')), findsOneWidget);
    expect(naPagina(find.byType(CircularProgressIndicator)), findsNothing);
  });

  testWidgets('autônomo sem logomarca: "Corretor autônomo" e o ícone de '
      'prédio, sem CRECI', (tester) async {
    await abrirEmpresa(
      tester,
      const PerfilState.carregado(camila),
      empresaId: 4,
    );

    expect(naPagina(find.text('Camila Duarte')), findsOneWidget);
    expect(naPagina(find.text('Corretor autônomo')), findsOneWidget);
    expect(naPagina(find.text('Imobiliária')), findsNothing);
    expect(naPagina(find.byIcon(Icons.apartment_outlined)), findsOneWidget);
    expect(naPagina(find.textContaining('CRECI')), findsNothing);
  });

  testWidgets('tipo desconhecido (nulo): sem rótulo de tipo', (tester) async {
    await abrirEmpresa(
      tester,
      const PerfilState.carregado(PerfilEmpresa(id: 5, nome: 'Sem Tipo')),
      empresaId: 5,
    );

    expect(naPagina(find.text('Sem Tipo')), findsOneWidget);
    expect(naPagina(find.text('Imobiliária')), findsNothing);
    expect(naPagina(find.text('Corretor autônomo')), findsNothing);
  });

  testWidgets('404: só o aviso e "Voltar" fecha a página', (tester) async {
    await abrirEmpresa(tester, const PerfilState.naoEncontrado());

    expect(
      naPagina(find.text('Esta página não está mais disponível')),
      findsOneWidget,
    );
    expect(
      naPagina(find.byIcon(Icons.domain_disabled_outlined)),
      findsOneWidget,
    );

    await tester.tap(naPagina(find.text('Voltar')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(PerfilEmpresaScreen), findsNothing);
  });

  testWidgets('falha: mensagem e "Tentar de novo" repete a busca', (
    tester,
  ) async {
    await abrirEmpresa(tester, const PerfilState.erro());

    expect(
      naPagina(find.text('Não foi possível carregar esta página.')),
      findsOneWidget,
    );

    await tester.tap(naPagina(find.text('Tentar de novo')));
    await tester.pump();

    verify(() => cubit.tentarNovamente()).called(1);
  });

  group('página completa (PERF-01, D-09, D-10, D-11)', () {
    testWidgets('empresa 3: ordem nome, Apresentação, Contato, Cidades de '
        'atuação, Imóveis de; contato como texto selecionável e três chips '
        'na ordem recebida', (tester) async {
      await abrirEmpresa(
        tester,
        const PerfilState.carregado(jequitibaCompleta),
      );

      for (final valor in [
        '(19) 3333-0000',
        '19988880000',
        'contato@jequitiba.exemplo.com',
      ]) {
        expect(
          naPagina(find.widgetWithText(SelectableText, valor)),
          findsOneWidget,
        );
      }
      expect(naPagina(find.byType(SelectableText)), findsNWidgets(3));
      expect(
        naPagina(find.text('Imobiliária com 20 anos de atuação.')),
        findsOneWidget,
      );

      final ys = [
        for (final texto in [
          'Imobiliária Jequitibá',
          'Apresentação',
          'Contato',
          'Cidades de atuação',
          'Imóveis de Imobiliária Jequitibá',
        ])
          tester.getTopLeft(naPagina(find.text(texto))).dy,
      ];
      for (var i = 0; i < ys.length - 1; i++) {
        expect(ys[i], lessThan(ys[i + 1]), reason: 'posição $i');
      }

      expect(naPagina(find.byType(Chip)), findsNWidgets(3));
      final chips = [
        for (final texto in ['Campinas, SP', 'Valinhos, SP', 'Vinhedo, SP'])
          tester.getTopLeft(naPagina(find.text(texto))),
      ];
      // Ordem de leitura: linha de cima primeiro; na mesma linha, da esquerda
      // para a direita (o terceiro chip pode quebrar de linha em 400 dp).
      for (var i = 0; i < chips.length - 1; i++) {
        final antes = chips[i];
        final depois = chips[i + 1];
        expect(
          antes.dy < depois.dy ||
              (antes.dy == depois.dy && antes.dx < depois.dx),
          isTrue,
          reason: 'chip $i antes do chip ${i + 1}',
        );
      }
    });

    testWidgets('o contato é só texto: sem botão, link ou toque na seção', (
      tester,
    ) async {
      await abrirEmpresa(
        tester,
        const PerfilState.carregado(jequitibaCompleta),
      );

      final secao = find.ancestor(
        of: naPagina(find.text('Contato')),
        matching: find.byType(Column),
      );
      final dentro = secao.first;
      for (final tipo in [InkWell, IconButton, TextButton, FilledButton]) {
        expect(
          find.descendant(of: dentro, matching: find.byType(tipo)),
          findsNothing,
          reason: '$tipo não pode existir na seção de contato',
        );
      }
    });

    testWidgets('empresa 4 (autônomo): sem Apresentação e sem a linha '
        'Telefone, com WhatsApp, um chip e os imóveis dela', (tester) async {
      await abrirEmpresa(
        tester,
        const PerfilState.carregado(camilaCompleta),
        empresaId: 4,
      );

      expect(naPagina(find.text('Apresentação')), findsNothing);
      expect(naPagina(find.text('Telefone')), findsNothing);
      expect(naPagina(find.text('WhatsApp')), findsOneWidget);
      expect(naPagina(find.byType(Chip)), findsOneWidget);
      expect(naPagina(find.text('Vinhedo, SP')), findsOneWidget);
      expect(naPagina(find.text('Imóveis de Camila Duarte')), findsOneWidget);
    });

    testWidgets('empresa sem cidades: o título Cidades de atuação some', (
      tester,
    ) async {
      await abrirEmpresa(
        tester,
        const PerfilState.carregado(
          PerfilEmpresa(id: 5, nome: 'Sem Cidades', whatsapp: '19900001111'),
        ),
        empresaId: 5,
      );

      expect(naPagina(find.text('Cidades de atuação')), findsNothing);
      expect(naPagina(find.byType(Chip)), findsNothing);
      expect(naPagina(find.text('Imóveis de Sem Cidades')), findsOneWidget);
    });
  });

  group('vitrine da empresa (PERF-03, API-08, D-12)', () {
    Imovel imovel(int id, String titulo) => Imovel(
      id: id,
      titulo: titulo,
      finalidade: FinalidadeImovel.venda,
      bairro: 'Cambuí',
      cidade: const Cidade(nome: 'Campinas', uf: 'SP'),
    );

    testWidgets('carregada: os cards aparecem depois de "Imóveis de" e tocar '
        'no primeiro repassa o imóvel', (tester) async {
      await abrirEmpresa(
        tester,
        const PerfilState.carregado(jequitibaCompleta),
        estadoVitrine: VitrineAnuncianteState.carregada(
          itens: [imovel(57, 'Casa 57'), imovel(42, 'Apartamento 42')],
        ),
      );

      expect(naPagina(find.byType(ImovelCard)), findsNWidgets(2));
      final yTitulo = tester
          .getTopLeft(naPagina(find.text('Imóveis de Imobiliária Jequitibá')))
          .dy;
      final yPrimeiro = tester
          .getTopLeft(find.byKey(const ValueKey('imovel-anunciante-57')))
          .dy;
      expect(yPrimeiro, greaterThan(yTitulo));

      await tester.tap(find.byKey(const ValueKey('imovel-anunciante-57')));
      await tester.pump();

      expect(imoveisAbertos, [57]);
    });

    testWidgets('com a empresa carregada, a vitrine é criada uma vez e '
        'carrega AnuncianteRef.empresa(3)', (tester) async {
      await abrirEmpresa(
        tester,
        const PerfilState.carregado(jequitibaCompleta),
      );

      expect(vitrinesCriadas, 1);
      verify(() => vitrine.carregar(const AnuncianteRef.empresa(3))).called(1);
    });

    testWidgets('empresa carregando, 404 ou erro: a fábrica da vitrine nunca '
        'é chamada', (tester) async {
      await abrirEmpresa(tester, const PerfilState.carregando());
      expect(vitrinesCriadas, 0);

      for (final estado in [
        const PerfilState<PerfilEmpresa>.naoEncontrado(),
        const PerfilState<PerfilEmpresa>.erro(),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await abrirEmpresa(tester, estado);
        expect(vitrinesCriadas, 0);
        expect(find.textContaining('Imóveis de'), findsNothing);
      }
      verifyNever(() => vitrine.carregar(any()));
    });

    testWidgets('erro da vitrine mostra a mensagem e "Tentar de novo" chama '
        'tentarNovamente uma vez', (tester) async {
      await abrirEmpresa(
        tester,
        const PerfilState.carregado(jequitibaCompleta),
        estadoVitrine: const VitrineAnuncianteState.erro(),
      );

      expect(
        naPagina(find.text('Não foi possível carregar os imóveis.')),
        findsOneWidget,
      );
      await tester.ensureVisible(naPagina(find.text('Tentar de novo')));
      await tester.tap(naPagina(find.text('Tentar de novo')));
      await tester.pump();
      verify(() => vitrine.tentarNovamente()).called(1);
    });
  });
}
