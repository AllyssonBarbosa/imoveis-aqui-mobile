import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/gateways/geolocator_gateway.dart';
import '../../domain/usecases/detectar_cidade_usecase.dart';
import '../../domain/usecases/obter_cidades_atendidas_usecase.dart';
import 'cidade_selecao_state.dart';

/// Orquestra o fluxo de permissão de localização (RESEARCH Pattern 4) e
/// delega a detecção GPS+geocodificação ao [DetectarCidadeUseCase] — nunca
/// chama `geolocator`/`geocoding` diretamente (sempre via
/// [GeolocatorGateway]).
///
/// `solicitarPermissao()` (equivalente a `Geolocator.requestPermission()`) é
/// disparado no máximo uma vez por tentativa de detecção, e só a partir de
/// [detectarCidade] — nunca na construção do Cubit (D-05).
@injectable
class CidadeSelecaoCubit extends Cubit<CidadeSelecaoState> {
  CidadeSelecaoCubit(
    this._geolocator,
    this._obterCidadesAtendidas,
    this._detectarCidade,
  ) : super(const CidadeSelecaoState.localizando());

  final GeolocatorGateway _geolocator;
  final ObterCidadesAtendidasUseCase _obterCidadesAtendidas;
  final DetectarCidadeUseCase _detectarCidade;

  /// Ponto de entrada único do fluxo de localização — chamado a partir do
  /// toque no CTA da tela de priming (D-05), nunca em `initState`.
  Future<void> detectarCidade() async {
    emit(const CidadeSelecaoState.localizando());

    final servicoHabilitado = await _geolocator.isServicoHabilitado();
    if (!servicoHabilitado) {
      await _emitirComListaAtendida(CidadeSelecaoState.servicoDesligado);
      return;
    }

    var permissao = await _geolocator.verificarPermissao();
    if (permissao == GatewayPermissaoLocalizacao.negada) {
      permissao = await _geolocator.solicitarPermissao();
    }

    switch (permissao) {
      case GatewayPermissaoLocalizacao.negada:
      case GatewayPermissaoLocalizacao.indeterminada:
        await _emitirComListaAtendida(CidadeSelecaoState.recusada);
      case GatewayPermissaoLocalizacao.negadaParaSempre:
        await _emitirComListaAtendida(CidadeSelecaoState.bloqueadaParaSempre);
      case GatewayPermissaoLocalizacao.duranteUso:
      case GatewayPermissaoLocalizacao.sempre:
        emit(await _detectarCidade());
    }
  }

  /// Carrega a lista de cidades atendidas para os caminhos que mostram a
  /// lista diretamente (ex.: "Tentar de novo" em [ErroCarregarCidades]) —
  /// emite [CidadeSelecaoState.erroCarregarCidades] em caso de falha, nunca
  /// uma tela fatal.
  Future<void> carregarLista() async {
    emit(const CidadeSelecaoState.localizando());
    await _emitirComListaAtendida(CidadeSelecaoState.recusada);
  }

  /// Entrada direta numa cidade sem passar pelo fluxo de GPS — usada tanto
  /// para a cidade já salva no aparelho (D-08, nunca re-pedir GPS) quanto
  /// para a seleção manual de uma cidade na lista (D-10 aplicado por
  /// analogia: sem passo de confirmação).
  void entrarDireto(Cidade cidade) {
    emit(CidadeSelecaoState.autorizadaEAtendida(cidade));
  }

  Future<void> _emitirComListaAtendida(
    CidadeSelecaoState Function(List<Cidade>) construirEstado,
  ) async {
    final resultado = await _obterCidadesAtendidas();
    switch (resultado) {
      case Success(:final data):
        emit(construirEstado(data));
      case Failure():
        emit(const CidadeSelecaoState.erroCarregarCidades());
      case Loading():
        break;
    }
  }
}
