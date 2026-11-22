import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/consulta_acervo.dart';
import '../../domain/entities/pagina_acervo.dart';
import '../../domain/repositories/acervo_repository.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../datasources/acervo_datasource.dart';
import '../models/acervo_envelope_model.dart';

/// Impl de [AcervoRepository] — injeta a interface trocável
/// [AcervoDataSource]. Só repassa a página na ordem recebida: não filtra nem
/// reordena (D-10, D-11). Traduz as falhas do acervo em tipos de domínio: 401
/// vira [SessaoExpiradaException] e 403 vira [SemPermissaoException], então o
/// Cubit decide só pelo tipo.
@LazySingleton(as: AcervoRepository)
class AcervoRepositoryImpl implements AcervoRepository {
  AcervoRepositoryImpl(this._dataSource);

  final AcervoDataSource _dataSource;

  @override
  Future<Result<PaginaAcervo>> buscar(ConsultaAcervo consulta) =>
      _executar(() => _dataSource.buscar(consulta));

  @override
  Future<Result<PaginaAcervo>> seguir(String proximaPagina) =>
      _executar(() => _dataSource.seguir(proximaPagina));

  /// Cadeia única de tradução de erros. A ordem importa: a sessão expirada
  /// (direta ou dentro do `DioException.error`, posta pelo interceptor) vem
  /// antes do `DioException` por status, depois o [TypeError] (que é um
  /// `Error`, não uma `Exception`) e por fim qualquer outra `Exception` — a
  /// [FormatException] do Model (finalidade desconhecida) e da guarda de
  /// origem passam como estão.
  Future<Result<PaginaAcervo>> _executar(
    Future<AcervoEnvelopeModel> Function() acao,
  ) async {
    try {
      final envelope = await acao();
      return Result.success(envelope.paraPagina());
    } on SessaoExpiradaException {
      return Result.failure(const SessaoExpiradaException());
    } on DioException catch (erro) {
      if (erro.error is SessaoExpiradaException) {
        return Result.failure(const SessaoExpiradaException());
      }
      if (erro.response?.statusCode == 403) {
        return Result.failure(const SemPermissaoException());
      }
      return Result.failure(erro);
    } on TypeError catch (erro) {
      return Result.failure(FormatException('acervo malformado: $erro'));
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
