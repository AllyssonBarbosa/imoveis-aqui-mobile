import '../../domain/entities/cidade.dart';

/// Caminhos dos endpoints públicos de opções (contrato §10 item 8, adendo da
/// Fase 3) — reaproveitados tal e qual pela Fase 4 quando a DataSource
/// remota substituir o mock (API-04).
const String caminhoBairrosPublico = '/api/publico/bairros/';
const String caminhoCaracteristicasPublico = '/api/publico/caracteristicas/';

/// Fronteira trocável mock->real das opções de bairro/característica (D-20).
/// A Fase 4 troca [OpcoesFiltroMockDataSource] por uma implementação `dio`
/// sem tocar `domain/`/`presentation/` — só a anotação de DI muda (mesma
/// disciplina de `ImovelDataSource`).
abstract class OpcoesFiltroDataSource {
  /// Bairros com ao menos um imóvel publicado em [cidade] — array não-
  /// paginado de strings (contrato §10 item 8).
  Future<List<String>> bairros(Cidade cidade);

  /// Todas as características do catálogo — array não-paginado de strings.
  Future<List<String>> caracteristicas();
}
