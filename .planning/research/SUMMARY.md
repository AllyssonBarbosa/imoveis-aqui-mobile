# Project Research Summary

**Project:** Imóveis Aqui — App (Vitrine)
**Domain:** Flutter mobile "vitrine" (public, no-login city-based real-estate browse app) + the public Django/DRF endpoints it consumes
**Researched:** 2026-09-21
**Confidence:** HIGH (stack, architecture) / MEDIUM (features, general UX pattern research)

## Executive Summary

This is a two-sided delivery: a Flutter Clean-Architecture "screen over the data" (APP01–03) and the public Django/DRF endpoints that feed it (`GET /cidades`, `GET /imoveis`), where the app repo owns and builds both sides but the underlying `Imóvel` model itself is an external, teammate-owned dependency (E2, web frontline). Experts build this kind of thing as: Cubit-driven presentation over pure-Dart UseCases over a Repository/Either boundary over a thin Dio DataSource, with every filter/search/sort/pagination decision resolved server-side — the app never holds or manipulates a full in-memory listing, matching PROJECT.md's hardest constraint ("nada que valha dinheiro é decidido no app — só no Django").

The recommended approach is to decouple the three tasks from the cross-team blocker instead of serializing behind it. APP01 (permission → city entry, hard-coded city list with a stable id/slug scheme) has zero API dependency and ships first, fully standalone. API-CIDADES is small, has no blocker (`Cidade` already exists), and should land next, letting APP02 swap its city source from hard-coded to API-backed. The critical unlock, however, is an API-AUDIT step that freezes the `GET /imoveis` contract (field names, enum values, filter param names, pagination envelope) in writing *before* either APP02/APP03 or the real API-IMOVEIS endpoint is coded — APP02 and APP03 then build their entire UI/Cubit/pagination/filter-sheet stack against a mock/fixture DataSource that honors that frozen contract, running in parallel with the teammate's `Imóvel` model work. A short, well-bounded final step swaps the mocked DataSource for the real Dio call once the model lands — a one-line DI change if the contract was honored.

The dominant risks are not technical-stack risk (the Flutter/DRF ecosystem here is mature and well-documented) but contract and boundary risk: silently leaking internal/multi-tenant fields or unpublished listings on the one deliberately public, cross-tenant endpoint in an otherwise strictly tenant-isolated system; `django-filter`'s default behavior of silently dropping unrecognized query params (a filter mismatch returns a plausible-looking but wrong 200, not an error); the ever-present temptation to "temporarily" filter client-side while waiting on the teammate's model; and pagination/state bugs (duplicate cards, scrambled lists) when filter/sort changes aren't treated as a full reset of the pagination cursor. All four are structurally preventable by freezing the API contract early, writing dedicated public serializers with explicit allow-lists, and modeling pagination/location outcomes as explicit sealed states rather than boolean/exception shortcuts.

## Key Findings

### Recommended Stack

Core state/architecture packages (`flutter_bloc` Cubit, `freezed`, `json_serializable`) were already decided by the team; research filled in the surrounding stack. `dio` is recommended over `http` specifically because APP03's query-param-heavy filtering needs an interceptor chain, not per-call boilerplate. `get_it` + `injectable` wire the Clean Architecture layers without hand-maintained registration once APP02/APP03's dependency graph grows. `geolocator` (permission flow built in) + `geocoding` (reverse-geocode, no API key) cover APP01's location need with no extra `permission_handler` dependency. `shared_preferences` (new `SharedPreferencesAsync` API) persists only the chosen city id. `cached_network_image` handles property card cover photos. Testing stack: `bloc_test` + `mocktail` (zero extra codegen vs. `mockito`).

**Core technologies:**
- `dio` ^5.11.1 — HTTP client — interceptor chain needed for base URL, query-param filters, timeouts, error normalization
- `flutter_bloc` ^9.1.1 / `freezed` ^4.0.2 / `json_serializable` ^6.14.1 — already-decided Cubit + immutable-model stack, versions verified current
- `get_it` ^9.3.0 + `injectable` ^3.0.0 — DI wiring across `data/domain/presentation`, scales with APP02/APP03's growing dependency graph
- `geolocator` ^14.0.3 + `geocoding` ^5.0.0 — location permission flow + reverse-geocoding, no extra permission library needed
- `shared_preferences` ^2.5.5 (new async API), `cached_network_image` ^4.0.0, `bloc_test`/`mocktail` (dev) — persistence, image caching, Cubit testing

Full install commands and version-compatibility notes are in STACK.md. Explicitly avoid: `dartz` (unmaintained), `permission_handler` (redundant given `geolocator`), `equatable` (redundant given `freezed`), `mockito` (extra codegen), legacy `SharedPreferences.getInstance()`.

### Expected Features

**Must have (table stakes):**
- Location-permission ask with a non-dead-end denied path → city picker, never an error screen
- Persisted city choice + one-tap "change city" always visible at top of vitrine
- Property card: cover photo, title, price (final form, no animation), natureza, bairro, quartos — consistent formatting card-to-card
- Debounced (300–600ms) server-triggered text search — debounce the committed query, never the visible TextField
- Sort by preço/área/mais-recentes with a sane default ("mais recentes")
- Infinite scroll pagination with 4 distinct states per list: loading (skeleton), empty, error+retry, end-of-list
- Filter sheet (APP03 fields) with Apply/Clear-all, active-filter count badge + removable chips row (chips ship with the sheet, not deferred)
- Pull-to-refresh that resets both the list and the end-of-list flag

**Should have (competitive, do not let block table stakes):**
- Result-count preview on filter Apply ("Ver 842 imóveis") — contingent on API-AUDIT confirming a cheap count is feasible
- "Novo"/"preço reduzido" merchandising badges — needs a new API data signal, v1.x
- Smart empty-state recovery suggestions — v1.x, only after basic "limpar filtros" proves insufficient

**Defer (v2+, explicitly out of scope per PROJECT.md):**
- Client-side filtering/sorting — anti-feature, directly violates the project's core constraint
- Map/geo-radius search, favorites, property detail page, WhatsApp CTA, login/saved searches, custom pre-permission priming screen

### Architecture Approach

Feature-first, layer-inside-feature structure: `lib/features/localizacao/` (APP01, decoupled) and `lib/features/vitrine/` (APP02+APP03 combined, since search/sort/filter all mutate the same query params against the same paginated endpoint), both riding on a shared `lib/core/` (DI container, Dio client, Failure/UseCase base types, theme, local storage). The Either/Result boundary sits at the Repository layer only — DataSource throws, Repository catches and converts to `Either<Failure, T>`, UseCase and Cubit never see raw exceptions. One UseCase per business operation; "load more" reuses the same `BuscarImoveis` UseCase with an incremented page, not a separate UseCase — pagination state lives in the Cubit as a UI/rendering concern.

On the API side, the public `GET /imoveis`/`GET /cidades` views deliberately do NOT use the existing `EmpresaScopedQuerySetMixin` (it derives empresa from `request.user`, which doesn't exist for an unauthenticated public request) — instead they filter explicitly by `publicado=True` and expose a dedicated allow-list serializer, never `fields = "__all__"` or a reused internal serializer.

**Major components:**
1. `localizacao/` feature (APP01) — permission flow, geocoding, city persistence; independent lifecycle, no dependency on `vitrine/`
2. `vitrine/` feature (APP02+APP03) — one Cubit holding current filter + accumulated results + pagination cursor; DataSource swappable between mock fixture and real Dio call behind the same Repository interface
3. `core/` — DI (`get_it`/`injectable`), Dio client, Failure/UseCase base types, local storage wrapper
4. DRF public views (`ImovelPublicoListAPIView`, `CidadePublicaListAPIView`) — `AllowAny`, explicit `publicado=True` filter, dedicated allow-list serializers, `django-filter` FilterSet + `SearchFilter` + `OrderingFilter` + `PageNumberPagination`

### Critical Pitfalls

1. **Public `/imoveis` leaking internal fields or other-tenant/unpublished records** — highest severity given the project's multitenant-isolation priority; avoid by writing a dedicated `ImovelPublicoSerializer` (explicit allow-list, never inherited from the internal serializer) and an explicit `publicado=True` queryset filter with no `EmpresaScopedQuerySetMixin`; add an automated "does not leak" regression test.
2. **Silent filter-param mismatch between app and API** — `django-filter` drops unrecognized params instead of erroring, so a naming mismatch returns a plausible-but-wrong 200. Avoid by freezing a written query-param contract (names, types, enum values) before either side is coded, and adding a DRF test asserting a filtered result count differs from unfiltered.
3. **Client-side filtering "just for now" while waiting on the teammate's model** — directly violates the project's core rule and rarely gets un-shipped once live. Avoid by being contract-first: freeze the `GET /imoveis` JSON shape independent of the real Django model, build APP02/APP03 against a mock/fixture DataSource honoring that contract, then swap DataSources when the real model lands.
4. **Location/permission outcomes modeled as `Failure` instead of explicit states** — denied, deniedForever, no-GPS-timeout, and "geocoded city not in served list" must each be distinct sealed states routing to the city-choice fallback (with a confirm step before auto-selecting a geocoded city), never collapsed into a generic error screen.
5. **Pagination correctness bugs** — sort/filter/search changes must reset the pagination cursor and replace (not append to) the list; infinite-scroll appends must dedupe by id to tolerate offset-pagination drift under concurrent writes; the DRF default ordering must have a deterministic tiebreaker.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: APP01 — Location + City Entry
**Rationale:** Zero API dependency (hard-coded city list is explicitly acceptable for v1 per PROJECT.md); fastest path to a demoable, shippable slice; establishes `core/` (DI, theme, local storage) that every later phase reuses.
**Delivers:** Permission flow with explicit sealed states (granted/denied/deniedForever/timeout/unserved-city), reverse-geocode-to-city with confirm step, hard-coded city list with a stable id/slug scheme (designed to match the future API), persisted city choice, one-tap change-city affordance, Material 3 theme shell (`ColorScheme.fromSeed`, verified contrast).
**Addresses:** All APP01 table-stakes features from FEATURES.md.
**Avoids:** Pitfalls 1–6, 15 (permission UX, denied-as-error, no-timeout, unserved-city, missing native permission strings, city-persisted-by-name, theme contrast).

### Phase 2: API-AUDIT — Contract Freeze
**Rationale:** Must happen before APP02/APP03 or API-IMOVEIS is coded — this is the single highest-leverage step for avoiding the project's worst-case pitfalls (silent param mismatch, client-side-filtering temptation, public data leakage). Can run in parallel with Phase 1.
**Delivers:** A written, committed contract doc (query param names/types/enum values, response envelope, pagination class, excluded-fields allow-list) for `GET /cidades` and `GET /imoveis`, reconciled with the teammate building the `Imóvel` model where field names are still open (e.g., `caracteristicas` shape, `quartos`/`suítes`/`vagas` exact-vs-`__gte` semantics).
**Addresses:** Unblocks APP02/APP03 to build against a frozen mock; unblocks API-IMOVEIS to become a bounded "map model to contract" task later.
**Avoids:** Pitfall 10 (silent param drift), Pitfall 14 (blocked-waiting-on-teammate), sets up avoidance of Pitfall 12 (public leak) by design.

### Phase 3: API-CIDADES — Real Endpoint
**Rationale:** No blocker — `Cidade` model already exists; small (~30 min of Django work reusing the existing `CidadeSerializer`). Unblocks APP02's city-list-from-API requirement.
**Delivers:** `GET /api/publico/cidades/`, `AllowAny`, reusing/relocating the existing serializer.
**Uses:** DRF `generics.ListAPIView` pattern already established by `EmpresaPublicaAPIView`.
**Implements:** The `localizacao` API integration point named in ARCHITECTURE.md.

### Phase 4: APP02 — Vitrine List/Search/Sort (against mocked contract)
**Rationale:** Builds the entire `vitrine/` feature's data/domain/presentation stack against the Phase 2 contract via a fixture/mock DataSource, so it does not block on the teammate's `Imóvel` model landing; swaps to the real API-CIDADES endpoint from Phase 3 for the city list.
**Delivers:** Property card UI, debounced search, sort (segmented control, 3 options + default), infinite scroll with all 4 list states, pagination-reset-on-query-change logic, dedupe-by-id on append.
**Addresses:** APP02 table-stakes features from FEATURES.md.
**Avoids:** Pitfalls 7 (client-side filtering), 8 (offset drift), 9 (no reset on mid-scroll change), 11 (empty vs error state confusion).

### Phase 5: APP03 — Server-Side Filters (against mocked contract)
**Rationale:** Same mock-first approach as Phase 4, built on the same `vitrine/` feature and Cubit; naturally sequenced after APP02 since the filter sheet mutates the same query-param state the list Cubit already manages.
**Delivers:** Filter bottom sheet (finalidade, natureza, price/area ranges, quartos/suítes/vagas, bairro, características) with Apply/Clear-all, active-filter chips row with count badge.
**Addresses:** APP03 table-stakes features from FEATURES.md.
**Avoids:** Pitfall 9 (reset on filter apply), Pitfall 11 (empty-result vs error distinction for aggressive filter combos).

### Phase 6: API-IMOVEIS — Real Endpoint + Wire Real API
**Rationale:** Genuinely blocked until the teammate's `Imóvel` model exists — sequenced last by necessity, but kept short because the contract was frozen in Phase 2 and the UI was already built against it in Phases 4–5. This phase is "map the real model to the already-agreed contract," not "invent the contract under time pressure."
**Delivers:** Real `GET /api/publico/imoveis/` (dedicated allow-list serializer, explicit `publicado=True` filter, `select_related`/`prefetch_related` for N+1 avoidance, `max_page_size` cap, deterministic ordering with tiebreaker), plus the one-line DI swap in `injection_container.dart` from mock DataSource to real Dio-backed DataSource, plus end-to-end UAT with real data.
**Delivers:** Security regression test asserting no unpublished/other-tenant record or internal field (proprietário, documento) ever appears in the public response.
**Avoids:** Pitfall 12 (public data leak — critical, should block launch until verified), Pitfall 13 (N+1/unbounded page size).

### Phase Ordering Rationale

- APP01 first because it is the only piece with zero API dependency — ships and demos independently.
- API-AUDIT is deliberately placed before any APP02/APP03 code is written, not after — this is the single change that converts a would-be serialized bottleneck (waiting on the teammate's `Imóvel` model) into two parallel tracks (UI work vs. backend model work) and structurally prevents the client-side-filtering shortcut and the silent-param-mismatch failure mode.
- APP02 before APP03 because the filter sheet extends the same list/Cubit infrastructure APP02 establishes; building filters first would have nothing to filter.
- API-IMOVEIS (real) is last by hard external constraint (teammate's model), not by choice — the roadmap should treat "Imóvel model ready" as an explicit checkpoint/gate, with Phases 4–5 explicitly scoped to not require it.

### Research Flags

Phases likely needing deeper research during planning:
- **API-AUDIT:** needs direct coordination with the teammate on `Imóvel` field names/enum values (`caracteristicas` shape, `quartos`/`suítes`/`vagas` semantics) — not resolvable from documentation alone, flag for `--research-phase` or a live sync.
- **API-IMOVEIS (real):** N+1 query prevention and pagination-scale decisions depend on the teammate's actual model shape once it lands — revisit `select_related`/`prefetch_related` targets at that point.

Phases with standard patterns (skip research-phase):
- **APP01:** Flutter location/permission/geocoding patterns are well-documented and stable (HIGH confidence in PITFALLS.md/STACK.md).
- **APP02, APP03:** Clean Architecture + Cubit + paginated list patterns are a converged, well-documented community pattern; the mock-first approach removes the API-dependency risk that would otherwise justify deeper research here.
- **API-CIDADES:** Trivial, reuses an existing serializer and an established `AllowAny` public-view pattern already in the codebase.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All package versions verified directly against pub.dev listings/changelogs on the research date; compatibility ranges (e.g. injectable↔get_it) confirmed from published pubspec constraints, not assumed |
| Features | MEDIUM | General mobile/e-commerce/real-estate UX pattern research from community sources (NN/g, Mobbin, UXPin) cross-checked across multiple searches; no direct named-competitor teardown (QuintoAndar/Loft/ZAP/VivaReal) was performed |
| Architecture | HIGH (Flutter layer layout) / MEDIUM (specific package picks like fpdart) | Folder structure matches both PROJECT.md's mandated constraints and the de facto Flutter Clean Architecture community convention; API contract proposal is grounded in direct reads of the sibling API repo's actual code (`localizacao`, `core`, `empresas` apps) |
| Pitfalls | HIGH (Flutter/DRF technical patterns) / MEDIUM (project-specific coordination pitfalls) | Location/pagination/DRF pitfalls are well-documented, stable-ecosystem issues; pitfalls about teammate coordination (contract drift, blocked-waiting) are informed by PROJECT.md's own explicit framing but depend on behavior not yet observed |

**Overall confidence:** HIGH — the app-side technical decisions (stack, architecture, most pitfalls) are well-grounded; the primary residual uncertainty is the exact shape of the `Imóvel` model, which is explicitly out of this project's control and is why API-AUDIT is positioned as its own gating phase rather than folded into API-IMOVEIS.

### Gaps to Address

- **Exact `Imóvel` field names and enum values** (natureza, finalidade, características shape, quartos/suítes/vagas exact-vs-range semantics) — not resolvable from research alone; must be negotiated live with the teammate during API-AUDIT and locked into the contract doc before APP02/APP03 planning finalizes filter param names.
- **Whether unserved `Cidade` rows (no active empresa) should be filtered from `GET /cidades`** — flagged in ARCHITECTURE.md as a decision to confirm with the teammate/PM, not a blocker for v1, but should be resolved before API-CIDADES ships to avoid an empty-vitrine dead end.
- **Result-count preview feasibility** (differentiator feature) — depends on whether a cheap count/estimate can be added to `GET /imoveis` without a full query; explicitly deferred to v1.x pending API-AUDIT's assessment, not a gap that should delay v1 phases.
- **No direct competitor teardown performed** — FEATURES.md confidence would rise from MEDIUM to HIGH with a follow-up pass on 1–2 named Brazilian real-estate apps (QuintoAndar, Loft, ZAP, VivaReal); not blocking, but worth a lightweight spike if card anatomy or filter UX decisions feel uncertain during APP02/APP03 planning.

## Sources

### Primary (HIGH confidence)
- pub.dev package pages and changelogs (dio, freezed, json_serializable, flutter_bloc, shared_preferences, geolocator, geocoding, cached_network_image, get_it, injectable, injectable_generator, build_runner, bloc_test, mocktail, flutter_lints) — fetched directly, 2026-09-21
- Django REST Framework official docs — pagination, generic views (django-rest-framework.org)
- `.planning/PROJECT.md` (this repo) — mandated architecture constraints, scope, requirements
- `../imoveis-aqui/Web/{localizacao,core,empresas}/**` (models, permissions, settings, existing public views/serializers) — read directly, grounds the concrete API contract proposal
- `../imoveis-aqui/README.md`, `CLAUDE.md` — current API state, multitenant rule, public endpoint pattern

### Secondary (MEDIUM confidence)
- bloclibrary.dev "Flutter Infinite List" tutorial — official flutter_bloc maintainer docs, informs hand-rolled pagination pattern choice
- Community sources on Flutter Clean Architecture folder structure (Reso Coder-style TDD Clean Architecture, multiple converging dev.to guides)
- Community sources on `fpdart` vs `dartz` for Result/Either pattern
- Nielsen Norman Group, Mobbin, UXPin, Pencil & Paper, Osvira, Onething Design, The Finch Design, TrangoTech — mobile filter/search/empty-state/permission UX pattern research (FEATURES.md sources list)
- LogRocket, Baseflow GitHub issues — Flutter geolocation/geocoding pitfalls

### Tertiary (LOW confidence)
- General category-level real-estate app UX convergence (no single named-competitor citation) — flagged in FEATURES.md as needing a follow-up competitor teardown to raise confidence

---
*Research completed: 2026-09-21*
*Ready for roadmap: yes*
