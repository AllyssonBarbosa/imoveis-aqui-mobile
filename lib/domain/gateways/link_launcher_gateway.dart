/// Wrapper mockável sobre `url_launcher.launchUrl` (função estática, não
/// mockável diretamente por `mocktail`) — D-16.
abstract class LinkLauncherGateway {
  /// Abre [link] em um aplicativo externo (WhatsApp, discador, e-mail ou o
  /// navegador do sistema).
  ///
  /// Devolve `true` quando o sistema aceitou abrir o link; `false` quando
  /// nada o trata. Nunca lança para o chamador.
  Future<bool> abrir(Uri link);
}

/// O contato já foi registrado no servidor, mas nenhum aplicativo do aparelho
/// abriu o link (D-15). O registro nunca é desfeito.
class ContatoSemAplicativoException implements Exception {
  const ContatoSemAplicativoException();

  @override
  String toString() => 'Nenhum aplicativo abriu o link de contato.';
}
