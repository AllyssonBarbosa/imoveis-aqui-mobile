import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
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
    DetalheImovelState estado,
  ) async {
    tester.view.physicalSize = const Size(400, 1200);
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
