# Feature Research

**Domain:** City-based real-estate browse ("vitrine") — Flutter mobile app, scoped to APP01 (city entry), APP02 (list/search/sort), APP03 (server-side filters)
**Researched:** 2026-09-21
**Confidence:** MEDIUM (general mobile/e-commerce UX pattern research from community and industry sources — Nielsen Norman Group, Mobbin, UXPin, Flutter package docs — cross-checked across multiple independent searches; no official Google/Apple HIG citation was pulled directly, and no direct competitor teardown of a Brazilian real-estate app was done)

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = the vitrine feels broken, not "minimal."

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Location-permission ask on first open, with a normal (non-dead-end) denied path | Users expect either "it just works" or a graceful manual choice — a permission denial that dead-ends the app (blank screen, forced retry loop) reads as broken | LOW–MEDIUM | Native OS dialog is not primeable in the "priming screen" sense for MVP — but the **denied branch must route to city picker**, never to an error screen or blocked state. iOS cannot re-trigger the native dialog after denial; don't try. |
| City picker fallback (searchable/scrollable list) | Standard fallback for any location-gated app; users without GPS/permission still need a way in | LOW | APP01: hard-coded list is acceptable to start. APP02 promotes this to API-backed (`GET /cidades`) — same UI, different data source. |
| Persisted city choice, reused on next launch | Nobody wants to re-grant permission or re-pick a city every session | LOW | Local device storage only (shared_preferences or similar) — explicitly no login, no backend user state (per PROJECT.md). |
| One-tap "change city" always visible at the top | Users relocate or want to browse a different market; burying this in a settings menu is a common annoyance in real-estate apps | LOW | Must be reachable from the vitrine itself, not nested — PROJECT.md's own spec already names this "um toque no topo." |
| Property card with cover photo, title, price, nature (casa/apto/terreno/lote), bairro, quartos | This is the scan-set buyers use to triage listings without opening each one; missing price or bairro on the card forces a tap-through just to filter mentally, which kills scan speed | MEDIUM | Price must render in final form immediately (no count-up animation), same currency formatting on every card. Bairro sits next to/under price — buyers search by neighborhood as much as by feature. Bed count format must be 100% consistent card-to-card. |
| Text search over the list | Even with filters, a search box is the fastest path when the user already knows what they want (an address fragment, a building name) | LOW–MEDIUM (server-side, so app-side complexity is mostly UX state, not query logic) | Server-side per PROJECT.md constraints — the app only debounces and sends the query string. |
| Debounced search with no jank while typing | Firing a network request per keystroke burns the visitor's mobile data and feels laggy; the industry-converged number is 300–600ms after typing stops | LOW | Debounce a separate "committed query" state, never the visible `TextField` value — the field itself must never lag behind keystrokes. |
| Explicit no-results state for search/filters | A results list that goes silently blank reads as a bug, not "zero matches" | LOW | Must name what was searched/filtered and offer one clear recovery action (clear search, ver todos, ajustar filtros) — never a bare "0 items" or blank screen. |
| Sort by price, area, most-recent | Explicitly named in APP02; also standard for any listings marketplace — users routinely want "cheapest first" or "newest first" | LOW–MEDIUM | 3 options fits a segmented control / single-select chip row far better than a full bottom sheet — small linear set, same dataset, needs one-tap reachability. |
| A sane default sort | Users should never land on an unsorted or ambiguously-sorted list | LOW | "Mais recentes" is the conventional default for a marketplace vitrine (freshest inventory first); confirm with the API/product owner, but do not ship with no default. |
| Infinite-scroll pagination | Explicitly named in APP02; long property lists without pagination either overload the device or force a fixed page-1-only view that's frustrating to browse | MEDIUM | Requires distinguishing first-page load (skeleton/center spinner) from next-page load (small inline spinner at list bottom) from end-of-list (no more spinner, optional "fim da lista" affordance). |
| Filter access with active-filter visibility | APP03's whole feature is filters; users must be able to tell at a glance that filters are active and what they are, or they'll distrust the results ("why is this list so short?") | MEDIUM | Filter-button badge showing count ("Filtros (3)") + removable chips row above the results list are the converged pattern — chips must NOT be hidden only inside the sheet. |
| Filter sheet with Apply / Clear-all | Standard mobile filter interaction; users expect to stage changes and commit them explicitly, and to reset everything in one action | MEDIUM | Apply and Clear-all buttons pinned to the sheet's bottom edge (thumb reach). Apply should ideally preview a result count before committing — depends on API supporting a "count" or fast preview call; flag as nice-to-have if the endpoint can't cheaply provide it. |
| Price range and area range as range inputs | Two of APP03's filter fields (faixa de preço, faixa de área) are explicitly ranges, not single values | MEDIUM | Dual-handle slider is the common pattern, but a min/max numeric input pair is a legitimate (and often more precise/accessible) alternative for price on mobile — either is fine; avoid forcing exact values only via slider drag. |
| Multi-select for natureza / bairro / características; single-select (or clear toggle) for finalidade | Natureza (casa/apto/terreno/lote) and características are naturally multi-value; finalidade (venda/aluguel) is naturally binary/single — treating them all the same way (e.g. forcing multi-select on finalidade) confuses intent | LOW–MEDIUM | Follows directly from the field semantics in APP03's own spec — not a new decision, just an implementation note. |
| Loading (skeleton), empty, error+retry, end-of-list states on every list screen | These four states are the baseline contract for any paginated network-backed list; skipping one (commonly "error+retry") is the most common way these screens "feel unfinished" | MEDIUM | Skeleton > spinner for first load (perceived speed). Error state needs a retry action, not just a message — first-page errors and next-page errors are different UI moments (center-screen vs. inline-at-bottom). |
| Pull-to-refresh resets list + end-of-list flag | Standard mobile list expectation once infinite scroll exists; forgetting to reset the "no more pages" flag on refresh is a common real bug, not just a UX nicety | LOW | Explicit test case to carry into requirements/QA, not just a UX preference. |

### Differentiators (Competitive Advantage)

Features that set the product apart within these 3 tasks. Not required, but valuable if budget allows — do not let these delay table stakes.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Result-count preview before applying filters (e.g. "Ver 842 imóveis") | Reduces the "apply into a dead end (0 results)" frustration that's a top complaint in mobile filter UX research | MEDIUM–HIGH | Needs either a cheap `count`-only API call or the full list call used opportunistically — depends on API-IMOVEIS design; flag for API-AUDIT to assess feasibility, don't block APP03 on it. |
| "New/reduced" or similar merchandising badge on the card | Common real-estate-app trend (Zillow/Loft/QuintoAndar-style "novo", "preço reduzido") that increases card engagement | LOW–MEDIUM | Needs a data signal from the API (published_at, price_changed_at) that doesn't currently exist in the model per PROJECT.md — treat as v1.x, not v1. |
| Smart empty-state suggestions ("try removing bairro filter", "search results near your term") | Converts a dead-end zero-results screen into a recovery path instead of a wall | MEDIUM | Requires either client-side heuristics (drop last-added filter) or API support for "did you mean" — simplest version (a "limpar filtros" button) is table stakes; the smart suggestion layer is the differentiator. |
| One-tap "remove this filter" directly from the active-filter chip | Slightly faster than reopening the sheet, editing, and reapplying | LOW | Natural extension of the chips-row pattern already in table stakes; cheap to add once chips exist. |

### Anti-Features (Commonly Requested, Often Problematic — Deliberately NOT Building for APP01–03)

| Feature | Why Requested | Why Problematic (here) | Alternative |
|---------|---------------|------------------------|-------------|
| Client-side filtering/sorting (download full acervo, filter on-device) | Feels "faster" for small lists, avoids extra API round-trips | Doesn't scale as inventory grows, burns the visitor's mobile data downloading unfiltered results, and directly violates the project's own non-negotiable constraint ("nada que valha dinheiro é decidido no app — só no Django") | All filter/sort/search logic stays server-side; the app only builds query params and renders what the API returns |
| Map view / geo-radius search | Very common real-estate app differentiator (Zillow-style map pins) | Explicitly out of scope for these 3 tasks; adds a whole new dependency (maps SDK, geo-indexed API, clustering UX) not budgeted here | Neighborhood (bairro) filter covers the "where" need for this milestone; map is a future card, not APP01–03 |
| Favorites / saved listings | Natural "while you're at it" ask when building a browse UI | Explicitly named as a separate future card in PROJECT.md's Out of Scope; requires local persistence design and touches the detail page (also out of scope) | Not built now — noted for a future milestone |
| Property detail page / tap-through | The card naturally makes users expect "tap for more" | Explicitly out of scope (card 8 in PROJECT.md); building it here would silently expand APP02's scope beyond "vitrine = list" | Cards render list-only for this milestone; detail page is a separate task |
| WhatsApp / contact CTA on the card or list | Common real-estate app pattern, high perceived business value | Explicitly out of scope (card 9); depends on the not-yet-built detail/contact flow | Deferred with the detail page |
| Login / saved searches / personalization | "Save my filters" or "notify me" feels like a natural filter-UX enhancement | Explicitly out of scope — PROJECT.md states the vitrine has no login by design ("sem login... qualquer pessoa navegue") | Filters and sort live in local UI state only, reset per session/screen, no account needed |
| Priming screen / custom pre-permission education UI before the OS location dialog | Common "best practice" advice (build a context screen before triggering the OS dialog) to increase grant rates | Adds a whole extra screen + copy + design cycle for a 3-task scope where the denied path already has to be a first-class, non-blocking flow — the marginal grant-rate lift doesn't justify the added screen for MVP | Trigger the native OS permission dialog directly on first open with a one-line rationale (Android already supports a rationale string; iOS shows `NSLocationWhenInUseUsageDescription`); invest in a custom primer screen only if data later shows low grant rates |
| Debouncing the visible search text field itself | Sometimes implemented naively "to reduce rebuilds" | Makes the input feel laggy — users must see every keystroke instantly; only the *API-triggering* state should be debounced | Debounce a derived/committed-query state, not the `TextEditingController`/field value |

## Feature Dependencies

```
APP01 (permission + city entry + hard-coded city list)
    └──precedes──> APP02 (vitrine: list/search/sort; city list now from API)
                       └──precedes──> APP03 (server-side filters on the vitrine)

API-CIDADES (GET /cidades)
    └──required by──> APP02's "city list now comes from the API" requirement
                       (APP01 can ship and be demoed with the hard-coded list first)

API-IMOVEIS (GET /imoveis?cidade=...&filtros&busca&ordenacao)
    └──required by──> APP02 (list, search, sort) AND APP03 (filters)
                       (this is the single most blocking dependency for both tasks)

API-IMOVEIS ──requires──> Model de Imóvel (frente web, E2 — explicitly Out of Scope /
                            external dependency per PROJECT.md)

City persistence (local device storage) ──enables──> "one-tap change city" and
                            "reused on next launch" (both are UI-only once storage exists)

Active-filter chips UI ──enhances──> Filter sheet (not a hard dependency, but should
                            ship together — a filter sheet without visible active state
                            is a materially worse experience)

Result-count preview (differentiator) ──requires──> API support for a cheap count/estimate
                            (blocked on API-AUDIT confirming feasibility)
```

### Dependency Notes

- **APP02 requires API-CIDADES only for the city-list-from-API upgrade** — the APP01 slice (hard-coded list) has zero API dependency and can be built/demoed independently first. This is the natural phase-ordering seam: ship APP01 against a static list, then swap the data source when API-CIDADES lands.
- **APP02 and APP03 both hard-depend on API-IMOVEIS** — search, sort, and filters are all query parameters on the same endpoint. There's no meaningful way to build APP02's list UI against real data without this endpoint existing (even a stub/mock is needed to unblock UI work before the real endpoint is ready).
- **API-IMOVEIS itself is blocked on the Model de Imóvel** being built by the web team (E2) — this is an external, cross-repo dependency called out explicitly in PROJECT.md as *not* under this project's control. Roadmap should treat "Imóvel model ready" as a hard gate/checkpoint before API-IMOVEIS can be finished, and plan for the app team to work against a documented contract/mock in the meantime.
- **Active-filter chips enhance, don't gate, the filter sheet** — a minimal APP03 could ship with just the sheet + Apply/Clear, but the research strongly favors shipping chips in the same phase since they're cheap (derived from the same filter state) and materially change perceived quality.
- **Result-count preview conflicts with a "ship early" mindset** if the API can't cheaply provide a count — don't let this differentiator block APP03's baseline Apply/Clear flow.

## MVP Definition

### Launch With (v1 — APP01, APP02, APP03 as specified)

- [ ] Location permission ask on open, resolves to city on grant — table stakes, is the entire premise of APP01
- [ ] Denied-permission → city picker (hard-coded list) — table stakes, must be a first-class path not an error state
- [ ] Persisted city choice + one-tap change-city at top — table stakes, named explicitly in APP01
- [ ] Property list with card (photo, title, price, natureza, bairro, quartos) — table stakes, is the entire premise of APP02
- [ ] Debounced text search with empty-query and no-results states — table stakes
- [ ] Sort by preço / área / mais recentes with a sane default — table stakes
- [ ] Infinite scroll with loading/empty/error+retry/end-of-list states on the list — table stakes
- [ ] City list swapped to API-backed source (API-CIDADES) — table stakes, explicit APP02 requirement
- [ ] Filter sheet (finalidade, natureza, preço, quartos, suítes, vagas, bairro, área, características) applied server-side — table stakes, is the entire premise of APP03
- [ ] Active-filter chips + Apply/Clear-all — table stakes-adjacent, ship in same phase as the sheet

### Add After Validation (v1.x)

- [ ] Result-count preview on the filter sheet's Apply button — trigger: API-AUDIT confirms a cheap count endpoint/param is feasible
- [ ] "Novo" / "preço reduzido" merchandising badges — trigger: API model gains a published_at/price_changed_at signal
- [ ] Smart empty-state recovery suggestions (auto-drop last filter, "did you mean") — trigger: basic "limpar filtros" empty state proves insufficient in real usage/feedback

### Future Consideration (v2+)

- [ ] Map / geo-radius search — defer until a dedicated map-feature milestone is scoped (out of these 3 tasks)
- [ ] Favorites / saved listings — defer to the future card explicitly named in PROJECT.md
- [ ] Property detail page, WhatsApp contact — defer to the future cards (8, 9) explicitly named in PROJECT.md
- [ ] Custom pre-permission priming screen — defer until real grant-rate data suggests the native-dialog-only flow underperforms

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Permission ask + denied→city-picker path | HIGH | LOW | P1 |
| Persisted city + change-city | HIGH | LOW | P1 |
| Property card anatomy | HIGH | MEDIUM | P1 |
| Debounced search + empty/no-results states | HIGH | LOW–MEDIUM | P1 |
| Sort (segmented, 3 options, default) | MEDIUM | LOW | P1 |
| Infinite scroll + all 4 list states | HIGH | MEDIUM | P1 |
| API-backed city list swap | MEDIUM | LOW (once API-CIDADES exists) | P1 |
| Filter sheet + server-side apply | HIGH | MEDIUM | P1 |
| Active-filter chips + Clear-all | HIGH | LOW–MEDIUM | P1 |
| Result-count preview on Apply | MEDIUM | MEDIUM–HIGH | P2 |
| Merchandising badges (novo/reduzido) | LOW–MEDIUM | LOW–MEDIUM | P2 |
| Smart empty-state suggestions | LOW–MEDIUM | MEDIUM | P3 |
| Map / geo search | HIGH (but out of scope) | HIGH | P3 (future milestone) |

**Priority key:**
- P1: Must have for launch (these 3 tasks)
- P2: Should have, add when possible (v1.x, contingent on API capability)
- P3: Nice to have, future consideration (explicitly out of scope per PROJECT.md)

## Competitor Feature Analysis

No direct competitor teardown (e.g. a specific QuintoAndar/Loft/Zillow screen-by-screen audit) was performed in this pass — general web search converged on common patterns across the real-estate and e-commerce mobile category rather than one named competitor. Treat the row below as category-level convergence, not a specific-app citation; a follow-up phase-specific research pass on 1–2 named Brazilian real-estate apps (QuintoAndar, Loft, ZAP Imóveis, VivaReal) would raise this from MEDIUM to HIGH confidence.

| Feature | Category Pattern (general real-estate/marketplace apps) | Our Approach |
|---------|-----------------------------------------------------------|--------------|
| Card layout | Photo → price (static, never animated) → title/location → bed/bath/area icon row, consistent format | Same pattern: capa, preço, título, natureza+bairro, quartos — server-supplied, app just renders |
| Filter access | Filter button with active-count badge; sheet or full-screen panel; chips above results | Bottom sheet with count badge + chips row above the list; Apply/Clear pinned at sheet bottom |
| Sort access | Segmented control or compact dropdown for 2-5 linear sort options | Segmented control / single-select row for preço, área, mais recentes |
| Permission-denied recovery | Manual location/city picker as universal fallback | City list (API-backed) as the denied-path fallback, per APP01 spec |

## Sources

- [Handling Permissions in Flutter (Location, Camera) Without Bad UX — Medium](https://medium.com/@imtiazaminsajid/handling-permissions-in-flutter-location-camera-without-bad-ux-54cb81c502fe)
- [Asking nicely: 3 strategies for successful mobile permission priming — Appcues](https://www.appcues.com/blog/mobile-permission-priming)
- [How to improve your permissions UX — Adam Lynch](https://adamlynch.com/improve-permissions-ux/)
- [Mobile UX Design: The Right Ways to Ask Users for Permissions — UX Planet](https://uxplanet.org/mobile-ux-design-the-right-ways-to-ask-users-for-permissions-6cdd9ab25c27)
- [Real Estate App UX 101: Designing for High-Stakes Decisions — Onething Design](https://www.onething.design/post/real-estate-app-ux)
- [Real Estate App UX: How to Design Property Search That Actually Converts Buyers — The Finch Design](https://thefinch.design/real-estate-app-ux-design-property-search-converts-buyers/)
- [UI/UX Best Practices to Drive Success for Real Estate Apps in 2025 — TrangoTech](https://trangotech.com/blog/ui-ux-for-real-estate-apps/)
- [Search UX Best Practices — Pencil & Paper](https://www.pencilandpaper.io/articles/search-ux)
- [Empty State UX Examples & Best Practices — Pencil & Paper](https://www.pencilandpaper.io/articles/empty-states)
- [Empty State UI Design — Mobbin](https://mobbin.com/glossary/empty-state)
- [In-app search UX that feels instant: debounce, cache, relevance — Koder.ai](https://koder.ai/blog/instant-in-app-search-ux)
- [Segmented Control UI: Best Practices + Real Examples — Eleken](https://www.eleken.co/blog-posts/segmented-control-ui)
- [Segmented Control UI Design — Mobbin](https://mobbin.com/glossary/segmented-control)
- [Bottom Sheets: Definition and UX Guidelines — Nielsen Norman Group](https://www.nngroup.com/articles/bottom-sheet/)
- [Bottom Sheet UI Design — Mobbin](https://mobbin.com/glossary/bottom-sheet)
- [Mobile Filter and Sort UX: A Practical Guide to Faster, Clearer Results — Osvira](https://osvira.com/mobile-filter-and-sort-ux-a-practical-guide-to-faster-clearer-results/)
- [Filter UI and UX Design: Best Practices, Patterns, and Examples — UXPin](https://www.uxpin.com/studio/blog/filter-ui-and-ux/)
- [Why Mobile Filter UX Is Broken — And 7 Fixes — Medium](https://medium.com/@kristina.krivitskaja/why-mobile-filter-ux-is-broken-and-7-fixes-every-designer-developer-should-use-19f760a05202)
- [Ecommerce Filter UX Design Patterns That Convert — BTNG.studio](https://www.btng.studio/articles/top-ecommerce-ux-filter-design-patterns-practical-tips-for-2025/)
- [infinite_scroll_pagination — pub.dev](https://pub.dev/packages/infinite_scroll_pagination)
- [How to implement infinite scroll pagination in Flutter — LogRocket](https://blog.logrocket.com/implement-infinite-scroll-pagination-flutter/)
- [Infinite scroll pagination with Riverpod and Flutter — ApparenceKit](https://apparencekit.dev/blog/flutter-pagination-riverpod/)

---
*Feature research for: City-based real-estate browse app (Flutter, APP01–APP03)*
*Researched: 2026-09-21*
