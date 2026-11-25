import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/acervo_por_corretor.dart';
import '../../domain/entities/contatos_por_corretor.dart';
import '../../domain/entities/mudancas_recentes.dart';
import '../../domain/entities/periodo_contatos.dart';
import '../../domain/entities/totais_por_situacao.dart';
import '../../domain/repositories/area_gestor_repository.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../datasources/area_gestor_datasource.dart';

/// Impl de [AreaGestorRepository] — injeta a interface trocável
/// [AreaGestorDataSource]. Só repassa o que o servidor devolveu, na ordem
/// recebida: não soma nem reordena (critério 5). Traduz as falhas em tipos de
/// domínio (D-22, D-23): 401 vira [SessaoExpiradaException], 403 vira
/// [SemPermissaoException] e o resto (rede, timeout, 5xx, 400, wire malformado)
/// vira `Failure` genérica, que a tela mostra com texto fixo (D-24). Nenhum
/// método lança: toda exceção vira `Failure`.
@LazySingleton(as: AreaGestorRepository)
class AreaGestorRepositoryImpl implements AreaGestorRepository {
  AreaGestorRepositoryImpl(this._fonte);

  final AreaGestorDataSource _fonte;

  @override
  Future<Result<TotaisPorSituacao>> obterTotaisPorSituacao() => _executar(
    () => _fonte.obterTotaisPorSituacao(),
    (modelo) => modelo.paraEntidade(),
  );

  @override
  Future<Result<AcervoPorCorretor>> obterAcervoPorCorretor() => _executar(
    () => _fonte.obterAcervoPorCorretor(),
    (modelo) => modelo.paraEntidade(),
  );

  @override
  Future<Result<ContatosPorCorretor>> obterContatosPorCorretor([
    PeriodoContatos? periodo,
  ]) => _executar(
    () => _fonte.obterContatosPorCorretor(periodo),
    (modelo) => modelo.paraEntidade(),
  );

  @override
  Future<Result<MudancasRecentes>> obterMudancasRecentes() => _executar(
    () => _fonte.obterMudancasRecentes(),
    (modelo) => modelo.paraEntidade(),
  );

  /// Cadeia única de tradução de erros. A ordem importa: a sessão expirada
  /// (direta ou dentro do `DioException.error`, posta pelo interceptor, ou
  /// status 401) vem antes do `DioException` por status (403), depois o
  /// [TypeError] (que é um `Error`, não uma `Exception`) e por fim qualquer
  /// outra `Exception` — a [FormatException] do Model (situação desconhecida)
  /// e da DataSource passam como estão. O mapeamento do Model também roda
  /// dentro do `try`, então um wire malformado vira falha em vez de escapar.
  Future<Result<T>> _executar<M, T>(
    Future<M> Function() acao,
    T Function(M) mapear,
  ) async {
    try {
      final modelo = await acao();
      return Result.success(mapear(modelo));
    } on SessaoExpiradaException {
      return Result.failure(const SessaoExpiradaException());
    } on DioException catch (erro) {
      final status = erro.response?.statusCode;
      if (erro.error is SessaoExpiradaException || status == 401) {
        return Result.failure(const SessaoExpiradaException());
      }
      if (status == 403) {
        return Result.failure(const SemPermissaoException());
      }
      return Result.failure(erro);
    } on TypeError catch (erro) {
      return Result.failure(
        FormatException('relatório do gestor malformado: $erro'),
      );
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
