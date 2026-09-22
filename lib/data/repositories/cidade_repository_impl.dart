import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/cidade.dart';
import '../../domain/repositories/cidade_repository.dart';
import '../datasources/cidade_local_datasource.dart';
import '../datasources/cidade_prefs_datasource.dart';

/// Impl local de [CidadeRepository] (D-14) — compõe a fonte de dados de
/// cidades atendidas (asset) e a de persistência da escolha (prefs). Fase 2
/// troca [CidadeLocalDataSource] por uma impl remota via DI, sem tocar
/// `domain/`/`presentation/`.
@LazySingleton(as: CidadeRepository)
class CidadeRepositoryImpl implements CidadeRepository {
  CidadeRepositoryImpl(this._local, this._prefs);

  final CidadeLocalDataSource _local;
  final CidadePrefsDataSource _prefs;

  @override
  Future<Result<List<Cidade>>> obterCidadesAtendidas() async {
    try {
      final modelos = await _local.obterCidades();
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
