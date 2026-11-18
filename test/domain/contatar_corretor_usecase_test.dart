import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/contato_remote_datasource.dart';
import 'package:imoveis_aqui/data/gateways/url_launcher_gateway_impl.dart';
import 'package:imoveis_aqui/data/repositories/contato_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/gateways/link_launcher_gateway.dart';
import 'package:imoveis_aqui/domain/repositories/contato_repository.dart';
import 'package:imoveis_aqui/domain/repositories/imovel_detalhe_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:imoveis_aqui/domain/usecases/contatar_corretor_usecase.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../support/api_falsa.dart';

class _ContatoRepositoryFalso extends Mock implements ContatoRepository {}

class _LinkLauncherFalso extends Mock implements LinkLauncherGateway {}

/// Plataforma falsa que grava o que o `url_launcher` pediria ao sistema e
/// quantas chamadas a [ApiFalsa] já tinha recebido naquele instante.
class _LauncherFalso extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  _LauncherFalso(this._api);

  final ApiFalsa _api;
  final List<String> urls = [];
  final List<PreferredLaunchMode> modos = [];
  final List<int> chamadasNoLancamento = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urls.add(url);
    modos.add(options.mode);
    chamadasNoLancamento.add(_api.chamadas.length);
    return true;
  }
}

void main() {
  group('ponta a ponta (ApiFalsa + UrlLauncherPlatform falso)', () {
    test(
      'registra o contato e entrega ao sistema o link capturado do WhatsApp',
      () async {
        final api = ApiFalsa();
        final falso = _LauncherFalso(api);
        final original = UrlLauncherPlatform.instance;
        UrlLauncherPlatform.instance = falso;
        addTearDown(() => UrlLauncherPlatform.instance = original);

        final idCasa =
            (lerFixtureApi('detalhe_casa.json')! as Map<String, Object?>)['id']!
                as int;
        final capturado =
            lerFixtureApi('contato_201_whatsapp.json')! as Map<String, Object?>;

        final casoDeUso = ContatarCorretorUseCase(
          ContatoRepositoryImpl(ContatoRemoteDataSource(api.criarDio())),
          UrlLauncherGatewayImpl(),
        );

        final resultado = await casoDeUso(idCasa, CanalContato.whatsapp);

        expect(resultado, isA<Success<void>>());
        expect(falso.urls, [capturado['link']]);
        expect(falso.modos, [PreferredLaunchMode.externalApplication]);
        expect(falso.chamadasNoLancamento, [1]);
        expect(api.chamadas.where((c) => c.metodo == 'POST'), hasLength(1));
      },
    );
  });

  group('bordas', () {
    late _ContatoRepositoryFalso repositorio;
    late _LinkLauncherFalso gateway;
    late ContatarCorretorUseCase casoDeUso;

    final uri = Uri.parse('https://wa.me/5519988887777?text=Ol%C3%A1');

    setUpAll(() {
      registerFallbackValue(Uri());
      registerFallbackValue(CanalContato.whatsapp);
    });

    setUp(() {
      repositorio = _ContatoRepositoryFalso();
      gateway = _LinkLauncherFalso();
      casoDeUso = ContatarCorretorUseCase(repositorio, gateway);
    });

    test(
      'registro ok e abertura true: Success, registra antes de abrir',
      () async {
        when(() => repositorio.registrarContato(any(), any()))
            .thenAnswer((_) async => Result.success(uri));
        when(() => gateway.abrir(any())).thenAnswer((_) async => true);

        final resultado = await casoDeUso(7, CanalContato.whatsapp);

        expect(resultado, isA<Success<void>>());
        verifyInOrder([
          () => repositorio.registrarContato(7, CanalContato.whatsapp),
          () => gateway.abrir(uri),
        ]);
      },
    );

    final falhas = <String, Exception>{
      'CanalIndisponivelException': const CanalIndisponivelException(),
      'ImovelNaoEncontradoException': const ImovelNaoEncontradoException(),
      'ContatoLimiteExcedidoException': const ContatoLimiteExcedidoException(),
      'LinkContatoInvalidoException': const LinkContatoInvalidoException(),
      'DioException': DioException(
        requestOptions: RequestOptions(path: '/contato/'),
        type: DioExceptionType.connectionTimeout,
      ),
    };
    falhas.forEach((nome, erro) {
      test('falha no registro ($nome): mesma falha e nada é aberto', () async {
        when(() => repositorio.registrarContato(any(), any()))
            .thenAnswer((_) async => Result.failure(erro));

        final resultado = await casoDeUso(7, CanalContato.telefone);

        expect(resultado, isA<Failure<void>>());
        expect((resultado as Failure<void>).erro, same(erro));
        verifyNever(() => gateway.abrir(any()));
      });
    });

    test('registro ok e abertura false: ContatoSemAplicativoException sem '
        'desfazer o registro', () async {
      when(() => repositorio.registrarContato(any(), any()))
          .thenAnswer((_) async => Result.success(uri));
      when(() => gateway.abrir(any())).thenAnswer((_) async => false);

      final resultado = await casoDeUso(7, CanalContato.whatsapp);

      expect(resultado, isA<Failure<void>>());
      expect(
        (resultado as Failure<void>).erro,
        isA<ContatoSemAplicativoException>(),
      );
      verify(() => repositorio.registrarContato(7, CanalContato.whatsapp))
          .called(1);
      verifyNoMoreInteractions(repositorio);
    });

    test('repositório em Loading: Loading e nada é aberto', () async {
      when(() => repositorio.registrarContato(any(), any()))
          .thenAnswer((_) async => const Result.loading());

      final resultado = await casoDeUso(7, CanalContato.email);

      expect(resultado, isA<Loading<void>>());
      verifyNever(() => gateway.abrir(any()));
    });
  });
}
