import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/repositories/gestao_imovel_repository.dart';
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
  group('recusa do servidor (D-10, T-09-13)', () {
    const mensagem =
        'Este imóvel tem um contrato assinado (#1): a situação não pode ser '
        'mudada à mão enquanto o contrato estiver valendo.';

    testWidgets('com a recusa a folha continua aberta, mostra a mensagem do '
        'servidor como texto simples em colorScheme.error e mantém a '
        'observação', (tester) async {
      respondeCom(
        () async =>
            const Failure<void>(MudancaSituacaoRecusadaException(mensagem)),
      );
      await abrirFolha(tester);

      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Sinal pago');
      await tester.tap(botaoConfirmar());
      await tester.pumpAndSettle();

      final texto = find.text(mensagem);
      expect(texto, findsOneWidget);
      final widget = tester.widget<Text>(texto);
      expect(widget.maxLines, 6);
      expect(
        widget.style?.color,
        Theme.of(tester.element(texto)).colorScheme.error,
      );
      // O texto genérico não aparece junto.
      expect(
        find.text('Não foi possível mudar a situação agora. Tente de novo.'),
        findsNothing,
      );
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

    testWidgets('escolher outra situação depois da recusa some a mensagem', (
      tester,
    ) async {
      respondeCom(
        () async =>
            const Failure<void>(MudancaSituacaoRecusadaException(mensagem)),
      );
      await abrirFolha(tester);

      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.tap(botaoConfirmar());
      await tester.pumpAndSettle();
      expect(find.text(mensagem), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('chip-mudar-vendido')));
      await tester.pump();

      expect(find.text(mensagem), findsNothing);
    });
  });

  group('envio protegido (D-09, D-10, T-09-07)', () {
    /// Abre a folha, escolhe "Reservado" e toca em Confirmar com o UseCase
    /// preso no [completer]: o envio fica em voo até o teste soltar.
    Future<void> iniciarEnvioEmVoo(
      WidgetTester tester,
      Completer<Result<void>> completer,
    ) async {
      respondeCom(() => completer.future);
      await abrirFolha(tester);
      await tester.tap(find.byKey(const ValueKey('chip-mudar-reservado')));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Sinal pago');
      await tester.tap(botaoConfirmar());
      // Sem pumpAndSettle: o indicador de progresso mantém a animação de pé.
      await tester.pump();
    }

    testWidgets('durante o envio Confirmar mostra carregamento e fica '
        'desabilitado; chips e campo ficam desabilitados', (tester) async {
      final completer = Completer<Result<void>>();
      await iniciarEnvioEmVoo(tester, completer);

      final botao = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(botao.onPressed, isNull);
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsNothing);
      for (final situacao in SituacaoImovel.values) {
        expect(
          tester
              .widget<ChoiceChip>(
                find.byKey(ValueKey('chip-mudar-${situacao.name}')),
              )
              .onSelected,
          isNull,
          reason: 'chip ${situacao.name} deve ficar desabilitado no envio',
        );
      }
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);

      completer.complete(const Success<void>(null));
      await tester.pumpAndSettle();
    });

    testWidgets('dois toques seguidos em Confirmar geram UMA chamada ao '
        'UseCase', (tester) async {
      final completer = Completer<Result<void>>();
      await iniciarEnvioEmVoo(tester, completer);

      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.pump();

      verify(
        () =>
            mudar(imovelId, SituacaoImovel.reservado, observacao: 'Sinal pago'),
      ).called(1);

      completer.complete(const Success<void>(null));
      await tester.pumpAndSettle();
    });

    testWidgets('tocar na barreira fora da folha durante o envio NÃO fecha a '
        'folha', (tester) async {
      final completer = Completer<Result<void>>();
      await iniciarEnvioEmVoo(tester, completer);

      await tester.tapAt(const Offset(10, 10));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Success<void>(null));
      await tester.pumpAndSettle();
    });

    testWidgets('o botão voltar (handlePopRoute) durante o envio NÃO fecha a '
        'folha', (tester) async {
      final completer = Completer<Result<void>>();
      await iniciarEnvioEmVoo(tester, completer);

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const Success<void>(null));
      await tester.pumpAndSettle();
    });

    testWidgets('a folha não tem alça de arrasto e não deixa arrastar para '
        'fechar', (tester) async {
      await abrirFolha(tester);

      // A alça é um widget privado do SDK: confere-se o que a liga.
      final folha = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(folha.showDragHandle, isFalse);
      expect(folha.enableDrag, isFalse);
    });

    testWidgets('ao completar com sucesso a folha fecha', (tester) async {
      final completer = Completer<Result<void>>();
      await iniciarEnvioEmVoo(tester, completer);

      completer.complete(const Success<void>(null));
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('abrir'), findsOneWidget);
    });

    testWidgets('com o envio ocioso, tocar na barreira fecha a folha '
        '(o PopScope só segura durante o envio)', (tester) async {
      await abrirFolha(tester);
      expect(find.byType(FilledButton), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
