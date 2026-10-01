---
phase: 03-vitrine-filtros-server-side
verified: 2026-10-01T02:05:30Z
status: human_needed
score: 10/10 must-haves verified
covered_files: [".planning/REQUIREMENTS.md", ".planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md", ".planning/phases/03-vitrine-filtros-server-side/03-01-PLAN.md", ".planning/phases/03-vitrine-filtros-server-side/03-01-SUMMARY.md", ".planning/phases/03-vitrine-filtros-server-side/03-02-PLAN.md", ".planning/phases/03-vitrine-filtros-server-side/03-02-SUMMARY.md", ".planning/phases/03-vitrine-filtros-server-side/03-03-PLAN.md", ".planning/phases/03-vitrine-filtros-server-side/03-03-SUMMARY.md", ".planning/phases/03-vitrine-filtros-server-side/03-04-PLAN.md", ".planning/phases/03-vitrine-filtros-server-side/03-04-SUMMARY.md", ".planning/phases/03-vitrine-filtros-server-side/03-05-PLAN.md", ".planning/phases/03-vitrine-filtros-server-side/03-05-SUMMARY.md", "lib/data/datasources/imovel_mock_datasource.dart", "lib/data/datasources/opcoes_filtro_datasource.dart", "lib/data/datasources/opcoes_filtro_mock_datasource.dart", "lib/data/datasources/parametros_consulta_imoveis.dart", "lib/data/mocks/imoveis_fixture.dart", "lib/data/repositories/opcoes_filtro_repository_impl.dart", "lib/di/injection.config.dart", "lib/domain/entities/consulta_imoveis.dart", "lib/domain/entities/filtros_vitrine.dart", "lib/domain/entities/filtros_vitrine.freezed.dart", "lib/domain/repositories/opcoes_filtro_repository.dart", "lib/domain/usecases/obter_bairros_usecase.dart", "lib/domain/usecases/obter_caracteristicas_usecase.dart", "lib/presentation/cidade_selecao/cidade_selecao_screen.dart", "lib/presentation/vitrine/apresentacao_filtros.dart", "lib/presentation/vitrine/opcoes_filtro_cubit.dart", "lib/presentation/vitrine/opcoes_filtro_state.dart", "lib/presentation/vitrine/opcoes_filtro_state.freezed.dart", "lib/presentation/vitrine/rascunho_filtros_cubit.dart", "lib/presentation/vitrine/sessao_filtros_vitrine.dart", "lib/presentation/vitrine/vitrine_cubit.dart", "lib/presentation/vitrine/vitrine_screen.dart", "lib/presentation/vitrine/vitrine_state.dart", "lib/presentation/vitrine/vitrine_state.freezed.dart", "lib/presentation/vitrine/widgets/chips_filtros_ativos.dart", "lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart", "lib/presentation/vitrine/widgets/mascara_numerica.dart", "test/data/imovel_mock_datasource_test.dart", "test/data/opcoes_filtro_mock_datasource_test.dart", "test/data/opcoes_filtro_repository_impl_test.dart", "test/data/parametros_consulta_imoveis_test.dart", "test/domain/filtros_vitrine_test.dart", "test/presentation/apresentacao_filtros_test.dart", "test/presentation/filtros_bottom_sheet_test.dart", "test/presentation/mascara_numerica_test.dart", "test/presentation/opcoes_filtro_cubit_test.dart", "test/presentation/rascunho_filtros_cubit_test.dart", "test/presentation/sessao_filtros_vitrine_test.dart", "test/presentation/vitrine_cubit_test.dart", "test/presentation/vitrine_fluxo_test.dart", "test/presentation/vitrine_screen_test.dart"]
covered_digest: "v1:sha256:a02079dec195555f305f8f876250b46627b2a437cb539b93a2101a21f52d3486"
behavior_unverified: 0
overrides_applied: 0
behavior_unverified_items: []
human_verification:
  - test: "No emulador Android e no simulador iOS (incluindo largura classe 360dp), na vitrine de Campinas: (1) olhar a linha abaixo da SearchBar (botões 'Ordenar'/'Filtros' e a linha de chips); (2) abrir Filtros e rolar o sheet inteiro; (3) escolher Venda, digitar uma faixa de preço no teclado numérico, depois trocar para Aluguel; (4) digitar Mínimo 300.000 e Máximo 250.000 em Área; (5) escolher Casa + Apartamento, '2+' quartos, um bairro via 'Filtrar bairros' e Piscina; aplicar; (6) tocar o corpo de um chip, depois o 'x' de um chip, depois 'Limpar filtros'; (7) aplicar Terreno + '1+' quartos, depois também digitar um termo de busca; (8) aplicar Venda + um bairro e trocar de cidade pelo cabeçalho; (9) fechar o app completamente e reabri-lo."
    expected: "(1) 'Ordenar: …' e 'Filtros' lado a lado numa linha (D-15), linha de chips só quando há filtro ativo; (2) sheet em tela cheia, Material 3 verde/branco, seções roláveis com o rodapé 'Limpar'/'Ver imóveis' sempre visível, inclusive acima do teclado (D-07); (3) campos de preço desabilitados até escolher finalidade, máscara estilo 'R$ 250.000', trocar para Aluguel limpa os campos e mostra '/mês' (D-03, D-09, D-13); (4) erro inline sob Máximo e 'Ver imóveis' desabilitado (D-12); (5) a lista recarrega do topo uma vez, chips como 'Casa, Apto', '2+ quartos', 'Cambuí', 'Piscina' e botão 'Filtros (N)'; (6) corpo do chip reabre o sheet com os valores aplicados, 'x' reconsulta na hora, 'Limpar filtros' preserva texto de busca e ordenação (D-17, D-18); (7) 'Nenhum imóvel com esses filtros', depois a mensagem citando a busca e 'Limpar busca e filtros' (D-22); (8) Venda mantido, chip de bairro sumiu, lista da nova cidade já filtrada (D-14); (9) reabre na cidade salva sem filtros (D-23)."
    why_human: "Fidelidade visual Material 3/paleta verde-branco, ergonomia do sheet em tela cheia com o teclado, sensação de digitação das máscaras numéricas e o layout em 360dp exigem os olhos do usuário num aparelho/simulador real — testes de widget verificam estrutura/texto/comportamento, não aparência visual final. Item embutido em 03-05-PLAN.md Task 2 `<verify><human-check>` (workflow.human_verify_mode: end-of-phase), colhido aqui."
advisory:
  - finding: "`formatarValorCompacto` (lib/presentation/vitrine/apresentacao_filtros.dart:142-150) mostra 'R$ 1.000 mil' em vez de '1 mi' para valores entre 999.950 e 999.999 digitados no campo Máximo de preço — o bucket 'mil'/'mi' é escolhido pelo valor bruto, mas o arredondamento de uma casa decimal acontece depois, dentro do bucket errado."
    category: other
    reason: "Confirmado por leitura direta do código (reproduz a análise de 03-REVIEW.md WR-01); bug de exibição em caso de borda, não bloqueia nenhum must-have da fase (filtro de preço em si funciona corretamente via query params/servidor simulado) — ainda não corrigido no HEAD atual."
    evidence_status: "reproduced by direct code read; not covered by a regression test yet"
---

# Phase 3: Vitrine — Filtros Server-Side Verification Report

**Phase Goal:** O visitante refina a vitrine com o conjunto completo de filtros de APP03, todos resolvidos no servidor (ainda sobre mock), com chips ativos e paginação sempre consistente ao mudar filtro ou ordenação.
**Verified:** 2026-10-01T02:05:30Z
**Status:** human_needed
**Re-verification:** No — initial verification

**Note on `Mode: mvp`:** ROADMAP.md tags this phase `Mode: mvp`, but the phase Goal is written in the standard goal/Success-Criteria prose used by all four phases in this roadmap, not the `As a ..., I want to ..., so that ....` user-story format (confirmed via `user-story.validate` — `valid: false`). The verification brief for this run explicitly points at "ROADMAP.md Phase 3 Success Criteria," so standard goal-backward verification was applied against those 5 Success Criteria rather than MVP Mode's User Flow Coverage table. Flagged as an informational note, not a blocker — Phases 1 and 2 use the identical pattern.

## Goal Achievement

### Observable Truths (ROADMAP Success Criteria)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | O visitante filtra por finalidade (venda/aluguel) e natureza (casa/apartamento/terreno/lote) num modal de filtros | ✓ VERIFIED | `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart` has `SegmentedButton` (Qualquer/Venda/Aluguel) and 4 `FilterChip`s for natureza; `lib/data/datasources/imovel_mock_datasource.dart:264-282` applies finalidade (inclusive of VENDA_E_ALUGUEL) and natureza (OU) server-side; e2e `test/presentation/vitrine_fluxo_test.dart` passes |
| 2 | O visitante filtra por faixa de preço, quartos, suítes, vagas, bairro, faixa de área e características | ✓ VERIFIED | All 7 dimensions present in `_linhaCasaComFiltros` (`imovel_mock_datasource.dart:284-340`): price by finalidade, quartos/suítes/vagas via `>=` (never `==`), bairro via OU/`normalizarTexto`, área range, características via AND (`every`); sheet sections confirmed in `filtros_bottom_sheet.dart` (Preço, Área, Quartos/Suítes/Vagas `_SeletorMinimo`, Bairros `ExpansionTile`+`CheckboxListTile`, Características `FilterChip`); options for bairro/características come from `OpcoesFiltroMockDataSource` deriving from `linhasAcervoFixture()` (no fixed list, D-20) |
| 3 | Filtros ativos aparecem como chips acima da lista, com opções de aplicar e limpar tudo | ✓ VERIFIED | `lib/presentation/vitrine/widgets/chips_filtros_ativos.dart` renders `InputChip` per active filter (9 label formats confirmed in `apresentacao_filtros.dart`) + `ActionChip` 'Limpar filtros'; sheet footer has 'Limpar' (draft only) / 'Ver imóveis' (apply); `FiltrosVitrine.ativos`/`quantidadeAtiva` is the single source for both the button count and the chips (confirmed by direct read of `filtros_vitrine.dart`) |
| 4 | Mudar filtro ou ordenação reseta a paginação — sem cards duplicados ou embaralhados | ✓ VERIFIED (behavioral) | `grep -c "++_versaoConsulta" lib/presentation/vitrine/vitrine_cubit.dart` = 1 (single reset path); ran the single named test `filtros A em voo é descartado quando filtros B já resolveu — só o resultado de B chega a ser emitido (D-19)` in `test/presentation/vitrine_cubit_test.dart` directly — **PASS**; also ran `carregarMais() em voo é descartado quando os filtros mudam antes de resolver` — version-token discard of both a stale first page and a stale in-flight "load more" is exercised, not just asserted by the plan |
| 5 | Toda a filtragem é resolvida pela camada de dados (mock hoje, honrando o contrato da Fase 1) — o app nunca filtra o acervo localmente no aparelho | ✓ VERIFIED | All 5 phase-level grep gates re-run directly against current HEAD, all 0 matches: no `Mock[D]ataSource`/`linhasAcervo[F]ixture` reference in `lib/presentation`/`lib/domain`; no `itens.(where|sort|retainWhere|removeWhere)`; no `.where(`/`.sort(` in the 4 vitrine Cubits; no `join(',')` outside `data/`; no `SharedPreferences`/`shared_preferences` in `lib/presentation/vitrine` |

**Score:** 5/5 ROADMAP Success Criteria verified, 0 present-but-behavior-unverified.

### Observable Truths (Plan-Level Must-Haves, Supporting Detail)

| # | Truth (abbreviated) | Plan | Status | Evidence |
|---|---|---|---|---|
| 6 | Finalidade tracer ponta a ponta (sheet → rascunho → VitrineCubit → query params → mock), VENDA_E_ALUGUEL inclusivo | 03-01 | ✓ VERIFIED | `_linhaCasaComFiltros` lines 264-275; `finalidadeDoParametro` rejects VENDA_E_ALUGUEL as a filter value (`parametros_consulta_imoveis.dart:121-132`) |
| 7 | Multivalores (natureza/bairro/características) viajam como CSV numa chave, só em `data/`; OU/OU/E corretos | 03-02 | ✓ VERIFIED | CSV construction confirmed only in `parametros_consulta_imoveis.dart`; grep gate `join(',')` outside `data/` = 0 matches; predicates match D-04/D-05 exactly |
| 8 | Fixture com variedade determinística (D-24) e combinação zero-resultado Terreno+quartos_min=1 | 03-02 | ✓ VERIFIED | Confirmed via SUMMARY coverage + full `flutter test` pass (includes the fixture-variety assertions) |
| 9 | Faixa de preço depende de finalidade (D-03), faixa de área independente, 400 simulado para faixa invertida/preço sem finalidade (D-12) | 03-03 | ✓ VERIFIED | `parametros_consulta_imoveis.dart:193-237` throws `FormatException` for price-without-finalidade and inverted ranges; `mascara_numerica.dart`/`rascunho_filtros_cubit.dart` provide client-side inline validation as a UX aid, never a substitute |
| 10 | SessaoFiltrosVitrine: filtros sobrevivem à troca de cidade sem bairros, só em memória do processo (D-14, D-23) | 03-05 | ✓ VERIFIED | Direct read of `sessao_filtros_vitrine.dart` confirms in-memory-only fields, `filtrosPara` clears `bairros` for a different `chaveNatural`; ran the single named e2e test `trocar para Valinhos pelo cabeçalho` directly — **PASS** |

**Combined score:** 10/10 must-haves verified (5 roadmap SC + 5 representative plan-level truths spanning all 5 plans); 0 present-but-behavior-unverified; 0 overrides applied.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/domain/entities/filtros_vitrine.dart` | `FiltrosVitrine` (freezed), `FinalidadeFiltro`, `FiltroAtivo`, `ativos`/`quantidadeAtiva`/`semFiltro` | ✓ VERIFIED | Read in full — matches spec exactly, including D-03 price-clear-on-finalidade-removal |
| `lib/data/datasources/parametros_consulta_imoveis.dart` | CSV mapping + `_min`/range parsers + D-03/D-12 validation | ✓ VERIFIED | `FormatException` for every documented malformed case, confirmed by direct read |
| `lib/data/datasources/imovel_mock_datasource.dart` | `_linhaCasaComFiltros` over 9 dimensions, nulls-last ordering by `preco_aluguel` under Aluguel | ✓ VERIFIED | Full predicate block read; matches D-01/D-02/D-03/D-04/D-05 |
| `lib/data/datasources/opcoes_filtro_mock_datasource.dart` | Derives bairro/característica options from `linhasAcervoFixture()`, no fixed list (D-20) | ✓ VERIFIED | `linhasAcervoFixture()` call confirmed at line 19 |
| `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart` | Full-screen sheet, fixed footer, all 9 sections | ✓ VERIFIED | Exists, referenced consistently across all 5 SUMMARYs, all acceptance-criteria greps from each PLAN re-verified true by the executors' own self-checks and spot-read |
| `lib/presentation/vitrine/widgets/chips_filtros_ativos.dart` | `InputChip`/`ActionChip` row | ✓ VERIFIED | Exists |
| `lib/presentation/vitrine/sessao_filtros_vitrine.dart` | `@lazySingleton`, `lembrar`/`filtrosPara`, in-memory only | ✓ VERIFIED | Read in full, matches spec |
| `lib/presentation/vitrine/vitrine_cubit.dart` | `aplicarFiltros`/`removerFiltro`/`limparFiltros`/`limparBuscaEFiltros` reaching the single reset path | ✓ VERIFIED | `++_versaoConsulta` appears exactly once; `SessaoFiltrosVitrine` wired as 2nd constructor arg |
| `lib/domain/repositories/opcoes_filtro_repository.dart` + usecases + `opcoes_filtro_repository_impl.dart` | Swappable mock→Dio boundary for options (D-20) | ✓ VERIFIED | Files exist, mirror `ImovelRepository` triad per SUMMARY and file listing |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `vitrine_screen.dart` | `filtros_bottom_sheet.dart` | `mostrarFiltrosBottomSheet(aplicados:, aoAplicar:, opcoes:)` | ✓ WIRED | Confirmed via grep across plan acceptance criteria and self-checks |
| `vitrine_cubit.dart` | `consulta_imoveis.dart` | `_aplicarConsulta` builds `ConsultaImoveis(filtros:)`, never filters items itself | ✓ WIRED | Confirmed — no `.where`/`.sort` in the 4 vitrine Cubits (grep gate 0 matches) |
| `imovel_mock_datasource.dart` | `parametros_consulta_imoveis.dart` | `filtrosDosParametros` is the only filter-parsing path | ✓ WIRED | Confirmed by direct read of `_montarPagina`/`_paginarPelosParametros` |
| `vitrine_cubit.dart` | `sessao_filtros_vitrine.dart` | `carregar(cidade)` → `filtrosPara(cidade)`; `_aplicarConsulta` → `lembrar(cidade, filtros)` | ✓ WIRED | Confirmed by direct read — `lembrar` called synchronously before the loading emit, matching the plan's "always reflects the last triggered query" requirement |
| `filtros_bottom_sheet.dart` | `opcoes_filtro_cubit.dart` | Bairros/Características sections switch over `OpcoesFiltroState` | ✓ WIRED | Confirmed present in sheet per 03-04/03-05 SUMMARYs and full test suite pass |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Stale filter response discarded, in-flight `carregarMais` discarded on filter change (D-19) | `flutter test test/presentation/vitrine_cubit_test.dart --plain-name "filtros A em voo é descartado quando filtros B já resolveu"` | 1 test passed | ✓ PASS |
| Filters survive city switch minus bairros, session-only (D-14/D-23) | `flutter test test/presentation/vitrine_fluxo_test.dart --plain-name "trocar para Valinhos pelo cabeçalho"` | 1 test passed | ✓ PASS |
| Full workspace suite (run once) | `flutter test` | 382 tests, "All tests passed!" | ✓ PASS |
| Static analysis | `flutter analyze` | "No issues found!" | ✓ PASS |
| FIL-05 static gates (5 greps) | see Truth 5 above | all 0 matches | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan(s) | Description | Status | Evidence |
|-------------|-----------------|--------------|--------|----------|
| FIL-01 | 03-01 | Filtro por finalidade (venda/aluguel) | ✓ SATISFIED | e2e + unit + mock tests, direct code read |
| FIL-02 | 03-02 | Filtro por natureza | ✓ SATISFIED | e2e + mock tests, direct code read |
| FIL-03 | 03-02, 03-03 | Faixas de preço, quartos, suítes, vagas | ✓ SATISFIED | mock + widget + e2e tests, direct code read |
| FIL-04 | 03-02, 03-03, 03-04, 03-05 | Bairro, faixa de área, características | ✓ SATISFIED | mock + widget + e2e tests across 4 plans, direct code read |
| FIL-05 | 03-01..03-05 | Filtragem resolvida no servidor, nunca localmente | ✓ SATISFIED | 5 static grep gates re-run directly, all 0 matches |
| FIL-06 | 03-01, 03-05 | Chips ativos, aplicar/limpar, reset de paginação | ✓ SATISFIED | chips widget, behavioral spot-check of version-token discard |

No orphaned requirements: REQUIREMENTS.md maps exactly FIL-01..FIL-06 to Phase 3, and the union of every plan's `requirements:` frontmatter field covers all six.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `lib/presentation/vitrine/apresentacao_filtros.dart` | 142-150 | `formatarValorCompacto` mis-renders `[999950, 999999]` as "1.000 mil" instead of "1 mi" (confirmed by direct read, matches 03-REVIEW.md WR-01) | Warning | Cosmetic display bug reachable from real user input (Máximo price field); does not affect actual server-side filtering, only the compact chip/range label text; not yet fixed on HEAD |
| `lib/data/datasources/imovel_mock_datasource.dart` | 85-91 | Dead `try`/`on FormatException { rethrow; }` around `Uri.parse` (03-REVIEW.md IN-01) | Info | No behavioral effect, code-quality nit |
| `lib/data/datasources/parametros_consulta_imoveis.dart` | 69-81, 150-161 | Documented, unmitigated CSV-comma collision risk for bairro/características (03-REVIEW.md IN-02) | Info | Explicitly out-of-scope for this phase per the code's own doc comment; tracked for Phase 4's Django implementation |
| `lib/presentation/vitrine/apresentacao_filtros.dart` | 130-136 | Chip label for multi-select depends on `Set` insertion order, undocumented as intentional (03-REVIEW.md IN-03) | Info | No functional bug today, latent regression risk on a future refactor |

No debt markers (`TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/`PLACEHOLDER`) found in any phase-touched file (the one `TODO`-pattern grep hit was a false positive on the Portuguese word "TODOS").

### Human Verification Required

#### 1. End-of-phase device check (Material 3 fidelity, keyboard/mask ergonomics, full filter lifecycle)

**Test:** On an Android emulator and an iOS simulator (360dp-class width included), in Campinas: (1) look at the row under the SearchBar; (2) open Filtros and scroll the whole sheet; (3) pick Venda, type a price range with the numeric keyboard, then switch to Aluguel; (4) type Mínimo 300.000 and Máximo 250.000 in Área; (5) choose Casa + Apartamento, '2+' quartos, a bairro via 'Filtrar bairros', and Piscina; apply; (6) tap a chip body, then a chip "x", then 'Limpar filtros'; (7) apply Terreno + '1+' quartos, then also type a search term; (8) apply Venda + a bairro and switch city in the header; (9) close the app completely and reopen it.

**Expected:** Full-screen Material 3 green/white sheet with always-visible footer above the keyboard; masked price fields disabled until finalidade chosen, cleared on finalidade switch with '/mês' suffix under Aluguel; inline error blocking apply on inverted ranges; one reload from the top per apply with correctly-labeled chips; chip body/x/Limpar-filtros semantics preserved; city switch keeps general filters minus bairro; filters never survive an app restart.

**Why human:** Visual Material 3/palette fidelity, full-screen sheet ergonomics with the keyboard, numeric-mask typing feel, and 360dp layout require a human's eyes on a real device/simulator — widget tests verify structure/text/behavior, not final visual appearance. This item is embedded in `03-05-PLAN.md` Task 2's `<verify><human-check>` block (`workflow.human_verify_mode: end-of-phase`) and is harvested here per the standard end-of-phase sink, not re-run as an automated check.

### Gaps Summary

No gaps. All 5 ROADMAP Success Criteria and all plan-level must-haves are backed by direct code reads and/or passing automated tests (including two behavior-dependent invariants re-run as single named tests, not just claimed by SUMMARYs). All 5 static FIL-05 grep gates were re-executed directly against the current HEAD and returned zero matches. The full `flutter test` (382 tests) and `flutter analyze` were re-run directly and are green, matching but not merely trusting the SUMMARYs' claims.

The phase is blocked from `passed` status only by the single embedded end-of-phase human-check (device/visual verification), which is a deliberate, planned deferral (`workflow.human_verify_mode: end-of-phase`), not a code defect. One pre-existing, already-documented display-bug (WR-01, `formatarValorCompacto`) remains unfixed and is carried forward as an advisory finding — it does not block any must-have truth.

---

_Verified: 2026-10-01T02:05:30Z_
_Verifier: Claude (gsd-verifier)_
