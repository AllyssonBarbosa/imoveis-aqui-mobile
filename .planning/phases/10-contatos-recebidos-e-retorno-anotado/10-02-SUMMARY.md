---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 02
subsystem: api
tags: [fixtures, captura, django, contatos, isolamento, wire-real]

requires:
  - phase: 10-01
    provides: "GET /api/contatos/ paginado, resumo, imoveis e PATCH com 400 na feat/APP10 do repo web"
provides:
  - "grupo `contatos` em tool/capturar_fixtures_api.py (enviar_patch, CANAIS_CONTATO, capturar_contatos)"
  - "11 fixtures reais da caixa de contatos em test/fixtures/api/ (lista p1/p2, filtros, resumo antes/depois, opções, PATCH 200/400/404, caixa da empresa B)"
  - "evidência no wire do isolamento entre empresas (empresa B com 1 contato de verdade)"
affects: [10-03 contrato §16, 10-05, 10-06, 10-07, 10-08, 10-09, 10-10]

commits: 2
plan_head_before: e70b498209043daeea8fb176424eb368c0ac6c01
plan_head_after: 4b1d2c4bdb8bda28c7c4885f39acdbd82870e14a

estimate_actuals_note: "tokens = chars/4 sobre o diff do app e70b498..4b1d2c4 (33760 chars)"
actuals:
  tokens: 8440
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "captura do wire real contra SQLite temporário, sem fixture escrita à mão (padrão §12/§14)"
    - "isolamento provado no wire: a captura falha se a caixa da empresa B vier vazia ou se o contato dela vazar para a A"

key-files:
  created:
    - test/fixtures/api/contatos_p1.json
    - test/fixtures/api/contatos_p2.json
    - test/fixtures/api/contatos_imovel.json
    - test/fixtures/api/contatos_periodo_vazio.json
    - test/fixtures/api/contatos_resumo.json
    - test/fixtures/api/contatos_resumo_apos.json
    - test/fixtures/api/contatos_imoveis.json
    - test/fixtures/api/contato_patch_200.json
    - test/fixtures/api/erro_400_retorno.json
    - test/fixtures/api/contatos_outra_empresa.json
    - test/fixtures/api/erro_404_contato.json
  modified:
    - tool/capturar_fixtures_api.py

key-decisions:
  - "Contato da empresa B criado pelo ORM só no SQLite temporário (DEMO-CASA-01 está VENDIDO, fora da vitrine; a rota pública recusaria); nenhum seed nem arquivo do repo web mudou"
  - "Na main@8bf4448 o POST público de contato não tem limite de taxa e CONTATO_TAXA_ANONIMA não existe no settings.py da feat/APP10; o servidor subiu sem ela (só LOGIN_TAXA_* = 100/hour)"

requirements-completed: [API-11, CXA-04]

coverage:
  - id: D1
    description: "Wire real da caixa de contatos capturado do Django: p1 (20 itens, count 25, next absoluto), p2 (5), filtro por imóvel, período vazio, opções do filtro, PATCH 200/400/404"
    requirement: "API-11"
    verification:
      - kind: command
        ref: "python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo contatos (exit 0, todas as checagens internas) + asserts Python sobre as 11 fixtures"
        status: pass
    human_judgment: false
  - id: D2
    description: "Contagem do resumo vinda do servidor cai exatamente 1 depois do PATCH FALEI (25 -> 24)"
    requirement: "API-11"
    verification:
      - kind: command
        ref: "contatos_resumo.json == {sem_retorno: 25}; contatos_resumo_apos.json == {sem_retorno: 24}"
        status: pass
    human_judgment: false
  - id: D3
    description: "Isolamento entre empresas no wire: empresa B com 1 contato real, A com count 25 e resumo 25, opções da A sem o imóvel da B, PATCH cruzado 404 nos dois sentidos, anônimo 401, page=99 404"
    requirement: "CXA-04"
    verification:
      - kind: command
        ref: "capturar_contatos (checagens internas) + assert de ids disjuntos entre contatos_outra_empresa e p1/p2"
        status: pass
    human_judgment: false

duration: 6min
completed: 2026-11-23
status: complete
---

# Phase 10 Plan 02: Captura do wire real da caixa de contatos Summary

**Grupo `contatos` na ferramenta de captura e 11 fixtures reais da caixa (25 contatos em 2 páginas, resumo 25 -> 24 após anotar, opções do filtro, PATCH 200/400/404 e a empresa B com 1 contato), capturadas do Django da `feat/APP10` contra um SQLite temporário.**

## Performance

- **Duration:** ~6 min
- **Completed:** 2026-11-23
- **Tasks:** 2
- **Files:** 12 no app (1 ferramenta + 11 fixtures); repo web sem mudança

## Accomplishments

- `enviar_patch(url, corpo, token=None, status_esperado=200)` e `capturar_contatos(base, pasta)` na ferramenta, só biblioteca padrão; grupo `contatos` em `GRUPOS` e em `--grupo`; docstring com variáveis, passos do SQLite temporário (inclusive o contato da empresa B) e a nota de taxa.
- 25 POSTs públicos reais em 3 imóveis da vitrine do corretor (ids 36, 35, 34; 3 canais), depois lista p1 (20, `next` em `http://127.0.0.1:8000/api/contatos/`) e p2 (5, `previous` preenchido, `next` nulo), seguindo o `next` real.
- Resumo `{"sem_retorno": 25}` antes e `{"sem_retorno": 24}` depois do PATCH `FALEI`; 400 do PATCH `PENDENTE` com a chave `retorno`.
- Isolamento no wire: a caixa da empresa B tem exatamente 1 contato (id 1, `DEMO-CASA-01`, `TELEFONE`), sem id em comum com p1/p2 (ids 2..26); a A segue com `count` 25; as opções do filtro da A não trazem o imóvel da B; PATCH cruzado dá 404 nos dois sentidos; sem token dá 401; `?page=99` dá 404.

## Task Commits

1. **Task 1: grupo contatos na ferramenta** - `ff6fa86` (feat)
2. **Task 2: captura real, 11 fixtures** - `4b1d2c4` (test)

**Plan metadata:** commit `docs(10-02)` (este SUMMARY + STATE + ROADMAP).

## Captura (registro de execução)

- SQLite temporário em pasta de scratchpad (caminho com letra de drive e barras normais), `DEBUG=True`, nunca o banco do `Web/.env`; `migrate`, `semear_vitrine_dev`, `seed_demo`.
- Contato da empresa B criado por `manage.py shell -c` (`Contato.objects.create` no mesmo molde de `registrar_contato`): **id 1**, empresa 2, imóvel 37 (`DEMO-CASA-01`).
- Senha do corretor demo da empresa A gerada na hora (`secrets.token_urlsafe`) e definida no SQLite lendo `os.environ`; credenciais da empresa B vieram do `seed_demo` por variável de ambiente; nada disso foi gravado em arquivo.
- Servidor em segundo plano com `ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2` e `LOGIN_TAXA_POR_EMAIL/IP=100/hour`; encerrado ao fim; porta 8000 conferida livre; **SQLite temporário e log do servidor apagados**; `git status --porcelain` do repo web vazio.
- Nenhuma fixture nova contém token ou senha (não há `login_200` novo); `grep` sem e-mail de usuário na ferramenta.

## Deviations from Plan

None - plan executed exactly as written. (A nota do planejamento sobre `CONTATO_TAXA_ANONIMA` se confirmou: a variável não existe no `settings.py` da `feat/APP10`, então não foi usada.)

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None - nenhuma superfície nova além das previstas em T-10-07, T-10-09, T-10-10 e T-10-SC (todas mitigadas: credenciais só por ambiente, SQLite temporário apagado, isolamento exigido no wire, nenhuma dependência instalada).

## Next Phase Readiness

Pronto para o 10-03 (§16 do contrato congelando estas respostas e teste de contrato). Nenhum arquivo Dart mudou neste plano (fim da onda 2, D-29). Nenhum `git push` em nenhum repositório.

## Self-Check: PASSED

- 11 fixtures e a ferramenta existem; `--help` lista `contatos`; asserts Python sobre as fixtures verdes; árvore do repo web limpa; porta 8000 livre; fixtures antigas sem diff desde `825a113`.
- Commits `ff6fa86` e `4b1d2c4` na `feat/APP10` do app; `git rev-list --count e70b498..HEAD` = 2.
