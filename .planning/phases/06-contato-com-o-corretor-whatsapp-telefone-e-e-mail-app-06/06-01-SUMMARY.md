---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 01
subsystem: api
tags: [django, drf, git-merge, vitrine, contatos, canais_contato, na_vitrine]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "imoveis_da_vitrine() sobre na_vitrine (publicado + DISPONIVEL + empresa ativa) e a política de git opcao-a + app-a"
provides:
  - "Política de git da fase registrada (API opcao-a, app app-a), lida por todos os planos seguintes"
  - "Branch local feat/APP06 na API = main + merge de origin/WEB-11 (W11), commit de merge 7d4f5cd, sem push"
  - "POST /api/publico/imoveis/<id>/contato/ sem token: 201 {canal, link}, grava Contato; imóvel RESERVADO responde 404 (ContatoSituacaoTests)"
  - "canais_contato no detalhe público (só nomes, ordem fixa WHATSAPP/TELEFONE/EMAIL, fallback da empresa no servidor) + VitrineCanaisContatoTests"
affects: [06-02, 06-03, 06-04, 06-05, 06-06, 06-07, 06-08, 06-09, 06-10]

plan_head_before: 2e63ca01db516d48a54e16f92425438e0c2daa03
actuals:
  tokens: 4500   # chars/4 sobre o diff realizado (merge dos 3 arquivos em conflito + 5 arquivos do trabalho da fase na API)
  tasks: 3
  commits: 0     # MEDIDO no repo do app (git rev-list plan_head_before..HEAD, antes do commit do SUMMARY): plano sem código no app. Repo da API: 1 commit local (merge 7d4f5cd); o resto fica sem commit por opcao-a.

tech-stack:
  added: []
  patterns:
    - "Contrato público expõe só NOMES dos canais; número, e-mail e link (com código interno) saem apenas no POST de contato"
    - "Regra de quais canais existem vive só no servidor (canais_disponiveis da W11), o app não deduz"
    - "Mutation check no teste de consultas: sem select_related('empresa') o teste de corretor desativado falha (4 != 3)"

key-files:
  created: []
  modified:
    - ../imoveis-aqui/README.md
    - ../imoveis-aqui/Web/static/css/painel.css
    - ../imoveis-aqui/Web/templates/contas/painel_home.html
    - ../imoveis-aqui/Web/contatos/tests.py
    - ../imoveis-aqui/Web/imoveis/api/serializers.py
    - ../imoveis-aqui/Web/imoveis/api/views.py
    - ../imoveis-aqui/Web/imoveis/tests.py

key-decisions:
  - "Git (Task 1, respondida pelo usuário via orquestrador): API opcao-a, app app-a"
  - "painel.css do merge reconstruído como a versão completa da main + bloco 'Caixa de contatos (W11)' completo da WEB-11 (os hunks do git estavam intercalados); inclui também a regra .retorno-contato button da WEB-11"
  - "get_canais_contato devolve str(canal) de canais_disponiveis(imovel); import de contatos.servicos no topo do serializer, sem import circular"
  - "select_related do detalhe ganha 'empresa' (imovel.empresa, relação diferente de corretor_responsavel__empresa) para o fallback do corretor desativado não custar consulta"

requirements-completed: [APP06-API-1, APP06-C4, APP06-C5, APP06-C6]

coverage:
  - id: D1
    description: "feat/APP06 da API = main + merge de origin/WEB-11, 3 conflitos aditivos resolvidos mantendo os dois lados, sem push, origin/WEB-11 intocada"
    requirement: APP06-API-1
    verification:
      - kind: integration
        ref: "manage.py test --noinput (427 testes, SQLite em memória) + manage.py check + makemigrations --check --dry-run"
        status: pass
    human_judgment: false
  - id: D2
    description: "POST público de contato sem token grava Contato e devolve {canal, link}; imóvel reservado dá 404 sem gravar"
    requirement: APP06-C4
    verification:
      - kind: unit
        ref: "contatos.tests.ContatoSituacaoTests.test_post_publico_sem_token_grava_e_devolve_canal_e_link / test_imovel_reservado_nao_recebe_contato"
        status: pass
    human_judgment: false
  - id: D3
    description: "canais_contato no detalhe: só nomes, ordem fixa, fallback da empresa, [] sem destino, ausente na lista"
    requirement: APP06-C5
    verification:
      - kind: unit
        ref: "imoveis.tests.VitrineCanaisContatoTests (6 testes) + VitrineAllowlistExataTests.CHAVES_DETALHE"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-16
status: complete
---

# Phase 6 Plan 01: Base da API da Fase 6 Summary

**API local `feat/APP06` = main + W11 (contatos), com o POST público de contato provado sobre a regra de vitrine e `canais_contato` (só nomes dos canais) no detalhe público.**

## Escolhas de git da Task 1 (política de git de toda a fase)

Respondidas pelo usuário (via orquestrador) antes de qualquer operação git:

| Repositório | Opção | Significado |
|-------------|-------|-------------|
| API (`../imoveis-aqui`) | **opcao-a** | Criar `feat/APP06` a partir da `main`, mesclar `origin/WEB-11`, commitar localmente SÓ o commit de merge. Toda outra mudança da API na fase (06-01 e 06-02) fica sem commit no working tree. Nunca push. |
| App (este repo) | **app-a** | Um commit local por task na `feat/APP06`, nunca push. |

Push, PR e merge na main ficam fora das duas escolhas: nunca acontecem nesta fase.

**Heads antes do merge** (após `git fetch origin`): `main` = `origin/main` = `71ffeedb6788449539f55f5569944ee2470449ee`; `origin/WEB-11` = `f0b6690e4d864f460cf97717d9c00e77ff7b2efd` (inalterada depois). WEB-11 não estava na main (`merge-base --is-ancestor` falso). O conjunto de conflitos continuou exatamente README.md, painel.css e painel_home.html.

**Commit de merge (API):** `7d4f5cd8b5c2d91452f2db5431c4c09993aae043` ("merge: WEB-11 (contatos da W11) na main para a APP06"). `git branch -r --contains HEAD` vazio (nunca enviado).

**Estado do working tree da API ao fim do 06-01 (sem commit, por opcao-a):** README.md, Web/contatos/tests.py, Web/imoveis/api/serializers.py, Web/imoveis/api/views.py, Web/imoveis/tests.py.

## Performance

- **Duration:** ~25 min
- **Started:** 2026-11-17T00:34Z (primeiro comando do executor)
- **Tasks:** 3 (1 checkpoint de decisão já respondido, 1 tracer, 1 TDD)
- **Files modified:** 7 (todos no repo da API)

## Accomplishments

- Branch `feat/APP06` na API criada da main com merge de `origin/WEB-11`; os 3 conflitos aditivos resolvidos mantendo os dois lados (README com "Seed de desenvolvimento" e "Contatos (W11)"; painel_home com "Imóveis da empresa" e "Contatos da empresa"; painel.css com main completa + bloco da W11, chaves balanceadas 79/79).
- Tracer provado: `ContatoSituacaoTests` mostra que o POST anônimo da W11 devolve 201 `{canal, link}` (link `tel:+55...`), grava Contato com imóvel, corretor e canal corretos, e que imóvel RESERVADO recebe 404 sem gravar nada (regra na_vitrine da main protege o POST da W11).
- `canais_contato` no detalhe (`ImovelVitrineDetalheSerializer`): `["WHATSAPP","TELEFONE","EMAIL"]` para corretor ativo completo; `["WHATSAPP","EMAIL"]` com corretor desativado e empresa sem telefone; `[]` sem destino; ausente da lista (D-04). `CHAVES_ITEM` intocada, só `CHAVES_DETALHE` ganhou a chave.
- Número de consultas do detalhe não muda com corretor desativado (`select_related("empresa")`); `test_detalhe_do_lote_tem_numero_fixo_de_consultas` segue em 3.

## Task Commits

API (`../imoveis-aqui`, opcao-a):

1. **Task 2 (merge)** — `7d4f5cd` merge: WEB-11 (contatos da W11) na main para a APP06
2. **Task 2 (ContatoSituacaoTests)** e **Task 3 (canais_contato)** — sem commit, por opcao-a (working tree)

App (app-a): nenhum commit de código neste plano (sem código no app). O commit do SUMMARY/STATE é de documentação.

## Verificação

- `manage.py test --noinput` (SQLite em memória, `DATABASE_URL="sqlite://:memory:"`): **427 testes, OK** (419 após o merge, +2 ContatoSituacaoTests, +6 VitrineCanaisContatoTests).
- `manage.py check`: limpo. `makemigrations --check --dry-run`: "No changes detected".
- Mutation check: removendo `"empresa"` do `select_related`, `test_corretor_desativado_nao_aumenta_as_consultas` falha (4 != 3); restaurado.
- Sem marcador de conflito nos 3 arquivos; painel.css com `.filtros-acoes`, `.filtros-contatos`, `.retorno-contato`, `.texto-suave`.
- `Web/.env` nunca lido; `.gitignore` intocado.

## Deviations from Plan

None - plan executed exactly as written. Observação: o painel.css reconstruído também inclui a regra `.retorno-contato button` da WEB-11 (o plano citava o bloco "até `.retorno-contato select`"); mantida para que toda regra dos dois lados sobreviva (decisão D-12: manter os dois lados).

## Issues Encountered

- A primeira tentativa de mutation check com `sed -i` falhou no BSD sed do macOS (sem alteração no arquivo); repetida com Python e arquivo restaurado e conferido por `git diff`.

## Known Stubs

None.

## Threat Flags

None - nenhuma superfície nova além da planejada; `canais_contato` expõe só os três nomes de canal (T-06-01-01 mitigada por `test_canais_sao_so_nomes`), o POST de contato passa por `imoveis_da_vitrine()` (T-06-01-02, `test_imovel_reservado_nao_recebe_contato`).

## Recado para a Palloma (pronto para enviar — o agente NÃO envia)

> Palloma, a WEB-11 (contatos da W11) foi mesclada localmente na minha branch `feat/APP06` do repo da API, em cima da main (71ffeed), para o app de contato poder usar o POST público. Nada foi enviado por push e a `origin/WEB-11` não foi alterada. Quando puder, vale mergear a WEB-11 na main. O conflito de merge foi só aditivo (README, painel.css e painel_home.html: mantive os dois lados).

O usuário envia este recado no checkpoint do 06-10 (Task 2), onde fica registrado se foi enviado ou não.

## Next Phase Readiness

- 06-02 (throttle do POST e `%20` no `link_whatsapp`) parte de uma API verde (427 testes) na `feat/APP06`; mudanças dela ficam sem commit (opcao-a).
- 06-03 (captura de fixtures) pode subir servidor temporário a partir desta branch: `POST /api/publico/imoveis/{id}/contato/` e `canais_contato` existem.
- Todo plano seguinte lê a política de git desta seção: API opcao-a (só o commit de merge), app app-a (um commit local por task, nunca push).

## Self-Check: PASSED

- `7d4f5cd` existe no repo da API (merge, feat/APP06); branch remota não contém HEAD; `origin/WEB-11` = f0b6690.
- Arquivos modificados presentes: serializers.py (`def get_canais_contato`), tests.py (`class VitrineCanaisContatoTests`), contatos/tests.py (`class ContatoSituacaoTests`), README (`canais_contato`).
