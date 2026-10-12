---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
reviewed: 2026-10-12T00:00:00Z
depth: standard
files_reviewed: 43
files_reviewed_list: lib/** and test/** files changed in phase 04 (generated *.g.dart, *.freezed.dart and lib/di/injection.config.dart excluded)
findings:
  critical: 0
  warning: 8
  info: 8
  total: 16
status: issues_found
---

# Phase 4: Code Review Report

**Status:** issues_found
**Structural findings (fallow):** none provided.

## Summary

The Clean Architecture layering, the `Result` handling, the discipline of never computing money or areas in the app, and the plain-text rendering of API strings are all solid. The weaknesses are mostly at the edges.

- Desktop mouse users (a stated target platform) cannot move between photos.
- The URL sanitisation has a dead bypass path.
- The contract test depends on files outside the source tree.
- The Cubit has no catch-all for unexpected errors.
- There are several small presentation inconsistencies.

## Critical Issues

None.

## Warnings

### WR-01: Gallery and fullscreen viewer cannot be paged with a mouse (Windows/macOS)
**File:** `lib/presentation/detalhe_imovel/widgets/galeria_imovel.dart:51-67`, `lib/presentation/detalhe_imovel/widgets/visualizador_fotos.dart:97-110`
**Issue:**
- `CLAUDE.md` lists Windows and macOS as target platforms.
- Flutter's default `MaterialScrollBehavior` does not include `PointerDeviceKind.mouse` in `dragDevices`, and no custom `scrollBehavior` exists anywhere in `lib/`.
- Both `PageView`s are therefore swipe-only. A mouse user sees "1/N" and can tap the photo, but cannot reach photos 2..N.
- There are no arrow buttons or keyboard shortcuts in either widget.
- The tests use touch-style `drag`, so they do not catch this.

**Fix:** Either set a `MaterialApp.scrollBehavior` that adds `PointerDeviceKind.mouse` to `dragDevices`, or add prev/next `IconButton`s that call `_controlador.previousPage` / `nextPage`. Buttons also help accessibility. Example:
```dart
class ComportamentoRolagem extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {...super.dragDevices, PointerDeviceKind.mouse};
}
```

### WR-02: `FotoImovelModel.paraEntidade()` is dead and bypasses the URL filter; `ordem` is required but never used
**File:** `lib/data/models/detalhe_imovel_model.dart:128-141` (also `71-75`)
**Issue:**
- `FotoImovelModel.paraEntidade()` is never called. A repo-wide grep confirms it.
- It copies `url` verbatim, while the real path in `DetalheImovelModel.paraEntidade` filters through `urlHttpOuNula` (V12/V13). A future caller using the "obvious" method would silently skip the security filter.
- `ordem` is a `required int`, so a server that omits it fails the whole detail with a `FormatException`. Yet it is never read, and the list is never sorted by it. If the API does not guarantee wire order, the "capa first" assumption breaks silently.

**Fix:** Delete `FotoImovelModel.paraEntidade()`, or make it return `FotoImovel?` using `urlHttpOuNula` and use it from the list comprehension. Then either make `ordem` nullable and unused, or stable-sort by it before mapping.

### WR-03: Contract test reads files from `.planning/` phase 1 by relative path
**File:** `test/data/contrato_detalhe_test.dart:17-24, 183-190`
**Issue:**
- `setUpAll` reads `.planning/phases/01-.../contrato/*.example.json` with `File(...).readAsStringSync()`.
- The test breaks if the planning directory is archived (the file's own comment admits this), if CI excludes `.planning/`, or if it runs from a different working directory.
- It also couples source tests to GSD planning artifacts, which the workflow filters out as non-source.

**Fix:** Move the two example JSONs to a stable location such as `test/fixtures/contrato/` (or declare them as test assets) and read them from there.

### WR-04: Double tap on a card pushes the detail page twice
**File:** `lib/presentation/vitrine/vitrine_screen.dart:354`, `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart:31-45`
**Issue:**
- `onTap: () => widget.aoAbrirImovel(context, imovel)` has no re-entrancy guard.
- During the push transition the card underneath still receives hits, so a quick second tap pushes a second `DetalheImovelScreen`.
- That also creates a second `DetalheImovelCubit` and a second fetch, and the user must press back twice.

**Fix:** Guard with a flag in `_VitrineScreenState`, for example:
```dart
bool _abrindo = false;
Future<void> _abrir(Imovel i) async {
  if (_abrindo) return;
  _abrindo = true;
  try { await widget.aoAbrirImovel(context, i); } finally { _abrindo = false; }
}
```

### WR-05: Fullscreen viewer shows a "broken image" icon while the photo is still loading
**File:** `lib/presentation/comum/imagem_rede.dart:63-64`, `lib/presentation/detalhe_imovel/widgets/visualizador_fotos.dart:168-172`
**Issue:**
- `ImagemRede` uses the same `padrao` widget for `placeholder` and `errorWidget`.
- The viewer passes `Icons.broken_image_outlined` as `imagemPadrao`, so every photo flashes a "broken image" glyph while loading and is indistinguishable from a real failure.
- The same applies to the corretor avatar (person icon during load), but that one is less misleading.

**Fix:** Add a separate `placeholderCarregando` parameter (a spinner, or empty) to `ImagemRede`, and keep the broken-image icon only for `errorWidget`.

### WR-06: Duplicated `finalidade`/`natureza` mappers across two models
**File:** `lib/data/models/detalhe_imovel_model.dart:97-123`, `lib/data/models/imovel_model.dart:60-86`
**Issue:**
- `_mapearFinalidade` and `_mapearNatureza` are byte-identical copies.
- A new `natureza` or `finalidade` added to only one of them gives the list and the detail different behaviour. That is a real risk, since the list already throws on an unknown `finalidade` and the detail does the same.

**Fix:** Extract shared top-level functions (for example `data/models/mapeadores_dominio.dart`) and use them from both models.

### WR-07: The Cubit and repository handle only `TypeError`/`Exception`; any other `Error` leaves the page on the spinner
**File:** `lib/data/repositories/imovel_detalhe_repository_impl.dart:37-43`, `lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart:23-54`
**Issue:**
- The repository converts `TypeError` and `Exception`. A `RangeError` or `StateError` (which are `Error`s) from `paraEntidade` or the data source escapes.
- `_buscar` has no `try/catch`, and the page triggers it unawaited (`criar()..carregar(previa.id)`). An escaped error becomes an unhandled zone error, and the state stays `carregando` forever with no retry button.
- `carregar` can also be called twice with overlapping in-flight requests. The last response wins, not the last request, so a stale result can overwrite a fresh one.

**Fix:** Wrap the use-case call in the Cubit with a catch-all that emits `DetalheImovelState.erro()`. This is an infrastructure boundary, not UI try/catch. Guard `_buscar` with a request token, for example:
```dart
Future<void> _buscar(int id) async {
  final token = ++_geracao;
  Result<DetalheImovel> r;
  try { r = await _obterDetalhe(id); } on Object { if (!isClosed && token == _geracao) emit(const DetalheImovelState.erro()); return; }
  if (isClosed || token != _geracao) return;
  ...
}
```

### WR-08: The 404 state still shows the withdrawn property's photo
**File:** `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart:96-111, 114-115`
**Issue:**
- For `DetalheNaoEncontrado`, the title and price are deliberately hidden ("saiu do ar"). But the `_ => ImagemRede(url: previa.fotoCapa)` branch still renders the cover photo in the app bar.
- The behaviour is inconsistent and shows content the page says is unavailable.

**Fix:** Add an explicit branch for `DetalheNaoEncontrado()` in the `background:` switch that returns `const ImagemPadraoImovel()`.

## Info

### IN-01: Inconsistent handling of zero values, and "0º" for the ground floor
**File:** `lib/presentation/detalhe_imovel/apresentacao_natureza.dart:106-107, 97-98, 141-148, 211`
**Issue:**
- `_contagem` omits zeros in the highlights, but `_inteiro` shows "Salas 0", "Pavimentos 0", "Elevadores 0" and similar.
- `Andar` renders `0º` for the ground floor (or `-1º` for a basement).

**Fix:** Pick one rule for zeros. Render `andar == 0` as "Térreo" and negative values as "Subsolo".

### IN-02: Documented "never throws / returned unchanged" contract does not hold for `NaN`/`Infinity`
**File:** `lib/presentation/detalhe_imovel/apresentacao_natureza.dart:22-34`, `lib/presentation/vitrine/apresentacao_imovel.dart:15-26`
**Issue:** `double.tryParse('NaN')` and `double.tryParse('Infinity')` succeed. The values are then formatted as "NaN m²" or "R$ ∞" rather than returned as-is.
**Fix:** Add `if (valor == null || !valor.isFinite) return valorDecimal;`.

### IN-03: `urlHttpOuNula` accepts embedded credentials and cleartext `http`
**File:** `lib/data/models/url_segura.dart:8-17`
**Issue:**
- `https://user:pass@host/x.jpg` passes, and the credentials would be sent as basic auth.
- Plain `http` passes too, but Android and iOS block cleartext by default, so these photos silently fall back to the placeholder.

**Fix:** Reject `uri.userInfo.isNotEmpty`. Consider allowing only `https` in release builds.

### IN-04: Test hooks exposed in production signatures; dead `ignore` comments
**File:** `lib/presentation/comum/imagem_rede.dart:52`, `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart:9-21`, `lib/presentation/detalhe_imovel/widgets/*.dart`, `lib/data/datasources/imovel_detalhe_mock_datasource.dart:26-29`
**Issue:**
- `construirImagemDeRede` is threaded through about eight production widgets and functions, most without `@visibleForTesting`.
- The two `// ignore: prefer_initializing_formals` comments in `paraTeste` suppress a lint that does not fire there.

**Fix:** Prefer a single injectable image-builder (an `InheritedWidget` or a `CacheManager` override) over per-widget parameters. Remove the unused `ignore` comments.

### IN-05: Viewer status-bar icons are likely invisible
**File:** `lib/presentation/detalhe_imovel/widgets/visualizador_fotos.dart:84-96`
**Issue:** The `AppBar` has a transparent background over black. Its overlay style is derived from the light theme, so the status-bar icons would be dark on black.
**Fix:** Set `systemOverlayStyle: SystemUiOverlayStyle.light`.

### IN-06: Tapping the collapsed app bar opens the photo viewer
**File:** `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart:93-111`
**Issue:** The gallery's `GestureDetector` sits behind the pinned toolbar area, so tapping the collapsed bar opens the viewer.
**Fix:** Disable `aoTocarFoto` when the app bar is collapsed, or confine the tap to the expanded region.

### IN-07: Import order and gallery index drift
**File:** `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart:8-9`, `lib/presentation/detalhe_imovel/widgets/galeria_imovel.dart:34, 71`
**Issue:**
- `../vitrine/...` is listed before `../comum/...`.
- `_indice` in `_GaleriaImovelState` is never reset or clamped if `widget.urls` changes length, which could show "5/3".

**Fix:** Sort the imports. Add `didUpdateWidget` to clamp `_indice`.

### IN-08: Long chip or title strings can overflow
**File:** `lib/presentation/detalhe_imovel/widgets/secoes_detalhe.dart:62`, `lib/presentation/detalhe_imovel/widgets/cards_natureza.dart:95`
**Issue:** `Chip(label: Text(nome))` has no width constraint or `maxLines`. A very long server string (no length bound on the API) can overflow the `Wrap`.
**Fix:** Wrap the label in `ConstrainedBox(maxWidth: ...)` with `overflow: TextOverflow.ellipsis`.

_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
