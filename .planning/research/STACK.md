# Stack Research

**Domain:** Flutter mobile "vitrine" (public property-listing browse app, no login) — Clean Architecture + Cubit, consuming a Django REST Framework public API
**Researched:** 2026-09-21
**Confidence:** HIGH (all versions verified directly against pub.dev package pages and changelogs on the research date; one official-docs cross-check against bloclibrary.dev)

This document is scoped to fill in concrete packages under the team's **already-decided, non-negotiable** stack: Flutter (latest stable) + Dart, Clean Architecture (`data/`/`domain/`/`presentation/`), Cubit (`flutter_bloc`), immutable models (`freezed`), Result/Either-style error states, Material 3. It does not re-litigate any of those decisions.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| `dio` | ^5.11.1 | HTTP client for the Django DRF API | Interceptor chain (logging, base URL, query-param filters, timeouts, retry) is exactly what a `RemoteDataSource` in Clean Architecture needs to stay a thin, single-responsibility class. `dart:http` has no interceptor concept, so every cross-cutting concern (base URL, `Content-Type`, query serialization for `GET /imoveis?cidade=...&preco_min=...`, timeout, error normalization) would be hand-rolled per call site instead of once. |
| `flutter_bloc` | ^9.1.1 (pulls `bloc` ^9.x) | Cubit-based state management | Already decided by the team. 9.1.1 is the current stable line; the 8→9 jump was mostly a `bloc` core bump plus a widget-mount safety fix — no API changes that affect a Cubit-only usage (no `Bloc`/event-transformer machinery needed here, since the team is using Cubit, not full Bloc). |
| `freezed` (+ `freezed_annotation`) | ^4.0.2 (+ ^3.x compatible `freezed_annotation`) | Immutable models, unions, `copyWith`, value equality, and (paired with `json_serializable`) the Result sealed class | Already decided by the team for models. Freezed 4.0.0 (Aug 2026) requires the Dart 3.13-era analyzer and dropped the `final` keyword inside generated constructor params — cosmetic for consumers, no migration burden for a greenfield project. Used here for **both** the API models (`Imovel`, `Cidade`) **and** the domain-level `Result<T>` sealed union (see Result/Either section). |
| `json_serializable` (+ `json_annotation`) | ^6.14.1 (+ matching `json_annotation`) | `fromJson`/`toJson` codegen paired with freezed | Freezed does not serialize JSON on its own — it still delegates to `json_serializable` via `part 'x.g.dart'` + a `factory X.fromJson(...) => _$XFromJson(json)` arrow factory. This is the only supported path to typed, codegen'd `fromJson`/`toJson` without hand-writing parsers (which the constraints explicitly forbid via "never `dynamic` where strong typing fits"). |
| `build_runner` | ^2.16.1 (dev dependency) | Runs `freezed` + `json_serializable` + `injectable_generator` codegen | One generator run covers all three annotation-driven packages. Use `dart run build_runner watch -d` during active development (regenerates `*.freezed.dart`/`*.g.dart`/`*.config.dart` on save) and `dart run build_runner build -d` in CI/pre-commit. `-d` (delete-conflicting-outputs) avoids stale generated files blocking a build after renames — expected and safe on a clean checkout. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `shared_preferences` | ^2.5.5 | Persist the user's chosen city locally, no login | Use the **new `SharedPreferencesAsync()` API**, not the legacy `SharedPreferences.getInstance()` singleton — pub.dev explicitly flags the singleton as "legacy, will be deprecated" and steers new code to `SharedPreferencesAsync`/`SharedPreferencesWithCache`. For this app it's a single string key (`cidade_selecionada_id` or similar) — no need for `flutter_secure_storage` (no credentials, no login, nothing sensitive is stored). |
| `geolocator` | ^14.0.3 | Resolve device GPS coordinates for APP01 ("descobre e entra na cidade") | Handles the **entire runtime permission flow itself** (`Geolocator.checkPermission()` / `Geolocator.requestPermission()` returning a `LocationPermission` enum: `denied`, `deniedForever`, `whileInUse`, `always`) — no separate `permission_handler` dependency is needed for this app, since location is the *only* permission it asks for. Also exposes `Geolocator.isLocationServiceEnabled()` to distinguish "permission denied" from "GPS off," both of which the spec treats as a normal fallback path (show the city list), not an error state. |
| `geocoding` | ^5.0.0 | Reverse-geocode coordinates → city name | `placemarkFromCoordinates(lat, lng)` returns a `List<Placemark>`; read `.locality` (or `.subAdministrativeArea` depending on country data quality) for the city name to match/suggest against the API's `GET /cidades` list. No API key needed — uses native `CLGeocoder` on iOS and Google Play Services `Geocoder` on Android. Same publisher (baseflow.com) as `geolocator`, so the two are maintained in lockstep. |
| `cached_network_image` | ^4.0.0 | Load + disk-cache property cover images (APP02) | Purpose-built for exactly this use case: `placeholder`/`errorWidget`/`progressIndicatorBuilder` params plus automatic disk caching via `flutter_cache_manager`, which matters a lot for a scrollable list of property cards re-showing the same images across app sessions on a visitor's mobile data plan. Note: web caching is minimal/unsupported by this package — irrelevant here since the target is Android/iOS phones, not Flutter Web. |
| `get_it` | ^9.3.0 | Service locator — wires `data/domain/presentation` layers together | Already the de-facto standard for DI in Flutter Clean Architecture setups (pairs naturally with `flutter_bloc`, which has no built-in DI opinion beyond `BlocProvider`). Registers `Dio`, data sources, repositories, use cases, and Cubits without threading constructors manually through `main.dart`. |
| `injectable` (+ `injectable_generator`) | injectable ^3.0.0, injectable_generator ^3.1.3 | Codegen for `get_it` registration | Removes the hand-maintained "register everything in `main.dart`" boilerplate that grows painfully once APP03's filter/search dependency graph (repositories → multiple use cases → one Cubit) is added. Annotate `@LazySingleton(as: ImovelRepository)` on the impl, `@injectable` on use cases/Cubits, run `build_runner`, call `getIt.init()` once at startup. Verified compatible: `injectable` 3.0.0 declares `get_it: '>=8.3.0 <10.0.0'`, which `get_it` 9.3.0 satisfies. |
| `bloc_test` (+ `mocktail`) | bloc_test ^10.0.0, mocktail ^1.0.5 (dev dependencies) | Cubit unit testing | `blocTest(...)` is the standard way to assert a Cubit's state sequence (`Loading` → `Success`/`Failure`) against a mocked use case, without spinning up widgets. `mocktail` (not `mockito`) because it needs no codegen/build_runner step — one less generator in an already-generator-heavy stack (freezed + json_serializable + injectable already run build_runner). |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| `flutter_lints` | Official Flutter/Dart lint ruleset | ^6.0.0 stable; include as dev dependency in `analysis_options.yaml`. Catches missing `const`, unused imports, and — combined with the constraint "no `dynamic` where strong typing fits" — flag `avoid_dynamic_calls` manually if not already in the default set. |
| `build_runner` watch mode | Live codegen during development | `dart run build_runner watch -d` in a dedicated terminal while editing `data/models/`, `domain/`, or DI annotations — avoids re-running the full build command after every model change. |

## Installation

```bash
# Core
flutter pub add dio flutter_bloc freezed_annotation json_annotation
flutter pub add shared_preferences geolocator geocoding
flutter pub add cached_network_image get_it injectable

# Dev dependencies (codegen + testing)
flutter pub add -d build_runner freezed json_serializable
flutter pub add -d injectable_generator
flutter pub add -d bloc_test mocktail flutter_lints
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|--------------------------|
| `dio` | `http` (dart-lang official) | Only if the app were trivially simple (one or two uncomposed GET calls, no interceptor needs). Given this app needs a base URL, query-param-driven filters (APP03), and centralized error/timeout handling across every screen, `dio`'s interceptor chain earns its dependency weight immediately. |
| Hand-rolled sealed `Result<T>` (generated via `freezed`) | `fpdart` (^1.2.0) `Either<Failure, T>` | If the team later wants monadic composition across use cases (`.map`, `.flatMap`, chaining multiple fallible steps before reaching the UI). For this app's scope — one repository call per screen action, mapped straight into a 3-state Cubit state — a plain sealed class is simpler, requires zero new library idioms for a team whose background is Java/Python OOP (per PROJECT.md), and matches the constraint's literal wording ("estados explícitos `Loading` / `Success<T>` / `Failure(Exception)`") more directly than a 2-case `Either`. |
| Hand-rolled `Cubit` + `ScrollController` pagination | `infinite_scroll_pagination` (^5.1.1) | If the team wants to skip writing the ~30 lines of scroll-listener + `hasReachedMax` boilerplate and is comfortable with a second state-owning object (`PagingController`) living alongside the Cubit. The official `bloclibrary.dev` "Infinite List" tutorial uses the hand-rolled pattern precisely because it keeps *all* list state (including `hasReachedMax`) inside the Cubit's single immutable state object — which is what this project's "imutabilidade estrita nos estados de tela" constraint calls for. |
| Hand-rolled `Timer`-based `Debouncer` | `easy_debounce` (^2.0.3) | If the team wants a one-line `EasyDebounce.debounce(...)` call instead of a ~15-line utility class. The hand-rolled version is trivial, has zero extra dependency surface, and is fully unit-testable inside the `presentation/` Cubit without mocking a plugin. |
| `get_it` + `injectable` | `get_it` alone (manual registration) | Fine while the dependency graph is small (APP01 only: one repository, one use case, one Cubit). Once APP02+APP03 add search/sort/filter use cases and their own Cubits, manual registration in `main.dart` becomes a maintenance tax that `injectable`'s codegen removes for the cost of one more `build_runner` target you're already running. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|--------------|
| `http` (dart-lang official package) as the sole HTTP layer | No interceptor concept — every cross-cutting concern (base URL, query-param filter serialization, logging, timeout, error mapping into the app's `Result`/sealed-class model) has to be re-implemented per call or wrapped by hand, which is exactly the kind of boilerplate a `RemoteDataSource` should not own. | `dio` |
| `dartz` | Last published **4 years ago** (version 0.10.1) — effectively unmaintained. Using it in a greenfield 2026 project locks the team to an abandoned functional-programming library with no Dart 3 pattern-matching ergonomics. | Hand-rolled sealed `Result<T>` (generated via `freezed`), or `fpdart` if functional composition is truly needed |
| `permission_handler` for *only* location permission | `geolocator` already owns the full permission request/check flow (`checkPermission()`/`requestPermission()`) for location specifically — adding `permission_handler` on top is a redundant second permission API for a single permission type. | `geolocator`'s built-in `LocationPermission` API |
| `equatable` alongside `freezed` | Freezed already generates `==`/`hashCode`/`toString` for every model and for the `Result`/Cubit-state unions. Adding `equatable` on top of freezed classes (or on Cubit states that are already freezed unions) is a redundant second equality mechanism with no added value — reserve `equatable` only for plain Dart classes the team chooses *not* to run through freezed. | `freezed`'s generated equality |
| `SharedPreferences.getInstance()` (legacy singleton API) | pub.dev's own package description flags this as the legacy API "that will be deprecated in the future" and explicitly recommends new code use the newer API instead. | `SharedPreferencesAsync()` (same `shared_preferences` package, new API surface) |
| `mockito` for Cubit/use-case tests | Requires its own `build_runner` codegen target (`@GenerateMocks`) — stacking a fourth generator (after freezed, json_serializable, injectable_generator) for something `mocktail` does with zero codegen. | `mocktail` |
| `Provider` for this app's state management | Constraint explicitly lists `Cubit (flutter_bloc)` as the primary choice (`Provider` only appears as a loose "or" in the original constraint wording, but the team's PROJECT.md and downstream architecture description settle on Cubit specifically — mixing both introduces two different state-management mental models in the same app for no benefit here). | `flutter_bloc` Cubit, consistently across `presentation/` |

## Stack Patterns by Variant

**If APP03's filters grow to include multiple simultaneous facets (finalidade, natureza, faixa de preço, quartos, suítes, vagas, bairro, faixa de área, características):**
- Model the filter state as its own small immutable `freezed` class (e.g. `FiltrosVitrine`) with a `toQueryParameters()` method, rather than passing 8+ loose parameters into the repository method.
- Because filtering/sorting/search are all server-side (per PROJECT.md — "nada é recalculado dentro do aparelho"), the repository's single job is turning `FiltrosVitrine` + pagination cursor into `dio`'s `queryParameters` map and parsing the paged response — keep that logic entirely inside `data/`, never in `presentation/`.

**If offline/poor-connectivity handling becomes a requirement in a later milestone:**
- Add `connectivity_plus` only then — it's out of scope for the current three tasks (APP01–03) and not justified by today's requirements.

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|------------------|-------|
| `freezed@^4.0.2` | `freezed_annotation` (matching 3.x line), `json_serializable@^6.14.1`, `build_runner@^2.16.1` | Freezed 4.0.0 raised its minimum analyzer requirement — run `flutter pub upgrade` after adding, and make sure the Flutter SDK is current-stable (already a non-negotiable constraint) so the bundled Dart SDK satisfies it. |
| `injectable@^3.0.0` | `get_it: '>=8.3.0 <10.0.0'` (per injectable's own pubspec constraint) | `get_it@^9.3.0` satisfies this range — confirmed directly from injectable's published dependency constraint, not assumed. Re-check this range if `get_it` crosses 10.0.0 in the future. |
| `injectable_generator@^3.1.3` | `injectable@^3.0.0`, `build_runner@^2.16.1` | Keep `injectable` and `injectable_generator` on matching major versions; they're published by the same maintainer and versioned together. |
| `geolocator@^14.0.3` | `geocoding@^5.0.0` | Both published by baseflow.com and commonly used as a pair; no direct dependency between them, but both require Android `compileSdkVersion 35`+ and the standard `NSLocationWhenInUseUsageDescription` iOS Info.plist entry (geolocator) — geocoding adds no extra native setup (no API key, uses native `CLGeocoder`/Play Services `Geocoder`). |
| `bloc_test@^10.0.0` | `flutter_bloc@^9.1.1` (via shared `bloc` core) | Confirm `bloc_test`'s `bloc` constraint isn't pinned below the `bloc` version `flutter_bloc@^9.1.1` pulls in when running `flutter pub get`; resolve any conflict by letting pub's version solver pick, not manual pinning. |

## Sources

- pub.dev package pages (fetched directly, 2026-09-21) — `dio`, `freezed`, `json_serializable`, `flutter_bloc`, `fpdart`, `shared_preferences`, `geolocator`, `geocoding`, `infinite_scroll_pagination`, `cached_network_image`, `get_it`, `injectable`, `injectable_generator`, `permission_handler`, `easy_debounce`, `build_runner`, `equatable`, `flutter_lints`, `bloc_test`, `mocktail`, `dartz` — HIGH confidence (primary/official registry, versions and publish dates read directly off each package's current listing).
- pub.dev changelog pages — `freezed`, `equatable`, `get_it`, `flutter_bloc` — HIGH confidence (official changelogs, used to confirm recency and breaking-change scope of each current major version).
- `bloclibrary.dev` — "Flutter Infinite List" tutorial — HIGH confidence (official `flutter_bloc` maintainer documentation; used to justify the hand-rolled `ScrollController` + Cubit pagination pattern over the `infinite_scroll_pagination` package).
- Project-internal: `.planning/PROJECT.md` (this repo) and `../imoveis-aqui/README.md` (sibling Django API repo) — used to scope the exact endpoints (`GET /cidades`, `GET /imoveis?cidade=...`), the no-login/no-auth constraint (ruling out `flutter_secure_storage`/token-refresh interceptors), and the explicit Result/Either and Cubit wording that shaped the Result-pattern recommendation.

---
*Stack research for: Flutter real-estate vitrine mobile app (Clean Architecture + Cubit, DRF public API consumer)*
*Researched: 2026-09-21*
