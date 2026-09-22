---
phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api
plan: 03
subsystem: location-permission
tags: [flutter, clean-architecture, freezed, flutter_bloc, geolocator, geocoding, mocktail, bloc_test, sealed-state, material3]

# Dependency graph
requires:
  - phase: 01-01
    provides: Clean Architecture skeleton (Result<T>, CidadeRepository, DI via get_it/injectable, CidadeSelecaoScreen tracer, main.dart launch seam)
provides:
  - GeolocatorGateway/GeocodingGateway mockable wrappers over the geolocator/geocoding statics, DI-registered
  - UfLookup — Brazil state-name → UF normalization (Pitfall 2)
  - DetectarCidadeUseCase — GPS + reverse geocoding wrapped in Result, nome+uf normalized match (D-09)
  - 8-variant sealed CidadeSelecaoState (D-07/LOC-06) — every location outcome + loading + defensive asset-error state, never a generic exception
  - CidadeSelecaoCubit — priming permission state machine, requestPermission called at most once per detect attempt (D-05)
  - PrimingScreen — FilledButton CTA is the only trigger of the permission flow
  - CidadeSelecaoScreen expanded to an exhaustive, compiler-enforced switch over all 8 states
  - main.dart wired: no saved city → PrimingScreen; saved city → direct entry via cubit.entrarDireto() (D-08)
affects: [01-04, phase-02]

# Actuals (#2632)
actuals:
  tokens: 24900
  tasks: 3
  commits: 3

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Static-function wrapping: geolocator/geocoding expose top-level statics that mocktail cannot mock — every such call is wrapped behind a domain/ gateway interface with a data/ @LazySingleton(as: ...) impl"
    - "Sealed UI-state union (freezed): CidadeSelecaoState models every reachable outcome as a named variant; the screen renders it via a Dart 3 exhaustive switch expression (no default branch — compiler enforces every variant is handled)"
    - "Use case returns the presentation-layer sealed state directly (DetectarCidadeUseCase -> CidadeSelecaoState) when its whole job is mapping fallible steps onto UI outcomes — keeps the Cubit a thin orchestrator"
    - "Widget tests drive a mocktail-mocked Cubit (bloc_test's MockCubit + whenListen) to pump each sealed state in isolation; Cubit tests drive mocktail-mocked gateways/use cases via blocTest state-sequence assertions"

key-files:
  created:
    - lib/domain/gateways/geolocator_gateway.dart
    - lib/domain/gateways/geocoding_gateway.dart
    - lib/data/gateways/geolocator_gateway_impl.dart
    - lib/data/gateways/geocoding_gateway_impl.dart
    - lib/data/constants/uf_lookup.dart
    - lib/domain/usecases/detectar_cidade_usecase.dart
    - lib/presentation/cidade_selecao/cidade_selecao_state.dart
    - lib/presentation/cidade_selecao/cidade_selecao_cubit.dart
    - lib/presentation/priming/priming_screen.dart
    - test/data/uf_lookup_test.dart
    - test/domain/detectar_cidade_usecase_test.dart
    - test/presentation/cidade_selecao_cubit_test.dart
    - test/presentation/cidade_selecao_screen_test.dart
    - test/presentation/priming_screen_test.dart
  modified:
    - lib/presentation/cidade_selecao/cidade_selecao_screen.dart
    - lib/main.dart
    - lib/di/injection.config.dart
    - test/skeleton_flow_test.dart

key-decisions:
  - "DetectarCidadeUseCase returns CidadeSelecaoState directly (not a narrower DTO) — its entire job is mapping GPS+geocoding+match onto a UI outcome, so returning the sealed state keeps the Cubit a thin permission-switch orchestrator"
  - "GPS-acquisition failure (not just reverse-geocoding failure) routes to falhaGeocodificacao — no separate state exists for a GPS-specific failure, and D-12's intent ('no error screen, fall back to list') applies identically"
  - "CidadeSelecaoCubit.carregarLista() reuses the recusada state as the generic 'just show the list' landing — used by erroCarregarCidades's 'Tentar de novo' retry"
  - "entrarDireto(Cidade) added to the Cubit beyond the plan's literal Task 2 text — used both for D-08's saved-city direct entry (main.dart) and for manual list-tap selection (D-10 applied by analogy: no confirmation step)"
  - "No AppBar/city-switcher header in CidadeSelecaoScreen this plan — LOC-05 ('trocar cidade num toque no topo') is explicitly out of this plan's requirements ([LOC-01, LOC-02, LOC-03, LOC-06]) and deferred to Plan 01-04"

patterns-established:
  - "Gateway wrapper pattern for any plugin exposing top-level static functions (geolocator, geocoding) — abstract interface in domain/, @LazySingleton(as:) impl in data/, never called directly from a Widget or Cubit"
  - "Exhaustive sealed-switch screens: a StatelessWidget's build() pattern-matches every variant of a sealed presentation state with no default case, so adding a new variant is a compile error until the screen handles it"

requirements-completed: [LOC-01, LOC-02, LOC-03, LOC-06]

coverage:
  - id: D1
    description: "Mockable gateways over geolocator/geocoding statics + Brazil UF lookup (Pitfall 2), DI-registered, whileInUse-only, MissingPluginException/UnimplementedError caught"
    requirement: LOC-02
    verification:
      - kind: unit
        ref: "test/data/uf_lookup_test.dart (8 tests)"
        status: pass
      - kind: integration
        ref: "flutter analyze"
        status: pass
    human_judgment: false
  - id: D2
    description: "8-variant sealed CidadeSelecaoState (D-07/LOC-06): localizando, autorizadaEAtendida, autorizadaNaoAtendida, recusada, bloqueadaParaSempre, servicoDesligado, falhaGeocodificacao, erroCarregarCidades — every outcome an explicit named state, never a generic exception"
    requirement: LOC-06
    verification:
      - kind: automated_ui
        ref: "test/presentation/cidade_selecao_screen_test.dart (10 widget tests, one per state + tap-to-select, asserts no ErrorWidget for any outcome)"
        status: pass
    human_judgment: false
  - id: D3
    description: "DetectarCidadeUseCase: GPS + reverse geocoding wrapped in Result, nome+uf normalized match against the served list (D-09)"
    requirement: LOC-02
    verification:
      - kind: unit
        ref: "test/domain/detectar_cidade_usecase_test.dart (6 tests: asset failure, GPS failure, geocoding failure, matched, unmatched, null locality)"
        status: pass
    human_judgment: false
  - id: D4
    description: "CidadeSelecaoCubit orchestrates the permission state machine (service off / denied / deniedForever / unableToDetermine / authorized) — requestPermission invoked at most once per detect attempt"
    requirement: LOC-01
    verification:
      - kind: unit
        ref: "test/presentation/cidade_selecao_cubit_test.dart (11 bloc_test cases covering every <behavior> branch)"
        status: pass
    human_judgment: false
  - id: D5
    description: "PrimingScreen: the FilledButton CTA is the only trigger of the location permission flow — the native OS prompt never fires on init (D-05)"
    requirement: LOC-01
    verification:
      - kind: automated_ui
        ref: "test/presentation/priming_screen_test.dart (2 widget tests: nothing fires before tap; requestPermission called exactly once after tap)"
        status: pass
    human_judgment: false
  - id: D6
    description: "Real device/emulator exercise of the native OS permission dialog and each of the 5 location outcomes end-to-end (Android + iOS)"
    verification: []
    human_judgment: true
    rationale: "The plan's own <verify> block queues this as a <human-check> for end-of-phase (workflow.human_verify_mode=end-of-phase, per checkpoints.md) — automated unit/widget tests prove the logic and rendering, but not the real OS permission dialog and device GPS/geocoding behavior."

duration: 34min
completed: 2026-09-22
status: complete
---

# Phase 1 Plan 3: Location Permission Flow + Sealed City-Selection Summary

**Priming screen with CTA-only permission trigger, GPS+reverse-geocoding city detection via mockable gateways, and an 8-variant sealed `CidadeSelecaoState` rendered by an exhaustive (compiler-enforced) switch — every location outcome (authorized/denied/blocked/service-off/unserved/geocoding-failure/asset-error) has its own UI, never a generic error screen.**

## Performance

- **Duration:** 34 min (approx.)
- **Started:** 2026-09-22T15:25:00Z (approx.)
- **Completed:** 2026-09-22T15:59:14Z
- **Tasks:** 3/3
- **Files modified:** 19 (14 created, 4 modified, 1 generated freezed part file)

## Accomplishments

- `GeolocatorGateway`/`GeocodingGateway` (domain) + `GeolocatorGatewayImpl`/`GeocodingGatewayImpl` (data, `@LazySingleton(as: ...)`) wrap the `geolocator`/`geocoding` top-level static functions so they're mockable with `mocktail` — requests `whileInUse` only, never `always`/background.
- `UfLookup`: 27 Brazil state names → UF lookup table + normalization (accents/case/whitespace), so `Placemark.administrativeArea` (often the full state name on Android) is correctly compared against `Cidade.uf` before the D-09 match (RESEARCH Pitfall 2).
- `DetectarCidadeUseCase`: orchestrates asset-list load → GPS → reverse geocoding → nome+uf normalized match, returning the exact `CidadeSelecaoState` outcome directly — every fallible step wrapped in `Result`, never a bare `await`/generic `try/catch`.
- `CidadeSelecaoState` (freezed sealed, 8 variants): `localizando`, `autorizadaEAtendida`, `autorizadaNaoAtendida`, `recusada`, `bloqueadaParaSempre`, `servicoDesligado`, `falhaGeocodificacao`, `erroCarregarCidades` — D-07/LOC-06.
- `CidadeSelecaoCubit`: runs the priming permission switch (service check → `checkPermission` → `requestPermission` only if `denied` → route to the matching state or to `DetectarCidadeUseCase` on `whileInUse`/`always`); exposes `carregarLista()` (list-only fallback paths) and `entrarDireto()` (D-08 saved-city entry + manual selection).
- `PrimingScreen` (D-05): heading + body copy + `FilledButton` "Usar minha localização" — the *only* call site of `detectarCidade()`, never on `initState`; navigates to `CidadeSelecaoScreen` sharing the same Cubit instance.
- `CidadeSelecaoScreen` expanded to an exhaustive Dart 3 `switch` expression over all 8 sealed states — no `default`/catch-all, compiler-enforced; each state has distinct copy/UI per the UI-SPEC Copywriting Contract; tapping a city persists via `SalvarCidadeUseCase` then enters direct (D-10 applied to manual selection).
- `main.dart` rewired: no saved city → `PrimingScreen`; saved city → `CidadeSelecaoScreen` entered directly via `cubit.entrarDireto(cidadeSalva)` (D-08, no GPS re-prompt).

## Task Commits

Each task was committed atomically:

1. **Task 1: Gateway wrappers over geolocator/geocoding + Brazil UF lookup + DI** - `72a845f` (feat)
2. **Task 2: Sealed CidadeSelecaoState + DetectarCidadeUseCase + CidadeSelecaoCubit** - `2a89a2b` (feat)
3. **Task 3: Priming screen + exhaustive city-selection screen + launch wiring** - `77095ac` (feat)

**Plan metadata:** commit pending (this SUMMARY + REQUIREMENTS.md, worktree mode — STATE.md/ROADMAP.md updated centrally by the orchestrator after merge)

_Note: `tdd="true"` was set on Task 2, but `workflow.tdd_mode` is not enabled for this project (absent from `.planning/config.json`) and this is a `type: execute` plan, not `type: tdd` — the strict plan-level RED/GREEN/REFACTOR gate does not apply (same precedent as Plan 01-01). Tests describing every `<behavior>` branch were written before the implementation was finalized, and the whole vertical slice was committed as one atomic `feat` commit per task, consistent with the rest of this plan._

## Files Created/Modified

- `lib/domain/gateways/geolocator_gateway.dart`, `geocoding_gateway.dart` - mockable interfaces over the plugin statics
- `lib/data/gateways/geolocator_gateway_impl.dart`, `geocoding_gateway_impl.dart` - `@LazySingleton(as: ...)` impls, whileInUse only, catch platform/plugin failures
- `lib/data/constants/uf_lookup.dart` - Brazil state-name → UF normalization (Pitfall 2)
- `lib/domain/usecases/detectar_cidade_usecase.dart` - GPS+geocoding+match orchestration, returns `CidadeSelecaoState`
- `lib/presentation/cidade_selecao/cidade_selecao_state.dart` (+ generated `.freezed.dart`) - 8-variant sealed union
- `lib/presentation/cidade_selecao/cidade_selecao_cubit.dart` - permission state machine + `carregarLista`/`entrarDireto`/`abrirConfiguracoesDoSistema`
- `lib/presentation/priming/priming_screen.dart` - CTA-only permission trigger
- `lib/presentation/cidade_selecao/cidade_selecao_screen.dart` - exhaustive 8-state switch, replaces the 01-01 minimal screen
- `lib/main.dart` - no-saved-city → priming; saved-city → direct entry via the Cubit
- `lib/di/injection.config.dart` - regenerated (3x) to register the new gateways/use case/cubit
- `test/data/uf_lookup_test.dart`, `test/domain/detectar_cidade_usecase_test.dart`, `test/presentation/cidade_selecao_cubit_test.dart`, `test/presentation/cidade_selecao_screen_test.dart`, `test/presentation/priming_screen_test.dart` - 37 new tests
- `test/skeleton_flow_test.dart` - trimmed the obsolete constructor-injection group (see Deviations)

## Decisions Made

See `key-decisions` in frontmatter. Highlights: `DetectarCidadeUseCase` returns the sealed `CidadeSelecaoState` directly (not a narrower DTO); GPS-failure and geocoding-failure both route to `falhaGeocodificacao` (no separate state exists, D-12's intent is identical either way); the city-switcher/AppBar header (LOC-05) is intentionally out of this plan's scope and deferred to Plan 01-04.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added `CidadeSelecaoCubit.abrirConfiguracoesDoSistema()`**
- **Found during:** Task 3 (wiring the `bloqueadaParaSempre` state's "Ativar localização nas Ajustes" CTA)
- **Issue:** D-06 requires a `TextButton` that opens the system settings (`geolocator.openAppSettings()`), but Task 2's file list didn't include `cidade_selecao_cubit.dart`, and the Clean Architecture constraint forbids the screen calling the gateway directly.
- **Fix:** Added a one-line `abrirConfiguracoesDoSistema()` method to `CidadeSelecaoCubit` that delegates to `GeolocatorGateway.abrirConfiguracoesApp()`. Covered by `cidade_selecao_screen_test.dart`'s `bloqueadaParaSempre` test (verifies the cubit method is invoked on tap).
- **Files modified:** `lib/presentation/cidade_selecao/cidade_selecao_cubit.dart`
- **Verification:** `flutter test`/`flutter analyze` green
- **Committed in:** `77095ac` (Task 3 commit)

**2. [Rule 1 - Bug] Trimmed the obsolete "Fluxo do walking skeleton" group in `test/skeleton_flow_test.dart`**
- **Found during:** Task 3 (`flutter analyze` after expanding `CidadeSelecaoScreen`)
- **Issue:** The 01-01 test group constructed `CidadeSelecaoScreen(obterCidadesAtendidas: ..., salvarCidade: ...)` — those constructor params no longer exist now that the screen is Cubit-driven (`analyzer` reported `undefined_named_parameter`), a direct, in-scope consequence of this task's own screen-API change.
- **Fix:** Removed the obsolete group; its coverage (list rendering, tap-to-persist) is now provided, through the Cubit, by `test/presentation/cidade_selecao_screen_test.dart` and `test/presentation/cidade_selecao_cubit_test.dart`. Kept the still-valid `decidirDestinoInicial` (D-08) tests.
- **Files modified:** `test/skeleton_flow_test.dart`
- **Verification:** `flutter analyze` clean, full suite green
- **Committed in:** `77095ac` (Task 3 commit)

---

**Total deviations:** 2 auto-fixed (1 missing critical for D-06 compliance, 1 blocking test-API fix)
**Impact on plan:** Both fixes were necessary for correctness/compliance with the plan's own decisions (D-06) and for the build to compile after this task's own screen-API change. No scope creep, no architectural changes.

## Issues Encountered

**Worktree forked from a stale base (pre-dispatch, not a deviation during execution):** This executor's worktree branch (`worktree-agent-a783895081e54b19f`) was forked at `59c1501` — a commit predating Plan 01-01's execution and merge into `main` (`be1cc17`). The worktree therefore had no `pubspec.yaml`/`lib/` at all when this plan started, even though the plan `depends_on: [01-01]` and its tasks directly extend 01-01's output (`lib/di/injection.dart`, `lib/core/result.dart`, the tracer screen, etc.). Resolved by fast-forward merging `main` into the worktree branch (`git merge --ff-only main`) before any Task 1 work — the worktree branch had zero unique commits, so this was a pure, non-destructive fast-forward (no rebase, no conflict resolution). Confirmed clean via `git log main..HEAD` (empty) before merging. This is the `#2649`/`#3659` base-drift scenario the orchestrator's pre-dispatch base-check is designed to catch; flagging here in case the orchestrator's dispatch-time check needs review for this wave.

## User Setup Required

None - no external service configuration required. No auth gates encountered.

## Known Stubs

None. All gateways, the use case, the cubit, and both screens are wired to real logic (no hardcoded/mocked data paths in production code) — `assets/cidades.json`'s illustrative served-city set is a pre-existing note from Plan 01-01 (not new to this plan).

## Threat Flags

None beyond what the plan's own `<threat_model>` already covers (T-01-03-01..04) — confirmed no raw GPS coordinates are logged or persisted (`grep` for `print`/`debugPrint`/`log(` in the new gateway/use case/cubit files returns nothing), only `whileInUse` permission is requested (no `always`/background code path), and `MissingPluginException`/`UnimplementedError` are caught in `GeocodingGatewayImpl`.

## Next Phase Readiness

- LOC-01, LOC-02, LOC-03, LOC-06 satisfied: automated unit/widget tests (37 new, 42 total in the suite) cover every `<behavior>` branch and every sealed-state rendering; `flutter test`/`flutter analyze` both green.
- Device/emulator human-check (real OS permission dialog, real GPS/geocoding on Android + iOS) is intentionally deferred to end-of-phase per `workflow.human_verify_mode=end-of-phase` — queued for the phase's UAT consolidation, not a blocker for this plan.
- `CidadeSelecaoCubit.entrarDireto()` gives Plan 01-04 a ready entry point for LOC-05 (tap-to-switch-city) and for hardening D-08's saved-city validation (RESEARCH Pitfall 5 — a saved city no longer in the served list should fall back to the list rather than being trusted blindly); neither is implemented yet, both are explicitly out of this plan's `requirements`.
- `assets/cidades.json`'s served-city set still needs cross-checking against the live API repo's `Cidade.objects.filter(empresas_atuantes__ativa=True)` (Pitfall 4/A3) before Phase 2 — carried over from Plan 01-01, unchanged by this plan.

## Self-Check: PASSED

All 19 changed files verified present on disk; all three task commit hashes (`72a845f`, `2a89a2b`, `77095ac`) verified present in `git log --oneline --all`. `flutter test` (42/42) and `flutter analyze` (0 issues) re-run clean immediately before writing this summary.

---
*Phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api*
*Completed: 2026-09-22*
