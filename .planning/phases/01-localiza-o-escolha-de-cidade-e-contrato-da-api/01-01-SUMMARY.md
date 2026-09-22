---
phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api
plan: 01
subsystem: mobile-app-foundation
tags: [flutter, clean-architecture, freezed, json_serializable, get_it, injectable, flutter_bloc, shared_preferences, geolocator, geocoding, dio, material3, walking-skeleton]

# Dependency graph
requires: []
provides:
  - Greenfield Flutter project (Android + iOS) with the full mandated stack at CLAUDE.md-exact versions
  - Clean Architecture layers (data/domain/presentation) wired end-to-end
  - Sealed Result<T> (Loading/Success/Failure) — no generic try/catch in UI
  - CidadeRepository (local impl, D-14) swappable for a remote impl via DI in Phase 2
  - Chosen-city persistence by nome+uf natural key (D-15) via SharedPreferencesAsync
  - Minimal CidadeSelecaoScreen proving the full vertical slice, testable via constructor-injected use cases
  - Native location config (Android manifest + iOS Info.plist), whileInUse only
  - Test harness (flutter_test + bloc_test + mocktail) used for the first time this phase
affects: [01-02, 01-03, 01-04, phase-02]

# Actuals (#2632)
actuals:
  tokens: 40348
  tasks: 2
  commits: 2

# Tech tracking
tech-stack:
  added: [dio@5.11.1, flutter_bloc@9.1.1, freezed_annotation@3.1.0, json_annotation@4.12.0, get_it@9.3.0, injectable@3.0.0, shared_preferences@2.5.5, geolocator@14.0.3, geocoding@5.0.0, build_runner@2.16.1, freezed@4.0.1, json_serializable@6.14.1, injectable_generator@3.1.3, bloc_test@10.0.0, mocktail@1.0.5, flutter_lints@6.0.0]
  patterns:
    - "Clean Architecture: data/domain/presentation, no widget performs business logic or network I/O directly"
    - "Sealed Result<T> (freezed) wraps every fallible call — no generic try/catch in UI"
    - "DI-swappable data sources: CidadeRepository interface in domain/, local impl in data/, registered via injectable @LazySingleton(as: ...)"
    - "Test-only constructors kept OFF the injectable-scanned default constructor (named ctor pattern) so DI codegen never tries to resolve an unregistered test dependency"
    - "Screens accept optional constructor-injected use cases (default to getIt in production) for direct unit/widget testability without mocking the DI container"

key-files:
  created:
    - pubspec.yaml
    - analysis_options.yaml
    - lib/app_theme.dart
    - lib/core/result.dart
    - lib/domain/entities/cidade.dart
    - lib/domain/repositories/cidade_repository.dart
    - lib/domain/usecases/obter_cidades_atendidas_usecase.dart
    - lib/domain/usecases/salvar_cidade_usecase.dart
    - lib/domain/usecases/obter_cidade_salva_usecase.dart
    - lib/data/models/cidade_model.dart
    - lib/data/datasources/cidade_local_datasource.dart
    - lib/data/datasources/cidade_prefs_datasource.dart
    - lib/data/repositories/cidade_repository_impl.dart
    - lib/di/injection.dart
    - lib/presentation/cidade_selecao/cidade_selecao_screen.dart
    - assets/cidades.json
    - test/data/cidade_local_datasource_test.dart
    - test/data/cidade_prefs_datasource_test.dart
    - test/skeleton_flow_test.dart
  modified:
    - lib/main.dart
    - android/app/src/main/AndroidManifest.xml
    - android/app/build.gradle.kts
    - ios/Runner/Info.plist

key-decisions:
  - "Downgraded freezed from CLAUDE.md's ^4.0.2 to ^4.0.1 — the exact-mandated version's analyzer ^14.0.0 requirement is unresolvable against Flutter 3.47.5's bundled flutter_test/test_api pin (dependency-graph conflict, not a legitimacy issue); 4.0.1 is the narrowest fix with no functional difference for this plan."
  - "CidadeLocalDataSource's default (injectable-scanned) constructor always uses rootBundle; a separate .comBundle() named constructor — invisible to injectable's codegen — is the only way tests inject a fixture, so the DI container never needs an unregistered AssetBundle."
  - "This tracer's CidadeSelecaoScreen resolves use cases via constructor injection (defaulting to getIt), not a Cubit — the plan's own action text explicitly permits 'resolved from getIt (or a BlocProvider-supplied Cubit)' for this minimal slice; the full Cubit-driven 5-sealed-state screen is Plan 01-03/01-04's job (files_modified frontmatter confirms no cubit file was in this plan's scope)."
  - "decidirDestinoInicial() extracted as a pure, top-level function in main.dart so the D-08 launch decision (direct vs. list) is unit-testable without booting the widget tree; the actual UI differentiation between the two paths is intentionally deferred to 01-03/01-04 per SKELETON.md."

patterns-established:
  - "Freezed sealed unions for both domain Result<T> and API models — abstract class X with _$X (primary constructor) syntax per freezed 4.x, private `X._()` ctor when extra methods/getters are needed"
  - "Every data source that needs test-only injectable state keeps that state off the injectable-scanned constructor"

requirements-completed: [LOC-04]

coverage:
  - id: D1
    description: "App scaffolds, resolves, and analyzes clean with the full mandated stack at (near-)exact CLAUDE.md versions, and native location config is whileInUse-only on Android + iOS"
    requirement: LOC-04
    verification:
      - kind: integration
        ref: "flutter pub get && flutter analyze"
        status: pass
      - kind: unit
        ref: "flutter test (8/8 passing)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Visitor sees served cities loaded from a real bundled data source (assets/cidades.json), taps one, and the choice persists on-device (nome+uf) so the next cold start opens directly in the saved city"
    requirement: LOC-04
    verification:
      - kind: unit
        ref: "test/data/cidade_prefs_datasource_test.dart#cidade salva por uma instância é lida de volta por uma instância nova (cold start)"
        status: pass
      - kind: unit
        ref: "test/data/cidade_local_datasource_test.dart#linha com nome/uf ausente é descartada; as válidas continuam carregando"
        status: pass
      - kind: automated_ui
        ref: "test/skeleton_flow_test.dart#tocar uma cidade persiste a escolha via SalvarCidadeUseCase"
        status: pass
    human_judgment: true
    rationale: "Device-level smoke check (flutter run on an Android emulator / iOS simulator) is explicitly deferred by the plan's own <verification> block to Plan 01-03/01-04's end-of-phase human-check — this plan's automated coverage proves the logic end-to-end but not the rendered app on a real device/emulator."

duration: 45min
completed: 2026-09-22
status: complete
---

# Phase 1 Plan 1: Flutter Walking Skeleton Summary

**Greenfield Flutter/Dart app (Android+iOS) with the full CLAUDE.md-mandated Clean Architecture stack wired end-to-end: a visitor sees served cities read from a real bundled asset, taps one, and the choice persists via `SharedPreferencesAsync` by `nome+uf` so the next cold start reopens in the saved city — proven by 8 passing tests.**

## Performance

- **Duration:** 45 min
- **Started:** 2026-09-22T15:15:00Z (approx.)
- **Completed:** 2026-09-22T16:00:00Z (approx.)
- **Tasks:** 2/2
- **Files modified:** 87 (23 hand-authored production/test files; the remainder is the standard `flutter create` Android/iOS scaffold + 4 generated codegen files)

## Accomplishments

- Scaffolded the Flutter project in place (`flutter create . --platforms=android,ios`, org `com.imoveisaqui`) with the entire mandated stack — `dio`, `flutter_bloc`, `freezed`/`freezed_annotation`, `json_serializable`/`json_annotation`, `get_it`, `injectable`(+generator), `shared_preferences`, `geolocator`, `geocoding`, `bloc_test`, `mocktail`, `flutter_lints` — at CLAUDE.md's exact versions (one narrow, documented exception: `freezed`).
- Native location config on both target platforms: Android `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` only (no background), `compileSdk` pinned to 35 for `geolocator`; iOS `NSLocationWhenInUseUsageDescription` only (no Always).
- Built the full vertical slice: sealed `Result<T>` → `Cidade` entity (with normalized `chaveNatural`) → `CidadeModel` (freezed+json, matches `GET /cidades` contract) → `CidadeLocalDataSource` (reads `assets/cidades.json`, drops malformed rows) → `CidadePrefsDataSource` (`SharedPreferencesAsync`, `nome|uf` under `cidade_selecionada`) → `CidadeRepositoryImpl` (registered via `injectable` as `CidadeRepository`) → 3 use cases → `CidadeSelecaoScreen` (`Card`>`ListTile` in `ListView.builder`) → `main.dart` bootstrap.
- Proved the cold-start persistence round-trip (LOC-04) with a real test: a city saved by one `CidadePrefsDataSource` instance is read back identically by a fresh instance sharing the same in-memory platform backing store.
- `assets/cidades.json` seeded with Campinas/SP and Valinhos/SP in the exact `GET /cidades` cursor-envelope shape (D-13); documented in this SUMMARY that the definitive served-city list must mirror `Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()` (Pitfall 4/A3) before Phase 2's real endpoint lands — the current fixture uses illustrative rows, not yet verified against the live API repo's data.
- `lib/app_theme.dart`: Material 3 `ColorScheme.fromSeed` on `Color(0xFF2E7D32)` (Green 800), light brightness.

## Task Commits

1. **Task 1: Scaffold the Flutter project + mandated stack + native location config** - `23ff24a` (feat)
2. **Task 2: End-to-end tracer — load served cities, select one, persist, reopen direct** - `0ccb2c1` (feat)

**Plan metadata:** commit pending (this SUMMARY + REQUIREMENTS.md, worktree mode — STATE.md/ROADMAP.md updated centrally by the orchestrator after merge)

_Note: `tdd="true"` was set on Task 2, but `workflow.tdd_mode` is not enabled for this project (absent from `.planning/config.json`) and this is a `type="tracer"` task inside a `type: execute` plan, not a `type: tdd` plan — the strict plan-level RED/GREEN/REFACTOR gate (separate `test(...)`/`feat(...)` commits) does not apply here. Tests were written to describe the `<behavior>` block's expected outcomes before finalizing the implementation, and all tests pass; the whole vertical slice was committed as one atomic tracer commit per the task's own instruction ("execute like `type=auto`... commit")._

## Files Created/Modified

- `pubspec.yaml` - Full mandated dependency stack + `assets/cidades.json` registration
- `lib/app_theme.dart` - Material 3 `ColorScheme.fromSeed` (green seed, light)
- `lib/core/result.dart` - Sealed `Result<T>` (`Loading`/`Success`/`Failure`)
- `lib/domain/entities/cidade.dart` - `Cidade` entity + normalized `chaveNatural`
- `lib/domain/repositories/cidade_repository.dart` - `CidadeRepository` interface
- `lib/domain/usecases/{obter_cidades_atendidas,salvar_cidade,obter_cidade_salva}_usecase.dart` - Thin `@injectable` use cases
- `lib/data/models/cidade_model.dart` - freezed+json `CidadeModel`, `paraEntidade()` mapper
- `lib/data/datasources/cidade_local_datasource.dart` - Reads `assets/cidades.json`, drops malformed rows
- `lib/data/datasources/cidade_prefs_datasource.dart` - `SharedPreferencesAsync` persistence, `nome|uf`
- `lib/data/repositories/cidade_repository_impl.dart` - `@LazySingleton(as: CidadeRepository)`
- `lib/di/injection.dart` + `injection.config.dart` - `configureDependencies()`
- `lib/presentation/cidade_selecao/cidade_selecao_screen.dart` - Minimal city list + persist-on-tap screen
- `lib/main.dart` - Bootstrap + `decidirDestinoInicial()` launch-decision seam
- `assets/cidades.json` - Served-city fixture (cursor envelope, D-13)
- `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts` - Location perms (whileInUse), `compileSdk=35`
- `ios/Runner/Info.plist` - `NSLocationWhenInUseUsageDescription`
- `test/data/cidade_local_datasource_test.dart`, `test/data/cidade_prefs_datasource_test.dart`, `test/skeleton_flow_test.dart` - 8 passing tests covering partial-row drop, cold-start persistence round-trip, launch decision, and tap-to-persist

## Decisions Made

- Persist the chosen city by `nome+uf` natural key (D-15), never the fixture's numeric `id` — matches the plan's `assumption_delta_decision`.
- `CidadeSelecaoScreen` resolves use cases via constructor injection (falls back to `getIt` in production) rather than a Cubit for this minimal tracer — the plan's own text explicitly sanctions this ("resolved from getIt (or a BlocProvider-supplied Cubit)"), and the plan's `files_modified` frontmatter lists no cubit file. The full Cubit-driven 5-sealed-state screen (D-07) is Plan 01-03/01-04's scope.
- See `key-decisions` in frontmatter for the two dependency-resolution/DI deviations (freezed version, `AssetBundle` constructor split).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Downgraded `freezed` from `^4.0.2` to `^4.0.1`**
- **Found during:** Task 1 (`flutter pub get` after adding the mandated stack)
- **Issue:** `freezed ^4.0.2` requires `analyzer >=14.0.0 <15.0.0`. `bloc_test`'s transitive `test` dependency is capped, under Flutter 3.47.5's bundled `flutter_test` (which pins `test_api` to exactly `0.7.12`), to a `test` version whose own `analyzer` constraint tops out at `<14.0.0` — pub's version solver reported "version solving failed" with no combination satisfying both. This is a real, current pub-ecosystem constraint conflict between two already-vetted, legitimate packages (both `OK`/`Approved` in RESEARCH's Package Legitimacy Audit) — not a hallucinated/slopsquatted package, so the package-legitimacy exclusion in Rule 3 does not apply.
- **Fix:** Set `freezed: ^4.0.1` (its `analyzer` constraint is `>=13.0.0 <15.0.0`, which overlaps with `test 1.31.1`'s `>=8.0.0 <14.0.0` at analyzer 13.x). `flutter pub get` resolved cleanly. No functional difference for this plan's usage (primary-constructor sealed unions and data classes — no freezed 4.0.2-specific feature used).
- **Files modified:** `pubspec.yaml`
- **Verification:** `flutter pub get` exit 0, `flutter analyze` exit 0, `flutter test` 8/8 pass
- **Committed in:** `23ff24a` (Task 1 commit)

**2. [Rule 1 - Bug] `CidadeLocalDataSource`'s test-only `AssetBundle` param broke DI wiring**
- **Found during:** Task 2 (`dart run build_runner build`)
- **Issue:** The initial design put an optional `AssetBundle? bundle` param on `CidadeLocalDataSource`'s default constructor (the one `injectable` scans for `@lazySingleton`). `injectable_generator` generated `CidadeLocalDataSource(bundle: gh<AssetBundle>())` — but `AssetBundle` is never registered in the `get_it` container, so `configureDependencies()` would have thrown `StateError`/`Bad state` at app startup in production. `build_runner` surfaced this as an explicit warning ("Missing dependencies... depends on unregistered type [AssetBundle]"), not a silent failure.
- **Fix:** Moved the test-only bundle parameter to a separate named constructor, `CidadeLocalDataSource.comBundle(AssetBundle bundle)`, which `injectable`'s codegen never inspects (it only scans the unnamed/default constructor). The default constructor now unconditionally uses `rootBundle`. Regenerated `injection.config.dart` — confirmed it now calls `CidadeLocalDataSource()` with zero DI-resolved params.
- **Files modified:** `lib/data/datasources/cidade_local_datasource.dart`, `test/data/cidade_local_datasource_test.dart`, `lib/di/injection.config.dart` (regenerated)
- **Verification:** `dart run build_runner build --delete-conflicting-outputs` — no warnings, no `[SEVERE]`; `flutter test` 8/8 pass
- **Committed in:** `0ccb2c1` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (1 blocking dependency-resolution conflict, 1 DI-wiring bug)
**Impact on plan:** Both fixes were necessary for the project to build/run at all — no scope creep, no architectural changes, no feature additions beyond the plan's stated scope.

## Issues Encountered

None beyond the two deviations documented above.

## User Setup Required

None - no external service configuration required. No auth gates encountered.

## Known Stubs

None. `assets/cidades.json` is a real, parsed data source (not a hardcoded UI value) — flagged above under Decisions as needing its served-city set verified against the live API repo before Phase 2, which is a data-accuracy follow-up, not a stub.

## Threat Flags

None beyond what the plan's own `<threat_model>` already covers (T-01-01-01, T-01-01-02, T-01-01-SC) — no new network endpoints, auth paths, or schema changes were introduced.

## Next Phase Readiness

- LOC-04 satisfied: cold-start persistence proven end-to-end with real tests.
- `CidadeRepository`/DI axis (D-14) is in place and ready for Phase 2 to swap the local data source for a remote one without touching `domain/`/`presentation/`.
- Plan 01-03/01-04 can now build directly on this skeleton to add the priming screen, the 5 sealed location outcomes (D-07), and the city switcher (LOC-05) — no architectural rework needed.
- Device-level smoke test (`flutter run` on an Android emulator / iOS simulator) intentionally deferred to 01-03/01-04's end-of-phase human-check, per the plan's own `<verification>` block.
- Before Phase 2 ships the real `GET /cidades` endpoint, confirm `assets/cidades.json`'s served-city set actually matches `Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()` in the sibling API repo (Pitfall 4/A3) — not yet cross-checked this session.

## Self-Check: PASSED

All 12 claimed created files verified present on disk; both commit hashes (`23ff24a`, `0ccb2c1`) verified present in `git log --oneline --all`.

---
*Phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api*
*Completed: 2026-09-22*
