---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 02
subsystem: testing
tags: [django, drf, testes-de-caracterizacao, idor, worktree, situacao]

requires:
  - phase: 08-login-e-rea-do-corretor-o-acervo
    provides: rotas autenticadas do corretor na API (login, acervo) e o isolamento por empresa
provides:
  - "worktree local ../imoveis-aqui-APP09 com a branch feat/APP09 criada da origin/main (8bf4448)"
  - "AppSituacaoApiTests (9 testes) travando 401, 403, 404 e 400 das rotas de situação e histórico do corretor"
  - "TravaDaSituacaoManualTests.test_api_do_corretor_recusa_com_contrato_assinado (400 com contrato assinado na rota do corretor)"
affects: [09-03, 09-10, 09-12, 09-13]

plan_head_before: 8bf4448eb36060daf4b9d91cb0a9c2f2a3322aca

actuals:
  tokens: 2300
  tasks: 2
  commits: 1

tech-stack:
  added: []
  patterns:
    - "testes de caracterização: o comportamento já existe no servidor, então o teste nasce verde e trava o contrato"
    - "worktree separado para a branch da web; o clone compartilhado nunca troca de branch"

key-files:
  created: []
  modified:
    - /Users/georgelucas/Documents/projeto-mobile/imoveis-aqui-APP09/Web/imoveis/tests.py
    - /Users/georgelucas/Documents/projeto-mobile/imoveis-aqui-APP09/Web/contratos/tests.py

key-decisions:
  - "Nenhum código de produção da web mudou: todos os testes de caracterização passaram de primeira, então o servidor da origin/main já se comporta como a pesquisa mediu"
  - "O teste de IDOR cria uma mudança real de situação dos dois lados antes de pedir o histórico, para o 404 não poder ser explicado por 'histórico vazio', e confere que o texto da observação não vaza no corpo"

patterns-established:
  - "403 antes de 400: colega recebe 403 com corpo inválido, provado com três corpos (situação inválida, vazio e observação nula)"

requirements-completed: [API-12]

coverage:
  - id: D1
    description: "Worktree feat/APP09 da origin/main (8bf4448), sem push, com o clone ../imoveis-aqui ainda na feat/APP06"
    requirement: "API-12"
    verification:
      - kind: other
        ref: "gate final do plano: branch feat/APP09, árvore limpa, 8bf4448 ancestral, diff contra origin/main só nos 2 arquivos de teste, sem refs/remotes/origin/feat/APP09, clone na feat/APP06"
        status: pass
    human_judgment: false
  - id: D2
    description: "Servidor recusa por teste: 401 sem token nas três rotas, 404 de histórico e detalhe de outra empresa (T-09-02), 403 do colega antes de qualquer 400, 403 do gestor na rota do corretor, colega lê o histórico"
    requirement: "SIT-06"
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#AppSituacaoApiTests.test_historico_e_detalhe_de_outra_empresa_dao_404"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AppSituacaoApiTests.test_sem_token_da_401_nas_tres_rotas"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AppSituacaoApiTests.test_colega_com_corpo_invalido_recebe_403_e_nao_400"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AppSituacaoApiTests.test_gestor_na_rota_do_corretor_recebe_403"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AppSituacaoApiTests.test_colega_le_o_historico"
        status: pass
    human_judgment: false
  - id: D3
    description: "Recusas de validação e de negócio e ordem do histórico: mesma situação, situação inválida/ausente, observação nula, contrato assinado, histórico mais recente primeiro com 6 chaves"
    requirement: "API-12"
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#AppSituacaoApiTests.test_mesma_situacao_da_400_com_a_mensagem"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AppSituacaoApiTests.test_situacao_invalida_ou_ausente_da_400_na_chave_situacao"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AppSituacaoApiTests.test_observacao_nula_da_400_na_chave_observacao"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#AppSituacaoApiTests.test_historico_mais_recente_primeiro_com_o_nome"
        status: pass
      - kind: unit
        ref: "Web/contratos/tests.py#TravaDaSituacaoManualTests.test_api_do_corretor_recusa_com_contrato_assinado"
        status: pass
    human_judgment: false

duration: 5min
completed: 2026-11-22
status: complete
---

# Phase 9 Plan 02: Travas de teste das rotas de situação do corretor (web) Summary

**Dez testes de caracterização no Django (401, 403 antes de 400, 404 de outra empresa no histórico e no detalhe, 400 de mesma situação, situação inválida/ausente, observação nula e contrato assinado, ordem do histórico), num worktree `feat/APP09` da `origin/main` com 1 commit local, sem mudar código de produção nem dar push**

## Performance

- **Duration:** ~5 min de execução (houve uma pausa antes do commit, ver "Issues Encountered")
- **Started:** 2026-11-22T15:29:51Z
- **Completed:** 2026-11-22T15:35:00Z (aproximado)
- **Tasks:** 2
- **Files modified:** 2 (na web; este SUMMARY e os docs de controle vão no repo do app)

## Accomplishments

- Worktree `/Users/georgelucas/Documents/projeto-mobile/imoveis-aqui-APP09` na `feat/APP09`, criado de `origin/main` (`8bf4448`). O clone `../imoveis-aqui` continuou na `feat/APP06` do começo ao fim; nada foi empurrado.
- `AppSituacaoApiTests` (9 métodos) cobre as lacunas L1 e L3 a L7 da pesquisa. O teste de IDOR (T-09-02) roda sozinho e passa: corretor da outra empresa recebe 404 no histórico e no detalhe, nos dois sentidos, sem vazar o texto da observação.
- `test_api_do_corretor_recusa_com_contrato_assinado` (L2) prova que o corretor responsável também é barrado com 400 na chave `situacao` quando há contrato assinado, e que a casa continua VENDIDO.
- Suíte Django inteira: linha de base 743, depois 753 (10 novos), `OK`, rodada de novo sobre o commit.

## Task Commits

Os dois testes entraram num único commit local na web, como o plano manda (a Task 1 não tem commit próprio; "vai na Task 2"):

1. **Task 1 + Task 2: worktree, travas de acesso, travas de validação e de contrato assinado** - `c02a506` (test), na `feat/APP09` do worktree da web

**Plan metadata:** commit `docs(09-02)` seguinte a este arquivo, no repo do app.

## Files Created/Modified

- `Web/imoveis/tests.py` (worktree da web) - classe `AppSituacaoApiTests`, +152 linhas, logo antes de `AcervoApiTests`
- `Web/contratos/tests.py` (worktree da web) - `test_api_do_corretor_recusa_com_contrato_assinado`, +12 linhas

## Decisions Made

- Seguiu-se o plano: só testes, nenhum arquivo de produção. Como todos os testes de caracterização passaram de primeira, a regra de "parar e reportar" não foi acionada.
- Nota de execução: antes do fetch, as três fontes da API (`views.py`, `serializers.py`, `models.py`) foram conferidas sem diferença entre `8bf4448` e `origin/main`, e o `fetch` funcionou (sem falha de rede).

## Deviations from Plan

None - o código dos testes foi escrito como o plano descreve.

Observações de processo, que não são desvios de código:

- A Task 1 e a Task 2 foram escritas juntas e rodadas em seguida (primeiro o teste de IDOR sozinho, depois as duas classes, depois a suíte inteira). O plano já previa um único commit.
- O trailer de atribuição do commit `c02a506` diz "Claude Opus 5.5", e não o que o ambiente indica ("Claude Sonnet 5.5"). O commit foi feito pelo coordenador. Não reescrevi o commit.
- `requirements-completed` lista só `API-12`. O plano declara `[API-12, SIT-06]`, mas o SIT-06 também depende da UI (botão só com `pode_mudar_situacao`, no 09-10, 09-12 e 09-13); este plano entrega só a prova no servidor. O SIT-06 fica pendente no REQUIREMENTS.md até esses planos.

## Issues Encountered

- O commit na web ficou parado por uma rodada: a autorização do usuário para o commit chegou só por mensagem de outro agente, e a regra do projeto web ("nenhum commit sem o OK do usuário", D-16) pede o OK do próprio usuário. O coordenador então fez o commit `c02a506` e o gate final foi conferido de novo por mim: branch `feat/APP09`, árvore limpa, `8bf4448` ancestral, diff contra `origin/main` só nos 2 arquivos de teste, nenhuma `refs/remotes/origin/feat/APP09`, clone na `feat/APP06`, 1 commit medido de `8bf4448` até HEAD.

## Known Stubs

None.

## Threat Flags

None. As três rotas já estão no modelo de ameaças do plano (T-09-01, T-09-02, T-09-15, T-09-16, T-09-SC); nenhuma superfície nova foi criada.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- O servidor já tem as rotas do corretor travadas por teste; o app (09-03 em diante) pode depender de 401/403/404/400 como medidos.
- Pendências fora desta fase: o `max_length` da observação no serializer (L8) segue como pergunta à equipe web; o push e o PR da `feat/APP09` da web ficam para quando o usuário autorizar.

## Self-Check: PASSED

- Arquivos de teste existem no worktree; `AppSituacaoApiTests` e `test_api_do_corretor_recusa_com_contrato_assinado` presentes (testes rodados: 14 nas duas classes, 753 na suíte).
- Commit `c02a506` existe na `feat/APP09` do worktree (`git log`), e `git rev-list --count 8bf4448..HEAD` dá 1.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
