---
phase: "3"
slug: "vitrine-filtros-server-side"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-09-30"
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (SDK) + `bloc_test ^10.0.0` + `mocktail ^1.0.5` (já instalados desde F1/F2) |
| **Config file** | none — `flutter test` roda `test/**_test.dart` por convenção |
| **Quick run command** | `flutter test test/data/imovel_mock_datasource_test.dart test/presentation/vitrine_cubit_test.dart` |
| **Full suite command** | `flutter test && flutter analyze` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test <arquivos tocados pela task>`
- **After every plan wave:** Run `flutter test && flutter analyze`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 3-01-T1 | 03-01 | 1 | FIL-01 | T-03-01-01 | unknown finalidade -> FormatException -> error state | unit (mock) + widget + e2e | `flutter test test/presentation/vitrine_fluxo_test.dart test/data/imovel_mock_datasource_test.dart test/domain/filtros_vitrine_test.dart test/presentation/rascunho_filtros_cubit_test.dart test/presentation/filtros_bottom_sheet_test.dart` | ❌ W0 (created in task) | ⬜ pending |
| 3-01-T2 | 03-01 | 1 | FIL-06 | T-03-01-02 | stale responses discarded (version token) | bloc_test + widget + e2e | `flutter test test/domain/filtros_vitrine_test.dart test/presentation/apresentacao_filtros_test.dart test/presentation/vitrine_cubit_test.dart test/presentation/vitrine_screen_test.dart test/presentation/vitrine_fluxo_test.dart` | ⚠️ (apresentacao test new) | ⬜ pending |
| 3-02-T1 | 03-02 | 2 | FIL-02, FIL-03, FIL-04 | T-03-02-01 | malformed CSV/min -> FormatException | unit | `flutter test test/data/parametros_consulta_imoveis_test.dart test/data/imovel_mock_datasource_test.dart` | ❌ W0 (parametros test created in task) | ⬜ pending |
| 3-02-T2 | 03-02 | 2 | FIL-02, FIL-03 | — | N/A | widget + e2e | `flutter test test/presentation/rascunho_filtros_cubit_test.dart test/presentation/filtros_bottom_sheet_test.dart test/presentation/vitrine_fluxo_test.dart` | ✅ | ⬜ pending |
| 3-02-T3 | 03-02 | 2 | FIL-05 (contract) | — | N/A | static (doc) | `grep -n "## 10. Adendos da Fase 3" .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` | ✅ | ⬜ pending |
| 3-03-T1 | 03-03 | 3 | FIL-03, FIL-04 | T-03-03-01 | inverted/malformed range, price without finalidade -> FormatException | unit | `flutter test test/data/parametros_consulta_imoveis_test.dart test/data/imovel_mock_datasource_test.dart` | ✅ | ⬜ pending |
| 3-03-T2 | 03-03 | 3 | FIL-03, FIL-04 | T-03-03-03 | inline validation min>max blocks apply | unit + widget + e2e | `flutter test test/presentation/mascara_numerica_test.dart test/presentation/rascunho_filtros_cubit_test.dart test/presentation/filtros_bottom_sheet_test.dart test/presentation/vitrine_fluxo_test.dart` | ❌ (mascara test created in task) | ⬜ pending |
| 3-04-T1 | 03-04 | 4 | FIL-04 | T-03-04-02 | options failure -> falha state + retry | unit + bloc_test | `flutter test test/data/opcoes_filtro_mock_datasource_test.dart test/data/opcoes_filtro_repository_impl_test.dart test/presentation/opcoes_filtro_cubit_test.dart` | ❌ W0 (created in task) | ⬜ pending |
| 3-04-T2 | 03-04 | 4 | FIL-04 | T-03-04-04 | N/A | widget + e2e | `flutter test test/presentation/apresentacao_filtros_test.dart test/presentation/rascunho_filtros_cubit_test.dart test/presentation/filtros_bottom_sheet_test.dart test/presentation/vitrine_screen_test.dart test/presentation/vitrine_fluxo_test.dart` | ✅ | ⬜ pending |
| 3-05-T1 | 03-05 | 5 | FIL-04 | — | N/A | widget + e2e | `flutter test test/presentation/rascunho_filtros_cubit_test.dart test/presentation/filtros_bottom_sheet_test.dart test/presentation/vitrine_fluxo_test.dart` | ✅ | ⬜ pending |
| 3-05-T2 | 03-05 | 5 | FIL-05, FIL-06 | T-03-05-01, T-03-05-03 | no client-side filtering, no persisted filters | static + unit + e2e | `flutter test && flutter analyze` plus the grep gates of 03-05 Task 2 (acervo filtering/sorting on `itens`, simulated-server references, CSV assembly outside data/, device-preferences usage) — the original draft gate `! grep -rn "\.where(" lib/presentation lib/domain` is superseded because it already matches legitimate non-acervo code (`imovel_card.dart` text joining, the D-21 option filter) | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

*Task IDs are filled in by the planner/executor once PLAN.md files exist.*

---

## Wave 0 Requirements

- [ ] `test/presentation/filtros_bottom_sheet_test.dart` — FIL-01 (SegmentedButton), FIL-03 (validação inline), D-07/D-08, D-13
- [ ] `test/data/parametros_consulta_imoveis_test.dart` — mapeamento CSV/`_min`/preço-por-finalidade isolado
- [ ] `test/data/opcoes_filtro_mock_datasource_test.dart` — FIL-04 (fonte de bairros/características, D-20)
- [ ] `test/presentation/rascunho_filtros_cubit_test.dart` — D-08/D-13 (se o rascunho for Cubit)

*Framework install: none — `bloc_test`/`mocktail` já instalados.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Visual do modal de filtros (Material 3, paleta verde/branco, rodapé fixo) em aparelho | FIL-01..FIL-04 | Aparência/ergonomia não é assertável em widget test | Rodar o app, abrir filtros, conferir layout, scroll e rodapé fixo |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
