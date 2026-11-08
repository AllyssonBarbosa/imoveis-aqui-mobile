import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/perfil_corretor.dart';
import '../../domain/entities/perfil_empresa.dart';
import '../../domain/repositories/perfil_repository.dart';
import '../datasources/perfil_datasource.dart';

/// Impl de [PerfilRepository] — injeta a interface trocável [PerfilDataSource],
/// nunca a classe mock diretamente (mesma disciplina de
/// `ImovelDetalheRepositoryImpl`).
///
/// Traduz toda falha da DataSource em `Result.failure` tipado (PERF-05, D-04):
/// 404 vira [PerfilNaoEncontradoException] e JSON malformado ([TypeError] do
/// `fromJson`) vira [FormatException], então o Cubit decide só pelo tipo. A
/// DataSource remota apenas deixa a `DioException` subir — nada acima do
/// repositório muda na troca do mock pela API real.
@LazySingleton(as: PerfilRepository)
class PerfilRepositoryImpl implements PerfilRepository {
  PerfilRepositoryImpl(this._dataSource);

  final PerfilDataSource _dataSource;

  @override
  Future<Result<PerfilCorretor>> buscarCorretor(int id) => _executar(
    () async => (await _dataSource.buscarCorretor(id)).paraEntidade(),
  );

  @override
  Future<Result<PerfilEmpresa>> buscarEmpresa(int id) => _executar(
    () async => (await _dataSource.buscarEmpresa(id)).paraEntidade(),
  );

  /// Cadeia única de tradução de erros dos perfis (corretor hoje, empresa
  /// depois). A ordem importa: a exceção de domínio vem antes, depois o
  /// `DioException` (404 vs. demais), o [TypeError] (que é um `Error`, não uma
  /// `Exception`) e por fim qualquer outra `Exception`.
  Future<Result<T>> _executar<T>(Future<T> Function() acao) async {
    try {
      return Result.success(await acao());
    } on PerfilNaoEncontradoException catch (erro) {
      return Result.failure(erro);
    } on DioException catch (erro) {
      // 404 = inexistente, não-corretor ou desativado: repetir não resolve.
      if (erro.response?.statusCode == 404) {
        return Result.failure(const PerfilNaoEncontradoException());
      }
      return Result.failure(erro);
    } on TypeError catch (erro) {
      // Campo obrigatório ausente no JSON: o `fromJson` gerado faz `as` e
      // lança TypeError, que é um Error (não Exception).
      return Result.failure(FormatException('perfil malformado: $erro'));
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
