---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 04
subsystem: api
tags: [contrato, fixtures, captura, django, token-auth, acervo]

requires:
  - phase: 08-01
    provides: "acervo do corretor em GET /api/imoveis/ (envelope, 10 chaves, busca/situacao)"
  - phase: 08-03
    provides: "limite de tentativas no login e rotas eu/sair"
provides:
  - "grupo `acervo` em tool/capturar_fixtures_api.py (postar, obter com token, _credencial por ambiente, redacao do token)"
  - "11 fixtures reais em test/fixtures/api (login, eu, acervo p1/p2/busca/vazia/outra empresa, 400/401/403)"
  - "secao 14 de 01-CONTRATO-API.md (14.1 a 14.9) e exemplos acervo/eu/login"
  - "contrato_acervo_test.dart: trava de chaves exatas, exemplo = fixture e isolamento entre empresas"
affects: [08-05, 08-06, 08-07, 08-08, 08-12]

actuals:
  tokens: 14800
  tasks: 2
  commits: 2
plan_head_before: c05329dccaf1d0278415ef90091d20f2588f3b9e
plan_head_after: 9305478c87efdac1d8c962e0be1d4c1f0b433b36

tech-stack:
  added: []
  patterns:
    - "captura autenticada: credenciais so por variavel de ambiente, token real so em memoria e revogado pelo Sair no fim"
    - "fixture de login com o token trocado por 40 zeros depois de conferir o formato {token}"

key-files:
  created:
    - "test/fixtures/api/login_200.json"
    - "test/fixtures/api/erro_400_login.json"
    - "test/fixtures/api/erro_401.json"
    - "test/fixtures/api/eu_corretor.json"
    - "test/fixtures/api/eu_gestor.json"
    - "test/fixtures/api/acervo_p1.json"
    - "test/fixtures/api/acervo_p2.json"
    - "test/fixtures/api/acervo_busca.json"
    - "test/fixtures/api/acervo_situacao_vazia.json"
    - "test/fixtures/api/acervo_outra_empresa.json"
    - "test/fixtures/api/erro_403_acervo.json"
    - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/acervo.example.json"
    - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/eu.example.json"
    - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/login.example.json"
    - "test/data/contrato_acervo_test.dart"
  modified:
    - "tool/capturar_fixtures_api.py"
    - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md"

key-decisions:
  - "login_200.json versionado com o token trocado por 40 zeros pela propria ferramenta (nenhuma chave viva, mesmo de banco descartavel)"
  - "Sem fixture de 429: nao e capturavel de forma deterministica; Retry-After fica travado no Django (08-03) e no app por resposta sintetica (08-05)"
  - "Credenciais da outra empresa e do gestor lidas do seed_demo e passadas so por ambiente na captura; a ferramenta nao contem e-mail nem senha"

patterns-established:
  - "Captura autenticada: login pela API, uso da chave em memoria, Sair e conferencia do 401 seguinte no fim do grupo"

requirements-completed: [API-09]

coverage:
  - id: D1
    description: "As 11 fixtures novas sao respostas reais do Django da feat/APP08, sem senha nem token vivo"
    requirement: "API-09"
    verification:
      - kind: command
        ref: "python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo acervo (exit 0, contra SQLite temporario)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Secao 14 do contrato congela login, eu, Sair e acervo (parametros, envelope, 10 chaves, erros, riscos aceitos, sincronizacao)"
    requirement: "API-09"
    verification:
      - kind: command
        ref: "grep da secao 14 + cmp dos tres exemplos contra as fixtures"
        status: pass
    human_judgment: false
  - id: D3
    description: "contrato_acervo_test.dart falha se o Django mudar chave do envelope, do item, do eu ou do login, se exemplo divergir da fixture ou se uma empresa vir imovel da outra"
    requirement: "API-09"
    verification:
      - kind: unit
        ref: "test/data/contrato_acervo_test.dart"
        status: pass
    human_judgment: false

duration: 20 min
completed: 2026-11-21
status: complete
---

# Phase 08 Plan 04: Contrato do login e do acervo (fixtures reais) Summary

**Grupo `acervo` na ferramenta de captura gerou 11 fixtures reais do Django da `feat/APP08` (login com token redigido, eu, acervo p1/p2/busca/vazia/outra empresa, 400/401/403), o §14 do contrato congela as rotas autenticadas e `contrato_acervo_test.dart` trava chaves exatas, exemplo = fixture e isolamento entre empresas.**

## Performance

- **Duration:** 20 min
- **Completed:** 2026-11-21
- **Tasks:** 2
- **Files modified:** 17 (todos no repo do app; o repo web ficou sem mudanca)

## Accomplishments

- `tool/capturar_fixtures_api.py`: `obter` ganhou `token`, nova `postar` (JSON, 204 vira `None`), `_credencial` (variavel de ambiente ou `ErroCaptura` em portugues) e `capturar_acervo` na ordem do plano, incluindo o Sair e a conferencia do 401 seguinte; grupo `acervo` em `GRUPOS` e em `--grupo`; docstring com as seis variaveis, os passos extras e a redacao do token. Os grupos antigos nao mudaram.
- Captura real: SQLite temporario fora dos dois repos (`migrate`, `semear_vitrine_dev` e `seed_demo` coexistiram sem conflito), senha descartavel do corretor demo gerada na hora e definida via `os.environ`, servidor na 8000 so durante a captura. Resultado: p1 com 20 itens e `next` absoluto, p2 com 16 e `previous` (count 36), busca `DEV-CAMPINAS-14` com count 1, `situacao=VENDIDO` com count 0, outra empresa so com `DEMO-CASA-01`, gestor com 403.
- §14 de `01-CONTRATO-API.md` (14.1 a 14.9) e abertura do contrato atualizada; exemplos `acervo`, `eu` e `login` copiados byte a byte.
- `contrato_acervo_test.dart` (24 testes): chaves exatas do envelope, do item (10), do `eu` e do login, deny-list, tipos de `situacao`/`meu_imovel`/`na_vitrine`, paginacao (20 + 16 sem repeticao), busca, vazio e isolamento entre empresas. `flutter test`: 818 verdes (eram 794); `flutter analyze lib`: os mesmos 30 `info` pre-existentes, nenhum em arquivo meu.

## Task Commits

1. **Task 1: grupo acervo na captura e 11 fixtures reais** - `5fa2e25` (feat)
2. **Task 2: secao 14 do contrato e contrato_acervo_test** - `9305478` (feat)

**Plan metadata:** commit docs(08-04) logo apos este arquivo.

## Decisions Made

- Token de `login_200.json` trocado por 40 zeros pela ferramenta, depois de conferir `set(resposta) == {"token"}`; a chave real nunca toca o disco e e revogada pelo Sair no fim.
- Sem fixture de 429 (nao deterministico); registrado no §14.2.
- `erro_400_login.json` capturado com o e-mail do corretor demo e uma senha errada fixa; o wire real e `{"non_field_errors": ["E-mail ou senha inválidos."]}`.
- No §14.1 foi registrado que `GET /api/imoveis/` mantem a autenticacao global do DRF (token, depois sessao do painel): o app so envia token, mas a rota tambem aceita a sessao do site.

## Deviations from Plan

### Ajustes de ambiente (sem mudar o plano)

- **Caminho do repo web:** o caminho do plano (`C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui`) e obsoleto; usado `C:/projetos/imoveis-aqui` (instrucao do orquestrador) na precondicao, nos comandos de captura e nas verificacoes.
- **Precondicao e verificacoes conferidas:** `name="api-sair"` presente em `contas/api/urls.py`, web em `feat/APP08` com arvore limpa, porta 8000 livre antes e depois; as 22 fixtures antigas sem diff contra `58fcd23`.

### Observacoes

- **`--grupo todos` agora inclui `acervo`** (a ferramenta usa `list(GRUPOS)`), por isso o docstring, o `--help` e o §14.9 repetem que `todos` nunca deve ser usado para acrescentar so o acervo (reescreveria as fixtures de lista/detalhe).
- **`SyntaxWarning` de `\S` no docstring** (`Web\venv\Scripts`) e pre-existente (linha do procedimento do Windows); nao tocado.

Fora isso, plano executado como escrito. Task 2 (`tdd="true"`, plano `type: execute`): as fixtures e exemplos ja existiam quando o teste foi escrito, entao o teste passou de primeira (nao ha RED natural: ele trava o wire ja capturado).

## Issues Encountered

None.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None - a superficie nova e a do `<threat_model>` do plano (T-08-21 a T-08-23 e T-08-SC mitigadas): credenciais so por ambiente, nenhuma senha ou e-mail na ferramenta, token redigido (gate `"token": "000...0"` verificado), SQLite temporario apagado, repo web limpo, nenhuma instalacao de pacote.

## Next Phase Readiness

Os planos do app (08-05 em diante) ja podem testar contra `login_200`, `eu_corretor`/`eu_gestor`, `acervo_*`, `erro_401`, `erro_403_acervo` e `erro_400_login` pela `ApiFalsa`; o 08-06 acrescenta o parse das fixtures pelos Models em cima do `contrato_acervo_test.dart`. Pendente para o 08-12: confirmar as taxas A1 do login (registrado no §14.8).

## Self-Check: PASSED

- Commits `5fa2e25` e `9305478` existem no repo do app (`feat/APP08`); as 11 fixtures, os 3 exemplos e o teste existem; `cmp` dos exemplos contra as fixtures sai 0.
- Porta 8000 livre, SQLite temporario apagado, `git -C /c/projetos/imoveis-aqui status --porcelain` vazio.
- `flutter test`: 818 verdes; `flutter analyze lib`: 30 `info` pre-existentes, nada novo.
