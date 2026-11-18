import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/core/result.dart';
import 'package:imoveis_aqui/data/datasources/contato_remote_datasource.dart';
import 'package:imoveis_aqui/data/gateways/url_launcher_gateway_impl.dart';
import 'package:imoveis_aqui/data/repositories/contato_repository_impl.dart';
import 'package:imoveis_aqui/domain/entities/canal_contato.dart';
import 'package:imoveis_aqui/domain/usecases/contatar_corretor_usecase.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../support/api_falsa.dart';

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
}
