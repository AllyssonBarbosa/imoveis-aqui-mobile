---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 07
subsystem: testing
tags: [fixtures, python-stdlib, captura, api-publica, detalhe, wire]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-06 (tool/capturar_fixtures_api.py grupo lista + 8 fixtures de lista) e 05-05 (seed com casos de borda)"
provides:
  - "tool/capturar_fixtures_api.py: grupo detalhe e todos = lista + detalhe"
  - "7 fixtures de detalhe reais em test/fixtures/api/ (casa, apartamento, terreno, lote, sem fotos, sem corretor, 404)"
affects: [05-14, 05-16, 05-17, 05-18]

plan_head_before: da9dba32d9d7ab54300fc7f30b81d964985f7f29
actuals:
  tokens: 12000
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Detalhes capturados de itens da lista ao vivo (mesmos ids das fixtures de lista, ids determinísticos num SQLite novo)"

key-files:
  created:
    - test/fixtures/api/detalhe_casa.json
    - test/fixtures/api/detalhe_apartamento.json
    - test/fixtures/api/detalhe_terreno.json
    - test/fixtures/api/detalhe_lote.json
    - test/fixtures/api/detalhe_sem_fotos.json
    - test/fixtures/api/detalhe_sem_corretor.json
    - test/fixtures/api/erro_404_detalhe.json
  modified:
    - tool/capturar_fixtures_api.py

key-decisions:
  - "O grupo detalhe grava só arquivos de detalhe e nunca reescreve as fixtures de lista do 05-06 (git status confirmou as 8 de lista intactas)"
  - "Uma única execução de captura (SQLite novo) para os 7 arquivos; commits separados por arquivos (script + 4 naturezas na Task 1; 3 bordas na Task 2)"

requirements-completed: []  # API-07 só fecha em 05-18 (orientação do coordenador)

coverage:
  - id: D1
    description: "Detalhe real de CASA, APARTAMENTO (com prédio), TERRENO e LOTE (com quadra/loteamento), cada um com fotos e corretor, e cada id presente na lista capturada com a mesma natureza"
    requirement: API-07
    verification:
      - kind: other
        ref: "três verificações inline do plano (Task 1): JSON válido, blocos/fotos/corretor, consistência com p1/p2"
        status: pass
    human_judgment: false
  - id: D2
    description: "Bordas do detalhe: sem fotos (lista com foto_capa null), corretor_responsavel null e 404 com chave detail"
    requirement: API-07
    verification:
      - kind: other
        ref: "verificação inline do plano (Task 2)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Captura nunca toca o banco do Web/.env; servidor temporário derrubado; repo da API inalterado"
    verification:
      - kind: other
        ref: "nc -z 127.0.0.1 8000 (porta livre) e git status --porcelain da API idêntico ao de antes"
        status: pass
    human_judgment: false

duration: 8min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 07: Captura de fixtures reais de detalhe Summary

**O grupo `detalhe` de `tool/capturar_fixtures_api.py` captura da API semeada (SQLite temporário) 7 respostas reais: detalhe de casa, apartamento, terreno e lote, o sem fotos, o sem corretor e o 404 fora da vitrine, todos consistentes com as listas do 05-06.**

## Ids usados em cada fixture (Campinas = id 1)

| Fixture | Id do imóvel | Observação |
|---|---|---|
| detalhe_casa.json | 21 | primeiro CASA da p1 com foto_capa |
| detalhe_apartamento.json | 22 | primeiro APARTAMENTO da p1 com foto_capa; tem prédio |
| detalhe_terreno.json | 23 | primeiro TERRENO da p1 com foto_capa |
| detalhe_lote.json | 24 | primeiro LOTE da p1 com foto_capa; tem quadra e loteamento |
| detalhe_sem_fotos.json | 11 | TERRENO DEV-CAMPINAS-11; `fotos: []`, foto_capa null na lista |
| detalhe_sem_corretor.json | 14 | APARTAMENTO DEV-CAMPINAS-14, corretor inativo; `corretor_responsavel: null` |
| erro_404_detalhe.json | 999999 | `{"detail": "No Imovel matches the given query."}` |

- Os ids batem com os da p1/p2 do 05-06 (p1: 24 a 5; p2: 4 a 1), como previsto (ids determinísticos num banco novo).
- Caminhos temporários usados (todos removidos): `$TMPDIR/imoveis_captura_05.sqlite3`, log e pid do runserver em `$TMPDIR`. Servidor em 127.0.0.1:8000, parado; porta livre no fim.
- O seed gera fotos em `Web/media/` do repo da API (gitignorado, comportamento já existente do seed); não aparece no `git status` da API.

## Task Commits (app, branch feat/APP05, política app-a)

1. **Task 1 (tracer)**: `892b260` test(05-07): captura dos detalhes por natureza - script + 4 detalhes
2. **Task 2**: `74fd2df` test(05-07): captura das bordas do detalhe - sem fotos, sem corretor, 404

Repo da API: zero commits e nenhuma mudança (git status idêntico ao de antes). Nunca push. O `Web/.env` não foi lido, impresso nem editado; o banco Postgres de dev (5433) não foi tocado.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: reexecutado e verde (JSON válido, blocos/fotos/corretor, consistência com a lista, porta livre); seguiu para a Task 2.

## Deviations from Plan

**1. [Organização, não de regra] Uma só execução de captura.** Como no 05-06, o script completo (todas as 7 capturas) foi escrito antes de rodar e a captura rodou uma vez só (SQLite novo), em vez de uma execução por task; os commits foram separados por arquivos. O commit da Task 1 já contém o script completo. Resultado final idêntico ao planejado.

Nenhuma outra: sem auth gates, sem correções de regra 1-3.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. T-05-07-02 (banco do Web/.env nunca usado) e T-05-07-03 (servidor parado, porta 8000 livre) mitigados e verificados; T-05-07-01 aceito (campos de contato do corretor são dados fictícios do seed).

## Verificação

- 7 fixtures: `python3 -m json.tool` OK; as três verificações inline de forma/consistência do plano OK; pasta com 15 arquivos.
- Fixtures de lista e cidades do 05-06 inalteradas (git status).
- `grep` de imports fora da stdlib no script: vazio. Nenhum formatador rodado.
- `nc -z 127.0.0.1 8000` falha (porta livre).
- API-03 e API-07 NÃO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Existem: os 7 JSON de detalhe em test/fixtures/api/ e tool/capturar_fixtures_api.py com o grupo detalhe.
- Commits 892b260 e 74fd2df existem em feat/APP05.
