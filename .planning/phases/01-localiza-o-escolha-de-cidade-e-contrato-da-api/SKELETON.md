# Walking Skeleton — Imóveis Aqui (App Vitrine)

**Phase:** 1
**Generated:** 2026-09-21

## Capability Proven End-to-End

> One sentence: the smallest user-visible capability that exercises the full stack.

A visitor opens the app, sees the list of served cities loaded from a real bundled data source
(`assets/cidades.json`), taps one, and that choice is persisted on-device (`nome+uf`) so the next
cold start opens directly in the saved city — proving scaffold → data source → repository → DI →
Cubit → UI → local persistence end-to-end, on an Android/iOS device or emulator.

## Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Framework | Flutter (latest stable) + Dart 3, Material 3 | Team-mandated stack (CLAUDE.md). Ships to Android + iOS (dev machines are macOS M1 / Windows — desktop is dev-only, per the session's authoritative target-platform correction). |
| Architecture | Clean Architecture — `data/` / `domain/` / `presentation/` | Non-negotiable constraint. No widget performs business logic or network I/O directly. |
| State management | `flutter_bloc` Cubit (^9.1.1), strict immutable states | Team-mandated. Screen state is a `freezed` sealed union. |
| Models / equality | `freezed` (^4.0.2) + `json_serializable` (^6.14.1) via `build_runner` (^2.16.1) | Immutable typed models with codegen `fromJson`/`toJson`. No `equatable` on top (redundant). |
| Error model | `freezed` sealed `Result<T>` — `Loading` / `Success<T>` / `Failure(Exception)` | Matches the literal constraint wording; every fallible call is wrapped, no generic `try/catch` in UI. |
| HTTP client (reserved) | `dio` (^5.11.1) | Declared in `pubspec.yaml` for Phase 2; NOT wired to any live endpoint in Phase 1 (see COVERAGE.md). |
| Local persistence | `shared_preferences` (^2.5.5) via the new `SharedPreferencesAsync()` API | Single non-sensitive key `cidade_selecionada` holding the chosen city `nome+uf` natural key (D-15). No login, no secrets. |
| Location | `geolocator` (^14.0.3) + `geocoding` (^5.0.0), request `whileInUse` only | On-device OS plugins. Reverse geocoding is a first-class path on Android + iOS. Added in slice Plan 01-03, not the skeleton itself. |
| Dependency injection | `get_it` (^9.3.0) + `injectable` (^3.0.0) codegen | Swappable-by-DI local→remote data source is the architecture's axis (API-04); applied to cities now (D-14). |
| City list source-of-truth | Local `assets/cidades.json` (D-13), same shape as `GET /cidades` (cursor envelope) | Phase 2 swaps the local `DataSource` for a remote one via DI without touching UI/Cubit/domain. Served-set filter rule documented in the contract (Pitfall 4). |
| Testing | `flutter_test` + `bloc_test` (^10.0.0) + `mocktail` (^1.0.5) | Cubit state-sequence assertions against mocked use cases; no codegen for mocks. |
| Directory layout | `lib/{core,di,data,domain,presentation}` + `assets/` + `test/` mirroring `lib/` | Per RESEARCH §Recommended Project Structure. |

## Stack Touched in Phase 1

- [x] Project scaffold (`flutter create`, `pubspec.yaml`, `analysis_options.yaml` with `flutter_lints`, `build_runner` codegen, `test/` runner) — Plan 01-01
- [x] Routing — single linear flow (skeleton: saved-city-or-list; expanded in 01-03/01-04 to priming → selection). No `NavigationRail` this phase.
- [x] Real data read — `CidadeLocalDataSource` reads `assets/cidades.json` (Plan 01-01)
- [x] Real data write — `CidadePrefsDataSource` persists chosen `nome+uf` via `SharedPreferencesAsync` (Plan 01-01)
- [x] UI wired to the data layer — `CidadeSelecaoScreen` lists cities from the repository; tap persists (Plan 01-01)
- [x] Runs on dev environment — documented local run: `flutter run` on an Android emulator or iOS simulator (full Xcode required for iOS)

## Out of Scope (Deferred to Later Slices)

> Anything that is *not* in the skeleton. This list prevents future phases from re-litigating Phase 1's minimalism.

- Location detection (GPS + reverse geocoding), the priming screen, and the 5 sealed location outcomes — added as a slice in Plan 01-03 (still Phase 1, but not the bare skeleton).
- City switcher header + returning-visitor validation — Plan 01-04 (still Phase 1).
- Real `GET /cidades` endpoint replacing the local asset — Phase 2 (VIT-06 / API-02); the local `DataSource` is swapped for a remote one via DI.
- Property listing / vitrine, search, sort, pagination — Phase 2 (VIT-01..05).
- Server-side filters + chips — Phase 3 (FIL-01..06).
- Real `GET /imoveis` endpoint + mock→real `DataSource` swap — Phase 4 (API-03 / API-04).
- Dark mode, `NavigationRail`, `cached_network_image`, `connectivity_plus` — not justified by Phase 1 requirements.

## Subsequent Slice Plan

Each later phase adds one vertical slice on top of this skeleton without altering its architectural decisions:

- Phase 2: The visitor browses a paginated, searchable, sortable vitrine of the chosen city; cities now come from the real `GET /cidades`; imóveis served by a swappable mock `DataSource` honoring the frozen contract.
- Phase 3: The visitor refines the vitrine with the full server-side filter set (finalidade, natureza, faixas, características) with active chips and consistent pagination.
- Phase 4: The API exposes the real `/imoveis` endpoint; the app swaps the mock `DataSource` for the real one via a one-line DI change, no UI/Cubit/domain edits.
