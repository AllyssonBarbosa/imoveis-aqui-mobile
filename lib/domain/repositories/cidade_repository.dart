import '../../core/result.dart';
import '../entities/cidade.dart';

/// Contrato de acesso a cidades. A impl concreta lê `GET
/// /api/publico/cidades/` via Dio (VIT-06, D-16) — trocável por DI (F1/D-14)
/// sem tocar `domain/` ou `presentation/`.
abstract class CidadeRepository {
  Future<Result<List<Cidade>>> obterCidadesAtendidas();

  Future<void> salvarCidade(Cidade cidade);

  Future<Cidade?> obterCidadeSalva();
}
