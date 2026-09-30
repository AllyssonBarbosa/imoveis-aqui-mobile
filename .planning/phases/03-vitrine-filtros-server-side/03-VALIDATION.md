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
| 3-TBD | TBD | TBD | FIL-01 | — | N/A | unit (mock) | `flutter test test/data/imovel_mock_datasource_test.dart` | ✅ | ⬜ pending |
| 3-TBD | TBD | TBD | FIL-01 | — | N/A | widget | `flutter test test/presentation/filtros_bottom_sheet_test.dart` | ❌ W0 | ⬜ pending |
| 3-TBD | TBD | TBD | FIL-02 | — | N/A | unit | `flutter test test/data/imovel_mock_datasource_test.dart test/data/parametros_consulta_imoveis_test.dart` | ⚠️ W0 (2nd file) | ⬜ pending |
| 3-TBD | TBD | TBD | FIL-03 | — | inline validation min>max blocks apply | unit + widget | `flutter test test/data/imovel_mock_datasource_test.dart test/presentation/filtros_bottom_sheet_test.dart` | ⚠️ W0 | ⬜ pending |
| 3-TBD | TBD | TBD | FIL-04 | — | N/A | unit | `flutter test test/data/imovel_mock_datasource_test.dart test/data/opcoes_filtro_mock_datasource_test.dart` | ⚠️ W0 | ⬜ pending |
| 3-TBD | TBD | TBD | FIL-05 | — | no client-side filtering | static | `! grep -rn "\.where(" lib/presentation lib/domain` | ✅ | ⬜ pending |
| 3-TBD | TBD | TBD | FIL-06 | — | N/A | bloc_test + widget | `flutter test test/presentation/vitrine_cubit_test.dart test/presentation/vitrine_screen_test.dart` | ✅ | ⬜ pending |

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
