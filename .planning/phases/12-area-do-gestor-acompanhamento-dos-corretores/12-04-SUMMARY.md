---
phase: 12-area-do-gestor-acompanhamento-dos-corretores
plan: 04
subsystem: domain
tags: [dominio, entidades, usecases, injectable, area-gestor, clean-architecture]

requires:
  - phase: 12
    provides: "12-03: §18 do contrato (4 relatórios da Área do gestor) que as entidades espelham"
  - phase: 10
    provides: "molde de entidade imutável, interface de repositório com falhas tipadas e use case de repasse"
provides:
  - "TotaisPorSituacao, AcervoPorCorretor (+ AcervoDoCorretor), ContatosPorCorretor (+ ContatosDoCorretor com daEmpresa) e MudancasRecentes (+ MudancaRecente)"
  - "AreaGestorRepository com as 4 leituras (contatos com PeriodoContatos? opcional; mudanças sem parâmetro de janela)"
  - "ObterTotaisPorSituacaoUseCase, ObterAcervoPorCorretorUseCase, ObterContatosPorCorretorUseCase, ObterMudancasRecentesUseCase registrados no DI"
affects: [12-05, 12-06, 12-07, 12-08, 12-09]

# Medido: git rev-list --count ${PLAN_HEAD_BEFORE}..HEAD (ledger gsd-plan-head-before-12-04), antes do commit do SUMMARY
commits: 4
plan_head_before: 902f3aadd9fe312ab7f8328e54b95d249b35f8ee
plan_head_after: 6a4fad1a21e49f99d83d37c469382157e124099e

estimate_actuals_note: "tokens = chars/4 sobre o diff do plano (921 linhas inseridas em 12 arquivos, ~37 mil chars)"
actuals:
  tokens: 9300
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Entidade de lista com construtor não const que copia por List.unmodifiable / Map.unmodifiable; linhas filhas const"
    - "Igualdade de Map escrita com laço sobre SituacaoImovel.values, sem package:collection no domínio"
    - "Use case @injectable de repasse puro com parâmetro posicional opcional repassado como veio"

key-files:
  created:
    - lib/domain/entities/totais_por_situacao.dart
    - lib/domain/entities/acervo_por_corretor.dart
    - lib/domain/entities/contatos_por_corretor.dart
    - lib/domain/entities/mudancas_recentes.dart
    - lib/domain/repositories/area_gestor_repository.dart
    - lib/domain/usecases/obter_totais_por_situacao_usecase.dart
    - lib/domain/usecases/obter_acervo_por_corretor_usecase.dart
    - lib/domain/usecases/obter_contatos_por_corretor_usecase.dart
    - lib/domain/usecases/obter_mudancas_recentes_usecase.dart
    - test/domain/entidades_area_gestor_test.dart
    - test/domain/area_gestor_usecases_test.dart
  modified:
    - lib/di/injection.config.dart

key-decisions:
  - "Entidades com lista ou mapa usam construtor não const que copia a coleção (List.unmodifiable / Map.unmodifiable), no molde de PaginaContatos; as linhas filhas (AcervoDoCorretor, ContatosDoCorretor, MudancaRecente) são const"
  - "A entidade não confere nem recalcula: total e pendentes ficam como o servidor mandou, mesmo diferentes da soma das linhas (provado em teste com valores divergentes de propósito)"
  - "MudancaRecente.toString só tem id, código do imóvel e de -> para; sem alteradoPor nem observacao (T-12-11)"

patterns-established:
  - "Domínio da Área do gestor só guarda o que o servidor mandou (critério 5); a conta, a ordem e quem aparece são do Django"

requirements-completed: [GES-01, GES-02, GES-03, GES-04, GES-05]

coverage:
  - id: D1
    description: "Entidades imutáveis das 4 seções, sem soma, filtro nem ordenação no aparelho, com daEmpresa e toString sem dado pessoal"
    requirement: "GES-01, GES-02, GES-03, GES-04"
    verification:
      - kind: test
        ref: "flutter test test/domain/entidades_area_gestor_test.dart (17 testes)"
        status: pass
    human_judgment: false
  - id: D2
    description: "AreaGestorRepository com as 4 leituras e a doc das falhas 401/403"
    requirement: "GES-05"
    verification:
      - kind: other
        ref: "greps da Task 1 (GREP_OK: classes, assinatura com PeriodoContatos? periodo, obterMudancasRecentes(), sem código de situação do wire em lib/domain)"
        status: pass
    human_judgment: false
  - id: D3
    description: "4 use cases de repasse puro registrados no DI, com período repassado como veio e falhas tipadas intactas"
    requirement: "GES-01, GES-02, GES-03, GES-04, GES-05"
    verification:
      - kind: test
        ref: "flutter test test/domain/area_gestor_usecases_test.dart (13 testes) + entidades_area_gestor_test + caixa_contatos_usecases_test: All tests passed (35)"
        status: pass
    human_judgment: false

# Metrics
duration: ~6 min
completed: 2026-11-25
status: complete
---

# Phase 12 Plan 04: Domínio da Área do gestor Summary

**Entidades imutáveis das 4 seções (totais, acervo, contatos por corretor com linha da empresa, mudanças recentes), interface `AreaGestorRepository` e 4 use cases `@injectable` de repasse puro, tudo sem nenhuma conta no aparelho.**

## Performance

- **Duration:** ~6 min
- **Started:** 2026-11-25T21:03:49Z
- **Completed:** 2026-11-25T21:09:36Z (gate; o SUMMARY e o STATE vêm depois)
- **Tasks:** 2
- **Files modified:** 12 (11 criados, 1 alterado)

## Accomplishments

- `TotaisPorSituacao` (mapa imutável das 4 `SituacaoImovel` + `total` do servidor, igualdade por laço sobre o enum), `AcervoPorCorretor`/`AcervoDoCorretor`, `ContatosPorCorretor`/`ContatosDoCorretor` (getter `daEmpresa` quando `corretorId` é nulo; sem nome do servidor, D-17) e `MudancasRecentes`/`MudancaRecente` (`dias` do servidor, situações não anuláveis, `toString` sem nome nem observação).
- `AreaGestorRepository` com `obterTotaisPorSituacao()`, `obterAcervoPorCorretor()`, `obterContatosPorCorretor([PeriodoContatos? periodo])` e `obterMudancasRecentes()` (sem parâmetro de janela, D-19), doc das falhas `SessaoExpiradaException` (401) e `SemPermissaoException` (403).
- 4 use cases de repasse puro; o de contatos repassa o `PeriodoContatos?` como veio (D-15/D-16). `lib/di/injection.config.dart` regenerado com os 4 (só esse arquivo gerado mudou de verdade).
- 30 testes novos (17 de entidades, 13 de use cases). Gate da onda 4 verde: `flutter analyze lib --no-fatal-infos` sem erro nem warning, 53 infos, todas o `deprecated_member_use` do import de `material.dart` (mesmo baseline); `flutter test` inteiro: **1805 testes, All tests passed** (1775 ao fim do 12-03 + 30 deste plano).

## Task Commits

1. **Task 1 RED: teste das entidades** - `a55d953` (test)
2. **Task 1 GREEN: entidades e AreaGestorRepository** - `f5522a4` (feat)
3. **Task 2 RED: teste dos use cases** - `b68e2f9` (test)
4. **Task 2 GREEN: use cases e DI regenerado** - `6a4fad1` (feat)

**Plan metadata:** commit `docs(12-04)` (este SUMMARY, STATE e ROADMAP)

## TDD Gate Compliance

- **RED (`a55d953`, `b68e2f9`):** nos dois casos `flutter test <arquivo>` terminou com exit 1 por falha de carga do arquivo ("Failed to load": os imports das entidades e dos use cases ainda não existiam), exatamente o RED que o plano pede ("os imports não existem"). Avaliação semântica: o alvo falhou pelo motivo planejado (símbolos inexistentes), não por erro de sintaxe nem fixture. O `gsd_run check tdd-red-evidence` não foi usado: `flutter test` não emite nenhum dos formatos que o classificador aceita e `workflow.tdd_mode` não está ligado em `config.json` (mesmo critério do 12-03).
- **GREEN (`f5522a4`, `6a4fad1`):** os testes passam (Task 1: 17 + os 21 de caixa de contatos; Task 2: 13 + 17 + 5 de caixa).
- **REFACTOR:** nenhum. O `dart format` rodou antes do GREEN da Task 1 e só reformatou uma linha de `mudancas_recentes.dart` e o teste.

## Files Created/Modified

- `lib/domain/entities/totais_por_situacao.dart`, `acervo_por_corretor.dart`, `contatos_por_corretor.dart`, `mudancas_recentes.dart` - entidades das 4 seções
- `lib/domain/repositories/area_gestor_repository.dart` - interface com as 4 leituras
- `lib/domain/usecases/obter_totais_por_situacao_usecase.dart`, `obter_acervo_por_corretor_usecase.dart`, `obter_contatos_por_corretor_usecase.dart`, `obter_mudancas_recentes_usecase.dart` - repasse puro
- `lib/di/injection.config.dart` - os 4 use cases registrados (+27 linhas geradas)
- `test/domain/entidades_area_gestor_test.dart`, `test/domain/area_gestor_usecases_test.dart` - testes

## Decisions Made

- Construtor não const com cópia imutável para as entidades que guardam coleção, escolhido entre as duas opções que o plano permitia (molde `PaginaContatos`) e documentado na doc de cada classe.
- A igualdade do mapa de totais é escrita à mão com laço sobre `SituacaoImovel.values` (o domínio não importa `package:collection`).
- Para o `grep` do plano que procura a assinatura literal `obterContatosPorCorretor([PeriodoContatos? periodo])`, ela aparece numa linha da doc da interface; a assinatura real fica quebrada em linhas pelo `dart format`.

## Deviations from Plan

None - plan executed exactly as written.

O `build_runner` regenerou 58 arquivos `*.freezed.dart`/`*.g.dart` só com diferença de fim de linha; foram restaurados com `git checkout --` como o plano manda (D-30), e só `lib/di/injection.config.dart` foi commitado.

## Issues Encountered

None.

## Known Stubs

Nenhum. As entidades e os use cases ainda não têm Model nem repositório concreto; isso é decisão do plano (12-05 e 12-06), não stub.

## Threat Flags

Nenhum. T-12-11 (`toString` de `MudancaRecente`) mitigado e coberto por teste; T-12-SC sem pacote novo. Nenhuma superfície nova: só domínio puro.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- O 12-05 mapeia os JSON do §18 para estas entidades (Models) e o 12-06 implementa `AreaGestorRepository`; o DI já resolve os 4 use cases assim que a implementação for registrada.
- Sem bloqueios.

## Self-Check: PASSED

- Arquivos: as 4 entidades, a interface, os 4 use cases e os 2 testes existem; `lib/di/injection.config.dart` cita os 4 use cases.
- Commits `a55d953`, `f5522a4`, `b68e2f9` e `6a4fad1` são ancestrais de `HEAD`.
- Verificação do plano: greps da Task 1 e da Task 2 ok, gerados sem sujeira, analyze sem erro, warning nem info novo, `flutter test` inteiro com 1805 testes verdes.

---
*Phase: 12-area-do-gestor-acompanhamento-dos-corretores*
*Completed: 2026-11-25*
