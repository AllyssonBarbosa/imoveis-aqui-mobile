---
phase: 03-vitrine-filtros-server-side
reviewed: 2026-10-01T01:44:35Z
depth: standard
files_reviewed: 37
files_reviewed_list:
  - lib/data/datasources/imovel_mock_datasource.dart
  - lib/data/datasources/opcoes_filtro_datasource.dart
  - lib/data/datasources/opcoes_filtro_mock_datasource.dart
  - lib/data/datasources/parametros_consulta_imoveis.dart
  - lib/data/mocks/imoveis_fixture.dart
  - lib/data/repositories/opcoes_filtro_repository_impl.dart
  - lib/domain/entities/consulta_imoveis.dart
  - lib/domain/entities/filtros_vitrine.dart
  - lib/domain/repositories/opcoes_filtro_repository.dart
  - lib/domain/usecases/obter_bairros_usecase.dart
  - lib/domain/usecases/obter_caracteristicas_usecase.dart
  - lib/presentation/cidade_selecao/cidade_selecao_screen.dart
  - lib/presentation/vitrine/apresentacao_filtros.dart
  - lib/presentation/vitrine/opcoes_filtro_cubit.dart
  - lib/presentation/vitrine/opcoes_filtro_state.dart
  - lib/presentation/vitrine/rascunho_filtros_cubit.dart
  - lib/presentation/vitrine/sessao_filtros_vitrine.dart
  - lib/presentation/vitrine/vitrine_cubit.dart
  - lib/presentation/vitrine/vitrine_screen.dart
  - lib/presentation/vitrine/vitrine_state.dart
  - lib/presentation/vitrine/widgets/chips_filtros_ativos.dart
  - lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart
  - lib/presentation/vitrine/widgets/mascara_numerica.dart
  - test/data/imovel_mock_datasource_test.dart
  - test/data/opcoes_filtro_mock_datasource_test.dart
  - test/data/opcoes_filtro_repository_impl_test.dart
  - test/data/parametros_consulta_imoveis_test.dart
  - test/domain/filtros_vitrine_test.dart
  - test/presentation/apresentacao_filtros_test.dart
  - test/presentation/filtros_bottom_sheet_test.dart
  - test/presentation/mascara_numerica_test.dart
  - test/presentation/opcoes_filtro_cubit_test.dart
  - test/presentation/rascunho_filtros_cubit_test.dart
  - test/presentation/sessao_filtros_vitrine_test.dart
  - test/presentation/vitrine_cubit_test.dart
  - test/presentation/vitrine_fluxo_test.dart
  - test/presentation/vitrine_screen_test.dart
findings:
  critical: 0
  warning: 2
  info: 3
  total: 5
status: issues_found
---

# Phase 03: Code Review Report

**Reviewed:** 2026-10-01T01:44:35Z
**Depth:** standard
**Files Reviewed:** 37
**Status:** issues_found

## Summary

Reviewed the full source + test set for the "vitrine com filtros server-side" phase: the mock server
(`ImovelMockDataSource`, `OpcoesFiltroMockDataSource`, `parametros_consulta_imoveis.dart`,
`imoveis_fixture.dart`), the filter domain model (`FiltrosVitrine`), the presentation layer
(`VitrineCubit`, `RascunhoFiltrosCubit`, `OpcoesFiltroCubit`, `SessaoFiltrosVitrine`, the bottom sheet
and its widgets), and all 37 paired test files.

This is a well-disciplined codebase: Clean Architecture boundaries are respected (no network/business
logic in widgets), filtering/sorting/validation genuinely live server-side in the mock datasource (never
recomputed in the app), `Result`/sealed-state patterns are used consistently, and the test suite
(85 tests just in the two files spot-checked, hundreds across the full set) is unusually thorough —
including adversarial cases (idempotency, stale-response discarding via version tokens, debounce
coalescing, cursor tampering, inverted ranges, nulls-last ordering). I ran the full `imovel_mock_datasource_test.dart`
and `apresentacao_filtros_test.dart` suites; all 85 tests pass.

Given that strength, the defects found below are narrow: one confirmed, reproducible display bug in the
compact price/area formatter (verified by executing the function against boundary values), plus a
handful of code-quality nits (dead exception-handling boilerplate, a documented-but-unmitigated data
risk). No security issues, no crashes, and no business-logic-in-app violations were found.

## Warnings

### WR-01: `formatarValorCompacto` mis-renders values just under 1,000,000 as "1.000 mil" instead of "1 mi"

**File:** `lib/presentation/vitrine/apresentacao_filtros.dart:142-150`
**Issue:** The function picks the "mil"/"mi" bucket using the raw integer value (`valor >= 1000000` →
"mi", `valor >= 1000` → "mil"), but then independently rounds to one decimal place *inside* the chosen
bucket via `NumberFormat('#,##0.#', 'pt_BR')`. For any `valor` in `[999950, 999999]`, the bucket decision
picks "mil" (since `valor < 1000000`), but `valor / 1000` (e.g. `999.95`..`999.999`) rounds UP to `1000.0`
with one decimal digit, which the pt_BR `NumberFormat` renders with a thousands separator as `"1.000"`.
The final label becomes `"R$ 1.000 mil"` (reads as "1 billion" to a Portuguese-speaking user, or at best
as a confusing/wrong magnitude) instead of either the correct `"R$ 999.999"`-ish value or a bump to
`"1 mi"`. Verified by direct execution:
```
999500 -> 999,5 mil   (correct)
999949 -> 999,9 mil   (correct)
999950 -> 1.000 mil    (BUG — should read as ~1 mi or exact value)
999999 -> 1.000 mil    (BUG)
```
This is reachable from real user input: a visitor can type `999999` (or any value `>= 999950`) into the
"Máximo" field of the Preço or the precoMin/precoMax chip renders this text directly
(`_rotuloPreco` → `formatarValorCompacto`), so the filter chip and "Até R$ ..." label can show a
nonsensical compacted value.
**Fix:** Round once, then branch on the rounded result, e.g.:
```dart
String formatarValorCompacto(int valor) {
  if (valor >= 999500000) return '${_umaCasaDecimal(valor / 1000000)} mi'; // handles 1mi rounding too
  final emMilhoes = valor / 1000000;
  if (valor >= 1000000 || _umaCasaDecimal(emMilhoes) == '1.000') {
    // recompute against the mi bucket once it would round up to 1000 mil
  }
  ...
}
```
A simpler fix: compute the rounded "mil" text first, and if it equals `"1.000"` (or more generally if the
rounded value hits the next magnitude), re-run the formatting one bucket up:
```dart
String formatarValorCompacto(int valor) {
  if (valor >= 1000000) return '${_umaCasaDecimal(valor / 1000000)} mi';
  if (valor >= 1000) {
    final texto = _umaCasaDecimal(valor / 1000);
    if (texto == '1.000') return '${_umaCasaDecimal(1)} mi'; // bumped by rounding
    return '$texto mil';
  }
  return '$valor';
}
```
Add a regression test for `formatarValorCompacto(999950)` / `formatarValorCompacto(999999)` alongside the
existing boundary tests in `apresentacao_filtros_test.dart`.

### WR-02: `ImovelMockDataSource` combines "erro" trigger check and filter validation in a 290-line, 9-dimension single method with inconsistent exception-priority

**File:** `lib/data/datasources/imovel_mock_datasource.dart:151-176` and `:260-343`
**Issue:** `_montarPagina` checks the deterministic `FalhaSimuladaDoMock` trigger (busca == "erro") *before*
calling `filtrosDosParametros(params)`, which performs D-12 validation (inverted price/area ranges, price
without finalidade, etc.). This means a consulta with `busca: 'erro'` AND an invalid filter combination
(e.g. `precoMin > precoMax`) always surfaces as `FalhaSimuladaDoMock` rather than the `FormatException`
a caller might expect to test validation ordering. This is not exercised by any test (both failure modes
collapse to `Result.failure` at the repository boundary, so it's invisible from the Cubit/UI), and is
unlikely to matter in practice, but it is an ordering inconsistency worth being intentional about before
Phase 4 reimplements this logic against the real Django validators (where exception precedence will be
whatever DRF validates first, not necessarily matching this mock).
**Fix:** Either document the deliberate precedence (busca-trigger wins over form validation) in the
class doc comment, or swap the order so `filtrosDosParametros` validation runs first — whichever matches
the eventual Django view's actual validation order, since this mock is explicitly described as rehearsing
the real contract.

## Info

### IN-01: Dead `try`/`catch`-`rethrow` around `Uri.parse` in `ImovelMockDataSource.seguir`

**File:** `lib/data/datasources/imovel_mock_datasource.dart:85-91`
**Issue:**
```dart
final Uri uri;
try {
  uri = Uri.parse(proximaPagina);
} on FormatException {
  rethrow;
}
```
This try/catch has no effect: `rethrow`-ing the only caught exception type is functionally identical to
not catching it at all (the same `FormatException` propagates to the caller either way). It's extra code
with no behavioral purpose, and could mislead a future reader into thinking something special happens
here (e.g. error wrapping) when nothing does.
**Fix:** Remove the try/catch and assign directly:
```dart
final uri = Uri.parse(proximaPagina);
```

### IN-02: Documented CSV-comma collision risk for `bairro`/`caracteristicas` filter params remains unmitigated

**File:** `lib/data/datasources/parametros_consulta_imoveis.dart:69-81`, `:150-161`
**Issue:** `_paraCsvOrdenado`/`listaDoParametro` serialize `Set<String>` filter values (bairro names,
características) as comma-separated values with no escaping. The code's own doc comment already flags
this ("RISCO REGISTRADO PARA O E2... dados reais precisarão de escape ou de um identificador"), and the
current fixture guarantees no comma ever appears in a bairro/característica name, so no test can catch
this today. Restating it here because it is a genuine, reachable data-integrity bug the moment Phase 4
wires this to real Django-sourced bairro/characteristic names (a bairro like `"Jardim das Nações, Lote 2"`
would silently split into two bogus filter values, corrupting the query with no error surfaced to the
user). Already tracked by the team; flagging so it is not lost when this phase's `REVIEW.md` is used as a
handoff artifact.
**Fix:** No action required in this phase (explicitly out of scope per the inline comment); ensure the
Phase 4 plan that replaces the mock datasource with the real `dio` implementation includes either
IDs instead of raw names, or a non-comma delimiter / proper URL-array encoding (`bairro=A&bairro=B`) for
these two params.

### IN-03: `FiltrosVitrine`'s bairros/características "chip" label depends on `Set` insertion order, not a stated ordering rule

**File:** `lib/presentation/vitrine/apresentacao_filtros.dart:130-136`
**Issue:** `_rotuloMultiSelecao` renders the chip text as `valores.first` + a count of the rest. Since
`Set<String>` in Dart is a `LinkedHashSet` by default, `.first` returns whichever element was inserted
first — in practice, whichever bairro/característica the user checked first in the bottom sheet. This is
exercised consistently by the existing tests (which always construct the Set/toggle in the order they
assert), so it is not a functional bug, but there is no doc comment establishing *why* "first selected"
(rather than, say, alphabetically-first, matching the sort order `OpcoesFiltroMockDataSource` already
uses for the options list) is the intended representative label. A future refactor of `FiltrosVitrine`
construction (e.g. switching to en `UnmodifiableSetView` wrapping a differently-ordered source, or
`copyWith` reconstructing the Set) could silently change which name is shown without any test catching a
regression in *meaning* (only in the literal string, if a test happens to assert it).
**Fix:** Either add a one-line doc comment on `_rotuloMultiSelecao` stating the insertion-order
dependency is intentional ("shows the most recently/first selected value"), or make the choice explicit
(e.g. sort before taking `.first`) so the behavior is self-evidently correct rather than an artifact of
`Set` implementation details.

---

_Reviewed: 2026-10-01T01:44:35Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
