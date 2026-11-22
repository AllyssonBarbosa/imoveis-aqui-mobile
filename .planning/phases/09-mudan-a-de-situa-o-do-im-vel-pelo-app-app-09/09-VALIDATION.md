---
phase: "09"
slug: "mudan-a-de-situa-o-do-im-vel-pelo-app-app-09"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-11-22"
---

# Phase 09 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution. Fonte: `09-RESEARCH.md` § Validation Architecture.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | App: `flutter_test` + `bloc_test ^10.0.0` + `mocktail ^1.0.5`. Web: Django `manage.py test` (`APITestCase`) |
| **Config file** | App: `analysis_options.yaml`. Web: nenhum extra |
| **Quick run command** | `flutter test test/<arquivo>_test.dart` |
| **Full suite command** | `flutter analyze lib && flutter test` (linha de base 1194 testes) |
| **Web quick/full** | `cd <Web da origin/main> && DATABASE_URL="sqlite://:memory:" DJANGO_SECRET_KEY=x DEBUG=True .venv/bin/python manage.py test [imoveis.tests.<Classe>] --noinput` (linha de base 743) |
| **Estimated runtime** | ~60 s (app), ~9 s (web) |

Observação: o web roda sobre o código da `origin/main` (a `feat/APP06` local não tem as rotas desta fase).

---

## Sampling Rate

- **After every task commit:** comando rápido do arquivo tocado + `flutter analyze lib` se tocou `lib/`
- **After every plan wave:** `flutter analyze lib` + `flutter test` completo; se a web mudou, `manage.py test` completo
- **Before `/gsd-verify-work`:** app 1194+N verde e analyze limpo; web 743+N verde (se mudou)
- **Max feedback latency:** ~60 seconds

---

## Per-Task Verification Map

Preenchido pelo planner/executor por tarefa. Mapa requisito → teste (do RESEARCH):

| Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| SIT-01 | T-09-07 | Confirmar só com escolha ≠ atual; sem duplo envio | widget + datasource | `flutter test test/presentation/mudar_situacao_sheet_test.dart test/data/gestao_imovel_remote_datasource_test.dart` | ❌ W0 | ⬜ pending |
| SIT-01 | — | Data `dd/MM/yyyy HH:mm` | unit | `flutter test test/presentation/apresentacao_gestao_test.dart` | ❌ W0 | ⬜ pending |
| SIT-02 | T-09-03 | Estado só muda depois do GET de recarga | bloc_test | `flutter test test/presentation/gestao_imovel_cubit_test.dart` | ❌ W0 | ⬜ pending |
| SIT-03 | T-09-10 | Histórico na ordem do servidor; situação desconhecida não derruba | widget + model | `flutter test test/presentation/historico_situacao_test.dart test/data/mudanca_situacao_model_test.dart` | ❌ W0 | ⬜ pending |
| SIT-03 / SIT-07 | T-09-10, T-09-14 | Um só mapa código → enum (acervo, gestão, histórico); código desconhecido vira `null`; ida e volta com `codigoDaSituacao` | unit | `flutter test test/data/codigos_imovel_api_test.dart test/data/imovel_acervo_model_test.dart` | ❌ W0 | ⬜ pending |
| SIT-04 | T-09-03, T-09-05, T-09-08 | 400/403 mostram mensagem e tela não muda; 404/5xx texto fixo; 401 → login | bloc_test + repo + fluxo | `flutter test test/presentation/mudar_situacao_cubit_test.dart test/data/gestao_imovel_repository_impl_test.dart test/presentation/gestao_imovel_fluxo_test.dart` | ❌ W0 | ⬜ pending |
| SIT-05 | — | Acervo recarrega com `mudou`, mantendo busca/chip | bloc_test + widget | `flutter test test/presentation/acervo_cubit_test.dart test/presentation/acervo_screen_test.dart` | ✅ estender | ⬜ pending |
| SIT-05 (servidor) | — | Imóvel reservado sai da vitrine pública (lista) e o detalhe público dá 404 — a regra `na_vitrine` é do Django | Django (já na `origin/main` `8bf4448`, `Web/imoveis/tests.py`) | `manage.py test imoveis.tests.VitrinePublicaTests.test_vitrine_so_lista_disponivel_e_publicado imoveis.tests.VitrinePublicaTests.test_detalhe_de_imovel_fora_da_vitrine_da_404` (no worktree `feat/APP09`, gate do 09-13) | ✅ existe | ⬜ pending |
| SIT-06 | T-09-01, T-09-02 | Botão só com `pode_mudar_situacao`; 403 forçado mostra mensagem | widget | `flutter test test/presentation/gestao_imovel_screen_test.dart` | ❌ W0 | ⬜ pending |
| SIT-06 / API-12 | T-09-01, T-09-02 | Servidor: 403 colega, 404 outra empresa, 401 sem token, 403>400 | Django | `manage.py test imoveis.tests.AppSituacaoApiTests` | ❌ W0 (web) | ⬜ pending |
| SIT-07 | — | Todo cartão toca; "Ver na vitrine" só com `na_vitrine` | widget | `flutter test test/presentation/cartao_imovel_acervo_test.dart test/presentation/gestao_imovel_screen_test.dart` | ✅ inverter D-07 | ⬜ pending |
| API-11 | T-09-04 | §16 + exemplos = fixtures capturadas | contrato | `flutter test test/data/contrato_gestao_situacao_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `tool/capturar_fixtures_api.py` — grupo `situacao` (SQLite temporário, credenciais por env, token redigido; o POST grava no banco)
- [ ] `test/fixtures/api/*` novas (capturadas) e `contrato/*.example.json` do §16
- [ ] `test/support/api_falsa.dart` — rotas de detalhe, histórico, POST + 401 sem token
- [ ] Testes novos da tabela acima (inclui `test/data/codigos_imovel_api_test.dart`, onda 1)
- [ ] Ajuste dos testes do cartão/acervo (inverter casos D-07)
- [ ] Web (D-08; worktree `../imoveis-aqui-APP09`, D-19): `AppSituacaoApiTests` na `feat/APP09`
- Framework: nenhuma instalação

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Vitrine reflete a mudança (ponta a ponta) | SIT-05 | A regra do servidor já é automática (`VitrinePublicaTests.test_vitrine_so_lista_disponivel_e_publicado` e `test_detalhe_de_imovel_fora_da_vitrine_da_404` na `origin/main`); o que é manual é a ponta a ponta app → Django real | UAT: reservar → imóvel some da vitrine; voltar a disponível → reaparece |
| 400 real (contrato assinado) e 403 real | SIT-04, SIT-06 | Ponta a ponta com seeds reais | UAT com `corretor@demo.com` em `DEMO-CASA-01` (400) e `DEV-CAMPINAS-14` (403 forçado) |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
