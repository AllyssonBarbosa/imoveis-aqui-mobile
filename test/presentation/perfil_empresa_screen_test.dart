import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/perfil_empresa.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_empresa_cubit.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_empresa_screen.dart';
import 'package:imoveis_aqui/presentation/perfis/perfil_state.dart';
import 'package:mocktail/mocktail.dart';

class _PerfilEmpresaCubitFalso extends MockCubit<PerfilState<PerfilEmpresa>>
    implements PerfilEmpresaCubit {}

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

  late _PerfilEmpresaCubitFalso cubit;

  setUp(() {
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
  }) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    whenListen(
      cubit,
      const Stream<PerfilState<PerfilEmpresa>>.empty(),
      initialState: estado,
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
}
