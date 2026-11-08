---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 03
subsystem: api-contract
tags: [contrato, requirements, perfis, wire, teste-de-contrato]

requires:
  - phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
    provides: "PerfilCorretorModel e corretoresPerfisFixture (plano 07-01)"
provides:
  - "IDs PERF-01..06 e API-08 registrados em REQUIREMENTS.md e no ROADMAP (Phase 7)"
  - "Secao 12 do contrato: perfis publicos WEB 02 como estao + vitrine do anunciante + PENDENTE WEB"
  - "perfil_corretor.example.json e perfil_empresa.example.json (wire dos perfis)"
  - "test/data/contrato_perfis_test.dart (allowlists 9/11/3 e coerencia exemplo x fixture)"
affects: [07-09, phase-05-api-imoveis, frente-web]

actuals:
  tokens: 9000
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Exemplos de wire no diretorio contrato/ da Fase 1, protegidos por teste de contrato"

key-files:
  created:
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/perfil_corretor.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/perfil_empresa.example.json
    - test/data/contrato_perfis_test.dart
  modified:
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md

key-decisions:
  - "Allowlist comparada por igualdade exata de chaves (nao apenas subconjunto): chave extra E chave faltando quebram o teste"
  - "Requisitos nao marcados como completos neste plano: API-08 e PERF-04 sao declarados por outros planos da fase (shared-ID gate); o orquestrador fecha"

requirements-completed: [API-08, PERF-04]

coverage:
  - id: D1
    description: "PERF-01..06 e API-08 rastreados para a Phase 7 em REQUIREMENTS.md e no ROADMAP"
    verification:
      - kind: other
        ref: "grep das 7 linhas de rastreabilidade, secao APP07, 37 total e linha Requirements do ROADMAP"
        status: pass
    human_judgment: false
  - id: D2
    description: "Secao 12 do contrato (12.1-12.9) escrita para sign-off da web, sem alterar nenhuma linha antiga"
    requirement: "API-08"
    verification:
      - kind: other
        ref: "git diff --numstat ba77b1e -- 01-CONTRATO-API.md (118 adicoes, 0 remocoes); 9 subsecoes 12.x"
        status: pass
    human_judgment: true
    rationale: "Adequacao do texto como proposta ao time web depende de sign-off humano da frente web"
  - id: D3
    description: "Wire dos perfis protegido por teste de contrato (exemplo do corretor == corretor 7 da fixture; allowlists)"
    requirement: "PERF-04"
    verification:
      - kind: unit
        ref: "test/data/contrato_perfis_test.dart"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-11-08
status: complete
---

# Phase 7 Plan 03: Rastreabilidade e contrato dos perfis Summary

**Secao 12 do contrato da API (perfis WEB 02 consumidos como estao + vitrine do anunciante com `empresa=`/`corretor=` e lista PENDENTE WEB), 2 exemplos de wire e teste de contrato que fixa as allowlists 9/11/3 e a igualdade exemplo x fixture.**

## Performance

- **Duration:** 15 min
- **Started:** 2026-11-08T18:08:00Z
- **Completed:** 2026-11-08T18:24:00Z
- **Tasks:** 2
- **Files modified:** 6 (3 criados, 3 editados)

## Accomplishments
- PERF-01..06 e API-08 registrados em REQUIREMENTS.md (secao "Perfis publicos (APP07)", item API-08, 7 linhas de rastreabilidade, 37 total) e a linha Requirements da Phase 7 no ROADMAP deixou de ser TBD.
- Secao 12 anexada ao contrato (118 linhas adicionadas, nenhuma removida) com 12.1-12.9: perfis WEB 02, endpoint/resposta/ordenacao da vitrine do anunciante, id inexistente = 200 vazio, valor nao inteiro = 400, lista PENDENTE WEB (a-f), sincronizacao e excecao dev-only do recorte no servidor simulado.
- `contrato_perfis_test.dart` (9 testes verdes): allowlists exatas, exemplo do corretor identico ao corretor 7 da fixture, `corretores_ativos` == corretores 7/8/10, parse por `PerfilCorretorModel`, e casos que provam que a guarda tem dente (chave `cpf` e chave faltando).

## Task Commits

1. **Task 1: Registrar PERF-01..06 e API-08 (D-17)** - `39ca0df` (docs)
2. **Task 2: Adendo 12 + exemplos de wire + teste de contrato** - `6d24180` (feat)

## Files Created/Modified
- `.planning/REQUIREMENTS.md` - secao APP07, API-08, rastreabilidade, cobertura
- `.planning/ROADMAP.md` - unica linha Requirements da Phase 7
- `.planning/phases/01-.../01-CONTRATO-API.md` - secao 12 (somente adicao)
- `.planning/phases/01-.../contrato/perfil_corretor.example.json` - corretor 7 verbatim
- `.planning/phases/01-.../contrato/perfil_empresa.example.json` - empresa 3 com corretores 7, 8 e 10
- `test/data/contrato_perfis_test.dart` - teste de contrato dos perfis

## Decisions Made
- Allowlist por igualdade exata de chaves (alem de "sem extras"), para que o contrato incompleto tambem falhe.
- `requirements mark-complete` nao executado: API-08 e PERF-04 sao compartilhados com outros planos da fase; o orquestrador/gate de ID compartilhado decide.

## Deviations from Plan

None - plan executed exactly as written.

Observacao: a verificacao `grep -E '...Pending \|$'` da Task 1 depende de fim de linha LF; o working tree no Windows e CRLF (autocrlf), entao a checagem foi feita com `tr -d '\r'` (indice git continua LF). Nao e desvio de conteudo.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Known Stubs
None.

## Threat Flags
None. T-07-05 mitigado pelo teste de contrato (allowlists 9/11/3 + caso "sujo").

## Next Phase Readiness
- 07-09 pode estender `contrato_perfis_test.dart` com a fixture da empresa 3 (o exemplo da empresa ja traz os corretores 7, 8 e 10 verbatim).
- Pendencias da web registradas em 12.8 (a-f); a Phase 5 precisa ser avisada de que as fixtures de imoveis ficam enquanto o endpoint nao existir.

## Self-Check: PASSED

- Arquivos criados presentes; commits `39ca0df` e `6d24180` sao ancestrais de HEAD; `flutter test test/data/contrato_perfis_test.dart` verde; `flutter analyze` sem issues.

---
*Phase: 07-perfis-p-blicos-da-empresa-e-do-corretor*
*Completed: 2026-11-08*
