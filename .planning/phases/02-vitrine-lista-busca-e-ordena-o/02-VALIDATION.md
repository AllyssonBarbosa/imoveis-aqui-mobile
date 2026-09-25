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
| 02-01-T1 | 02-01 | 1 | VIT-01, API-04 | T-02-01-03, T-02-01-04 | UI/Cubit/domain never hold the full acervo; no emit after close | e2e widget + blocTest + unit | `flutter test test/presentation/vitrine_fluxo_test.dart test/presentation/vitrine_cubit_test.dart test/data/imovel_repository_impl_test.dart test/data/imovel_mock_datasource_test.dart` | ❌ W0 (created by the task) | ⬜ pending |
| 02-01-T2 | 02-01 | 1 | VIT-02 | T-02-01-02 | bad price/URL never breaks the card layout | unit + widget | `flutter test test/presentation/apresentacao_imovel_test.dart test/presentation/imovel_card_test.dart` | ❌ W0 (created by the task) | ⬜ pending |
| 02-02-T1 | 02-02 | 1 | API-02 | T-02-02-01..05, T-02-02-07 | served-only queryset, id/nome/uf allowlist, read-only, DEBUG-only seed, no unauthorized commit | Django TestCase | `cd ../imoveis-aqui/Web && DATABASE_URL="sqlite://:memory:" .venv/bin/python manage.py test empresas --noinput` | ❌ W0 (created by the task) | ⬜ pending |
| 02-02-T2 | 02-02 | 1 | API-02 | — | N/A (contract doc) | grep | `grep -n "Adendos da Fase 2" .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` | n/a | ⬜ pending |
| 02-03-T1 | 02-03 | 2 | VIT-05, API-04 | T-02-03-02 | malformed cursor -> failure, never a crash; mock stateless | unit | `flutter test test/data/imovel_mock_datasource_test.dart` | ✅ (from 02-01-T1, extended) | ⬜ pending |
| 02-03-T2 | 02-03 | 2 | VIT-05 | T-02-03-01, T-02-03-04 | single request per cursor; no auto-retry loop | unit (blocTest) | `flutter test test/presentation/vitrine_cubit_test.dart` | ✅ (extended) | ⬜ pending |
| 02-03-T3 | 02-03 | 2 | VIT-05 | — | N/A | widget + e2e | `flutter test test/presentation/vitrine_screen_test.dart test/presentation/vitrine_fluxo_test.dart` | ❌ W0 (vitrine_screen_test created by the task) | ⬜ pending |
| 02-04-T1 | 02-04 | 2 | VIT-06 | T-02-04-02, T-02-04-03, T-02-04-04 | next followed only on the API origin; timeouts; typed parsing | unit (fake HttpClientAdapter) | `flutter test test/data/cidade_remote_datasource_test.dart` | ❌ W0 (created by the task) | ⬜ pending |
| 02-04-T2 | 02-04 | 2 | VIT-06 | T-02-04-01 | cleartext only in debug; iOS local networking only | unit + widget + manifest/plist checks | `flutter test test/domain/validar_cidade_atendida_usecase_test.dart test/presentation/cidade_selecao_screen_test.dart` | ✅ (updated) | ⬜ pending |
| 02-05-T1 | 02-05 | 3 | VIT-03, VIT-04 | T-02-05-03 | unknown ordenacao rejected | unit | `flutter test test/core/texto_normalizado_test.dart test/data/imovel_mock_datasource_test.dart` | ❌ W0 (texto_normalizado_test created by the task) | ⬜ pending |
| 02-05-T2 | 02-05 | 3 | VIT-03 | T-02-05-01, T-02-05-02 | debounce bounds request volume; term opaque to the app | unit (fake_async) + widget + e2e | `flutter test test/presentation/vitrine_cubit_test.dart test/presentation/vitrine_screen_test.dart test/presentation/vitrine_fluxo_test.dart` | ✅ (extended) | ⬜ pending |
| 02-05-T3 | 02-05 | 3 | VIT-04 | T-02-05-03 | closed enum of orderings | widget + blocTest + e2e | `flutter test test/presentation/ordenacao_bottom_sheet_test.dart test/presentation/vitrine_cubit_test.dart test/presentation/vitrine_fluxo_test.dart` | ❌ W0 (ordenacao_bottom_sheet_test created by the task) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

*Task IDs follow `{plan}-T{n}` and match the `<task>` order inside each PLAN.md.*

---

## Wave 0 Requirements

- [ ] `test/presentation/vitrine_cubit_test.dart` — VIT-01, VIT-03, VIT-04, VIT-05 (created by 02-01-T1, extended by 02-03-T2, 02-05-T2/T3)
- [ ] `test/presentation/imovel_card_test.dart` — VIT-02 (02-01-T2)
- [ ] `test/data/cidade_remote_datasource_test.dart` — VIT-06 (02-04-T1)
- [ ] `test/data/imovel_repository_impl_test.dart` — API-04 (02-01-T1)
- [ ] `test/data/imovel_mock_datasource_test.dart` — D-14/D-15 (created by 02-01-T1; cursor/fixture in 02-03-T1; search/nulls-last/"erro" trigger in 02-05-T1)
- [ ] `test/presentation/vitrine_fluxo_test.dart` — end-to-end tracer (02-01-T1), scroll (02-03-T3), search/sort (02-05-T2/T3)
- [ ] `fake_async` dev dependency (`flutter pub add --dev fake_async`) — installed by 02-01-T2, used by 02-05-T2

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
