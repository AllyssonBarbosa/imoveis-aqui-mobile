import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/gateways/geocoding_gateway.dart';

/// Implementação concreta de [GeocodingGateway] sobre
/// `geocoding.placemarkFromCoordinates`.
///
/// Captura `MissingPluginException`/`UnimplementedError` (plataforma sem
/// suporte a geocoding, ex. um desenvolvedor rodando em Windows desktop —
/// RESEARCH Pitfall 1/A1) e qualquer outra falha (sem internet, timeout, sem
/// resultado) como [Result.failure] — o caso de uso mapeia isso para o
/// desfecho `falhaGeocodificacao` (D-12), nunca uma exceção não tratada.
@LazySingleton(as: GeocodingGateway)
class GeocodingGatewayImpl implements GeocodingGateway {
  final Geocoding _geocoding = Geocoding();

  @override
  Future<Result<GatewayLugar>> cidadeDeCoordenadas(
    double latitude,
    double longitude,
  ) async {
    try {
      final lugares = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (lugares.isEmpty) {
        return Result.failure(Exception('Reverse geocoding sem resultado'));
      }
      final lugar = lugares.first;
      return Result.success(
        GatewayLugar(
          localidade: lugar.locality,
          administrativeArea: lugar.administrativeArea,
        ),
      );
    } on Exception catch (erro) {
      // Cobre MissingPluginException e UnimplementedError (ambas são
      // subtipos de Exception/Error conforme a plataforma) além de falhas
      // de rede/timeout — todas viram o mesmo desfecho explícito.
      return Result.failure(erro);
    } on Error catch (erro) {
      return Result.failure(Exception(erro.toString()));
    }
  }
}
