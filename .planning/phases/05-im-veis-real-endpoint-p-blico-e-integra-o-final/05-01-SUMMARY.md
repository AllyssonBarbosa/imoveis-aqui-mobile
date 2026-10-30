---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 01
subsystem: api
tags: [django, drf, git-merge, vitrine, na_vitrine, multitenant]

requires:
  - phase: 02-api-publica
    provides: "W09 (origin/WEB-09) com rotas públicas publico-vitrine-cidade, publico-imovel e publico-cidades"
provides:
  - "Política de git da fase registrada (opcao-a + app-a), lida por todos os planos seguintes"
  - "Branch local feat/APP05 na API = origin/WEB-09 + merge de origin/feat/web-08 (W05..W08)"
  - "imoveis_da_vitrine() sobre Imovel.objects.na_vitrine() — regra única publicado + DISPONIVEL + empresa ativa"
  - "VitrineSituacaoTests: reservado/vendido/alugado fora de lista, detalhe (mesmo 404) e cidades atendidas"
  - "Branch local feat/APP05 no repo do app (a partir da feat/APP04)"
affects: [05-02, 05-03, 05-04, 05-05, 05-06, 05-07, 05-08, 05-09, 05-10, 05-11, 05-12, 05-13, 05-14, 05-15, 05-16, 05-17, 05-18]

plan_head_before: 575c69742566fc6d251e5c52c7020cfae7b0c208
actuals:
  tokens: 20000
  tasks: 3
  commits: 0   # MEDIDO no repo do app (git rev-list plan_head_before..HEAD, antes do commit do SUMMARY): plano sem código no app. Repo da API: 1 commit local (merge 0592176).

tech-stack:
  added: []
  patterns:
    - "Regra de vitrine em um só lugar (ImovelQuerySet.na_vitrine) consumida por lista, detalhe e cidades"
    - "404 idêntico para imóvel fora da vitrine e id inexistente (sem enumeração)"

key-files:
  created: []
  modified:
    - ../imoveis-aqui/Web/config/urls.py
    - ../imoveis-aqui/Web/imoveis/api/serializers.py
    - ../imoveis-aqui/Web/imoveis/api/urls_publico.py
    - ../imoveis-aqui/Web/imoveis/api/views.py
    - ../imoveis-aqui/Web/imoveis/tests.py
    - ../imoveis-aqui/Web/imoveis/vitrine.py

key-decisions:
  - "Git (Task 1, respondida pelo usuário): opcao-a + app-a"
  - "Vitrine pública da W08 (VitrineImovelViewSet, VitrineImovelSerializer, router vitrine-imovel) removida na resolução do merge; vence a da W09 (D-10a)"
  - "tests.py do merge reconstruído a partir da versão da web-08 + bloco da W09 inserido no mesmo ponto, em vez de resolver hunk a hunk (os hunks do git estavam intercalados)"

requirements-completed: [API-03, API-07]

coverage:
  - id: D1
    description: "feat/APP05 da API = origin/WEB-09 + merge de origin/feat/web-08, sem conflito remanescente e sem push"
    requirement: API-03
    verification:
      - kind: other
        ref: "git -C ../imoveis-aqui merge-base --is-ancestor origin/feat/web-08 HEAD; git branch -r --contains HEAD (vazio)"
        status: pass
    human_judgment: false
  - id: D2
    description: "imoveis_da_vitrine() usa Imovel.objects.na_vitrine(); reservado/vendido/alugado fora de lista, detalhe (mesmo 404) e cidades atendidas"
    requirement: API-03
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineSituacaoTests"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrinePublicaTests"
        status: pass
    human_judgment: false
  - id: D3
    description: "Leitura consistente sob mudança de situação concorrente (API-07): regra reavaliada a cada requisição"
    requirement: API-07
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrineSituacaoTests.test_mudanca_entre_a_lista_e_o_detalhe_vale_na_leitura_seguinte"
        status: pass
    human_judgment: false
  - id: D4
    description: "Suíte Django inteira (285 testes) verde em SQLite em memória; makemigrations --check sem migração faltando"
    verification:
      - kind: integration
        ref: "DATABASE_URL=sqlite://:memory: manage.py test --noinput; manage.py makemigrations --check --dry-run"
        status: pass
    human_judgment: false

duration: 5min
completed: 2026-10-30
status: complete
---

# Phase 5 Plan 01: Base da API (merge W05..W08 + regra única da vitrine) Summary

**feat/APP05 da API = origin/WEB-09 + merge de origin/feat/web-08, com a vitrine pública da W09 filtrada pela regra única `Imovel.objects.na_vitrine()` da W08 e 285 testes Django verdes.**

## Escolhas de git (Task 1, checkpoint já respondido pelo usuário)

**Resposta registrada: `opcao-a + app-a`.** Todo plano seguinte da fase lê a política de git daqui.

- **API (`../imoveis-aqui`) — opcao-a:** branch local `feat/APP05` a partir de `origin/WEB-09`, merge de `origin/feat/web-08` e **somente o commit do merge** feito pelo agente. Todas as demais mudanças da fase no repo da API (05-01 Task 3, 05-02, 05-04, 05-05) ficam **sem commit, no working tree**. Nunca push.
- **App (`imovies-aqui-mobile`) — app-a:** branch local `feat/APP05` a partir de `feat/APP04`; **um commit local por task** de código nos planos que mudam o app (05-03, 05-06 a 05-18), documentos de `.planning/` pelo auto-commit do GSD. Nunca push. Planos paralelos podem usar worktrees.

## Heads e commits

| Item | Valor |
|------|-------|
| `origin/WEB-09` | `8ad14108a4d3337af6a185faa45277ec9b9dc680` (esperado 8ad1410) |
| `origin/feat/web-08` | `ebcbcd623ea78baef13ed358ce8421a49272fa26` (esperado ebcbcd6) |
| Conflitos do merge | exatamente os 5 arquivos previstos |
| Commit do merge (API, feat/APP05) | `0592176` |
| App: feat/APP05 criada de | `575c697` (feat/APP04) |
| Push / remoto contém HEAD | nenhum (`git branch -r --contains HEAD` vazio) |

## Performance

- **Duration:** 5 min (executor)
- **Started:** 2026-10-30T18:32:05Z
- **Completed:** 2026-10-30T18:37Z
- **Tasks:** 3 (1 checkpoint já respondido, 1 tracer, 1 auto/tdd)
- **Files modified:** 6 (todos no repo da API)

## Accomplishments

- Merge de W05..W08 sobre a W09 resolvido nos 5 arquivos em conflito: `config/urls.py` (cada include uma vez), `api/urls_publico.py` (arquivo da W09, sem router), `api/views.py` (união painel W07/W08 + vitrine W09, sem `VitrineImovelViewSet`), `api/serializers.py` (união, sem `VitrineImovelSerializer` que vazava `codigo`/`empresa`/id do corretor), `tests.py` (todas as classes dos dois lados, helpers uma vez).
- `imoveis_da_vitrine()` parte de `Imovel.objects.na_vitrine()`, docstring atualizada; lista, detalhe e cidades atendidas passam todos por ela.
- `VitrinePublicaTests` da W08 reapontada para `publico-vitrine-cidade` / `publico-imovel` (asserções por `id`, mesmos 5 comportamentos).
- `VitrineSituacaoTests` (4 testes): três situações fora da lista; 404 do detalhe idêntico ao de id inexistente; cidade some e volta de `publico-cidades`; mudança de situação entre lista e detalhe vale na leitura seguinte (API-07).
- `makemigrations --check --dry-run`: nenhuma migração faltando (0005/0006 vêm da web-08).

## Task Commits

1. **Task 1 (checkpoint:decision)** — respondida pelo usuário: `opcao-a + app-a`. Sem commit.
2. **Task 2 (tracer)** — branch `feat/APP05` criada no app (sem commit) e na API; merge commit da API `0592176` (inclui `vitrine.py` e o `tests.py` reapontado).
3. **Task 3 (auto, tdd)** — `VitrineSituacaoTests` em `Web/imoveis/tests.py`, **sem commit** por opcao-a (fica no working tree da API).

Tracer gate: modo `end-of-phase` com `<verify>` só automatizado — `manage.py check` e a suíte inteira verdes (281 testes no merge, 285 com os 4 novos), seguiu para a Task 3.

## Deviations from Plan

None - plan executed exactly as written.

Observações (não são desvios de regra):
- `tests.py` do merge foi montado a partir da versão da web-08 mais o bloco W09 inserido no mesmo ponto (os hunks do git vinham intercalados), com `from unittest import mock` e `from .api.views import PaginacaoVitrine` restaurados nos imports. Resultado verificado pela suíte inteira.
- Trailer dos commits do agente: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` (atribuição da sessão), no lugar de "Opus 5.5" citado no prompt do orquestrador.

## Verificação do plano

- Ambos os repos em `feat/APP05`; `origin/feat/web-08` é ancestral do HEAD da API; sem marcadores de conflito em `Web/config`, `Web/imoveis`, `README.md`.
- `grep "vitrine-imovel-|SimpleRouter"` em `urls_publico.py` e `tests.py`: vazio. `grep -c "imoveis.api.urls_publico" config/urls.py` = 1; `localizacao.api.urls_publico` presente.
- `manage.py check` limpo; `manage.py test --noinput`: 285 testes OK (SQLite em memória).
- Banco de dev do `Web/.env` não foi tocado nem lido; `.gitignore` intocado. `Web/empresas/management/` (untracked pré-existente) intocado.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum — superfície pública diminuiu (viewset/serializer da W08 removidos, T-05-01-01/02/03 mitigados e testados).

## Next Phase Readiness

Pronto para 05-02 (API: lote). Lembrete aos planos seguintes: mudanças no repo da API ficam no working tree (opcao-a); a migração 0005/0006 no banco de dev é a task [BLOCKING] do plano 05-05.

## Self-Check: PASSED

- API: `0592176` existe em `git log`; `Web/imoveis/vitrine.py` contém `objects.na_vitrine()`; `Web/imoveis/tests.py` contém `class VitrineSituacaoTests`, `class VitrinePublicaTests`, `class LoteamentoModelTests`.
- App: branch `feat/APP05` ativa; `plan_head_before` = 575c697.
