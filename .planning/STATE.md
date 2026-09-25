---
gsd_state_version: "1.0"
current_phase: 02
current_phase_name: Vitrine — Lista, Busca e Ordenação
status: verifying
stopped_at: Completed 02-05-PLAN.md
last_updated: "2026-09-25T23:28:24.432Z"
last_activity: 2026-09-25
last_activity_desc: Phase 02 execution started
state_head: 00259e2e2db9e746caa3343c9690bb3c50ec149c
progress:
  total_phases: 4
  completed_phases: 0
  total_plans: 9
  completed_plans: 9
  percent: 0
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-09-21)

**Core value:** A vitrine do app abre na cidade do usuário e mostra imóveis reais vindos da API, com a busca e o filtro resolvidos no servidor — o mesmo dado e a mesma regra do site, nunca recalculados dentro do aparelho.
**Current focus:** Phase 02 — Vitrine — Lista, Busca e Ordenação

## Current Position

Phase: 02 (Vitrine — Lista, Busca e Ordenação) — EXECUTING
Plan: 5 of 5
Status: Phase complete — ready for verification
Last activity: 2026-09-25 — Phase 02 execution started

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

**Velocity:**

- Total plans completed: 0
- Average duration: - min
- Total execution time: 0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| - | - | - | - |

**Recent Trend:**

- Last 5 plans: -
- Trend: -

*Updated after each plan completion*
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 01 P02 | 6 min | 2 tasks | 3 files |
| Phase 02 P01 | 25min | 2 tasks | 36 files |
| Phase 02 P02 | 11min | 2 tasks | 8 files |
| Phase 02 P03 | 22 min | 3 tasks | 9 files |
| Phase 02 P04 | 27 min | 2 tasks | 22 files |
| Phase 02 P05 | 17min | 3 tasks | 12 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: API-01 (contract freeze) bundled into Phase 1 alongside APP01 rather than as a standalone phase — research called it parallelizable with zero-API-dependency APP01; keeps it from being a thin, non-user-observable single-requirement phase.
- [Roadmap]: API-02 (`GET /cidades` real endpoint) folded into Phase 2 rather than a standalone phase — Phase 2 is where the app actually consumes it (VIT-06), so build+consume ship as one coherent, user-observable capability.
- [Roadmap]: API-03 (`GET /imoveis` real endpoint) kept as its own final Phase 4 per explicit project constraint — genuinely gated on the teammate's (E2) `Imóvel` model landing in the sibling API repo.
- [Phase 01]: GET /cidades e GET /imoveis frozen contract written (01-CONTRATO-API.md), grounded in real sibling Django models; corrected stale PROJECT.md note that the Imovel model didn't exist. — Public serializer must use an explicit allowlist and never the authenticated ImovelSerializer; tipologia fields marked PENDENTE E2; four semantically-open items (quartos/suites/vagas range-vs-exact, cidade param format, VENDA_E_ALUGUEL card price, ordenacao values) flagged for web-team sign-off instead of guessed.
- [Phase 02]: ImovelMockDataSource filtra/ordena sobre mapas de wire (snake_case) e só então parseia via ImoveisEnvelopeModel.fromJson — Garante que o parsing exercitado nos testes é idêntico ao usado contra o endpoint real na Fase 4
- [Phase 02]: [Phase 02-02]: GET /api/publico/cidades/ real criado no repo irmão (AllowAny, cursor page_size=50, servido-only) + seed idempotente semear_vitrine_dev; tudo uncommitted em feat/APP02 aguardando autorização do usuário
- [Phase 02]: [Phase 02-02]: Adendos da Fase 2 (busca D-05, ordenacao D-11, preço-base nulls-last D-12 + risco CursorPagination) registrados em 01-CONTRATO-API.md §9, pendentes de sign-off do E2
- [Phase 02]: [Phase 02-03]: Instante-base da fixture (2026-07-20) escolhido anterior a todas as 3 datas verbatim do contrato — linhas 42/57/63 continuam na 1a pagina apos expandir para 40 imoveis/cidade
- [Phase 02]: [Phase 02-04]: Cidades trocadas do asset fixo para GET /api/publico/cidades/ via Dio (D-16/D-17); falha do endpoint nao bloqueia mais quem ja tem cidade salva (autorizadaEAtendida direto)
- [Phase 02]: [Phase 02-05]: D-10 interpretado como botão Ordenar na linha logo abaixo da SearchBar (nao lado a lado) - a 360dp os dois nao cabem juntos; sinalizado no human-check de fim de fase para confirmacao do usuario
- [Phase 02]: [Phase 02-05]: keepScrollOffset:false so restaura o topo com um ScrollPosition NOVO; troca de busca/ordenacao reconstroi o mesmo ListView/controller in-place, entao D-13 precisou de jumpTo(0) explicito num BlocConsumer.listener quando ConteudoVitrine.carregando reaparece

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 4]: Externally blocked on the `Imóvel` model (owned by teammate E2 in `../imoveis-aqui/Web`) — Phases 1-3 do not require it (mock-first build), but Phase 4 cannot complete until that model lands.
- [Phase 1]: API-AUDIT needs live coordination with the teammate on exact `Imóvel` field names/enum values (natureza, finalidade, características shape, quartos/suítes/vagas exact-vs-range semantics) — not resolvable from docs alone.

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 260922-jk3 | Reescrever README com preparo do ambiente e execução do app | 2026-09-22 | e738540 | [260922-jk3-reescrever-o-readme-md-do-projeto-hoje-b](./quick/260922-jk3-reescrever-o-readme-md-do-projeto-hoje-b/) |
| 2 | Adicionar setup de ambiente Windows ao README | 2026-09-22 | b40437b | — |
| 3 | Corrigir compileSdk 35→36 (plugins exigem 36+); verificado com build real no emulador | 2026-09-22 | 559486a | — |

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-09-25T23:28:24.410Z
Stopped at: Completed 02-05-PLAN.md
Resume file: None
