---
phase: "2"
slug: "vitrine-lista-busca-e-ordena-o"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-09-25"
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (bundled) + `bloc_test` ^10.0.0 + `mocktail` ^1.0.5 (+ `fake_async` for debounce) |
| **Config file** | none — default `flutter test` |
| **Quick run command** | `flutter test test/presentation/vitrine_cubit_test.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~60 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/presentation/vitrine_cubit_test.dart` (plus the task's own test file)
- **After every plan wave:** Run `flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 2-TBD | TBD | TBD | VIT-01 | — | N/A | unit (blocTest) | `flutter test test/presentation/vitrine_cubit_test.dart` | ❌ W0 | ⬜ pending |
| 2-TBD | TBD | TBD | VIT-02 | — | N/A | widget | `flutter test test/presentation/imovel_card_test.dart` | ❌ W0 | ⬜ pending |
| 2-TBD | TBD | TBD | VIT-03 | — | N/A | unit (blocTest + fake_async) | `flutter test test/presentation/vitrine_cubit_test.dart` | ❌ W0 | ⬜ pending |
| 2-TBD | TBD | TBD | VIT-04 | — | N/A | unit (blocTest) | `flutter test test/presentation/vitrine_cubit_test.dart` | ❌ W0 | ⬜ pending |
| 2-TBD | TBD | TBD | VIT-05 | — | N/A | unit (blocTest) | `flutter test test/presentation/vitrine_cubit_test.dart` | ❌ W0 | ⬜ pending |
| 2-TBD | TBD | TBD | VIT-06 | — | N/A | unit | `flutter test test/data/cidade_remote_datasource_test.dart` | ❌ W0 | ⬜ pending |
| 2-TBD | TBD | TBD | API-04 | — | N/A | unit | `flutter test test/data/imovel_repository_impl_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

*Task IDs are filled in by the planner/executor once PLAN.md files exist.*

---

## Wave 0 Requirements

- [ ] `test/presentation/vitrine_cubit_test.dart` — VIT-01, VIT-03, VIT-04, VIT-05
- [ ] `test/presentation/imovel_card_test.dart` — VIT-02
- [ ] `test/data/cidade_remote_datasource_test.dart` — VIT-06
- [ ] `test/data/imovel_repository_impl_test.dart` — API-04
- [ ] `test/data/imovel_mock_datasource_test.dart` — D-14/D-15 (deterministic error/empty triggers, nulls-last ordering, title+bairro search)
- [ ] `fake_async` dev dependency (`flutter pub add --dev fake_async`)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| `GET /api/publico/cidades/` returns 200 without a token, served cities only | API-02 | Django endpoint lives in sibling repo `../imoveis-aqui/Web`, outside `flutter test` | Run Django dev server; `curl -i http://localhost:8000/api/publico/cidades/` → 200, JSON `results` only with cities served by at least one company |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
