---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 07
subsystem: auth
tags: [flutter, usecase, cubit, freezed, injectable, sessao]

requires:
  - phase: 08-05
    provides: "AutenticacaoRepository/Impl (sair e descartarSessaoLocal nunca lancam), falhas tipadas, Papel"
provides:
  - "EntrarUseCase: login -> papel com rollback (descartarSessaoLocal) que nunca lanca"
  - "ObterPapelUseCase, SairUseCase (nunca lanca), LerSessaoUseCase (so o aparelho)"
  - "SessaoState (verificando, anonima, autenticada) e SessaoCubit singleton (carregar, marcarAutenticada, marcarAnonima, sair)"
affects: [08-10 tela de login, 08-11 botao do topo e rota Meu acervo, 08-12]

actuals:
  tokens: 11000
  tasks: 2
  commits: 2
plan_head_before: 0e5eb1edbbdfb983a683e35c71004e1fae18c2c3
plan_head_after: 4a2093b3e3663299787f4a8928118a8885427a6a

tech-stack:
  added: []
  patterns:
    - "Use case fino sobre o repositorio; a garantia de nao lancar vem da camada de dados"
    - "SessaoCubit.sair(): try/finally sem catch; emite anonima depois do descarte do token"
    - "Testes de garantia na pilha real (use case + AutenticacaoRepositoryImpl) com DataSource e ArmazenamentoToken mocktail que lancam"

key-files:
  created:
    - lib/domain/usecases/entrar_usecase.dart
    - lib/domain/usecases/obter_papel_usecase.dart
    - lib/domain/usecases/sair_usecase.dart
    - lib/domain/usecases/ler_sessao_usecase.dart
    - lib/presentation/sessao/sessao_state.dart
    - lib/presentation/sessao/sessao_state.freezed.dart
    - lib/presentation/sessao/sessao_cubit.dart
    - test/domain/entrar_usecase_test.dart
    - test/domain/sair_usecase_test.dart
    - test/presentation/sessao_cubit_test.dart
  modified:
    - lib/di/injection.config.dart

key-decisions:
  - "Os estados do SessaoState sao nomeados SessaoVerificando/SessaoAnonima/SessaoAutenticada para nao colidir com classes de outros estados"
  - "Sem catch no SessaoCubit.sair(): o finally so garante o estado anonimo se o contrato de dados quebrar"

patterns-established:
  - "Sessao com dono unico (singleton) lida so do aparelho; papel so ao entrar ou tocar em Meu acervo"

requirements-completed: [AUTH-01, AUTH-02, AUTH-04, AUTH-05]

coverage:
  - id: D1
    description: "Login -> papel com rollback que nunca lanca (apagar() com PlatformException na pilha real)"
    requirement: "AUTH-01"
    verification:
      - kind: unit
        ref: "test/domain/entrar_usecase_test.dart#pilha real: rollback com apagar() lançando PlatformException"
        status: pass
    human_judgment: false
  - id: D2
    description: "Sair completa sem lancar com rede fora, 401 e apagar() lancando"
    requirement: "AUTH-05"
    verification:
      - kind: unit
        ref: "test/domain/sair_usecase_test.dart#pilha real"
        status: pass
    human_judgment: false
  - id: D3
    description: "SessaoCubit le so o aparelho e sair() sempre termina anonima, inclusive com use case que lanca"
    requirement: "AUTH-04"
    verification:
      - kind: unit
        ref: "test/presentation/sessao_cubit_test.dart#pilha real e regressao do contrato"
        status: pass
    human_judgment: false

duration: 15 min
completed: 2026-11-21
status: complete
---

# Phase 08 Plan 07: Use cases da autenticacao e SessaoCubit Summary

**`EntrarUseCase` (login -> papel com rollback que nunca lanca), `ObterPapelUseCase`, `SairUseCase`, `LerSessaoUseCase` e o `SessaoCubit` singleton que le a sessao so do aparelho e cujo `sair()` sempre termina anonimo, provado na pilha real com DataSource e armazenamento que lancam.**

## Performance

- **Duration:** 15 min
- **Tasks:** 2
- **Files modified:** 11 (10 criados, 1 alterado)

## Accomplishments

- Quatro use cases `@injectable` com `call`, registrados em `injection.config.dart`.
- `EntrarUseCase` devolve a falha do login sem perguntar o papel; se o papel falha (conexao, `FormatException`, sessao expirada), chama `descartarSessaoLocal()` uma vez.
- `SessaoCubit` (`@lazySingleton`) comeca em `verificando`; `carregar()` so usa `LerSessaoUseCase`; `sair()` usa `try/finally` e emite `anonima` depois do descarte.
- 22 testes novos; suite completa: 905 verdes (883 + 22).

## Task Commits

1. **Task 1: Use cases de autenticacao** - `527a8de` (feat)
2. **Task 2: SessaoState e SessaoCubit** - `4a2093b` (feat)

## Decisions Made

- Classes de estado nomeadas `SessaoVerificando`, `SessaoAnonima`, `SessaoAutenticada` (padrao do app: cada uniao freezed tem nomes proprios).
- Sem `catch` no `sair()` do cubit, como o plano pede: a garantia de nao lancar e do repositorio.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `dart format` reformatou arquivos alheios**
- **Found during:** Task 1
- **Issue:** `dart format lib/domain/usecases test/domain` alterou 4 arquivos existentes fora do escopo.
- **Fix:** restaurados com `git checkout --` por caminho explicito antes de commitar; nada alheio foi commitado.

Fora isso, o plano foi executado como escrito. Os 30 arquivos gerados que o `build_runner` marcou so por CRLF foram restaurados (diff ignorando EOL vazio); so `injection.config.dart` e `sessao_state.freezed.dart` tem mudanca real.

## Issues Encountered

`flutter analyze lib` continua com os 30 `info` `deprecated_member_use` pre-existentes (material.dart); nenhum em arquivo deste plano. Por isso o criterio "No issues found!" do plano nao e literal, mas nao ha issue novo.

## Known Stubs

None.

## Threat Flags

None.

## Self-Check: PASSED

- Arquivos criados existem; commits `527a8de` e `4a2093b` presentes na branch `feat/APP08`; `flutter test` inteiro verde.
