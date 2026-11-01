import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../mocks/imoveis_detalhe_fixture.dart';
import '../models/detalhe_imovel_model.dart';
import 'imovel_detalhe_datasource.dart';

/// Gatilho determinístico de falha do servidor simulado do detalhe (D-17) —
/// disparado ao buscar o id reservado [idDetalheFalhaMock]. Vive só aqui: sai
/// junto com o resto do mock no plano 05-14, nunca em `domain/` ou
/// `presentation/`.
class FalhaSimuladaDoMock implements Exception {
  const FalhaSimuladaDoMock();

  @override
  String toString() =>
      'FalhaSimuladaDoMock: falha determinística provocada pelo id '
      'reservado do detalhe (D-17)';
}

/// Servidor simulado do detalhe do imóvel — serve mapas de wire da fixture,
/// parseados pelo MESMO `DetalheImovelModel.fromJson` que o remoto da Fase 5
/// usará. O construtor padrão (o único que o `injectable` enxerga) usa a
/// fixture fixa com a latência simulada de rede; testes usam
/// [ImovelDetalheMockDataSource.paraTeste] para injetar detalhes/latência
/// próprios.
@LazySingleton(as: ImovelDetalheDataSource)
class ImovelDetalheMockDataSource implements ImovelDetalheDataSource {
  ImovelDetalheMockDataSource()
    : _detalhes = detalhesAcervoFixture(),
      _latencia = const Duration(milliseconds: 500);

  @visibleForTesting
  ImovelDetalheMockDataSource.paraTeste({
    required Map<int, Map<String, Object?>> detalhes,
    Duration latencia = Duration.zero,
    // ignore: prefer_initializing_formals
  }) : _detalhes = detalhes,
       // ignore: prefer_initializing_formals
       _latencia = latencia;

  final Map<int, Map<String, Object?>> _detalhes;
  final Duration _latencia;

  @override
  Future<DetalheImovelModel> buscarDetalhe(int id) async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }
    if (id == idDetalheFalhaMock) {
      // Falha determinística (D-17): o detalhe existe no servidor simulado,
      // mas buscá-lo sempre falha — prova o fluxo "Tentar de novo" à mão.
      throw const FalhaSimuladaDoMock();
    }
    final mapa = _detalhes[id];
    if (mapa == null) {
      // 404 simulado (D-01): imóvel inexistente ou não publicado.
      throw const ImovelNaoEncontradoException();
    }
    return DetalheImovelModel.fromJson(mapa);
  }
}
