# Pitfalls Research

**Domain:** Flutter city-vitrine app (location + reverse-geocode + paginated/filtered list) consuming a Django/DRF public API that this project also builds
**Researched:** 2026-09-21
**Confidence:** HIGH (Flutter location/pagination/DRF patterns are well-documented, stable ecosystems; MEDIUM on project-specific coordination pitfalls since they depend on teammate behavior not yet observed)

## Critical Pitfalls

### Pitfall 1: Requesting location permission on cold start before explaining why

**What goes wrong:**
The app calls `Geolocator.requestPermission()` (or `Permission.location.request()`) the instant `main()`/splash finishes, before the user has any context. iOS and Android both show the OS permission dialog on first launch with zero pre-framing. Users reflexively tap "Don't Allow" / "Deny" on a screen with no app content yet, because they don't know why an unfamiliar app wants their location. Once denied on iOS, the system dialog never reappears — the app is stuck without an explicit "ask again" path.

**Why it happens:**
It feels natural to ask for location "since that's the whole point of APP01," and skipping a pre-permission explainer screen saves a build step. Teams treat permission dialogs as a technical precondition instead of a UX moment.

**How to avoid:**
Show a lightweight in-app rationale (not a second OS dialog, just app UI: "Usamos sua localização para abrir direto na vitrine da sua cidade") with a "Permitir localização" CTA that *then* triggers the OS prompt, plus a visible "Escolher cidade manualmente" alternative on the same screen. This satisfies both iOS App Review guidance and Android's "why permission" pattern, and gives the user an equally fast path (city picker) instead of a dead end.

**Warning signs:**
- Permission dialog fires inside `initState`/`main()` before any screen renders.
- No fallback UI reachable without granting permission.
- QA reports "app feels broken" when permission is denied during first test.

**Phase to address:** APP01

---

### Pitfall 2: Treating "permission denied" as an error state instead of a normal path

**What goes wrong:**
The domain use case throws/returns a `Failure` when permission is denied or `deniedForever`, and the presentation layer renders a generic error screen ("Algo deu errado") with a retry button that just re-triggers the same denied request in a loop. The city-choice fallback described in APP01 ("recusada — caminho normal, não um beco") never actually renders because the code path was built as an exception, not a first-class state.

**Why it happens:**
`PermissionStatus` has many values (`denied`, `deniedForever`, `restricted`, `granted`, `limited`) and it's tempting to collapse everything that isn't `granted` into a single `Failure`. Clean Architecture's `Result`/`sealed class` pattern makes this worse if the state enum only has `Loading/Success/Failure` — there's no natural slot for "permission declined, show picker."

**How to avoid:**
Model permission outcomes as explicit sealed states, not exceptions: `LocationGranted(Position)`, `LocationDenied` (recoverable — show request-again UI), `LocationDeniedForever` (must deep-link to app settings via `openAppSettings()` since the OS prompt won't reappear), `LocationUnresolved` → routes to city-choice list. None of these are `Failure`; `Failure` is reserved for true errors (GPS hardware fault, unexpected exception).

**Warning signs:**
- Only one enum value exists for "no location" in the Cubit/state class.
- Denied-forever and denied-once are handled identically (both just say "try again").
- No UI path to `openAppSettings()`.

**Phase to address:** APP01

---

### Pitfall 3: No timeout on `getCurrentPosition()` — infinite spinner with no GPS/indoors/emulator

**What goes wrong:**
`Geolocator.getCurrentPosition()` can hang indefinitely on devices with weak/no GPS signal (indoors, basements, emulators without mock location, airplane mode with Wi-Fi-only positioning unavailable). Without a timeout, the splash/loading screen spins forever and the user has no way out except force-quitting the app.

**Why it happens:**
Happy-path testing on a real phone outdoors or a simulator with a fixed mock location never exposes this; the failure only shows up on real devices in real buildings, often discovered by users in production, not QA.

**How to avoid:**
Always pass a `timeLimit` (e.g., 8–10s) to `getCurrentPosition()`, and additionally check `Geolocator.isLocationServiceEnabled()` before requesting a position (device GPS/location services toggled off entirely is a different case from permission denial and needs its own message: "Ative a localização do aparelho"). On timeout, degrade to the city-choice list rather than retrying silently — this reuses the same fallback UI as Pitfall 2.

**Warning signs:**
- No `timeLimit` parameter in the `getCurrentPosition` call.
- No separate check for `isLocationServiceEnabled()`.
- Manual test "turn off GPS mid-flow" was never run.

**Phase to address:** APP01

---

### Pitfall 4: Reverse-geocoded city not in the API's served-cities list

**What goes wrong:**
Reverse geocoding (`geocoding` package or platform geocoder) returns a city name straight from OS/geocoding provider data — e.g., "São Paulo" vs. the API's canonical "São Paulo - SP", or a small satellite town/district name that the business doesn't serve at all. If the app does a naive string match against `GET /cidades` and finds no match, it either crashes, shows a blank vitrine, or silently defaults to the first city in the list (silently wrong location for the user).

**Why it happens:**
Developers assume reverse geocoding returns exactly the string the business database uses. Geocoding is fuzzy and jurisdiction-name conventions vary (city vs. metro region vs. municipality with accents/diacritics differences).

**How to avoid:**
Never string-match the raw geocoder output directly against city *names* for selection. Fetch `GET /cidades` first (or from local cache), then match the geocoded city against that list using a normalized comparison (lowercase, strip accents/diacritics) — and if there is no confident match, treat it exactly like "location denied": fall through to the manual city-choice screen with a message like "Não atendemos sua região ainda — escolha uma cidade". Never auto-select "closest city" without the user seeing which city was chosen; always show a confirm step ("Você está em Cidade X, é isso? [Sim] [Trocar]") so a bad geocode doesn't silently strand the user in the wrong vitrine.

**Warning signs:**
- Matching logic is `cidades.any((c) => c.nome == geocodedName)` with no normalization.
- No UI state for "geocoded city not served."
- No confirmation step before locking in the detected city.

**Phase to address:** APP01 (and revisited in APP02 once city list moves from hard-coded to API-sourced — see Pitfall 6)

---

### Pitfall 5: Missing or wrong platform permission strings block store submission / silently fail at runtime

**What goes wrong:**
On iOS, forgetting `NSLocationWhenInUseUsageDescription` in `Info.plist` causes an instant crash (not a graceful denial) the moment the OS tries to show the permission dialog — App Review will also reject the build. On Android, forgetting `ACCESS_COARSE_LOCATION`/`ACCESS_FINE_LOCATION` in `AndroidManifest.xml` makes the plugin permission check always report denied, with a confusing error that looks like a permission-flow bug rather than a missing manifest entry.

**Why it happens:**
`geolocator`/`permission_handler` require manual native manifest edits in addition to the Dart-level `requestPermission()` call — this is easy to skip since the Dart code compiles and runs fine on some platforms until the specific permission-requesting code path executes.

**How to avoid:**
Add `NSLocationWhenInUseUsageDescription` (only "when in use," never request "always" — this app only needs a one-time fix on city, not background tracking) to `Info.plist` with a real, translated rationale string, and `ACCESS_COARSE_LOCATION` + `ACCESS_FINE_LOCATION` to `AndroidManifest.xml`, as part of the APP01 setup checklist — before writing any Dart permission-handling code, so the native layer is never the untested variable.

**Warning signs:**
- App crashes (not "denies") on iOS the first time location is requested.
- Android `checkPermission()` always returns `denied` even after tapping "Allow" in a real device test.
- Manifest/plist diff missing from the APP01 PR.

**Phase to address:** APP01

---

### Pitfall 6: Storing the chosen city by name instead of a stable ID, breaking when APP02 swaps the source

**What goes wrong:**
APP01 ships with a hard-coded city list (per PROJECT.md: "Lista de cidades pode começar fixa no app"). If the persisted value is the city's display *name* (a `String`), APP02's switch to an API-sourced city list can produce a different casing, accent, or naming convention for the "same" city (e.g., hard-coded `"São Paulo"` vs. API `"São Paulo - SP"` or a different `slug`). Existing users who already chose a city on APP01 silently lose their selection on upgrade, or worse, get matched to the wrong city if two different cities share a substring.

**Why it happens:**
A quick MVP naturally persists whatever value is easiest to display back to the user — the name — since APP01 has no API-sourced IDs yet to persist instead.

**How to avoid:**
Even while the city list is hard-coded in APP01, give every hard-coded city entry a stable identifier (`id` or `slug`) that is designed to match — or will be migrated to match — the primary key `GET /cidades` will later return, and persist that ID (not the display name) in local storage (`SharedPreferences`/`Hive`) alongside a cached display name for offline rendering. When APP02 lands, write a one-time migration step: on first launch after the API-sourced list is available, resolve the persisted ID against the new list; if not found, clear the persisted choice and route to the city-choice screen instead of silently keeping a stale/wrong city.

**Warning signs:**
- `SharedPreferences` key stores a raw city name string, no ID field.
- No migration/reconciliation logic mentioned when APP02 planning starts.
- Hard-coded APP01 city list has no ID scheme at all (just a `List<String>`).

**Phase to address:** APP01 (data model decision) → APP02 (migration execution)

---

### Pitfall 7: Client-side filtering/search/sort "just for now" because the API isn't ready yet

**What goes wrong:**
Because the Imóvel model and `/imoveis` endpoint are still being built by the teammate (E2), it's tempting to unblock APP02/APP03 by fetching one big page of properties and filtering/sorting/searching them in Dart on-device — "we'll swap it to server-side later." This becomes the shipped behavior because "later" rarely comes, it doesn't scale past a handful of properties, and it directly violates the project's non-negotiable rule (PROJECT.md: "nenhuma regra de negócio é decidida no celular"; "Filtrar no celular exigiria baixar o acervo inteiro — não escala e gasta o dado do visitante").

**Why it happens:**
Client-side filtering is faster to build solo and doesn't require backend coordination, so under deadline pressure it looks like the path of least resistance — especially since the app and API in this project are built by the same person/timeline, making it tempting to "just skip the contract phase."

**How to avoid:**
Contract-first, not code-first: before writing any APP02/APP03 UI, write and freeze the `GET /imoveis` query-parameter contract (see Pitfall 12) as a doc/OpenAPI stub, then build APP02/APP03 against a mock server or fixture JSON that returns *pre-filtered/pre-sorted* data honoring that contract — never against a full in-memory list that the app then filters. This keeps the app "a thin client" by construction: if there's no code path that holds the entire imóveis list in memory, client-side filtering is structurally impossible, not just discouraged by convention.

**Warning signs:**
- Any `List<Imovel>.where(...)` / `.sort(...)` call in `presentation/` or `domain/` driven by user-entered filter/search/sort values.
- A repository method that fetches "all imóveis for a city" with no query params, called once and cached locally for re-filtering.
- Search-as-you-type that doesn't trigger a new network call per keystroke debounce.

**Phase to address:** APP02, APP03 — and API-IMOVEIS (contract must exist before APP02/APP03 planning starts)

---

### Pitfall 8: Offset/page-number pagination drifting when the underlying data changes mid-scroll

**What goes wrong:**
DRF's default `PageNumberPagination`/`LimitOffsetPagination` recomputes "page 2" as "skip N, take M" against the live table each request. If new imóveis are published (or existing ones get their `finalidade`/preço/situação changed by a corretor) while the user is scrolling, offset-based pagination can show duplicate items (an item shifts from page 3 to page 2 between requests) or skip items entirely (an item shifts the other direction). At vitrine scale this is a real risk since properties are actively managed by multiple corretores while visitors browse.

**Why it happens:**
Offset pagination is DRF's default and the simplest to wire up; the instability only appears under concurrent writes, which local dev/manual testing rarely reproduces since one developer isn't editing imóveis while scrolling as a "visitor."

**How to avoid:**
Prefer a stable ordering with a deterministic tiebreaker for the default sort (e.g., `ORDER BY data_publicacao DESC, id DESC`, never just `id` alone or an unordered default) so "most recentes" doesn't reshuffle silently, and accept that page-number/offset pagination is acceptable here (this is a public vitrine, not a financial ledger — occasional duplicate/missing card on live-changing data is a UX nit, not a correctness bug) *as long as* the app treats duplicates defensively: dedupe by `id` when appending pages to the in-memory list (a `Set`-backed check or `Map<id, Imovel>` merge instead of blind `list.addAll(newPage)`), so a shifted duplicate card doesn't render twice.

**Warning signs:**
- Infinite-scroll `addAll()` call with no dedupe-by-id logic.
- Default DRF ordering left unset (Postgres does not guarantee stable order without `ORDER BY`).
- No manual test of "publish a new imóvel to city X while a test session is mid-scroll on city X."

**Phase to address:** APP02 (dedupe-on-append) and API-IMOVEIS (deterministic ordering)

---

### Pitfall 9: Sort/filter change mid-scroll appends to the existing list instead of resetting it

**What goes wrong:**
The user is on page 3 of "preço crescente," switches to "mais recentes" or types a new search term, and the infinite-scroll controller — because it only knows "load next page" — either keeps appending page 4 under the *old* sort, or appends the *new* sort's page 1 onto the *old* sort's pages 1–3, producing a visibly scrambled, duplicated list (imóveis appear twice with different neighbors, ordering looks broken).

**Why it happens:**
Infinite-scroll pagination controllers are usually built as "load more" appenders and it's easy to forget that *any* change to search/sort/filter parameters invalidates the current page cursor — this is a different kind of "reset" than a pull-to-refresh, and it's easy to wire the filter/sort UI to just refetch page 1 and `addAll` it onto the existing list rather than replacing the list.

**How to avoid:**
Any state change to query params (search text after debounce, sort key, filter values) must clear the current item list and pagination cursor (`page = 1`, `hasMore = true`) before firing the new request — treat it as a "new query" state transition, not an "append" transition. Model this explicitly in the Cubit: a distinct event/method (`aplicarFiltros(novosFiltros)`) that always resets pagination state, separate from `carregarProximaPagina()` which never changes query params.

**Warning signs:**
- One single method handles both "load next page" and "apply new filter."
- List flickers with duplicate/out-of-order cards when switching sort mid-scroll during manual test.
- No explicit "reset" state transition documented in the Cubit's states.

**Phase to address:** APP02 (pagination controller design), APP03 (filter application flow)

---

### Pitfall 10: Filter query params app and API disagree on (silent 200 with wrong/empty results instead of a clear contract error)

**What goes wrong:**
The app builds `GET /imoveis?cidade=1&finalidade=venda&quartos_min=2` but the API expects `?cidade_id=1&tipo_negocio=venda&quartos__gte=2` (or any other naming mismatch — plural vs singular, `min`/`max` suffix convention, enum value casing like `"Venda"` vs `"venda"` vs `"VENDA"`). DRF filter backends (`django-filter`, custom `FilterSet`) silently *ignore* unrecognized query params by default rather than erroring — so a mismatched param name doesn't 400, it just gets dropped, and the API returns the *unfiltered* list. The app then displays results that look plausible (a real, non-empty list) but are actually wrong — the single worst failure mode here because nothing crashes or looks obviously broken.

**Why it happens:**
The app (this repo) and the API (this repo, same developer, different "sides" in the PROJECT.md split) are built somewhat in parallel from a mental model rather than a written contract, and `django-filter`'s default behavior (silently ignore unknown params) actively hides the mismatch instead of surfacing it.

**How to avoid:**
Write the exact query-param names, types, and enum values as a literal contract artifact (a markdown table or OpenAPI-lite doc committed to the repo, e.g. `.planning/research/` or a shared `CONTRATO-API.md`) before either side is coded, and keep both a Dart `enum`/const map and the DRF `FilterSet` field list in sync with that single source of truth — treat renaming a filter param as a breaking-contract change requiring updates in both places in the same commit/PR. In DRF, prefer explicit `FilterSet` fields (not `fields = '__all__'`) so unrecognized params are a deliberate allow-list, and add a test that asserts a known-good filter combination returns a *different* (smaller) result set than no filter — a regression test that would catch "params silently ignored" immediately.

**Warning signs:**
- No single written source of truth for filter param names shared between app and API code.
- `FilterSet` uses `fields = '__all__'` or accepts `**kwargs` loosely.
- No test asserting "applying a filter changes the result count" (as opposed to just "the endpoint returns 200").

**Phase to address:** API-AUDIT (define the contract) → APP03 + API-IMOVEIS (implement against the frozen contract)

---

### Pitfall 11: Empty-result and error states rendered identically ("no imóveis found" looks like "request failed")

**What goes wrong:**
A `Success<List<Imovel>>([])` (legitimate zero matches for an aggressive filter combo, e.g., "5 quartos + piscina + até R$50.000") and a `Failure` (network error, 500, malformed JSON) both end up rendering the same generic empty/blank state, or conversely a genuine empty result gets treated as an error and shows a scary "Algo deu errado, tente novamente" message for a perfectly valid "no properties match your filters" case.

**Why it happens:**
The sealed-state pattern (`Loading/Success/Failure`) is correct, but teams often only design one "nothing to show" UI and wire both empty-success and failure into it, because building two distinct empty/error visual states feels like scope creep on a list screen.

**How to avoid:**
Design three distinct terminal UI states for the vitrine list, not two: `Success` with items (the list), `Success` with an empty list ("Nenhum imóvel encontrado com esses filtros — tente ajustar" + a visible "limpar filtros" action), and `Failure` ("Não foi possível carregar os imóveis agora" + retry action, no filter-clearing suggestion since that's not the problem). This is a direct consequence of the `Result`/sealed-class constraint already mandated by PROJECT.md — the empty list is data (`Success<List<Imovel>>([])`), not the absence of data (`Failure`), and the UI must branch on that distinction, not just on "is the list non-empty."

**Warning signs:**
- Only one "empty state" widget exists in the codebase, referenced by both success-empty and failure paths.
- Empty-filter-results shows a "tentar novamente" (retry) button, which implies something broke.
- No manual test case for "apply filters guaranteed to match zero imóveis."

**Phase to address:** APP02, APP03

---

### Pitfall 12: Public `/imoveis` and `/cidades` endpoints leak internal fields or unpublished/other-tenant records

**What goes wrong:**
Because `Imovel` will be an `EmpresaOwnedModel` in the same multitenant base as the rest of the system, a naive `ModelViewSet`/serializer built by copying the pattern from authenticated internal endpoints will (a) serialize *every* model field including `proprietario`, `documento`, internal notes, cost/commission fields, or the owning `empresa`'s internal data, and (b) return imóveis across *all* empresas and in *any* `situacao` (draft, unpublished, sold-and-hidden) rather than only `publicado=True` records — because the queryset has no `.filter(publicado=True)` and the multitenant scoping mixin (`EmpresaScopedQuerySetMixin`) that normally derives the empresa from the *authenticated* user doesn't apply to a public, unauthenticated endpoint (there is no `request.user.empresa` to scope by).

**Why it happens:**
This is the single highest-severity pitfall in the whole project given PROJECT.md's explicit framing ("Isolamento multitenant é o critério de maior peso da avaliação") — yet the public vitrine endpoints are structurally the *one* place in the API that must deliberately punch a hole in that isolation model (multiple empresas' published imóveis, unauthenticated), which is exactly the kind of "exception to the rule" that's easy to get wrong precisely because every other endpoint in the codebase is built the opposite way (scope-by-authenticated-empresa).

**How to avoid:**
Never reuse the internal admin/gestor serializer for the public endpoint — write a dedicated `ImovelPublicoSerializer` with an explicit allow-list of fields (title, price, natureza, bairro, quartos, cover photo, etc.) that structurally cannot leak `proprietario`/`documento`/internal fields because they're not listed, not because they're excluded. Build the public queryset with an explicit, hard-coded filter — `Imovel.objects.filter(publicado=True)` (or whatever the teammate's model calls it) with **no** empresa-scoping mixin at all, since "public across all empresas" is correct here by design (this is the shared public vitrine, not a single tenant's private view) — but confirm that assumption explicitly with the teammate/PM rather than assuming it, since it's the one place the standard rule inverts. Add an automated test that asserts an unpublished/draft imóvel and a `proprietario` field never appear in the public endpoint's response, run in CI as a security regression test, not just a feature test.

**Warning signs:**
- Public `ImovelPublicoSerializer` uses `fields = '__all__'` or extends the internal serializer.
- Queryset for `/imoveis` has no `.filter(publicado=True)` (or equivalent) clause.
- No test named anything like "public endpoint does not leak unpublished/internal fields."
- The endpoint is scoped to a single empresa (URL like `/imoveis?empresa=1`) when it should show all empresas' published listings, or vice-versa — confirm which is actually correct for this vitrine.

**Phase to address:** API-IMOVEIS (critical — should block launch until verified), API-AUDIT (should flag this explicitly as a review item)

---

### Pitfall 13: N+1 queries and unbounded page size on the public list endpoint

**What goes wrong:**
`/imoveis` is the one endpoint expected to take real, un-authenticated public traffic (every vitrine visitor, no login gate) and to display cover photos, addresses (`Endereco`), and possibly nested `bairro`/`cidade` data per card. A naive serializer accessing `imovel.endereco.bairro` or `imovel.cidade.nome` per item without `select_related`/`prefetch_related` on the viewset's queryset produces one query per row (N+1) — invisible with 5 test records, punishing at real vitrine scale (hundreds of imóveis per city). Separately, if `page_size_query_param` is enabled without a `max_page_size` cap, any client (including the app itself, by an app bug, or a scraper) can request `?page_size=10000` and force the DB/API to serialize the entire acervo in one response — a self-inflicted DoS vector on the one endpoint that's open to the whole internet with no auth throttle.

**Why it happens:**
Query optimization and pagination limits are invisible in local dev with a handful of seed records — they only bite once there's meaningful data volume, which is exactly the moment a public-facing endpoint would be hit hardest.

**How to avoid:**
Set `select_related('cidade', 'endereco', 'endereco__bairro')` (adjust to the teammate's actual model shape) on the public queryset for every FK the serializer touches, and `prefetch_related` for any reverse-FK/M2M (photos, características). Set DRF's pagination class explicitly with a fixed reasonable default (`page_size = 20`) and, if `page_size_query_param` is exposed at all, always set `max_page_size` (e.g., 50) alongside it — never expose an uncapped client-controlled page size on a public endpoint. Verify with Django Debug Toolbar or `django-silk`/query-count assertions in a test (`assertNumQueries`) that listing N imóveis costs a constant, small number of queries regardless of N.

**Warning signs:**
- Serializer method fields or nested serializers access related objects without a matching `select_related`/`prefetch_related` on the viewset queryset.
- `page_size_query_param` set with no `max_page_size`.
- No `assertNumQueries`-style test on the list endpoint.

**Phase to address:** API-IMOVEIS, API-CIDADES (same pattern applies if cidades ever gets nested relations)

---

### Pitfall 14: Building APP02/APP03 blocked waiting on the teammate's Imóvel model instead of contract-first mocking

**What goes wrong:**
PROJECT.md explicitly flags the Imóvel model as "**dependência** minha, mas construídos na frente web pelos colegas (E2)". Without a deliberate unblocking strategy, APP02/APP03 (and even API-IMOVEIS's own implementation) stall waiting for the teammate to finish the model, fields, and migrations — turning a parallelizable cross-team dependency into a serialized bottleneck, and creating pressure to cut corners (see Pitfall 7 — client-side filtering) once the deadline looms.

**Why it happens:**
It feels more "real" to build against the actual model/DB than a mock, so teams default to waiting rather than investing upfront in a contract artifact — especially when the same person controls both the app and the API-building task and could "just wait until the model lands, then build both."

**How to avoid:**
Do the API-AUDIT task first and produce a frozen response-shape contract for `GET /imoveis` (field names, types, pagination envelope, filter param names — see Pitfall 10) *independent of* the teammate's final Django model internals — the contract describes the public JSON shape, not the DB schema. Build APP02/APP03 against a local JSON fixture or a lightweight mock server (e.g., `json_server`, a Django management command that returns static fixture data, or DRF viewset stub backed by an in-memory list) that matches the frozen contract. When the teammate's real Imóvel model lands, API-IMOVEIS's job becomes "map the real model to the already-agreed contract" — a bounded, well-defined task — rather than "invent the contract and the mapping simultaneously under time pressure." Explicitly negotiate the contract *with* the teammate before freezing it (field names they'll actually have, e.g., confirm `natureza` enum values exist) so API-IMOVEIS isn't reverse-engineering a mismatch later.

**Warning signs:**
- APP02/APP03 planning stalls with "waiting on Imóvel model" as a blocking note.
- No fixture/mock JSON file exists anywhere in the app repo before APP02 starts.
- The filter contract (Pitfall 10) and the Imóvel model's actual field names were never explicitly compared/reconciled with the teammate.

**Phase to address:** API-AUDIT (produces the contract) → APP02/APP03 (consume mock, then swap to real API without UI changes)

---

### Pitfall 15: `ColorScheme.fromSeed` with a green seed produces poor contrast or clashing semantic colors (error, warning) without deliberate tuning

**What goes wrong:**
`ColorScheme.fromSeed(seedColor: Colors.green)` generates a full Material 3 tonal palette algorithmically (via Material Color Utilities), including `error`, `onError`, `surface`, `onSurface`, etc. Teams pick a green seed for brand reasons and then discover: (a) the generated "on primary"/"on surface" text colors can have borderline contrast in certain tonal combinations if the seed is a very light or very saturated green picked purely for brand-matching rather than for how M3's tonal algorithm treats it, (b) the auto-generated `error` color is a Material-default red *derived independently of the seed*, which is correct/expected M3 behavior but often gets "fixed" by hardcoding a clashing custom red that fights the rest of the generated palette, and (c) `brightness` (light/dark) isn't set explicitly, so `ColorScheme.fromSeed` silently defaults and the "Branco" (white) half of the palette requirement isn't actually verified against real M3 surface tones (M3 surfaces are rarely pure `#FFFFFF` — they're tinted with the seed).

**Why it happens:**
`ColorScheme.fromSeed` is a one-liner that "just works" visually in a quick screenshot, so teams treat it as done without checking contrast ratios or confirming the light/white background actually reads as the required "Branco" rather than a green-tinted off-white, and without running an accessibility contrast check on real screens (price/status text on colored Card backgrounds, error text on filter validation).

**How to avoid:**
Explicitly set `brightness: Brightness.light` (this project has no stated dark-mode requirement — don't build/theme for it if it's out of scope) when calling `ColorScheme.fromSeed`, and manually verify against WCAG AA (4.5:1 for body text) the specific pairs that will actually appear on screen: `onPrimary` on `primary` (e.g., "Filtrar" `FilledButton` text), `onSurface` on `surface` (list card text), and the *default* `error`/`onError` pair on whatever background validation messages render on (e.g., "faixa de preço inválida" on a filter form) — don't hand-pick a different red without re-checking contrast against the generated palette. If the brand's exact green must be the *visible* primary color (not just a seed nudging tone), verify it survives `fromSeed`'s tonal remapping by testing the actual rendered `colorScheme.primary` value, not just eyeballing the seed input.

**Warning signs:**
- No `brightness` argument passed to `ColorScheme.fromSeed`.
- No contrast check performed on button text, card text, or error/validation text against their actual backgrounds.
- Error/warning colors hardcoded separately from the seed-generated `colorScheme.error`.
- "Verde e Branco" palette review is done by screenshot eyeballing only, not against real card/list content with price/status labels.

**Phase to address:** Any phase touching `ThemeData`/`MaterialApp` setup (likely earliest in APP01, since it establishes the app shell) — flag for a UI-review pass before APP02/APP03 ship visible list/filter screens.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|-----------------|------------------|
| Fetch "all imóveis for city" once, filter/sort in Dart | Unblocks APP02 UI without waiting on API filter params | Breaks PROJECT.md's core constraint; re-download on every filter change once dataset grows; must be fully rewritten | Never for shipped behavior — only acceptable as a throwaway local prototype deleted before merge |
| Persist chosen city as display name string | One field, trivial `SharedPreferences` code in APP01 | Breaks silently when APP02 swaps to API-sourced IDs (Pitfall 6); requires a migration pass later | Only if an explicit migration step is already planned into APP02's scope |
| Reuse internal `ImovelSerializer` for the public endpoint, minus a few fields manually excluded in the view | Faster to ship API-IMOVEIS | Any new field added to the internal model later leaks publicly by default (opt-out instead of opt-in) | Never — always build a dedicated opt-in public serializer |
| Skip `max_page_size` on public pagination "since the app always sends a fixed page size anyway" | One less setting to configure | Any other client (scraper, bug, future site frontend) can force full-table responses | Never on a public unauthenticated endpoint |
| Build APP03 filters UI before the query-param contract is frozen, guessing param names | Keeps moving instead of waiting | Silent param-name mismatches (Pitfall 10) discovered late, often in demo/review, not in dev | Only with mock/fixture data whose param names are explicitly marked "provisional — must reconcile with API-AUDIT before merge" |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|-----------------|-------------------|
| `geolocator` / `geocoding` plugins | Requesting "always" location permission when only "when in use" (one-time city lookup) is needed | Request only `NSLocationWhenInUseUsageDescription` / `ACCESS_COARSE_LOCATION`; never request background/always location for this use case |
| `GET /cidades` consumed by APP01's hard-coded list | Treating the hard-coded list as throwaway and the API list as unrelated, so IDs never line up (Pitfall 6) | Design APP01's hard-coded list with the same ID/slug shape the API will use, from day one |
| `GET /imoveis` filters (`django-filter`) | Silent param-name drift between app and API since unknown params are dropped, not rejected (Pitfall 10) | Freeze a written filter contract before either side codes against it; add a DRF test asserting filters change result counts |
| DRF pagination envelope | App assumes a specific envelope shape (`count`/`next`/`previous`/`results`) without confirming which pagination class (`PageNumber` vs `LimitOffset` vs custom) the API actually uses | Pin the pagination class and document its exact JSON envelope in the same contract doc as the filter params |
| Multitenant base (`EmpresaOwnedModel`, `EmpresaScopedQuerySetMixin`) reused for public endpoints | Assuming the standard scoping mixin is safe to reuse as-is for an unauthenticated public view (it derives empresa from `request.user`, which doesn't exist here) | Write the public queryset filter explicitly (`publicado=True`, no user-derived empresa scope) and confirm with the team whether the public vitrine spans all empresas or is scoped some other way |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|-----------------|
| N+1 queries on `/imoveis` list serializer | List endpoint gets slower as more imóveis/cidades/bairros are seeded; fine with 5 test records | `select_related`/`prefetch_related` on every FK/M2M the serializer touches; `assertNumQueries` test | Noticeable at dozens of records; a real problem at hundreds+ with concurrent public traffic |
| Unbounded `page_size` query param | One malformed/malicious request serializes the entire table | Always set `max_page_size` alongside `page_size_query_param` | Immediately exploitable, no scale threshold needed — this is a day-one risk on a public endpoint |
| Offset pagination duplicate/skip under concurrent writes | Occasional duplicate or missing card while scrolling during active corretor edits | Deterministic `ORDER BY` + dedupe-by-id on client append (Pitfall 8) | Increasingly visible as more corretores actively publish/edit while visitors browse |
| Client-side filter/sort of a fully-downloaded list | Fast and "scalable-looking" with a handful of test imóveis; degrades as acervo grows | Server-side filtering only (Pitfall 7) — structurally prevent by never holding a full unfiltered list in app memory | Breaks UX and data cost immediately past a trivial dataset size; explicitly called out as unacceptable in PROJECT.md regardless of scale |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Public `/imoveis`/`/cidades` reuse internal serializers/querysets | Leaks `proprietario`, `documento`, unpublished imóveis, or other-tenant data to any unauthenticated caller | Dedicated allow-list serializer + explicit `publicado=True` filter; automated leak-regression test (Pitfall 12) |
| No rate limiting / unbounded pagination on public endpoints | Trivial DoS or full-acervo scraping via `?page_size=` abuse | `max_page_size` cap; consider DRF throttling classes on public views even without auth |
| Relying on the multitenant scoping mixin's default behavior for a public view | Mixin assumes `request.user.empresa` exists; public/unauthenticated requests have no such user, so behavior is undefined/wrong, not merely "less strict" | Never inherit the standard `EmpresaScopedQuerySetMixin` unmodified into a public viewset — write scoping explicitly |
| Storing anything beyond the chosen city ID/name locally on-device | Low risk here (no login, no PII collected per PROJECT.md), but scope creep (e.g., caching full imóvel details with owner info) would create local data-at-rest exposure | Keep local persistence strictly to the city selection; never cache API responses containing fields that shouldn't exist in the public payload in the first place |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-------------------|
| Cold-start OS permission dialog with no context | User denies reflexively, gets stuck or confused about why the app "isn't working" | In-app rationale screen before the OS prompt, with an equally fast manual city-choice alternative |
| Silent auto-selection of a "closest match" city from geocoding | User ends up browsing the wrong city's vitrine without realizing it | Always show a confirm step ("Você está em X?") before locking in the detected city |
| Filter results showing a scary error message for a legitimate zero-match | User thinks the app broke and abandons instead of adjusting filters | Distinct, friendly empty-state ("nenhum imóvel encontrado" + clear filters CTA) separate from network-error state |
| List reshuffles/duplicates visibly when changing sort or filter mid-scroll | User loses trust in the list's correctness, may miss/double-see listings | Reset pagination state on any query-param change, never append across different queries |
| No visible affordance to change city after first choice | User stuck in wrong city with no obvious way out (PROJECT.md requires "trocar de cidade num toque no topo") | Persistent, always-visible city switcher in the vitrine header, not buried in a settings menu |

## "Looks Done But Isn't" Checklist

- [ ] **Location permission flow:** Often missing the `deniedForever` path (`openAppSettings()`) — verify by denying permission twice in a row on a real device/simulator and confirming there's still a usable path forward.
- [ ] **Reverse geocoding to city:** Often missing the "geocoded city isn't in our served list" case — verify by mocking a geocode result for an unserved region and confirming it routes to city-choice, not a crash or blank vitrine.
- [ ] **Infinite scroll pagination:** Often missing dedupe-by-id and pagination reset on filter/sort change — verify by rapidly switching sort options while mid-scroll and checking for duplicate/scrambled cards.
- [ ] **Server-side filters:** Often missing a real "does filtering actually change results" test — verify by applying a filter combo in the running app and confirming the API request URL contains the expected query params *and* the result count differs from unfiltered.
- [ ] **Public `/imoveis` endpoint:** Often missing exclusion of unpublished imóveis and internal fields — verify by creating an unpublished imóvel with `proprietario`/`documento` set and confirming neither the record nor those fields appear in the public JSON response.
- [ ] **Pagination page size limits:** Often missing `max_page_size` — verify by manually requesting `?page_size=99999` against the running API and confirming it's capped, not honored as-is.
- [ ] **City persistence across app updates:** Often missing reconciliation between hard-coded APP01 IDs and API-sourced APP02 IDs — verify by simulating an "upgrade" (persisted APP01 city value present, then switch to APP02's API-backed city source) and confirming the app either resolves correctly or gracefully re-prompts, never silently mis-shows a wrong city.
- [ ] **Theme contrast:** Often missing an actual contrast check beyond eyeballing — verify `onPrimary`/`primary`, `onSurface`/`surface`, and `onError`/`error` pairs against WCAG AA using a contrast checker on the real rendered hex values, not the seed color.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|----------------|------------------|
| City persisted by name, breaks on APP02 migration | LOW | Add a one-time reconciliation check on app start: if persisted city can't be matched in the new API-sourced list, clear it and route to city-choice; ship as a small patch, no data loss for the user beyond a re-pick |
| Client-side filtering shipped in APP02/APP03 | MEDIUM–HIGH | Requires reworking the repository layer to pass filter/sort/search params into the API call instead of applying them locally, plus removing any in-memory full-list caching; UI mostly unaffected if state management was already clean |
| Public endpoint leaking internal fields (already shipped) | HIGH | Immediate hotfix to serializer allow-list and querysite filter, treat as a security incident (rotate any exposed sensitive identifiers if `documento`/personal data was actually exposed), add the regression test retroactively, audit logs/analytics for evidence of scraping during the exposure window |
| Offset pagination duplicates under load | LOW | Add client-side dedupe-by-id on list append; no API changes required if ordering is already deterministic |
| Filter param mismatch discovered late (app sends params API ignores) | LOW–MEDIUM | Reconcile the contract doc, update whichever side is wrong (app query-building or DRF `FilterSet` field list), add the missing regression test so it can't silently regress again |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|-------------------|----------------|
| Permission requested with no context (P1) | APP01 | Manual test: fresh install, confirm in-app rationale screen appears before OS dialog |
| Denied treated as error, not a state (P2) | APP01 | Unit test each `PermissionStatus` value maps to a distinct, non-`Failure` UI state where appropriate |
| No timeout / no GPS handling (P3) | APP01 | Manual test with GPS disabled and with airplane mode; confirm bounded wait then fallback |
| Geocoded city not in served list (P4) | APP01 | Unit test: geocode result for an unserved city routes to city-choice, not crash/blank |
| Missing native permission strings (P5) | APP01 | PR checklist item: `Info.plist`/`AndroidManifest.xml` diffs present and reviewed before first location-permission code merges |
| City persisted by name not ID (P6) | APP01 (schema) / APP02 (migration) | Test: simulate APP01→APP02 upgrade path, confirm city resolves or gracefully re-prompts |
| Client-side filtering as a stopgap (P7) | APP02, APP03 | Code review gate: no `.where()`/`.sort()` on filter/search/sort-driven data in `domain`/`presentation`; verify network request carries the params |
| Offset pagination drift (P8) | APP02, API-IMOVEIS | Test: dedupe-by-id on append; API test: deterministic `ORDER BY` with tiebreaker |
| No reset on filter/sort change mid-scroll (P9) | APP02, APP03 | Manual test: change sort while mid-scroll, confirm list resets cleanly with no duplicates |
| App/API filter param mismatch (P10) | API-AUDIT → APP03, API-IMOVEIS | Contract doc exists and is referenced by both sides' code; DRF test asserts filtered result count differs from unfiltered |
| Empty vs error state confusion (P11) | APP02, APP03 | Manual test: filter combo guaranteed to return zero results renders the empty state, not the error state |
| Public endpoint leaking internal fields/tenants (P12) | API-IMOVEIS (blocking), API-AUDIT (flag) | Automated test: unpublished/other-tenant imóvel and `proprietario`/`documento` fields never appear in public response |
| N+1 / unbounded page size (P13) | API-IMOVEIS, API-CIDADES | `assertNumQueries` test; manual `?page_size=99999` request confirms capped response |
| Blocked waiting on teammate's model instead of contract-first (P14) | API-AUDIT → APP02, APP03 | Mock/fixture-backed APP02/APP03 builds and runs before the real Imóvel model lands; contract doc exists |
| `ColorScheme.fromSeed` contrast/brightness not verified (P15) | APP01 (theme setup) | Contrast check performed on `onPrimary`/`primary`, `onSurface`/`surface`, `onError`/`error` against real rendered values before APP02/APP03 UI review |

## Sources

- [Geolocation and geocoding in Flutter — LogRocket Blog](https://blog.logrocket.com/geolocation-geocoding-flutter/)
- [geolocator | Flutter package (pub.dev)](https://pub.dev/packages/geolocator)
- [Baseflow/flutter-geolocator — permission-related issues (GitHub)](https://github.com/Baseflow/flutter-geolocator/issues/1241)
- [Django REST Framework — Pagination (official docs)](https://www.django-rest-framework.org/api-guide/pagination/)
- [Django REST Framework — Generic views (official docs)](https://www.django-rest-framework.org/api-guide/generic-views/)
- [Django REST Framework — OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/cheatsheets/Django_REST_Framework_Cheat_Sheet.html)
- [encode/django-rest-framework — max_page_size / pagination issues (GitHub)](https://github.com/encode/django-rest-framework/issues/6185)
- Project-specific: `.planning/PROJECT.md` (multitenant priority, server-side-only business rules, city persistence, Material 3 palette constraints) and `../imoveis-aqui/CLAUDE.md` (multitenant isolation rule, public vitrine no-login rule) — both read in full for this research.
- General Clean Architecture / sealed-state (`Result`/`Either`) pattern knowledge, applied to the project's stated architecture constraints, informed by common Flutter/BLoC community practice (no single canonical source; cross-checked against multiple community guides during research).

---
*Pitfalls research for: Flutter city-vitrine app + Django/DRF public API (imovies-aqui-mobile)*
*Researched: 2026-09-21*
