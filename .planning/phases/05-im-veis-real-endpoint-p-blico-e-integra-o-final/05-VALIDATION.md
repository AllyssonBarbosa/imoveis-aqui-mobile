---
phase: "5"
slug: "im-veis-real-endpoint-p-blico-e-integra-o-final"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-30"
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework (app)** | flutter_test + bloc_test ^10.0.0 + mocktail ^1.0.5 (+ fake_async) |
| **Framework (API)** | Django `TestCase` / DRF `APITestCase` (runner Django), Postgres |
| **Config file** | none — app: `test/**_test.dart`; API: `manage.py test` |
| **Quick run command (app)** | `flutter test <arquivos de teste tocados pela task>` |
| **Quick run command (API)** | `cd ../imoveis-aqui/Web && .venv/bin/python manage.py test imoveis.tests.<Classe> -v 1` |
| **Full suite command (app)** | `flutter test && flutter analyze` (baseline: 587 verdes) |
| **Full suite command (API)** | `cd ../imoveis-aqui/Web && .venv/bin/python manage.py test` |
| **Codegen** | `dart run build_runner build -d` antes de testes que dependem de `*.freezed.dart` / `*.g.dart` / DI |
| **Estimated runtime** | ~90 seconds (cada suíte) |

---

## Sampling Rate

- **After every task commit:** Run the quick command for the touched tests (app ou API)
- **After every plan wave:** Run both full suites (API `manage.py test`; app `flutter test && flutter analyze`)
- **Before `/gsd-verify-work`:** Both full suites green + checagem E2E humana contra o seed
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

> Preenchido pelo planner / executor a partir dos PLAN.md. Mapa requisito → teste vem do 05-RESEARCH.md §Validation Architecture.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 5-XX-XX | — | — | API-03 | — | Lista só `na_vitrine`; allowlist exata; sem vazamento multitenant | Django integração | `manage.py test imoveis.tests.VitrineBuscaTests` | ❌ W0 | ⬜ pending |
| 5-XX-XX | — | — | API-07 | — | 404 igual p/ inexistente/rascunho/reservado/empresa inativa | Django integração | `manage.py test imoveis.tests.VitrineDetalheTests` | ❌ W0 | ⬜ pending |
| 5-XX-XX | — | — | API-03/07 | — | N/A | Flutter unit | `flutter test test/data/` | parcial | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Branch `feat/APP05` (API) a partir de `origin/WEB-09` + merge de `origin/feat/web-08`; `manage.py migrate` e `manage.py test` verdes como baseline
- [ ] Testes Django novos: situação (`RESERVADO`…), `LOTE`, CSV, bairros, características, allowlist exata, seed idempotente
- [ ] `test/fixtures/api/*.json` capturados da API semeada + `test/support/` com fakes (`HttpClientAdapter` falso, `FakeImovelDataSource`)
- [ ] Testes das DataSources remotas (lista, detalhe, opções) e de `parametros_consulta_imoveis`
- [ ] Teste de contrato da lista (hoje só existe o do detalhe)
- [ ] Migração dos ~10 arquivos de teste que dependem de mocks **antes** de apagar os mocks

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Visitante vê/busca/ordena/filtra imóveis reais e abre o detalhe das 4 naturezas | API-03, API-07 | Exige simulador/AVD + servidor Django com seed (sem CORS, sem `macos/`) | Subir Postgres + `runserver`, rodar seed, `flutter run --dart-define=API_BASE_URL=...` no simulador e percorrer o fluxo |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
