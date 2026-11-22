import '../../core/result.dart';
import '../entities/imovel_gestao.dart';
import '../entities/mudanca_situacao.dart';
import '../entities/situacao_imovel.dart';

/// Leitura do imóvel para a gestão da situação (SIT-07). Os dados vêm do
/// servidor (D-01): o repositório nunca monta o imóvel por conta própria.
abstract class GestaoImovelRepository {
  /// Lê o imóvel [id] da API. Falhas tipadas: `SessaoExpiradaException` (401),
  /// `ImovelNaoEncontradoException` (404, imóvel inexistente ou de outra
  /// empresa) e `FalhaDeConexaoException` (rede, 5xx, JSON malformado).
  Future<Result<ImovelGestao>> obterImovel(int id);

  /// Lê o histórico de mudanças de situação do imóvel [id], na ordem em que o
  /// servidor mandou (mais recente primeiro; o app não reordena, não filtra e
  /// não pagina — D-11). Mesmas falhas tipadas de [obterImovel]:
  /// `SessaoExpiradaException` (401), `ImovelNaoEncontradoException` (404) e
  /// `FalhaDeConexaoException` (rede, 5xx, corpo ou item malformado).
  Future<Result<List<MudancaSituacao>>> obterHistorico(int id);

  /// Pede ao servidor a mudança da situação do imóvel [id] para [nova]
  /// (`POST /api/imoveis/{id}/situacao/`). O app pede e o servidor decide: a
  /// data e o autor da mudança são os do servidor, então nenhum dos dois é
  /// enviado (D-05). [observacao] é opcional (D-06): vazia ou só com espaços,
  /// não vai no corpo. O 200 não é lido como estado (D-10): quem chama relê o
  /// imóvel depois. Nenhuma nova tentativa automática é feita (um POST com
  /// tempo esgotado pode ter gravado). Falhas tipadas:
  /// `MudancaSituacaoRecusadaException` (400/403, com a mensagem do servidor),
  /// `ImovelNaoEncontradoException` (404), `SessaoExpiradaException` (401) e
  /// `FalhaDeConexaoException` (rede, tempo esgotado, 5xx, recusa sem texto).
  Future<Result<void>> mudarSituacao(
    int id,
    SituacaoImovel nova, {
    String observacao = '',
  });
}
