---
phase: 01-localiza-o-escolha-de-cidade-e-contrato-da-api
verified: 2026-09-22T00:00:00Z
status: human_needed
score: 12/12 must-haves verified (2 caveated as advisory — see Anti-Patterns)
covered_files:
  - ".planning/REQUIREMENTS.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-01-PLAN.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-01-SUMMARY.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-02-PLAN.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-02-SUMMARY.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-03-PLAN.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-03-SUMMARY.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-04-PLAN.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-04-SUMMARY.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-REVIEW.md"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/cidades.example.json"
  - ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imoveis.example.json"
  - "analysis_options.yaml"
  - "android/app/build.gradle.kts"
  - "android/app/src/main/AndroidManifest.xml"
  - "assets/cidades.json"
  - "ios/Runner/Info.plist"
  - "lib/app_theme.dart"
  - "lib/core/result.dart"
  - "lib/data/constants/uf_lookup.dart"
  - "lib/data/datasources/cidade_local_datasource.dart"
  - "lib/data/datasources/cidade_prefs_datasource.dart"
  - "lib/data/gateways/geocoding_gateway_impl.dart"
  - "lib/data/gateways/geolocator_gateway_impl.dart"
  - "lib/data/models/cidade_model.dart"
  - "lib/data/repositories/cidade_repository_impl.dart"
  - "lib/di/injection.config.dart"
  - "lib/di/injection.dart"
  - "lib/domain/entities/cidade.dart"
  - "lib/domain/gateways/geocoding_gateway.dart"
  - "lib/domain/gateways/geolocator_gateway.dart"
  - "lib/domain/repositories/cidade_repository.dart"
  - "lib/domain/usecases/detectar_cidade_usecase.dart"
  - "lib/domain/usecases/obter_cidade_salva_usecase.dart"
  - "lib/domain/usecases/obter_cidades_atendidas_usecase.dart"
  - "lib/domain/usecases/salvar_cidade_usecase.dart"
  - "lib/domain/usecases/validar_cidade_atendida_usecase.dart"
  - "lib/main.dart"
  - "lib/presentation/cidade_selecao/cidade_selecao_cubit.dart"
  - "lib/presentation/cidade_selecao/cidade_selecao_screen.dart"
  - "lib/presentation/cidade_selecao/cidade_selecao_state.dart"
  - "lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart"
  - "lib/presentation/priming/priming_screen.dart"
  - "pubspec.yaml"
covered_digest: "v1:sha256:c028180a247d0aea9b7cb956319f6a41f2a32e867af92be5f1253f1473313eec"
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "On an Android emulator and an iOS simulator (flutter run): first launch → confirm the priming screen shows and the native OS permission prompt fires only after tapping 'Usar minha localização', never before/on init."
    expected: "No permission dialog appears until the CTA is tapped; tapping it triggers the real OS prompt."
    why_human: "Requires a real device/emulator and the actual OS permission dialog — not observable via static analysis or widget tests (mocked gateways stand in for the OS in the automated suite)."
  - test: "Exercise all 5 location outcomes on a real emulator/simulator: allow+served city, allow+unserved city, deny, block-forever (tap 'Ativar localização nas Ajustes' and confirm it opens system settings), and turn the device's location service off."
    expected: "Each outcome shows its own dedicated screen/copy; none shows a generic error screen or a dead end; the Ajustes CTA actually opens the OS settings app."
    why_human: "Requires real GPS/geocoding hardware behavior and real OS settings navigation — the automated suite mocks GeolocatorGateway/GeocodingGateway, so it proves the code path is reachable but not that the real OS integration behaves as coded."
  - test: "After entering a city, tap the '{Cidade}, {UF}' header at the top; confirm it reopens the city list WITHOUT any location permission prompt, then pick a different city and confirm it updates the header and survives a cold restart (kill and reopen the app)."
    expected: "No permission prompt on tap; new city persists across a genuine process restart, not just an in-memory Cubit state change."
    why_human: "A real cold restart (killing and relaunching the OS process) cannot be simulated by `flutter test`'s in-memory widget harness; the automated suite proves persistence round-trips at the SharedPreferencesAsync layer, not an end-to-end OS-level relaunch."
  - test: "Simulate a geocoding failure (airplane mode / no network path for reverse geocoding, or run on a platform without geocoding support) and confirm the app shows 'Não conseguimos identificar sua localização automaticamente. Escolha sua cidade abaixo.' rather than freezing or crashing."
    expected: "falhaGeocodificacao state renders; no hang, no crash."
    why_human: "Requires reproducing a real platform-channel failure condition outside the mocked test harness."
  - test: "Copy 01-CONTRATO-API.md into the sibling ../imoveis-aqui/Web repo and obtain explicit web-team (E2) sign-off on the 4 flagged open items (quartos/suites/vagas semantics, cidade param format, VENDA_E_ALUGUEL card price, ordenacao enum values)."
    expected: "The contract is copied to the sibling repo and the web team explicitly agrees to the frozen shape and the pending items' resolution — only then is the contract truly 'congelado' per the roadmap's Success Criterion 5 ('escrito e acordado com a frente web')."
    why_human: "This is a real cross-team coordination step (a human conversation/sign-off with a colleague on another repo) that cannot be verified from this codebase alone. The written half of API-01 is done and grounded in the real sibling models; the 'acordado' (agreed) half is explicitly still outstanding per the 01-02-SUMMARY.md's own 'Next Phase Readiness' note."
---

# Phase 1: Localização, Escolha de Cidade e Contrato da API — Verification Report

**Phase Goal:** O visitante abre o app e entra numa cidade atendida — por localização ou por
escolha manual — com a cidade guardada e trocável a qualquer momento; em paralelo, o contrato de
`GET /cidades` e `GET /imoveis` fica escrito e congelado para orientar as fases seguintes.
**Verified:** 2026-09-22
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

Merged from ROADMAP.md Success Criteria (5) and the 4 plans' `must_haves.truths` frontmatter
(deduplicated where a plan truth restates a roadmap SC).

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Primeira abertura pede permissão de localização só a partir do toque no CTA da tela de priming — nunca em `initState` (LOC-01, D-05) | ✓ VERIFIED | `lib/presentation/priming/priming_screen.dart:57-61` — `_aoTocarUsarLocalizacao` is the sole call site of `cubit.detectarCidade()`; `CidadeSelecaoCubit` constructor does not call it. `test/presentation/priming_screen_test.dart` (9 tests) asserts nothing fires before the tap and `requestPermission` fires exactly once after. |
| 2 | Autorizada, o app faz reverse geocoding e entra direto na cidade se atendida; se não atendida, cai no fallback de escolha (LOC-02, D-09/D-10/D-11) | ✓ VERIFIED | `lib/domain/usecases/detectar_cidade_usecase.dart` orchestrates GPS→geocode→`chaveNatural` match; `test/domain/detectar_cidade_usecase_test.dart` covers matched→`autorizadaEAtendida`, unmatched→`autorizadaNaoAtendida` with detected name + full list. |
| 3 | Recusada ou bloqueada, o app mostra a lista de cidades atendidas — caminho normal, nunca uma tela de erro (LOC-03) | ✓ VERIFIED | `CidadeSelecaoCubit.detectarCidade()` routes `negada`/`indeterminada`→`recusada`, `negadaParaSempre`→`bloqueadaParaSempre`, both rendering `_CorpoLista` (list), never an error widget. `cidade_selecao_screen_test.dart` asserts distinct, non-apologetic UI for `recusada` and the "Ativar localização nas Ajustes" CTA for `bloqueadaParaSempre`. |
| 4 | Cada um dos desfechos de localização é um estado explícito da sealed union com UI própria, nunca uma exceção genérica (LOC-06, D-07) | ✓ VERIFIED | `lib/presentation/cidade_selecao/cidade_selecao_state.dart` — 8-variant `@freezed sealed class`; `cidade_selecao_screen.dart`'s `build()` is an exhaustive `switch` (no `default` — Dart 3 compiler-enforced). `cidade_selecao_screen_test.dart` pumps all 8 states and asserts distinct UI + no `ErrorWidget`. **Caveat:** see Anti-Patterns CR-01/CR-02 — the *reachability* of this guarantee depends on upstream code catching every failure as an `Exception`; two real gaps (non-`Exception` `TypeError`/`Error` from malformed JSON, and an unguarded `isServicoHabilitado()` call) can bypass this state machine entirely for inputs outside what's currently tested. This does not fail the truth for the app's current, valid `assets/cidades.json` and the exact failure modes the plan's own tests cover, but it is a real crack in the "never a generic exception" promise — flagged, not scored as a blocker per this phase's explicit advisory framing of code-review findings. |
| 5 | A cidade escolhida é guardada no aparelho sem conta/senha e reusada nas próximas aberturas (LOC-04, D-15) | ✓ VERIFIED | `CidadePrefsDataSource` uses `SharedPreferencesAsync` (not the legacy singleton), key `cidade_selecionada`, `nome|uf`. `test/data/cidade_prefs_datasource_test.dart` proves a fresh instance (cold-start simulation) reads back an identical value. `lib/main.dart`'s `_TelaInicialState` reads the saved city on `initState` and routes accordingly. |
| 6 | O visitante troca de cidade num toque no topo da tela, sem novo GPS; a nova escolha passa a ser a guardada (LOC-05) | ✓ VERIFIED | `lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart` — tap calls `cubit.carregarLista()`, never `detectarCidade()`. `test/presentation/seletor_cidade_topo_test.dart` asserts `verifyNever` on the geolocator gateway and that selecting a new city calls `SalvarCidadeUseCase`. |
| 7 | Reabertura com cidade já guardada vai direto pra cidade guardada sem re-pedir GPS; se a cidade guardada não está mais atendida, cai na lista em vez de uma cidade fantasma (LOC-05, D-08, A2/Pitfall 5) | ✓ VERIFIED | `ValidarCidadeAtendidaUseCase` revalidates by `chaveNatural` against the current served list, returns `autorizadaEAtendida` or `autorizadaNaoAtendida` — never touches `GeolocatorGateway`/`GeocodingGateway`. `lib/main.dart` calls `iniciarNaAberturaComCidadeSalva`, not `entrarDireto`, on the saved-city path. `test/domain/validar_cidade_atendida_usecase_test.dart` + 2 new `blocTest` cases in `cidade_selecao_cubit_test.dart` (`verifyNever` on the gateway) + `test/main_launch_routing_test.dart` (wiring) all pass. |
| 8 | Linha inválida do asset de cidades (nome/uf ausente) é descartada no parse; a tela continua com as válidas, nunca crash (UI-SPEC E2/E3 partial) | ✓ VERIFIED (scoped) | `lib/data/datasources/cidade_local_datasource.dart:38-43` drops rows where `nome`/`uf` is `null` or empty. `test/data/cidade_local_datasource_test.dart` proves a mixed-validity fixture returns only the 2 valid rows. **Scope note:** this truth is specifically about *missing* fields, which is what's implemented and tested. A wrong-*typed* field (e.g. `"nome": 123`) is a different, untested failure mode — see CR-01 in Anti-Patterns; it is not covered by this truth's literal wording but is a related robustness gap worth tracking. |
| 9 | Cada cidade renderiza como Card > ListTile em `ListView.builder` sem cap; nomes longos quebram/truncam sem estourar o layout | ✓ VERIFIED | `_CorpoLista` in `cidade_selecao_screen.dart` uses `ListView.builder` (no length cap) with `Card`>`ListTile` (leading `Icons.location_on`, trailing chevron); `Text` has no `maxLines`, so it wraps rather than overflowing. Long-name backstop not independently device-tested (flagged `verification: backstop` in the plan — no dedicated automated or human check found beyond the code-level guarantee that unconstrained `Text` wraps). |
| 10 | O acesso às cidades passa por `CidadeRepository`/DataSource com impl local registrada por DI, trocável por impl remota na Fase 2 sem tocar UI/Cubit (D-14) | ✓ VERIFIED | `CidadeRepositoryImpl` is `@LazySingleton(as: CidadeRepository)`; `lib/di/injection.config.dart` confirms it's registered against the abstract type, and `CidadeSelecaoCubit`/use cases depend only on the `CidadeRepository` interface (never the impl or a data source directly). |
| 11 | Existe um documento de contrato escrito cobrindo `GET /cidades` e `GET /imoveis` (campos, enums, params, envelope cursor), grounded nos models reais, com itens pendentes marcados para sign-off da frente web (API-01) | ✓ VERIFIED (written half only) | `01-CONTRATO-API.md` exists; all 6 required tokens present (`GET /cidades`, `GET /imoveis`, `CursorPagination`, `PENDENTE E2`, `publicado`, `allowlist`); both `contrato/*.example.json` fixtures are valid JSON with the cursor envelope; `assets/cidades.json`'s shape (`id`/`nome`/`uf`, cursor envelope) matches `cidades.example.json` exactly. **The roadmap's Success Criterion 5 also requires the contract be "escrito **e acordado** com a frente web" (written AND agreed) — the "agreed" half is explicitly NOT done yet** (01-02-SUMMARY.md's own "Next Phase Readiness": "Manual coordination step still outstanding... obtain E2 sign-off"). Routed to human verification below rather than scored as a gap, matching the plan's own explicit deferral. |
| 12 | O contrato especifica um serializer público com allowlist explícita (sem proprietário/documento/corretor/empresa interno) e `publicado=True` no queryset, preservando isolamento multitenant | ✓ VERIFIED | `01-CONTRATO-API.md` §6 documents this as a hard requirement for Phase 4, citing the `EmpresaPublicaAPIView`/`EmpresaScopedQuerySetMixin` precedent from the sibling repo. |

**Score:** 12/12 truths verified (0 present-behavior-unverified, 0 overrides). Two of the twelve
(#4, #8) carry a documented, narrowly-scoped caveat rather than a full pass — see Anti-Patterns.

### Deferred Items

None — no gaps were identified that map to later-phase roadmap coverage.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/core/result.dart` | sealed `Result<T>` (Loading/Success/Failure) | ✓ VERIFIED | Present, used throughout `data/`/`domain/`. |
| `lib/domain/entities/cidade.dart` | `Cidade` entity + `chaveNatural` | ✓ VERIFIED | Present, normalized natural-key getter confirmed. |
| `lib/data/models/cidade_model.dart` | freezed+json `CidadeModel` | ✓ VERIFIED | `fromJson`/`toJson`/`paraEntidade()` present, generated `.freezed.dart`/`.g.dart` exist. |
| `lib/data/datasources/cidade_local_datasource.dart` | reads asset, drops malformed rows | ✓ VERIFIED (scoped) | Confirmed for missing-field rows; see CR-01 caveat for wrong-typed rows. |
| `lib/data/datasources/cidade_prefs_datasource.dart` | `SharedPreferencesAsync` persistence | ✓ VERIFIED | Uses the new (non-legacy) API as mandated. |
| `lib/data/repositories/cidade_repository_impl.dart` | `@LazySingleton(as: CidadeRepository)` | ✓ VERIFIED | Confirmed in source and in generated `injection.config.dart`. |
| `lib/di/injection.dart` | `configureDependencies()` | ✓ VERIFIED | Present, called from `main.dart`. |
| `lib/presentation/cidade_selecao/cidade_selecao_screen.dart` | exhaustive 8-state screen | ✓ VERIFIED | Confirmed compiler-enforced switch, no default branch. |
| `assets/cidades.json` | served-city fixture, cursor envelope | ✓ VERIFIED | Valid JSON, matches `contrato/cidades.example.json` shape. |
| `lib/app_theme.dart` | Material 3 `ColorScheme.fromSeed` green | ✓ VERIFIED | `Color(0xFF2E7D32)`, `useMaterial3: true`. |
| `lib/domain/gateways/geolocator_gateway.dart` / `geocoding_gateway.dart` | mockable interfaces | ✓ VERIFIED | Abstract classes present, implemented in `data/gateways/` with `@LazySingleton(as: ...)`. |
| `lib/data/constants/uf_lookup.dart` | Brazil state → UF lookup | ✓ VERIFIED | 27-entry map + normalize helper present; `test/data/uf_lookup_test.dart` passes. |
| `lib/presentation/cidade_selecao/cidade_selecao_state.dart` | sealed 8-variant state | ✓ VERIFIED | Confirmed. |
| `lib/presentation/cidade_selecao/cidade_selecao_cubit.dart` | permission state machine | ✓ VERIFIED | Confirmed, `requestPermission` called at most once per attempt. |
| `lib/presentation/priming/priming_screen.dart` | CTA-only permission trigger | ✓ VERIFIED | Confirmed. |
| `lib/domain/usecases/validar_cidade_atendida_usecase.dart` | stale-city revalidation | ✓ VERIFIED | Confirmed. |
| `lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart` | top city switcher | ✓ VERIFIED | Confirmed, 48dp `ConstrainedBox`, `Semantics(label: 'Trocar cidade')`. |
| `lib/main.dart` | launch routing (D-08) | ✓ VERIFIED | Confirmed, saved+city → `iniciarNaAberturaComCidadeSalva`. |
| `.planning/.../01-CONTRATO-API.md` | frozen contract doc | ✓ VERIFIED | Present, all required tokens found. |
| `contrato/cidades.example.json`, `contrato/imoveis.example.json` | mock fixtures | ✓ VERIFIED | Valid JSON, cursor envelope present in both. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `cidade_selecao_screen.dart` | `cidade_repository_impl.dart` | resolved through `getIt`/Cubit, never direct data-source call | ✓ WIRED | Screen only calls `context.read<CidadeSelecaoCubit>()` / constructor-injected use case; no data source import in the widget. |
| `cidade_prefs_datasource.dart` | device storage | `SharedPreferencesAsync` | ✓ WIRED | Confirmed. |
| `cidade_selecao_cubit.dart` | `detectar_cidade_usecase.dart` | cubit invokes use case, use case calls gateways | ✓ WIRED | Confirmed; cubit never imports `geolocator`/`geocoding` packages directly. |
| `geolocator_gateway_impl.dart` | device OS location plugin | `Geolocator` whileInUse calls | ✓ WIRED | Confirmed, no `always`/background permission requested anywhere. |
| `priming_screen.dart` | `cidade_selecao_cubit.dart` | CTA `onPressed` → `detectarCidade()` | ✓ WIRED | Confirmed, sole call site. |
| `seletor_cidade_topo.dart` | `cidade_selecao_screen.dart`/cubit | tap → `carregarLista()`, never `detectarCidade()` | ✓ WIRED | Confirmed via source read and `verifyNever` test. |
| `main.dart` | `validar_cidade_atendida_usecase.dart` | launch-time revalidation before direct entry | ✓ WIRED | Confirmed via `iniciarNaAberturaComCidadeSalva` call chain. |
| `contrato/cidades.example.json` | `assets/cidades.json` | identical envelope + field shape | ✓ WIRED | Confirmed byte-for-byte structural match (`{id, nome, uf}` rows, cursor envelope). |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|---------------------|--------|
| `CidadeSelecaoScreen` city list | `cidadesAtendidas` | `CidadeRepositoryImpl.obterCidadesAtendidas()` → `CidadeLocalDataSource.obterCidades()` → `rootBundle.loadString('assets/cidades.json')` | Yes | ✓ FLOWING (real asset read, not a hardcoded literal) |
| `SeletorCidadeTopo` header text | `cidade` | `CidadeSelecaoState.autorizadaEAtendida(cidade)`, sourced from either `DetectarCidadeUseCase`, `ValidarCidadeAtendidaUseCase`, or manual selection | Yes | ✓ FLOWING |
| Saved-city launch decision | `_cidadeSalva` | `ObterCidadeSalvaUseCase` → `CidadeRepositoryImpl.obterCidadeSalva()` → `CidadePrefsDataSource.obterSalva()` → `SharedPreferencesAsync` | Yes | ✓ FLOWING |

No hardcoded/mocked production data paths found in `lib/`. The one static value in the pipeline is `assets/cidades.json` itself — by design (D-13, a local fixture standing in for the future real `GET /cidades`, explicitly scoped and documented as such in every plan's SUMMARY).

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| `flutter analyze` clean | `flutter analyze` | "No issues found!" | ✓ PASS |
| Full test suite passes | `flutter test` | "53/53, All tests passed!" | ✓ PASS |
| Contract doc has required sections | `grep -F` on 6 required tokens | all 6 found | ✓ PASS |
| Fixtures are valid JSON with cursor envelope | `python3 -m json.tool` + `grep '"results"'` | both valid, both contain `results` | ✓ PASS |
| No `always`/background location permission requested | `grep` AndroidManifest.xml + Info.plist | no matches for "Always"/"BACKGROUND" | ✓ PASS |
| `compileSdk` pinned to 35 | `grep compileSdk` in `build.gradle.kts` | `compileSdk = 35` | ✓ PASS |
| No debt markers (TBD/FIXME/XXX/TODO/HACK/PLACEHOLDER) in `lib/` | `grep -rn` | none found | ✓ PASS |

I independently re-ran `flutter analyze` and `flutter test` rather than trusting the SUMMARY's reported numbers — both reproduced clean/green.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| LOC-01 | 01-03 | Primeira abertura pede permissão de localização | ✓ SATISFIED | Priming screen CTA-only trigger, tested. |
| LOC-02 | 01-03 | Autorizada, descobre a cidade e entra (ou cai no fallback) | ✓ SATISFIED | `DetectarCidadeUseCase` + tests. |
| LOC-03 | 01-03 | Recusada/bloqueada → lista, caminho normal | ✓ SATISFIED | Sealed states + screen tests. |
| LOC-04 | 01-01 | Cidade guardada sem conta/senha, reusada | ✓ SATISFIED | `CidadePrefsDataSource` + cold-start test. |
| LOC-05 | 01-04 | Troca de cidade num toque no topo | ✓ SATISFIED | `SeletorCidadeTopo` + launch revalidation. |
| LOC-06 | 01-03 | Desfechos como estados explícitos, nunca exceção genérica | ✓ SATISFIED (caveated) | 8-variant sealed state, exhaustive switch; see CR-01/CR-02 caveat on reachability for untested failure shapes. |
| API-01 | 01-02 | Contrato de `/cidades`/`/imoveis` auditado e congelado por escrito | ✓ SATISFIED (written; sign-off pending) | `01-CONTRATO-API.md` grounded in real sibling models; E2 sign-off is a human-verification item. |

**Orphan check:** REQUIREMENTS.md's Traceability table maps exactly LOC-01..06 and API-01 to Phase
1, all seven appear in some plan's `requirements:` frontmatter (01-01→LOC-04, 01-02→API-01,
01-03→LOC-01/02/03/06, 01-04→LOC-05). No orphaned requirement IDs found.

### Anti-Patterns Found

These are drawn from `01-REVIEW.md` (an independent code review already run on this phase) and
re-confirmed by direct source inspection during this verification. Per this verification's explicit
task framing, code-review findings are treated as advisory quality risks, not automatic goal
blockers — but they are real, source-confirmed gaps and are recorded here rather than silently
dropped.

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `lib/data/datasources/cidade_local_datasource.dart` / `lib/data/repositories/cidade_repository_impl.dart` | 32-45 / 26 | Unguarded type casts (`as Map<String,dynamic>`, `as List<dynamic>?`) inside a `try { } on Exception` block — a `TypeError` is an `Error`, not an `Exception`, in Dart, so it is NOT caught | 🛑 Blocker-class (re-confirmed) | A malformed-but-present field (e.g. `"nome": 123`) in a future `assets/cidades.json` edit or a live `GET /cidades` response crashes the app uncaught instead of degrading to `erroCarregarCidades`, contradicting the phase's own "nunca crash" design promise for this exact code path's comment. Does not affect the current, well-formed fixture. |
| `lib/data/gateways/geolocator_gateway_impl.dart` | 12-13 | `isServicoHabilitado()` has no `try/catch`, unlike every sibling method in the same class | 🛑 Blocker-class (re-confirmed) | If the platform channel throws on this specific call (the very first call made by `detectarCidade()`), the user is stuck on "Localizando você…" forever with no retry and no error UI — violates LOC-06's "every outcome has explicit UI" guarantee for this one call site. |
| `lib/main.dart` | 69-76 | `_carregar()` has no `try/catch` around `_obterCidadeSalva()`, the app's very first async call after `runApp()` | 🛑 Blocker-class (re-confirmed) | A `SharedPreferencesAsync` platform-channel failure on cold boot would leave the app stuck on a spinner indefinitely, before any UI (including the fallback priming flow) can render. |
| `lib/domain/usecases/detectar_cidade_usecase.dart:5`, `validar_cidade_atendida_usecase.dart:4` | — | `domain/` imports `presentation/cidade_selecao_state.dart` | ⚠️ Warning (re-confirmed) | Violates CLAUDE.md's "não-negociável" Clean Architecture layering (inner layer depends on outer layer). Documented in the 01-03 SUMMARY as an intentional convenience trade-off, not a resolved conflict. |
| `lib/domain/repositories/cidade_repository.dart:10,12` | — | `salvarCidade`/`obterCidadeSalva` are the only two fallible repository methods NOT wrapped in `Result<T>` | ⚠️ Warning (re-confirmed) | Inconsistent with the project's own "Erros de API: padrão Result... estados explícitos" constraint; root cause enabling the `main.dart` gap above. |

None of these are debt markers (`TBD`/`FIXME`/`XXX`) — a fresh `grep` across `lib/` found zero
matches — so the debt-marker gate does not apply. They are traced, source-confirmed logic gaps, not
placeholder text.

## Human Verification Required

See the `human_verification` list in the frontmatter (5 items): the 4 device/emulator smoke-checks
this phase's own plans explicitly deferred to end-of-phase per
`workflow.human_verify_mode=end-of-phase`, plus the cross-team API contract sign-off (API-01's
"agreed with the web team" half, distinct from its "written" half which is done).

## Gaps Summary

No must-have truth, artifact, or key link FAILED outright. All 4 plans' automated verification
gates (`flutter analyze`, `flutter test`, JSON validity, required-token greps) were independently
re-run during this verification and reproduced clean/green (53/53 tests, 0 analyzer issues).

Two things keep this phase out of a clean `passed`:

1. **Five items require a human** (device/emulator OS-level behavior, and cross-team contract
   sign-off) that cannot be verified from the codebase alone — this phase's own plans explicitly
   modeled these as end-of-phase human-checks, not oversights.
2. **Three re-confirmed code-review findings (CR-01, CR-02, CR-03)** describe real, traced gaps in
   the "never a generic exception" design promise for failure modes outside what the current tests
   and current `assets/cidades.json` exercise. They do not break any currently-testable must-have
   truth (the happy paths and the specific failure modes the plans' own tests cover all pass), but
   they are genuine cracks in LOC-06's core guarantee and are worth closing before Phase 2 swaps in
   a live, less-controlled `GET /cidades` response. Recorded as advisory per this verification's
   task framing, not as blocking gaps — but flagged prominently rather than silently absorbed.

---

_Verified: 2026-09-22_
_Verifier: Claude (gsd-verifier)_
