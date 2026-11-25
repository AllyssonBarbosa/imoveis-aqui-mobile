---
phase: 12-area-do-gestor-acompanhamento-dos-corretores
plan: 07
subsystem: presentation
tags: [cubit, freezed, injectable, area-gestor, estado-por-secao, tdd]

requires:
  - phase: 12
    provides: "12-04: entidades, AreaGestorRepository e os 4 use cases; 12-06: repositório concreto com 401/403 tipados"
provides:
  - "Textos fixos e funções puras da Área do gestor (apresentacao_area_gestor.dart)"
  - "EstadoSecao<T> (carregando/comFalha/carregada), FalhaDaSecao, SecaoDaAreaGestor e AreaGestorState"
  - "AreaGestorCubit (carregar, tentarNovamente, aplicarPeriodo, limparPeriodo) registrado no DI"
affects: [12-08, 12-09]

# Medido: git rev-list --count ${PLAN_HEAD_BEFORE}..HEAD (ledger gsd-plan-head-before-12-07), antes do commit do SUMMARY
commits: 4
plan_head_before: 2a191ebb27715a98fbe71faee5e9d8d15b78ff47
plan_head_after: b8e02c90e3e28d962f6d09a0e6519e3a05e8f093

estimate_actuals_note: "tokens = chars/4 sobre o diff do plano (~65 mil chars, 1707 linhas inseridas em 7 arquivos, 714 delas do .freezed.dart gerado)"
actuals:
  tokens: 16300
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Uma união freezed genérica por seção (EstadoSecao<T>) no molde de Result<T>, para que cada relatório carregue, falhe e termine sozinho"
    - "Um contador de versão por seção descarta resposta superada (período trocado, dois retries seguidos)"
    - "Tradução do Result em estado de seção por um único método genérico _traduzir<T>, que devolve null só para o 401"

key-files:
  created:
    - lib/presentation/area_gestor/apresentacao_area_gestor.dart
    - lib/presentation/area_gestor/area_gestor_state.dart
    - lib/presentation/area_gestor/area_gestor_state.freezed.dart
    - lib/presentation/area_gestor/area_gestor_cubit.dart
    - test/presentation/apresentacao_area_gestor_test.dart
    - test/presentation/area_gestor_cubit_test.dart
  modified:
    - lib/di/injection.config.dart

key-decisions:
  - "Falha de seção guarda só o TIPO (FalhaDaSecao); o texto é de textoDaFalha, com switch exaustivo e fixo (D-23, T-12-19)"
  - "O 401 é terminal: sessaoExpirada trava todo pedido novo e toda emissão, inclusive respostas atrasadas das outras seções (D-22, T-12-17)"
  - "aplicarPeriodo com o período já aplicado e limparPeriodo sem período não chamam a API"
  - "O ramo Loading() de _traduzir devolve carregando (estado igual ao atual, sem efeito) em vez de um caso vazio, para manter o switch exaustivo e o tipo T"

patterns-established:
  - "Estado de tela com várias seções independentes: um EstadoSecao<T> por seção e uma versão por seção no Cubit"

requirements-completed: [GES-01, GES-02, GES-03, GES-04, GES-05, GES-06]

coverage:
  - id: D1
    description: "Textos fixos e funções puras da Área do gestor (títulos, singular/plural, período, mudanças, falhas) reaproveitando rotuloSituacao e formatarDataHora"
    requirement: "GES-01, GES-02, GES-03, GES-04, GES-05"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/apresentacao_area_gestor_test.dart (16 testes)"
        status: pass
    human_judgment: false
  - id: D2
    description: "EstadoSecao<T>, FalhaDaSecao, SecaoDaAreaGestor e AreaGestorState com as 4 seções carregando, período nulo e sessão viva"
    requirement: "GES-06"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/apresentacao_area_gestor_test.dart#estado inicial"
        status: pass
    human_judgment: false
  - id: D3
    description: "AreaGestorCubit: carga paralela, falha isolada por seção (genérica, 403, formato), retry por seção, período só nos contatos com versão, 401 terminal e nenhum emit após close()"
    requirement: "GES-01, GES-02, GES-03, GES-04, GES-05, GES-06"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/area_gestor_cubit_test.dart (17 testes)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Os textos da Área do gestor leem bem na tela (títulos, linha da empresa, texto do 403 com Tentar de novo)"
    verification: []
    human_judgment: true
    rationale: "Ainda não há widget; o texto do 403 com o mesmo Tentar de novo é uma suposição sinalizada no plano e fica para o human-check do 12-09"

# Metrics
duration: ~7 min
completed: 2026-11-25
status: complete
---

# Phase 12 Plan 07: Lógica de tela da Área do gestor Summary

**`AreaGestorCubit` com um estado por seção (carregando/falha/carregada), 4 pedidos em paralelo, retry só da seção que falhou, período recarregando só os contatos com versão, 401 terminal e 403 com texto próprio, mais os textos fixos em funções puras, tudo sem nenhuma conta no aparelho.**

## Performance

- **Duration:** ~7 min
- **Started:** 2026-11-25T21:27:41Z
- **Completed:** 2026-11-25T21:34:02Z (gate; o SUMMARY e o STATE vêm depois)
- **Tasks:** 2
- **Files modified:** 7 (6 criados, 1 alterado)

## Accomplishments

- `apresentacao_area_gestor.dart`: constantes dos títulos e textos fixos e as funções puras do plano (`textoTotalImoveis`, `textoImoveisDoCorretor`, `nomeDoCorretor`, `textoContatosDoCorretor`, `textoTotalContatos`, `textoDoPeriodo`, `tituloSecaoMudancas`, `textoNenhumaMudanca`, `rotuloImovelDaMudanca`, `textoDeParaMudanca`, `textoQuandoEQuemMudanca`, `textoDaFalha`), com singular/plural e reaproveitando `rotuloSituacao` e `formatarDataHora` por import.
- `area_gestor_state.dart`: `EstadoSecao<T>` freezed genérico, `FalhaDaSecao`, `SecaoDaAreaGestor` e `AreaGestorState` (4 seções `@Default(carregando)`, `periodo`, `sessaoExpirada`).
- `AreaGestorCubit` (`@injectable`): `carregar()` dispara os 4 pedidos com `unawaited`; uma versão por seção; `tentarNovamente(secao)` por `switch` exaustivo; `aplicarPeriodo`/`limparPeriodo` recarregam só os contatos e não chamam a API quando nada muda; `sessaoExpirada` trava pedidos e emissões; `isClosed` conferido antes de todo `emit`.
- 33 testes novos (16 de apresentação/estado, 17 do Cubit). Gate da onda 7 (D-30) verde: `flutter analyze lib --no-fatal-infos` sem erro nem warning, 53 infos, todas o `deprecated_member_use` do import de `material.dart` (mesmo baseline); `flutter test` inteiro: **1888 testes, All tests passed** (1855 ao fim do 12-06 + 33 deste plano).

## Task Commits

1. **Task 1 RED: teste da apresentação e do estado** - `c2ebfa2` (test)
2. **Task 1 GREEN: textos fixos e estado por seção** - `58b56f9` (feat)
3. **Task 2 RED: teste do AreaGestorCubit** - `debe9ae` (test)
4. **Task 2 GREEN: AreaGestorCubit e DI regenerado** - `b8e02c9` (feat)

**Plan metadata:** commit `docs(12-07)` (este SUMMARY, STATE e ROADMAP)

## TDD Gate Compliance

- **RED (`c2ebfa2`, `debe9ae`):** nos dois casos `flutter test <arquivo>` terminou com exit 1 por falha de carga do arquivo ("Failed to load": os imports de `apresentacao_area_gestor.dart`/`area_gestor_state.dart` e de `area_gestor_cubit.dart` ainda não existiam), o RED que o plano pede. Avaliação semântica: o alvo falhou pelo motivo planejado (símbolos inexistentes), não por sintaxe nem fixture. O `gsd_run check tdd-red-evidence` não foi usado: `flutter test` não emite nenhum dos formatos que o classificador aceita e `workflow.tdd_mode` não está ligado (mesmo critério do 12-03 e 12-04).
- **GREEN (`58b56f9`, `b8e02c9`):** os testes passam (Task 1: 16 + 29 da apresentação de contatos; Task 2: 17 + 16 + caixa de contatos, 88 no total do comando).
- **REFACTOR:** nenhum.

## Files Created/Modified

- `lib/presentation/area_gestor/apresentacao_area_gestor.dart` - textos fixos e funções puras
- `lib/presentation/area_gestor/area_gestor_state.dart` e `area_gestor_state.freezed.dart` - estado por seção (o `.freezed.dart` é gerado)
- `lib/presentation/area_gestor/area_gestor_cubit.dart` - o Cubit
- `lib/di/injection.config.dart` - `AreaGestorCubit` registrado (+10 linhas geradas)
- `test/presentation/apresentacao_area_gestor_test.dart`, `test/presentation/area_gestor_cubit_test.dart` - testes

## Decisions Made

- O ramo `Loading()` de `_traduzir` devolve `carregando` (igual ao estado em voo, sem efeito) para manter o `switch` exaustivo e tipado; os use cases do 12-04 nunca devolvem `Loading`.
- `_traduzir<T>` devolve `null` só para o 401, e cada carregador emite `sessaoExpirada: true` nesse caso (um ponto único de tradução, sem repetir o `switch` nos 4 carregadores).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Tipo `Never` nas falhas de seção**
- **Found during:** Task 2 (GREEN, primeira rodada do teste do Cubit)
- **Issue:** em `_traduzir<T>`, `const EstadoSecao.comFalha(...)` dentro do `switch` foi inferido como `EstadoSecao<Never>`, então `SecaoComFalha<Never>` não igualava `EstadoSecao<AcervoPorCorretor>.comFalha(...)` (3 testes de falha isolada vermelhos) e o estado ficava com tipo errado.
- **Fix:** `EstadoSecao<T>.comFalha(...)` explícito (sem `const`, pois `T` é variável de tipo).
- **Files modified:** `lib/presentation/area_gestor/area_gestor_cubit.dart`
- **Verification:** os 3 testes passaram; os 88 do comando da Task 2 verdes.
- **Committed in:** `b8e02c9` (parte do commit do GREEN; o conserto veio antes do commit)

---

**Total deviations:** 1 auto-fixed (1 bug, apanhado pelo próprio teste antes do commit)
**Impact on plan:** nenhum; sem mudança de escopo.

O `build_runner` reescreveu dezenas de `*.freezed.dart`/`*.g.dart` só com diferença de fim de linha, nas duas rodadas; foram restaurados com `git checkout --` arquivo a arquivo (D-30). Só `area_gestor_state.freezed.dart` e `lib/di/injection.config.dart` foram commitados.

## Issues Encountered

None.

## Known Stubs

Nenhum. O estado, os textos e o Cubit não têm dado fixo nem placeholder; a tela que os usa é o 12-08.

## Threat Flags

Nenhum. T-12-17 (401 ignorado), T-12-18 (período antigo cobrindo o novo) e T-12-19 (texto do servidor) mitigados e cobertos por teste; T-12-SC sem pacote novo. Nenhuma superfície nova: só lógica de tela.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- O 12-08 monta a tela sobre `AreaGestorCubit`/`AreaGestorState` e `apresentacao_area_gestor.dart`; o `sessaoExpirada` terminal é o que ela deve levar ao login.
- Suposição sinalizada que segue aberta para o human-check do 12-09: o 403 mostra o texto próprio com o mesmo "Tentar de novo" das outras falhas.
- Sem bloqueios.

## Self-Check: PASSED

- Arquivos: os 4 de `lib/presentation/area_gestor/`, os 2 testes e `lib/di/injection.config.dart` (cita `AreaGestorCubit`) existem.
- Commits `c2ebfa2`, `58b56f9`, `debe9ae` e `b8e02c9` são ancestrais de `HEAD`.
- Verificação do plano: greps das duas tasks ok, analyze sem erro, warning nem info novo, `flutter test` inteiro com 1888 testes verdes, nenhum `.fold(`/`.reduce(` no Cubit nem na apresentação, nenhum gerado deixado sem commit.

---
*Phase: 12-area-do-gestor-acompanhamento-dos-corretores*
*Completed: 2026-11-25*
