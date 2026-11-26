import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/models/imovel_gestao_model.dart';
import 'package:imoveis_aqui/domain/entities/imovel.dart';
import 'package:imoveis_aqui/domain/entities/imovel_acervo.dart';
import 'package:imoveis_aqui/domain/entities/imovel_gestao.dart';
import 'package:imoveis_aqui/domain/entities/mudanca_situacao.dart';
import 'package:imoveis_aqui/domain/entities/situacao_imovel.dart';
import 'package:imoveis_aqui/domain/usecases/obter_historico_situacao_usecase.dart';
import 'package:imoveis_aqui/domain/usecases/obter_imovel_gestao_usecase.dart';
import 'package:imoveis_aqui/presentation/fotos_imovel/fotos_alteradas.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_state.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/mudar_situacao_cubit.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/mudar_situacao_state.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

import '../support/api_falsa.dart';

class _GestaoCubitFalso extends MockCubit<GestaoImovelState>
    implements GestaoImovelCubit {}

class _MudarCubitFalso extends MockCubit<MudarSituacaoState>
    implements MudarSituacaoCubit {}

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

class _ObterImovel extends Mock implements ObterImovelGestaoUseCase {}

class _ObterHistorico extends Mock implements ObterHistoricoSituacaoUseCase {}

ImovelGestao _imovel() => ImovelGestaoModel.fromJson(
  lerFixtureApi('imovel_gestao_disponivel.json')! as Map<String, Object?>,
).paraEntidade();

ImovelAcervo _previa() => ImovelAcervo(
  id: 36,
  codigo: 'DEV-INDAIATUBA-04',
  titulo: 'Título da prévia',
  finalidade: FinalidadeImovel.venda,
  precoVenda: '90000.00',
  fotoCapa: 'http://exemplo.test/capa-do-cartao.jpg',
  situacao: SituacaoImovel.disponivel,
  meuImovel: true,
  naVitrine: true,
);

/// Chamadas recebidas pelo abridor falso da tela de fotos.
typedef _Chamada = ({int imovelId, String codigo});

void main() {
  group('tela de gestão: botão "Fotos" (APP 11, D-08)', () {
    late _GestaoCubitFalso cubit;
    late _MudarCubitFalso mudar;
    late _SessaoCubitFalso sessao;
    late List<_Chamada> chamadas;

    setUp(() {
      cubit = _GestaoCubitFalso();
      mudar = _MudarCubitFalso();
      sessao = _SessaoCubitFalso();
      whenListen(
        mudar,
        const Stream<MudarSituacaoState>.empty(),
        initialState: const MudarSituacaoState(),
      );
      whenListen(
        sessao,
        const Stream<SessaoState>.empty(),
        initialState: const SessaoState.autenticada(),
      );
      when(() => cubit.recarregar()).thenAnswer((_) async {});
      chamadas = [];
      registerFallbackValue(
        const FotosAlteradas(urlDaCapa: null, capaConhecida: false),
      );
    });

    Future<void> montar(
      WidgetTester tester,
      GestaoImovelState estado, {
      FotosAlteradas? resultadoDasFotos,
    }) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      whenListen(
        cubit,
        const Stream<GestaoImovelState>.empty(),
        initialState: estado,
      );
      await tester.pumpWidget(
        BlocProvider<SessaoCubit>.value(
          value: sessao,
          child: MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<GestaoImovelCubit>.value(value: cubit),
                BlocProvider<MudarSituacaoCubit>.value(value: mudar),
              ],
              child: GestaoImovelScreen(
                previa: _previa(),
                aoVerNaVitrine: (context, imovel) async {},
                aoAbrirFotos:
                    (context, {required imovelId, required codigo}) async {
                      chamadas.add((imovelId: imovelId, codigo: codigo));
                      return resultadoDasFotos;
                    },
                construirImagemDeRede: (url) => Text('FOTO:$url'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('com o imóvel carregado aparece "Fotos", que abre a tela com '
        'o id e o código', (tester) async {
      await montar(
        tester,
        GestaoImovelState(imovel: ConteudoImovelGestao.carregado(_imovel())),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Fotos'));
      await tester.pump();

      expect(chamadas, [(imovelId: 36, codigo: 'DEV-INDAIATUBA-04')]);
    });

    testWidgets('sem o imóvel carregado não há botão "Fotos"', (tester) async {
      await montar(tester, const GestaoImovelState());
      expect(find.widgetWithText(OutlinedButton, 'Fotos'), findsNothing);
    });

    testWidgets('volta com fotos alteradas avisa o Cubit da gestão', (
      tester,
    ) async {
      const alteradas = FotosAlteradas(
        urlDaCapa: 'http://api.test/media/imoveis/fotos/nova.jpg',
        capaConhecida: true,
      );
      await montar(
        tester,
        GestaoImovelState(imovel: ConteudoImovelGestao.carregado(_imovel())),
        resultadoDasFotos: alteradas,
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Fotos'));
      await tester.pump();

      verify(() => cubit.registrarMudancaDeFotos(alteradas)).called(1);
    });

    testWidgets('volta sem mudança não avisa o Cubit', (tester) async {
      await montar(
        tester,
        GestaoImovelState(imovel: ConteudoImovelGestao.carregado(_imovel())),
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Fotos'));
      await tester.pump();

      verifyNever(() => cubit.registrarMudancaDeFotos(any()));
    });

    testWidgets('o cabeçalho mostra a capa atualizada pelo servidor no lugar '
        'da do cartão', (tester) async {
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovel()),
          capaAtualizada: 'http://api.test/media/imoveis/fotos/nova.jpg',
          temCapaAtualizada: true,
        ),
      );

      expect(
        find.text('FOTO:http://api.test/media/imoveis/fotos/nova.jpg'),
        findsOneWidget,
      );
      expect(
        find.text('FOTO:http://exemplo.test/capa-do-cartao.jpg'),
        findsNothing,
      );
    });

    testWidgets('sem capa atualizada o cabeçalho segue com a do cartão', (
      tester,
    ) async {
      await montar(
        tester,
        GestaoImovelState(imovel: ConteudoImovelGestao.carregado(_imovel())),
      );
      expect(
        find.text('FOTO:http://exemplo.test/capa-do-cartao.jpg'),
        findsOneWidget,
      );
    });

    testWidgets('mudar fotos não esconde "Ver na vitrine" (só a situação '
        'esconde, D-18 da Fase 9)', (tester) async {
      await montar(
        tester,
        GestaoImovelState(
          imovel: ConteudoImovelGestao.carregado(_imovel()),
          fotosMudaram: true,
        ),
      );
      expect(find.text('Ver na vitrine'), findsOneWidget);
    });
  });

  group('GestaoImovelCubit.registrarMudancaDeFotos', () {
    late _ObterImovel obterImovel;
    late _ObterHistorico obterHistorico;

    setUp(() {
      obterImovel = _ObterImovel();
      obterHistorico = _ObterHistorico();
      when(() => obterImovel(36))
          .thenAnswer((_) async => Result.success(_imovel()));
      when(() => obterHistorico(36)).thenAnswer(
        (_) async => const Result<List<MudancaSituacao>>.success([]),
      );
    });

    test(
      'capa conhecida: marca fotosMudaram e guarda a capa (também nula)',
      () {
        final cubit = GestaoImovelCubit(obterImovel, obterHistorico)
          ..registrarMudancaDeFotos(
            const FotosAlteradas(urlDaCapa: null, capaConhecida: true),
          );

        expect(cubit.state.fotosMudaram, isTrue);
        expect(cubit.state.temCapaAtualizada, isTrue);
        expect(cubit.state.capaAtualizada, isNull);
        expect(cubit.state.mudou, isFalse, reason: 'não é mudança de situação');
      },
    );

    test('capa desconhecida: só marca fotosMudaram', () {
      final cubit = GestaoImovelCubit(obterImovel, obterHistorico)
        ..registrarMudancaDeFotos(
          const FotosAlteradas(urlDaCapa: null, capaConhecida: false),
        );

      expect(cubit.state.fotosMudaram, isTrue);
      expect(cubit.state.temCapaAtualizada, isFalse);
    });

    test('uma nova carga mantém a mudança de fotos e a capa', () async {
      final cubit = GestaoImovelCubit(obterImovel, obterHistorico)
        ..registrarMudancaDeFotos(
          const FotosAlteradas(
            urlDaCapa: 'http://api.test/nova.jpg',
            capaConhecida: true,
          ),
        );

      await cubit.carregar(36);

      expect(cubit.state.fotosMudaram, isTrue);
      expect(cubit.state.capaAtualizada, 'http://api.test/nova.jpg');
      expect(cubit.state.imovel, isA<ImovelGestaoCarregado>());
    });
  });
}
