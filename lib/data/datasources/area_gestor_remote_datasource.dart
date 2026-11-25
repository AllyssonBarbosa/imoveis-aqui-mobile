import 'package:dio/dio.dart';

import '../../domain/entities/periodo_contatos.dart';
import '../models/acervo_por_corretor_model.dart';
import '../models/contatos_por_corretor_model.dart';
import '../models/mudancas_recentes_model.dart';
import '../models/totais_por_situacao_model.dart';
import 'area_gestor_datasource.dart';

// Esqueleto da fase RED: ainda sem comportamento.
class AreaGestorRemoteDataSource implements AreaGestorDataSource {
  AreaGestorRemoteDataSource(this._dio);

  // ignore: unused_field
  final Dio _dio;

  @override
  Future<TotaisPorSituacaoModel> obterTotaisPorSituacao() =>
      throw UnimplementedError();

  @override
  Future<AcervoPorCorretorModel> obterAcervoPorCorretor() =>
      throw UnimplementedError();

  @override
  Future<ContatosPorCorretorModel> obterContatosPorCorretor([
    PeriodoContatos? periodo,
  ]) => throw UnimplementedError();

  @override
  Future<MudancasRecentesModel> obterMudancasRecentes() =>
      throw UnimplementedError();
}
