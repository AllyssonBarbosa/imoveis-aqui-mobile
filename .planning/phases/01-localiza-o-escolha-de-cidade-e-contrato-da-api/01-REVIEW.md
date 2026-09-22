---
phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api
reviewed: 2026-09-22T00:00:00Z
depth: standard
files_reviewed: 30
files_reviewed_list:
  - lib/core/result.dart
  - lib/app_theme.dart
  - lib/main.dart
  - lib/di/injection.dart
  - lib/domain/entities/cidade.dart
  - lib/domain/repositories/cidade_repository.dart
  - lib/domain/gateways/geolocator_gateway.dart
  - lib/domain/gateways/geocoding_gateway.dart
  - lib/domain/usecases/obter_cidades_atendidas_usecase.dart
  - lib/domain/usecases/obter_cidade_salva_usecase.dart
  - lib/domain/usecases/salvar_cidade_usecase.dart
  - lib/domain/usecases/detectar_cidade_usecase.dart
  - lib/domain/usecases/validar_cidade_atendida_usecase.dart
  - lib/data/models/cidade_model.dart
  - lib/data/datasources/cidade_local_datasource.dart
  - lib/data/datasources/cidade_prefs_datasource.dart
  - lib/data/repositories/cidade_repository_impl.dart
  - lib/data/gateways/geolocator_gateway_impl.dart
  - lib/data/gateways/geocoding_gateway_impl.dart
  - lib/data/constants/uf_lookup.dart
  - lib/presentation/cidade_selecao/cidade_selecao_cubit.dart
  - lib/presentation/cidade_selecao/cidade_selecao_state.dart
  - lib/presentation/cidade_selecao/cidade_selecao_screen.dart
  - lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart
  - lib/presentation/priming/priming_screen.dart
  - pubspec.yaml
  - analysis_options.yaml
  - assets/cidades.json
  - android/app/src/main/AndroidManifest.xml
  - ios/Runner/Info.plist
findings:
  critical: 3
  warning: 2
  info: 3
  total: 8
status: issues
---

# Phase 1: Code Review Report

**Reviewed:** 2026-09-22
**Depth:** standard
**Files Reviewed:** 30
**Status:** issues

## Summary

Phase 1 (LOC-01..LOC-06) implements a clean, well-tested vertical slice: sealed `Result<T>`, a sealed 8-variant `CidadeSelecaoState`, gateway wrappers over `geolocator`/`geocoding` statics, and a Cubit-driven permission state machine. `flutter analyze` is clean and 53 tests pass, but the test suite exercises only the "happy paths" and the explicitly-modeled failure branches (`Result.failure`) — it does not exercise malformed/mistyped input data or platform-channel exceptions thrown outside the methods that already have `try/catch`. Tracing those paths by hand surfaces three real crash/hang risks that bypass the app's own "never a generic exception, always an explicit state" design promise, plus a genuine Clean Architecture layering violation (domain importing presentation) that the plan's own SUMMARY documents as an intentional decision rather than flagging as a constraint conflict.

## Critical Issues

### CR-01: Malformed/mistyped JSON in the served-city data source crashes instead of degrading to `erroCarregarCidades`

**File:** `lib/data/repositories/cidade_repository_impl.dart:22-28` (catch clause), root cause in `lib/data/datasources/cidade_local_datasource.dart:31-45`
**Issue:** `CidadeRepositoryImpl.obterCidadesAtendidas()` only catches `on Exception` around `_local.obterCidades()`. But `CidadeLocalDataSource.obterCidades()` performs several unguarded type casts — `jsonDecode(conteudo) as Map<String, dynamic>` (line 32), `envelope['results'] as List<dynamic>?` (line 33), `linha as Map<String, dynamic>` (line 37), `mapa['nome'] as String?` / `mapa['uf'] as String?` (lines 38-39) — and `CidadeModel.fromJson(mapa)` (line 44) itself does a further typed cast for `id`. Every one of these throws a `TypeError`, which is a subtype of `Error`, **not** `Exception` in Dart — so `on Exception catch` does not catch it, and the exception propagates uncaught out of `obterCidadesAtendidas()`, `DetectarCidadeUseCase.call()`, `ValidarCidadeAtendidaUseCase.call()`, and `CidadeSelecaoCubit._emitirComListaAtendida()`, none of which have their own try/catch either.
**Concrete failure scenario:** A future edit to `assets/cidades.json` (or, after Phase 2, a live `GET /cidades` response) that sends `"nome": 123` (a number instead of a string) for one row, or a `results` value that isn't a JSON array, or a row that isn't a JSON object, crashes the app the very first time it loads the served-city list — i.e., on essentially every cold start — instead of falling back to the already-built `erroCarregarCidades` state. This directly contradicts the in-code comment "// Linha descartada: nome/uf ausente — **nunca crash**" (line 41), which is only true for `null`/empty values, not for wrong-typed values.
**Fix:**
```dart
// cidade_local_datasource.dart — validate shape defensively instead of blind casts
for (final linha in linhas) {
  if (linha is! Map<String, dynamic>) continue;
  final nome = linha['nome'];
  final uf = linha['uf'];
  if (nome is! String || nome.isEmpty || uf is! String || uf.isEmpty) continue;
  cidades.add(CidadeModel.fromJson(linha));
}

// cidade_repository_impl.dart — widen the catch to cover parsing/type errors too
} on Object catch (erro) {
  return Result.failure(erro is Exception ? erro : Exception(erro.toString()));
}
```

### CR-02: `GeolocatorGatewayImpl.isServicoHabilitado()` has no error handling — a platform exception leaves the user stuck on the loading spinner forever

**File:** `lib/data/gateways/geolocator_gateway_impl.dart:12-13`
**Issue:** Every other method on this class (`verificarPermissao`, `solicitarPermissao`, `obterPosicaoAtual`) wraps the underlying `geolocator` static call in `try/catch` and maps failures to an explicit `GatewayPermissaoLocalizacao`/`Result`. `isServicoHabilitado()` is the sole exception: `Future<bool> isServicoHabilitado() => Geolocator.isLocationServiceEnabled();` has no guard at all. It is the very first call made by `CidadeSelecaoCubit.detectarCidade()` (`lib/presentation/cidade_selecao/cidade_selecao_cubit.dart:39`), right after `emit(const CidadeSelecaoState.localizando())`.
**Concrete failure scenario:** If the location plugin's platform channel throws for this call (plausible on the same class of devices/OSes the code's own comments call out elsewhere as throwing `PlatformException` for `checkPermission`, e.g. certain Windows/desktop or misconfigured Android setups), `detectarCidade()`'s `Future` completes with an unhandled error. Because `PrimingScreen._aoTocarUsarLocalizacao` invokes it as `unawaited(cubit.detectarCidade())` (`lib/presentation/priming/priming_screen.dart:61`), nothing observes that error — the Cubit never emits past its initial `localizando` state, and the user is left staring at "Localizando você…" indefinitely with no retry affordance and no error UI, directly violating LOC-06/D-07's guarantee that every location outcome has its own explicit state.
**Fix:**
```dart
@override
Future<bool> isServicoHabilitado() async {
  try {
    return await Geolocator.isLocationServiceEnabled();
  } on Exception {
    // Trate como "serviço desligado": mesmo desfecho prático (cair na lista).
    return false;
  }
}
```

### CR-03: App launch path has no error handling around reading the saved city — a `SharedPreferencesAsync` failure crashes/hangs the app before any UI renders

**File:** `lib/main.dart:69-76`
**Issue:** `_TelaInicialState._carregar()` calls `await _obterCidadeSalva()` (which resolves to `CidadeRepositoryImpl.obterCidadeSalva()` → `CidadePrefsDataSource.obterSalva()` → `SharedPreferencesAsync().getString(...)`) with no try/catch anywhere in that chain. `CidadeRepository.salvarCidade`/`obterCidadeSalva` are the only two repository methods in the whole codebase that are *not* `Result`-wrapped (contrast with `obterCidadesAtendidas`, which is defensively wrapped in `CidadeRepositoryImpl`).
**Concrete failure scenario:** This is the very first async call the app makes after `runApp()`, on `initState`, before any user interaction. If the platform channel backing `shared_preferences` throws (e.g., a corrupted preferences store, a plugin registration race on a cold boot, or a platform quirk), the `Future` returned by `_carregar()` completes with an unhandled error and `setState` is never reached — the app is stuck on the `CircularProgressIndicator` forever with no way to recover, on every subsequent launch, since nothing ever persists a "safe" fallback state.
**Fix:**
```dart
Future<void> _carregar() async {
  Cidade? salva;
  try {
    salva = await _obterCidadeSalva();
  } catch (_) {
    salva = null; // Degrada para o fluxo "sem cidade salva" (PrimingScreen).
  }
  if (!mounted) return;
  setState(() {
    _cidadeSalva = salva;
    _carregando = false;
  });
}
```
Longer-term, wrap `CidadeRepository.salvarCidade`/`obterCidadeSalva` in `Result<T>` like every other fallible call in the codebase, per the project's own "Erros de API: padrão Result/Either... estados explícitos" constraint (CLAUDE.md).

## Warnings

### WR-01: Domain layer imports the presentation layer, violating the project's non-negotiable Clean Architecture layering

**File:** `lib/domain/usecases/detectar_cidade_usecase.dart:5`, `lib/domain/usecases/validar_cidade_atendida_usecase.dart:4`
**Issue:** Both use cases `import '../../presentation/cidade_selecao/cidade_selecao_state.dart'` and return `CidadeSelecaoState` directly from `domain/`. CLAUDE.md states the Clean Architecture layering (`data/`, `domain/`, `presentation/`) is "Não negociável," and explicitly describes `domain/` as holding "UseCases puros" — pure use cases must not depend on a `presentation/`-layer type. Here the dependency arrow points the wrong way: `presentation/cidade_selecao_cubit.dart` depends on `domain/detectar_cidade_usecase.dart`, which in turn depends back on `presentation/cidade_selecao_state.dart`. This is documented in the Plan 01-03 SUMMARY as an intentional "key-decision" ("keeps the Cubit a thin orchestrator"), but a convenience trade-off doesn't resolve the underlying constraint violation.
**Concrete failure scenario:** Any attempt to reuse `DetectarCidadeUseCase`/`ValidarCidadeAtendidaUseCase` from a different presentation surface (a future web/desktop UI, a second Cubit, or a plain Dart script/CLI tool for QA) requires pulling in the entire `presentation/cidade_selecao/` module and its Flutter/freezed dependencies just to get a domain-level "is this city served?" answer. It also means every time a new UI outcome is added to `CidadeSelecaoState` (a presentation concern), `domain/` files must change too — the dependency rule that Clean Architecture exists to enforce (inner layers never know about outer layers) is broken.
**Fix:** Introduce a narrow domain-level result type (e.g., a small sealed `DeteccaoResultado` with variants `servida(Cidade)` / `naoServida(String, List<Cidade>)` / `falhaGeocodificacao(List<Cidade>)` / `falhaCarregarLista()`), have the use cases return that, and let `CidadeSelecaoCubit` map it onto `CidadeSelecaoState` at the presentation boundary — restoring the correct dependency direction.

### WR-02: `CidadeRepository.salvarCidade`/`obterCidadeSalva` bypass the codebase's `Result<T>` error-handling convention entirely

**File:** `lib/domain/repositories/cidade_repository.dart:10,12`, `lib/data/repositories/cidade_repository_impl.dart:31-41`
**Issue:** Every other fallible operation in this codebase (`obterCidadesAtendidas`, `obterPosicaoAtual`, `cidadeDeCoordenadas`) is wrapped in `Result<T>` per CLAUDE.md's explicit "Erros de API: padrão Result/Either... estados explícitos Loading/Success<T>/Failure(Exception)" rule. `salvarCidade` returns a bare `Future<void>` and `obterCidadeSalva` returns a bare `Future<Cidade?>`, with zero error handling in `CidadeRepositoryImpl` (no try/catch at all). This is the direct root cause enabling CR-03.
**Concrete failure scenario:** A `SharedPreferencesAsync.setString`/`getString` failure (disk full, platform channel not yet ready, corrupted store) surfaces as a raw unhandled exception anywhere these are awaited (`main.dart`, `CidadeSelecaoScreen._selecionarCidade`), rather than a `Result.failure` the caller can render an explicit state for — inconsistent with the pattern established everywhere else in the same file/class.
**Fix:** Wrap both methods in `Result<T>` (or at minimum add `try/catch` returning a sentinel/null on failure) so persistence failures degrade gracefully instead of propagating as unhandled exceptions.

## Info

### IN-01: Accent-normalization logic is duplicated verbatim in two unrelated files

**File:** `lib/domain/entities/cidade.dart:17-27` (`Cidade._normalizar`) and `lib/data/constants/uf_lookup.dart:65-74` (`UfLookup._semAcentos`)
**Issue:** Both private methods implement the exact same `comAcento`/`semAcento` character-substitution algorithm independently. This is a DRY violation with drift risk — if one is fixed/extended (e.g., to handle a missed accented character) the other silently stays out of sync, and `Cidade.chaveNatural`'s matching (D-09) and `UfLookup.normalizarUf`'s state-name matching (Pitfall 2) could then diverge on the exact same input string.
**Fix:** Extract a single shared `String removerAcentos(String valor)` utility (e.g., in `lib/core/` or a small `text_normalizer.dart`) and have both call sites use it.

### IN-02: Dead `case Loading():` branches across three call sites, since no data source ever produces `Result.loading()`

**File:** `lib/presentation/cidade_selecao/cidade_selecao_cubit.dart:105-106`, `lib/domain/usecases/detectar_cidade_usecase.dart:34,44,57`, `lib/domain/usecases/validar_cidade_atendida_usecase.dart:43-44`
**Issue:** All three switches over a `Result<T>` include a `case Loading():` branch, but `CidadeRepositoryImpl`/`GeolocatorGatewayImpl`/`GeocodingGatewayImpl` never return `Result.loading()` — only `Result.success`/`Result.failure`. These branches are unreachable in practice (required only because the switch must be exhaustive over the sealed `Result<T>` union).
**Fix:** No functional change needed (exhaustiveness requires handling every variant), but consider a one-line comment at each site noting `Loading` is structurally required but never actually produced by this call chain, to save the next reader from tracing the same dead path.

### IN-03: `CidadePrefsDataSource`'s `nome|uf` string encoding is fragile to a literal `|` in a city name

**File:** `lib/data/datasources/cidade_prefs_datasource.dart:18-30`
**Issue:** The chosen city is persisted as a single string `'$nome|$uf'` and parsed back with `valor.split('|')`, discarding the value entirely (returning `null`, silently falling back to "no saved city") if `partes.length != 2`. Currently low-risk since city names come from a controlled asset/API list, but there's no guard preventing a future served-city name containing `|` (or a multi-word name that happens to include the delimiter) from silently breaking persistence — the user's saved city would appear to reset without any error surfaced.
**Fix:** Use a delimiter guaranteed not to appear in city names (e.g., JSON-encode `{"nome":..., "uf":...}` instead of manual string concatenation), or assert/validate on `salvar()` that neither field contains the delimiter.

---

_Reviewed: 2026-09-22_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
