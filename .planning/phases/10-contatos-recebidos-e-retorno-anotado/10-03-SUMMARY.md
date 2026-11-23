---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 03
subsystem: api
tags: [contrato, antidrift, contatos, isolamento, fuso, requirements]

requires:
  - phase: 10-01
    provides: "GET /api/contatos/ paginado, resumo, imoveis e PATCH com 400 na feat/APP10 do repo web"
  - phase: 10-02
    provides: "11 fixtures reais da caixa de contatos capturadas do Django"
provides:
  - "§16 de 01-CONTRATO-API.md (16.1-16.10) congelando lista, PATCH, contagem, opções, isolamento, fuso e sincronização"
  - "4 exemplos em contrato/ (contatos, contatos_resumo, contatos_imoveis, contato_patch) iguais byte a byte às fixtures"
  - "test/data/contrato_contatos_test.dart: 36 testes de chaves exatas, exemplo = fixture e isolamento no wire"
  - "CXA-01..06, API-11 e API-12 registrados (pendentes) no REQUIREMENTS e na Phase 10 do ROADMAP"
affects: [10-04, 10-05, 10-06, 10-07, 10-08, 10-09, 10-10]

commits: 3
plan_head_before: 694c0c8b68b465f8dae5f904227d1692df0f03cf
plan_head_after: c8673e1801ed705cb25f38ac6b82102df96b7746

estimate_actuals_note: "tokens = chars/4 sobre o diff do app 694c0c8..c8673e1 (45171 chars, inclui os 4 exemplos JSON e o §16)"
actuals:
  tokens: 11293
  tasks: 2
  commits: 3

tech-stack:
  added: []
  patterns:
    - "teste de contrato por fase: exemplo do contrato = fixture capturada, chaves exatas e isolamento provado no wire (padrão §14)"
    - "prova de isolamento exige a caixa da outra empresa NÃO vazia, senão a checagem de disjunção seria vácua"

key-files:
  created:
    - test/data/contrato_contatos_test.dart
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/contatos.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/contatos_resumo.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/contatos_imoveis.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/contato_patch.example.json
  modified:
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md

key-decisions:
  - "API-11 e CXA-04 ficam Pending no REQUIREMENTS: outros planos da fase (10-05, 10-10) também os declaram, e o gate de ID compartilhado (requirements.ready-ids) os bloqueia até o último plano terminar; a aceitação da Task 2 também exige Pending"
  - "Teste de contrato inclui checagens além do mínimo do plano: ordem decrescente de criado_em, PATCH 200 = mesmo contato de p1 já anotado, contagem do resumo = count da caixa (D-05), opções = imóveis dos contatos de p1+p2"

requirements-completed: []

coverage:
  - id: D1
    description: "§16 do contrato escrito a partir do wire real, com os 4 exemplos copiados byte a byte das fixtures"
    requirement: "API-11"
    verification:
      - kind: test
        ref: "test/data/contrato_contatos_test.dart#exemplo do contrato == resposta capturada"
        status: pass
      - kind: command
        ref: "grep '## 16. Caixa de contatos do corretor' + '### 16.10' + cmp -s dos 4 exemplos contra as fixtures"
        status: pass
    human_judgment: false
  - id: D2
    description: "Chaves exatas do envelope, do item (12), do resumo e das opções do imóvel travadas no app"
    requirement: "API-11"
    verification:
      - kind: test
        ref: "test/data/contrato_contatos_test.dart#lista da caixa / anotar o retorno / contagem / opções do filtro"
        status: pass
    human_judgment: false
  - id: D3
    description: "Isolamento entre empresas provado no wire: caixa da empresa B não vazia, disjunta da A, fora das opções e da contagem da A"
    requirement: "CXA-04"
    verification:
      - kind: test
        ref: "test/data/contrato_contatos_test.dart#isolamento entre empresas no wire (CXA-04)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Os 8 IDs da fase registrados (pendentes) no REQUIREMENTS com rastreabilidade e Coverage 65, e listados na Phase 10 do ROADMAP"
    requirement: "API-11"
    verification:
      - kind: command
        ref: "loop grep dos 8 IDs em '- [ ]' e '| Phase 10 | Pending |' + grep da linha Requirements do ROADMAP"
        status: pass
    human_judgment: false

duration: 6min
completed: 2026-11-23
status: complete
---

# Phase 10 Plan 03: Contrato §16 da caixa de contatos Summary

**§16 do contrato congelando a caixa de contatos (lista de 12 chaves, PATCH com 400 para corpo vazio, contagem, opções, fuso de São Paulo e isolamento por empresa), 4 exemplos copiados do wire real e 36 testes de contrato no app que provam o isolamento com a empresa B não vazia.**

## Performance

- **Duration:** ~6 min (2026-11-23T22:46:36Z a 22:52:37Z)
- **Tasks:** 2
- **Files:** 8 (1 teste, 4 exemplos, contrato, REQUIREMENTS e ROADMAP); repo web sem mudança

## Accomplishments

- `## 16. Caixa de contatos do corretor (Fase 10)` com 16.1 a 16.10 no padrão do §14: rotas e autenticação (401/403/405, gestor passa mas o app não oferece a entrada, barra final obrigatória), lista (`page_size = 20`, `imovel`/`de`/`ate`/`page`, ordem `-criado_em, -id`, tabela das 12 chaves, erros 400 como string e 404 de página), PATCH (valores anotáveis, 200 com o item, 400 para `PENDENTE`/inválido/vazio/sem `retorno` com "Este campo é obrigatório.", 404 cruzado, `retorno_em` novo a cada anotação), contagem sem filtros (D-05), opções do imóvel, isolamento com a evidência da empresa B, fuso (dia de São Paulo, hora local do aparelho como risco A3), comportamento no app, riscos aceitos e sincronização. Parágrafo de abertura da Fase 10 no topo.
- `contrato/contatos.example.json`, `contatos_resumo.example.json`, `contatos_imoveis.example.json` e `contato_patch.example.json` copiados byte a byte (`cmp -s` sai 0).
- `contrato_contatos_test.dart` (36 testes, RED visto com os 4 exemplos faltando e depois verde): exemplo = fixture, envelope e 12 chaves em 5 fixtures de lista e no PATCH 200, canal/retorno válidos, datas ISO-8601 com offset, `next` de mesma origem da `urlBaseApiFalsa`, p1+p2 sem repetição, resumo 25 -> 24 e igual ao `count`, opções por `codigo` e iguais aos imóveis dos contatos, e o grupo de isolamento (B não vazia, ids e imóveis disjuntos da A, contagem da A sem o contato da B).
- REQUIREMENTS: seção "Caixa de contatos (APP10)" com CXA-01..06, API-11 e API-12 em `- [ ]`, 8 linhas `Phase 10 | Pending` na rastreabilidade, Coverage em 65 e "Last updated". ROADMAP: linha `**Requirements**:` da Phase 10 com os 8 IDs, nada mais mudou.

## Task Commits

1. **Task 1 (RED): teste de contrato** - `11723e2` (test)
2. **Task 1 (GREEN): §16 e 4 exemplos** - `25140c9` (feat)
3. **Task 2: IDs no REQUIREMENTS e no ROADMAP** - `c8673e1` (docs)

**Plan metadata:** commit `docs(10-03)` (este SUMMARY + STATE + ROADMAP).

## Verification

- `flutter test test/data/contrato_contatos_test.dart test/data/contrato_acervo_test.dart test/data/contrato_lista_test.dart`: 82 verdes.
- Gate da onda 3 (D-29): `flutter analyze lib --no-fatal-infos` sai 0, 0 erros/warnings, 0 infos fora dos 41 `deprecated_member_use` de `material.dart`; `flutter test` inteiro: **1230 verdes** (1194 + 36 novos).
- Os dois verificadores automáticos das tarefas (greps do §16, `cmp -s` dos exemplos, loop dos 8 IDs) passaram.

## Deviations from Plan

None - plan executed exactly as written. (Dois detalhes de execução, sem desvio de regra: o `01-CONTRATO-API.md` e o `REQUIREMENTS.md` usam CRLF, então as inserções foram feitas por script preservando CRLF; e o TDD do plano foi feito como RED `test(10-03)` seguido do GREEN `feat(10-03)`.)

## Issues Encountered

None.

## Known Stubs

None.

## Threat Flags

None - nenhuma superfície nova; T-10-08 (drift Django x app) mitigado pelo `contrato_contatos_test.dart` e T-10-SC sem instalação de dependência.

## Next Phase Readiness

Pronto para o 10-04 e a onda de Models/Repository do app: o wire está congelado e travado por teste (o 10-05 acrescenta o grupo "Models leem toda fixture" a este arquivo). `API-11` e `CXA-04` seguem `Pending` de propósito: o gate de ID compartilhado os bloqueia até os planos 10-05 e 10-10 terminarem. Nenhum `git push` em nenhum repositório.

## Self-Check: PASSED

- Os 5 arquivos criados existem; `01-CONTRATO-API.md` tem `## 16.` e `### 16.1` a `### 16.10`; os 4 exemplos são idênticos às fixtures.
- Commits `11723e2`, `25140c9` e `c8673e1` presentes na `feat/APP10`; `git rev-list --count 694c0c8..HEAD` = 3.
