import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/repositories/cidade_repository.dart';
import '../datasources/cidade_prefs_datasource.dart';
import '../datasources/cidade_remote_datasource.dart';

/// Impl de [CidadeRepository] apoiada em [CidadeRemoteDataSource] (VIT-06,
/// D-16) — a lista de cidades atendidas vem de `GET /api/publico/cidades/`,
/// fonte única da verdade (o antigo asset local foi removido). Compõe a
/// DataSource remota com a de persistência da escolha (prefs); a interface
/// [CidadeRepository] não muda (F1/D-14).
@LazySingleton(as: CidadeRepository)
class CidadeRepositoryImpl implements CidadeRepository {
  CidadeRepositoryImpl(this._remoto, this._prefs);

  final CidadeRemoteDataSource _remoto;
  final CidadePrefsDataSource _prefs;

  @override
  Future<Result<List<Cidade>>> obterCidadesAtendidas() async {
    try {
      final modelos = await _remoto.obterCidades();
      final cidades = modelos.map((modelo) => modelo.paraEntidade()).toList();
      return Result.success(cidades);
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }

  @override
  Future<void> salvarCidade(Cidade cidade) {
    return _prefs.salvar(nome: cidade.nome, uf: cidade.uf);
  }

  @override
  Future<Cidade?> obterCidadeSalva() async {
    final salva = await _prefs.obterSalva();
    if (salva == null) return null;
    return Cidade(nome: salva.$1, uf: salva.$2);
  }
}
