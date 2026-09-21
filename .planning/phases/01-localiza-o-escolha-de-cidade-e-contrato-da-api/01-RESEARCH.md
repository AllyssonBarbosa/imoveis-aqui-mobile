# Phase 1: Localização, Escolha de Cidade e Contrato da API - Research

**Researched:** 2026-09-21
**Domain:** Flutter Clean Architecture walking skeleton (location permission state machine + local persistence) + Django DRF public API contract design
**Confidence:** MEDIUM-HIGH (stack/versions VERIFIED against pub.dev registry; API contract grounded in real model files; two open semantic questions genuinely need the web team, not resolvable from docs)

## Summary

Phase 1 has two independent halves that can be built in parallel: (1) a Flutter walking skeleton
— priming screen → 5-sealed-state city-selection screen → persisted city, wired through a thin
Clean Architecture slice (one Cubit, one repository, one local `DataSource`, `freezed` models,
`get_it`/`injectable` DI) — and (2) a **non-code** documentation deliverable, the frozen API
contract for `GET /cidades` and `GET /imoveis`, written against the real Django models in the
sibling `../imoveis-aqui/Web` repo (confirmed readable and read this session).

The single most consequential finding this session: **the project's target platforms are Windows
and macOS (per `instruções.md` §Ambiente, not Android/iOS)**, and the `geocoding` package —
which the whole "detect city automatically" flow (LOC-02) depends on — **does not support
Windows** (confirmed via the package's own `pubspec.yaml` platform declaration on the pub.dev
registry: only `android`, `ios`, `macos`). `geolocator` (GPS itself) does support Windows. This
means on Windows the app will always get a device coordinate but can never resolve it to a city
name — which is not a crash risk (the existing sealed-state design already has a graceful
"geocoding failed → show city list" path, D-12), but **is a real product behavior gap** that
should be an explicit, acknowledged decision rather than a surprise at build time.

The second major finding: the sibling API repo already has a `Cidade` model, a public
`CidadeSerializer` (`empresas/api/serializers.py`), and a `AllowAny`-pattern precedent
(`EmpresaPublicaAPIView`) to copy for the future `/api/publico/cidades/` and
`/api/publico/imoveis/` endpoints (Phase 2 / Phase 4 work, not this phase) — but the "atendida"
(served) city set is **not** simply "every row in the `Cidade` table"; it is Cities that have at
least one active `Empresa` operating in them (`Empresa.cidades_atuacao` M2M, `related_name=
"empresas_atuantes"`). The fixed `assets/cidades.json` this phase ships (D-13/D-16) must mirror
that scoped set, not the raw table, or Phase 2's real `GET /cidades` will return a different city
list than Phase 1's fixture — silently breaking the "same shape as day one" premise of D-13.

**Primary recommendation:** Build the Flutter skeleton exactly as CLAUDE.md's stack table
specifies (all versions confirmed current against the pub.dev registry this session); write
`CONTRATO-API.md` + example JSON fixtures grounded in the real `Imovel`/`Cidade`/`Endereco`
models read this session, explicitly marking tipologia fields `PENDENTE E2`; and surface the two
genuinely unresolved semantic questions (quartos/suítes/vagas: exact-match vs. range; Windows
geocoding gap) to the user/web-team before committing to a single answer in the frozen contract.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| GPS coordinate acquisition | Client (device OS via `geolocator`) | — | Native permission + hardware API; no server involvement possible |
| Coordinate → city name (reverse geocoding) | Client (device OS via `geocoding`, macOS/Android only) | — (Windows has no equivalent client capability — see Pitfall 1) | Uses native `CLGeocoder`/Play Services, not a server call; server has no lat/long-based city lookup endpoint in scope for this phase |
| City-served matching (`nome+uf` vs. `Cidade` table) | Client (compares reverse-geocoded name against the bundled/fetched city list) | API (owns the authoritative `Cidade` list) | Client only *compares strings*; the authoritative list of "which cities exist" is server-owned (asset today, API in Phase 2) — no business rule is decided client-side, per project constraint |
| Chosen-city persistence | Client (`shared_preferences`) | — | No account/login exists (LOC-04 explicit); local-only by design |
| City list source-of-truth | API (Django `Cidade` model + future `cidades_atuacao` scoping) | Client (local asset mirrors it this phase, D-13/14) | Swappable-by-DI local→remote impl is the architecture's stated axis (API-04) |
| API contract definition (fields/enums/params/pagination) | API (Django/DRF owns the real shape) | Docs (this phase freezes it in Markdown, versioned in both repos) | Contract-first coordination point between the two team members before either side codes against it |
| Property listing filtering/sorting/search | API (Django, server-side only) | — | Non-negotiable project rule: "nada é recalculado dentro do aparelho" — out of Phase 1's build scope but the contract frozen here constrains it |

## User Constraints (from CONTEXT.md)

<user_constraints>

### Locked Decisions

- **D-01:** Envelope de paginação = **cursor** (DRF `CursorPagination`), resposta
  `{next, previous, results}`. Escolhido porque imuniza a vitrine contra cards
  duplicados/embaralhados quando o acervo muda durante o scroll. Trade-off aceito: sem `count`
  total e sem pulo de página. Reversibility: one-way.
- **D-02:** Congelar o **contrato completo** já incluindo os campos de tipologia que ainda NÃO
  existem no model (`natureza` casa/apto/terreno/lote, `quartos`, `suites`, `vagas`, `area`),
  marcados explicitamente como **pendente E2**. Reversibility: costly.
- **D-03:** Documento de contrato = **Markdown human-legível** + **arquivos JSON de exemplo**
  que servem de fixture do mock (API-04). Versionado no repo do app E no repo da API.
- **D-04:** Idioma/estilo de campos e query params = **português snake_case** (`cidade`,
  `preco_min`, `preco_max`, `quartos_min`, `natureza`, `finalidade`, `ordenacao`, `cursor`).
- **D-05:** Pedir a permissão com **tela de priming antes** — CTA "Usar minha localização" que
  só então dispara o prompt nativo do OS.
- **D-06:** Desfecho `deniedForever` → **cai na lista de cidades** (caminho normal) + CTA
  discreto "Ativar localização nas Ajustes" (`geolocator.openAppSettings`). Nunca tela de erro.
- **D-07:** Os **5 desfechos** de localização (autorizado / recusado / bloqueado-para-sempre /
  serviço-desligado / cidade-não-atendida) = estados explícitos (sealed class / enum) na
  **mesma tela de seleção de cidade**.
- **D-08:** Reabertura do app com cidade já guardada → **vai direto pra cidade guardada**, sem
  re-pedir GPS. Localização só roda na 1ª vez (sem cidade) ou quando o usuário pede pra trocar.
- **D-09:** Casamento reverse geocoding → cidade atendida = **nome + UF normalizado** (acentos,
  caixa, espaços). Casa com o model `Cidade` (`unique(nome, uf)`).
- **D-10:** Cidade detectada com sucesso E atendida → **entra direto** na vitrine dela, nome no
  topo, trocável num toque. Sem passo de confirmação.
- **D-11:** Cidade detectada mas NÃO atendida → **lista de cidades + aviso leve** ("Ainda não
  atendemos [Cidade] — escolha uma das disponíveis").
- **D-12:** Falha no reverse geocoding (sem internet / timeout / sem resultado) → **mais um
  desfecho explícito → cai na lista** de cidades, sem tela de erro.
- **D-13:** Formato = **asset JSON** (`assets/cidades.json`) com a **mesma forma do contrato de
  `GET /cidades`**.
- **D-14:** Acesso via **`CidadeRepository`/`DataSource` com impl local** (lê o asset) nesta
  fase; Fase 2 entra impl remota por **DI** sem tocar UI/Cubit.
- **D-15:** Persistir a cidade escolhida por **nome + uf (chave natural)**, não por id.
  Reversibility: costly (migração se mudar depois).
- **D-16:** Conteúdo da lista fixa = **espelhar as Cidades já cadastradas no banco da API** (as
  realmente atendidas).

### Claude's Discretion

Nenhuma decisão delegada — o usuário respondeu todas as áreas explicitamente.

### Deferred Ideas (OUT OF SCOPE)

- **`GET /cidades` real via API** — Fase 2 (VIT-06/API-02); nesta fase a lista é fixa.
- **Endpoint real de `/imoveis` + troca do DataSource por DI** — Fase 4 (API-03).
- **Result-count "Ver N imóveis"** no botão aplicar — v2 (API-05).
- **Tipologia do imóvel no model Django** (natureza/quartos/suítes/vagas/área) — dependência
  externa do E2; nesta fase só é *congelada no contrato*, não implementada.

</user_constraints>

## Phase Requirements

<phase_requirements>

| ID | Description | Research Support |
|----|-------------|------------------|
| LOC-01 | Pedir permissão de localização na 1ª abertura | `geolocator` priming-screen pattern (Code Examples §1); `LocationPermission` enum confirmed via pub.dev docs |
| LOC-02 | Autorizada → reverse geocoding → entra na cidade; não atendida → fallback | `geocoding.placemarkFromCoordinates` + D-09 nome/UF match (Code Examples §2); **Windows platform gap flagged as Pitfall 1** |
| LOC-03 | Recusada/bloqueada → lista de cidades como caminho normal | Sealed-state Cubit design (Architecture Pattern 1); no error screen |
| LOC-04 | Cidade guardada no aparelho, reusada nas próximas aberturas | `SharedPreferencesAsync` persistence (Code Examples §3), key = `nome+uf` per D-15 |
| LOC-05 | Trocar cidade num toque no topo | UI-SPEC's tappable header component; re-triggers the city-selection screen, not GPS |
| LOC-06 | 5 desfechos como estados explícitos, nunca exceção genérica | `sealed class DesfechoLocalizacao` design (Architecture Pattern 2) |
| API-01 | Auditar API atual e congelar contrato de `/cidades` e `/imoveis` | Full contract draft below (§API Contract Draft), grounded in `Imovel`/`Cidade`/`Endereco`/`Empresa` models read this session |

</phase_requirements>

## Standard Stack

### Core

All versions below were queried directly against the pub.dev registry API this session
(`curl https://pub.dev/api/packages/<pkg>`) and match the CLAUDE.md-mandated versions exactly —
`[VERIFIED: pub.dev registry]`.

| Library | Version (confirmed 2026-09-21) | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `dio` | 5.11.1 (published 2026-09-04) | HTTP client for the Django DRF API | Interceptor chain for base URL, query-param filters, timeouts. `[VERIFIED: pub.dev registry]` |
| `flutter_bloc` | 9.1.1 (published 2025-05-02) | Cubit-based state management | Team-mandated; publisher `bloclibrary.dev`. `[VERIFIED: pub.dev registry]` |
| `freezed` | 4.0.2 (published 2026-09-18) | Immutable models + sealed `Result<T>` union | Publisher `dash-overflow.net`. `[VERIFIED: pub.dev registry]` |
| `freezed_annotation` | 3.1.0 (published 2025-07-02) | Companion annotations for `freezed` | `[VERIFIED: pub.dev registry]` |
| `json_serializable` | 6.14.1 (published 2026-07-30) | `fromJson`/`toJson` codegen | Publisher `google.dev`. `[VERIFIED: pub.dev registry]` |
| `json_annotation` | 4.12.0 (published 2026-05-15) | Companion annotations | `[VERIFIED: pub.dev registry]` |
| `build_runner` | 2.16.1 (published 2026-09-02) | Codegen runner (freezed/json_serializable/injectable_generator) | Publisher `tools.dart.dev`. `[VERIFIED: pub.dev registry]` |

### Supporting

| Library | Version (confirmed 2026-09-21) | Purpose | When to Use |
|---------|---------|---------|-------------|
| `shared_preferences` | 2.5.5 (published 2026-03-25) | Persist chosen city (`nome+uf` key) | Use the **new `SharedPreferencesAsync()`** class, not the legacy singleton (see State of the Art). Cross-platform incl. Windows/macOS confirmed via pub.dev platform tags. `[VERIFIED: pub.dev registry]` |
| `geolocator` | 14.0.3 (published 2026-06-12) | GPS coordinate + permission flow | Publisher `baseflow.com`, `flutter-favorite` tag. Platform tags confirm `android, ios, windows, linux, macos, web` — **Windows supported**. `[VERIFIED: pub.dev registry]` |
| `geocoding` | 5.0.0 (published 2026-07-03) | Reverse-geocode coordinates → city name | Publisher `baseflow.com`. **Platform tags confirm only `android, ios, macos` — Windows is NOT declared.** See Pitfall 1. `[VERIFIED: pub.dev registry]` |
| `get_it` | 9.3.0 (published 2026-09-19) | Service locator | Publisher `flutter-it.dev`. `[VERIFIED: pub.dev registry]` |
| `injectable` + `injectable_generator` | 3.0.0 / 3.1.3 | Codegen for `get_it` registration | Publisher `codeness.ly`. Constraint `get_it: '>=8.3.0 <10.0.0'` satisfied by 9.3.0. `[VERIFIED: pub.dev registry]` |
| `bloc_test` + `mocktail` | 10.0.0 / 1.0.5 | Cubit unit testing | Publishers `bloclibrary.dev` / `felangel.dev`. `[VERIFIED: pub.dev registry]` |
| `flutter_lints` | 6.0.0 (published 2025-05-27) | Lint ruleset | Publisher `flutter.dev`. `[VERIFIED: pub.dev registry]` |

Not needed this phase (deferred to Phase 2): `cached_network_image` (property card images, APP02).

### Alternatives Considered

No alternatives researched independently this phase — CLAUDE.md's Alternatives Considered table
already covers `http` vs `dio`, `fpdart` vs hand-rolled `Result`, `infinite_scroll_pagination` vs
hand-rolled pagination, and `easy_debounce` vs hand-rolled debounce. None of those tradeoffs are
exercised by Phase 1's scope (no list pagination, no debounced search yet — those are Phase 2/3).

**Installation:**
```bash
flutter create . --platforms=windows,macos
flutter pub add dio flutter_bloc freezed_annotation json_annotation get_it injectable shared_preferences geolocator geocoding
flutter pub add --dev build_runner freezed json_serializable injectable_generator bloc_test mocktail flutter_lints
```

## Package Legitimacy Audit

The `gsd-tools package-legitimacy check` seam only supports `npm|pypi|crates` ecosystems — Dart's
`pub` ecosystem is not covered. Legitimacy was instead verified directly against the **pub.dev
registry publisher API** this session (`curl https://pub.dev/api/packages/<pkg>/publisher`),
which is the pub.dev-equivalent authoritative source. All packages below are re-verifications of
already-team-decided CLAUDE.md entries, not new recommendations.

| Package | Registry | Publisher (verified) | Downloads/wk (approx, `is:flutter-favorite` where applicable) | Verdict | Disposition |
|---------|----------|----------------------|----------------------|---------|-------------|
| `geolocator` | pub.dev | `baseflow.com` (verified publisher, flutter-favorite) | high | OK | Approved |
| `geocoding` | pub.dev | `baseflow.com` (verified publisher) | high | OK | Approved (platform gap noted separately, not a legitimacy concern) |
| `shared_preferences` | pub.dev | `flutter.dev` (Google-owned Flutter team) | very high | OK | Approved |
| `dio` | pub.dev | `flutter.cn` (verified publisher) | very high | OK | Approved |
| `flutter_bloc` | pub.dev | `bloclibrary.dev` (verified publisher) | very high | OK | Approved |
| `freezed` / `freezed_annotation` | pub.dev | `dash-overflow.net` (verified publisher) | very high | OK | Approved |
| `json_serializable` / `json_annotation` | pub.dev | `google.dev` (verified publisher) | very high | OK | Approved |
| `get_it` | pub.dev | `flutter-it.dev` (verified publisher) | high | OK | Approved |
| `injectable` / `injectable_generator` | pub.dev | `codeness.ly` (verified publisher) | high | OK | Approved |
| `bloc_test` | pub.dev | `bloclibrary.dev` (verified publisher) | high | OK | Approved |
| `mocktail` | pub.dev | `felangel.dev` (verified publisher) | high | OK | Approved |
| `flutter_lints` | pub.dev | `flutter.dev` (verified publisher) | very high | OK | Approved |
| `build_runner` | pub.dev | `tools.dart.dev` (verified publisher, official Dart team) | very high | OK | Approved |

**Packages removed due to [SLOP] verdict:** none.
**Packages flagged as suspicious [SUS]:** none — every package resolves to a `pub.dev` **verified
publisher** domain matching a known organization (Google/Flutter team, Baseflow, bloclibrary.dev,
dash-overflow.net), which is the pub.dev-native signal equivalent to an npm/PyPI "verified" badge.

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          presentation/                                │
│  ┌────────────────┐        ┌──────────────────────────────────────┐  │
│  │ PrimingScreen   │──CTA──▶│ CidadeSelecaoScreen                  │  │
│  │ (FilledButton)  │        │  - watches CidadeCubit.state          │  │
│  └────────────────┘        │  - 5 sealed-state UI branches (D-07)  │  │
│         │ app launch,           - top city switcher (LOC-05)       │  │
│         │ no city saved   └───────────────┬──────────────────────┘  │
│         ▼                                 │ emits Loading/state      │
│  ┌────────────────┐                       ▼                          │
│  │ CidadeCubit     │◀──calls use cases──────┐                        │
│  └────────────────┘                         │                        │
└──────────────────────────────────────────────┼────────────────────────┘
                                                │
┌───────────────────────────────────────────────┼────────────────────────┐
│                          domain/               ▼                        │
│  ┌─────────────────────┐   ┌─────────────────────────┐                 │
│  │ DetectarCidadeUseCase│   │ SalvarCidadeEscolhidaUC  │                 │
│  │ (calls geolocator +  │   │ (writes to repository)   │                 │
│  │  geocoding directly, │   └───────────┬──────────────┘                 │
│  │  wrapped as Result)  │               │                                │
│  └──────────┬───────────┘   ┌───────────▼──────────────┐                 │
│             │               │ CidadeRepository (iface)  │                 │
│             │               └───────────┬──────────────┘                 │
└─────────────┼───────────────────────────┼────────────────────────────────┘
              │                           │
┌─────────────┼───────────────────────────┼────────────────────────────────┐
│             ▼              data/         ▼                                │
│  ┌─────────────────────┐   ┌──────────────────────────┐                  │
│  │ geolocator/geocoding │   │ CidadeRepositoryImpl       │                  │
│  │ (device OS APIs)     │   │  ├─ CidadeLocalDataSource   │  reads         │
│  │                      │   │  │   (assets/cidades.json) │──asset,        │
│  │                      │   │  └─ CidadePrefsDataSource   │  Phase 2 swaps │
│  │                      │   │      (SharedPreferencesAsync)│ in remote via │
│  └──────────────────────┘   └──────────────────────────┘  get_it/injectable│
└────────────────────────────────────────────────────────────────────────┘
```

### Recommended Project Structure
```
lib/
├── app_theme.dart                     # ColorScheme.fromSeed, Material 3
├── main.dart                          # getIt.init(), runApp
├── di/
│   └── injection.dart                 # @InjectableInit config
├── core/
│   └── result.dart                    # sealed Result<T> (freezed)
├── data/
│   ├── models/
│   │   └── cidade_model.dart          # freezed + json_serializable, fromJson matches contract
│   ├── datasources/
│   │   ├── cidade_local_datasource.dart   # reads assets/cidades.json (D-14)
│   │   └── cidade_prefs_datasource.dart   # SharedPreferencesAsync read/write (D-15)
│   └── repositories/
│       └── cidade_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── cidade.dart
│   ├── repositories/
│   │   └── cidade_repository.dart     # interface
│   └── usecases/
│       ├── detectar_cidade_usecase.dart     # GPS + reverse geocoding, returns DesfechoLocalizacao
│       ├── obter_cidade_salva_usecase.dart  # D-08: skip GPS if already saved
│       └── salvar_cidade_usecase.dart
└── presentation/
    ├── priming/
    │   └── priming_screen.dart
    └── cidade_selecao/
        ├── cidade_selecao_cubit.dart
        ├── cidade_selecao_state.dart  # sealed union, 5 desfechos + Loading (D-07)
        └── cidade_selecao_screen.dart
assets/
└── cidades.json                       # same shape as GET /cidades contract (D-13)
```

### Pattern 1: Sealed States for the 5 Location Outcomes (D-07)

**What:** A single `freezed` sealed union modeling every reachable outcome as its own named
variant — never a generic `Failure(Exception)` for domain-expected outcomes.
**When to use:** Any flow where "the normal path branches into known, finite outcomes" (LOC-06)
— this is a UI-state modeling pattern, not the network `Result<T>` pattern (which still wraps
each individual GPS/geocoding call and gets *consumed into* one of these variants).

```dart
// lib/presentation/cidade_selecao/cidade_selecao_state.dart
// Source: freezed 4.0.2 sealed-union pattern (dash-overflow.net docs / training knowledge)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cidade_selecao_state.freezed.dart';

@freezed
sealed class CidadeSelecaoState with _$CidadeSelecaoState {
  const factory CidadeSelecaoState.localizando() = _Localizando;
  const factory CidadeSelecaoState.autorizadaEAtendida(Cidade cidade) = _AutorizadaEAtendida;
  const factory CidadeSelecaoState.autorizadaNaoAtendida(
    String cidadeDetectada, List<Cidade> cidadesAtendidas,
  ) = _AutorizadaNaoAtendida;
  const factory CidadeSelecaoState.recusada(List<Cidade> cidadesAtendidas) = _Recusada;
  const factory CidadeSelecaoState.bloqueadaParaSempre(List<Cidade> cidadesAtendidas) =
      _BloqueadaParaSempre;
  const factory CidadeSelecaoState.servicoDesligado(List<Cidade> cidadesAtendidas) =
      _ServicoDesligado;
  const factory CidadeSelecaoState.falhaGeocodificacao(List<Cidade> cidadesAtendidas) =
      _FalhaGeocodificacao;
  const factory CidadeSelecaoState.erroCarregarCidades() = _ErroCarregarCidades; // defensive, UI-SPEC E2/E3 error row
}
```

Note the sealed union has **7** variants (5 desfechos from LOC-06 + `localizando` loading state +
the defensive `erroCarregarCidades` asset-parse-failure state the UI-SPEC calls out) — LOC-06's
"5 desfechos" describes the *location outcomes*, not the total state-machine variant count.

### Pattern 2: Network-Call Result Wrapping

**What:** Every individual fallible call (GPS fetch, reverse geocode, asset read) returns a
`Result<T>`; the use case then maps combinations of `Result`s into one `CidadeSelecaoState`
variant — the sealed state above is the *outcome*, `Result<T>` is the *plumbing* to get there.

```dart
// lib/core/result.dart
// Source: freezed 4.0.2 sealed class pattern (training knowledge; matches project's
// literal constraint wording "Loading / Success<T> / Failure(Exception)")
import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.loading() = Loading<T>;
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Exception erro) = Failure<T>;
}
```

### Pattern 3: DI Wiring with `get_it` + `injectable`

**What:** Annotate the impl, run codegen, call `getIt.init()` once in `main()` — no manual
constructor threading.

```dart
// lib/data/repositories/cidade_repository_impl.dart
// Source: injectable 3.0.0 official usage pattern (training knowledge, standard for the package)
import 'package:injectable/injectable.dart';

@LazySingleton(as: CidadeRepository)
class CidadeRepositoryImpl implements CidadeRepository {
  CidadeRepositoryImpl(this._local, this._prefs);
  final CidadeLocalDataSource _local;
  final CidadePrefsDataSource _prefs;
  // ...
}
```

```dart
// lib/main.dart
import 'di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(); // getIt.init() wrapper generated by injectable
  runApp(const MyApp());
}
```

### Pattern 4: Priming Screen Before Native Prompt (D-05)

**What:** Show explanatory UI with a `FilledButton` CTA; only the CTA's `onPressed` calls
`Geolocator.requestPermission()` — never call it on `initState`/app launch directly.

```dart
// Source: geolocator 14.0.3 official permission API (pub.dev docs, confirmed this session)
Future<void> _aoTocarUsarLocalizacao() async {
  final habilitado = await Geolocator.isLocationServiceEnabled();
  if (!habilitado) {
    cubit.emitirServicoDesligado();
    return;
  }
  LocationPermission permissao = await Geolocator.checkPermission();
  if (permissao == LocationPermission.denied) {
    permissao = await Geolocator.requestPermission();
  }
  switch (permissao) {
    case LocationPermission.denied:
      cubit.emitirRecusada();
    case LocationPermission.deniedForever:
      cubit.emitirBloqueadaParaSempre();
    case LocationPermission.whileInUse:
    case LocationPermission.always:
      cubit.detectarCidade(); // proceeds to geolocator + geocoding
    case LocationPermission.unableToDetermine:
      cubit.emitirRecusada(); // web-only edge case; treat as denied
  }
}
```

### Anti-Patterns to Avoid

- **Calling `requestPermission()` on screen init:** Burns the permission on first launch before
  the user understands why — exactly what D-05's priming screen exists to prevent.
- **Requesting `LocationPermission.always` or background location:** This app only needs a
  one-shot foreground location fetch to enter a city on launch. Requesting `always`/background
  scope (and the corresponding `ACCESS_BACKGROUND_LOCATION`/`NSLocationAlwaysAndWhenInUseUsage
  Description` entries some geolocator tutorials show) is over-privileged for this use case and
  is themable as suspicious by app store review — request `whileInUse` only.
- **Generic `catch (e)` around the geocoding call:** Project constraint explicitly forbids
  generic `try/catch` in the UI; wrap each fallible call in `Result<T>` and let the use case
  decide which sealed state it becomes (LOC-06).
- **Persisting the city by database ID:** D-15 explicitly locks `nome+uf` as the persisted key —
  IDs from the fixed `assets/cidades.json` will not match the real API's IDs once Phase 2 lands.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Location permission state tracking | A custom `PermissionStatus` polling loop | `geolocator`'s `LocationPermission` enum + `checkPermission()`/`requestPermission()` | Already handles Android/iOS/macOS/Windows-specific permission quirks (see Pitfall 3 re: Windows) |
| Reverse geocoding | A hand-rolled REST call to a third-party geocoding API | `geocoding`'s `placemarkFromCoordinates` (macOS/Android/iOS) | No API key, no rate-limit management needed for the platforms it supports — but see Pitfall 1 for the Windows gap this does NOT solve |
| Local key-value persistence | Raw file I/O for a single string | `SharedPreferencesAsync` | Handles platform-native storage (`NSUserDefaults`/`DataStore Preferences`/Windows registry-backed) uniformly |
| DI wiring | Manual constructor injection through `main.dart` | `get_it` + `injectable` codegen | Team's already-decided pattern; scales cleanly into Phase 2/3's larger dependency graph |
| Immutable state + equality | Hand-written `==`/`hashCode`/`copyWith` | `freezed` | Team's already-decided pattern; do not add `equatable` on top (redundant, see CLAUDE.md "What NOT to Use") |

**Key insight:** Every "don't hand-roll" item above is already a locked project decision
(CLAUDE.md) — Phase 1's job is applying them correctly to the location/city domain, not choosing
new tools.

## Runtime State Inventory

Not applicable — this is a greenfield phase (no rename/refactor/migration). The repo has no
`pubspec.yaml`/`lib/` yet (confirmed: `git status` shows only `.DS_Store` tracked); there is no
prior runtime state to inventory.

## Common Pitfalls

### Pitfall 1: `geocoding` does not support Windows — the auto-detect flow silently degrades

**What goes wrong:** LOC-02's "authorized → reverse geocode → enter city directly" path can
never succeed on Windows, because the `geocoding` package's platform declaration
(`pubspec.yaml` → `flutter.plugin.platforms`, confirmed via the pub.dev registry API this
session) only lists `android`, `ios`, `macos`. Calling `placemarkFromCoordinates` on Windows
throws a `MissingPluginException` at runtime, not a graceful "no result."
**Why it happens:** `geocoding` (unlike `geolocator`) has no federated `geocoding_windows`
implementation package — this is a genuine, currently-unaddressed gap in the Baseflow plugin,
not a configuration mistake.
**How to avoid:** Wrap the `placemarkFromCoordinates` call in the same `Result<T>` pattern used
for every other fallible call, and treat a caught `MissingPluginException`/`UnimplementedError`
on Windows identically to D-12's "geocoding failure" outcome — this requires **zero new UI
states** because D-12 already exists and degrades to the city list gracefully. Recommend
checking `defaultTargetPlatform` (or catching the exception directly) and routing straight to
`falhaGeocodificacao` without even attempting the call on Windows, to avoid a guaranteed-slow
plugin-channel round trip that will always fail.
**Warning signs:** A `MissingPluginException` in logs when the app should show the "Localizando
você…" loading spinner; on Windows, users will *always* land on the city list even with location
authorized — confirm this is the accepted behavior with the user (see Open Questions) before
treating it as done.

### Pitfall 2: `administrativeArea` from `geocoding` does not reliably return the two-letter UF

**What goes wrong:** D-09's match rule requires `nome + uf` (normalized) to equal the `Cidade`
table's `unique(nome, uf)` constraint, where `uf` is a 2-character abbreviation (e.g. `"SP"`).
`Placemark.administrativeArea` is documented as "the name of the state or province" — on Android
in particular this frequently returns the **full state name** (`"São Paulo"`), not the
abbreviation, and this has been an open community issue against the sibling `geolocator`
ecosystem (Baseflow/flutter-geocoding#3, "Administrative area US abbreviation").
**Why it happens:** The underlying native geocoders (Play Services `Geocoder`, Apple
`CLGeocoder`) return locale-formatted administrative names, not ISO subdivision codes.
**How to avoid:** Build a small Brazil state-name→UF lookup table (27 entries, static data, no
network) in the `data/` layer and normalize `administrativeArea` through it before the D-09
comparison — never compare `administrativeArea` to `Cidade.uf` directly.
**Warning signs:** A detected city that should match (e.g. Campinas/SP) instead falls through to
D-11's "not served" path even though Campinas *is* in the served list — the failure mode is
silent (looks like a legitimate not-served city, not an error).
`[CITED: GitHub Baseflow/flutter-geolocator#3; pub.dev geocoding Placemark-class docs]`

### Pitfall 3: Windows' `checkPermission()` can throw instead of returning a clean enum

**What goes wrong:** An open GitHub issue against `geolocator` (Baseflow/flutter-geolocator#1577)
reports a `PlatformException` from `checkPermission()` specifically on Windows 11 in certain
configurations, rather than a `LocationPermission.denied` value.
**Why it happens:** `geolocator_windows` calls into `Windows.Devices.Geolocation`, which has its
own OS-level consent flow (Settings → Privacy → Location) separate from the per-app permission —
edge cases around that separation are less mature than the Android/iOS implementations.
**How to avoid:** Wrap the initial `checkPermission()`/`requestPermission()` calls in the
project's `Result<T>` pattern (not a bare `await`), so an unexpected `PlatformException` maps to
an explicit state (recommend routing it to `servicoDesligado`, since the practical fix a user
takes is identical: enable location in Windows Settings) rather than crashing the priming screen.
**Warning signs:** A crash log referencing `PlatformException` from the geolocator plugin channel
on Windows specifically, not reproducible on macOS. `[CITED: GitHub Baseflow/flutter-geolocator#1577]`

### Pitfall 4: `/cidades` "atendidas" is not every row in the `Cidade` table

**What goes wrong:** D-16 says the fixed `assets/cidades.json` should "espelhar as Cidades já
cadastradas no banco da API (as realmente atendidas)." Reading the actual models
(`Empresa.cidades_atuacao`, a `ManyToManyField` to `Cidade`) shows that a `Cidade` row can exist
in the table with **zero** `Empresa` operating there — meaning "exists in the table" and "is
actually served" are different sets. If the fixed asset (or, later, the real `GET /cidades`
endpoint) naively returns `Cidade.objects.all()`, the app could offer a city with zero
listings — a dead end for the visitor, and inconsistent with D-16's stated intent ("as realmente
atendidas").
**Why it happens:** `Cidade` is a flat lookup table maintained by an administrator (per its own
docstring: `"Tabela geral mantida pelo administrador"`), decoupled from which companies actually
operate there.
**How to avoid:** When generating `assets/cidades.json` for this phase, filter to cities with at
least one `empresa_atuante` where `ativa=True` (mirroring the existing
`EmpresaPublicaAPIView.queryset = Empresa.objects.filter(ativa=True)` precedent) — i.e.
`Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()` — not `Cidade.objects.all()`.
Document this filtering rule explicitly in the API-01 contract doc so Phase 2's real
`GET /cidades` endpoint applies the identical rule.
`[VERIFIED: ../imoveis-aqui/Web/empresas/models.py:31-34 — "cidades_atuacao = models.ManyToManyField(\"localizacao.Cidade\", related_name=\"empresas_atuantes\", blank=True)"; ../imoveis-aqui/Web/empresas/api/views.py:8-13 — "queryset = Empresa.objects.filter(ativa=True)"]`

### Pitfall 5: Reopening the app must not re-trigger GPS — but must still validate the saved city

**What goes wrong:** D-08 says a saved city skips GPS entirely on reopen. If the persisted
`nome+uf` city was removed from the served list between sessions (e.g. the company serving it
went inactive), naively trusting the saved value could route the user into a "vitrine" for a
city with zero listings, with no fallback triggered.
**Why it happens:** The served-city list can change server-side (Phase 2+) independent of what's
cached on the device.
**How to avoid:** On reopen with a saved city, still validate the saved `nome+uf` against the
current served-city source (asset this phase, API later) before entering directly; if it's no
longer present, fall back to the city list (reuse the `autorizadaNaoAtendida`-style UI, or a
dedicated "cidade removida" copy) rather than silently trusting stale local state. Flag this to
the planner as a decision point since CONTEXT.md's D-08 wording ("vai direto pra cidade
guardada") doesn't explicitly address the removed-city case — this is a genuine assumption.
`[ASSUMED]`

## Code Examples

### Cursor-Paginated `GET /imoveis` Fixture Shape

```json
{
  "next": "http://api.example.com/api/publico/imoveis/?cursor=cD0y&cidade=Campinas-SP",
  "previous": null,
  "results": [
    {
      "id": 42,
      "titulo": "Apartamento 2 quartos no Cambuí",
      "finalidade": "VENDA",
      "preco_venda": "450000.00",
      "preco_aluguel": null,
      "natureza": "APARTAMENTO",
      "quartos": 2,
      "suites": 1,
      "vagas": 1,
      "area": "68.50",
      "bairro": "Cambuí",
      "cidade": { "id": 3, "nome": "Campinas", "uf": "SP" },
      "foto_capa": "https://api.example.com/media/imoveis/fotos/capa-42.jpg",
      "caracteristicas": ["Portão eletrônico", "Ar-condicionado"],
      "criado_em": "2026-08-14T10:32:00Z"
    }
  ]
}
```
`[ASSUMED — drafted this session from D-02/D-04 + the real Imovel/Cidade/Endereco fields; the
tipologia fields (natureza/quartos/suites/vagas/area) do not exist on Imovel yet (confirmed by
reading imoveis/models.py in full — no such fields present) and are the PENDENTE E2 fields per
D-02. This exact JSON shape needs web-team sign-off per D-03 before being frozen.]`

### `assets/cidades.json` Fixture Shape (matches `GET /cidades` contract, D-13)

```json
{
  "next": null,
  "previous": null,
  "results": [
    { "id": 1, "nome": "Campinas", "uf": "SP" },
    { "id": 2, "nome": "Valinhos", "uf": "SP" }
  ]
}
```
`[VERIFIED: ../imoveis-aqui/Web/localizacao/models.py:4-19 — "nome = models.CharField(max_length=100, uf = models.CharField(\"UF\", max_length=2)"; field names/types match this shape exactly. ../imoveis-aqui/Web/empresas/api/serializers.py:8-11 — "class CidadeSerializer(serializers.ModelSerializer): ... fields = [\"id\", \"nome\", \"uf\"]" confirms this exact serializer already exists in the API repo.]`

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| `SharedPreferences.getInstance()` singleton | `SharedPreferencesAsync()` | `shared_preferences` 2.3.0+ (per pub.dev package description) | pub.dev's own description flags the singleton as "legacy... will be deprecated" — new code should not adopt it. `[CITED: pub.dev shared_preferences package page]` |

**Deprecated/outdated:**
- `SharedPreferences.getInstance()`: superseded by `SharedPreferencesAsync`/
  `SharedPreferencesWithCache`, which read from native storage without an in-memory cache shared
  across isolates/engine instances — matters for a Cubit-driven app where the value must always
  reflect the latest write.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | On Windows, geocoding failure should silently route to the existing `falhaGeocodificacao` (D-12) state rather than a new dedicated "platform not supported" state | Pitfall 1 | Low — worst case is a slightly less precise message; the fallback UX is identical either way. Needs a one-line user confirmation before locking into the plan. |
| A2 | Reopening the app with a saved city that's no longer served should re-trigger the city list rather than trusting the stale value | Pitfall 5 | Medium — if left unaddressed, a user could land on a "ghost" city with zero listings and no path back to the list without manually tapping the switcher |
| A3 | `assets/cidades.json`/future `GET /cidades` should filter to `Cidade.objects.filter(empresas_atuantes__ativa=True)`, not `Cidade.objects.all()` | Pitfall 4, API Contract Draft | Medium — if the fixture mirrors the raw table instead, Phase 2's real endpoint will return a different (correct) list, breaking the "shape stays the same" premise of D-13 |
| A4 | Draft `GET /imoveis` JSON field names/types for the not-yet-existing tipologia fields (`natureza`, `quartos`, `suites`, `vagas`, `area`) and their exact enum values (`CASA`/`APARTAMENTO`/`TERRENO`/`LOTE`) | Code Examples, API Contract Draft | High if wrong — D-02 explicitly calls this "costly to reverse" (renaming later touches fixtures, freezed models, and the real serializer simultaneously). This is the single highest-value item to get explicit web-team sign-off on before coding APP02/03 against it. |
| A5 | `quartos_min`/`suites_min`/`vagas_min` (D-04 names them with the `_min` suffix) implies these are always range filters (≥), never exact-match — but STATE.md's own Blockers section says this is explicitly unresolved ("quartos/suítes/vagas exact-vs-range semantics — not resolvable from docs alone") | API Contract Draft, Open Questions | Medium — if the web team intends exact match for some of these, the frozen param names are wrong and FIL-03's implementation would silently filter incorrectly |
| A6 | Which price (`preco_venda` vs `preco_aluguel`) the vitrine card shows when `finalidade == VENDA_E_ALUGUEL` | API Contract Draft, Open Questions | Low-medium — a UI/copy decision, not a data-shape one, but affects what the contract's "preço" field on the card conceptually means |
| A7 | `ordenacao` enum values (`preco_asc`, `preco_desc`, `area_asc`, `area_desc`, `mais_recentes`) | API Contract Draft | Low — a naming convention guess consistent with D-04's snake_case style; easy to correct later since it's a param value, not a data-shape field |
| A8 | The `cidade` query param on `GET /imoveis` takes the natural key (`nome-uf` or similar), not the numeric `id`, for consistency with D-15's local persistence choice | API Contract Draft, Open Questions | Medium — if the web team's serializer instead expects a numeric `cidade_id`, Phase 2/4 code built against this guess needs rework |

**If this table is empty:** N/A — see rows above.

## Open Questions

1. **Windows and the reverse-geocoding gap (Pitfall 1)**
   - What we know: `geolocator` supports Windows; `geocoding` does not (confirmed via pub.dev
     registry `pubspec.yaml` platform declaration).
   - What's unclear: Whether the team accepts "Windows always falls back to the city list" as
     final behavior for v1, or wants a network-based geocoding fallback (e.g., calling a
     REST reverse-geocoding service) specifically for Windows.
   - Recommendation: Accept the fallback-to-list behavior (zero extra scope, reuses D-12's
     existing state) unless the user says otherwise — confirm at plan-review or in a
     `checkpoint:human-verify` before coding the platform-conditional skip.

2. **quartos/suítes/vagas: exact match or range filter? (A5)**
   - What we know: STATE.md's own Blockers section already flags this as unresolved and
     requiring live coordination with the teammate (E2) — this is not something research can
     resolve from docs alone, it is genuinely undecided upstream.
   - What's unclear: Whether `FIL-03`'s "quartos, suítes e vagas" filters are minimum-threshold
     (`quartos_min=2` means "2 or more") or exact-value (`quartos=2` means "exactly 2").
   - Recommendation: The contract doc (API-01 deliverable) should present **both** naming
     options side by side and require an explicit web-team choice before being marked "frozen" —
     do not let the planner silently pick one.

3. **Which price does the vitrine card show for `VENDA_E_ALUGUEL` listings? (A6)**
   - What we know: `Imovel.finalidade` has three values including a combined
     `VENDA_E_ALUGUEL` state with both `preco_venda` and `preco_aluguel` populated.
   - What's unclear: VIT-02 just says "preço" — singular — on the card.
   - Recommendation: Contract should expose both price fields always (already the case in the
     model) and let the **app** (not the API) decide display convention — e.g., "show both,
     separated" or "show venda primarily with a badge" — this is a Phase 2 UI decision, not an
     API-01 blocker, but flag it now so Phase 2 planning isn't surprised by dual-price data.

4. **`cidade` query param format on `GET /imoveis` (A8)**
   - What we know: D-15 deliberately persists the chosen city by natural key (`nome+uf`), not
     `id`, specifically to be stable across the fixture→real-API transition.
   - What's unclear: Whether the *query param itself* should also take `nome+uf` (e.g.
     `?cidade=Campinas-SP`) or the numeric `id` the API returns from `GET /cidades`.
   - Recommendation: For consistency with D-15's reasoning, recommend the natural-key form in
     the frozen contract, but this needs explicit web-team agreement since it changes how the
     Django `ImovelViewSet`'s future filter backend resolves the `cidade` param (a `slug`-like
     lookup across two fields is slightly more code than an `id` FK filter).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Entire phase (no `pubspec.yaml` exists yet) | ✗ (checked: `flutter --version` → command not found) | — | Must be installed as a Wave 0 task before any scaffolding; target "latest stable" per `instruções.md` (≈3.47.x / Dart 3.13.x confirmed via web search this session, `[CITED: shorebird.dev, Wikipedia Flutter release info]`, re-verify exact number at install time) |
| Dart SDK | Bundled with Flutter | ✗ (same check) | — | Installed alongside Flutter SDK, no separate step |
| Android `adb` / Xcode full toolchain | Only relevant if Android/iOS targets are ever added — **not** in this phase's scope | ✗ (checked: `adb` not found; `xcodebuild` reports only Command Line Tools, not full Xcode) | — | Not needed — project targets Windows + macOS per `instruções.md` §Ambiente, not Android/iOS. Full Xcode IS needed for macOS builds specifically (`flutter build macos`) — verify Xcode.app (not just CLT) is installed before macOS build tasks. |
| `../imoveis-aqui/Web` sibling repo | API-01 contract audit | ✓ | Django 5.2.17, DRF 3.18.1 (read from `requirements.txt`) | — |

**Missing dependencies with no fallback:**
- Flutter SDK itself must be installed before Wave 1 can begin — this should be the plan's first
  task (Wave 0), not assumed as already present.
- Full Xcode (not just Command Line Tools) is required to actually build/run the macOS target —
  currently only CLT is present on this machine. Confirm before scheduling a macOS build/manual
  verification task.

**Missing dependencies with fallback:**
- Android/iOS toolchains: no fallback needed — genuinely out of scope per the written platform
  constraint.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `bloc_test` 10.0.0 + `mocktail` 1.0.5 (per CLAUDE.md; not yet installed — greenfield) |
| Config file | none yet — created when `pubspec.yaml` is scaffolded (Wave 0) |
| Quick run command | `flutter test test/presentation/cidade_selecao/cidade_selecao_cubit_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| LOC-01 | Priming CTA triggers `Geolocator.requestPermission()` exactly once | unit (`bloc_test`, mock `Geolocator` calls behind a thin wrapper interface) | `flutter test test/presentation/cidade_selecao/priming_test.dart` | ❌ Wave 0 |
| LOC-02 | Authorized + served city → `autorizadaEAtendida` state; authorized + unserved → `autorizadaNaoAtendida` | unit (`bloc_test`, mocked `DetectarCidadeUseCase`) | `flutter test test/domain/detectar_cidade_usecase_test.dart` | ❌ Wave 0 |
| LOC-03 | Denied → `recusada` with populated city list, never an error widget | unit (`bloc_test`) | `flutter test test/presentation/cidade_selecao/cidade_selecao_cubit_test.dart` | ❌ Wave 0 |
| LOC-04 | Saved city persists across a simulated app restart (fresh Cubit instance reads from the same `CidadePrefsDataSource`) | unit (fake in-memory `SharedPreferencesAsync` or a fake `CidadePrefsDataSource`) | `flutter test test/data/cidade_prefs_datasource_test.dart` | ❌ Wave 0 |
| LOC-05 | Tapping the city switcher re-opens the selection screen, does not call GPS | widget test | `flutter test test/presentation/cidade_selecao/city_switcher_widget_test.dart` | ❌ Wave 0 |
| LOC-06 | Each of the 7 sealed-state variants renders distinct UI (no fallthrough to a generic error widget) | widget test (golden or structural — assert no generic `ErrorWidget` is rendered) | `flutter test test/presentation/cidade_selecao/cidade_selecao_screen_test.dart` | ❌ Wave 0 |
| API-01 | N/A — documentation deliverable, not testable code | manual-only | — | ❌ Wave 0 (no test — verified by web-team review/sign-off instead) |

### Sampling Rate

- **Per task commit:** `flutter test <changed test file>`
- **Per wave merge:** `flutter test` (full suite)
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps

- [ ] `flutter create .` scaffold + `pubspec.yaml` with the full dependency list — nothing exists yet.
- [ ] `test/` directory structure mirroring `lib/` — standard Flutter convention, not present.
- [ ] A thin `GeolocatorGateway`/`GeocodingGateway` wrapper interface in `domain/` so
  `geolocator`/`geocoding`'s static methods can be mocked with `mocktail` (their real APIs are
  static top-level functions, not injectable classes — this wrapper is required infrastructure,
  not optional, for LOC-01/02 to be unit-testable at all).
- [ ] Fake/in-memory `SharedPreferencesAsync` test double for LOC-04's persistence test — the
  real `shared_preferences` package ships a `SharedPreferencesAsyncPlatform.instance` test
  override pattern; confirm exact API when scaffolding Wave 0 (not verified this session).

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | No | App has no login (explicit project constraint — "sem conta e sem senha") |
| V3 Session Management | No | No session concept exists in this phase |
| V4 Access Control | Partial | The future public API endpoints (`/api/publico/*`) must not leak `Empresa`/`Imovel` internal fields — precedent already exists (`EmpresaPublicaSerializer` allowlists fields explicitly) — this phase's contract doc must specify the same allowlist discipline for the `/imoveis` public serializer, not just describe fields loosely |
| V5 Input Validation | Yes | `freezed`+`json_serializable` typed `fromJson` on all API/asset responses; UI-SPEC already specifies malformed-row-drop behavior for `assets/cidades.json` parsing (defensive, not a crash) |
| V6 Cryptography | No | No secrets/tokens in scope — this phase's persisted data (chosen city name) is not sensitive |
| V8 Data Protection | Yes (light) | Location coordinates are transient (never persisted — only the resolved city name/UF is saved via `shared_preferences`); do not log raw lat/long to any analytics/crash-reporting sink added in a later phase |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| Public serializer leaking internal fields (`proprietario`, `corretor_responsavel`, `empresa` id/CNPJ) once `/api/publico/imoveis/` is actually built (Phase 4) | Information Disclosure | Explicit field allowlist on a dedicated public serializer — never reuse the authenticated `ImovelSerializer` (which includes `corretor_responsavel`, `proprietario`) for the public endpoint. This phase's contract doc must name the allowlist explicitly so Phase 4 doesn't rediscover this the hard way. |
| Multitenant isolation bypass via `cidade`/`id` query manipulation on the future public `/imoveis` endpoint | Elevation of Privilege / Tampering | Not scoped to this phase's build (no endpoint code written yet), but the contract doc should note that the public endpoint filters by `publicado=True` at the queryset level (not per-request trust), mirroring the existing `EmpresaScopedQuerySetMixin` pattern used for the authenticated `ImovelViewSet` |
| Over-broad location permission scope (`always`/background) requested unnecessarily | (not STRIDE — privacy/least-privilege) | Request `whileInUse` only (see Anti-Patterns) |

## Sources

### Primary (HIGH confidence)
- pub.dev registry API (`https://pub.dev/api/packages/<pkg>`, `.../score`, `.../publisher`) —
  queried directly this session for every package's latest version, publish date, publisher
  identity, and platform support tags.
- `../imoveis-aqui/Web/imoveis/models.py`, `localizacao/models.py`, `core/models.py`,
  `empresas/models.py`, `imoveis/api/{serializers,views,urls}.py`, `empresas/api/{serializers,
  views,urls_publico}.py`, `contas/api/urls_publico.py`, `config/urls.py`, `config/settings.py`,
  `requirements.txt` — all read directly this session.
- `.planning/phases/01-.../01-CONTEXT.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`,
  `.planning/PROJECT.md`, `.planning/phases/01-.../01-UI-SPEC.md`, `.claude/CLAUDE.md`,
  `instruções.md` — all read directly this session.

### Secondary (MEDIUM confidence)
- pub.dev package pages fetched via WebFetch for `geolocator`, `geocoding`, `shared_preferences`
  — permission enum values, Placemark fields, `SharedPreferencesAsync` code example.
- Django REST Framework official pagination docs (`django-rest-framework.org`) — `CursorPagination`
  envelope shape and `cursor_query_param` default.
- GitHub issues Baseflow/flutter-geolocator#3 and #1577 — cited for specific known platform
  quirks (administrativeArea format, Windows PlatformException).

### Tertiary (LOW confidence)
- WebSearch results for current Flutter stable version (3.47.x / Dart 3.13.x) — cross-referenced
  two secondary sources (Shorebird docs, Wikipedia), not the official flutter.dev release page
  directly; re-verify with `flutter --version` once the SDK is actually installed (Wave 0).

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — every version/publisher confirmed against the pub.dev registry API this session, matching CLAUDE.md exactly.
- Architecture: HIGH — patterns are direct applications of already-locked project constraints (Clean Architecture, sealed Result, Cubit), not new choices.
- API contract: MEDIUM — grounded in real model files read this session, but contains multiple genuinely open semantic questions (tipologia enum values, quartos/suítes/vagas semantics, price display convention, cidade param format) that need explicit web-team sign-off before the contract can be called "frozen" per D-03.
- Pitfalls: HIGH for the Windows/`geocoding` platform gap and the `cidades_atuacao` scoping gap (both directly verified against registry/model source this session); MEDIUM for the `administrativeArea` and Windows `PlatformException` issues (community-reported, not independently reproduced this session).

**Research date:** 2026-09-21
**Valid until:** 30 days for the Flutter package stack (stable ecosystem); re-verify immediately if the web team changes the `Imovel`/`Cidade`/`Empresa` models before this phase's contract doc is signed off.
