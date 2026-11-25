---
phase: 12-area-do-gestor-acompanhamento-dos-corretores
plan: 03
subsystem: testing
tags: [contrato, api, fixtures, relatorios, gestor, isolamento, requisitos]

requires:
  - phase: 12
    provides: "12-02: 10 fixtures reais da Área do gestor (4 relatórios, 400/403 e a empresa B) e a ferramenta de captura com o grupo gestor"
  - phase: 10
    provides: "molde do §17 e de contrato_contatos_test.dart"
provides:
  - "§18 de 01-CONTRATO-API.md (18.1 a 18.10) e o parágrafo de abertura da Fase 12"
  - "4 exemplos em contrato/ idênticos byte a byte às fixtures capturadas"
  - "test/data/contrato_area_gestor_test.dart (28 testes: chaves lidas, exemplo = fixture, soma = total, isolamento A x B no wire)"
  - "seção Área do gestor (APP12) no REQUIREMENTS com GES-01..06, API-15 e API-16 (82 no total) e a linha Requirements da Phase 12 no ROADMAP"
affects: [12-04, 12-05, 12-06, 12-07, 12-08, 12-09]

# Medido: git rev-list --count ${PLAN_HEAD_BEFORE}..HEAD (ledger gsd-plan-head-before-12-03), antes do commit do SUMMARY
commits: 3
plan_head_before: 523ad9ecd80c913e569d7aa3b6db724c4acf7777
plan_head_after: 27df3ebce7184c67d79be524d74114c25c480ca1

estimate_actuals_note: "tokens = chars/4 sobre o diff do plano (§18 ~20 mil chars, teste ~14 mil, requisitos ~5 mil, exemplos ~3 mil)"
actuals:
  tokens: 10500
  tasks: 2
  commits: 3

tech-stack:
  added: []
  patterns:
    - "Teste de contrato com exemplo = fixture byte a byte, conjuntos const de chaves e prova de isolamento com a empresa B não vazia (molde da Fase 10)"
    - "Seção do contrato escrita a partir do que o Django entrega, com tabela fixture -> exemplo e travas nos dois repositórios"

key-files:
  created:
    - test/data/contrato_area_gestor_test.dart
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/relatorio_acervo.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/relatorio_acervo_por_corretor.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/relatorio_contatos.example.json
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/relatorio_mudancas.example.json
  modified:
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md

key-decisions:
  - "O §18 documenta que o app lê só `totais` e `total` do acervo (D-09) e que `situacoes`/`linhas` existem e não são lidas; o teste trava só as chaves lidas e a soma"
  - "A linha da empresa nos contatos (corretor_id nulo) fica documentada com o texto fixo do app, nunca o do servidor (D-17)"
  - "Os 6 itens de ordem (acervo por total e nome, contatos por total e nome, mudanças por -alterado_em) foram escritos como observados nas fixtures reais"

patterns-established:
  - "Isolamento no wire por interseção vazia de corretor_id (acervo) e imovel_id (mudanças), com a empresa B obrigatoriamente não vazia"

requirements-completed: [API-16, GES-06]

coverage:
  - id: D1
    description: "§18 do contrato congela as 4 rotas da Área do gestor (parâmetros, campos lidos, 400/401/403, isolamento, fuso, janela, riscos e sincronização)"
    requirement: "API-16"
    verification:
      - kind: other
        ref: "greps da Task 1 (GREP_OK: heading ## 18, ### 18.10, texto fixo do 403, 4 cmp -s exemplo x fixture) e 10 subseções ### 18.N"
        status: pass
    human_judgment: false
  - id: D2
    description: "Teste de contrato trava chaves lidas, exemplo = fixture, soma do acervo por corretor = total e isolamento entre empresas no wire"
    requirement: "API-16"
    verification:
      - kind: test
        ref: "flutter test test/data/contrato_area_gestor_test.dart (28 testes) + contrato_contatos_test + contrato_gestao_situacao_test: All tests passed (103)"
        status: pass
    human_judgment: false
  - id: D3
    description: "GES-06 no wire: o corretor recebe 403 nas 4 rotas e nenhum corretor/imóvel da empresa B aparece nos relatórios da A"
    requirement: "GES-06"
    verification:
      - kind: test
        ref: "test/data/contrato_area_gestor_test.dart#isolamento entre empresas no wire (critério 6)"
        status: pass
    human_judgment: false
  - id: D4
    description: "IDs GES-01..06, API-15 e API-16 registrados (pendentes, 82 no total), nota no LOG-01 e Requirements da Phase 12"
    verification:
      - kind: other
        ref: "VERIFY2_OK (8 linhas - [ ], 8 linhas Phase 12 | Pending, Coverage 82, LOG-01 com Phase 12, linha Requirements do ROADMAP)"
        status: pass
    human_judgment: false

# Metrics
duration: ~5 min
completed: 2026-11-25
status: complete
---

# Phase 12 Plan 03: Contrato da Área do gestor (§18) Summary

**§18 do contrato com as 4 rotas do gestor, 4 exemplos idênticos às fixtures reais e `contrato_area_gestor_test.dart` travando chaves lidas, soma do acervo por corretor e isolamento entre empresas no wire; IDs GES-01..06, API-15 e API-16 registrados.**

## Performance

- **Duration:** ~5 min (289 s de relógio até o gate final)
- **Started:** 2026-11-25T20:56:39Z
- **Completed:** 2026-11-25T21:01:28Z (gate; o SUMMARY e o STATE vêm depois)
- **Tasks:** 2
- **Files modified:** 8 (5 criados, 3 alterados)

## Accomplishments

- `## 18. Área do gestor (Fase 12)` com 18.1 a 18.10 e o parágrafo de abertura da Fase 12: rotas e `EhGestor`, totais (o app lê só `totais`/`total`), acervo por corretor (4 chaves, quem aparece, ordem, soma = total), contatos por corretor (5 chaves, linha da empresa, `de`/`ate` ecoados), mudanças (9 chaves, `?dias=` 1 a 365, padrão no servidor, janela provada nos dois sentidos), isolamento com a evidência da empresa B, fuso e dia de São Paulo, comportamento no app (401, 403, falha de formato), riscos aceitos e sincronização.
- Os 4 `*.example.json` copiados byte a byte das fixtures (`cmp -s` sai 0).
- `contrato_area_gestor_test.dart` com 28 testes: exemplo = fixture (4), totais (3), acervo por corretor (7), contatos (6), mudanças (7), erros (3) e isolamento (4). Falha se o Django mudar uma chave lida, se um exemplo divergir, se a soma deixar de fechar, se os relatórios da B vierem vazios ou se tiverem corretor ou imóvel da A.
- `REQUIREMENTS.md`: seção "Área do gestor (APP12)" com os 8 IDs em `- [ ]`, 8 linhas `Phase 12 | Pending` na rastreabilidade, Coverage em 82, nota de promoção no `LOG-01`; `ROADMAP.md`: linha `**Requirements**:` da Phase 12 com os 8 IDs.
- Gate da onda 3 verde: `flutter analyze lib --no-fatal-infos` sem erro nem warning e sem info fora do baseline (53 infos `deprecated_member_use` do `material.dart`, as mesmas de antes); `flutter test` inteiro: **1775 testes, All tests passed** (baseline 1743 do plano; os 28 novos deste plano e o restante vindo das ondas anteriores).

## Task Commits

1. **Task 1 RED: teste de contrato** - `038366d` (test)
2. **Task 1 GREEN: §18 e exemplos** - `00f6292` (feat)
3. **Task 2: IDs no REQUIREMENTS e ROADMAP** - `27df3eb` (docs)

**Plan metadata:** commit `docs(12-03)` (este SUMMARY, STATE e ROADMAP)

## TDD Gate Compliance

- **RED (`038366d`):** `flutter test test/data/contrato_area_gestor_test.dart` terminou com exit diferente de zero: 24 passam e **4 falham, exatamente os 4 testes "exemplo = fixture"**, com `PathNotFoundException` ao abrir `contrato/relatorio_*.example.json` (os exemplos ainda não existiam). Avaliação semântica: o alvo executou e falhou pelo motivo planejado (exemplo ausente), não por erro de sintaxe, import ou fixture. Os outros 24 testes passam desde o RED porque descrevem o wire que o 12-02 já capturou, e não código novo: o plano não tem Model nem implementação Dart a escrever. O `gsd_run check tdd-red-evidence` não foi usado: `flutter test` não emite nenhum dos formatos que o classificador aceita (TAP, JUnit, swift-testing, unittest, go test) e `workflow.tdd_mode` não está ligado em `config.json`.
- **GREEN (`00f6292`):** exemplos copiados e §18 escrito; os 28 testes passam, e `contrato_contatos_test.dart` e `contrato_gestao_situacao_test.dart` continuam passando (103 no total nos três arquivos).
- **REFACTOR:** nenhum (não houve o que limpar).

## Files Created/Modified

- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` - parágrafo de abertura da Fase 12 e `## 18. Área do gestor (Fase 12)`
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/relatorio_acervo.example.json`, `relatorio_acervo_por_corretor.example.json`, `relatorio_contatos.example.json`, `relatorio_mudancas.example.json` - exemplos copiados das fixtures
- `test/data/contrato_area_gestor_test.dart` - teste de contrato (constantes `_pastaContrato`, `_situacoes`, `_chavesAcervoPorCorretor`, `_chavesLinhaAcervoCorretor`, `_chavesLinhaContatosCorretor`, `_chavesMudancas`, `_chavesMudancaRecente`)
- `.planning/REQUIREMENTS.md` - seção APP12, rastreabilidade, Coverage 82, nota no LOG-01, Last updated
- `.planning/ROADMAP.md` - só a linha `**Requirements**:` da Phase 12 (o contador "2/9 plans executed" da Phase 12 é atualizado pelo `roadmap update-plan-progress` no fechamento)

## Decisions Made

- O teste trava só o que o app lê no acervo (`totais` com as 4 situações inteiras e `total` = soma); `situacoes` e `linhas` só têm a presença conferida, como o D-09 manda.
- A ordem do acervo por corretor e dos contatos foi documentada como "mais primeiro e, no empate, por nome", porque é o que as fixtures reais mostram (35, 1, 0; e, no período vazio, "Corretor Sem Acervo" antes de "Corretor Vitrine Demo"). O teste trava só a ordem não crescente dos totais do acervo.
- A frase "administrador → 403" do §18.1 segue o plano e o `EhGestor` do servidor; a captura do 12-02 só exercitou o corretor (403) e o anônimo (401). A cobertura do administrador fica nas classes do Django.

## Deviations from Plan

None - plan executed exactly as written.

O único desvio de forma foi o commit da Task 2 ter saído pelo helper `gsd-tools query commit`, que não acrescenta o trailer `Co-Authored-By`; o commit foi emendado (ainda local, sem push) para incluí-lo, sem mudar o conteúdo (`1161c9a` virou `27df3eb`).

## Issues Encountered

None.

## Known Stubs

Nenhum. Nada neste plano é placeholder; o teste ainda não tem Models porque o plano 12-05 os testa contra estas mesmas fixtures (decisão do plano, não um stub).

## Threat Flags

Nenhum. T-12-10 (drift entre o Django e o app) mitigado pelo teste de contrato; T-12-SC sem instalação de pacote. Nenhuma superfície nova: o plano só escreve documentação, um teste e cópias de fixtures já varridas no 12-02 (sem e-mail, senha nem token).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Os planos 12-04 em diante podem citar o §18 e as 10 fixtures; o 12-05 testa os Models contra elas.
- Os 8 IDs seguem `Pending` no REQUIREMENTS até os planos de UI e fechamento da fase. Este plano declara `requirements: [API-16, GES-06]` no frontmatter; como API-16 e GES-06 também aparecem em outros planos da fase, o `requirements.ready-ids` decide quais viram `Complete` agora.
- Sem bloqueios.

## Self-Check: PASSED

- Arquivos: o teste, os 4 exemplos e o SUMMARY existem; `01-CONTRATO-API.md` tem `## 18. Área do gestor (Fase 12)` e 10 subseções `### 18.N`.
- Commits `038366d`, `00f6292` e `27df3eb` são ancestrais de `HEAD`.
- Verificação do plano: `flutter test` dos 3 arquivos de contrato verde (103), `cmp -s` dos 4 exemplos, VERIFY2_OK, `flutter analyze lib --no-fatal-infos` sem erro, warning nem info novo, e `flutter test` inteiro com 1775 testes verdes.

---
*Phase: 12-area-do-gestor-acompanhamento-dos-corretores*
*Completed: 2026-11-25*
