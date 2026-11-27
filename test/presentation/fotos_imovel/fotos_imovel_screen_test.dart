import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/foto_imovel.dart';
import 'package:imoveis_aqui/presentation/fotos_imovel/fotos_alteradas.dart';
import 'package:imoveis_aqui/presentation/fotos_imovel/fotos_imovel_cubit.dart';
import 'package:imoveis_aqui/presentation/fotos_imovel/fotos_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/fotos_imovel/fotos_imovel_state.dart';
import 'package:imoveis_aqui/presentation/login/login_cubit.dart';
import 'package:imoveis_aqui/presentation/login/login_screen.dart';
import 'package:imoveis_aqui/presentation/login/login_state.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_state.dart';
import 'package:mocktail/mocktail.dart';

class _FotosCubitFalso extends MockCubit<FotosImovelState>
    implements FotosImovelCubit {}

class _SessaoCubitFalso extends MockCubit<SessaoState> implements SessaoCubit {}

class _LoginCubitFalso extends MockCubit<LoginState> implements LoginCubit {}

FotoImovel _foto(int id, int ordem, {bool capa = false}) => FotoImovel(
  id: id,
  url: 'http://api.test/media/imoveis/fotos/$id.jpg',
  ordem: ordem,
  capa: capa,
);

final _tres = [_foto(10, 0, capa: true), _foto(20, 1), _foto(30, 2)];

FotosImovelState _carregado({
  List<FotoImovel>? fotos,
  List<EnvioDeFoto> fila = const [],
  OperacaoFotos operacao = const OperacaoFotos.nenhuma(),
}) => FotosImovelState(
  lista: ListaFotos.carregada(fotos ?? _tres),
  fila: fila,
  operacao: operacao,
);

EnvioDeFoto _envio(int id, EstadoEnvio estado) => EnvioDeFoto(
  id: id,
  original: FotoEscolhida(caminho: '/camera/$id.jpg'),
  estado: estado,
);

void main() {
  late _FotosCubitFalso cubit;
  late _SessaoCubitFalso sessao;

  setUp(() {
    cubit = _FotosCubitFalso();
    sessao = _SessaoCubitFalso();
    when(() => sessao.encerrarPorExpiracao()).thenAnswer((_) async {});
    whenListen(
      sessao,
      const Stream<SessaoState>.empty(),
      initialState: const SessaoState.autenticada(),
    );
    when(() => cubit.tentarNovamente()).thenAnswer((_) async {});
    when(() => cubit.tirarFoto()).thenAnswer((_) async {});
    when(() => cubit.escolherDaGaleria()).thenAnswer((_) async {});
    when(() => cubit.reordenar(any(), any())).thenAnswer((_) async {});
    when(() => cubit.definirCapa(any())).thenAnswer((_) async {});
    when(() => cubit.apagar(any())).thenAnswer((_) async {});
    when(() => cubit.remover(any())).thenAnswer((_) async {});
    when(() => cubit.tentarDeNovoEnvio(any())).thenAnswer((_) {});
  });

  tearDown(() async => getIt.reset());

  Widget tela() => FotosImovelScreen(
    codigo: 'DEV-CAMPINAS-11',
    construirImagemDeRede: (url) => Text('FOTO:$url'),
    construirMiniaturaLocal: (caminho) => Text('LOCAL:$caminho'),
  );

  Future<void> montar(
    WidgetTester tester,
    FotosImovelState estado, {
    Stream<FotosImovelState> depois = const Stream<FotosImovelState>.empty(),
    bool comRotaEmbaixo = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    whenListen(cubit, depois, initialState: estado);
    final conteudo = BlocProvider<FotosImovelCubit>.value(
      value: cubit,
      child: tela(),
    );
    await tester.pumpWidget(
      BlocProvider<SessaoCubit>.value(
        value: sessao,
        child: MaterialApp(
          home: comRotaEmbaixo
              ? Builder(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => conteudo),
                        ),
                        child: const Text('abrir'),
                      ),
                    ),
                  ),
                )
              : conteudo,
        ),
      ),
    );
    if (comRotaEmbaixo) {
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }
    await tester.pump();
  }

  group('desfechos da leitura', () {
    testWidgets('carregando mostra o indicador', (tester) async {
      await montar(tester, const FotosImovelState());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Fotos'), findsOneWidget);
      expect(find.text('DEV-CAMPINAS-11'), findsOneWidget);
    });

    testWidgets('erro mostra o texto fixo e "Tentar de novo" relê', (
      tester,
    ) async {
      await montar(tester, const FotosImovelState(lista: ListaFotos.erro()));

      expect(find.text('Não foi possível carregar as fotos.'), findsOneWidget);
      await tester.tap(find.text('Tentar de novo'));
      verify(() => cubit.tentarNovamente()).called(1);
    });

    testWidgets('404 mostra o texto fixo da gestão, sem "Tentar de novo"', (
      tester,
    ) async {
      await montar(
        tester,
        const FotosImovelState(lista: ListaFotos.naoEncontrado()),
      );
      expect(
        find.text('Este imóvel não está mais no seu acervo.'),
        findsOneWidget,
      );
      expect(find.text('Tentar de novo'), findsNothing);
    });

    testWidgets('imóvel sem fotos mostra o vazio e os dois botões', (
      tester,
    ) async {
      await montar(tester, _carregado(fotos: const []));
      expect(find.text('Este imóvel ainda não tem fotos.'), findsOneWidget);
      expect(find.text('Tirar foto'), findsOneWidget);
      expect(find.text('Escolher da galeria'), findsOneWidget);
    });
  });

  group('lista do servidor', () {
    testWidgets('mostra as fotos na ordem do servidor e o selo "Capa" só na '
        'capa', (tester) async {
      await montar(tester, _carregado());

      expect(find.text('Foto 1'), findsOneWidget);
      expect(find.text('Foto 3'), findsOneWidget);
      expect(find.text('Capa'), findsOneWidget);
      expect(
        find.text('FOTO:http://api.test/media/imoveis/fotos/10.jpg'),
        findsOneWidget,
      );
      // Com tudo livre, cada foto tem a alça de arrastar.
      expect(find.byType(ReorderableDragStartListener), findsNWidgets(3));
    });

    testWidgets('os botões abrem a câmera e a galeria pelo Cubit', (
      tester,
    ) async {
      await montar(tester, _carregado());

      await tester.tap(find.text('Tirar foto'));
      await tester.tap(find.text('Escolher da galeria'));

      verify(() => cubit.tirarFoto()).called(1);
      verify(() => cubit.escolherDaGaleria()).called(1);
    });

    testWidgets('soltar uma foto pede a ordem ao Cubit com a posição final', (
      tester,
    ) async {
      await montar(tester, _carregado());

      tester
          .widget<ReorderableListView>(find.byType(ReorderableListView))
          .onReorderItem!(2, 0);

      verify(() => cubit.reordenar(2, 0)).called(1);
    });

    testWidgets('na capa, o menu só tem "Apagar"; nas outras, também "Definir '
        'como capa", que chama o Cubit', (tester) async {
      await montar(tester, _carregado());

      await tester.tap(find.byTooltip('Ações da foto 1'));
      await tester.pumpAndSettle();
      expect(find.text('Definir como capa'), findsNothing);
      expect(find.text('Apagar'), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Ações da foto 2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Definir como capa'));
      await tester.pumpAndSettle();

      verify(() => cubit.definirCapa(20)).called(1);
    });

    testWidgets('"Apagar" pede confirmação: Cancelar não apaga, Apagar sim', (
      tester,
    ) async {
      await montar(tester, _carregado());

      await tester.tap(find.byTooltip('Ações da foto 3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apagar'));
      await tester.pumpAndSettle();
      expect(find.text('Apagar esta foto?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      verifyNever(() => cubit.apagar(any()));

      await tester.tap(find.byTooltip('Ações da foto 3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apagar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Apagar'));
      await tester.pumpAndSettle();

      verify(() => cubit.apagar(30)).called(1);
    });

    testWidgets('com envio em andamento, sem alça de arrastar e menu desligado '
        '(D-20)', (tester) async {
      await montar(
        tester,
        _carregado(
          fila: [_envio(1, const EstadoEnvio.enviando(progresso: 0.5))],
        ),
      );

      expect(find.byType(ReorderableDragStartListener), findsNothing);
      final menus = tester.widgetList<PopupMenuButton<Object?>>(
        find.byWidgetPredicate((widget) => widget is PopupMenuButton),
      );
      expect(menus.every((menu) => !menu.enabled), isTrue);
    });

    testWidgets('durante uma operação aparece a barra de progresso e a foto da '
        'operação mostra o indicador', (tester) async {
      await montar(
        tester,
        _carregado(operacao: const OperacaoFotos.apagando(30)),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byTooltip('Ações da foto 3'), findsNothing);
    });
  });

  group('fila de envio', () {
    testWidgets('enviando mostra a barra com o progresso; aguardando, só o '
        'texto', (tester) async {
      await montar(
        tester,
        _carregado(
          fila: [
            _envio(1, const EstadoEnvio.enviando(progresso: 0.4)),
            _envio(2, const EstadoEnvio.aguardando()),
          ],
        ),
      );

      expect(find.text('Enviando…'), findsOneWidget);
      expect(find.text('Aguardando'), findsOneWidget);
      expect(find.text('LOCAL:/camera/1.jpg'), findsOneWidget);
      final barra = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(barra.value, 0.4);
    });

    testWidgets('falha com mensagem do servidor: mostra a mensagem, "Tentar de '
        'novo" e "Remover"', (tester) async {
      await montar(
        tester,
        _carregado(
          fila: [
            _envio(
              7,
              const EstadoEnvio.falhou(
                mensagemDoServidor:
                    'Este imóvel já tem 30 fotos, o máximo permitido.',
              ),
            ),
          ],
        ),
      );

      expect(
        find.text('Este imóvel já tem 30 fotos, o máximo permitido.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Tentar de novo'));
      await tester.tap(find.text('Remover'));

      verify(() => cubit.tentarDeNovoEnvio(7)).called(1);
      verify(() => cubit.remover(7)).called(1);
    });

    testWidgets('falha sem mensagem usa o texto fixo (envio e preparo)', (
      tester,
    ) async {
      await montar(
        tester,
        _carregado(
          fila: [
            _envio(1, const EstadoEnvio.falhou()),
            _envio(2, const EstadoEnvio.falhou(noPreparo: true)),
          ],
        ),
      );

      expect(find.text('Não foi possível enviar.'), findsOneWidget);
      expect(find.text('Não foi possível preparar a foto.'), findsOneWidget);
    });
  });

  group('avisos', () {
    testWidgets('falha de operação mostra a mensagem do servidor, se houver', (
      tester,
    ) async {
      final estado = _carregado();
      await montar(
        tester,
        estado,
        depois: Stream.fromIterable([
          estado.copyWith(falhasDeOperacao: 1),
          estado.copyWith(
            falhasDeOperacao: 2,
            mensagemDaUltimaFalha:
                'Envie a lista completa das fotos deste imóvel, sem repetir.',
          ),
        ]),
      );
      await tester.pump();

      expect(
        find.text(
          'Envie a lista completa das fotos deste imóvel, sem repetir.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('falha de operação sem mensagem usa o texto fixo', (
      tester,
    ) async {
      final estado = _carregado();
      await montar(
        tester,
        estado,
        depois: Stream.value(estado.copyWith(falhasDeOperacao: 1)),
      );
      await tester.pump();

      expect(find.text('Não foi possível salvar a mudança.'), findsOneWidget);
    });

    testWidgets('foto apagada e câmera que não abre mostram o aviso', (
      tester,
    ) async {
      final estado = _carregado();
      await montar(
        tester,
        estado,
        depois: Stream.value(estado.copyWith(fotosApagadas: 1)),
      );
      await tester.pump();
      expect(find.text('Foto apagada.'), findsOneWidget);
    });

    testWidgets('câmera ou galeria que não abre mostra o aviso', (
      tester,
    ) async {
      final estado = _carregado();
      await montar(
        tester,
        estado,
        depois: Stream.value(estado.copyWith(falhasAoEscolher: 1)),
      );
      await tester.pump();
      expect(
        find.text('Não foi possível abrir a câmera ou a galeria.'),
        findsOneWidget,
      );
    });
  });

  group('sessão e saída', () {
    void registrarLogin() {
      final login = _LoginCubitFalso();
      whenListen(
        login,
        const Stream<LoginState>.empty(),
        initialState: const LoginState.editando(),
      );
      getIt.registerFactory<LoginCubit>(() => login);
    }

    testWidgets('401 volta ao login com o aviso', (tester) async {
      registrarLogin();
      await montar(
        tester,
        _carregado(),
        depois: Stream.value(
          const FotosImovelState(lista: ListaFotos.sessaoExpirada()),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => sessao.encerrarPorExpiracao()).called(1);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(FotosImovelScreen), findsNothing);
    });

    testWidgets('sessão já expirada quando a tela abre também volta ao login', (
      tester,
    ) async {
      registrarLogin();
      await montar(
        tester,
        const FotosImovelState(lista: ListaFotos.sessaoExpirada()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('voltar com envio pendente pede confirmação; "Continuar '
        'enviando" fica, "Sair" sai', (tester) async {
      await montar(
        tester,
        _carregado(fila: [_envio(1, const EstadoEnvio.aguardando())]),
        comRotaEmbaixo: true,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Sair e cancelar os envios?'), findsOneWidget);
      await tester.tap(find.text('Continuar enviando'));
      await tester.pumpAndSettle();
      expect(find.byType(FotosImovelScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      expect(find.byType(FotosImovelScreen), findsNothing);
    });

    testWidgets('sem envio pendente, voltar sai direto', (tester) async {
      await montar(
        tester,
        _carregado(fila: [_envio(1, const EstadoEnvio.falhou())]),
        comRotaEmbaixo: true,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Sair e cancelar os envios?'), findsNothing);
      expect(find.byType(FotosImovelScreen), findsNothing);
    });
  });

  group('resultado devolvido à gestão (fotosAlteradasDe)', () {
    test('nada mudou → null', () {
      expect(fotosAlteradasDe(_carregado()), isNull);
    });

    test('mudou com a lista carregada → a capa que o servidor marcou', () {
      expect(
        fotosAlteradasDe(_carregado().copyWith(mudou: true)),
        const FotosAlteradas(
          urlDaCapa: 'http://api.test/media/imoveis/fotos/10.jpg',
          capaConhecida: true,
        ),
      );
    });

    test('mudou e ficou sem fotos → capa conhecida e nula', () {
      expect(
        fotosAlteradasDe(_carregado(fotos: const []).copyWith(mudou: true)),
        const FotosAlteradas(urlDaCapa: null, capaConhecida: true),
      );
    });

    test('mudou mas a lista final não é conhecida → capa desconhecida', () {
      expect(
        fotosAlteradasDe(
          const FotosImovelState(lista: ListaFotos.erro(), mudou: true),
        ),
        const FotosAlteradas(urlDaCapa: null, capaConhecida: false),
      );
    });
  });
}
