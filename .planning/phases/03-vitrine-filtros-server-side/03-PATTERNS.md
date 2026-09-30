# Phase 3: Vitrine — Filtros Server-Side - Pattern Map

**Mapped:** 2026-09-30
**Files analyzed:** 16 (new + modified, per RESEARCH.md Recommended Project Structure)
**Analogs found:** 16 / 16

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/domain/entities/filtros_vitrine.dart` (NOVO) | model (domain entity, freezed) | transform | `lib/domain/entities/pagina_imoveis.dart` / `lib/presentation/vitrine/vitrine_state.dart` (freezed entity shape) | role-match |
| `lib/domain/entities/consulta_imoveis.dart` (ALTERADO) | model | transform | itself (existing file) | exact |
| `lib/domain/repositories/opcoes_filtro_repository.dart` (NOVO) | service (repository interface) | request-response | `lib/domain/repositories/cidade_repository.dart` | exact |
| `lib/domain/usecases/obter_bairros_usecase.dart` (NOVO) | service (use case) | request-response | `lib/domain/usecases/obter_cidades_atendidas_usecase.dart` | exact |
| `lib/domain/usecases/obter_caracteristicas_usecase.dart` (NOVO) | service (use case) | request-response | `lib/domain/usecases/obter_cidades_atendidas_usecase.dart` | exact |
| `lib/data/datasources/parametros_consulta_imoveis.dart` (ALTERADO) | utility (query mapping) | transform | itself (existing file) | exact |
| `lib/data/datasources/imovel_mock_datasource.dart` (ALTERADO) | service (mock data source) | CRUD/transform | itself (existing file) | exact |
| `lib/data/datasources/opcoes_filtro_mock_datasource.dart` (NOVO) | service (mock data source) | request-response | `lib/data/datasources/imovel_mock_datasource.dart` (closest: fixture-driven mock, `@LazySingleton`) + `lib/data/datasources/cidade_remote_datasource.dart` (closest: options-list shape) | role-match |
| `lib/data/repositories/opcoes_filtro_repository_impl.dart` (NOVO) | service (repository impl) | request-response | `lib/data/repositories/imovel_repository_impl.dart` | exact |
| `lib/data/mocks/imoveis_fixture.dart` (ALTERADO) | config (fixture data) | batch | itself (existing file) | exact |
| `lib/presentation/vitrine/vitrine_cubit.dart` (ALTERADO) | controller (Cubit) | event-driven | itself (existing file) | exact |
| `lib/presentation/vitrine/vitrine_state.dart` (ALTERADO) | model (freezed state) | transform | itself (existing file) | exact |
| `lib/presentation/vitrine/vitrine_screen.dart` (ALTERADO) | component (screen widget) | request-response | itself (existing file) | exact |
| `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart` (NOVO) | component (bottom sheet) | event-driven | `lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart` | role-match (simpler analog; sheet is single-select radio vs. multi-field draft) |
| `lib/presentation/vitrine/widgets/rascunho_filtros_cubit.dart` + `rascunho_filtros_state.dart` (NOVO) | controller (short-lived Cubit) | event-driven | `lib/presentation/vitrine/vitrine_cubit.dart` + `vitrine_state.dart` (freezed-state + Cubit discipline) | role-match |
| `lib/presentation/vitrine/widgets/chip_filtro_ativo.dart` (NOVO) | component (stateless widget) | transform | `lib/presentation/vitrine/widgets/imovel_card.dart` (closest small presentational widget) | partial-match |
| `lib/presentation/vitrine/widgets/mascara_numerica.dart` (NOVO) | utility (`TextInputFormatter`) | transform | none in codebase (new SDK-class extension point) | no-analog |

## Pattern Assignments

### `lib/domain/entities/filtros_vitrine.dart` (model, transform)

**Analog:** `lib/presentation/vitrine/vitrine_state.dart` (freezed usage pattern) + `lib/domain/entities/consulta_imoveis.dart` (plain domain entity holding a query's shape)

**Freezed class + private extension pattern** (`vitrine_state.dart` lines 1-18):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'vitrine_state.freezed.dart';

@freezed
abstract class VitrineState with _$VitrineState {
  const factory VitrineState({
    @Default(OrdenacaoVitrine.maisRecentes) OrdenacaoVitrine ordenacao,
    String? termoBusca,
    @Default(ConteudoVitrine.carregando()) ConteudoVitrine conteudo,
  }) = _VitrineState;
}
```
RESEARCH.md already specifies the exact target shape (Pattern 1) — use it verbatim as the primary source; the codebase confirms `@freezed`/`part` conventions and the `@Default` idiom for collection fields (`Set<T>`), matching how `VitrineCarregada` defaults `carregandoMais`/`erroAoCarregarMais` to `false`.

**Plain domain entity `==`/`hashCode`/`toString` convention** (`consulta_imoveis.dart` lines 7-32): note this file currently is a *hand-rolled* class, not freezed — `ConsultaImoveis` gains a `filtros` field per RESEARCH.md; follow the existing hand-rolled `operator ==`/`hashCode`/`toString` triad already in this file rather than converting it to freezed (keep the diff minimal — add `filtros` to all three).

---

### `lib/domain/repositories/opcoes_filtro_repository.dart` (service, request-response)

**Analog:** `lib/domain/repositories/cidade_repository.dart` — not read in full this session, but its shape is proven by its sibling `lib/domain/repositories/imovel_repository.dart` (lines 1-14):
```dart
import '../../core/result.dart';
import '../entities/consulta_imoveis.dart';
import '../entities/pagina_imoveis.dart';

abstract class ImovelRepository {
  Future<Result<PaginaImoveis>> buscarImoveis(ConsultaImoveis consulta);
  Future<Result<PaginaImoveis>> buscarProximaPagina(String proximaPagina);
}
```
Apply directly: `abstract class OpcoesFiltroRepository { Future<Result<List<String>>> bairrosPorCidade(Cidade cidade); Future<Result<List<String>>> caracteristicas(); }` (RESEARCH Pattern 7, already concrete).

---

### `lib/domain/usecases/obter_bairros_usecase.dart` / `obter_caracteristicas_usecase.dart` (service, request-response)

**Analog:** `lib/domain/usecases/obter_cidades_atendidas_usecase.dart` (full file, lines 1-17):
```dart
import 'package:injectable/injectable.dart';

import '../../core/result.dart';
import '../entities/cidade.dart';
import '../repositories/cidade_repository.dart';

@injectable
class ObterCidadesAtendidasUseCase {
  ObterCidadesAtendidasUseCase(this._repositorio);

  final CidadeRepository _repositorio;

  Future<Result<List<Cidade>>> call() => _repositorio.obterCidadesAtendidas();
}
```
Copy this shape exactly: `@injectable`, constructor-injected repository interface (never the mock class), single `call()`/named method delegating with zero business logic — same as `BuscarImoveisUseCase` (lines 1-21), which additionally shows the "delegate only" doc comment convention: *"Delega direto ao repositório (sem lógica própria)"*.

---

### `lib/data/datasources/parametros_consulta_imoveis.dart` (utility, transform) — ALTERADO

**Analog:** itself, existing code (full file, lines 1-51). Current mapping + inverse-parsing pattern to extend:
```dart
Map<String, String> parametrosDaConsulta(ConsultaImoveis consulta) {
  final params = <String, String>{
    'cidade': '${consulta.cidade.nome}-${consulta.cidade.uf}',
    'ordenacao': consulta.ordenacao.valorApi,
  };
  final busca = consulta.busca?.trim();
  if (busca != null && busca.isNotEmpty) {
    params['busca'] = busca;
  }
  return params;
}
```
and the `FormatException`-based inverse-parser convention:
```dart
OrdenacaoVitrine ordenacaoDoParametro(String valor) {
  for (final opcao in OrdenacaoVitrine.values) {
    if (opcao.valorApi == valor) return opcao;
  }
  throw FormatException('ordenacao desconhecida: $valor');
}
```
Extend `parametrosDaConsulta` with the `if (f.x != null) params['x'] = ...` block already fully drafted in RESEARCH.md Pattern 1 (lines 379-403 of 03-RESEARCH.md) — copy verbatim, it was derived directly from this file. Add symmetric parsers (`bairroDoParametro`, `caracteristicasDoParametro`, `naturezaDoParametro`) following the same `FormatException` convention as `ordenacaoDoParametro`/`cidadeDoParametro` — required because `ImovelMockDataSource.seguir()` round-trips every param through the cursor URL (see next entry).

---

### `lib/data/datasources/imovel_mock_datasource.dart` (service, CRUD/transform) — ALTERADO

**Analog:** itself, existing code. Key excerpts to extend, not replace:

**Filter pipeline on wire-format maps** (lines 136-146, `_paginar`):
```dart
final linhasFiltradas =
    _linhas.where((linha) {
      final cidadeLinha = linha['cidade']! as Map<String, Object?>;
      final cidadeDaLinha = Cidade(
        nome: cidadeLinha['nome']! as String,
        uf: cidadeLinha['uf']! as String,
      );
      if (cidadeDaLinha.chaveNatural != chaveCidade) return false;
      return _linhaCasaComBusca(linha, termoBusca);
    }).toList()
    ..sort(_comparadorDe(ordenacao));
```
Add each new filter (D-01..D-05) as another `&&`-chained predicate inside this same `.where()`, operating on the raw wire map (`linha['quartos'] as int`, `linha['natureza'] as String`, etc.) — never after `ImoveisEnvelopeModel.fromJson` parsing, matching the file's own doctrine (doc comment lines 28-34: "filtrando... sobre as linhas em forma de wire (snake_case)").

**"N or more" comparator pattern to copy for `quartos_min`/`suites_min`/`vagas_min`** (D-01, use `>=` not `==`) — mirror the existing nulls-last numeric comparator idiom (lines 252-270):
```dart
static int Function(Map<String, Object?>, Map<String, Object?>)
_compararPorCampoNumericoNullsLast(String campo, {required bool ascendente}) {
  return (a, b) {
    final valorA = a[campo] as String?;
    ...
  };
}
```
Use the same `as` cast + null-check discipline for new filter predicates (e.g. `(linha['quartos'] as int) >= quartosMin`).

**Base URL/cursor round-trip pattern** (lines 154-164, `montarUrl`) must also carry the new filter params through `next`/`previous` cursor URLs — extend `paramsBase` to include the new filter keys (via the extended `parametrosDaConsulta`), and extend `seguir()` (lines 93-111) to read them back out with the new inverse parsers.

**Deterministic failure trigger convention** (lines 15-26, `FalhaSimuladaDoMock`) — no new trigger needed this phase, but shows the project's pattern for simulating server-side validation failures (e.g. D-12's `FormatException` for min>max), reused by `ordenacaoDoParametro`.

---

### `lib/data/datasources/opcoes_filtro_mock_datasource.dart` (service, request-response) — NOVO

**Analog:** `lib/data/datasources/imovel_mock_datasource.dart` for the `@LazySingleton(as: ...)` + fixture-derived + artificial-latency conventions (class header, lines 44-53):
```dart
@LazySingleton(as: ImovelDataSource)
class ImovelMockDataSource implements ImovelDataSource {
  ImovelMockDataSource()
    : _linhas = linhasAcervoFixture(),
      _latencia = const Duration(milliseconds: 500),
      _tamanhoPagina = 10;

  @visibleForTesting
  ImovelMockDataSource.paraTeste({...});
```
Copy the dual-constructor idiom (`ImovelMockDataSource()` for injectable/production, `.paraTeste()` `@visibleForTesting` factory for tests) for `OpcoesFiltroMockDataSource`. RESEARCH.md Pattern 7 (lines 538-552 of 03-RESEARCH.md) already sketches the class signature — derive bairros/características from the SAME `imoveis_fixture.dart` rows (`linhasAcervoFixture()`), never a parallel fixed list, per D-20.

---

### `lib/data/repositories/opcoes_filtro_repository_impl.dart` (service, request-response) — NOVO

**Analog:** `lib/data/repositories/imovel_repository_impl.dart` (full file, lines 1-42):
```dart
@LazySingleton(as: ImovelRepository)
class ImovelRepositoryImpl implements ImovelRepository {
  ImovelRepositoryImpl(this._dataSource);
  final ImovelDataSource _dataSource;

  @override
  Future<Result<PaginaImoveis>> buscarImoveis(ConsultaImoveis consulta) async {
    try {
      final envelope = await _dataSource.buscar(consulta);
      return Result.success(envelope.paraPagina());
    } on Exception catch (erro) {
      return Result.failure(erro);
    }
  }
  ...
}
```
Copy verbatim shape: `try { ... return Result.success(...) } on Exception catch (erro) { return Result.failure(erro); }` is the project's single error-handling convention for repository impls — same pattern, no sealed-exception hierarchy needed (`core/result.dart` `Result<T>` sealed union, lines 1-13).

---

### `lib/data/mocks/imoveis_fixture.dart` (config, batch) — ALTERADO (D-24 variety)

**Analog:** itself, existing code. Wire-format row shape to replicate with new variety (lines 23-47):
```dart
{
  'id': 42,
  'titulo': 'Apartamento 2 quartos no Cambuí',
  'finalidade': 'VENDA',
  'preco_venda': '450000.00',
  'preco_aluguel': null,
  ...
  'bairro': 'Cambuí',
  'cidade': {'id': 1, 'nome': 'Campinas', 'uf': 'SP'},
  'caracteristicas': ['Portão eletrônico', 'Ar-condicionado', 'Varanda gourmet'],
  'natureza': 'APARTAMENTO',
  'quartos': 2, 'suites': 1, 'vagas': 1, 'area': '68.50',
}
```
Every added row must follow this exact key set (snake_case, wire format) since `ImoveisEnvelopeModel.fromJson` parses these maps directly. Note the deliberate empty-city convention (doc comment lines 6-8: "Indaiatuba fica intencionalmente sem nenhuma linha... exercita o estado vazio determinístico") — apply the same technique for D-22's "zero-result filter combination" (add a combination, e.g. a specific bairro+característica pairing, that intentionally matches zero rows).

---

### `lib/presentation/vitrine/vitrine_cubit.dart` (controller, event-driven) — ALTERADO

**Analog:** itself. **This is the most important pattern in the phase** — RESEARCH.md Pattern 2 is already concrete and directly derived from this file. Core reset mechanism to reuse, never reimplement (lines 193-242, `_aplicarConsulta`):
```dart
Future<void> _aplicarConsulta({
  required OrdenacaoVitrine ordenacao,
  required String? termoBusca,
}) async {
  final cidade = _cidade;
  if (cidade == null) return;

  final minhaVersao = ++_versaoConsulta;
  emit(state.copyWith(
    ordenacao: ordenacao,
    termoBusca: termoBusca,
    conteudo: const ConteudoVitrine.carregando(),
  ));

  final resultado = await _buscarImoveis(
    ConsultaImoveis(cidade: cidade, busca: termoBusca, ordenacao: ordenacao),
  );

  if (minhaVersao != _versaoConsulta || isClosed) return;

  switch (resultado) {
    case Success(:final data): ...
    case Failure(): emit(state.copyWith(conteudo: const ConteudoVitrine.erro()));
    case Loading(): break;
  }
}
```
Extend the method signature to accept `FiltrosVitrine filtros = const FiltrosVitrine()` (or read `state.filtros` as default, mirroring how `ordenacao`/`termoBusca` already default from `state`), and thread it into the `ConsultaImoveis(...)` constructor call. Add `aplicarFiltros`/`removerFiltro`/`limparFiltros` as thin delegations exactly like `ordenarPor` (lines 89-92):
```dart
Future<void> ordenarPor(OrdenacaoVitrine ordenacao) {
  if (ordenacao == state.ordenacao) return Future<void>.value();
  return _aplicarConsulta(ordenacao: ordenacao, termoBusca: state.termoBusca);
}
```
— i.e. `aplicarFiltros` should be a one-line delegate to `_aplicarConsulta`, never a duplicate reset flow (see RESEARCH.md Pitfall 2, already documents this exact risk against this exact file).

**Token-of-version obsolete-response guard** (line 215, repeated at line 150): `if (minhaVersao != _versaoConsulta || isClosed) return;` — copy verbatim for D-19 in every new reset-triggering method.

---

### `lib/presentation/vitrine/vitrine_state.dart` (model, transform) — ALTERADO

**Analog:** itself. Sealed `ConteudoVitrine` union pattern to extend with the new D-22 empty-state variant (lines 24-50):
```dart
@freezed
sealed class ConteudoVitrine with _$ConteudoVitrine {
  const factory ConteudoVitrine.carregando() = VitrineCarregando;
  const factory ConteudoVitrine.vazioNaCidade() = VitrineVaziaNaCidade;
  const factory ConteudoVitrine.semResultado(String termo) = VitrineSemResultado;
  const factory ConteudoVitrine.erro() = VitrineErro;
  const factory ConteudoVitrine.carregada({
    required List<Imovel> itens,
    String? proximaPagina,
    @Default(false) bool carregandoMais,
    @Default(false) bool erroAoCarregarMais,
  }) = VitrineCarregada;
}
```
Add a new variant (e.g. `const factory ConteudoVitrine.semResultadoComFiltros({String? termo, required FiltrosVitrine filtros}) = VitrineSemResultadoComFiltros;`) following the exact same factory-with-named-fields idiom; add `FiltrosVitrine filtros` as a new top-level `VitrineState` field alongside `ordenacao`/`termoBusca` (lines 13-17), since D-22's copy needs to distinguish "busca only," "filtros only," and "busca + filtros" — mirror how `VitrineCarregando`/`vazioNaCidade`/`semResultado`/`erro` already are mutually exclusive leaves of the same union consumed by `vitrine_screen.dart`'s exhaustive `switch`.

---

### `lib/presentation/vitrine/vitrine_screen.dart` (component, request-response) — ALTERADO

**Analog:** itself. Pattern for the controls row (already reserves the exact spot per D-10/D-15, lines 131-159):
```dart
Row(
  children: [
    Flexible(
      child: BlocSelector<VitrineCubit, VitrineState, OrdenacaoVitrine>(
        selector: (state) => state.ordenacao,
        builder: (context, ordenacao) {
          return OutlinedButton.icon(
            icon: const Icon(Icons.sort),
            label: Text('Ordenar: ${ordenacao.rotulo}', overflow: TextOverflow.ellipsis),
            onPressed: () {
              final cubit = context.read<VitrineCubit>();
              unawaited(mostrarOrdenacaoBottomSheet(
                context, atual: ordenacao, aoEscolher: cubit.ordenarPor,
              ));
            },
          );
        },
      ),
    ),
    const Spacer(), // reservado para o botão de filtros (Fase 3)
  ],
),
```
Replace the `const Spacer()` with the "Filtros (N)" button following the identical `BlocSelector` + `context.read<VitrineCubit>()` + `unawaited(mostrarXBottomSheet(...))` idiom. Add the active-chips row as a new `if (filtros.quantidadeAtiva > 0) ...` block directly below this `Row`, same `SizedBox(height: ...)` spacing convention used throughout the `build()` method. Extend the exhaustive `switch (conteudo)` (lines 181-259) with the new `VitrineSemResultadoComFiltros()` case, following the exact `Center(child: Padding(... Column(mainAxisSize: MainAxisSize.min, children: [Text(...), SizedBox(height: 16), TextButton(...)])))` shape already used by `VitrineSemResultado`/`VitrineErro`.

---

### `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart` (component, event-driven) — NOVO

**Analog:** `lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart` (full file, lines 1-70) for the sheet-opening/`showModalBottomSheet` scaffolding:
```dart
Future<void> mostrarOrdenacaoBottomSheet(
  BuildContext context, {
  required OrdenacaoVitrine atual,
  required ValueChanged<OrdenacaoVitrine> aoEscolher,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (contextDoSheet) {
      return SafeArea(
        child: ...,
      );
    },
  );
}
```
Note the doc comment convention to also copy (lines 22-25): `aoEscolher` must be captured from `context.read` on the SCREEN side before opening the sheet, since the modal route sits outside the vitrine's `BlocProvider` — the new sheet must accept `aplicados: FiltrosVitrine` and an `aoAplicar: ValueChanged<FiltrosVitrine>` callback the same way, rather than reading `VitrineCubit` from inside the sheet. D-07 requires `isScrollControlled: true` and `useSafeArea: true` (not present in this analog — `ordenacao_bottom_sheet.dart` uses only `showDragHandle` since it's a short single-column sheet); RESEARCH.md line 212 explicitly flags this delta. Fixed footer with "Limpar"/"Ver imóveis" has no direct analog in this codebase — build as a `Scaffold`-less `Column` with `Expanded(child: SingleChildScrollView(...))` + a non-scrolling bottom `Row` of two buttons, wrapped in the new `RascunhoFiltrosCubit`'s `BlocProvider`.

---

### `lib/presentation/vitrine/widgets/rascunho_filtros_cubit.dart` + `rascunho_filtros_state.dart` (controller, event-driven) — NOVO

**Analog:** `lib/presentation/vitrine/vitrine_cubit.dart` + `vitrine_state.dart` for the Cubit/freezed-state discipline (constructor-seeded initial state, `@injectable`-free since it's short-lived and constructed inline via `BlocProvider(create: (_) => RascunhoFiltrosCubit(filtrosAplicados))`), and `vitrine_cubit.dart`'s simple setter-method style (e.g. `buscar`/`limparBusca`) for the ~10 field setters (`definirFinalidade`, `alternarNatureza`, `definirQuartosMin`, etc.) — each setter does `emit(state.copyWith(...))` directly, no debounce/version-token needed here since nothing is dispatched until "Ver imóveis" (D-08). D-13's "trocar finalidade limpa a faixa de preço" rule belongs in `definirFinalidade`, clearing `precoMin`/`precoMax` in the same `copyWith` call.

---

### `lib/presentation/vitrine/widgets/chip_filtro_ativo.dart` (component, transform) — NOVO

**Analog:** `lib/presentation/vitrine/widgets/imovel_card.dart` — not read this session in full, but RESEARCH.md Pattern 9 (lines 567-586 of 03-RESEARCH.md) already gives concrete pure-function label helpers (`rotuloFaixaPreco`, `rotuloMultiSelecao`) to place alongside this widget; wrap them in a stateless `Widget` using `InputChip` (body tap opens sheet, `onDeleted` calls `VitrineCubit.removerFiltro` directly) — no existing `InputChip`/`Chip` usage in the codebase to copy structurally, so follow Material 3 `InputChip(label: ..., onDeleted: ..., onPressed: ...)` API directly.

---

### `lib/presentation/vitrine/widgets/mascara_numerica.dart` (utility, transform) — NOVO

**No analog found in codebase.** RESEARCH.md Pattern 5 (lines 478-509 of 03-RESEARCH.md) already provides the full concrete implementation (`MascaraMoeda extends TextInputFormatter`, using `intl.NumberFormat`) — use it directly as the primary source, since no `TextInputFormatter` subclass exists anywhere in `lib/` to copy from. The closest *disciplinary* precedent (same hand-rolled-over-package philosophy) is `Timer`-based `_debounce` in `vitrine_cubit.dart` (lines 28, 43-63) — small, self-contained, no extra dependency, per CLAUDE.md "Alternatives Considered."

---

## Shared Patterns

### Result/error handling
**Source:** `lib/core/result.dart` (lines 1-13) + `lib/data/repositories/imovel_repository_impl.dart` (lines 18-40)
**Apply to:** `opcoes_filtro_repository_impl.dart`, any new usecases
```dart
try {
  final envelope = await _dataSource.buscar(consulta);
  return Result.success(envelope.paraPagina());
} on Exception catch (erro) {
  return Result.failure(erro);
}
```

### Pagination-reset / obsolete-response token guard (D-19)
**Source:** `lib/presentation/vitrine/vitrine_cubit.dart` lines 193-215
**Apply to:** every new `VitrineCubit` method that changes applied filters (`aplicarFiltros`, `removerFiltro`, `limparFiltros`) — all must funnel through `_aplicarConsulta`, never reimplement the version-token/loading-emit/cursor-reset sequence.
```dart
final minhaVersao = ++_versaoConsulta;
emit(state.copyWith(conteudo: const ConteudoVitrine.carregando(), ...));
final resultado = await _buscarImoveis(...);
if (minhaVersao != _versaoConsulta || isClosed) return;
```

### DI registration
**Source:** `lib/data/datasources/imovel_mock_datasource.dart` line 48, `lib/data/repositories/imovel_repository_impl.dart` line 12, `lib/domain/usecases/obter_cidades_atendidas_usecase.dart` line 9
**Apply to:** `OpcoesFiltroMockDataSource` (`@LazySingleton(as: OpcoesFiltroDataSource)`), `OpcoesFiltroRepositoryImpl` (`@LazySingleton(as: OpcoesFiltroRepository)`), `ObterBairrosUseCase`/`ObterCaracteristicasUseCase` (`@injectable`) — then re-run `dart run build_runner build -d` to regenerate `injection.config.dart`.

### Text normalization for client-side option filtering (D-21)
**Source:** `lib/core/texto_normalizado.dart` (full file)
**Apply to:** `filtros_bottom_sheet.dart`'s bairro-search field — filters the already-loaded OPTIONS list only, never the imóvel acervo.
```dart
final opcoesVisiveis = todasAsOpcoes.where(
  (bairro) => normalizarTexto(bairro).contains(normalizarTexto(termoFiltro)),
).toList();
```

### Wire-format-only filtering/sorting (no business logic in presentation/domain)
**Source:** `lib/data/datasources/imovel_mock_datasource.dart` lines 115-146 (doc comment + `_paginar`)
**Apply to:** every new filter predicate (D-01..D-05) — must live inside `ImovelMockDataSource._paginar`'s `.where()` chain, operating on raw `Map<String, Object?>` wire rows, never in `VitrineCubit` or widgets.

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `lib/presentation/vitrine/widgets/mascara_numerica.dart` | utility | transform | No `TextInputFormatter` subclass exists anywhere in the codebase yet; RESEARCH.md Pattern 5 already supplies a complete implementation to use as the primary source instead of an in-repo analog. |
| Fixed-footer ("Limpar" / "Ver imóveis") full-screen bottom sheet shell | component | event-driven | `ordenacao_bottom_sheet.dart` is a short single-column, no-footer sheet (`showDragHandle` only, no `isScrollControlled`/`useSafeArea`) — structurally the closest available but does not cover the fixed-footer-over-scrollable-sections layout D-07 requires; build from Material 3 `showModalBottomSheet` docs directly. |

## Metadata

**Analog search scope:** `lib/` (all layers: `domain/`, `data/`, `presentation/vitrine/`), guided by CONTEXT.md §code_context "Reusable Assets"/"Established Patterns" and RESEARCH.md's Recommended Project Structure.
**Files scanned:** 16 existing `.dart` source files read directly this session (`consulta_imoveis.dart`, `parametros_consulta_imoveis.dart`, `imovel_mock_datasource.dart`, `ordenacao_bottom_sheet.dart`, `vitrine_cubit.dart`, `vitrine_state.dart`, `vitrine_screen.dart`, `imovel_repository.dart`, `imovel_repository_impl.dart`, `buscar_imoveis_usecase.dart`, `obter_cidades_atendidas_usecase.dart`, `ordenacao_vitrine.dart`, `result.dart`, `texto_normalizado.dart`, `imoveis_fixture.dart`) plus a full `find lib -name '*.dart'` inventory (50 files) for classification/completeness.
**Pattern extraction date:** 2026-09-30
