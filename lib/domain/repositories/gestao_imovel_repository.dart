import '../../core/result.dart';
import '../entities/imovel_gestao.dart';
import '../entities/mudanca_situacao.dart';

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
}
