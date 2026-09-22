import '../../core/result.dart';
import '../entities/cidade.dart';

/// Contrato de acesso a cidades. A impl concreta é local nesta fase (D-14,
/// lê `assets/cidades.json`); a Fase 2 troca por uma impl remota via DI sem
/// tocar `domain/` ou `presentation/`.
abstract class CidadeRepository {
  Future<Result<List<Cidade>>> obterCidadesAtendidas();

  Future<void> salvarCidade(Cidade cidade);

  Future<Cidade?> obterCidadeSalva();
}
