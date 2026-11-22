import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/imovel_gestao.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/repositories/gestao_imovel_repository.dart';
import '../datasources/gestao_imovel_datasource.dart';

/// Impl de [GestaoImovelRepository] — injeta a interface trocável
/// [GestaoImovelDataSource]. Traduz as falhas da leitura em tipos de domínio
/// (D-10): o Cubit decide só pelo tipo e nenhum texto do servidor sobe.
@LazySingleton(as: GestaoImovelRepository)
class GestaoImovelRepositoryImpl implements GestaoImovelRepository {
  GestaoImovelRepositoryImpl(this._dataSource);

  final GestaoImovelDataSource _dataSource;

  @override
  Future<Result<ImovelGestao>> obterImovel(int id) =>
      _executar(() async => (await _dataSource.obterImovel(id)).paraEntidade());

  /// Cadeia única de tradução de erros. A ordem importa: a sessão expirada
  /// (direta ou dentro do `DioException.error`, posta pelo interceptor) vem
  /// antes do `DioException` por status; depois o [TypeError] (que é um
  /// `Error`, não uma `Exception`) e por fim qualquer outra `Exception` (a
  /// `FormatException` de data inválida, finalidade desconhecida ou corpo que
  /// não é objeto). Tudo o que não é sessão vira [FalhaDeConexaoException].
  Future<Result<T>> _executar<T>(Future<T> Function() acao) async {
    try {
      return Result.success(await acao());
    } on SessaoExpiradaException {
      return Result.failure(const SessaoExpiradaException());
    } on DioException catch (erro) {
      if (erro.error is SessaoExpiradaException) {
        return Result.failure(const SessaoExpiradaException());
      }
      return Result.failure(const FalhaDeConexaoException());
    } on TypeError {
      return Result.failure(const FalhaDeConexaoException());
    } on Exception {
      return Result.failure(const FalhaDeConexaoException());
    }
  }
}
