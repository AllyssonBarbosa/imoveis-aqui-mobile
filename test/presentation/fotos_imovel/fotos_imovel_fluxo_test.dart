import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/foto_imovel.dart';
import 'package:imoveis_aqui/domain/gateways/preparador_de_foto_gateway.dart';
import 'package:imoveis_aqui/domain/gateways/seletor_de_fotos_gateway.dart';
import 'package:imoveis_aqui/presentation/fotos_imovel/fotos_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/gestao_imovel/gestao_imovel_screen.dart';
import 'package:imoveis_aqui/presentation/login/login_screen.dart';

import '../../support/api_falsa.dart';
import '../../support/pilha_real.dart';

/// Câmera e galeria falsas: devolvem o que o teste mandar.
class _SeletorFalso implements SeletorDeFotosGateway {
  List<FotoEscolhida> daGaleria = const [];

  @override
  Future<Result<FotoEscolhida?>> tirarFoto() async =>
      Result.success(daGaleria.firstOrNull);

  @override
  Future<Result<List<FotoEscolhida>>> escolherDaGaleria() async =>
      Result.success(daGaleria);
}

/// Compressão falsa: "prepara" escrevendo um arquivo de verdade (o Dio lê o
/// arquivo no multipart) e registra o que foi descartado.
class _PreparadorFalso implements PreparadorDeFotoGateway {
  _PreparadorFalso(this._pasta);

  final Directory _pasta;
  final List<String> descartadas = [];

  @override
  Future<Result<FotoEscolhida>> preparar(FotoEscolhida original) async {
    final nome = original.caminho.split('/').last;
    final arquivo = File('${_pasta.path}${Platform.pathSeparator}$nome')
      ..writeAsBytesSync(List.filled(2048, 1));
    return Result.success(FotoEscolhida(caminho: arquivo.path));
  }

  @override
  Future<void> descartar(FotoEscolhida preparada) async =>
      descartadas.add(preparada.caminho);
}

/// Fluxos ponta a ponta das fotos do imóvel (APP 11) pela pilha REAL do app
/// (acervo → gestão → Fotos → Cubit → UseCase → Repository → DataSource no
/// `Dio` autenticado) sobre a `ApiFalsa` com o wire capturado do Django. Só a
/// câmera/galeria e a compressão (plugins) são falsas.
void main() {
  late Directory pasta;
  late _SeletorFalso seletor;
  late _PreparadorFalso preparador;

  final gestao =
      lerFixtureApi('imovel_gestao_disponivel.json')! as Map<String, Object?>;
  final codigo = gestao['codigo']! as String;
  final id = gestao['id']! as int;
  final rotaFotos = '/api/imoveis/$id/fotos/';

  setUp(() {
    pasta = Directory.systemTemp.createTempSync('fotos_fluxo_');
    seletor = _SeletorFalso();
    preparador = _PreparadorFalso(pasta);
  });

  tearDown(() async {
    await getIt.reset();
    pasta.deleteSync(recursive: true);
  });

  /// Sessão guardada → "Meu acervo" → cartão do imóvel → gestão → "Fotos".
  Future<PilhaReal> abrirFotos(
    WidgetTester tester, {
    void Function(PilhaReal pilha)? antesDeAbrir,
  }) async {
    final pilha = await PilhaReal.preparar(token: tokenDasFixtures)
      ..trocarPluginsDeFotos(seletor: seletor, preparador: preparador);
    antesDeAbrir?.call(pilha);
    await pilha.entrarNoAcervo(tester);
    await tester.tap(find.text(codigo));
    await assentar(tester);
    final botao = find.widgetWithText(OutlinedButton, 'Fotos');
    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await assentar(tester);
    return pilha;
  }

  /// O envio lê o arquivo preparado com I/O assíncrono de verdade
  /// (`MultipartFile.fromFile`), que não anda no relógio falso do teste de
  /// widget: intercala tempo real (`runAsync`) com quadros até a fila assentar.
  Future<void> deixarEnviar(WidgetTester tester, {int voltas = 12}) async {
    for (var i = 0; i < voltas; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  List<String> pedidosDasFotos(PilhaReal pilha) => [
    for (final pedido in pilha.api.requisicoesDasFotos)
      '${pedido.metodo} ${pedido.uri.path}',
  ];

  testWidgets('"Fotos" na gestão abre a lista do servidor, com o token', (
    tester,
  ) async {
    final pilha = await abrirFotos(tester);

    expect(find.byType(FotosImovelScreen), findsOneWidget);
    expect(find.text('Foto 1'), findsOneWidget);
    expect(find.text('Foto 3'), findsOneWidget);
    expect(find.text('Capa'), findsOneWidget);
    expect(pedidosDasFotos(pilha), ['GET $rotaFotos']);
    pilha.conferirCabecalhosDeAutorizacao();
  });

  testWidgets('duas fotos da galeria sobem uma por vez (multipart, campo '
      'imagem), a lista é relida depois de cada uma e os JPEGs são '
      'descartados (FOT-01, FOT-02)', (tester) async {
    seletor.daGaleria = const [
      FotoEscolhida(caminho: '/galeria/a.jpg'),
      FotoEscolhida(caminho: '/galeria/b.jpg'),
    ];
    final pilha = await abrirFotos(tester);

    await tester.tap(find.text('Escolher da galeria'));
    await deixarEnviar(tester);

    expect(pedidosDasFotos(pilha), [
      'GET $rotaFotos',
      'POST $rotaFotos',
      'GET $rotaFotos',
      'POST $rotaFotos',
      'GET $rotaFotos',
    ]);
    final envios = pilha.api.requisicoesDasFotos.where(
      (pedido) => pedido.metodo == 'POST',
    );
    for (final envio in envios) {
      expect('name="imagem"'.allMatches(envio.corpoEmTexto), hasLength(1));
    }
    expect(envios.first.corpoEmTexto, contains('filename="foto.jpg"'));
    expect(find.text('Enviando…'), findsNothing, reason: 'fila vazia no fim');
    expect(preparador.descartadas, hasLength(2));
    pilha.conferirCabecalhosDeAutorizacao();
  });

  testWidgets('foto recusada pelo servidor mostra a mensagem dele e as '
      'opções; a fila não trava (FOT-02)', (tester) async {
    seletor.daGaleria = const [FotoEscolhida(caminho: '/galeria/a.jpg')];
    final pilha = await abrirFotos(tester);
    pilha.api.responder(
      (uri) => uri.path == rotaFotos,
      status: 400,
      fixture: 'erro_400_foto_limite.json',
    );

    await tester.tap(find.text('Escolher da galeria'));
    await deixarEnviar(tester);

    expect(
      find.text('Este imóvel já tem 30 fotos, o máximo permitido.'),
      findsOneWidget,
    );
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.text('Remover'), findsOneWidget);

    await tester.tap(find.text('Remover'));
    await assentar(tester);
    expect(
      find.text('Este imóvel já tem 30 fotos, o máximo permitido.'),
      findsNothing,
    );
    expect(preparador.descartadas, hasLength(1));
  });

  testWidgets('falha de rede no envio: "Tentar de novo" reenvia e a foto '
      'sobe (FOT-02)', (tester) async {
    seletor.daGaleria = const [FotoEscolhida(caminho: '/galeria/a.jpg')];
    final pilha = await abrirFotos(tester);
    pilha.api.falharProximas(rotaFotos, status: 500);

    await tester.tap(find.text('Escolher da galeria'));
    await deixarEnviar(tester);
    expect(find.text('Não foi possível enviar.'), findsOneWidget);

    await tester.tap(find.text('Tentar de novo'));
    await deixarEnviar(tester);

    expect(find.text('Não foi possível enviar.'), findsNothing);
    expect(
      pilha.api.requisicoesDasFotos.where((p) => p.metodo == 'POST'),
      hasLength(2),
    );
  });

  testWidgets('soltar a terceira foto no topo manda PUT com a lista completa '
      'e mostra a lista devolvida (FOT-03)', (tester) async {
    final pilha = await abrirFotos(tester);

    tester
        .widget<ReorderableListView>(find.byType(ReorderableListView))
        .onReorderItem!(2, 0);
    await assentar(tester);

    final put = pilha.api.chamadas.singleWhere(
      (chamada) => chamada.metodo == 'PUT',
    );
    expect(put.uri.path, '${rotaFotos}ordem/');
    expect(put.corpo, {
      'ids': [90, 88, 89],
    });
    // A lista mostrada é a que o servidor devolveu (fotos_reordenadas.json:
    // 90, 89, 88 com a capa na 88, agora a terceira).
    final fotos = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data)
        .toList();
    expect(fotos, ['Foto 1', 'Foto 2', 'Foto 3']);
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('Foto 3'),
          matching: find.byType(ListTile),
        ),
        matching: find.text('Capa'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('"Definir como capa" e "Apagar" com confirmação vão ao servidor '
      'e a tela mostra a lista devolvida (FOT-03, FOT-04)', (tester) async {
    final pilha = await abrirFotos(tester);

    await tester.tap(find.byTooltip('Ações da foto 2'));
    await assentar(tester);
    await tester.tap(find.text('Definir como capa'));
    await assentar(tester);
    expect(pedidosDasFotos(pilha).last, 'POST ${rotaFotos}89/capa/');

    await tester.tap(find.byTooltip('Ações da foto 2'));
    await assentar(tester);
    await tester.tap(find.text('Apagar'));
    await assentar(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Apagar'));
    await assentar(tester);

    expect(pedidosDasFotos(pilha).last, 'DELETE ${rotaFotos}89/');
    expect(find.text('Foto apagada.'), findsOneWidget);
    expect(find.text('Foto 3'), findsNothing, reason: 'restaram 2 no servidor');
    pilha.conferirCabecalhosDeAutorizacao();
  });

  testWidgets('voltar da tela de fotos e da gestão depois de mudar uma foto '
      'faz o acervo reler a API (capa nova no cartão, D-23)', (tester) async {
    final pilha = await abrirFotos(tester);
    await tester.tap(find.byTooltip('Ações da foto 2'));
    await assentar(tester);
    await tester.tap(find.text('Definir como capa'));
    await assentar(tester);
    final leiturasDoAcervo = pilha.api.requisicoesGravadas
        .where((p) => p.uri.path == '/api/imoveis/')
        .length;

    await tester.pageBack();
    await assentar(tester);
    expect(find.byType(GestaoImovelScreen), findsOneWidget);
    expect(find.text('Ver na vitrine'), findsOneWidget);
    await tester.pageBack();
    await assentar(tester);

    expect(
      pilha.api.requisicoesGravadas
          .where((p) => p.uri.path == '/api/imoveis/')
          .length,
      greaterThan(leiturasDoAcervo),
    );
  });

  testWidgets('401 no envio volta ao login com o aviso (FOT-05)', (
    tester,
  ) async {
    seletor.daGaleria = const [FotoEscolhida(caminho: '/galeria/a.jpg')];
    final pilha = await abrirFotos(tester);
    pilha.api.responder(
      (uri) => uri.path == rotaFotos,
      status: 401,
      fixture: 'erro_401.json',
    );

    await tester.tap(find.text('Escolher da galeria'));
    await deixarEnviar(tester);

    await assentar(tester, quadros: 8); // a tela de fotos termina de sair

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(FotosImovelScreen), findsNothing);
    expect(
      find.descendant(
        of: find.byType(LoginScreen),
        matching: find.text('Sua sessão terminou. Entre de novo.'),
      ),
      findsOneWidget,
    );
    expect(pilha.armazenamento.token, isNull);
  });

  testWidgets('imóvel de outra empresa (404) mostra o texto fixo, sem o '
      'detail em inglês (FOT-05)', (tester) async {
    await abrirFotos(
      tester,
      antesDeAbrir: (pilha) => pilha.api.responder(
        (uri) => uri.path == rotaFotos,
        status: 404,
        fixture: 'erro_404_fotos_outra_empresa.json',
      ),
    );

    expect(
      find.text('Este imóvel não está mais no seu acervo.'),
      findsOneWidget,
    );
    expect(find.textContaining('No Imovel'), findsNothing);
  });
}
