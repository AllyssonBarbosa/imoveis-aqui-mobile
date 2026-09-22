import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../data/constants/uf_lookup.dart';
import '../../presentation/cidade_selecao/cidade_selecao_state.dart';
import '../entities/cidade.dart';
import '../gateways/geocoding_gateway.dart';
import '../gateways/geolocator_gateway.dart';
import '../repositories/cidade_repository.dart';

/// Orquestra GPS + reverse geocoding + casamento com a lista atendida
/// (D-09), retornando diretamente o [CidadeSelecaoState] resultante — nunca
/// lança, cada chamada falível (asset, GPS, geocodificação) é consumida via
/// [Result] e mapeada para um estado explícito (LOC-06).
///
/// Assume que a permissão já foi concedida (`whileInUse`/`always`) — o
/// [CidadeSelecaoCubit] só invoca este caso de uso depois de resolver o
/// fluxo de permissão (RESEARCH Pattern 4).
@injectable
class DetectarCidadeUseCase {
  DetectarCidadeUseCase(this._geolocator, this._geocoding, this._repositorio);

  final GeolocatorGateway _geolocator;
  final GeocodingGateway _geocoding;
  final CidadeRepository _repositorio;

  Future<CidadeSelecaoState> call() async {
    final resultadoLista = await _repositorio.obterCidadesAtendidas();
    final List<Cidade> cidadesAtendidas;
    switch (resultadoLista) {
      case Success(:final data):
        cidadesAtendidas = data;
      case Failure():
      case Loading():
        return const CidadeSelecaoState.erroCarregarCidades();
    }

    final resultadoPosicao = await _geolocator.obterPosicaoAtual();
    final GatewayPosicao posicao;
    switch (resultadoPosicao) {
      case Success(:final data):
        posicao = data;
      case Failure():
      case Loading():
        return CidadeSelecaoState.falhaGeocodificacao(cidadesAtendidas);
    }

    final resultadoLugar = await _geocoding.cidadeDeCoordenadas(
      posicao.latitude,
      posicao.longitude,
    );
    final GatewayLugar lugar;
    switch (resultadoLugar) {
      case Success(:final data):
        lugar = data;
      case Failure():
      case Loading():
        return CidadeSelecaoState.falhaGeocodificacao(cidadesAtendidas);
    }

    final localidade = lugar.localidade;
    final uf = UfLookup.normalizarUf(lugar.administrativeArea);
    if (localidade == null || localidade.trim().isEmpty || uf == null) {
      // Sem localidade ou UF resolvível — mesmo desfecho explícito de falha
      // de geocodificação (nenhum resultado utilizável), D-12.
      return CidadeSelecaoState.falhaGeocodificacao(cidadesAtendidas);
    }

    final chaveDetectada = Cidade(nome: localidade, uf: uf).chaveNatural;
    for (final cidade in cidadesAtendidas) {
      if (cidade.chaveNatural == chaveDetectada) {
        return CidadeSelecaoState.autorizadaEAtendida(cidade);
      }
    }
    return CidadeSelecaoState.autorizadaNaoAtendida(
      localidade,
      cidadesAtendidas,
    );
  }
}
