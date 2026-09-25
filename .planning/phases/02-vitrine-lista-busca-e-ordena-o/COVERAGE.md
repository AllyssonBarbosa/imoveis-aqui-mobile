# API Coverage — API pública Imóveis Aqui (Django/DRF, repo irmão `../imoveis-aqui/Web`)

> Full coverage by default. Opt-outs are explicit, reasoned decisions.

**Generated:** 2026-09-25 (plan-phase, Phase 02)

## Decision

This phase **does** integrate an HTTP API at runtime: the app starts calling the team's own public
Django API (`GET /api/publico/cidades/`, built in plan 02-02 and consumed via Dio in plan 02-04).
Although first-party, it is a real network integration, so the capability matrix below is recorded
instead of a "no external API integration" declaration. The surface enumerated is the public
contract frozen in Phase 1 (`01-CONTRATO-API.md`) plus the other public/authenticated surfaces of
the same API, each decided explicitly. Capabilities of `/imoveis` marked INTEGRATE are implemented
against the contract shape by the swappable mock DataSource this phase (API-04, D-14) — the real
endpoint itself is opted out until Phase 4.

| capability | decision | reason |
|---|---|---|
| cidades: listar cidades atendidas (GET /api/publico/cidades/, servidor) | INTEGRATE | plan 02-02 (API-02) |
| cidades: consumo no app via Dio com API_BASE_URL | INTEGRATE | plan 02-04 (VIT-06, D-17) |
| cidades: paginação cursor seguindo next até null | INTEGRATE | plans 02-02 / 02-04 |
| cidades: navegação reversa pelo previous | OPT-OUT | not needed — the small list is loaded in one forward walk; previous is never followed |
| imoveis: endpoint real GET /api/publico/imoveis/ | OPT-OUT | not needed yet — explicitly Phase 4 (API-03), blocked on E2's Imóvel tipologia; mock honors the contract meanwhile |
| imoveis: envelope cursor e campos do contrato (§3/§4) | INTEGRATE | mock DataSource + ImovelModel/ImoveisEnvelopeModel (plans 02-01 / 02-03) |
| imoveis: param cidade | INTEGRATE | mock, formato provisório Campinas-SP (§7.2) |
| imoveis: param busca | INTEGRATE | mock, título + bairro (D-05/D-06, plan 02-05) |
| imoveis: param ordenacao | INTEGRATE | mock, 5 valores com nulls last (D-11/D-12, plan 02-05) |
| imoveis: param cursor (scroll infinito) | INTEGRATE | mock (plan 02-03) |
| imoveis: filtros da vitrine (finalidade, natureza, faixas, características) | OPT-OUT | not needed yet — explicitly Phase 3 (FIL-01..FIL-06), all §5 filter params |
| imoveis: contagem de resultados (Ver N imóveis) | OPT-OUT | not needed yet — v2 (API-05) |
| empresas: perfil público GET /api/publico/empresas/{id}/ | OPT-OUT | explicitly out of scope — not part of APP01-APP03 vitrine; detail/contact are v2 (DET-01/CON-01) |
| API autenticada por token (/api/ painel, corretor, gestor) | OPT-OUT | explicitly out of scope — the vitrine has no login (LOG-01 is v2) |

## Specless-probe edge coverage — no silent drops

The deterministic edge probe returned 9 items (4 `unclassified`, 5 classified), all `unresolved`
(it cannot read Portuguese requirement prose). Each was resolved by authoring a defensible,
explicit acceptance criterion from CONTEXT.md / RESEARCH.md into the owning plan's
`must_haves.truths`; none became a backstop, none was dropped.

- VIT-01 (unclassified) — truth authored in 02-01 (only the chosen city's imóveis, matched by natural key in data/).
- VIT-02 (unclassified) — truths authored in 02-01 (slot order, D-02 stacked prices, D-03 BRL, D-04 same-height placeholder).
- VIT-03 (unclassified) — truths authored in 02-05 (D-07/D-08 debounce rules, D-09 distinct no-result state).
- VIT-04 (unclassified) — truths authored in 02-05 (five options, D-12 nulls last, D-13 reset to top).
- VIT-05 idempotency — truth authored in 02-03 (double carregarMais -> one request; same cursor never requested twice).
- VIT-05 concurrency — truth authored in 02-03 (stale load-more discarded by the version token; no emit after close).
- VIT-06 concurrency — truth authored in 02-04 (a page failure mid-walk -> erroCarregarCidades, never a partial list; retry re-walks).
- API-02 concurrency — truth authored in 02-02 (read-only endpoint; stable cursor ordering -> each city exactly once even if one is added between requests; seed idempotent).
- API-04 concurrency — truth authored in 02-03 (mock DataSource stateless: concurrent consultas independent; following the same next is idempotent).

No-silent-drop equality: 9 probe items == 9 authored truths + 0 flagged assumptions.

## Prohibition recall (PROHIB_ABSENT) — authored descriptor-less

Kept (values/safety), authored in `must_haves.prohibitions` without `check_*` descriptors:

- 02-01: no filter/search/sort/pagination outside the swappable DataSource; no network/business logic in widgets; no generic try/catch in presentation.
- 02-02: served-city rule and field allowlist decided server-side only; seed never outside DEBUG / never touches real companies; no sibling-repo commit without the user's authorization.
- 02-03: load-more failure never discards visible cards; presentation never parses or builds the next-page reference.
- 02-04: no cleartext HTTP in release builds; never follow a `next` off the configured API origin; no second (fallback) city source.
- 02-05: Cubit/UI never filter or sort locally; the "erro" failure trigger exists only in the mock DataSource.

Dropped as routine engineering (owned by tests/code review): duplicate-card prevention details,
timer cleanup, widget key hygiene. Canon-referral breadcrumbs (not minted): injection via the
`busca` param and access control of the public endpoint are covered by OWASP ASVS L1 controls in
each plan's `<threat_model>`.
