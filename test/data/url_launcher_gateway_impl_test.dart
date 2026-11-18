import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imoveis_aqui/data/gateways/url_launcher_gateway_impl.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Plataforma falsa: grava o pedido e devolve (ou lança) o que o teste mandar.
class _LauncherFalso extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  final List<String> urls = [];
  final List<PreferredLaunchMode> modos = [];
  Future<bool> Function() resposta = () async => true;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) {
    urls.add(url);
    modos.add(options.mode);
    return resposta();
  }
}

/// O gateway entrega o link ao sistema sempre como aplicativo externo e
/// transforma qualquer falha da plataforma em `false`, sem nunca lançar.
void main() {
  late _LauncherFalso falso;
  late UrlLauncherGatewayImpl gateway;

  setUp(() {
    falso = _LauncherFalso();
    final original = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = falso;
    addTearDown(() => UrlLauncherPlatform.instance = original);
    gateway = UrlLauncherGatewayImpl();
  });

  group('esquemas do contato', () {
    final links = <String, String>{
      'wa.me': 'https://wa.me/5519988887777?text=Ol%C3%A1',
      'tel': 'tel:+5519988887777',
      'mailto': 'mailto:a@b.com?subject=x',
    };
    links.forEach((nome, texto) {
      test(
        '$nome: o sistema recebe o mesmo texto como aplicativo externo',
        () async {
          final abriu = await gateway.abrir(Uri.parse(texto));

          expect(abriu, isTrue);
          expect(falso.urls, [texto]);
          expect(falso.modos, [PreferredLaunchMode.externalApplication]);
        },
      );
    });
  });

  group('falhas da plataforma viram false', () {
    final link = Uri.parse('https://wa.me/5519988887777');

    test('o sistema devolve false', () async {
      falso.resposta = () async => false;

      expect(await gateway.abrir(link), isFalse);
      expect(falso.modos, [PreferredLaunchMode.externalApplication]);
    });

    test('PlatformException ACTIVITY_NOT_FOUND', () async {
      falso.resposta = () async =>
          throw PlatformException(code: 'ACTIVITY_NOT_FOUND');

      expect(await gateway.abrir(link), isFalse);
    });

    test('ArgumentError', () async {
      falso.resposta = () async => throw ArgumentError('url inválida');

      expect(await gateway.abrir(link), isFalse);
    });
  });
}
