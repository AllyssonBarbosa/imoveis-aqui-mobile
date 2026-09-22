import '../../core/result.dart';

/// Wrapper mockável sobre as funções estáticas do pacote `geolocator`.
///
/// `geolocator` expõe funções top-level estáticas, que `mocktail` não
/// consegue mockar diretamente — este gateway é a infraestrutura necessária
/// para que [lib/domain/usecases/detectar_cidade_usecase.dart] e o Cubit
/// sejam testáveis sem tocar a plataforma real (RESEARCH §Wave 0 Gaps).
abstract class GeolocatorGateway {
  /// Verifica se o serviço de localização do aparelho está ligado.
  Future<bool> isServicoHabilitado();

  /// Lê a permissão de localização atual, sem solicitar ao usuário.
  Future<GatewayPermissaoLocalizacao> verificarPermissao();

  /// Solicita a permissão de localização ao usuário (dispara o prompt
  /// nativo do OS) — só deve ser chamado a partir do toque no CTA da tela
  /// de priming (D-05), nunca em `initState`.
  Future<GatewayPermissaoLocalizacao> solicitarPermissao();

  /// Obtém a posição atual (GPS), apenas com escopo `whileInUse`.
  Future<Result<GatewayPosicao>> obterPosicaoAtual();

  /// Abre as configurações do sistema para o usuário ativar a permissão
  /// manualmente (usado no desfecho `deniedForever`, D-06).
  Future<void> abrirConfiguracoesApp();
}

/// Espelha `LocationPermission` do pacote `geolocator`, desacoplado da
/// dependência externa no nível de domínio.
enum GatewayPermissaoLocalizacao {
  negada,
  negadaParaSempre,
  duranteUso,
  sempre,
  indeterminada,
}

/// Coordenadas transientes — nunca persistidas nem enviadas a servidor
/// (T-01-03-01); usadas apenas para resolver a cidade via reverse geocoding.
class GatewayPosicao {
  const GatewayPosicao({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
