import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../../domain/entities/consulta_contatos.dart';
import '../../domain/entities/contato_recebido.dart';
import '../../domain/entities/imovel_com_contato.dart';
import '../../domain/entities/pagina_contatos.dart';
import '../../domain/entities/retorno_contato.dart';
import '../../domain/repositories/caixa_contatos_repository.dart';
import '../../domain/repositories/falhas_autenticacao.dart';
import '../../domain/repositories/falhas_caixa_contatos.dart';
import '../datasources/caixa_contatos_datasource.dart';

/// Impl de [CaixaContatosRepository] — injeta a interface trocável
/// [CaixaContatosDataSource]. Só repassa o que o servidor devolveu, na ordem
/// recebida: não filtra nem reordena (D-08, D-13). Traduz as falhas da caixa
/// em tipos de domínio (D-17, D-23): 401 vira [SessaoExpiradaException], 403
/// vira [SemPermissaoException] e, só no PATCH do retorno, 404 vira
/// [ContatoNaoEncontradoException]. Nenhum método lança: toda exceção vira
/// `Failure`, então o Cubit decide só pelo tipo.
@LazySingleton(as: CaixaContatosRepository)
class CaixaContatosRepositoryImpl implements CaixaContatosRepository {
  CaixaContatosRepositoryImpl(this._fonte);

  final CaixaContatosDataSource _fonte;

  @override
  Future<Result<PaginaContatos>> buscar(ConsultaContatos consulta) => _executar(
    () => _fonte.buscar(consulta),
    (envelope) => envelope.paraPagina(),
  );

  @override
  Future<Result<PaginaContatos>> seguir(String proximaPagina) => _executar(
    () => _fonte.seguir(proximaPagina),
    (envelope) => envelope.paraPagina(),
  );

  @override
  Future<Result<int>> contarSemRetorno() =>
      _executar(() => _fonte.contarSemRetorno(), (resumo) => resumo.semRetorno);

  @override
  Future<Result<List<ImovelComContato>>> listarImoveis() => _executar(
    () => _fonte.listarImoveis(),
    (modelos) => modelos.map((modelo) => modelo.paraEntidade()).toList(),
  );

  @override
  Future<Result<ContatoRecebido>> anotarRetorno(
    int id,
    RetornoContato retorno,
  ) => _executar(
    () => _fonte.anotarRetorno(id, retorno),
    (modelo) => modelo.paraEntidade(),
    notFoundEhContato: true,
  );

  /// Cadeia única de tradução de erros. A ordem importa: a sessão expirada
  /// (direta ou dentro do `DioException.error`, posta pelo interceptor) vem
  /// antes do `DioException` por status (403; e 404 só quando
  /// [notFoundEhContato], isto é, no PATCH), depois o [TypeError] (que é um
  /// `Error`, não uma `Exception`) e por fim qualquer outra `Exception` — a
  /// [FormatException] do Model (canal/retorno desconhecido) e da guarda de
  /// origem passam como estão. O mapeamento do Model também roda dentro do
  /// `try`, então um wire malformado vira falha em vez de escapar.
  Future<Result<T>> _executar<M, T>(
    Future<M> Function() acao,
    T Function(M) mapear, {
    bool notFoundEhContato = false,
  }) async {
    try {
      final modelo = await acao();
      return Result.success(mapear(modelo));
    } on SessaoExpiradaException {
      return Result.failure(const SessaoExpiradaException());
    } on DioException catch (erro) {
      if (erro.error is SessaoExpiradaException) {
        return Result.failure(const SessaoExpiradaException());
      }
      final status = erro.response?.statusCode;
      if (status == 403) {
        return Result.failure(const SemPermissaoException());
      }
      if (status == 404 && notFoundEhContato) {
        return Result.failure(const ContatoNaoEncontradoException());
      }
      return Result.failure(erro);
    } on TypeError catch (erro) {
      return Result.failure(
        FormatException('caixa de contatos malformada: $erro'),
      );
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
}
