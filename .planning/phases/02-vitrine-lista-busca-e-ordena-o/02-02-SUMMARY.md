---
phase: 02-vitrine-lista-busca-e-ordena-o
plan: 02
subsystem: api
tags: [django, drf, cursor-pagination, allowany, management-command, contrato-api]

# Dependency graph
requires:
  - phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api
    provides: "01-CONTRATO-API.md (§2.1-§2.3, §4), CidadeSerializer reaproveitável, EmpresaPublicaAPIView como precedente AllowAny, contrato/cidades.example.json"
provides:
  - "GET /api/publico/cidades/ real, público, servido-only (Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()), cursor page_size=50 ordering (nome, uf), no repo irmão ../imoveis-aqui/Web"
  - "Comando de desenvolvimento semear_vitrine_dev — idempotente, DEBUG-only, semeia as mesmas 4 cidades (Campinas/Valinhos/Vinhedo/Indaiatuba-SP) do contrato e da fixture mock do app com 1 Empresa de demonstração ativa"
  - "Adendos da Fase 2 registrados em 01-CONTRATO-API.md: §5 (busca), §7.4 (ordenacao adotada), §7.5 (novo — preço-base nulls last + risco CursorPagination), §2.2/§2.3 (paginação real de /cidades + remoção do asset local), §9 (resumo consolidado)"
affects: ["02-04 (VIT-06 troca a lista fixa/mock por este endpoint real)", "04 (endpoint real de /imoveis herda o mesmo risco de nulls-last documentado em §7.5)"]

# Actuals (#2632)
actuals:
  tokens: 4874
  tasks: 2
  commits: 1
  plan_head_before: bac7701

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Regra 'atendida' decidida inteiramente no queryset do servidor (empresas_atuantes__ativa=True, .distinct()), nunca por parâmetro do cliente — mesmo idioma de EmpresaPublicaAPIView.queryset = Empresa.objects.filter(ativa=True)"
    - "Seed de desenvolvimento idempotente via get_or_create + guarda settings.DEBUG (CommandError fora de DEBUG), buscando a Empresa demo só pelo nome marcador próprio — nunca toca outra Empresa"
    - "Teste de paginação cursor simula inserção concorrente colocando a nova cidade ANTES da posição do cursor da página 1 (entre Cidade025 e Cidade026), provando estabilidade por posição em vez de por offset"

key-files:
  created:
    - ../imoveis-aqui/Web/empresas/management/__init__.py
    - ../imoveis-aqui/Web/empresas/management/commands/__init__.py
    - ../imoveis-aqui/Web/empresas/management/commands/semear_vitrine_dev.py
  modified:
    - ../imoveis-aqui/Web/empresas/api/views.py
    - ../imoveis-aqui/Web/empresas/api/urls_publico.py
    - ../imoveis-aqui/Web/empresas/tests.py
    - ../imoveis-aqui/Web/.env.example
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md

key-decisions:
  - "Mudanças no repo irmão ficam 100% uncommitted em feat/APP02 (HEAD == main) — CLAUDE.md do repo irmão exige autorização explícita do usuário antes de qualquer commit lá."
  - "Uma única Empresa de demonstração (get_or_create pelo nome marcador NOME_EMPRESA_DEMO) atende as 4 cidades do seed, em vez de 4 empresas com 4 CNPJs — reduz superfície e reforça a idempotência."
  - "Teste de concorrência de paginação usa uma cidade nova posicionada ANTES do cursor da página 1 (não depois) para provar que a página 2 nunca perde/duplica cidades já existentes quando o acervo cresce entre requisições."

requirements-completed: [API-02]

coverage:
  - id: D1
    description: "GET /api/publico/cidades/ responde 200 sem token/sessão, no envelope {next, previous, results}"
    requirement: "API-02"
    verification:
      - kind: integration
        ref: "empresas/tests.py#CidadesPublicasAPITests.test_lista_cidades_publica_sem_autenticacao_200"
        status: pass
    human_judgment: false
  - id: D2
    description: "Só cidades com empresa ativa aparecem, uma única vez cada, mesmo com múltiplas empresas atuando na mesma cidade"
    requirement: "API-02"
    verification:
      - kind: integration
        ref: "empresas/tests.py#CidadesPublicasAPITests.test_somente_cidades_atendidas_aparecem_uma_unica_vez"
        status: pass
    human_judgment: false
  - id: D3
    description: "Cada linha expõe exatamente id, nome, uf — nenhum dado interno"
    requirement: "API-02"
    verification:
      - kind: integration
        ref: "empresas/tests.py#CidadesPublicasAPITests.test_cada_linha_tem_somente_id_nome_uf"
        status: pass
    human_judgment: false
  - id: D4
    description: "CursorPagination page_size=50, next absoluto com cursor=, sem duplicar/perder cidades quando uma nova é criada entre duas requisições"
    requirement: "API-02"
    verification:
      - kind: integration
        ref: "empresas/tests.py#CidadesPublicasAPITests.test_paginacao_cursor_50_por_pagina_sem_duplicar_com_insercao_concorrente"
        status: pass
    human_judgment: false
  - id: D5
    description: "Endpoint é somente leitura — POST responde 405"
    requirement: "API-02"
    verification:
      - kind: integration
        ref: "empresas/tests.py#CidadesPublicasAPITests.test_post_retorna_405"
        status: pass
    human_judgment: false
  - id: D6
    description: "semear_vitrine_dev é idempotente (rodar 2x não duplica), cria as 4 cidades do contrato com 1 Empresa demo ativa, e recusa rodar com DEBUG=False"
    requirement: "API-02"
    verification:
      - kind: integration
        ref: "empresas/tests.py#SemearVitrineDevTests (2 casos: idempotência+DEBUG=True, CommandError+DEBUG=False)"
        status: pass
    human_judgment: false
  - id: D7
    description: "Adendos da Fase 2 (busca, ordenacao, preço-base nulls-last, paginação de /cidades) registrados em 01-CONTRATO-API.md, marcados como pendentes de sign-off do E2, sem perder §1-§8"
    verification:
      - kind: other
        ref: "grep -n 'Adendos da Fase 2|search_param|Coalesce|semear_vitrine_dev|page_size = 50' 01-CONTRATO-API.md (todos presentes) + grep -c '^## ' == 9"
        status: pass
    human_judgment: false
  - id: D8
    description: "Verificação visual real: servidor Django rodando com Postgres do usuário, curl contra localhost e contra Host: 10.0.2.2 (emulador Android) retornando as 4 cidades"
    verification: []
    human_judgment: true
    rationale: "Requer as credenciais Postgres do usuário (desconhecidas por este agente — a tentativa com postgres:postgres foi recusada nesta máquina) e um dev server rodando; consolidado no UAT de fim de fase (human_verify_mode=end-of-phase). USER-SETUP não gerado porque o plano já embute os passos no seu próprio human-check."
  - id: D9
    description: "Usuário revisa git diff/status em ../imoveis-aqui (branch feat/APP02) e autoriza (ou faz) o commit — Claude não commitou no repo irmão"
    verification: []
    human_judgment: true
    rationale: "O CLAUDE.md do repo irmão exige autorização explícita do usuário para qualquer commit; este agente não pode se autoaprovar, independentemente do modo (auto ou interativo)."

duration: 11min
completed: 2026-09-25
status: complete
---

# Phase 2 Plan 2: Endpoint Público de Cidades + Seed de Desenvolvimento + Adendos ao Contrato Summary

**`GET /api/publico/cidades/` real no Django (AllowAny, cursor page_size=50, só cidades com empresa ativa), com seed idempotente `semear_vitrine_dev` e os adendos D-05/D-11/D-12 registrados no contrato congelado — tudo no repo irmão, aguardando autorização do usuário para commit.**

## Performance

- **Duration:** 11 min
- **Started:** 2026-09-25T20:03:30Z
- **Completed:** 2026-09-25T20:14:00Z
- **Tasks:** 2
- **Files modified:** 8 (5 no repo irmão `../imoveis-aqui/Web` + 1 no repo do app)

## Accomplishments
- Endpoint público `GET /api/publico/cidades/` (API-02): `CidadesPublicasAPIView` (`AllowAny`, `ListAPIView`) reaproveitando `CidadeSerializer` sem alteração, com queryset `Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()` — a regra "atendida" decidida inteiramente no servidor
- `CidadeCursorPagination` (`page_size=50`, `ordering=("nome","uf")`, sem `page_size_query_param`) provada por um teste que insere uma cidade nova ENTRE duas requisições, posicionada antes do cursor da página 1, e confirma zero duplicação/perda na página 2
- Comando `semear_vitrine_dev`: idempotente (`get_or_create`), recusa rodar fora de `DEBUG=True` (`CommandError`), semeia as mesmas 4 cidades do contrato/fixture mock com 1 única Empresa de demonstração
- 12 testes Django (6 novos de `CidadesPublicasAPITests` + 2 novos de `SemearVitrineDevTests`, mais os 4 pré-existentes de `EmpresaModelTests`) passando em SQLite em memória; `manage.py check` limpo
- `01-CONTRATO-API.md` atualizado com os adendos da Fase 2 (§5 `busca`, §7.4 `ordenacao`, §7.5 novo com o risco de nulls-last do `CursorPagination`, §2.2/§2.3 com fatos de paginação/remoção do asset local, §9 novo resumindo tudo) — §1-§8 preservados intactos

## Task Commits

Cada task foi commitada atomicamente:

1. **Task 1: GET /api/publico/cidades/ público, só cidades atendidas, cursor + seed de desenvolvimento (API-02)** — sem commit no app repo (todo o trabalho é no repo irmão `../imoveis-aqui/Web`, branch `feat/APP02`, **não commitado** — HEAD ainda igual a `main`, aguardando autorização explícita do usuário, conforme `../imoveis-aqui/CLAUDE.md`).
2. **Task 2: Adendos da Fase 2 no contrato congelado** — `9c34d8c` (docs)

**Plan metadata:** commitado junto com este SUMMARY.

_Nota: task com `tdd="true"` seguiu RED (12 testes falhando por `NoReverseMatch`/`CommandError: Unknown command`) → GREEN (12/12 passando) dentro do repo irmão, sem commit intermediário ali (regra do CLAUDE.md irmão), diferente do padrão usual de commits separados por fase RED/GREEN._

## Files Created/Modified

**Repo irmão `../imoveis-aqui/Web` (branch `feat/APP02`, uncommitted):**
- `empresas/api/views.py` - `CidadeCursorPagination` + `CidadesPublicasAPIView` (`AllowAny`)
- `empresas/api/urls_publico.py` - rota `cidades/` → `name="publico-cidades"`
- `empresas/tests.py` - `CidadesPublicasAPITests` (6 testes) + `SemearVitrineDevTests` (2 testes)
- `empresas/management/__init__.py`, `empresas/management/commands/__init__.py` - novos pacotes vazios
- `empresas/management/commands/semear_vitrine_dev.py` - comando de seed idempotente DEBUG-only
- `.env.example` - `ALLOWED_HOSTS` estendido com `10.0.2.2` (emulador Android) + comentário

**Repo do app (commitado):**
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` - adendos da Fase 2 (§2.2, §2.3, §5, §7.4, §7.5 novo, §9 novo)

## Decisions Made
- Uma única Empresa de demonstração (`get_or_create` por `razao_social_ou_nome=NOME_EMPRESA_DEMO`) atende as 4 cidades do seed, em vez de 4 empresas — menos CNPJs para gerenciar, mesma garantia de "atendida".
- O teste de concorrência de paginação insere a cidade nova ANTES da posição do cursor da página 1 (entre `Cidade025` e `Cidade026`), não depois — isso é o que de fato prova estabilidade por posição (a inserção não afeta a segunda página, que continua exatamente com as 5 cidades restantes), em vez de testar um caso que não distingue paginação por cursor de paginação por offset.
- Nada foi commitado em `../imoveis-aqui` — toda a Task 1 fica em `feat/APP02` com `HEAD == main`, exatamente como o `CLAUDE.md` do repo irmão exige.

## Deviations from Plan

None — plan executado exatamente como escrito. Os dois `human-check` do `<verify>` da Task 1 (servidor real com Postgres do usuário, e revisão/autorização do diff no repo irmão) são, por natureza, não automatizáveis por este agente e ficam consolidados no UAT de fim de fase (`human_verify_mode: end-of-phase`), como já antecipado no `checkpoint_note` desta execução.

## Issues Encountered
None.

## User Setup Required

**Ação pendente do usuário antes do UAT de fim de fase** (não é uma "USER-SETUP.md" formal porque o próprio `<verify>` da Task 1 já traz os passos exatos):

1. Em `../imoveis-aqui/Web`, criar `.env` a partir de `.env.example` com suas próprias credenciais Postgres (`DATABASE_URL`) e `ALLOWED_HOSTS` incluindo `10.0.2.2` + o IP da sua rede local.
2. Rodar `python manage.py migrate`, `python manage.py semear_vitrine_dev`, `python manage.py runserver 0.0.0.0:8000`.
3. Confirmar `curl -i http://localhost:8000/api/publico/cidades/` e `curl -i -H "Host: 10.0.2.2:8000" http://localhost:8000/api/publico/cidades/` — ambos 200, sem token, com Campinas/Indaiatuba/Valinhos/Vinhedo (SP).
4. Revisar `git -C ../imoveis-aqui diff` / `status` em `feat/APP02` e autorizar (ou fazer você mesmo) o commit — Claude não commitou nada lá.

## Next Phase Readiness
- API-02 completo e testado (12/12 testes Django, `manage.py check` limpo); pronto para o plano 02-04 (VIT-06) trocar a lista de cidades fixa/mock pelo consumo real deste endpoint.
- Os 4 adendos da Fase 2 (`busca`, `ordenacao`, preço-base nulls-last, formato de `cidade`) estão registrados em `01-CONTRATO-API.md §9`, aguardando sign-off do E2 — nenhum bloqueia esta fase (mock em Dart puro), mas o risco do `CursorPagination` com campos nulos (§7.5) **bloqueia a Fase 4** se não for resolvido antes.
- Mudanças no repo irmão seguem 100% não commitadas em `feat/APP02` — dependem da autorização do usuário para virar commit real.

---
*Phase: 02-vitrine-lista-busca-e-ordena-o*
*Completed: 2026-09-25*

## Self-Check: PASSED

- Todos os 8 arquivos criados/modificados verificados presentes em disco (`[ -f ]`): 3 novos + 4 modificados no repo irmão, 1 modificado no repo do app.
- Commit `9c34d8c` (Task 2) verificado em `git log` do repo do app.
- Repo irmão confirmado em `feat/APP02` com `HEAD == main` (`git rev-parse HEAD` == `git rev-parse main`) — nenhum commit não autorizado.
- Suíte Django completa (`empresas`, 12 testes) e `manage.py check` re-executados nesta sessão, ambos verdes.
- Todos os greps de verificação de Task 1 e Task 2 (page_size, empresas_atuantes__ativa, publico-cidades, Adendos da Fase 2, search_param, Coalesce, semear_vitrine_dev) re-executados e passando.
