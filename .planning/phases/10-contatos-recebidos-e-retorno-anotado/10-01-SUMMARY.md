---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 01
subsystem: api
tags: [django, drf, pagination, contatos, isolamento, multitenant]

requires:
  - phase: 08
    provides: login por token (POST /api/auth/login/) e permissão PertenceAUmaEmpresa
provides:
  - "GET /api/contatos/ em envelope paginado {count,next,previous,results}, 20 por página, filtros preservados no next"
  - "GET /api/contatos/resumo/ -> {sem_retorno: N}, ignora filtros e página"
  - "GET /api/contatos/imoveis/ -> [{id,codigo,titulo}] por código, mesma regra do seletor do site"
  - "PATCH /api/contatos/<id>/ com corpo sem retorno devolvendo 400 em vez de 500"
  - "branch local feat/APP10 no repo web (2 commits sobre 8bf4448, sem push)"
affects: [10-02 captura do wire, 10-03 contrato §17, 10-04, 10-05, 10-06, 10-07, 10-08, 10-09, 10-10]

# Medido: commits de produção no repo WEB (o repo do app só recebe este SUMMARY e o STATE/ROADMAP).
# plan_head_* referem-se ao repo web; no repo do app o ledger registra 0 commits de código (408d148).
commits: 2
plan_head_before: 8bf4448eb36060daf4b9d91cb0a9c2f2a3322aca
plan_head_after: d046bdc78b7aeb17c63206816360d101d198546e

estimate_actuals_note: "tokens = chars/4 sobre o diff web 8bf4448..HEAD (22940 chars)"
actuals:
  tokens: 5735
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "PageNumberPagination com page_size fixo e sem page_size_query_param (cliente não escolhe o tamanho)"
    - "@action(detail=False) partindo de contatos_visiveis_para(request.user), nunca de filtrar_contatos"
    - "CenarioDeIsolamento como base de teste compartilhada (IsolamentoTests, ResumoSemRetornoTests, OpcoesDeImovelDaCaixaTests)"

key-files:
  created: []
  modified:
    - "C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web/contatos/api/views.py"
    - "C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web/contatos/api/serializers.py"
    - "C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web/contatos/tests.py"
    - "C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/README.md"

key-decisions:
  - "D-12 aplicado: lista da caixa vira envelope paginado de 20 (mudança costly já decidida, só o app consome)"
  - "Anônimo recebe 401 nas rotas novas (medido em teste, WWW-Authenticate: Token) — nenhum fallback para 403 foi necessário"
  - "Base de teste CenarioDeIsolamento extraída do setUp de IsolamentoTests, sem mudar o comportamento dele"

requirements-completed: [API-14, CXA-01, CXA-02, CXA-03, CXA-04, CXA-05]

coverage:
  - id: D1
    description: "Caixa paginada ponta a ponta com token real: login -> GET /api/contatos/ em envelope de 20, 12 chaves por item, ordem -criado_em,-id, filtros no next, page=99 em 404, page_size ignorado"
    requirement: "API-14"
    verification:
      - kind: integration
        ref: "contatos.tests.PaginacaoDaCaixaTests (7 testes, incl. test_ponta_a_ponta_com_login_real_e_token)"
        status: pass
    human_judgment: false
  - id: D2
    description: "GET /api/contatos/resumo/ conta so os PENDENTE visiveis ao usuario, ignora filtros/pagina e cai apos PATCH"
    requirement: "CXA-05"
    verification:
      - kind: integration
        ref: "contatos.tests.ResumoSemRetornoTests"
        status: pass
    human_judgment: false
  - id: D3
    description: "GET /api/contatos/imoveis/ devolve as opcoes do filtro pela mesma regra do seletor do site"
    requirement: "CXA-03"
    verification:
      - kind: integration
        ref: "contatos.tests.OpcoesDeImovelDaCaixaTests"
        status: pass
    human_judgment: false
  - id: D4
    description: "PATCH {} responde 400 {retorno:[...]} sem alterar o contato; PUT segue 405; isolamento por empresa/corretor/admin/anonimo nas rotas novas"
    requirement: "CXA-04"
    verification:
      - kind: integration
        ref: "contatos.tests.AnotarRetornoTests / contatos.tests.IsolamentoTests"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-23
status: complete
---

# Phase 10 Plan 01: Caixa de contatos no Django Summary

**Caixa de contatos da API Django paginada em 20 (envelope DRF), com rotas `resumo` (sem retorno) e `imoveis` (opções do filtro) partindo de `contatos_visiveis_para`, PATCH vazio virando 400 e isolamento por empresa/corretor provado por teste, em dois commits locais na `feat/APP10` da web.**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-11-23T22:13Z (aprox.)
- **Completed:** 2026-11-23T22:40Z
- **Tasks:** 2 (1 tracer + 1 TDD)
- **Files modified:** 4 (todos no repo web)

## Accomplishments

- Tracer provado de ponta a ponta com token real: `POST api-login` -> `Authorization: Token` -> `GET contato-list` em envelope `{count,next,previous,results}` com 20 itens, `next` absoluto (`http://testserver/...page=2`) preservando `de`/`ate`.
- `resumo` e `imoveis` como `@action(detail=False)` da `ContatoViewSet`, atrás de `PertenceAUmaEmpresa` (admin 403, anônimo 401) e fora de `filtrar_contatos` (D-05).
- `ContatoSerializer.validate` fecha o 500 por `KeyError` do `PATCH {}` (emenda ao D-25).
- Fuso: o recorte `de`/`ate` pelo dia de São Paulo ficou travado por teste (10/01 01:30 UTC = 09/01 22:30 local).
- Suíte completa da web: 766 testes verdes (743 de linha de base + 23 novos); `manage.py check` limpo.

## Task Commits

Commits no repo web (`C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui`), branch `feat/APP10`, sem push:

1. **Task 1: TRACER — caixa paginada ponta a ponta** - `6c0838b` (feat)
2. **Task 2: resumo, imoveis, PATCH {} -> 400, isolamento, fuso, README** - `d046bdc` (feat)

**Plan metadata:** commit `docs(10-01)` no repo do app (este SUMMARY + STATE + ROADMAP + REQUIREMENTS).

## TDD / RED evidence

- **Task 1 RED:** o RED do plano (import de `PaginacaoContatos` falhando) é falha de carga, não de asserção. Para o RED ser válido, a classe `PaginacaoContatos` foi adicionada sem ser ligada à ViewSet e os testes rodaram: 5 ERROR (`TypeError: list indices must be integers or slices, not str` / `unhashable type: 'dict'` — a lista ainda era um array, sem envelope) e 1 FAIL (`AssertionError: 200 != 404` para `?page=99`); `test_detalhe_e_patch_devolvem_o_item_sem_envelope` passou, como esperado (comportamento inalterado). Avaliação semântica: os alvos executaram e falharam pela asserção do comportamento planejado (envelope/paginação ausentes). O classificador `gsd_run check tdd-red-evidence` não foi usado (formato unittest do Django verificado manualmente; o plano não é `type: tdd`).
- **Task 2 RED:** 19 ERROR — `NoReverseMatch` para `contato-resumo`/`contato-imoveis` e `KeyError: 'retorno'` no `PATCH {}`. Passaram de saída (testes de caracterização, esperado): fuso de São Paulo, `PUT` 405, 12 chaves do PATCH e `criado_em` com `-03:00`.
- **GREEN:** `views.py` (paginação, `resumo`, `imoveis`), `serializers.py` (`validate`) e README. 57 testes de `contatos` verdes, depois 766 na suíte inteira.
- **Commits:** RED e GREEN entram no mesmo commit por tarefa (o plano manda um commit por tarefa, não `test(...)`/`feat(...)` separados).

## Files Created/Modified

- `Web/contatos/api/views.py` - `CONTATOS_POR_PAGINA = 20`, `PaginacaoContatos`, `pagination_class` na ViewSet, ações `resumo` e `imoveis`.
- `Web/contatos/api/serializers.py` - `ContatoSerializer.validate` exigindo `retorno`.
- `Web/contatos/tests.py` - `PaginacaoDaCaixaTests`, `ResumoSemRetornoTests`, `OpcoesDeImovelDaCaixaTests`, base `CenarioDeIsolamento`, testes novos em `IsolamentoTests`/`AnotarRetornoTests`/`CaixaDeContatosTests`; `ids_api` lê `response.data["results"]`.
- `README.md` (web) - linhas da lista com `&page=`, `resumo`, `imoveis` e PATCH com 400.

## Decisions Made

- Anônimo nas rotas novas: 401 com `WWW-Authenticate: Token`, como medido na pesquisa (sem precisar do fallback 401/403). Registrar no §17 (10-03).
- `IsolamentoTests` agora herda de `CenarioDeIsolamento` (o `setUp` foi movido sem alteração); as duas classes novas reaproveitam o mesmo cenário.
- Edição dos arquivos preservando CRLF (o repo web usa `core.autocrlf=true`; os arquivos de trabalho são CRLF).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking/qualidade do RED] RED do tracer feito com a classe stub em vez do import quebrado**
- **Found during:** Task 1 (RED)
- **Issue:** O RED descrito (ImportError) é falha de carga, que a regra de TDD trata como RED inválido.
- **Fix:** Adicionou `PaginacaoContatos` (ainda não ligada) antes de rodar o RED, para as falhas virarem asserções do comportamento.
- **Files modified:** `Web/contatos/api/views.py` (mesmo commit `6c0838b`)

**2. [Rule 3 - Refactor de teste] Cenário de isolamento extraído para base compartilhada**
- **Found during:** Task 2
- **Issue:** O plano permitia copiar o `setUp` ou extrair um helper; copiar duplicaria 12 linhas em duas classes.
- **Fix:** `CenarioDeIsolamento(ContatoBase)` com o `setUp` original; `IsolamentoTests` herda dela sem mudar comportamento (todos os testes antigos continuam verdes).
- **Files modified:** `Web/contatos/tests.py` (commit `d046bdc`)

**Total deviations:** 2 (ambas organizacionais, sem mudança de comportamento do produto). **Impact:** nenhum no escopo nem no contrato.

## Issues Encountered

- A atualização dos testes do app (`.planning` etc.) não se aplica aqui: nenhuma mudança no repo do app neste plano (fim da onda 1, D-29).
- Os arquivos do repo web são CRLF; as edições foram feitas por script Python preservando CRLF para não gerar diff de fim de linha.

## Known Stubs

None.

## Threat Flags

None — as rotas novas são as já previstas em T-10-01..T-10-05 (mitigadas por teste); `Web/requirements.txt` inalterado (T-10-SC) e T-10-06 (`imoveis/` sem paginação) segue aceito.

## Next Phase Readiness

Pronto para o 10-02 (captura do wire real: login -> `GET /api/contatos/`, `resumo`, `imoveis`, PATCH 200/400/404) e o 10-03 (§17 do contrato). A `feat/APP10` da web está local, com árvore limpa e sem `origin/feat/APP10`; nenhum push foi feito (D-B).

## Self-Check: PASSED

- Arquivos modificados no repo web existem e contêm `class PaginacaoContatos(PageNumberPagination)`, `pagination_class = PaginacaoContatos`, `def resumo(self, request)`, `def imoveis(self, request)`, `def validate(self, atributos)`, `class ResumoSemRetornoTests`, `class OpcoesDeImovelDaCaixaTests`, e as rotas `/api/contatos/resumo/` e `/api/contatos/imoveis/` no README.
- Commits `6c0838b` e `d046bdc` estão na `feat/APP10` da web com `8bf4448` como ancestral; `git rev-list --count 8bf4448..HEAD` = 2.
- `manage.py test --noinput` (SQLite em memória): 766 testes, OK. `Web/requirements.txt` igual ao de `8bf4448`; árvore limpa; sem `origin/feat/APP10`.
