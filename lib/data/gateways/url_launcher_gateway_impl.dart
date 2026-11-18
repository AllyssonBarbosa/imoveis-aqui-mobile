import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/gateways/link_launcher_gateway.dart';

/// Implementação concreta de [LinkLauncherGateway] sobre `launchUrl`.
///
/// Sempre usa [LaunchMode.externalApplication]: o `platformDefault` abriria
/// `https://wa.me/...` numa aba interna do app (Custom Tab /
/// SFSafariViewController), mas o link do WhatsApp precisa sair do app — para o
/// aplicativo do WhatsApp ou, na falta dele, para o navegador externo.
///
/// Toda falha da plataforma vira `false`: o Android lança `PlatformException`
/// (`ACTIVITY_NOT_FOUND`) quando nada trata o link, o iOS lança para URL
/// inválida e os testes em `flutter test` podem lançar `MissingPluginException`.
/// O chamador só precisa saber se abriu ou não. O link nunca é registrado em
/// log (leva o código interno do imóvel e a mensagem do visitante).
@LazySingleton(as: LinkLauncherGateway)
class UrlLauncherGatewayImpl implements LinkLauncherGateway {
  @override
  Future<bool> abrir(Uri link) async {
    try {
      return await launchUrl(link, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    } on Error {
      return false;
    }
  }
}
