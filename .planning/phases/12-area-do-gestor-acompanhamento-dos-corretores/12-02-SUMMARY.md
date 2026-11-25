---
phase: 12-area-do-gestor-acompanhamento-dos-corretores
plan: 02
subsystem: testing
tags: [fixtures, captura, python, django, relatorios, gestor, isolamento]

requires:
  - phase: 12
    provides: "12-01: rotas acervo-por-corretor e mudancas-situacao no Django feat/APP12 (repo web, 5763b90)"
  - phase: 10
    provides: "grupo contatos da ferramenta de captura e as rotas de contato/PATCH que o grupo gestor reaproveita"
provides:
  - "grupo `gestor` em tool/capturar_fixtures_api.py (capturar_gestor + 5 constantes + checagens de soma, janela, papel e isolamento)"
  - "10 fixtures reais em test/fixtures/api/ (4 relatórios do gestor, 400 de período, 400 de dias, 403, e os 2 relatórios da empresa B)"
  - "prova no wire de que a janela de 7 dias exclui a mudança antiga (10 dias) e de que ?dias=30 a inclui"
affects: [12-03 contrato §18, 12-04, 12-05, 12-06, 12-07, 12-08, 12-09]

# Medido: git rev-list --count ${PLAN_HEAD_BEFORE}..HEAD no repo do app (ledger gsd-plan-head-before-12-02)
commits: 3
plan_head_before: d1df11dae94fabf2f9ab1a4ab738bcfe99ff4bc5
plan_head_after: 18cb39dd745c74cacb0be48a5e0ace9c20ce9659

estimate_actuals_note: "tokens = chars/4 sobre o diff do app d1df11d..18cb39d (28871 chars), ferramenta Python + 10 fixtures JSON"
actuals:
  tokens: 7218
  tasks: 2
  commits: 3

tech-stack:
  added: []
  patterns:
    - "Grupo de captura que GRAVA no banco só roda no SQLite temporário, numa porta que não é a do servidor do desenvolvedor (8012, nunca 8000)"
    - "A ferramenta confere os números do servidor contra o acervo lido ao vivo (Counter das situações, soma das linhas = total) antes de salvar a fixture"
    - "Isolamento provado com a empresa B tendo dado de verdade (imóvel e mudança) e interseção vazia de corretor_id/imovel_id"

key-files:
  created:
    - test/fixtures/api/relatorio_acervo.json
    - test/fixtures/api/relatorio_acervo_por_corretor.json
    - test/fixtures/api/relatorio_contatos.json
    - test/fixtures/api/relatorio_contatos_periodo.json
    - test/fixtures/api/erro_400_relatorio_contatos.json
    - test/fixtures/api/relatorio_mudancas.json
    - test/fixtures/api/erro_400_dias.json
    - test/fixtures/api/erro_403_relatorio.json
    - test/fixtures/api/relatorio_acervo_por_corretor_outra_empresa.json
    - test/fixtures/api/relatorio_mudancas_outra_empresa.json
  modified:
    - tool/capturar_fixtures_api.py

key-decisions:
  - "Porta 8012 para o servidor temporário (a 8000 é do runserver do Allysson contra o Postgres dele e nunca foi tocada); as respostas dos relatórios não têm URL absoluta, então a porta não entra nas fixtures"
  - "A captura não exige `canais_contato` no detalhe público: o Django da feat/APP12 (base origin/main) não traz esse campo (ele é da feat/APP06); o 201 do POST de contato já prova o canal"
  - "Credenciais só em variáveis de ambiente de um script fora do repo (senhas geradas com secrets, e-mails `.invalid`); nada de e-mail, senha ou token em arquivo versionado"

patterns-established:
  - "Mudança antiga criada só no SQLite temporário (update de alterado_em para 10 dias atrás) para que a janela possa falhar nos dois sentidos"
  - "Linha do corretor demo achada pelo id do detalhe público, nunca por ser a maior da lista"

requirements-completed: [API-16, GES-05, GES-06]

coverage:
  - id: D1
    description: "Ferramenta de captura com o grupo gestor: 4 relatórios, 400/403/401 e a empresa B, com as checagens de soma, janela, papel e isolamento"
    requirement: "API-16"
    verification:
      - kind: other
        ref: "python3 tool/capturar_fixtures_api.py --help (lista gestor) + greps da Task 1 (VERIFY1_OK)"
        status: pass
      - kind: other
        ref: "python3 tool/capturar_fixtures_api.py http://127.0.0.1:8012 test/fixtures/api --grupo gestor (CAPTURA_EXIT=0)"
        status: pass
    human_judgment: false
  - id: D2
    description: "10 fixtures reais do Django da feat/APP12: totais por situação, acervo por corretor (zero e desativado), contatos por corretor (linha da empresa e período vazio), mudanças de 7 dias com 9 chaves, 400/403"
    requirement: "GES-05"
    verification:
      - kind: other
        ref: "verificação automatizada da Task 2 (VERIFY_A_OK: JSON válido, soma = total, zero/desativado/empresa, dias 7 com 2 itens)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Isolamento e papel no wire: corretor recebe 403 e anônimo 401 nas 4 rotas; a empresa B tem imóvel e mudança próprios sem interseção com a A"
    requirement: "GES-06"
    verification:
      - kind: other
        ref: "capturar_gestor passos 15 e 16 (exceção ErroCaptura se vazar) + VERIFY_A_OK (interseção vazia)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Repo web intocado, porta 8012 livre, SQLite e log apagados, as 60 fixtures antigas sem diff"
    verification:
      - kind: other
        ref: "VERIFY_B_OK (git -C web status vazio; sem listener em 8012; git diff --diff-filter=MD 439746a -- test/fixtures/api vazio)"
        status: pass
    human_judgment: false

# Metrics
duration: ~8min (cronometrado no turno final; houve uma pausa por limite de uso no meio)
completed: 2026-11-25
status: complete
---

# Phase 12 Plan 02: Captura das fixtures reais da Área do gestor Summary

**Grupo `gestor` na ferramenta de captura e 10 fixtures reais do Django da `feat/APP12` (acervo, acervo por corretor, contatos, mudanças de 7 dias, 400/403 e a empresa B), com soma, janela, papel e isolamento conferidos no wire.**

## Performance

- **Duration:** ~8 min de relógio no turno final (a execução foi interrompida pelo limite de uso e retomada; a pausa não entra na conta)
- **Started:** 2026-11-25T20:46:00Z
- **Completed:** 2026-11-25T20:54:00Z
- **Tasks:** 2
- **Files modified:** 11 (1 ferramenta + 10 fixtures novas)

## Accomplishments

- `capturar_gestor` faz login de 3 usuários, lê o acervo inteiro, cria 4 contatos públicos, anota 1 como FALEI, muda X para RESERVADO e Y para VENDIDO, e só então captura os 4 relatórios do gestor da empresa A. Cada número do servidor é conferido contra o acervo lido ao vivo antes de a fixture ser salva.
- Números da captura (ids do SQLite temporário): `totais` = DISPONIVEL 33, RESERVADO 2, VENDIDO 1, ALUGADO 0, `total` 36; acervo por corretor = corretor demo (id 1) 35, desativado (id 2, `ativo: false`) 1, "Corretor Sem Acervo" (id 7, ativo) 0; contatos = total 4, pendentes 3, com a linha da empresa (`corretor_id` nulo, total 1); janeiro de 2024 = total 0 sem linha da empresa.
- Janela provada nos dois sentidos: o padrão de 7 dias traz só `[Y, X]` (35 VENDIDO, depois 36 RESERVADO, `-03:00`), e `?dias=30` traz também Z (32), a mudança de 10 dias atrás criada só no SQLite temporário.
- Isolamento: o corretor recebe 403 e o anônimo 401 nas 4 rotas; a empresa B tem de verdade 1 imóvel (`DEMO-CASA-01`, id 37) e 1 mudança, o corretor dela (id 5) não aparece na A, e o relatório de contatos dela dá 0.

## Task Commits

1. **Task 1: Grupo gestor na ferramenta de captura** - `ce98173` (feat)
2. **Task 1 (ajuste): captura não exige `canais_contato`** - `50dbefa` (fix)
3. **Task 2: 10 fixtures reais dos relatórios do gestor** - `18cb39d` (test)

**Plan metadata:** commit `docs(12-02)` (este SUMMARY e depois STATE/ROADMAP/REQUIREMENTS)

## Files Created/Modified

- `tool/capturar_fixtures_api.py` - `capturar_gestor`, `_ler_acervo_inteiro`, `_exigir_linhas`, `ROTAS_DO_GESTOR`, `CHAVES_LINHA_ACERVO_CORRETOR`, `CHAVES_LINHA_CONTATOS_CORRETOR`, `CHAVES_MUDANCA_RECENTE`, `OBSERVACAO_GESTOR`; grupo `gestor` em `GRUPOS` e `--grupo`; docstring com as 6 variáveis, os passos extras no SQLite, a ordem e a porta 8012
- `test/fixtures/api/relatorio_acervo.json`, `relatorio_acervo_por_corretor.json`, `relatorio_contatos.json`, `relatorio_contatos_periodo.json`, `relatorio_mudancas.json` - os 4 relatórios do gestor da empresa A
- `test/fixtures/api/erro_400_relatorio_contatos.json`, `erro_400_dias.json`, `erro_403_relatorio.json` - os erros
- `test/fixtures/api/relatorio_acervo_por_corretor_outra_empresa.json`, `relatorio_mudancas_outra_empresa.json` - evidência no wire do isolamento

## Decisions Made

- Servidor temporário em `127.0.0.1:8012`, SQLite temporário com `DATABASE_URL` explícito (o `Web/.env` e o Postgres do Allysson não foram tocados), com `LOGIN_TAXA_POR_EMAIL`/`LOGIN_TAXA_POR_IP` altos só para os vários logins da captura.
- Preparo do SQLite num único `manage.py shell` lido de arquivo temporário fora dos repositórios, com tudo vindo de `os.environ`: senha descartável do corretor demo, gestor da empresa A (`.invalid`), corretor ativo sem imóvel e a mudança antiga de 10 dias. Nenhum seed nem arquivo do repo web mudou.
- Usuário do gestor da empresa B (e-mail e senha do `seed_demo.py`) lido do arquivo do web por `grep` dentro do script de captura e exportado só no ambiente do processo.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] A captura exigia `canais_contato` no detalhe público, campo que o Django da `feat/APP12` não tem**
- **Found during:** Task 2 (primeira execução da captura: `KeyError: 'canais_contato'` no detalhe de W)
- **Issue:** o plano assumia `canais_contato` com `WHATSAPP` no detalhe público de W. O `canais_contato` é da `feat/APP06` e não está na base `origin/main` (`e2d1fa0`) da `feat/APP12` do web (`grep canais_contato` no web, fora de testes, não acha nada). As fixtures antigas têm o campo porque foram capturadas de um servidor com a APP06. O `corretor_responsavel` nulo e o `POST .../contato/` existem normalmente.
- **Fix:** removi a exigência de `canais_contato` do `capturar_gestor` (com comentário explicando) e deixei o 201 do `POST` de contato WHATSAPP em W como a prova de que o canal é aceito. A leitura direta de `detalhe_w["corretor_responsavel"] is None` ficou como o plano manda.
- **Files modified:** `tool/capturar_fixtures_api.py`
- **Verification:** segunda execução da captura, `CAPTURA_EXIT=0`, 10 fixtures gravadas, as duas verificações automatizadas da Task 2 verdes.
- **Committed in:** `50dbefa`

---

**Total deviations:** 1 auto-fixed (1 bug de premissa do plano)
**Impact on plan:** nenhum no resultado; as 10 fixtures e as checagens de soma, janela, papel e isolamento ficaram como especificado. O custo foi um commit a mais e uma segunda subida do servidor temporário.

## Issues Encountered

- A primeira execução da captura parou no `KeyError` acima, depois de já ter feito `migrate`, `semear_vitrine_dev`, `seed_demo` e o preparo; o script apaga o SQLite no `trap` de saída, então a segunda execução recomeçou de um banco novo (ids determinísticos iguais).
- O comando de edição em heredoc grande foi recusado pelo parser do shell; o conteúdo foi escrito com a ferramenta de escrita num arquivo auxiliar do scratchpad (fora do repositório) e aplicado por um script curto.

## Known Stubs

Nenhum. Nada na ferramenta nem nas fixtures é placeholder; os arquivos auxiliares (script de captura e de preparo) vivem só no scratchpad e não foram versionados.

## Threat Flags

Nenhum. T-12-07 (credenciais), T-12-08 (porta 8000 e Postgres) e T-12-09 (isolamento) mitigados: `grep` por e-mails `@demo.com`/`@example.com`/`@captura.invalid`, `SenhaForte` e tokens de 40 caracteres hexadecimais não acha nada na ferramenta nem nas fixtures; a porta 8000 não foi usada nem sondada; o repo web terminou com `status --porcelain` vazio em `5763b90`; T-12-SC sem instalação de pacote.

## User Setup Required

None - no external service configuration required. O `runserver` e o Postgres do Allysson não foram tocados; porta 8012 livre ao final (sem listener), SQLite temporário e log apagados, variáveis `CAPTURA_*` descartadas com o processo.

## Next Phase Readiness

- O 12-03 pode congelar o §18 do contrato com estas fixtures como exemplos (D-27) e criar os IDs `GES-01..GES-06`/`API-15`/`API-16` no `REQUIREMENTS.md` (se eles ainda não existirem, o `requirements mark-complete` deste plano não tem o que marcar).
- Nenhum arquivo Dart mudou neste plano; o gate do app (`flutter analyze`/`flutter test`) roda no fim da onda 3 (12-03), como o plano manda.
- Sem bloqueios.

## Self-Check: PASSED

- Arquivos: as 10 fixtures e `tool/capturar_fixtures_api.py` existem (`test -s`); os 3 commits `ce98173`, `50dbefa` e `18cb39d` são ancestrais de `HEAD`.
- Verificações do plano: Task 1 (`VERIFY1_OK`), Task 2 parte A (`VERIFY_A_OK`) e parte B (`VERIFY_B_OK`: web limpo, 8012 sem listener, 60 fixtures antigas sem diff).
- Critérios de aceitação: `--help` lista `gestor`; `def capturar_gestor(`, `ROTAS_DO_GESTOR`, `CHAVES_MUDANCA_RECENTE`, `OBSERVACAO_GESTOR` e `"gestor": capturar_gestor` presentes; nenhum e-mail de usuário nem senha no arquivo.

---
*Phase: 12-area-do-gestor-acompanhamento-dos-corretores*
*Completed: 2026-11-25*
