---
phase: "01"
slug: "localiza-o-escolha-de-cidade-e-contrato-da-api"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-09-21"
---

# Phase 01 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test + bloc_test ^10.0.0 + mocktail ^1.0.5 (Dart) |
| **Config file** | none — Wave 0 installs (pubspec.yaml dev_dependencies + test/ dir) |
| **Quick run command** | `flutter test` |
| **Full suite command** | `flutter test && flutter analyze` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test`
- **After every plan wave:** Run `flutter test && flutter analyze`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

> Seeded by plan-phase; the planner/executor fills concrete task IDs and commands. The API
> contract deliverable (API-01) is a document, not code — it is verified by review + web-team
> sign-off (see Manual-Only Verifications), not an automated command.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 0 | LOC-01..06 | — | test harness present | unit | `flutter test` | ❌ W0 | ⬜ pending |
| 01-01-02 | 01 | 1 | LOC-04 | — | chosen city persists across cold start | unit | `flutter test test/city_persistence_test.dart` | ❌ W0 | ⬜ pending |
| 01-01-03 | 01 | 1 | LOC-01,02,03,05,06 | — | each location outcome maps to its own sealed state | unit | `flutter test test/location_cubit_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `pubspec.yaml` — flutter_test, bloc_test, mocktail dev_dependencies + core stack
- [ ] `test/` directory + shared mocktail fixtures for repository/data-source doubles
- [ ] `flutter create` scaffold (no pubspec.yaml/lib exists yet — greenfield)

*If none: "Existing infrastructure covers all phase requirements."*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Location permission prompt appears on first launch and each outcome shows its own UI | LOC-01, LOC-03 | Runtime OS permission dialog cannot be driven by unit tests; needs device/emulator | Run on Android emulator + iOS simulator; deny, allow, disable location service, and simulate an unserved-city coordinate; confirm each shows its dedicated screen (never a generic error) |
| API contract document exists and is agreed with the web team | API-01 | Deliverable is a frozen document (field names/enums/filter params/pagination envelope), not code | Review CONTRATO-API.md; confirm GET /cidades + GET /imoveis shapes are present and the open items are explicitly flagged for web-team sign-off |

*If none: "All phase behaviors have automated verification."*

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
