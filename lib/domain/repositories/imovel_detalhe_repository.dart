import '../../core/result.dart';
import '../entities/detalhe_imovel.dart';

/// Contrato de falha de `buscarDetalhe` para um imóvel inexistente ou não
/// publicado (D-01) — o servidor responde 404 e a camada de dados o traduz
/// para esta exceção.
class ImovelNaoEncontradoException implements Exception {
  const ImovelNaoEncontradoException();

  @override
  String toString() => 'Imóvel não encontrado ou não publicado.';
}

/// Fronteira de domínio do detalhe do imóvel (DET-01).
abstract class ImovelDetalheRepository {
  Future<Result<DetalheImovel>> buscarDetalhe(int id);
}
