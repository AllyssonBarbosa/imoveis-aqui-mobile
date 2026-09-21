# Phase 01 — API Coverage Decision (ai-integration checkpoint)

**Generated:** 2026-09-21
**Checkpoint:** Full API Coverage by Default — Opt Out, Never Opt In.

## Decision: No external API integration this phase

**No external API integration: Phase 01 uses a fixed local `assets/cidades.json` and produces the
API contract as a written document; live `/cidades` and `/imoveis` endpoints are Phase 2/4.**

### Reasoning

The checkpoint fires when a phase integrates an external API/SDK/service at runtime. Evaluated
against Phase 01's actual scope:

- **The app half does NOT call any external HTTP API at runtime.** The served-cities list is a
  fixed local asset (`assets/cidades.json`, D-13) read by `CidadeLocalDataSource`. Phase 2 swaps
  this for a remote `DataSource` via DI (VIT-06 / API-02) — that integration is Phase 2 work.
- **`dio` is declared in `pubspec.yaml` but not wired to any live endpoint.** It is present so the
  dependency graph and version resolution are settled early; no `BaseOptions.baseUrl`, no
  interceptor, no request is issued this phase. It hits no network.
- **`geolocator` / `geocoding` are on-device OS plugins, not external APIs.** They call native
  `CLGeocoder` (iOS) / Play Services `Geocoder` (Android) locally — no API key, no HTTP, no
  third-party service. GPS coordinates are transient and never leave the device (see threat models).
- **API-01 is a documentation deliverable, not an integration.** It freezes the written contract
  for `GET /cidades` and `GET /imoveis` (field names, enums, filter params, cursor pagination
  envelope) so Phase 2/4 can build against it. Writing a contract is not calling an endpoint.

Because no external API is integrated at runtime this phase, the reasoned no-integration
declaration above is recorded in lieu of a capability coverage matrix. When Phase 2 wires `dio` to
the real `GET /cidades`, the full INTEGRATE-by-default coverage matrix applies there.

## Specless-probe edge coverage — no silent drops

The deterministic edge probe returned all 7 requirement items `unclassified`/`unresolved` (it
cannot classify Portuguese prose). Per §A/§C of the specless-probe fallback, each was resolved by
authoring a defensible acceptance criterion into the owning plan's `must_haves.truths` (concrete
material came from CONTEXT.md's sealed location decisions and the UI-SPEC). None were silently
dropped.

| Probe item | Disposition | Where authored |
|---|---|---|
| LOC-01 | truth authored | 01-03 `must_haves.truths` |
| LOC-02 | truth authored | 01-03 `must_haves.truths` |
| LOC-03 | truth authored | 01-03 `must_haves.truths` |
| LOC-04 | truth authored | 01-01 `must_haves.truths` |
| LOC-05 | truth authored | 01-04 `must_haves.truths` |
| LOC-06 | truth authored | 01-03 `must_haves.truths` |
| API-01 | truth authored | 01-02 `must_haves.truths` |

No-silent-drop equality: 7 probe items == 7 authored truths + 0 flagged assumptions from the probe
set. (Separate research assumptions A1/A2 are surfaced as flagged assumptions inside their owning
plans; those are not part of the 7-item probe set.)

## UI-SPEC ## UI Considerations lift — no silent drops

19 applicable considerations (18 explicit resolved, 1 backstop, 1 dismissed):

- **18 explicit** → represented as truths in 01-01 (skeleton list rendering) and 01-03 (state
  variations, loading, error fallback, partial-row drop, overflow) `must_haves.truths`.
- **1 backstop** (E3 long-text city name wrap/ellipsize) → authored as a flat-scalar backstop
  marker in 01-03 `must_haves` (`{ statement: "...", verification: backstop }`).
- **1 dismissed** (E4 city switcher — navigation affordance with no own data state; Material 3
  default press/disabled states) → breadcrumb only, no truth required. Reason: it carries no data
  state of its own; its behavior (label + tap → open list, LOC-05) is covered by the 01-04
  switcher truths.
