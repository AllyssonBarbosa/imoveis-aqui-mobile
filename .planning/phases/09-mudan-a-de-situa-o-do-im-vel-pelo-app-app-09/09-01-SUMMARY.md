---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 01
subsystem: api
tags: [django, drf, fixtures, contrato, flutter-test, captura]

requires:
  - phase: 08-login-e-rea-do-corretor-o-acervo
    provides: fixtures do acervo (acervo_p1, acervo_busca, acervo_outra_empresa), login por API e a ferramenta de captura com o grupo acervo
provides:
  - grupo `situacao` em tool/capturar_fixtures_api.py (wire completo da mudança de situação)
  - 12 fixtures reais em test/fixtures/api/ (detalhe de gestão, POST 200, histórico, 400/403 e 404 de outra empresa)
  - "§16 de 01-CONTRATO-API.md (16.1 a 16.7) e exemplos imovel_gestao e historico_situacao"
  - test/data/contrato_gestao_situacao_test.dart (trava de contrato do wire)
affects: [09-02, 09-03, 09-04, 09-05, 09-06, 09-07, 09-08, 09-09, 09-10, 09-11, 09-12, 09-13]

plan_head_before: 1b30b8e70e2cf10aaf652d39308431bd387f4557

actuals:
  tokens: 13700
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "captura contra a origin/main por git archive em pasta temporária (clone da web nunca muda de branch)"
    - "ids das fixtures novas lidos das fixtures do acervo e conferidos ao vivo (a ferramenta para se não baterem)"

key-files:
  created:
    - test/data/contrato_gestao_situacao_test.dart
    - test/fixtures/api/imovel_gestao_disponivel.json
    - test/fixtures/api/imovel_gestao_reservado.json
    - test/fixtures/api/imovel_gestao_sem_permissao.json
    - test/fixtures/api/situacao_200.json
    - test/fixtures/api/historico_vazio.json
    - test/fixtures/api/historico_um_item.json
    - test/fixtures/api/historico_contrato.json
    - test/fixtures/api/erro_400_mesma_situacao.json
    - test/fixtures/api/erro_400_contrato_assinado.json
    - test/fixtures/api/erro_403_situacao.json
    - test/fixtures/api/erro_404_imovel.json
    - test/fixtures/api/erro_404_historico.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_gestao.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/historico_situacao.example.json
  modified:
    - tool/capturar_fixtures_api.py
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md

key-decisions:
  - "O wire da mudança de situação foi capturado do Django da origin/main 8bf4448 (git archive, SQLite temporário), sem tocar no clone da web, que seguiu na feat/APP06 com árvore limpa antes e depois"
  - "O 404 do histórico de outra empresa é idêntico ao do detalhe e ao do POST (T-09-02); o app nunca exibe o detail em inglês"
  - "Limite de 500 caracteres da observação registrado no §16.6 como D-17 (exceção à D-06); o limite no servidor (L8) fica PENDENTE WEB"

patterns-established:
  - "Teste de contrato por subconjunto de chaves quando o serializer é compartilhado com o painel (9 chaves lidas do ImovelSerializer de 26)"
  - "Exemplo do contrato = cópia byte a byte da fixture capturada, conferida por teste"

requirements-completed: [API-11]

coverage:
  - id: D1
    description: "Grupo `situacao` da ferramenta de captura: login, detalhe, POST 200, histórico, 400/403 e 404 de outra empresa (detalhe e histórico), só com credenciais por os.environ"
    requirement: "API-11"
    verification:
      - kind: other
        ref: "python3 tool/capturar_fixtures_api.py http://127.0.0.1:8000 test/fixtures/api --grupo situacao (RC=0 contra o Django da origin/main 8bf4448)"
        status: pass
      - kind: other
        ref: "gate de credenciais e tokens do <verify> (python3 -c, saída: credenciais e tokens: ok)"
        status: pass
    human_judgment: false
  - id: D2
    description: "12 fixtures reais da mudança de situação em test/fixtures/api/, com ids casados com o acervo e as 37 fixtures antigas intactas"
    requirement: "API-11"
    verification:
      - kind: unit
        ref: "test/data/contrato_gestao_situacao_test.dart#detalhe do imóvel (as 9 chaves que o app lê)"
        status: pass
      - kind: unit
        ref: "test/data/contrato_gestao_situacao_test.dart#histórico da situação"
        status: pass
      - kind: unit
        ref: "test/data/contrato_gestao_situacao_test.dart#erros capturados"
        status: pass
    human_judgment: false
  - id: D3
    description: "§16 de 01-CONTRATO-API.md congela as três rotas com os corpos reais e registra o limite de 500 da observação como D-17"
    requirement: "API-11"
    verification:
      - kind: unit
        ref: "test/data/contrato_gestao_situacao_test.dart#exemplo do contrato == resposta capturada"
        status: pass
      - kind: other
        ref: "grep do <verify> do plano: ## 16., ### 16.1 a 16.7, D-17, erro_404_historico, cmp -s dos dois exemplos"
        status: pass
    human_judgment: true
    rationale: "A prosa do §16 (ordem das decisões do servidor, tabela de respostas, riscos aceitos) é conferida por teste só nos exemplos e nas chaves; a fidelidade do texto às regras do Django depende de leitura humana."

duration: 10min
completed: 2026-11-22
status: complete
---

# Phase 9 Plan 01: Tracer do wire da mudança de situação Summary

**Wire real da mudança de situação (login, detalhe, POST 200, histórico, 400/403 e 404 de outra empresa no detalhe e no histórico) capturado do Django da origin/main em 12 fixtures, congelado no §16 do contrato e travado por teste de contrato no app**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-11-22T15:19:00Z (aproximado; o relógio de início não foi gravado no arranque)
- **Completed:** 2026-11-22T15:29:00Z
- **Tasks:** 2
- **Files modified:** 17 (13 criados nas fixtures e exemplos mais o teste, 2 editados: ferramenta e contrato)

## Accomplishments

- Grupo `situacao` na ferramenta de captura (`capturar_situacao`, `_ler_fixture`, `CHAVES_LIDAS_DO_IMOVEL`, `OBSERVACAO_DA_CAPTURA`): percorre o caminho inteiro do wire contra o Django real e PARA com mensagem em português se algum id, status ou corpo divergir (nenhuma fixture escrita à mão).
- 12 fixtures reais: `imovel_gestao_disponivel` é o id 36 (primeiro cartão de `acervo_p1`), `imovel_gestao_sem_permissao` é o id 14 (`DEV-CAMPINAS-14`, `pode_mudar_situacao` falso), `situacao_200`, `imovel_gestao_reservado` e `historico_um_item` mostram DISPONIVEL para RESERVADO, `erro_400_contrato_assinado` vem do id 37 (`DEMO-CASA-01`).
- IDOR provado ao vivo (T-09-02): o corretor da outra empresa recebe 404 `{"detail": "No Imovel matches the given query."}` no detalhe, no histórico e no POST do imóvel alvo, e os dois corpos salvos são idênticos.
- §16 do contrato (16.1 a 16.7) com os corpos reais, a ordem das decisões do servidor, o comportamento do app (achatar a mensagem, 404 com texto fixo, data no fuso do aparelho) e o limite de 500 da observação como D-17 no §16.6; abertura do contrato atualizada.
- `contrato_gestao_situacao_test.dart` (27 testes novos): 9 chaves lidas (subconjunto), 6 chaves exatas do histórico, ordem decrescente, formato dos erros, os dois 404 iguais, exemplo = fixture e ids casados com o acervo.

## Task Commits

1. **Task 1: TRACER do wire (grupo situacao + 12 fixtures)** - `d002dd5` (feat)
2. **Task 2: §16 do contrato, exemplos e teste de contrato** - `4cdf6c0` (feat)

**Plan metadata:** commit `docs(09-01)` seguinte a este arquivo.

## Files Created/Modified

- `tool/capturar_fixtures_api.py` - grupo `situacao`, docstring com o procedimento via `git archive origin/main`
- `test/fixtures/api/*.json` (12 novas) - respostas reais do Django da origin/main
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` - §16 e nota na abertura
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_gestao.example.json` e `historico_situacao.example.json` - cópias byte a byte das fixtures
- `test/data/contrato_gestao_situacao_test.dart` - trava de contrato

## Verificação da captura (D-19)

- Clone da web (`../imoveis-aqui`): branch `feat/APP06` com `status --porcelain` vazio, **antes e depois** da captura (iguais, como o plano exige).
- Servidor: código da `origin/main` (`8bf4448`) extraído por `git archive` em `mktemp -d`; as 3 fontes da API (`views.py`, `serializers.py`, `models.py`) conferidas sem mudança desde `8bf4448` antes de capturar.
- Banco: SQLite temporário na pasta de extração, criado com `migrate`, `semear_vitrine_dev` e `seed_demo` (nessa ordem); pasta apagada no fim, porta 8000 livre, variáveis `CAPTURA_*` limpas. Senha do corretor demo gerada na hora (`secrets`) e definida lendo `os.environ`.
- Gate de credenciais e tokens verde: nenhum literal de senha, nenhum token de 40 hex além dos 40 zeros do `login_200.json`.
- As 37 fixtures antigas sem diff (`git diff --diff-filter=MD 97833e4 -- test/fixtures/api` vazio).

## Decisions Made

- Seguiu-se o plano: captura só de leitura no clone, fixtures sem edição manual, 500 caracteres da observação registrados como D-17.
- `historico_contrato.json` tem um único item (a venda por contrato feita pelo `seed_demo`); o teste de ordem decrescente passa trivialmente nele, e a ordem real fica coberta pela descrição do §16.4 e pelo teste do Django do 09-02 (L6).

## Deviations from Plan

None - plan executed exactly as written.

Observação de processo (não é desvio de código): o teste do Dart da Task 2 foi escrito depois das fixtures da Task 1 existirem, então o ciclo RED não ocorreu (as fixtures e os exemplos já estavam no lugar quando o teste nasceu). O plano manda "teste primeiro", mas não há código de produção do app nesta tarefa; o teste trava fixtures e contrato, e passou de primeira.

## Issues Encountered

None. A captura passou na primeira execução (`RC=0`) e a suíte inteira ficou verde (`flutter test`: 1221 testes, linha de base 1194 mais os novos; `flutter analyze lib` limpo).

## Known Stubs

None.

## Threat Flags

None. A superfície de rede nova (as três rotas) já está no modelo de ameaças do plano (T-09-02, T-09-12, T-09-14).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Os planos do app (09-04 em diante) já têm as fixtures reais para a `ApiFalsa`; o 09-02 (worktree `feat/APP09` da web, testes L1 a L7) segue independente: este plano só leu objetos git do clone.
- Pendências registradas no §16.6: limite da observação no servidor (L8, depende da equipe web) e rotas do gestor (APP-12).

## Self-Check: PASSED

- Arquivos criados existem: ferramenta, 12 fixtures, 2 exemplos, teste e §16 (conferidos com `[ -f ]` e `grep`).
- Commits `d002dd5` e `4cdf6c0` existem (`git log`), 2 commits medidos de `plan_head_before` até HEAD.
- Verificações do plano: `<verify>` automatizados da Task 1 e da Task 2 verdes; `flutter test` inteiro e `flutter analyze lib` verdes.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
