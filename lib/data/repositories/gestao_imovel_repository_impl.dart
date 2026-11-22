import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/imovel_gestao.dart';
import '../../domain/entities/mudanca_situacao.dart';
import '../../domain/entities/situacao_imovel.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/repositories/gestao_imovel_repository.dart';
import '../../domain/repositories/imovel_detalhe_repository.dart';
import '../datasources/gestao_imovel_datasource.dart';
import '../network/mensagem_de_recusa.dart';

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

  @override
  Future<Result<List<MudancaSituacao>>> obterHistorico(int id) => _executar(
    // Imutável: o Cubit não consegue reordenar nem editar o que veio do
    // servidor (D-11). A tradução de cada item roda dentro da ação, então uma
    // data inválida vira falha tipada.
    () async => List.unmodifiable([
      for (final item in await _dataSource.obterHistorico(id))
        item.paraEntidade(),
    ]),
  );

  @override
  Future<Result<void>> mudarSituacao(
    int id,
    SituacaoImovel nova, {
    String observacao = '',
  }) => _executar<void>(
    // Sem nova tentativa automática: um POST com tempo esgotado pode ter
    // gravado, e o servidor é o árbitro do reenvio do usuário.
    () => _dataSource.mudarSituacao(id, nova, observacao),
  );

  /// Cadeia única de tradução de erros. A ordem importa: a sessão expirada
  /// (direta ou dentro do `DioException.error`, posta pelo interceptor) vem
  /// antes do `DioException` por status; depois o [TypeError] (que é um
  /// `Error`, não uma `Exception`) e por fim qualquer outra `Exception` (a
  /// `FormatException` de data inválida, finalidade desconhecida ou corpo que
  /// não é objeto). 404 vira [ImovelNaoEncontradoException] (reaproveitada do
  /// detalhe público); o resto, que não é sessão, vira
  /// [FalhaDeConexaoException]. 400 e 403 (só a escrita os espera) viram
  /// [MudancaSituacaoRecusadaException] com a mensagem do servidor, ou
  /// [FalhaDeConexaoException] se o corpo não tem texto.
  Future<Result<T>> _executar<T>(Future<T> Function() acao) async {
    try {
      return Result.success(await acao());
    } on SessaoExpiradaException {
      return Result.failure(const SessaoExpiradaException());
    } on DioException catch (erro) {
      if (erro.error is SessaoExpiradaException) {
        return Result.failure(const SessaoExpiradaException());
      }
      final status = erro.response?.statusCode;
      if (status == 400 || status == 403) {
        // Recusa do servidor na escrita: a mensagem dele (já em português) sobe
        // achatada; sem texto aproveitável, é falha de conexão (D-10).
        final texto = mensagemDeRecusa(erro.response?.data);
        return Result.failure(
          texto == null
              ? const FalhaDeConexaoException()
              : MudancaSituacaoRecusadaException(texto),
        );
      }
      if (status == 404) {
        // O `detail` do Django vem em inglês e nunca sobe (T-09-05).
        return Result.failure(const ImovelNaoEncontradoException());
      }
      return Result.failure(const FalhaDeConexaoException());
    } on TypeError {
      return Result.failure(const FalhaDeConexaoException());
    } on Exception {
      return Result.failure(const FalhaDeConexaoException());
    }
  }
}
