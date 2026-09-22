---
phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api
plan: 02
subsystem: api
tags: [contrato, django, drf, cursor-pagination, documentation, fixtures]

# Dependency graph
requires: []
provides:
  - "01-CONTRATO-API.md — frozen written contract for GET /cidades and GET /imoveis (field tables, enums, cursor envelope, allowlist rule)"
  - "contrato/cidades.example.json and contrato/imoveis.example.json — mock fixtures for Phase 2/3 DataSources"
affects: [01-01 (walking skeleton — assets/cidades.json must match the cidades.example.json shape), phase-2 (vitrine), phase-3 (filtros), phase-4 (real /imoveis endpoint)]

# Actuals (#2632)
actuals:
  tokens: 4500
  tasks: 2
  commits: 2

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "DRF CursorPagination envelope {next, previous, results} for all paginated public endpoints"
    - "Dedicated public serializer with explicit field allowlist — never reuse an authenticated serializer for a public/AllowAny endpoint"
    - "Queryset-level trust boundary (publicado=True, empresas_atuantes__ativa=True) instead of per-request trust"

key-files:
  created:
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/cidades.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imoveis.example.json
  modified: []

key-decisions:
  - "Audit corrected PROJECT.md's stale claim that the Imovel model doesn't exist — it does; only tipologia (natureza/quartos/suites/vagas/area) and the public endpoints are missing."
  - "GET /cidades served-set rule frozen as Cidade.objects.filter(empresas_atuantes__ativa=True).distinct(), not Cidade.objects.all() — grounded in Empresa.cidades_atuacao M2M read from empresas/models.py."
  - "Public /imoveis serializer must be a dedicated new serializer, never the authenticated ImovelSerializer (which exposes corretor_responsavel/proprietario)."
  - "Four genuinely-open items (quartos/suites/vagas exact-vs-range, cidade param format, VENDA_E_ALUGUEL card price, ordenacao enum values) presented as options, not frozen — explicitly deferred to web-team (E2) sign-off."

requirements-completed: [API-01]

coverage:
  - id: D1
    description: "Frozen written contract (01-CONTRATO-API.md) for GET /cidades and GET /imoveis — field tables, enums, cursor pagination envelope, PT snake_case query params, public-serializer allowlist rule — grounded in the real sibling Django models"
    requirement: API-01
    verification:
      - kind: other
        ref: "test -f 01-CONTRATO-API.md && grep -Fq required section tokens (GET /cidades, GET /imoveis, CursorPagination, PENDENTE E2, publicado, allowlist)"
        status: pass
    human_judgment: true
    rationale: "The automated grep gate only proves required tokens/sections are present, not that the field shapes are correct or that they will satisfy the web team. Final 'congelado' status requires E2 sign-off (§8 of the doc) — a human/cross-team review step this plan explicitly cannot automate."
  - id: D2
    description: "Example JSON fixtures (cidades.example.json, imoveis.example.json) matching the frozen contract shape, doubling as Phase 2/3 mock DataSource fixtures"
    requirement: API-01
    verification:
      - kind: other
        ref: "python3 -m json.tool cidades.example.json && python3 -m json.tool imoveis.example.json (valid JSON) + grep -Fq '\"results\"' on both"
        status: pass
    human_judgment: false

# Metrics
duration: 6min
completed: 2026-09-22
status: complete
---

# Phase 1 Plan 2: Contrato da API (GET /cidades, GET /imoveis) Summary

**Auditou os models reais do repo Django irmão e congelou por escrito o contrato de `GET /cidades` e `GET /imoveis` — cursor pagination, campos, allowlist do serializer público, e os itens genuinamente pendentes de sign-off da frente web.**

## Performance

- **Duration:** ~6 min
- **Started:** 2026-09-22T14:56:00Z (approx, orchestrator init)
- **Completed:** 2026-09-22T15:02:39Z
- **Tasks:** 2
- **Files modified:** 3 (all created)

## Accomplishments
- Auditou `Cidade`, `Imovel`, `Endereco`, `Empresa` e os serializers/views existentes no repo `../imoveis-aqui/Web`, corrigindo a nota desatualizada do PROJECT.md ("model de Imóvel não existe" → na verdade existe, falta tipologia + endpoints públicos).
- Congelou `01-CONTRATO-API.md`: field tables reais para `GET /cidades` (`id`, `nome`, `uf`) e `GET /imoveis` (campos reais + tipologia marcada PENDENTE E2), envelope `CursorPagination` `{next, previous, results}`, regra do conjunto servido (`empresas_atuantes__ativa=True`), e a disciplina de allowlist do serializer público (nunca reusar `ImovelSerializer` autenticado; `publicado=True` obrigatório no queryset).
- Criou `contrato/cidades.example.json` e `contrato/imoveis.example.json`, fixtures válidas que espelham exatamente a forma congelada — servirão de mock DataSource para as Fases 2/3 (API-04).
- Sinalizou explicitamente os quatro itens genuinamente em aberto (semântica de quartos/suítes/vagas, formato do param `cidade`, preço exibido em `VENDA_E_ALUGUEL`, valores de `ordenacao`) como pendentes de sign-off do E2, sem chutar uma resposta única.

## Task Commits

Each task was committed atomically:

1. **Task 1: Audit sibling models and write the frozen API contract doc** - `f8474ff` (docs)
2. **Task 2: Write the example JSON fixtures** - `41df887` (docs)

**Plan metadata:** (this commit)

_Note: this was a documentation-only plan — no Flutter/Dart code, no TDD cycle applicable._

## Files Created/Modified
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` - frozen contract: field tables, cursor pagination, query params, public-serializer allowlist, pendente-sign-off section
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/cidades.example.json` - example `GET /cidades` response (cursor envelope, id/nome/uf rows)
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imoveis.example.json` - example `GET /imoveis` response (cursor envelope, real + PENDENTE-E2 fields, 3 representative rows covering VENDA/ALUGUEL/VENDA_E_ALUGUEL and CASA/APARTAMENTO/TERRENO)

## Decisions Made
- Followed the plan's grounding discipline strictly: every field in the contract traces back to a model/serializer/view actually read in the sibling repo this session — nothing invented without a citation.
- Excluded `preco_condominio`/`preco_iptu` from the `GET /imoveis` v1 field table (they exist on the model but are out of VIT-02's card scope) — documented as available-but-unused rather than silently omitted.
- Chose Campinas/Valinhos/Vinhedo/Indaiatuba as the example served-city set (consistent with the RESEARCH.md fixture examples) to keep `cidades.example.json` realistic and reusable as-is for Plan 01-01's `assets/cidades.json`.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- `01-CONTRATO-API.md` and both example fixtures are ready to orient Plan 01-01's `assets/cidades.json` (must mirror `cidades.example.json`'s shape per D-13), and Phase 2/3's mock DataSources.
- **Manual coordination step still outstanding (not blocking this plan, but blocking "congelado" status):** copy `01-CONTRATO-API.md` into `../imoveis-aqui/Web` and obtain explicit E2 sign-off on §7's four open items before Phase 4 builds the real `/imoveis` endpoint against this contract as final.
- Ready for 01-01 (walking skeleton) and 01-03/01-04 if applicable — this plan's output has no code dependency on the Flutter SDK and required none.

## Self-Check: PASSED

- FOUND: .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md
- FOUND: .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/cidades.example.json
- FOUND: .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imoveis.example.json
- FOUND commit: f8474ff (Task 1)
- FOUND commit: 41df887 (Task 2)

---
*Phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api*
*Completed: 2026-09-22*
