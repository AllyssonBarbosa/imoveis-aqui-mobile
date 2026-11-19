---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 06
subsystem: testing
tags: [fixtures, python-stdlib, captura, api-publica, wire]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-05 (semear_vitrine_dev: 36 imóveis, Campinas com 24) e rotas públicas de 05-01/05-02/05-04"
provides:
  - "tool/capturar_fixtures_api.py: captura reexecutável (stdlib) do grupo lista; 05-07 acrescenta o grupo detalhe"
  - "8 fixtures de wire reais em test/fixtures/api/ (cidades, lista p1/p2, CASA,LOTE, vazia, bairros, características, 400 de natureza)"
affects: [05-07, 05-08, 05-09, 05-10, 05-11, 05-12, 05-13, 05-14, 05-15, 05-18]

plan_head_before: e48b67a4e3fb3888da71faf3cf94585c0106b9fc
actuals:
  tokens: 14000
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Fixture de wire nunca é escrita à mão: vem de uma execução do tool/capturar_fixtures_api.py contra a API semeada num SQLite temporário"
    - "JSON salvo como recebido (ensure_ascii=False, indent=2, quebra de linha final)"

key-files:
  created:
    - tool/capturar_fixtures_api.py
    - test/fixtures/api/cidades.json
    - test/fixtures/api/lista_campinas_p1.json
    - test/fixtures/api/lista_campinas_p2.json
    - test/fixtures/api/lista_campinas_casa_lote.json
    - test/fixtures/api/lista_campinas_vazia.json
    - test/fixtures/api/bairros_campinas.json
    - test/fixtures/api/caracteristicas.json
    - test/fixtures/api/erro_400_natureza.json
  modified: []

key-decisions:
  - "Script único com o grupo lista completo já na Task 1; as duas tasks compartilharam uma só execução de captura (SQLite novo), garantindo que os 8 arquivos saem do mesmo banco"
  - "O `next` da p1 é absoluto em http://127.0.0.1:8000/..., então os testes do app que consomem essas fixtures devem tratar a base como a do servidor de captura"

requirements-completed: []  # API-03 só fecha em 05-18 (orientação do coordenador)

coverage:
  - id: D1
    description: "Cidades atendidas e primeira página real de Campinas (20 itens, 4 naturezas, next absoluto) capturadas da API semeada"
    requirement: API-03
    verification:
      - kind: other
        ref: "python3 -m json.tool + verificação de forma inline do plano (Task 1)"
        status: pass
    human_judgment: false
  - id: D2
    description: "p2 (previous aponta para a p1), lista CASA,LOTE só com as duas naturezas, lista vazia, bairros (strings), características ({id, nome}) e 400 de natureza com a chave natureza"
    requirement: API-03
    verification:
      - kind: other
        ref: "verificação de forma inline do plano (Task 2)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Captura nunca toca o banco do Web/.env; servidor temporário derrubado; repo da API inalterado"
    verification:
      - kind: other
        ref: "nc -z 127.0.0.1 8000 (porta livre) e git status --porcelain da API idêntico ao de antes"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 06: Captura de fixtures reais de lista e opções Summary

**`tool/capturar_fixtures_api.py` (Python stdlib, reexecutável) captura da API semeada, num SQLite temporário, as 8 respostas reais de lista/opções que o app consome: cidades, Campinas p1/p2, CASA,LOTE, vazia, bairros, características e o 400 de natureza.**

## Dados da captura (para os planos seguintes)

- **Campinas = id 1** (`{"id": 1, "nome": "Campinas", "uf": "SP"}`); count da lista = 24.
- **p1**: 20 itens, ids 24 a 5 (mais recentes primeiro), `next` = `http://127.0.0.1:8000/api/publico/cidades/1/imoveis/?page=2`, `previous` null, 4 naturezas.
- **p2**: 4 itens, ids 4, 3, 2, 1; `previous` = `http://127.0.0.1:8000/api/publico/cidades/1/imoveis/`, `next` null.
- **400**: `{"natureza": "Opções válidas: CASA, TERRENO, APARTAMENTO, LOTE."}`.
- Os ids são determinísticos para um banco novo semeado pelo mesmo comando (05-07 deve reusar o procedimento).
- **Caminhos temporários usados** (todos removidos ao final): SQLite `$TMPDIR/imoveis_captura_05.sqlite3` (`$TMPDIR` = `/var/folders/ds/45_3bzq97zv_58cpf89qf1cr0000gn/T/`), log e pid do runserver no mesmo `$TMPDIR`. Servidor em `127.0.0.1:8000`, parado; porta livre no fim.

## Task Commits (app, branch feat/APP05, política app-a)

1. **Task 1 (tracer)**: `491790d` test(05-06): captura de cidades e lista real — script + cidades.json + lista_campinas_p1.json
2. **Task 2**: `64766cc` test(05-06): captura das formas de lista e opções — p2, casa_lote, vazia, bairros, características, erro_400

Repo da API: zero commits e nenhuma mudança (git status idêntico ao de antes da captura). Nunca push. O `Web/.env` não foi lido, impresso nem editado; o banco Postgres de dev (porta 5433) não foi tocado.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: reexecutado e verde (forma de cidades/p1, JSON válido, porta livre), seguiu para a Task 2.

## Deviations from Plan

**1. [Organização, não de regra] Script completo já na Task 1.** O plano pedia o script da Task 1 só com cidades+p1 e a extensão na Task 2. Como a Task 2 exige uma única execução fresca para os 8 arquivos, escrevi o grupo `lista` inteiro de uma vez e executei a captura uma vez só; os commits foram separados por arquivos (script + 2 fixtures na Task 1; 6 fixtures restantes na Task 2). Resultado final idêntico ao planejado; o commit da Task 1 já contém o script completo.

Nenhuma outra: sem auth gates, sem correções de regra 1-3.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. T-05-06-01 (banco do Web/.env nunca usado), T-05-06-03 (servidor parado, porta 8000 livre) mitigados e verificados; T-05-06-02 aceito (dados fictícios do seed).

## Verificação

- 8 fixtures: `python3 -m json.tool` OK; as duas verificações de forma inline do plano OK.
- `grep -nE "^import (requests|httpx)|^from (requests|httpx)"` no script: vazio; `ls test/fixtures/api/` lista só os 8 arquivos.
- `nc -z 127.0.0.1 8000` falha (porta livre). Nenhum formatador rodado.
- API-03 e API-07 NÃO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Existem: tool/capturar_fixtures_api.py e os 8 JSON em test/fixtures/api/.
- Commits 491790d e 64766cc existem em feat/APP05.
