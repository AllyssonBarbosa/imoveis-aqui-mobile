import '../../core/result.dart';
import '../entities/consulta_contatos.dart';
import '../entities/contato_recebido.dart';
import '../entities/imovel_com_contato.dart';
import '../entities/pagina_contatos.dart';
import '../entities/retorno_contato.dart';

/// Caixa de contatos do corretor (CXA-01, CXA-02, CXA-03, CXA-05). O filtro e
/// a ordem são do servidor: o repositório nunca filtra nem reordena
/// (D-08, D-13).
///
/// Falhas tipadas comuns a todos os métodos: `SessaoExpiradaException` (401),
/// `SemPermissaoException` (403) e as demais como `Failure` genérica.
abstract class CaixaContatosRepository {
  /// Primeira página da caixa para [consulta].
  Future<Result<PaginaContatos>> buscar(ConsultaContatos consulta);

  /// Página seguinte, a partir do cursor opaco [proximaPagina] da página
  /// anterior.
  Future<Result<PaginaContatos>> seguir(String proximaPagina);

  /// Quantos contatos estão sem retorno anotado, sem filtros (D-05).
  Future<Result<int>> contarSemRetorno();

  /// Imóveis que já receberam contato — as opções do filtro por imóvel.
  Future<Result<List<ImovelComContato>>> listarImoveis();

  /// Anota [retorno] no contato [id] e devolve o contato atualizado. Além das
  /// falhas comuns, `ContatoNaoEncontradoException` só no 404 do PATCH (o
  /// contato saiu da caixa ou é de outro corretor/empresa).
  Future<Result<ContatoRecebido>> anotarRetorno(int id, RetornoContato retorno);
}
