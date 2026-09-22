import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/gateways/geolocator_gateway.dart';

/// Implementação concreta de [GeolocatorGateway] sobre as funções estáticas
/// do pacote `geolocator`. Solicita SEMPRE `whileInUse` — nunca
/// `always`/background (T-01-03-02, RESEARCH Anti-Patterns).
@LazySingleton(as: GeolocatorGateway)
class GeolocatorGatewayImpl implements GeolocatorGateway {
  @override
  Future<bool> isServicoHabilitado() => Geolocator.isLocationServiceEnabled();

  @override
  Future<GatewayPermissaoLocalizacao> verificarPermissao() async {
    try {
      final permissao = await Geolocator.checkPermission();
      return _paraGateway(permissao);
    } on Exception {
      // Pitfall 3: em algumas configurações (ex. Windows 11) checkPermission
      // pode lançar PlatformException em vez de retornar um enum limpo.
      // Tratamos como "negada" — o próximo passo prático do usuário é o
      // mesmo (verificar as configurações do aparelho).
      return GatewayPermissaoLocalizacao.negada;
    }
  }

  @override
  Future<GatewayPermissaoLocalizacao> solicitarPermissao() async {
    try {
      final permissao = await Geolocator.requestPermission();
      return _paraGateway(permissao);
    } on Exception {
      return GatewayPermissaoLocalizacao.negada;
    }
  }

  @override
  Future<Result<GatewayPosicao>> obterPosicaoAtual() async {
    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return Result.success(
        GatewayPosicao(latitude: posicao.latitude, longitude: posicao.longitude),
      );
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }

  @override
  Future<void> abrirConfiguracoesApp() async {
    await Geolocator.openAppSettings();
  }

  GatewayPermissaoLocalizacao _paraGateway(LocationPermission permissao) {
    switch (permissao) {
      case LocationPermission.denied:
        return GatewayPermissaoLocalizacao.negada;
      case LocationPermission.deniedForever:
        return GatewayPermissaoLocalizacao.negadaParaSempre;
      case LocationPermission.whileInUse:
        return GatewayPermissaoLocalizacao.duranteUso;
      case LocationPermission.always:
        return GatewayPermissaoLocalizacao.sempre;
      case LocationPermission.unableToDetermine:
        return GatewayPermissaoLocalizacao.indeterminada;
    }
  }
}
