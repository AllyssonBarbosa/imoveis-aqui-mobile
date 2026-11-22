import '../../core/result.dart';
import '../entities/imovel_gestao.dart';

/// Leitura do imóvel para a gestão da situação (SIT-07). Os dados vêm do
/// servidor (D-01): o repositório nunca monta o imóvel por conta própria.
abstract class GestaoImovelRepository {
  /// Lê o imóvel [id] da API. Falhas tipadas: `SessaoExpiradaException` (401),
  /// `ImovelNaoEncontradoException` (404, imóvel inexistente ou de outra
  /// empresa) e `FalhaDeConexaoException` (rede, 5xx, JSON malformado).
  Future<Result<ImovelGestao>> obterImovel(int id);
}
