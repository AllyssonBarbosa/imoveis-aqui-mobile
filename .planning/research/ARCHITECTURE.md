# Architecture Research

**Domain:** Flutter Clean-Architecture mobile client + the Django REST Framework public API contract it consumes (real-estate marketplace vitrine, paginated/filterable listing)
**Researched:** 2026-09-21
**Confidence:** HIGH (Flutter layer layout: converged community pattern + matches PROJECT.md's mandated constraints) / MEDIUM (specific package picks: fpdart, PageNumberPagination — verified against docs + community sources, not project-pinned yet)

This document covers two connected systems: the app's internal structure (this repo, `imovies-aqui-mobile`), and the API contract it depends on (sibling repo `imoveis-aqui/Web`, Django 5.2 + DRF). Both are greenfield for the endpoints in question — `GET /cidades` and `GET /imoveis` do not exist yet.

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│  imovies-aqui-mobile (this repo) — Flutter app, "tela sobre os dados"│
├─────────────────────────────────────────────────────────────────────┤
│  presentation/  Widgets (Material 3) + Cubit (flutter_bloc)          │
│       │  emits VitrineState { Loading | Loaded<List<Imovel>> |       │
│       │                       LoadingMore | Failure(Exception) }     │
├───────┴────────────────────────────────────────────────────────────┤
│  domain/  UseCases (pure Dart, no Flutter/http import) +             │
│           abstract Repository interfaces + Entities                  │
├───────┬────────────────────────────────────────────────────────────┤
│  data/  Repository impl → DataSource (Dio) → Models (freezed,        │
│         fromJson/toJson) ←→ Either<Failure, T> boundary here          │
├───────┴────────────────────────────────────────────────────────────┤
│  core/  DioClient, get_it (injection_container.dart), Failure types, │
│         NetworkInfo, local storage (cidade escolhida)                │
└─────────────────────────────┬─────────────────────────────────────┘
                               │  HTTPS, no token, JSON
┌─────────────────────────────┴─────────────────────────────────────┐
│  imoveis-aqui/Web (sibling repo, Django 5.2 + DRF) — API owns rule  │
├───────────────────────────────────────────────────────────────────┤
│  urls_publico.py → generics.ListAPIView (AllowAny) → Serializer     │
├───────────────────────────────────────────────────────────────────┤
│  ViewSet/View filters queryset: publicado=True (+ EmpresaScoped      │
│  only applies to logged-in acervo views, NOT the public vitrine —   │
│  vitrine spans ALL active empresas in a city, by design)            │
├───────────────────────────────────────────────────────────────────┤
│  Models: Cidade (exists) · Empresa (exists) · Endereco (exists) ·   │
│  Imóvel (MISSING — teammate E2 dependency, blocks GET /imoveis)     │
└───────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|-------------------------|
| Widget (presentation) | Render state, dispatch user intent (scroll, filter tap, search input) | `StatelessWidget`/`StatefulWidget`, `BlocBuilder`/`BlocConsumer<VitrineCubit, VitrineState>` |
| Cubit (presentation) | Orchestrate UseCases, hold immutable UI state, debounce search, track pagination cursor | `flutter_bloc` `Cubit<VitrineState>`, calls one or more UseCases, never touches Dio/Repository directly |
| UseCase (domain) | One business operation, pure Dart, testable without Flutter | `class BuscarImoveis implements UseCase<PaginaImoveis, ParametrosBusca>` — calls `repository.buscarImoveis(params)` |
| Repository interface (domain) | Contract only — no implementation, no Dio import | `abstract class ImovelRepository { Future<Either<Failure, PaginaImoveis>> buscarImoveis(ParametrosBusca p); }` |
| Repository impl (data) | Fulfills the contract, converts exceptions → `Failure`, converts Models → Entities | `class ImovelRepositoryImpl implements ImovelRepository` — try/catch around DataSource call, maps `DioException` → `ServerFailure`/`ConexaoFailure` |
| DataSource (data) | Raw HTTP call, throws on non-2xx, returns raw Model (never Either — Either starts one level up) | `class ImovelRemoteDataSource { Future<PaginaImoveisModel> buscarImoveis(...) }` using `Dio` |
| Model (data) | JSON (de)serialization only, `freezed` + `json_serializable`, extends/maps to domain Entity | `@freezed class ImovelModel with _$ImovelModel { factory .fromJson(...) }` + `toEntity()` |
| Entity (domain) | Pure business object, no JSON annotations, what the UI actually renders | `class Imovel { final int id; final String titulo; ... }` |
| get_it container | Wires Cubit ← UseCase ← Repository ← DataSource ← Dio at app start | `injection_container.dart`, `sl.registerFactory(() => VitrineCubit(sl()))`, `sl.registerLazySingleton<ImovelRepository>(() => ImovelRepositoryImpl(sl()))` |
| DRF public View | Serve filtered/paginated/serialized `Imovel` queryset, no auth required | `generics.ListAPIView` with `permission_classes = [AllowAny]`, `filterset_class`, `pagination_class` |

## Recommended Project Structure

```
lib/
├── main.dart                          # runApp, injection_container init, MaterialApp(theme: ColorScheme.fromSeed)
├── core/
│   ├── di/
│   │   └── injection_container.dart   # get_it: sl.registerLazySingleton/registerFactory, one place, called from main()
│   ├── network/
│   │   ├── dio_client.dart            # Dio instance, baseUrl, interceptors (logging in debug), timeouts
│   │   └── network_info.dart          # abstract NetworkInfo (connectivity check) — optional but idiomatic
│   ├── error/
│   │   ├── failures.dart              # sealed class Failure { ServidorFailure, ConexaoFailure, InesperadaFailure }
│   │   └── exceptions.dart            # ServidorException, thrown by DataSource, caught by Repository impl
│   ├── usecase/
│   │   └── usecase.dart               # abstract class UseCase<Type, Params> { Future<Either<Failure,Type>> call(Params p); }
│   ├── theme/
│   │   └── app_theme.dart             # ColorScheme.fromSeed(seedColor: verde), ThemeData Material 3
│   └── local_storage/
│       └── cidade_local_storage.dart  # SharedPreferences wrapper — persists cidade escolhida (APP01)
│
├── features/
│   ├── localizacao/                   # APP01 — abrir app, permissão, escolher/trocar cidade
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── cidade_remote_datasource.dart   # GET /api/publico/cidades/
│   │   │   ├── models/
│   │   │   │   └── cidade_model.dart               # freezed, fromJson({id, nome, uf})
│   │   │   └── repositories/
│   │   │       └── cidade_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── cidade.dart
│   │   │   ├── repositories/
│   │   │   │   └── cidade_repository.dart          # abstract
│   │   │   └── usecases/
│   │   │       ├── listar_cidades.dart
│   │   │       └── obter_cidade_por_geolocalizacao.dart  # local device geocoding, not an API call
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── localizacao_cubit.dart
│   │       │   └── localizacao_state.dart          # freezed sealed states
│   │       ├── pages/
│   │       │   └── selecionar_cidade_page.dart
│   │       └── widgets/
│   │           └── cidade_list_tile.dart
│   │
│   └── vitrine/                       # APP02 + APP03 — lista paginada, busca, ordenação, filtros
│       ├── data/
│       │   ├── datasources/
│       │   │   └── imovel_remote_datasource.dart   # GET /api/publico/imoveis/?...
│       │   ├── models/
│       │   │   ├── imovel_model.dart               # card-level fields only
│       │   │   └── pagina_imoveis_model.dart        # {count, next, previous, results}
│       │   └── repositories/
│       │       └── imovel_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── imovel.dart
│       │   │   ├── pagina_imoveis.dart
│       │   │   └── filtro_vitrine.dart              # value object: finalidade, natureza, precoMin..., ordering
│       │   ├── repositories/
│       │   │   └── imovel_repository.dart
│       │   └── usecases/
│       │       └── buscar_imoveis.dart               # single UseCase, ParametrosBusca carries page+filtro+query+ordering
│       └── presentation/
│           ├── cubit/
│           │   ├── vitrine_cubit.dart                # holds current FiltroVitrine + page cursor, appends results
│           │   └── vitrine_state.dart                # freezed: Carregando | Carregado(itens, temMais) | CarregandoMais | Erro
│           ├── pages/
│           │   └── vitrine_page.dart                 # ListView.builder + ScrollController listener → loadMore()
│           └── widgets/
│               ├── imovel_card.dart
│               ├── busca_bar.dart
│               ├── ordenacao_dropdown.dart
│               └── filtros_bottom_sheet.dart          # APP03
│
└── shared/                            # cross-feature only if truly reused (e.g. shimmer loading, empty state)
    └── widgets/
        └── empty_state.dart
```

### Structure Rationale

- **`lib/core/`:** Everything that has no business meaning but every feature needs — DI wiring, the Dio instance, the `Failure`/`UseCase` base types, theme, local storage. Kept feature-agnostic on purpose so `localizacao` and `vitrine` never import each other's internals, only `core/`.
- **`lib/features/<feature>/{data,domain,presentation}`:** Feature-first at the top level, layer-first inside each feature. This is the layout the vast majority of Flutter Clean Architecture references converge on (Reso Coder's TDD Clean Architecture course pattern, still the de facto reference nearly everyone cites) — it scales better than a single top-level `data/domain/presentation` once the app grows past two features (APP01 and APP02/03 already justify the split; later phases — detalhe do imóvel, favoritos, área logada — become new feature folders, not new top-level layers). PROJECT.md's constraint "camadas data/ domain/ presentation/" is satisfied per-feature, which is the standard reading of that constraint in Flutter — a single global `data/domain/presentation` at repo root becomes unmanageable once there is more than one screen family.
- **`vitrine/` bundles APP02 (list) and APP03 (filters) in one feature**, not two: a filter change and a search change both mutate the same `ParametrosBusca` and re-trigger the same `buscar_imoveis` UseCase against the same paginated endpoint. Splitting them into separate features would force the filter UI to reach into the list feature's Cubit anyway — better to keep the vertical slice whole and split only the widgets (`filtros_bottom_sheet.dart` vs `imovel_card.dart`).
- **`localizacao/` is separate** because it owns a genuinely different concern (device permission, device geolocation, local persistence of the chosen city) and a different lifecycle (asked once at launch, revisited only via the "trocar cidade" affordance) — it should not be a dependency direction into `vitrine/`; instead `vitrine/` reads the already-chosen `Cidade` id from `core/local_storage` or receives it as a UseCase parameter, keeping the two features decoupled.

## Architectural Patterns

### Pattern 1: Result/Either boundary sits at the Repository, not the DataSource or the Cubit

**What:** The DataSource throws (`ServidorException`, `DioException` bubbles up); the Repository implementation is the *only* place with a `try/catch`, and it is the place that converts exceptions into `Either<Failure, T>`. The UseCase and Cubit never see a raw exception — they only ever see `Either<Failure, T>` or, after the UseCase unwraps it via `fold`, a typed state.

**When to use:** Always, for every network-backed UseCase in this app — this is exactly what PROJECT.md mandates ("padrão Result/Either... sem try/catch genérico na UI").

**Trade-offs:** Slightly more boilerplate per Repository method (one `try/catch` block) than letting exceptions propagate to a global error handler, but it is what makes "no generic try/catch in the UI" true, and it makes every failure mode explicit and testable without mocking the network.

**Example:**
```dart
// data/repositories/imovel_repository_impl.dart
class ImovelRepositoryImpl implements ImovelRepository {
  ImovelRepositoryImpl(this._remote);
  final ImovelRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaginaImoveis>> buscarImoveis(ParametrosBusca p) async {
    try {
      final model = await _remote.buscarImoveis(p);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(e.response != null ? ServidorFailure(e.response!.statusCode!) : ConexaoFailure());
    } on Exception {
      return Left(InesperadaFailure());
    }
  }
}

// presentation/cubit/vitrine_cubit.dart
Future<void> carregar(FiltroVitrine filtro) async {
  emit(const VitrineState.carregando());
  final resultado = await _buscarImoveis(ParametrosBusca(filtro: filtro, pagina: 1));
  resultado.fold(
    (falha) => emit(VitrineState.erro(falha)),
    (pagina) => emit(VitrineState.carregado(itens: pagina.resultados, temMais: pagina.proxima != null)),
  );
}
```

### Pattern 2: One UseCase per business operation, Cubit composes them, never talks to Repository directly

**What:** `BuscarImoveis` (page 1 / new filter) and "load more" reuse the *same* UseCase with an incremented `pagina` — there is no separate `CarregarMaisImoveis` UseCase, because "load more" is not a distinct business operation, it's the same query with a different page. The Cubit is responsible for tracking `paginaAtual` and appending `resultados` to the existing list rather than replacing it, and for deciding when to call `carregar` vs `carregarMais` based on scroll position.

**When to use:** Any paginated list backed by one query endpoint with a stable filter shape (exactly this vitrine).

**Trade-offs:** Keeps UseCase count low and each one meaningful; the cost is that pagination *state* (current page, whether more exist) lives in the Cubit rather than being an explicit domain concept — acceptable here because pagination is a UI/rendering concern, not a business rule (no regra de negócio is being decided by tracking "which page am I on").

### Pattern 3: freezed sealed states for the Cubit, freezed unions for API models

**What:** `VitrineState` is a `@freezed` sealed class with named constructors (`.inicial()`, `.carregando()`, `.carregado(itens, temMais)`, `.carregandoMais(itens)`, `.erro(Failure)`) so `BlocBuilder` can exhaustively switch without `is` checks. API response Models (`ImovelModel`, `PaginaImoveisModel`) are also `@freezed` + `json_serializable`, immutable, with a `toEntity()` mapper method that strips out any field the domain layer doesn't need (keeps the domain Entity independent of API JSON shape, so a future API field rename doesn't ripple into the UI).

**When to use:** Every screen state and every API-facing model in this app — this is a direct implementation of PROJECT.md's "todo JSON mapeado para Models imutáveis (freezed)" and "estados imutáveis nos estados de tela" constraints.

**Trade-offs:** freezed requires `build_runner` codegen (`dart run build_runner watch`), a minor DX cost during active development, in exchange for compile-time exhaustiveness checks and equality/copyWith for free.

## Data Flow

### Request Flow — filtered, paginated vitrine list

```
User scrolls near bottom of ListView / taps a filter chip / types in search
    ↓
VitrinePage (Widget) → context.read<VitrineCubit>().carregarMais() / aplicarFiltro(novoFiltro)
    ↓
VitrineCubit builds ParametrosBusca { cidadeId, q, filtro: FiltroVitrine, ordering, pagina }
    ↓
BuscarImoveis (UseCase) .call(ParametrosBusca) → ImovelRepository.buscarImoveis(params)
    ↓
ImovelRepositoryImpl → ImovelRemoteDataSource.buscarImoveis(params)
    ↓
Dio GET /api/publico/imoveis/?cidade=3&finalidade=venda&quartos=2&ordering=-criado_em&page=2
    ↓                                                                    ↓ (Django side)
DRF ListAPIView → filterset (django-filter) narrows queryset → OrderingFilter → PageNumberPagination.paginate_queryset
    ↓
Serializer (card-level fields only) → JSON { count, next, previous, results: [...] }
    ↓
PaginaImoveisModel.fromJson (freezed) ← DataSource returns Model
    ↓
Repository: model.toEntity() → Right(PaginaImoveis) ← Either boundary
    ↓
UseCase returns Either<Failure, PaginaImoveis> unchanged to Cubit
    ↓
Cubit.fold: Left → emit(VitrineState.erro(falha))
            Right → emit(VitrineState.carregado(itens: [...anteriores, ...novos], temMais: pagina.proxima != null))
    ↓
BlocBuilder<VitrineCubit, VitrineState> rebuilds ListView with appended items
```

### State Management

```
VitrineCubit (holds: FiltroVitrine atual, List<Imovel> acumulados, int paginaAtual, bool temMais, bool carregandoMais)
    ↓ emit
VitrineState (sealed, freezed)
    ↓ (subscribe via BlocBuilder/BlocConsumer)
VitrinePage, ImovelCard list, FiltrosBottomSheet (reads current FiltroVitrine to pre-fill controls)
    ↓ (user action)
context.read<VitrineCubit>().aplicarFiltro(...) / buscarPorTexto(...) / carregarMais()
    → re-enters the Request Flow above, always through the same UseCase
```

### Key Data Flows

1. **App launch → cidade resolution (APP01):** `LocalizacaoCubit` checks `core/local_storage` for a previously chosen `cidadeId`; if present, skip straight to `vitrine/` with that id. If absent, request location permission; on grant, reverse-geocode locally (device-side, no API call) and match against the `GET /cidades` list already fetched; on denial or no match, show the city list fetched from `GET /cidades` for manual pick. Either path ends by persisting the choice locally and handing `cidadeId` to `vitrine/`.
2. **Filter/search/sort change → full reset, not append:** Any change to `FiltroVitrine`, the search text, or `ordering` resets `paginaAtual = 1` and replaces (not appends) the accumulated list, because the underlying DRF queryset itself changed — appending page-2-of-a-different-query results onto page-1-of-the-old-query would silently corrupt the list. This is a Cubit responsibility, not a UseCase one.
3. **Infinite scroll → append-only, same queryset:** Scroll-triggered `carregarMais()` keeps every other `ParametrosBusca` field fixed and only increments `pagina`, appending `results` to the existing accumulated list. Guarded by `temMais` (derived from DRF's `next` being non-null) and a `carregandoMais` flag to avoid duplicate in-flight requests from rapid scroll events.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| MVP — single city launch, hundreds of imóveis | Exactly the structure above. `PageNumberPagination`, no caching layer beyond Dio defaults, no local DB. |
| Multiple cities, low thousands of imóveis per city | Same structure holds. Consider adding a thin in-memory LRU in the Cubit (already-fetched pages) so switching filters back and forth doesn't always refetch — optional, not required for correctness. |
| Tens of thousands of imóveis nationally, public API under real traffic | Revisit DRF pagination: move from `PageNumberPagination` (OFFSET/LIMIT, degrades on deep pages) to `CursorPagination` (stable, O(1) regardless of depth) — but this requires committing to a single consistent ordering scheme per cursor and is a backend-only change; the Flutter `PaginaImoveis` entity already models `proxima`/`anterior` as opaque strings, not raw page numbers, so this migration would not require Flutter contract changes if designed that way now (see API Contract note below). |

### Scaling Priorities

1. **First bottleneck (backend):** An unindexed `Imóvel` queryset filtered by `cidade` + several optional filters (`bairro`, price range, `quartos`, etc.) without database indexes on the FK/queried columns. Fix: index `cidade_id`, `finalidade`, `natureza`, `preco`, `bairro` on the `Imóvel` table as soon as it's created (teammate's model, flag this to them).
2. **Second bottleneck (backend):** `N+1` queries from the serializer resolving `cover photo` per imóvel from a related `Foto` table. Fix: `select_related`/`prefetch_related` in the ViewSet's `get_queryset`, or denormalize a `foto_capa_url` field on `Imóvel` if fotos are a separate model — this decision belongs to the teammate building E2, but the app's serializer contract (a flat `foto_capa` URL string) should be designed now so it doesn't force a breaking API change later.

## Anti-Patterns

### Anti-Pattern 1: Cubit calling Repository or DataSource directly, skipping the UseCase

**What people do:** `VitrineCubit(this._imovelRepository)` and call `_imovelRepository.buscarImoveis(...)` straight from the Cubit, skipping the UseCase layer "because it's just a pass-through for now."
**Why it's wrong:** It collapses the domain/presentation boundary — the Cubit becomes coupled to the Repository's exact method signature, and there is no longer a single, independently-testable unit representing "the business operation of searching imóveis." It also makes it easy to accidentally decide business logic (like which fields go in `ParametrosBusca`, or clamping a price range) inside the Cubit instead of the domain layer, which violates PROJECT.md's "nenhuma regra de negócio... decidida no app."
**Do this instead:** Always route through a `UseCase<Type, Params>` even when it looks like a thin pass-through today — the layer boundary is the point, not the amount of logic inside it.

### Anti-Pattern 2: Filtering, sorting, or "de-duplicating" the imóvel list client-side after fetching a page

**What people do:** Fetch a page of results and then apply an extra `where(imovel.preco <= filtroLocal)` in Dart, or re-sort the already-server-sorted list "just to be safe," or hide items client-side based on some heuristic.
**Why it's wrong:** Directly violates PROJECT.md's hardest constraint — "nada que valha dinheiro ou mude estado é decidido no app," and specifically "filtrar no celular... não escala." Server-side filtering exists precisely so the phone never downloads more than it shows. Any client-side filtering on top of a server-filtered page is redundant at best and silently wrong at worst (a page can look "empty after filtering" when the server already applied that filter, confusing the "load more" logic).
**Do this instead:** Every filter, sort, and search parameter that affects which imóveis appear is a query param sent to `GET /imoveis`, full stop. The only thing the app is allowed to do to received data is *render* it and paginate the *display* of an already-correct list.

### Anti-Pattern 3 (API side): Reusing `EmpresaScopedQuerySetMixin` on the public vitrine endpoint

**What people do:** Since `Imóvel` will inherit `EmpresaOwnedModel`, it's tempting to reuse the same `EmpresaScopedQuerySetMixin` used by authenticated acervo endpoints on the public `GET /imoveis` view too, "for consistency."
**Why it's wrong:** `EmpresaScopedQuerySetMixin` filters the queryset by `request.user.empresa_id` — but the public vitrine has no authenticated user at all (`AllowAny`, no token) and, by design, must show imóveis from *every active empresa* operating in the chosen city, not one empresa's own acervo. Applying that mixin to a public, unauthenticated request either raises on the missing `request.user.empresa_id` or (worse) silently returns an empty/wrong queryset.
**Do this instead:** The public `ImovelPublicoViewSet`/`ListAPIView` filters explicitly and only by `publicado=True` (and by `cidade`, `finalidade`, etc. from query params) — it does not use `EmpresaScopedQuerySetMixin` at all, because multitenant scoping is a *painel/authenticated* concern, and the *public* isolation concern is different: never leak `proprietário`, `documento`, or any field that isn't meant for public eyes, via the serializer's explicit `fields` allowlist (never `fields = "__all__"` on a public serializer).

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Django DRF public API (`imoveis-aqui/Web`) | REST/JSON over HTTPS, `Dio`, no auth header on public vitrine endpoints | Base URL configured per build flavor (dev points at local `runserver`, prod at deployed API); `AllowAny` + `TokenAuthentication` for future logged-in features co-exist because `DEFAULT_PERMISSION_CLASSES` is `IsAuthenticated` globally — public views must explicitly set `permission_classes = [AllowAny]` per-view, exactly like the existing `EmpresaPublicaAPIView` already does. |
| Device geolocation (`geolocator` or `location` package) | Native platform permission + GPS, local only, no network call | Used only in `localizacao/` to *suggest* a city by reverse-geocoding coordinates against the already-fetched `GET /cidades` list — never sent to the API; APP01 explicitly allows the flow to fall back to manual city pick. |
| Local persistence (`shared_preferences`) | Key-value, device-local | Stores only the chosen `cidadeId`/`cidadeNome` — no other client-side state persists per PROJECT.md ("O app persiste só a cidade escolhida localmente"). |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `localizacao/` feature ↔ `vitrine/` feature | Indirect, via `core/local_storage` (read cidadeId) + navigation argument on first entry | No direct import of one feature's Cubit/UseCase by the other — keeps them independently testable and lets a future "trocar cidade" affordance in the vitrine app bar just re-run the `localizacao` flow without a circular dependency. |
| `presentation/` ↔ `domain/` | Cubit calls UseCase (constructor-injected via get_it) | Cubit never imports anything from `data/` — enforced by folder discipline, not the compiler, so this is a code-review rule, not just an architecture diagram. |
| `domain/` ↔ `data/` | `data/repositories/*_impl.dart` implements the interface declared in `domain/repositories/*.dart` | `domain/` has zero imports of `data/` or Flutter/Dio packages — it is pure Dart, which is what makes UseCases trivially unit-testable with a mocked Repository. |
| Flutter app ↔ Django API | HTTP/JSON, versionless URL for now (`/api/publico/...`), contract defined below | This is the boundary both teams (app + web) must keep in sync — see API Contract section. Any field rename on the Django serializer is a breaking change to `ImovelModel.fromJson` and must be coordinated, not silently pushed. |

---

## Proposed API Contract

This is the concrete shape for `API-CIDADES` and `API-IMOVEIS` (PROJECT.md requirements), designed to slot into the existing DRF conventions already established in `imoveis-aqui/Web` (same `generics.*APIView` + `AllowAny` + `urls_publico.py` pattern as `EmpresaPublicaAPIView`).

### `GET /api/publico/cidades/`

**Purpose:** Populate APP01's city list (both for manual pick and for matching against device geolocation) and, later, city filter dropdowns on the web vitrine.

**Auth:** None (`AllowAny`), no token required — matches the two existing `/api/publico/*` endpoints.

**Query params:** None needed for v1 — the `Cidade` table is small ("mantida pelo administrador") and doesn't need pagination or filtering yet. If it grows, add `?uf=` later; do not add pagination to this endpoint now, it would only complicate the Flutter city picker for no real benefit at this scale.

**Response (200):**
```json
[
  { "id": 3, "nome": "Cuiabá", "uf": "MT" },
  { "id": 7, "nome": "Várzea Grande", "uf": "MT" },
  { "id": 12, "nome": "Rondonópolis", "uf": "MT" }
]
```

**Implementation note:** `CidadeSerializer` already exists verbatim in `empresas/api/serializers.py` (`fields = ["id", "nome", "uf"]`) — reuse it, don't duplicate it. Consider whether it belongs in `localizacao/api/serializers.py` instead (it's `localizacao`'s model) and have `empresas` import from there, since `localizacao` is the natural owner of `Cidade`. The view is a one-liner:

```python
# localizacao/api/views.py
class CidadePublicaListAPIView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = CidadeSerializer
    queryset = Cidade.objects.all()
```
```python
# localizacao/api/urls_publico.py
urlpatterns = [ path("cidades/", CidadePublicaListAPIView.as_view(), name="publico-cidades") ]
```
```python
# config/urls.py — add one line
path("api/publico/", include("localizacao.api.urls_publico")),
```

**Optionally: only expose cidades with active empresas.** If a `Cidade` exists in the general table but no `Empresa` currently operates there (`cidades_atuacao`), showing it in the vitrine picker leads to an empty screen. Recommend filtering to `Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()` once `Empresa.cidades_atuacao` is populated with real data — flag this as a decision to confirm with the teammate owning `empresas`, not a blocker for v1.

### `GET /api/publico/imoveis/`

**Purpose:** APP02 (list, search, sort, infinite scroll) and APP03 (filters), server-side only.

**Auth:** None (`AllowAny`), no token — same pattern as the other two public endpoints. **Hard-blocked** on the `Imóvel` model existing (teammate E2 work, see Build Order below).

**Query params:**

| Param | Type | Required | Notes |
|-------|------|----------|-------|
| `cidade` | int (Cidade id) | Yes, for a useful vitrine | Filters to imóveis in that city. Without it, a "todas as cidades" mode is possible but not in APP01–03's scope — recommend requiring it. |
| `q` | string | No | Free-text search, matched against `titulo` and `bairro` (and `endereco.logradouro` if useful) via DRF `SearchFilter` (`search_fields`). |
| `finalidade` | string enum: `venda` \| `aluguel` | No | Exact match. |
| `natureza` | string enum: `casa` \| `apartamento` \| `terreno` \| `lote` | No | Exact match. |
| `preco_min` / `preco_max` | decimal | No | `preco__gte` / `preco__lte`. |
| `quartos` | int | No | Exact or `__gte` — recommend `__gte` ("2 quartos" usually means "2 or more" in real-estate search UX); confirm with web team since site filter should match. |
| `suites` | int | No | Same `__gte` treatment as `quartos`. |
| `vagas` | int | No | Same `__gte` treatment. |
| `bairro` | string | No | Exact or `icontains` — recommend `icontains` for forgiving free-typed neighborhood names, unless the web team standardizes on a bairro dropdown/autocomplete, in which case exact match is fine and preferable (avoids partial-match surprises). |
| `area_min` / `area_max` | decimal | No | `area__gte` / `area__lte`. |
| `caracteristicas` | comma-separated slugs or repeated param | No | Depends entirely on how the teammate models "características" (likely a M2M to a `Caracteristica` table once designed in E2) — placeholder param, confirm exact shape once that model lands; do not block APP03 on getting this exactly right today. |
| `ordering` | string | No, default `-criado_em` | DRF `OrderingFilter` convention: `preco`, `-preco`, `area`, `-area`, `criado_em`, `-criado_em` (matches APP02's "preço, área ou mais recentes", `-` prefix = descending). |
| `page` | int | No, default 1 | See pagination decision below. |

**Pagination — recommend `PageNumberPagination`, not `CursorPagination`, for v1:**

DRF's own docs (official, HIGH confidence) describe `PageNumberPagination` as `{count, next, previous, results}` — simple, gives a total count useful for UI copy ("128 imóveis encontrados"), and works with `?page=N`. `CursorPagination` is more scalable for very large/real-time-changing datasets, but its opaque cursor is tied to a *single* ordering — every time the user changes `ordering` (a first-class APP02 requirement: preço/área/mais recentes) or any filter, the cursor must be discarded and restarted from the beginning anyway, so its main advantage (stable mid-scroll cursor) doesn't help this specific UX as much as it would for a single-order infinite feed. Given the dataset size (a city's imóveis — realistically hundreds to low thousands, not millions) `PageNumberPagination`'s OFFSET/LIMIT cost is not a real concern at this scale. **Design the Flutter side to treat `next`/`previous` as opaque URLs, not to hand-construct `?page=N` itself** — this keeps the door open to switching the backend to `CursorPagination` later without a Flutter-side contract change, since the app would just follow whatever URL `next` contains either way.

```python
# config/settings.py — add
REST_FRAMEWORK = {
    ...,
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}
```

**Response (200) — envelope + per-item card fields:**
```json
{
  "count": 87,
  "next": "http://api.imoveisaqui.com.br/api/publico/imoveis/?cidade=3&page=3",
  "previous": "http://api.imoveisaqui.com.br/api/publico/imoveis/?cidade=3&page=1",
  "results": [
    {
      "id": 154,
      "titulo": "Casa 3 quartos no Jardim das Américas",
      "preco": "450000.00",
      "finalidade": "venda",
      "natureza": "casa",
      "bairro": "Jardim das Américas",
      "quartos": 3,
      "suites": 1,
      "vagas": 2,
      "area": "180.00",
      "foto_capa": "http://api.imoveisaqui.com.br/media/imoveis/154/capa.jpg"
    }
  ]
}
```

**Explicitly excluded from this serializer** (public safety — never in the public payload, regardless of what's on the `Imóvel` model): `proprietario` (any FK/name/contact of the owner), `documento`/`matricula`, `empresa` internal id or any field identifying *which* empresa/corretor owns it beyond what's needed for a future "ver detalhes"/WhatsApp contact flow (out of scope for APP01–03 per PROJECT.md), `criado_em`/`atualizado_em` (internal, unless needed for `-criado_em` ordering — ordering doesn't require exposing the field itself), any `situacao` internal workflow state beyond the boolean effect of `publicado` already being enforced at the queryset level (never exposed as a field to filter/see from the public API — it's a queryset filter server-side only, not client-controllable).

**View sketch:**
```python
# imoveis/api/views.py  (new app, teammate-owned, or shared — TBD with web team)
class ImovelPublicoListAPIView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = ImovelVitrineSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = ImovelPublicoFilterSet   # django-filter FilterSet: cidade, finalidade, natureza, preco_min/max→preco, quartos__gte, etc.
    search_fields = ["titulo", "bairro"]
    ordering_fields = ["preco", "area", "criado_em"]
    ordering = ["-criado_em"]

    def get_queryset(self):
        return Imovel.objects.filter(publicado=True).select_related("endereco", "endereco__cidade")
```

**Why no `EmpresaScopedQuerySetMixin` here:** see Anti-Pattern 3 above — this is a cross-empresa public listing by city, not one empresa's authenticated acervo view.

## Build Order — what's blocked on the teammate's `Imóvel` model vs what proceeds now

The hard dependency is explicit in PROJECT.md: *"Model de Imóvel... construído na frente web pelos colegas (E2)."* Sequence work so nothing sits idle waiting on that model longer than necessary.

**Can start immediately, no dependency on `Imóvel`:**
1. Flutter project scaffold: `pubspec.yaml` deps (`flutter_bloc`, `get_it`, `freezed`/`json_serializable`, `dio`, `fpdart`, `shared_preferences`, `geolocator`), `core/` (DI container, DioClient, Failure/UseCase base types, theme), folder skeleton above.
2. `API-CIDADES` end-to-end, both sides — `Cidade` model already exists, nothing blocks this. Build the real `GET /api/publico/cidades/` endpoint (small, ~30 min of Django work reusing the existing `CidadeSerializer`) and the Flutter `localizacao/` feature against the *real* endpoint, not a mock. This also fully unblocks and validates APP01.
3. `vitrine/` feature's entire skeleton against a **contract mock**: `domain/` entities (`Imovel`, `PaginaImoveis`, `FiltroVitrine`), `domain/repositories/imovel_repository.dart` interface, `BuscarImoveis` UseCase, `VitrineCubit` + states, and all `presentation/` widgets (`ImovelCard`, `BuscaBar`, `OrdenacaoDropdown`, `FiltrosBottomSheet`) — all of this only needs the JSON shape agreed above, not the real Django model. Point `ImovelRemoteDataSource` at a local fixture/fake server (e.g. a `json_server`-style static JSON file matching the exact contract above, or a `MockImovelRemoteDataSource` behind a feature flag) so the entire UI, pagination-append logic, filter state, and error states can be built, tested, and demoed before `Imóvel` exists on the backend.
4. Coordinate the contract itself with the web team **now**, in writing (this document is a starting proposal) — specifically the `caracteristicas` shape and the `quartos`/`suites`/`vagas` exact/`__gte` semantics, since those depend on decisions the teammate will make while designing `Imóvel` in E2. Everything else in the contract (pagination style, envelope, excluded fields, ordering param names) can be locked in now since it doesn't depend on `Imóvel`'s internal field names.

**Genuinely blocked until the teammate's `Imóvel` model (and at least a `publicado` flag + photo relation) exists:**
1. The real `GET /api/publico/imoveis/` view, filterset, and serializer (Django side) — cannot query a model that doesn't exist yet.
2. Swapping `vitrine/`'s DataSource from the fixture/mock to the real Dio call — a one-line change in `injection_container.dart` if the mock strictly honored the contract above, which is the entire point of building against the contract first.
3. Any end-to-end verification that the *real* data (actual photos, actual prices) renders correctly — UAT for APP02/APP03 cannot fully close until this lands, only the UI/interaction layer can.

**Recommended phase-level takeaway for the roadmap:** `API-CIDADES` and the `localizacao/` feature form one deliverable phase that has zero external blockers and should go first. `vitrine/`'s UI/state-management work (APP02 scaffolding, APP03 filter UI) can be a second phase built against the mocked contract, running in parallel with the teammate's E2 `Imóvel` work. A final, smaller phase swaps the mock for the real `GET /api/publico/imoveis/` endpoint once `Imóvel` exists — this phase is short specifically because the contract was fixed early and the UI was already built against it.

## Sources

- `/Users/georgelucas/Documents/projeto-mobile/imovies-aqui-mobile/.planning/PROJECT.md` — mandated architecture constraints, scope, requirements (APP01–03, API-CIDADES, API-IMOVEIS) — HIGH confidence, primary source.
- `/Users/georgelucas/Documents/projeto-mobile/imoveis-aqui/README.md`, `CLAUDE.md` — current API state, multitenant rule, public endpoint pattern — HIGH confidence, primary source.
- `/Users/georgelucas/Documents/projeto-mobile/imoveis-aqui/Web/{localizacao,core,empresas}/**` (models, permissions, settings, existing public views/serializers) — read directly — HIGH confidence, primary source, grounds the concrete `CidadeSerializer`/`EmpresaPublicaAPIView` reuse recommendations.
- Django REST Framework official pagination docs (`django-rest-framework.org/api-guide/pagination/`) — HIGH confidence, official source — informs `PageNumberPagination` vs `CursorPagination` recommendation.
- Community sources on Flutter Clean Architecture folder structure (dev.to, Reso-Coder-style TDD Clean Architecture pattern, multiple converging guides) — MEDIUM confidence, cross-checked across several independent write-ups, consistent with each other and with PROJECT.md's own stated constraints.
- Community sources on `fpdart` vs `dartz` — MEDIUM confidence — `fpdart` recommended as the newer, actively maintained option; `dartz` remains a valid, more established alternative if the team prefers it (either satisfies PROJECT.md's "Result/Either" constraint equally).

---
*Architecture research for: Flutter Clean-Architecture app (Cubit/get_it/freezed) + the DRF public API contract it consumes*
*Researched: 2026-09-21*
