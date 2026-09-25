# Phase 2: Vitrine — Lista, Busca e Ordenação - Pattern Map

**Mapped:** 2026-09-25
**Files analyzed:** 20 (Flutter) + 3 (Django, API-02)
**Analogs found:** 20 / 20 (Flutter) — 3 / 3 (Django)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|--------------------|------|-----------|-----------------|----------------|
| `lib/data/datasources/cidade_remote_datasource.dart` | service (datasource) | request-response (paginated GET) | `lib/data/datasources/cidade_local_datasource.dart` | role-match (asset→HTTP swap) |
| `lib/data/datasources/imovel_mock_datasource.dart` | service (datasource) | CRUD/filter (simulated server) | `lib/data/datasources/cidade_local_datasource.dart` | role-match |
| `lib/data/models/imovel_model.dart` | model | transform (JSON↔entity) | `lib/data/models/cidade_model.dart` | exact |
| `lib/data/models/imovel_model.freezed.dart` / `.g.dart` | model (generated) | transform | `lib/data/models/cidade_model.freezed.dart` / `.g.dart` | exact (codegen) |
| `lib/data/models/imoveis_envelope_model.dart` | model | transform (cursor envelope) | none (new shape) — pattern from RESEARCH Code Example | no analog |
| `lib/data/repositories/imovel_repository_impl.dart` | service (repository) | CRUD | `lib/data/repositories/cidade_repository_impl.dart` | exact |
| `lib/data/repositories/cidade_repository_impl.dart` | service (repository) | CRUD | itself (modified in place) | exact — modify only |
| `lib/domain/entities/imovel.dart` | model (entity) | transform | `lib/domain/entities/cidade.dart` | exact |
| `lib/domain/entities/ordenacao_vitrine.dart` | model (enum) | transform | none — small new enum, follow `Cidade` immutability conventions | no analog |
| `lib/domain/entities/pagina_imoveis.dart` | model (value object) | transform | none — small new value type | no analog |
| `lib/domain/repositories/imovel_repository.dart` | service (interface) | CRUD | `lib/domain/repositories/cidade_repository.dart` | exact |
| `lib/domain/usecases/buscar_imoveis_usecase.dart` | service (usecase) | CRUD/request-response | `lib/domain/usecases/obter_cidades_atendidas_usecase.dart` | exact |
| `lib/presentation/vitrine/vitrine_state.dart` | model (state union) | transform | `lib/presentation/cidade_selecao/cidade_selecao_state.dart` | exact |
| `lib/presentation/vitrine/vitrine_cubit.dart` | controller (Cubit) | event-driven/request-response | `lib/presentation/cidade_selecao/cidade_selecao_cubit.dart` | role-match (adds debounce+pagination, not in analog) |
| `lib/presentation/vitrine/vitrine_screen.dart` | component (screen) | request-response (renders Cubit state) | `lib/presentation/cidade_selecao/cidade_selecao_screen.dart` | exact |
| `lib/presentation/vitrine/widgets/imovel_card.dart` | component | transform (presentation of Imovel) | `lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart` (layout/tap conventions) + `_CorpoLista`'s `Card`/`ListTile` in `cidade_selecao_screen.dart` | role-match |
| `lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart` | component | event-driven (user selection) | none in-repo (first bottom sheet) — Material 3 `showModalBottomSheet` + `RadioListTile`, use `_CorpoLista` card-tap style as event-callback pattern | no analog |
| `lib/di/injection.dart` (+ generated `injection.config.dart`, Dio module) | config (DI) | — | itself (modified) — needs `@module` class for `Dio` singleton | partial (no existing Dio/`@module` example) |
| `lib/core/texto_normalizado.dart` (extracted util, per RESEARCH Don't-Hand-Roll) | utility | transform | `lib/domain/entities/cidade.dart` (`_normalizar` static method, lines 17-27) | exact (extraction source) |
| `pubspec.yaml` | config | — | itself (modified) — add `intl`, `cached_network_image`, `fake_async`, `assets/mocks/...json` | n/a |
| **Django (sibling repo `../imoveis-aqui/Web`)** | | | | |
| `empresas/api/views_publico_cidades.py` (or added to existing views) | controller (DRF view) | request-response (list, paginated) | `empresas/api/views.py::EmpresaPublicaAPIView` | exact |
| `empresas/api/urls_publico.py` (modified — add `cidades/` route) | route | request-response | itself (modified) — pattern from same file's `empresas/<int:pk>/` entry | exact |
| `empresas/api/serializers.py` (reuse `CidadeSerializer`, no new file) | model (serializer) | transform | `empresas/api/serializers.py::CidadeSerializer` (lines 9-12) | exact — reused as-is |

## Pattern Assignments

### `lib/data/datasources/cidade_remote_datasource.dart` (service/datasource, request-response)

**Analog:** `lib/data/datasources/cidade_local_datasource.dart` (full file read, 49 lines)

**Class shape / DI pattern** (lines 19-27):
```dart
@lazySingleton
class CidadeLocalDataSource {
  CidadeLocalDataSource() : _bundle = rootBundle;

  @visibleForTesting
  CidadeLocalDataSource.comBundle(AssetBundle bundle) : _bundle = bundle;

  final AssetBundle _bundle;
  ...
}
```
Apply the same shape but inject `Dio` instead of `AssetBundle`, and add a `@visibleForTesting` named constructor for tests (`CidadeRemoteDataSource.comDio(Dio dio)`), matching this repo's convention of exposing a testable secondary constructor rather than mocking the default one.

**Parsing/discard-invalid-row pattern** (lines 30-47): rows with missing/empty `nome`/`uf` are silently skipped, never thrown — reuse this defensive-parse style if the remote envelope ever contains partial rows, though DRF's `CursorPagination` envelope should already be well-formed. Follow Pattern 5 from RESEARCH.md for the pagination loop (`dio.get(nextUrl)` with absolute URL, loop until `next == null`).

**Result of file is a `List<CidadeModel>`** — same return type as the analog, so `CidadeRepositoryImpl` needs no interface change, only swapping which datasource it injects (see below).

---

### `lib/data/repositories/cidade_repository_impl.dart` (MODIFIED — service/repository, CRUD)

**Analog:** itself, current version (43 lines, already read in full)

**Current constructor injects the local datasource** (lines 15-18):
```dart
CidadeRepositoryImpl(this._local, this._prefs);

final CidadeLocalDataSource _local;
final CidadePrefsDataSource _prefs;
```
Swap `CidadeLocalDataSource` → `CidadeRemoteDataSource`, no other line changes — `obterCidadesAtendidas()` (lines 20-29) already wraps the call in `Result.success`/`Result.failure` via try/catch on `Exception`, so `Dio`'s `DioException` (a subtype of `Exception`) is already caught correctly by the existing `on Exception catch (erro)` clause. `salvarCidade`/`obterCidadeSalva` (lines 31-41) are untouched — they operate on `CidadePrefsDataSource`, unaffected by D-16.

---

### `lib/data/repositories/imovel_repository_impl.dart` (NEW — service/repository, CRUD)

**Analog:** `lib/data/repositories/cidade_repository_impl.dart` (same file as above)

**Core pattern to copy** — the try/catch → `Result` wrapping shape (lines 20-29):
```dart
@override
Future<Result<List<Cidade>>> obterCidadesAtendidas() async {
  try {
    final modelos = await _local.obterCidades();
    final cidades = modelos.map((modelo) => modelo.paraEntidade()).toList();
    return Result.success(cidades);
  } on Exception catch (erro) {
    return Result.failure(erro);
  }
}
```
`ImovelRepositoryImpl.buscarImoveis(...)` follows the identical shape: call `ImovelMockDataSource`, map `ImovelModel` → `Imovel` (via a `paraEntidade()` extension method on `ImovelModel`, same convention as `CidadeModel.paraEntidade()` at `cidade_model.dart:25`), wrap in `Result.success`/`Result.failure`. Register with `@LazySingleton(as: ImovelRepository)` (same annotation style as `cidade_repository_impl.dart:13`).

---

### `lib/data/models/imovel_model.dart` (NEW — model, transform)

**Analog:** `lib/data/models/cidade_model.dart` (full file, 27 lines)

**Full structure to copy:**
```dart
@freezed
abstract class CidadeModel with _$CidadeModel {
  const CidadeModel._();

  const factory CidadeModel({
    required int id,
    required String nome,
    required String uf,
  }) = _CidadeModel;

  factory CidadeModel.fromJson(Map<String, Object?> json) =>
      _$CidadeModelFromJson(json);

  /// Mapeia para a entidade de domínio (descarta o `id`, D-15).
  Cidade paraEntidade() => Cidade(nome: nome, uf: uf);
}
```
`ImovelModel` follows this exact shape (private constructor `const ImovelModel._()`, `part` directives for `.freezed.dart`/`.g.dart`, `fromJson` factory delegating to `_$ImovelModelFromJson`, and a `paraEntidade()` method mapping to the domain `Imovel`). Use RESEARCH.md's Code Example verbatim for field list (nullable PENDENTE-E2 fields, `CidadeModel cidade` nested field reusing this exact model).

---

### `lib/domain/entities/imovel.dart` (NEW — model/entity, transform)

**Analog:** `lib/domain/entities/cidade.dart` (full file, 39 lines)

**Structure to copy** — plain immutable class, no serialization, manual `==`/`hashCode`/`toString` (lines 4-39): `Imovel` should be a plain Dart class (not freezed, matching this repo's convention of freezed only in `data/`+`presentation/`, plain classes in `domain/entities/`), with `const` constructor and named required fields. If `Imovel` needs a formatted-price presenter (D-03, D-03/Pitfall 7 — BRL formatting logic must live outside the widget), add it as a getter method on this entity or a separate presenter function, following the same "logic lives on the entity, not scattered" precedent set by `Cidade.chaveNatural` (lines 15-27) — a computed getter on the entity itself.

**Extract `_normalizar` as a shared util** (RESEARCH Don't-Hand-Roll, lines 17-27 of `cidade.dart`):
```dart
static String _normalizar(String valor) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';
  final minusculo = valor.trim().toLowerCase();
  final builder = StringBuffer();
  for (final char in minusculo.split('')) {
    final indice = comAcento.indexOf(char);
    builder.write(indice >= 0 ? semAcento[indice] : char);
  }
  return builder.toString();
}
```
Move this into `lib/core/texto_normalizado.dart` as a top-level function, have `Cidade.chaveNatural` call it, and reuse it inside `ImovelMockDataSource` for accent/case-insensitive search on `titulo`/`bairro` (D-06) — do not reimplement.

---

### `lib/domain/repositories/imovel_repository.dart` (NEW — service/interface, CRUD)

**Analog:** `lib/domain/repositories/cidade_repository.dart` (full file, 13 lines)

```dart
abstract class CidadeRepository {
  Future<Result<List<Cidade>>> obterCidadesAtendidas();
  Future<void> salvarCidade(Cidade cidade);
  Future<Cidade?> obterCidadeSalva();
}
```
`ImovelRepository` follows the same minimal-interface style: one method, e.g. `Future<Result<PaginaImoveis>> buscarImoveis({required String cidadeChave, String? busca, required OrdenacaoVitrine ordenacao, String? cursor})`. Keep it a single abstract method returning `Result<T>` — no premature split.

---

### `lib/domain/usecases/buscar_imoveis_usecase.dart` (NEW — service/usecase, CRUD)

**Analog:** `lib/domain/usecases/obter_cidades_atendidas_usecase.dart` (full file, 15 lines)

```dart
@injectable
class ObterCidadesAtendidasUseCase {
  ObterCidadesAtendidasUseCase(this._repositorio);

  final CidadeRepository _repositorio;

  Future<Result<List<Cidade>>> call() => _repositorio.obterCidadesAtendidas();
}
```
Copy verbatim shape: `@injectable`, single-method `call(...)` delegating straight to the repository, no logic in the usecase itself (all business logic — search/sort/pagination — lives server-side / in the mock datasource per RESEARCH's Architectural Responsibility Map).

---

### `lib/presentation/vitrine/vitrine_state.dart` (NEW — model/state union, transform)

**Analog:** `lib/presentation/cidade_selecao/cidade_selecao_state.dart` (full file, 59 lines)

**Sealed union pattern** (lines 16-59):
```dart
@freezed
sealed class CidadeSelecaoState with _$CidadeSelecaoState {
  const factory CidadeSelecaoState.localizando() = Localizando;
  const factory CidadeSelecaoState.autorizadaEAtendida(Cidade cidade) = AutorizadaEAtendida;
  ...
}
```
Doc-comment convention: each variant gets a `///` explaining exactly which decision (`D-xx`) or requirement it satisfies — follow this for `VitrineState` (already drafted in RESEARCH.md Pattern 1, lines 291-305 of RESEARCH). Reuse the "flattened success state with flags" shape from RESEARCH Pattern 1 rather than a sealed-per-page state (explicit anti-pattern, RESEARCH lines 449-451).

---

### `lib/presentation/vitrine/vitrine_cubit.dart` (NEW — controller/Cubit, event-driven + request-response)

**Analog:** `lib/presentation/cidade_selecao/cidade_selecao_cubit.dart` (full file, 109 lines)

**Constructor + DI + initial state pattern** (lines 20-32):
```dart
@injectable
class CidadeSelecaoCubit extends Cubit<CidadeSelecaoState> {
  CidadeSelecaoCubit(
    this._geolocator,
    this._obterCidadesAtendidas,
    this._detectarCidade,
    this._validarCidadeAtendida,
  ) : super(const CidadeSelecaoState.localizando());
  ...
}
```
`VitrineCubit` follows the same `@injectable` + constructor-injected usecases + typed initial state shape, injecting `BuscarImoveisUseCase`.

**Result-switch pattern for emitting state from a usecase call** (lines 96-108):
```dart
Future<void> _emitirComListaAtendida(
  CidadeSelecaoState Function(List<Cidade>) construirEstado,
) async {
  final resultado = await _obterCidadesAtendidas();
  switch (resultado) {
    case Success(:final data):
      emit(construirEstado(data));
    case Failure():
      emit(const CidadeSelecaoState.erroCarregarCidades());
    case Loading():
      break;
  }
}
```
Copy this `switch` shape for both `_buscarPrimeiraPagina()` and `carregarMais()`, adding the request-token guard from RESEARCH Pattern 2 (lines 316-336 of RESEARCH.md) and the scroll guard from Pattern 4 (lines 376-406) — neither pattern exists yet in this codebase (this Cubit is simpler, no debounce/pagination), so those two additions are net-new logic layered on top of this file's existing switch-on-`Result` convention. Mirror the `@override Future<void> close()` cleanup convention for cancelling the debounce `Timer` (RESEARCH Pattern 3, lines 361-365) — `CidadeSelecaoCubit` has no `close()` override today (nothing to cancel), so this is new but follows standard `Cubit` lifecycle override style.

---

### `lib/presentation/vitrine/vitrine_screen.dart` (NEW — component/screen, request-response)

**Analog:** `lib/presentation/cidade_selecao/cidade_selecao_screen.dart` (full file, 259 lines)

**Exhaustive switch-per-state pattern** (lines 28-91):
```dart
return BlocBuilder<CidadeSelecaoCubit, CidadeSelecaoState>(
  builder: (context, state) {
    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          Localizando() => const _CorpoCarregando(),
          AutorizadaEAtendida(:final cidade) => _CorpoCidadeEntrada(cidade: cidade),
          ...
        },
      ),
    );
  },
);
```
Copy this exact `BlocBuilder` + exhaustive-`switch`-over-sealed-state shape (Dart 3 pattern matching, compile-checked exhaustiveness — doc comment at lines 11-15 explains why this matters). Each `VitrineState` variant gets its own private `_Corpo*` widget, same as `_CorpoCarregando`/`_CorpoLista`/`_CorpoErro` here.

**Error-state-with-retry widget pattern** (lines 230-258, `_CorpoErro`):
```dart
class _CorpoErro extends StatelessWidget {
  const _CorpoErro({required this.onTentarNovamente});
  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Não foi possível carregar as cidades', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(onPressed: onTentarNovamente, child: const Text('Tentar de novo')),
          ],
        ),
      ),
    );
  }
}
```
Reuse verbatim for `VitrineState.erroInicial()`'s body and for the inline "erroAoCarregarMais" affordance at the bottom of the infinite list (smaller inline variant).

**List rendering pattern** (lines 206-224, `_CorpoLista`'s `ListView.builder`): copy the `ListView.builder` + `itemCount`/`itemBuilder` shape for `VitrineScreen`'s card list, but attach a `ScrollController` (per RESEARCH Pattern 4) which this analog does not have (analog list is short/unpaginated).

---

### `lib/presentation/vitrine/widgets/imovel_card.dart` (NEW — component, transform)

**Analog:** `_CorpoLista`'s `Card`/`ListTile` block in `cidade_selecao_screen.dart` (lines 206-224) + `SeletorCidadeTopo` (full file, 55 lines) for tap/semantics conventions.

**Card-per-row pattern** (lines 211-221 of `cidade_selecao_screen.dart`):
```dart
return Card(
  child: ListTile(
    leading: const Icon(Icons.location_on),
    title: Text('${cidade.nome}, ${cidade.uf}'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => onTocarCidade(cidade),
  ),
);
```
`ImovelCard` follows Material 3 `Card` usage but needs a custom body (not `ListTile`) to fit D-01's "wide cover photo on top, info below" layout — wrap the whole card content (image + text column) in a `Card` the same way, keep the "long text doesn't break layout" comment convention (`cidade_selecao_screen.dart:215-216`) for `titulo`/`bairro` overflow handling.

**AspectRatio-wrapped image slot** — no existing analog in this repo (first `cached_network_image` usage); apply RESEARCH Pitfall 6 exactly: wrap `CachedNetworkImage` (including its `placeholder`/`errorWidget`) in a single `AspectRatio` so all three states (loading/error/loaded) share one height.

---

### `lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart` (NEW — component, event-driven)

**No close analog exists** in this codebase (first bottom sheet, first `RadioListTile`). Follow Material 3 `showModalBottomSheet` + `RadioListTile` per D-10/D-11, using the same callback-passed-to-widget convention seen in `SeletorCidadeTopo`'s `onTap: () => context.read<CidadeSelecaoCubit>().carregarLista()` (line 30) — i.e., trigger `context.read<VitrineCubit>().ordenarPor(novaOrdenacao)` directly from the tapped `RadioListTile`, not via a separate confirm step (matches this app's no-confirmation-step precedent, `cidade_selecao_screen.dart:98`).

---

### `lib/di/injection.dart` (MODIFIED — config/DI)

**Analog:** itself (12 lines, unchanged shape) + `injectable`'s `@module` convention (not yet used in this repo — needs a new `Dio` provider).

**Current content:**
```dart
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```
This file itself does not change (all registration is annotation-driven, discovered by `build_runner`). Add a new `lib/di/dio_module.dart` (or inline in `injection.dart`) with an `@module` abstract class exposing `@lazySingleton Dio dio() => Dio(BaseOptions(baseUrl: ...))`, reading `API_BASE_URL` via `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000')` (D-17). No existing `@module` example in this repo — this is genuinely new DI surface; keep it minimal (one `Dio` instance, `BaseOptions.baseUrl` + a sane connect/receive timeout) matching the "single responsibility, no premature `@Environment`" guidance in RESEARCH Pattern 6.

---

### Django: `empresas/api/views.py` (or new `views_publico_cidades.py`) (NEW — controller, request-response)

**Analog:** `empresas/api/views.py::EmpresaPublicaAPIView` (full file, 10 lines)

```python
from rest_framework import generics
from rest_framework.permissions import AllowAny

from ..models import Empresa
from .serializers import EmpresaPublicaSerializer


class EmpresaPublicaAPIView(generics.RetrieveAPIView):
    """Perfil público da empresa, sem login. Empresa inativa não aparece."""

    permission_classes = [AllowAny]
    serializer_class = EmpresaPublicaSerializer
    queryset = Empresa.objects.filter(ativa=True)
```
Copy the `permission_classes = [AllowAny]` + `queryset` filtered to only "active"/"served" rows pattern exactly. New view is `generics.ListAPIView` (not `RetrieveAPIView`, since it's a collection) + `pagination_class = CidadeCursorPagination` (new `CursorPagination` subclass, `ordering = ("nome", "uf")` per `Cidade.Meta.ordering`) + `queryset = Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()`, `serializer_class = CidadeSerializer` (already exists, reused as-is from `empresas/api/serializers.py:9-12`).

### Django: `empresas/api/urls_publico.py` (MODIFIED — route, request-response)

**Analog:** itself (current content, 6 lines)
```python
from django.urls import path
from .views import EmpresaPublicaAPIView

urlpatterns = [
    path("empresas/<int:pk>/", EmpresaPublicaAPIView.as_view(), name="publico-empresa"),
]
```
Add `path("cidades/", CidadesPublicasAPIView.as_view(), name="publico-cidades")` to the same `urlpatterns` list — already routed under `api/publico/` via `config/urls.py:14` (`path('api/publico/', include('empresas.api.urls_publico'))`), no `config/urls.py` change needed.

### Django: `empresas/api/serializers.py::CidadeSerializer` (REUSED — model/serializer, transform)

**Analog:** itself, lines 9-12 — reused verbatim, no modification:
```python
class CidadeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cidade
        fields = ["id", "nome", "uf"]
```

## Shared Patterns

### Result/sealed-state pattern (all Cubits, repositories, usecases)
**Source:** `lib/core/result.dart` (full file, 13 lines)
```dart
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.loading() = Loading<T>;
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Exception erro) = Failure<T>;
}
```
**Apply to:** `ImovelRepositoryImpl`, `CidadeRemoteDataSource` (indirectly, via `CidadeRepositoryImpl`), `BuscarImoveisUseCase`, `VitrineCubit` — no generic `try/catch` on the UI side, always `switch` on `Result` (see `_emitirComListaAtendida` example above).

### Repository try/catch-to-Result wrapping
**Source:** `lib/data/repositories/cidade_repository_impl.dart`, lines 20-29
**Apply to:** `ImovelRepositoryImpl.buscarImoveis(...)`, modified `CidadeRepositoryImpl.obterCidadesAtendidas()` (same method, now backed by `Dio` — `on Exception catch (erro)` already correctly catches `DioException`).

### `@lazySingleton`/`@LazySingleton(as: X)`/`@injectable` DI annotations
**Source:** `lib/data/datasources/cidade_local_datasource.dart:19`, `lib/data/repositories/cidade_repository_impl.dart:13`, `lib/domain/usecases/obter_cidades_atendidas_usecase.dart:8`
**Apply to:** every new datasource (`@lazySingleton`), every new repository impl (`@LazySingleton(as: <Interface>)`), every new usecase and Cubit (`@injectable`). Run `dart run build_runner build -d` after adding annotations (per CLAUDE.md), regenerating `injection.config.dart`.

### Exhaustive `switch` over sealed Cubit state in the screen
**Source:** `lib/presentation/cidade_selecao/cidade_selecao_screen.dart`, lines 28-91 (doc comment lines 11-15 explains the compile-time exhaustiveness guarantee)
**Apply to:** `VitrineScreen`'s top-level `switch (state) { ... }` over `VitrineState`'s sealed variants — no `default`/catch-all case, ever.

### AllowAny public DRF view + filtered-to-active queryset
**Source:** `../imoveis-aqui/Web/empresas/api/views.py::EmpresaPublicaAPIView` (10 lines)
**Apply to:** `CidadesPublicasAPIView` — same `permission_classes = [AllowAny]`, same "queryset pre-filtered to only rows that should be publicly visible" idiom (`ativa=True` there → `empresas_atuantes__ativa=True` here).

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `lib/data/models/imoveis_envelope_model.dart` | model | transform | First non-generic paginated-envelope model in the repo (cidades so far only came from a flat asset, no `{next,previous,results}` wrapper in Dart code yet) — build from RESEARCH.md's Code Example (`ImoveisEnvelopeModel`), same freezed+json_serializable shape as `ImovelModel`/`CidadeModel` |
| `lib/domain/entities/ordenacao_vitrine.dart` | model (enum) | transform | No enum-with-API-value precedent in `domain/entities/` yet; keep it a plain Dart `enum` with a `valorApi` getter (`String get valorApi => ...`), consistent with "domain entities are plain Dart, no freezed" convention from `cidade.dart` |
| `lib/domain/entities/pagina_imoveis.dart` | model (value object) | transform | No multi-field plain value object exists yet beyond `Cidade` itself; follow the same const-constructor/immutable-fields shape |
| `lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart` | component | event-driven | First `showModalBottomSheet`/`RadioListTile` usage in the app — build directly from Material 3 API + D-10/D-11, using `SeletorCidadeTopo`'s direct-callback-on-tap convention (no confirm step) |
| `lib/di/dio_module.dart` (or inline `@module`) | config | — | First `@module`/`Dio`-singleton registration in the repo — build from `injectable`'s standard `@module abstract class` + `@lazySingleton Dio dio() => ...` pattern (external library docs, not an in-repo analog) |

## Metadata

**Analog search scope:** `lib/` (all of `data/`, `domain/`, `presentation/`, `di/`, `core/`), sibling Django repo `../imoveis-aqui/Web/empresas/`, `localizacao/`, `config/`
**Files scanned:** 20 Dart files (full repo `lib/` tree) + 6 Python files (Django `empresas`/`localizacao`/`config`)
**Pattern extraction date:** 2026-09-25
**Tracked-source verification:** all analog paths confirmed via `git ls-files` in their respective repos (both `imovies-aqui-mobile` and `../imoveis-aqui/Web`) — no gitignored mirror paths used.
