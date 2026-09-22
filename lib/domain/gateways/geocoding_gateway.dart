import '../../core/result.dart';

/// Wrapper mockável sobre `geocoding.placemarkFromCoordinates` (função
/// estática, não mockável diretamente por `mocktail` — RESEARCH §Wave 0
/// Gaps).
abstract class GeocodingGateway {
  /// Reverse geocoding: coordenadas → localidade + área administrativa.
  ///
  /// Retorna [Result.failure] em caso de falha de rede/timeout/sem
  /// resultado, ou quando a plataforma não suporta geocoding
  /// (`MissingPluginException`/`UnimplementedError`, Pitfall 1/A1) — nunca
  /// lança para o chamador.
  Future<Result<GatewayLugar>> cidadeDeCoordenadas(
    double latitude,
    double longitude,
  );
}

/// Pequeno value object com só os campos usados pelo casamento D-09 — não o
/// `Placemark` bruto do pacote `geocoding`.
class GatewayLugar {
  const GatewayLugar({required this.localidade, required this.administrativeArea});

  /// Nome da cidade (`Placemark.locality`).
  final String? localidade;

  /// Nome (frequentemente por extenso) ou sigla do estado
  /// (`Placemark.administrativeArea`) — precisa ser normalizado via
  /// `uf_lookup.dart` antes de comparar com `Cidade.uf` (Pitfall 2).
  final String? administrativeArea;
}
