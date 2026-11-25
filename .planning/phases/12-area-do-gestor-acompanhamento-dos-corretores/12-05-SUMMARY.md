---
phase: 12-area-do-gestor-acompanhamento-dos-corretores
plan: 05
subsystem: data
tags: [freezed, json_serializable, models, area-do-gestor, relatorios, fixtures]

requires:
  - phase: 12-03
    provides: wire do §18 congelado e fixtures reais dos 4 relatórios (inclusive as da outra empresa)
  - phase: 12-04
    provides: entidades TotaisPorSituacao, AcervoPorCorretor, ContatosPorCorretor e MudancasRecentes
provides:
  - TotaisPorSituacaoModel (só totais/total, 4 situações obrigatórias)
  - AcervoPorCorretorModel e LinhaAcervoCorretorModel
  - ContatosPorCorretorModel e LinhaContatosCorretorModel (linha da empresa sem texto do servidor)
  - MudancasRecentesModel e MudancaRecenteModel (situação estrita, alterado_em em UTC)
  - test/data/modelos_area_gestor_test.dart lendo as 7 fixtures de relatório
affects: [12-06, 12-07, 12-08, 12-09]

actuals:
  tokens: 24800
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Model de transporte freezed com paraEntidade(): toda tradução de código e recusa de wire malformado na camada de dados (D-24)"
    - "Casos malformados nascem de cópias das fixtures reais (Map.of), nunca de JSON escrito à mão (D-27)"

key-files:
  created:
    - lib/data/models/totais_por_situacao_model.dart
    - lib/data/models/totais_por_situacao_model.freezed.dart
    - lib/data/models/totais_por_situacao_model.g.dart
    - lib/data/models/acervo_por_corretor_model.dart
    - lib/data/models/acervo_por_corretor_model.freezed.dart
    - lib/data/models/acervo_por_corretor_model.g.dart
    - lib/data/models/contatos_por_corretor_model.dart
    - lib/data/models/contatos_por_corretor_model.freezed.dart
    - lib/data/models/contatos_por_corretor_model.g.dart
    - lib/data/models/mudancas_recentes_model.dart
    - lib/data/models/mudancas_recentes_model.freezed.dart
    - lib/data/models/mudancas_recentes_model.g.dart
    - test/data/modelos_area_gestor_test.dart
  modified: []

key-decisions:
  - "Situação desconhecida ou faltando é FormatException na camada de dados, nunca valor padrão (D-24, T-12-12)"
  - "A linha de contatos da empresa (corretor_id nulo) descarta corretor e ativo do servidor no próprio Model (D-17, T-12-13)"
  - "Chaves do wire que a tela não usa (situacoes, linhas, de, ate, desde) são ignoradas na desserialização"

requirements-completed: [GES-01, GES-02, GES-03, GES-04, API-16]

coverage:
  - id: D1
    description: "TotaisPorSituacaoModel lê totais/total de relatorio_acervo.json e recusa situação desconhecida ou faltando"
    requirement: GES-01
    verification:
      - kind: unit
        ref: "test/data/modelos_area_gestor_test.dart#TotaisPorSituacaoModel"
        status: pass
    human_judgment: false
  - id: D2
    description: "AcervoPorCorretorModel lê as duas fixtures de acervo por corretor na ordem do wire"
    requirement: GES-02
    verification:
      - kind: unit
        ref: "test/data/modelos_area_gestor_test.dart#AcervoPorCorretorModel"
        status: pass
    human_judgment: false
  - id: D3
    description: "ContatosPorCorretorModel lê as fixtures de contatos e a linha da empresa não carrega o texto do servidor"
    requirement: GES-03
    verification:
      - kind: unit
        ref: "test/data/modelos_area_gestor_test.dart#ContatosPorCorretorModel"
        status: pass
    human_judgment: false
  - id: D4
    description: "MudancasRecentesModel lê as fixtures de mudanças, recusa situação desconhecida e entrega alteradoEm em UTC"
    requirement: GES-04
    verification:
      - kind: unit
        ref: "test/data/modelos_area_gestor_test.dart#MudancasRecentesModel"
        status: pass
    human_judgment: false

duration: 4min
completed: 2026-11-25
status: complete
plan_head_before: 6c8c75a9486c8606772f63d8e1938948a6fb7b16
plan_head_after: c31d2a26ddbe12598d9a30dfe3606dcba156d8fd
commits: 4
---

# Phase 12 Plan 05: Models da Área do gestor Summary

**Quatro Models freezed/json_serializable que leem as 7 fixtures reais dos relatórios do gestor, traduzem situação com recusa estrita (FormatException) e entregam as entidades do 12-04 sem recalcular nada.**

## Performance

- **Duração:** 4 min
- **Início:** 2026-11-25T21:12:12Z
- **Fim:** 2026-11-25T21:16:28Z
- **Tarefas:** 2
- **Arquivos criados:** 13 (4 Models, 8 gerados, 1 teste)

## Accomplishments

- `TotaisPorSituacaoModel` lê só `totais` e `total` de `GET /api/relatorios/acervo/`; chave desconhecida (`EM_OBRA`) ou situação faltando (`ALUGADO`) lança `FormatException`; o `total` é o do servidor, sem soma.
- `AcervoPorCorretorModel` e `LinhaAcervoCorretorModel` mapeiam o acervo por corretor na ordem do wire (a fixture da empresa A traz uma linha desativada e uma com total 0); linha sem `corretor_id` lança.
- `ContatosPorCorretorModel` e `LinhaContatosCorretorModel` descartam `corretor` e `ativo` quando `corretor_id` é nulo (linha da empresa, `daEmpresa` verdadeiro) mesmo com o servidor mandando texto (D-17).
- `MudancasRecentesModel` e `MudancaRecenteModel` traduzem `situacao_anterior` e `situacao_nova` por `situacaoDoCodigo` e lançam `FormatException` quando vier desconhecida (D-24); `alterado_em` vira UTC; `alterado_em` inválido também lança.
- `test/data/modelos_area_gestor_test.dart`: 20 testes sobre as 7 fixtures (inclusive as 2 da outra empresa e a do período).

## Task Commits

1. **Task 1: totais por situação e acervo por corretor** (TDD)
   - RED `82ed320` (test) — o teste não carregava, Models inexistentes
   - GREEN `32f8f5b` (feat)
2. **Task 2: contatos por corretor e mudanças recentes** (TDD)
   - RED `8f845c5` (test) — o teste não carregava, Models inexistentes
   - GREEN `c31d2a2` (feat)

**Metadados do plano:** commit `docs(12-05)` seguinte a este SUMMARY.

## Files Created/Modified

- `lib/data/models/totais_por_situacao_model.dart` — totais por situação, tradução estrita
- `lib/data/models/acervo_por_corretor_model.dart` — linha e envelope do acervo por corretor
- `lib/data/models/contatos_por_corretor_model.dart` — linha (anulável, empresa sem texto) e envelope dos contatos
- `lib/data/models/mudancas_recentes_model.dart` — item (9 chaves, situação estrita, UTC) e envelope das mudanças
- `lib/data/models/*.freezed.dart`, `*.g.dart` — gerados por `dart run build_runner build -d` (8 arquivos)
- `test/data/modelos_area_gestor_test.dart` — os Models contra as fixtures reais e os casos de falha de formato

## Decisions Made

- A recusa de wire malformado fica toda no `paraEntidade()`/`fromJson` (D-24); o repositório do 12-06 só precisa converter `FormatException`/`TypeError` em falha tipada.
- `MudancaRecenteModel` usa um auxiliar privado `_situacaoEstrita` em vez de reaproveitar o `null` tolerante de `situacaoDoCodigo`, porque aqui situação desconhecida é falha e não "sem situação" (diferente do histórico da APP-09).

## TDD Gate Compliance

RED (`82ed320`, `8f845c5`) precede GREEN (`32f8f5b`, `c31d2a2`) nas duas tarefas. RED por falha de carregamento: o teste importa Models que ainda não existiam (símbolo indefinido), o RED padrão do Dart para código novo; avaliação semântica: o alvo falhou pelo motivo planejado (ausência da implementação), sem erro de sintaxe nem fixture quebrada. Sem REFACTOR.

## Deviations from Plan

None - plan executed exactly as written.

Observação operacional (sem desvio de escopo): `build_runner` reescreveu ~60 arquivos gerados já versionados só com diferença de fim de linha; foram restaurados com `git checkout -- lib` antes de cada commit (D-30), e só os 8 gerados novos foram commitados.

## Issues Encountered

None.

## Verification

- `flutter test test/data/modelos_area_gestor_test.dart test/data/contrato_area_gestor_test.dart test/data/contato_recebido_model_test.dart` verde (65 testes).
- `flutter analyze lib --no-fatal-infos`: 0 erros, 0 warnings, 53 infos (todos o `deprecated_member_use` do `material.dart`, baseline); o teste novo analisa sem issues.
- `flutter test` inteiro: **1825 testes verdes** (1805 do fim do 12-04 + 20 novos).
- Nenhum gerado deixado sem commit.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Os Models estão prontos para o repositório do 12-06 (`AreaGestorRepository` sobre o Dio), que converte `FormatException`/`TypeError` em falha tipada.

## Self-Check: PASSED

- 13 arquivos criados existem em disco; commits `82ed320`, `32f8f5b`, `8f845c5`, `c31d2a2` presentes no histórico da branch; acceptance_criteria e `<verification>` reexecutados com sucesso.

---
*Phase: 12-area-do-gestor-acompanhamento-dos-corretores*
*Completed: 2026-11-25*
