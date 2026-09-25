import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/imovel_mock_datasource.dart';
import 'package:imoveis_aqui/data/mocks/imoveis_fixture.dart';
import 'package:imoveis_aqui/data/repositories/imovel_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/usecases/buscar_imoveis_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:imoveis_aqui/presentation/vitrine/vitrine_cubit.dart';
import 'package:imoveis_aqui/presentation/vitrine/widgets/imovel_card.dart';
import 'package:mocktail/mocktail.dart';

/// Teste ponta a ponta (VIT-01): pilha REAL
/// `VitrineCubit -> BuscarImoveisUseCase -> ImovelRepositoryImpl ->
/// ImovelMockDataSource` montada dentro de `CidadeSelecaoScreen`, com apenas
/// o `CidadeSelecaoCubit` mockado (para controlar diretamente o desfecho
/// `autorizadaEAtendida`).
class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

void main() {
  const campinas = Cidade(nome: 'Campinas', uf: 'SP');
  const indaiatuba = Cidade(nome: 'Indaiatuba', uf: 'SP');

  late _CidadeSelecaoCubitFalso cidadeSelecaoCubit;
  late _SalvarCidadeUseCaseFalso salvarCidade;

  VitrineCubit criarVitrineCubitReal() => VitrineCubit(
    BuscarImoveisUseCase(
      ImovelRepositoryImpl(
        ImovelMockDataSource.paraTeste(linhas: linhasAcervoFixture()),
      ),
    ),
  );

  setUp(() {
    cidadeSelecaoCubit = _CidadeSelecaoCubitFalso();
    salvarCidade = _SalvarCidadeUseCaseFalso();
  });

  Future<void> pumpVitrineDe(WidgetTester tester, Cidade cidade) async {
    whenListen(
      cidadeSelecaoCubit,
      Stream<CidadeSelecaoState>.value(
        CidadeSelecaoState.autorizadaEAtendida(cidade),
      ),
      initialState: CidadeSelecaoState.autorizadaEAtendida(cidade),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CidadeSelecaoCubit>.value(
          value: cidadeSelecaoCubit,
          child: CidadeSelecaoScreen(
            salvarCidade: salvarCidade,
            criarVitrineCubit: criarVitrineCubitReal,
          ),
        ),
      ),
    );
    // Nunca pumpAndSettle aqui — o CircularProgressIndicator (estado
    // `carregando`) tem animação indeterminada e pumpAndSettle nunca se
    // estabiliza enquanto ele está de pé.
    await tester.pump();
    await tester.pump();
  }

  testWidgets(
    'Campinas: cabeçalho "Campinas, SP" + cards só de Campinas, pela pilha '
    'real Cubit -> UseCase -> Repository -> DataSource (VIT-01, API-04)',
    (tester) async {
      await pumpVitrineDe(tester, campinas);

      expect(find.text('Campinas, SP'), findsOneWidget);
      expect(find.byType(ImovelCard), findsNWidgets(2));

      final cards = tester.widgetList<ImovelCard>(find.byType(ImovelCard));
      for (final card in cards) {
        expect(card.imovel.cidade, campinas);
      }

      expect(find.text('Apartamento 2 quartos no Cambuí'), findsOneWidget);
      expect(find.text('Casa térrea 3 quartos no Taquaral'), findsOneWidget);
      expect(
        find.text('Terreno no Loteamento Jardim das Palmeiras'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'Indaiatuba (atendida, sem imóveis na fixture): estado vazio próprio '
    '(D-15), distinto de erro',
    (tester) async {
      await pumpVitrineDe(tester, indaiatuba);

      expect(
        find.text('Ainda não há imóveis anunciados em Indaiatuba.'),
        findsOneWidget,
      );
      expect(find.byType(ImovelCard), findsNothing);
      expect(find.byType(ErrorWidget), findsNothing);
    },
  );
}
