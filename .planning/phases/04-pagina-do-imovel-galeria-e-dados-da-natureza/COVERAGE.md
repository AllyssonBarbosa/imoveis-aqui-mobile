# Phase 04 — API Coverage Decision (ai-integration checkpoint)

**Generated:** 2026-10-12
**Checkpoint:** Full API Coverage by Default — Opt Out, Never Opt In.

## Decision: No external API integration this phase

**No external API integration: consumes the project's own Django public API contract via a mock
datasource; no third-party API.**

### Reasoning

- The detail page reads `GET /api/publico/imoveis/{id}/`, an endpoint of this project's own Django
  API (sibling repo `../imoveis-aqui/Web`). Phase 4 only freezes its contract (§11 of
  `01-CONTRATO-API.md` + `contrato/imovel_detalhe.example.json`, API-06) and builds the app over
  `ImovelDetalheMockDataSource`, an in-memory simulated server that serves wire maps in that shape.
- No HTTP request is issued by the detail feature this phase. `dio` appears only (a) in the
  repository's error translation (`DioException` 404 -> `ImovelNaoEncontradoException`) and (b) in a
  unit test that runs a real `Dio` over a fake `HttpClientAdapter`; neither reaches the network.
- Photos are loaded by `cached_network_image` from URLs the (mock) API returns — the same media
  rendering already used by the vitrine since Phase 2; it is not a third-party API integration.
- The real endpoint and the mock -> remote DI swap are API-07, scheduled for Phase 5; the
  INTEGRATE-by-default coverage matrix applies there if anything external is introduced.

Because no external API/SDK/service is integrated at runtime this phase, this reasoned
no-integration declaration is recorded in lieu of a capability coverage matrix.
