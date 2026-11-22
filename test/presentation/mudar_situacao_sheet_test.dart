import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/usecases/mudar_situacao_usecase.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/mudar_situacao_cubit.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart';
import 'package:mocktail/mocktail.dart';

class _MudarSituacaoUseCaseFalso extends Mock implements MudarSituacaoUseCase {}

/// Teste da folha "Mudar situação" com o `MudarSituacaoCubit` REAL sobre um
/// `MudarSituacaoUseCase` falso — o `Completer` deixa o teste segurar o envio
/// em voo e soltar quando quiser.
void main() {
  const imovelId = 36;
  const dicaDoSite = 'Ex.: reservado para o cliente João até a assinatura.';

  late _MudarSituacaoUseCaseFalso mudar;
  late MudarSituacaoCubit cubit;

  setUpAll(() {
    registerFallbackValue(SituacaoImovel.disponivel);
  });

  setUp(() {
    mudar = _MudarSituacaoUseCaseFalso();
    cubit = MudarSituacaoCubit(mudar)
      ..iniciar(imovelId: imovelId, atual: SituacaoImovel.disponivel);
  });

  tearDown(() async {
    await cubit.close();
  });

  /// Abre a folha por um botão numa tela simples (a rota do modal fica acima do
  /// `MaterialApp`, como no app).
  Future<void> abrirFolha(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    mostrarMudarSituacaoSheet(context, cubit: cubit),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  void respondeCom(Future<Result<void>> Function() resposta) {
    when(() => mudar(any(), any(), observacao: any(named: 'observacao')))
        .thenAnswer((_) => resposta());
  }

  Finder botaoConfirmar() => find.widgetWithText(FilledButton, 'Confirmar');

  group('observação e "Data: hoje" (D-05, D-06, D-17)', () {
    testWidgets('mostra o campo "Observação (opcional)" com a dica do site e '
        'o contador de 500, e o texto "Data: hoje"', (tester) async {
      await abrirFolha(tester);

      expect(find.text('Observação (opcional)'), findsOneWidget);
      final campo = tester.widget<TextField>(find.byType(TextField));
      expect(campo.maxLength, 500);
      expect(campo.decoration?.hintText, dicaDoSite);
      expect(find.text('0/500'), findsOneWidget);
      expect(find.text('Data: hoje'), findsOneWidget);
    });

    testWidgets('texto acima de 500 caracteres não entra no campo (D-17)', (
      tester,
    ) async {
      await abrirFolha(tester);

      await tester.enterText(find.byType(TextField), 'a' * 600);
      await tester.pump();

      final campo = tester.widget<TextField>(find.byType(TextField));
      expect(campo.controller!.text, hasLength(500));
      expect(find.text('500/500'), findsOneWidget);
    });

    testWidgets('Confirmar com "Sinal pago" chama o UseCase com essa '
        'observação e a folha fecha no sucesso', (tester) async {
      respondeCom(() async => const Success<void>(null));
      await abrirFolha(tester);

      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Sinal pago');
      await tester.tap(botaoConfirmar());
      await tester.pumpAndSettle();

      verify(
        () =>
            mudar(imovelId, SituacaoImovel.reservado, observacao: 'Sinal pago'),
      ).called(1);
      expect(find.text('Confirmar'), findsNothing);
    });

    testWidgets('observação vazia vai como texto vazio (opcional, D-06)', (
      tester,
    ) async {
      respondeCom(() async => const Success<void>(null));
      await abrirFolha(tester);

      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.tap(botaoConfirmar());
      await tester.pumpAndSettle();

      verify(() => mudar(imovelId, SituacaoImovel.reservado, observacao: ''))
          .called(1);
    });

    testWidgets('depois de uma falha a folha continua aberta com o texto da '
        'observação no campo e Confirmar volta a ficar habilitado', (
      tester,
    ) async {
      respondeCom(() async => Failure<void>(Exception('recusado')));
      await abrirFolha(tester);

      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Sinal pago');
      await tester.tap(botaoConfirmar());
      await tester.pumpAndSettle();

      expect(find.text('Confirmar'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Sinal pago',
      );
      expect(
        tester.widget<FilledButton>(botaoConfirmar()).onPressed,
        isNotNull,
      );
    });
  });
}
