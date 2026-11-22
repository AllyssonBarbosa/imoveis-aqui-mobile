import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/models/imovel_gestao_model.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel_acervo.dart';
import 'package:imoveis_aqui/domain/entities/imovel_gestao.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/apresentacao_gestao.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/apresentacao_imovel.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

class _GestaoImovelCubitFalso extends MockCubit<GestaoImovelState>
    implements GestaoImovelCubit {}

ImovelAcervo _previa({bool naVitrine = true}) => ImovelAcervo(
  id: 36,
  codigo: 'DEV-INDAIATUBA-04',
  titulo: 'Título da prévia',
  finalidade: FinalidadeImovel.venda,
  precoVenda: '90000.00',
  fotoCapa: 'http://exemplo.test/capa.jpg',
  situacao: SituacaoImovel.disponivel,
  meuImovel: true,
  naVitrine: naVitrine,
);

/// O imóvel lido da fixture capturada do Django, pelo Model (wire real).
ImovelGestao _imovelDaFixture() => ImovelGestaoModel.fromJson(
  lerFixtureApi('imovel_gestao_disponivel.json')! as Map<String, Object?>,
).paraEntidade();

void main() {
  late _GestaoImovelCubitFalso cubit;
  late List<Imovel> abertosNaVitrine;

  setUp(() {
    cubit = _GestaoImovelCubitFalso();
    abertosNaVitrine = [];
    when(() => cubit.tentarNovamente()).thenAnswer((_) async {});
  });

  Future<void> montar(
    WidgetTester tester,
    GestaoImovelState estado, {
    ImovelAcervo? previa,
  }) async {
    // Tela de celular: com a foto 16:9 na largura padrão do teste (800) o
    // corpo passaria da área visível e o `ListView` não construiria o resto.
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    whenListen(
      cubit,
      const Stream<GestaoImovelState>.empty(),
      initialState: estado,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<GestaoImovelCubit>.value(
          value: cubit,
          child: GestaoImovelScreen(
            previa: previa ?? _previa(),
            aoVerNaVitrine: (context, imovel) async =>
                abertosNaVitrine.add(imovel),
            construirImagemDeRede: (url) => Text('FOTO:$url'),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('carregando: AppBar com o código, cabeçalho da prévia e '
      'indicador de progresso', (tester) async {
    await montar(tester, const GestaoImovelState());

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('DEV-INDAIATUBA-04'),
      ),
      findsOneWidget,
    );
    expect(find.text('Título da prévia'), findsOneWidget);
    expect(find.text('FOTO:http://exemplo.test/capa.jpg'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(tituloSecaoSituacao), findsNothing);
  });

  testWidgets('carregado: título, preço, "Situação", rótulo e "desde" do '
      'servidor, sem endereço nem descrição (D-03, D-05)', (tester) async {
    final imovel = _imovelDaFixture();
    await montar(
      tester,
      GestaoImovelState(imovel: ConteudoImovelGestao.carregado(imovel)),
    );

    expect(find.text(imovel.titulo), findsOneWidget);
    for (final linha in linhasDePrecoPorFinalidade(
      finalidade: imovel.finalidade,
      precoVenda: imovel.precoVenda,
      precoAluguel: imovel.precoAluguel,
    )) {
      expect(find.text(linha), findsOneWidget);
    }
    expect(find.text('Situação'), findsOneWidget);
    expect(find.text('Disponível'), findsOneWidget);
    expect(find.text(textoDesde(imovel.situacaoDesde)), findsOneWidget);
    expect(find.textContaining('Rua das Palmeiras'), findsNothing);
    expect(find.textContaining('Lote de demonstração'), findsNothing);
  });

  testWidgets('"Ver na vitrine" só com naVitrine do servidor; tocar abre o '
      'imóvel de mesmo id (D-02)', (tester) async {
    final imovel = _imovelDaFixture();
    await montar(
      tester,
      GestaoImovelState(imovel: ConteudoImovelGestao.carregado(imovel)),
    );

    expect(find.text('Ver na vitrine'), findsOneWidget);
    await tester.tap(find.text('Ver na vitrine'));
    await tester.pump();

    expect(abertosNaVitrine, hasLength(1));
    expect(abertosNaVitrine.single.id, 36);
  });

  testWidgets('sem naVitrine o botão "Ver na vitrine" não existe', (
    tester,
  ) async {
    final imovel = _imovelDaFixture();
    await montar(
      tester,
      GestaoImovelState(imovel: ConteudoImovelGestao.carregado(imovel)),
      previa: _previa(naVitrine: false),
    );

    expect(find.text('Ver na vitrine'), findsNothing);
    expect(find.text('Situação'), findsOneWidget);
  });

  testWidgets('erro: texto fixo e "Tentar de novo" chama tentarNovamente', (
    tester,
  ) async {
    await montar(
      tester,
      const GestaoImovelState(imovel: ConteudoImovelGestao.erro()),
    );

    expect(find.text('Não foi possível carregar o imóvel.'), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    await tester.pump();

    verify(() => cubit.tentarNovamente()).called(1);
  });
}
