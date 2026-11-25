import '../../core/result.dart';
import '../../domain/entities/acervo_por_corretor.dart';
import '../../domain/entities/contatos_por_corretor.dart';
import '../../domain/entities/mudancas_recentes.dart';
import '../../domain/entities/periodo_contatos.dart';
import '../../domain/entities/totais_por_situacao.dart';
import '../../domain/repositories/area_gestor_repository.dart';
import '../datasources/area_gestor_datasource.dart';

// Esqueleto da fase RED: ainda sem comportamento.
class AreaGestorRepositoryImpl implements AreaGestorRepository {
  AreaGestorRepositoryImpl(this._fonte);

  // ignore: unused_field
  final AreaGestorDataSource _fonte;

  @override
  Future<Result<TotaisPorSituacao>> obterTotaisPorSituacao() =>
      throw UnimplementedError();

  @override
  Future<Result<AcervoPorCorretor>> obterAcervoPorCorretor() =>
      throw UnimplementedError();

  @override
  Future<Result<ContatosPorCorretor>> obterContatosPorCorretor([
    PeriodoContatos? periodo,
  ]) => throw UnimplementedError();

  @override
  Future<Result<MudancasRecentes>> obterMudancasRecentes() =>
      throw UnimplementedError();
}
