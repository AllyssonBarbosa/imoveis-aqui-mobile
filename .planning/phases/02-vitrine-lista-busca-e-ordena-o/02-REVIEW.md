---
phase: 02-vitrine-lista-busca-e-ordena-o
reviewed: 2026-09-25T00:00:00Z
depth: standard
files_reviewed: 50
files_reviewed_list:
  - README.md
  - android/app/src/debug/AndroidManifest.xml
  - android/app/src/main/AndroidManifest.xml
  - ios/Runner/Info.plist
  - lib/core/texto_normalizado.dart
  - lib/data/datasources/cidade_remote_datasource.dart
  - lib/data/datasources/imovel_datasource.dart
  - lib/data/datasources/imovel_mock_datasource.dart
  - lib/data/datasources/parametros_consulta_imoveis.dart
  - lib/data/mocks/imoveis_fixture.dart
  - lib/data/models/cidade_model.dart
  - lib/data/models/imoveis_envelope_model.dart
  - lib/data/models/imovel_model.dart
  - lib/data/repositories/cidade_repository_impl.dart
  - lib/data/repositories/imovel_repository_impl.dart
  - lib/di/injection.config.dart
  - lib/di/injection.dart
  - lib/di/modulo_rede.dart
  - lib/domain/entities/cidade.dart
  - lib/domain/entities/consulta_imoveis.dart
  - lib/domain/entities/imovel.dart
  - lib/domain/entities/ordenacao_vitrine.dart
  - lib/domain/entities/pagina_imoveis.dart
  - lib/domain/repositories/cidade_repository.dart
  - lib/domain/repositories/imovel_repository.dart
  - lib/domain/usecases/buscar_imoveis_usecase.dart
  - lib/domain/usecases/obter_cidades_atendidas_usecase.dart
  - lib/domain/usecases/validar_cidade_atendida_usecase.dart
  - lib/presentation/cidade_selecao/cidade_selecao_screen.dart
  - lib/presentation/cidade_selecao/cidade_selecao_state.dart
  - lib/presentation/vitrine/apresentacao_imovel.dart
  - lib/presentation/vitrine/vitrine_cubit.dart
  - lib/presentation/vitrine/vitrine_screen.dart
  - lib/presentation/vitrine/vitrine_state.dart
  - lib/presentation/vitrine/widgets/foto_capa_imovel.dart
  - lib/presentation/vitrine/widgets/imovel_card.dart
  - lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart
  - pubspec.yaml
  - test/core/texto_normalizado_test.dart
  - test/data/cidade_remote_datasource_test.dart
  - test/data/imovel_mock_datasource_test.dart
  - test/data/imovel_repository_impl_test.dart
  - test/domain/validar_cidade_atendida_usecase_test.dart
  - test/main_launch_routing_test.dart
  - test/presentation/apresentacao_imovel_test.dart
  - test/presentation/cidade_selecao_screen_test.dart
  - test/presentation/imovel_card_test.dart
  - test/presentation/ordenacao_bottom_sheet_test.dart
  - test/presentation/seletor_cidade_topo_test.dart
  - test/presentation/vitrine_cubit_test.dart
  - test/presentation/vitrine_fluxo_test.dart
  - test/presentation/vitrine_screen_test.dart
findings:
  critical: 0
  warning: 3
  info: 3
  total: 6
status: issues_found
---

# Phase 02: Code Review Report

**Reviewed:** 2026-09-25T00:00:00Z
**Depth:** standard
**Files Reviewed:** 50 (mobile app) + cross-repo context read from `../imoveis-aqui/Web` (Django, read-only, not in this repo's scope)
**Status:** issues_found

## Summary

This phase (vitrine: lista/busca/ordenação, VIT-01..05) is unusually well-engineered for a
mid-phase submission: the Cubit's debounce/versioning logic against race conditions
(city-switch-while-in-flight, stale "load more" responses, close()-during-network-call) is
carefully built and has dense, targeted test coverage (`vitrine_cubit_test.dart`) that actually
exercises the race conditions via `Completer`/`fakeAsync` rather than just happy paths. The
`CidadeRemoteDataSource` pagination-following logic has a real, tested SSRF-style guard (never
follow `next` to a different origin) and a bounded page count. No injection, hardcoded secret,
or `eval`-class vulnerability was found.

The issues below are narrower: an inconsistent error-handling contract between the
cidades path (defensively validates fields before constructing models) and the imóveis path
(trusts `json_serializable`'s unchecked casts and only catches `Exception`, not `Error`), a
`Cubit.emit` call that isn't guarded against `isClosed` at entry (only after the network
`await`), and a couple of low-value/dead-code and doc-consistency nits.

## Warnings

### WR-01: `TypeError` from malformed imóvel JSON is never caught — vitrine hangs on "carregando" forever

**File:** `lib/data/repositories/imovel_repository_impl.dart:18-40`
**Issue:**
`ImovelRepositoryImpl.buscarImoveis`/`buscarProximaPagina` only catch `on Exception catch (erro)`:

```dart
try {
  final envelope = await _dataSource.buscar(consulta);
  return Result.success(envelope.paraPagina());
} on Exception catch (erro) {
  return Result.failure(erro);
}
```

`envelope.paraPagina()` maps every row through `ImovelModel.paraEntidade()`, and the envelope
itself was built via `ImoveisEnvelopeModel.fromJson(...)` / `ImovelModel.fromJson(...)`
(`lib/data/models/imoveis_envelope_model.dart:22-23`, `lib/data/models/imovel_model.dart:37-38`).
Those are the plain, *unchecked* `json_serializable` factories (no `@JsonSerializable(checked:
true)`), so a missing/wrong-typed field (e.g. `criado_em: null`, or `id` sent as a string) throws
a raw `TypeError`, not an `Exception`. `on Exception catch` does not match `TypeError` (it's an
`Error`), so the exception propagates out of `buscarImoveis`/`buscarProximaPagina` uncaught.

That propagation lands in `VitrineCubit._aplicarConsulta`/`_carregarProximaPagina`, which are
invoked via `unawaited(...)` from `carregar()`/`ordenarPor()`/etc. An uncaught error inside an
`unawaited` Future is silently dropped by the zone's uncaught-error handler — the Cubit never
reaches the `Failure()` branch, so it never emits `ConteudoVitrine.erro()`. The user is left
staring at the loading spinner (`VitrineCarregando`) forever, with no "Tentar de novo" affordance,
for a single malformed row anywhere in the response.

Contrast this with `CidadeRemoteDataSource.obterCidades()` (`lib/data/datasources/
cidade_remote_datasource.dart:56-71`), which deliberately avoids this exact trap by validating
`id`/`nome`/`uf` types by hand and constructing `CidadeModel(...)` directly (never calling
`CidadeModel.fromJson` on untrusted rows) — proving the team already knows this failure mode
exists, just didn't carry the same defense into the imóveis path. This is currently latent
because the in-memory mock fixture (`imoveis_fixture.dart`) is always well-formed and covered by
`ImovelModel` parsing tests, but it becomes a real production risk the moment Phase 4 swaps in
the actual Django endpoint, where a single bad row (e.g. a future nullable-turned-non-nullable
mismatch) would hang every user's vitrine for that city.

**Fix:** Broaden the catch (and wrap non-`Exception` errors so `Result.failure`'s `Exception erro`
parameter still type-checks), e.g.:

```dart
try {
  final envelope = await _dataSource.buscar(consulta);
  return Result.success(envelope.paraPagina());
} catch (erro) {
  return Result.failure(erro is Exception ? erro : Exception(erro.toString()));
}
```

Apply the same change to `buscarProximaPagina`, and consider doing the equivalent defensive
row validation used by `CidadeRemoteDataSource` once the real `/imoveis` endpoint lands in Phase 4.

### WR-02: `VitrineCubit._aplicarConsulta` / `_carregarProximaPagina` call `emit()` before checking `isClosed`

**File:** `lib/presentation/vitrine/vitrine_cubit.dart:126-143, 193-207`
**Issue:** Both private methods increment/capture the version token and call `emit(...)`
(the "loading"/"carregandoMais" state) *before* any `isClosed` check — the existing
`if (minhaVersao != _versaoConsulta || isClosed) return;` guard only runs **after** the
`await` on the network call:

```dart
Future<void> _aplicarConsulta({...}) async {
  final cidade = _cidade;
  if (cidade == null) return;

  final minhaVersao = ++_versaoConsulta;
  emit(state.copyWith(...));               // <-- no isClosed guard here
  final resultado = await _buscarImoveis(...);
  if (minhaVersao != _versaoConsulta || isClosed) return;   // guard only here
  ...
}
```

`buscar()`'s own debounce path is protected because `close()` cancels the pending `Timer`
(and this is tested: "close() com debounce pendente nunca dispara a chamada"). But
`ordenarPor()` and `limparBusca()` call `_aplicarConsulta` directly and synchronously — if
either is invoked once the Cubit is already closed (e.g. a stale `aoEscolher` callback fired
from a `mostrarOrdenacaoBottomSheet` that outlived the `VitrineScreen`'s `BlocProvider`, or any
future caller that doesn't perfectly track the Cubit lifecycle), the synchronous `emit()` throws
`StateError: Cannot emit new states after calling close`. There is no test exercising
`ordenarPor()`/`limparBusca()`/`carregarMais()` called after `close()` (only the network-response-
after-close path is tested).

**Fix:** Guard at entry, not just after the await:

```dart
Future<void> _aplicarConsulta({...}) async {
  if (isClosed) return;
  final cidade = _cidade;
  if (cidade == null) return;
  ...
}
```

and the equivalent at the top of `_carregarProximaPagina`.

### WR-03: `next` same-origin check in `CidadeRemoteDataSource` also compares `scheme`, which will reject legitimate pagination behind a TLS-terminating reverse proxy

**File:** `lib/data/datasources/cidade_remote_datasource.dart:92-102`
**Issue:** `_resolverProximaUrl` requires `proximoUri.scheme == baseUri.scheme` in addition to
host/port. This is a deliberate and good anti-SSRF defense (T-02-04-02), but in a very common
production topology — Django behind an HTTPS-terminating reverse proxy/load balancer, without
`SECURE_PROXY_SSL_HEADER`/`USE_X_FORWARDED_HOST` configured — `request.build_absolute_uri()`
on the Django side (used by DRF's `CursorPagination` to build `next`) returns `http://...` even
though the app's `API_BASE_URL` (and the public-facing URL) is `https://...`. Every page after
the first would then throw `FormatException` in `obterCidades()`, converted by
`CidadeRepositoryImpl` into `Result.failure`, surfacing `ErroCarregarCidades` for any deployment
with more than one page of cities (currently masked in dev because `CidadeCursorPagination.
page_size = 50` and the seeded dataset has 4 cities, so `next` is always `null` today).
**Fix:** Not a code defect in this repo per se, but worth a `README.md`/deploy-notes callout
that production Django must set `SECURE_PROXY_SSL_HEADER` (or otherwise ensure
`build_absolute_uri()` reflects the externally-visible scheme) so this app-side guard doesn't
misfire; alternatively, relax the check to same-host+port only once HTTPS termination is
confirmed to always be consistent.

## Info

### IN-01: Dead try/catch in `ImovelMockDataSource.seguir`

**File:** `lib/data/datasources/imovel_mock_datasource.dart:86-92`
**Issue:**
```dart
final Uri uri;
try {
  uri = Uri.parse(proximaPagina);
} on FormatException {
  rethrow;
}
```
This catches `FormatException` only to immediately `rethrow` it — behaviorally identical to
`final uri = Uri.parse(proximaPagina);` with no try/catch at all. Harmless, but it's dead-weight
mock-only code that will be deleted in Phase 4 anyway.
**Fix:** `final uri = Uri.parse(proximaPagina);`

### IN-02: `pubspec.yaml` pins `freezed: ^4.0.1`, one patch below the version CLAUDE.md's mandated stack table specifies

**File:** `pubspec.yaml:64`
**Issue:** CLAUDE.md's Technology Stack table states `freezed (+ freezed_annotation) ^4.0.2`.
`pubspec.yaml` declares `freezed: ^4.0.1`. `^4.0.1` still resolves to the latest `4.x` (so in
practice `pub get` likely lands on the same version either way), but it's a needless divergence
from the documented "exact versions" mandate the file's own comment claims to follow
(`# Mandated stack (CLAUDE.md §Technology Stack) — exact versions`).
**Fix:** Bump to `freezed: ^4.0.2` to match the documented constraint exactly.

### IN-03: `ImovelModel.suites` / `.vagas` / `.area` are parsed and generated in the fixture but never reach the domain layer or the UI

**File:** `lib/data/models/imovel_model.dart:32-34`, `lib/domain/entities/imovel.dart`
**Issue:** `suites`, `vagas`, and `area` are declared on `ImovelModel`, populated for every
generated fixture row (`imoveis_fixture.dart:197-198,250-251`), and `area` even drives the
`areaAsc`/`areaDesc` server-side sort — but `ImovelModel.paraEntidade()` never copies `suites`/
`vagas`/`area` onto the domain `Imovel`, and no widget displays them. This is explicitly called
out in code comments as "PENDENTE E2" (backend field not yet confirmed), so it's an intentional,
tracked gap rather than an oversight — flagging only so it isn't lost once E2 confirms the
fields, since right now there's no compiler signal (unused-field warnings don't fire for
freezed-generated classes) tying the parsed data back to a follow-up task.
**Fix:** No action required now; consider a `// TODO(E2):` marker or a linked backlog item so the
mapping gap surfaces again when the "PENDENTE E2" fields are unblocked.

---

_Reviewed: 2026-09-25T00:00:00Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
