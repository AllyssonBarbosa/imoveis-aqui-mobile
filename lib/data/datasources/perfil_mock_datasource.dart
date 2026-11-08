import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../../domain/repositories/perfil_repository.dart';
import '../mocks/perfis_fixture.dart';
import '../models/perfil_corretor_model.dart';
import '../models/perfil_empresa_model.dart';
import 'perfil_datasource.dart';

/// Servidor simulado dos perfis públicos — serve mapas de wire da fixture,
/// parseados pelo MESMO `PerfilCorretorModel.fromJson` que a DataSource remota
/// usará. O construtor padrão (o único que o `injectable` enxerga) usa a
/// fixture fixa com a latência simulada de rede; testes usam
/// [PerfilMockDataSource.paraTeste] para injetar corretores/latência próprios.
@LazySingleton(as: PerfilDataSource)
class PerfilMockDataSource implements PerfilDataSource {
  PerfilMockDataSource()
    : _corretores = corretoresPerfisFixture(),
      _empresas = empresasPerfisFixture(),
      _latencia = const Duration(milliseconds: 500);

  @visibleForTesting
  PerfilMockDataSource.paraTeste({
    required Map<int, Map<String, Object?>> corretores,
    Map<int, Map<String, Object?>> empresas = const {},
    Duration latencia = Duration.zero,
    // ignore: prefer_initializing_formals
  }) : _corretores = corretores,
       // ignore: prefer_initializing_formals
       _empresas = empresas,
       // ignore: prefer_initializing_formals
       _latencia = latencia;

  final Map<int, Map<String, Object?>> _corretores;
  final Map<int, Map<String, Object?>> _empresas;
  final Duration _latencia;

  @override
  Future<PerfilCorretorModel> buscarCorretor(int id) async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }
    // Corretor reservado e desativado (PERF-05, D-15): sempre 404, antes de
    // olhar o mapa — nenhum dado dele chega à tela.
    if (id == idCorretorDesativadoMock) {
      throw const PerfilNaoEncontradoException();
    }
    final mapa = _corretores[id];
    if (mapa == null) {
      // 404 simulado (D-04): corretor inexistente, que não é corretor ou
      // desativado.
      throw const PerfilNaoEncontradoException();
    }
    return PerfilCorretorModel.fromJson(mapa);
  }

  @override
  Future<PerfilEmpresaModel> buscarEmpresa(int id) async {
    if (_latencia > Duration.zero) {
      await Future<void>.delayed(_latencia);
    }
    final mapa = _empresas[id];
    if (mapa == null) {
      // 404 simulado (D-04): empresa inexistente ou inativa.
      throw const PerfilNaoEncontradoException();
    }
    return PerfilEmpresaModel.fromJson(mapa);
  }
}
