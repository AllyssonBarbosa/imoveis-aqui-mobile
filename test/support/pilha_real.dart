import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/datasources/armazenamento_token.dart';
import 'package:imoveis_aqui/data/network/interceptador_sessao.dart';
import 'package:imoveis_aqui/di/injection.dart';
import 'package:imoveis_aqui/domain/entities/cidade.dart';
import 'package:imoveis_aqui/domain/gateways/preparador_de_foto_gateway.dart';
import 'package:imoveis_aqui/domain/gateways/seletor_de_fotos_gateway.dart';
import 'package:imoveis_aqui/domain/usecases/salvar_cidade_usecase.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_cubit.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_screen.dart';
import 'package:imoveis_aqui/presentation/cidade_selecao/cidade_selecao_state.dart';
import 'package:imoveis_aqui/presentation/sessao/botao_sessao_topo.dart';
import 'package:imoveis_aqui/presentation/sessao/sessao_cubit.dart';
import 'package:mocktail/mocktail.dart';

import 'api_falsa.dart';
import 'armazenamento_token_em_memoria.dart';

/// Token de 40 zeros de `login_200.json`: o único token das fixtures.
const String tokenDasFixtures = '0000000000000000000000000000000000000000';

class _CidadeSelecaoCubitFalso extends MockCubit<CidadeSelecaoState>
    implements CidadeSelecaoCubit {}

class _SalvarCidadeUseCaseFalso extends Mock implements SalvarCidadeUseCase {}

/// A pilha REAL do app (DI de produção: Cubits, use cases, repositórios,
/// DataSources e `InterceptadorSessao`) sobre a [ApiFalsa] com o wire capturado
/// do Django. Troca só o que toca o mundo de fora: o `Dio` público, o `Dio`
/// `'autenticado'` e o `ArmazenamentoToken` (no lugar do Keychain/Keystore).
///
/// Usada pelos fluxos ponta a ponta da fase 08 (login e acervo).
class PilhaReal {
  PilhaReal._(this.api, this.armazenamento);

  final ApiFalsa api;
  final ArmazenamentoTokenEmMemoria armazenamento;

  /// Monta o DI de produção com as trocas. [token] é o token já guardado no
  /// aparelho (sessão existente); `null` abre sem sessão.
  static Future<PilhaReal> preparar({String? token}) async {
    final api = ApiFalsa();
    final armazenamento = ArmazenamentoTokenEmMemoria(token);
    await configureDependencies();
    // Antes de resolver qualquer coisa: todas as DataSources são preguiçosas.
    getIt.unregister<ArmazenamentoToken>();
    getIt.registerSingleton<ArmazenamentoToken>(armazenamento);
    getIt.unregister<Dio>();
    getIt.registerLazySingleton<Dio>(api.criarDio);
    getIt.unregister<Dio>(instanceName: 'autenticado');
    getIt.registerLazySingleton<Dio>(
      () => api.criarDioAutenticado(getIt<InterceptadorSessao>()),
      instanceName: 'autenticado',
    );
    return PilhaReal._(api, armazenamento);
  }

  /// Troca só os plugins das fotos (APP 11) — câmera/galeria e compressão, que
  /// não rodam em `flutter test` — por falsos; DataSource, repositório, use
  /// cases e Cubit continuam os de produção. Chamar antes de abrir a tela.
  void trocarPluginsDeFotos({
    required SeletorDeFotosGateway seletor,
    required PreparadorDeFotoGateway preparador,
  }) {
    getIt.unregister<SeletorDeFotosGateway>();
    getIt.registerSingleton<SeletorDeFotosGateway>(seletor);
    getIt.unregister<PreparadorDeFotoGateway>();
    getIt.registerSingleton<PreparadorDeFotoGateway>(preparador);
  }

  /// Campinas como a API devolve (com id), lida da fixture capturada.
  static Cidade get campinas {
    final linhas = lerFixtureApi('cidades.json')! as List<Object?>;
    final linha = linhas.cast<Map<String, Object?>>().firstWhere(
      (c) => c['nome'] == 'Campinas',
    );
    return Cidade(
      id: linha['id']! as int,
      nome: linha['nome']! as String,
      uf: linha['uf']! as String,
    );
  }

  /// Monta o app como o `main()`: `SessaoCubit` singleton acima do
  /// `MaterialApp`, carregado sem `await` (AC-6), e a vitrine de Campinas com
  /// o [BotaoSessaoTopo] — só o `CidadeSelecaoCubit` é falso, para ir direto
  /// ao desfecho "cidade atendida".
  Future<void> abrirApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cidadeCubit = _CidadeSelecaoCubitFalso();
    whenListen(
      cidadeCubit,
      Stream<CidadeSelecaoState>.value(
        CidadeSelecaoState.autorizadaEAtendida(campinas),
      ),
      initialState: CidadeSelecaoState.autorizadaEAtendida(campinas),
    );
    final sessao = getIt<SessaoCubit>()..carregar();
    await tester.pumpWidget(
      BlocProvider<SessaoCubit>.value(
        value: sessao,
        child: MaterialApp(
          home: BlocProvider<CidadeSelecaoCubit>.value(
            value: cidadeCubit,
            child: CidadeSelecaoScreen(
              salvarCidade: _SalvarCidadeUseCaseFalso(),
              acaoSessao: const BotaoSessaoTopo(),
            ),
          ),
        ),
      ),
    );
    await assentar(tester);
  }

  /// Abre o app (como [abrirApp]) e entra em "Meu acervo" pelo botão do topo,
  /// como o usuário faz; deixa a primeira página do acervo na tela. A entrada
  /// pergunta o papel e se substitui pelo acervo (duas transições).
  Future<void> entrarNoAcervo(WidgetTester tester) async {
    await abrirApp(tester);
    expect(find.text('Meu acervo'), findsOneWidget);
    await tester.tap(find.text('Meu acervo'));
    await assentar(tester, quadros: 12);
  }

  /// Confere o que o app mandou em cada rota: o login e as rotas públicas
  /// nunca levam `Authorization`; `eu`, `sair`, toda rota `/api/imoveis/...`
  /// (acervo e gestão do imóvel), as rotas da caixa de contatos
  /// (`/api/contatos/...`) e as dos relatórios do gestor (`/api/relatorios/...`)
  /// sempre levam o token (T-08-45, T-09-04, T-12-23).
  void conferirCabecalhosDeAutorizacao() {
    for (final pedido in api.requisicoesGravadas) {
      final caminho = pedido.uri.path;
      final autorizacao = pedido.cabecalho('authorization');
      final autenticada =
          caminho == '/api/auth/eu/' ||
          caminho == '/api/auth/sair/' ||
          caminho.startsWith('/api/imoveis/') ||
          caminho.startsWith('/api/contatos/') ||
          caminho.startsWith('/api/relatorios/');
      if (autenticada) {
        expect(
          autorizacao,
          'Token $tokenDasFixtures',
          reason: '${pedido.metodo} $caminho deveria levar o token',
        );
      } else {
        expect(
          autorizacao,
          isNull,
          reason: '${pedido.metodo} $caminho nunca leva o token',
        );
      }
    }
  }
}

/// Deixa as respostas do `dio` e as transições de rota chegarem. Nunca
/// `pumpAndSettle`: o indicador de progresso mantém a animação de pé.
Future<void> assentar(WidgetTester tester, {int quadros = 6}) async {
  for (var i = 0; i < quadros; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
