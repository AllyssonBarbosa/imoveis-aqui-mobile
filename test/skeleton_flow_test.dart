import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/usecases/obter_cidades_atendidas_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/main.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockObterCidadesAtendidasUseCase extends Mock
    implements ObterCidadesAtendidasUseCase {}

class _MockSalvarCidadeUseCase extends Mock implements SalvarCidadeUseCase {}

void main() {
  group('decidirDestinoInicial (D-08)', () {
    test('com cidade salva, a decisão é entrar direto', () {
      const cidade = Cidade(nome: 'Campinas', uf: 'SP');

      expect(decidirDestinoInicial(cidade), DestinoInicial.entraDireto);
    });

    test('sem cidade salva, a decisão é mostrar a lista', () {
      expect(decidirDestinoInicial(null), DestinoInicial.mostraLista);
    });
  });

  group('Fluxo do walking skeleton (CidadeSelecaoScreen)', () {
    late _MockObterCidadesAtendidasUseCase obterCidades;
    late _MockSalvarCidadeUseCase salvarCidade;

    const campinas = Cidade(nome: 'Campinas', uf: 'SP');
    const valinhos = Cidade(nome: 'Valinhos', uf: 'SP');

    setUpAll(() {
      registerFallbackValue(campinas);
    });

    setUp(() {
      obterCidades = _MockObterCidadesAtendidasUseCase();
      salvarCidade = _MockSalvarCidadeUseCase();
      when(
        () => obterCidades(),
      ).thenAnswer((_) async => const Result.success([campinas, valinhos]));
      when(() => salvarCidade(any())).thenAnswer((_) async {});
    });

    testWidgets('carrega as cidades atendidas e lista cada uma', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CidadeSelecaoScreen(
            obterCidadesAtendidas: obterCidades,
            salvarCidade: salvarCidade,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Campinas, SP'), findsOneWidget);
      expect(find.text('Valinhos, SP'), findsOneWidget);
      verify(() => obterCidades()).called(1);
    });

    testWidgets('tocar uma cidade persiste a escolha via SalvarCidadeUseCase', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CidadeSelecaoScreen(
            obterCidadesAtendidas: obterCidades,
            salvarCidade: salvarCidade,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Campinas, SP'));
      await tester.pumpAndSettle();

      verify(() => salvarCidade(campinas)).called(1);
    });
  });
}
