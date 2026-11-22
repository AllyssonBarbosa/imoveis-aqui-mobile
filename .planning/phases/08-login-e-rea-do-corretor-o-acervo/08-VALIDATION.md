---
phase: "08"
slug: "login-e-rea-do-corretor-o-acervo"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-11-20"
---

# Phase 08 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
> Fonte: `08-RESEARCH.md` § Validation Architecture.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Web: Django `manage.py test` (Django 5.2.17 + DRF 3.18.1, `APITestCase`) · App: `flutter_test` + `bloc_test ^10.0.0` + `mocktail ^1.0.5` |
| **Config file** | Web: nenhum extra (`config/settings.py` troca o hasher só em `test`) · App: `analysis_options.yaml` (`flutter_lints`) |
| **Quick run command** | Web: `cd "/c/projetos/imoveis-aqui/Web" && DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test <app.tests.Classe> --noinput` · App: `flutter test <arquivo>_test.dart` |
| **Full suite command** | Web: `cd "/c/projetos/imoveis-aqui/Web" && DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test --noinput` (linha de base 695 testes) · App: `flutter analyze lib` + `flutter test` (linha de base 774 testes) |
| **Estimated runtime** | Web ~18 s · App ~60 s |

---

## Sampling Rate

- **After every task commit:** comando rápido do arquivo tocado (web: classe de teste; app: arquivo de teste) + `flutter analyze lib` se tocou `lib/`
- **After every plan wave:** suíte completa dos dois repos, rodada à mão (D-18: o gate pós-merge do GSD vê `ios/Runner.xcodeproj` e pula os testes Flutter)
- **Before `/gsd-verify-work`:** `manage.py test` 695+N verde, `flutter analyze lib` limpo, `flutter test` 774+N verde
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 01 | 1 | API-10, ACV-01..04 | ver PLAN | ver PLAN | Django APITestCase | `DATABASE_URL="sqlite://:memory:" manage.py test imoveis.tests.AcervoApiTests` | ✅ | ✅ green |
| 08-01-02 | 01 | 1 | ACV-02, ACV-03, ACV-04 | ver PLAN | ver PLAN | Django APITestCase | `DATABASE_URL="sqlite://:memory:" manage.py test imoveis.tests.AcervoApiTests imoveis.tests.AcervoAllowlistExataTests` | ✅ | ✅ green |
| 08-02-01 | 02 | 1 | AUTH-02 | ver PLAN | ver PLAN | flutter_test | `flutter test test/data/armazenamento_token_seguro_test.dart` | ✅ | ✅ green |
| 08-02-02 | 02 | 1 | AUTH-02 | ver PLAN | ver PLAN | flutter_test | `flutter test test/data/interceptador_sessao_test.dart` | ✅ | ✅ green |
| 08-03-01 | 03 | 2 | AUTH-06 | ver PLAN | ver PLAN | Django APITestCase | `DATABASE_URL="sqlite://:memory:" manage.py test contas.tests.LoginLimiteDeTentativasTests contas.tests.LoginApiTests` | ✅ | ✅ green |
| 08-03-02 | 03 | 2 | AUTH-02, AUTH-03, AUTH-05, API-10 | ver PLAN | ver PLAN | Django APITestCase | `DATABASE_URL="sqlite://:memory:" manage.py test contas.tests.EuApiTests contas.tests.SairApiTests` | ✅ | ✅ green |
| 08-04-01 | 04 | 3 | API-09 | ver PLAN | ver PLAN | flutter_test | `python tool/capturar_fixtures_api.py --grupo acervo` (fixtures reais) + `flutter test test/data/contrato_acervo_test.dart` | ✅ | ✅ green |
| 08-04-02 | 04 | 3 | API-09 | ver PLAN | ver PLAN | flutter_test | `flutter test test/data/contrato_acervo_test.dart` | ✅ | ✅ green |
| 08-05-01 | 05 | 4 | AUTH-01, AUTH-03 | ver PLAN | ver PLAN | flutter_test | `flutter test test/data/autenticacao_remote_datasource_test.dart` | ✅ | ✅ green |
| 08-05-02 | 05 | 4 | AUTH-01, AUTH-02, AUTH-05 | ver PLAN | ver PLAN | flutter_test | `flutter test test/data/autenticacao_repository_impl_test.dart` | ✅ | ✅ green |
| 08-06-01 | 06 | 4 | ACV-01, ACV-04 | ver PLAN | ver PLAN | flutter_test | `flutter test test/domain/imovel_acervo_test.dart` | ✅ | ✅ green |
| 08-06-02 | 06 | 4 | ACV-01, ACV-04 | ver PLAN | ver PLAN | flutter_test | `flutter test test/data/imovel_acervo_model_test.dart test/data/contrato_acervo_test.dart` | ✅ | ✅ green |
| 08-07-01 | 07 | 5 | AUTH-01, AUTH-04, AUTH-05 | ver PLAN | ver PLAN | flutter_test | `flutter test test/domain/entrar_usecase_test.dart test/domain/sair_usecase_test.dart` | ✅ | ✅ green |
| 08-07-02 | 07 | 5 | AUTH-02, AUTH-04 | ver PLAN | ver PLAN | flutter_test | `flutter test test/presentation/sessao_cubit_test.dart` | ✅ | ✅ green |
| 08-08-01 | 08 | 6 | ACV-02 | ver PLAN | ver PLAN | flutter_test | `flutter test test/data/parametros_consulta_acervo_test.dart test/data/acervo_remote_datasource_test.dart` | ✅ | ✅ green |
| 08-08-02 | 08 | 6 | ACV-01, ACV-04 | ver PLAN | ver PLAN | flutter_test | `flutter test test/data/acervo_repository_impl_test.dart` | ✅ | ✅ green |
| 08-09-01 | 09 | 7 | ACV-02, ACV-04 | ver PLAN | ver PLAN | flutter_test | `flutter test test/presentation/acervo_cubit_test.dart` | ✅ | ✅ green |
| 08-09-02 | 09 | 7 | ACV-01 | ver PLAN | ver PLAN | flutter_test | `flutter test test/presentation/cartao_imovel_acervo_test.dart test/presentation/chips_situacao_test.dart` | ✅ | ✅ green |
| 08-09-03 | 09 | 7 | ACV-01, ACV-02 | ver PLAN | ver PLAN | flutter_test | `flutter test test/presentation/acervo_screen_test.dart` | ✅ | ✅ green |
| 08-10-01 | 10 | 8 | AUTH-01, AUTH-03 | ver PLAN | ver PLAN | flutter_test | `flutter test test/presentation/apresentacao_login_test.dart test/presentation/login_cubit_test.dart` | ✅ | ✅ green |
| 08-10-02 | 10 | 8 | AUTH-01, AUTH-05 | ver PLAN | ver PLAN | flutter_test | `flutter test test/presentation/login_screen_test.dart test/presentation/aviso_area_screen_test.dart test/presentation/acervo_screen_test.dart` | ✅ | ✅ green |
| 08-11-01 | 11 | 9 | AUTH-04, AUTH-05 | ver PLAN | ver PLAN | flutter_test | `flutter test test/presentation/entrada_area_cubit_test.dart test/presentation/entrada_area_screen_test.dart` | ✅ | ✅ green |
| 08-11-02 | 11 | 9 | AUTH-04 | ver PLAN | ver PLAN | flutter_test | `flutter test test/presentation/botao_sessao_topo_test.dart test/main_launch_routing_test.dart` | ✅ | ✅ green |
| 08-12-01 | 12 | 10 | AUTH-01..05, ACV-01..04 | ver PLAN | ver PLAN | flutter_test | `flutter test test/presentation/login_fluxo_test.dart test/presentation/acervo_fluxo_test.dart` | ✅ | ✅ green |
| 08-12-02 | 12 | 10 | (docs: README, REQUIREMENTS) | ver PLAN | ver PLAN | flutter_test | `grep "Área do corretor" README.md` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `test/support/armazenamento_token_em_memoria.dart` — fake de `ArmazenamentoToken` (nenhum teste toca o canal de plataforma)
- [x] `test/support/api_falsa.dart` — gravar cabeçalhos (`options.headers`), rotas `eu`/`acervo`/`login`/`sair` com fixtures novas e 401 sem `Authorization`
- [x] `tool/capturar_fixtures_api.py` — grupo `acervo` e fixtures `acervo_*.json`, `eu_corretor.json`, `erro_400_login.json`, `erro_401.json`
- [x] Web: `AcervoApiTests`, `AcervoAllowlistExataTests` (`imoveis/tests.py`), `EuApiTests`, `SairApiTests`, `LoginLimiteDeTentativasTests` (`contas/tests.py`); ajustar `test_lista_apenas_da_propria_empresa`
- [x] Helper de `SessaoCubit` falso (`MockCubit`) para `test/main_launch_routing_test.dart`
- [x] `flutter pub add flutter_secure_storage` + `dart run build_runner build -d`

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Login, acervo, busca/situação, Sair e tela de aviso no emulador contra o Django real | AC-1..AC-6 | Fluxo ponta a ponta com servidor real e armazenamento seguro do aparelho | `runserver 0.0.0.0:8000` com `10.0.2.2` no `ALLOWED_HOSTS`; dados: `seed_demo` + `semear_vitrine_dev` + `set_password` (receita no RESEARCH) |
| Token no Keychain do iOS | AUTH-01/AUTH-02 | Exige Mac (entitlements `keychain-access-groups`) | Checkpoint humano num Mac M1 |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-11-21 (validate-phase: 1059 flutter + 743 Django verdes, sem lacunas)

## Validation Audit 2026-11-21

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
