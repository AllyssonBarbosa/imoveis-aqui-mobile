---
phase: "12"
slug: "area-do-gestor-acompanhamento-dos-corretores"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-11-25"
---

# Phase 12 — Validation Strategy

> Contrato de validação da fase, reconstruído depois da execução (`/gsd-validate-phase 12`, State B) a partir dos 9 PLANs, dos 9 SUMMARYs e dos testes que existem nos dois repositórios. O planejamento foi pelo caminho curto (`--skip-research`), por isso não havia VALIDATION.md antes.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework (web)** | Django `TestCase` / DRF `APITestCase` (`manage.py test`) — 803 testes na `feat/APP12` (51 em `relatorios`) |
| **Framework (app)** | `flutter_test` + `bloc_test` + `mocktail` — 1924 testes na `feat/APP12` |
| **Config file** | `Web/manage.py` / `pubspec.yaml` (sem config extra) |
| **Quick run command (web)** | `cd "/c/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web" && DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test relatorios --noinput` |
| **Full suite command (web)** | `cd "/c/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web" && DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test --noinput` |
| **Quick run command (app)** | `flutter test test/<arquivo>_test.dart` |
| **Full suite command (app)** | `flutter analyze lib --no-fatal-infos` (0 errors/warnings; infos só `material.dart` obsoleto) + `flutter test` |
| **Estimated runtime** | web `relatorios` ~15 s; testes da fase no app ~50 s; app completo ~3–5 min |

---

## Sampling Rate

- **After every task commit:** o `<automated>` da tarefa (arquivos de teste da tarefa e/ou `manage.py test relatorios.tests.<Classe>`).
- **After every plan wave:** `flutter analyze lib --no-fatal-infos` + `flutter test` completo; na web, `manage.py test --noinput` completo. Rodados à mão — o gate pós-merge do GSD pula os testes Flutter.
- **Before `/gsd-verify-work`:** as três suítes verdes (12-09 Task 3: analyze 0 erros/warnings, 1924 testes no app, 803 na web) + roteiro humano do 12-UAT.md.
- **Max feedback latency:** ~60 s por tarefa; suíte completa só por onda.

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 12-01-T1 | 12-01 | 1 | API-15, GES-01, GES-04, GES-06 | T-12-01, T-12-02 | acervo por corretor só da empresa do usuário; soma das linhas = total = total do acervo; corretor 403, administrador 403, anônimo 401 | integration (Django) | `manage.py test relatorios.tests.AcervoPorCorretorTests relatorios.tests.AreaDoGestorApiTests relatorios.tests.AcervoTests relatorios.tests.ApiRelatoriosTests --noinput` | ✅ | ✅ green |
| 12-01-T2 | 12-01 | 1 | API-15, GES-03, GES-06 | T-12-01, T-12-03, T-12-04, T-12-05 | `?dias=` de 1 a 365 (padrão 7; `0`/`366`/`abc`/`-1` → 400); só os 9 campos de D-20; mudança da empresa B nunca aparece; parcelas sem mudança de comportamento | integration (Django) | `manage.py test relatorios.tests.MudancasDeSituacaoTests relatorios.tests.AreaDoGestorApiTests relatorios.tests.AcervoPorCorretorTests relatorios.tests.ApiRelatoriosTests relatorios.tests.ParcelasTests --noinput` | ✅ | ✅ green |
| 12-02-T1 | 12-02 | 2 | API-16, GES-06 | T-12-07, T-12-09 | grupo `gestor` na ferramenta: credenciais só por variável de ambiente; checagens de soma, janela, 403/401 e outra empresa disjunta | capture (tool) | `python3 tool/capturar_fixtures_api.py --help` + greps do `<verify>` (`capturar_gestor`, `CHAVES_MUDANCA_RECENTE`) | ✅ | ✅ green |
| 12-02-T2 | 12-02 | 2 | API-16, GES-05 | T-12-07, T-12-08 | as 10 fixtures capturadas do Django real (SQLite temporário, porta 8012); sem e-mail, senha nem token; repo web intocado | capture (tool) | `test -s test/fixtures/api/<10 fixtures>.json` + asserções Python do `<verify>` | ✅ | ✅ green |
| 12-03-T1 | 12-03 | 3 | API-16, GES-06 | T-12-10 | §18 do contrato: chaves exatas, exemplo = fixture, soma = total, relatórios da outra empresa disjuntos | contract (app) | `flutter test test/data/contrato_area_gestor_test.dart` | ✅ | ✅ green |
| 12-03-T2 | 12-03 | 3 | API-16 (registro) | — | GES-01..06, API-15, API-16 no REQUIREMENTS e no ROADMAP | doc (grep) | greps do `<verify>` sobre `.planning/REQUIREMENTS.md` | ✅ | ✅ green |
| 12-04-T1 | 12-04 | 4 | GES-01..GES-05 | T-12-11 | entidades com igualdade por valor; `toString` de `MudancaRecente` sem nome nem observação; `daEmpresa` | unit (app) | `flutter test test/domain/entidades_area_gestor_test.dart` | ✅ | ✅ green |
| 12-04-T2 | 12-04 | 4 | GES-01..GES-05 | — | 4 use cases só repassam (o app não calcula); DI regenerado | unit (app) | `flutter test test/domain/area_gestor_usecases_test.dart` | ✅ | ✅ green |
| 12-05-T1 | 12-05 | 5 | GES-01, GES-04, API-16 | T-12-12 | `TotaisPorSituacaoModel`/`AcervoPorCorretorModel` contra as fixtures reais; situação desconhecida → `FormatException` | unit (app) | `flutter test test/data/modelos_area_gestor_test.dart test/data/contrato_area_gestor_test.dart` | ✅ | ✅ green |
| 12-05-T2 | 12-05 | 5 | GES-02, GES-03, API-16 | T-12-12, T-12-13 | linha da empresa descarta o texto do servidor; mudanças com situação estrita e hora em UTC | unit (app) | `flutter test test/data/modelos_area_gestor_test.dart test/data/contrato_area_gestor_test.dart` | ✅ | ✅ green |
| 12-06-T1 | 12-06 | 6 | GES-01..GES-04, GES-06 | T-12-14 | só o `Dio` autenticado; `Authorization` em todo pedido; `de`/`ate` só com período | unit (app) | `flutter test test/data/area_gestor_remote_datasource_test.dart` | ✅ | ✅ green |
| 12-06-T2 | 12-06 | 6 | GES-05, GES-06 | T-12-15, T-12-16 | 401 → `SessaoExpiradaException`, 403 → `SemPermissaoException`, resto e wire malformado → `Failure`; nenhum método lança | unit (app) | `flutter test test/data/area_gestor_repository_impl_test.dart` | ✅ | ✅ green |
| 12-07-T1 | 12-07 | 7 | GES-01..GES-05 | T-12-19 | textos fixos e funções puras (singular/plural, "Total: N imóveis", linha da empresa, falhas) | unit (app) | `flutter test test/presentation/apresentacao_area_gestor_test.dart` | ✅ | ✅ green |
| 12-07-T2 | 12-07 | 7 | GES-02, GES-05, GES-06 | T-12-17, T-12-18 | 4 pedidos em paralelo; seções independentes; retry por seção; versão descarta período antigo; 401 terminal | unit (bloc_test) | `flutter test test/presentation/area_gestor_cubit_test.dart` | ✅ | ✅ green |
| 12-08-T1 | 12-08 | 8 | GES-01..GES-05 | T-12-20, T-12-21 | 4 seções em cartões; linhas sem toque (`NavigatorObserver`); texto do servidor nunca na tela | widget (app) | `flutter test test/presentation/secoes_area_gestor_test.dart` | ✅ | ✅ green |
| 12-08-T2 | 12-08 | 8 | GES-02, GES-05, GES-06 | T-12-22 | uma tela com as 4 seções na ordem; Sair na AppBar; chip de período; 401 → login com só a vitrine embaixo | widget (app) | `flutter test test/presentation/area_gestor_screen_test.dart` | ✅ | ✅ green |
| 12-09-T1 | 12-09 | 9 | GES-06 | T-12-23, T-12-24 | gestor → Área do gestor (login e botão do topo); administrador → aviso próprio; corretor → acervo | widget (app) | `flutter test test/presentation/entrada_area_screen_test.dart test/presentation/login_screen_test.dart test/presentation/aviso_area_screen_test.dart test/presentation/login_fluxo_test.dart test/presentation/botao_sessao_topo_test.dart test/presentation/acervo_fluxo_test.dart` | ✅ | ✅ green |
| 12-09-T2 | 12-09 | 9 | GES-01..GES-06 | T-12-25 | ponta a ponta sobre a pilha real: 4 seções, token, período só nos contatos, falha isolada, 403, 401 e corretor sem `/api/relatorios/` | e2e (app, `ApiFalsa`) | `flutter test test/presentation/area_gestor_fluxo_test.dart test/presentation/login_fluxo_test.dart` | ✅ | ✅ green |
| 12-09-T3 | 12-09 | 9 | GES-01..06, API-15, API-16 | T-12-SC | gates finais: analyze limpo, suítes completas dos dois repositórios, REQUIREMENTS `[x]` | gate | `flutter analyze lib --no-fatal-infos` + `flutter test` + `manage.py test --noinput` | ✅ | ✅ green (na execução: 1924 / 803) |
| 12-09-T4 | 12-09 | 9 | GES-06 (preparo do UAT) | T-12-26 | escrita no Postgres do desenvolvedor só pelo Allysson, script fora dos repositórios | manual (checkpoint `blocking-human`) | — | — | ✅ feito em 2026-11-25 |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

**Revalidação de 2026-11-25 (este audit):** os 16 arquivos de teste do app ligados às tarefas acima rodaram juntos — 213 testes, todos verdes — mais `acervo_fluxo_test.dart` (6 verdes); na web, `manage.py test relatorios` — 51 testes, OK; as 10 fixtures do 12-02 existem e não estão vazias.

---

## Requirement Coverage

| Requirement | Testes automáticos | Status |
|-------------|--------------------|--------|
| GES-01 — acervo por corretor | `AcervoPorCorretorTests`; `modelos_area_gestor_test`, `contrato_area_gestor_test`, `secoes_area_gestor_test`, `area_gestor_fluxo_test` | COVERED |
| GES-02 — contatos por corretor e período | `area_gestor_remote_datasource_test` (`de`/`ate`), `area_gestor_cubit_test` (período e versão), `area_gestor_screen_test` (chip), `area_gestor_fluxo_test` | COVERED |
| GES-03 — mudanças recentes | `MudancasDeSituacaoTests`; `modelos_area_gestor_test`, `entidades_area_gestor_test`, `secoes_area_gestor_test`, `area_gestor_fluxo_test` | COVERED |
| GES-04 — totais por situação | `AcervoTests`, `AreaDoGestorApiTests`; `modelos_area_gestor_test`, `contrato_area_gestor_test` (soma = total), `secoes_area_gestor_test` | COVERED |
| GES-05 — números do servidor, seções independentes | `area_gestor_usecases_test` (só repasse), `area_gestor_cubit_test` (falha isolada, retry por seção), `area_gestor_fluxo_test` | COVERED |
| GES-06 — só o gestor | `AreaDoGestorApiTests` (403/401 nas 4 rotas); `entrada_area_screen_test`, `login_fluxo_test`, `aviso_area_screen_test`, `botao_sessao_topo_test`, `area_gestor_fluxo_test` (corretor sem relatórios) | COVERED |
| API-15 — 2 rotas novas na web | `relatorios` (51 testes) | COVERED |
| API-16 — §18 do contrato + fixtures | `contrato_area_gestor_test.dart` + checagens da captura (12-02) | COVERED |

---

## Wave 0 Requirements

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Números do app iguais aos do painel do site | GES-01, GES-02, GES-04 | compara a tela do app com Relatórios → Acervo/Contatos do site, contra o Postgres real | 12-UAT.md teste 2 — ✅ pass em 2026-11-25 |
| Seletor de período em português no aparelho | GES-02 | seletor nativo do Material no emulador | 12-UAT.md teste 3 — ✅ pass |
| Gestor de outra empresa e administrador no app real | GES-06 | logins reais contra o Django do desenvolvedor | 12-UAT.md testes 5 e 6 — ✅ pass |
| Visual (verde e branco, 2×2, quebra de texto, singular) | GES-01..05 | julgamento visual | 12-UAT.md teste 7 — ✅ pass |
| Proibições (sem push, CLAUDE.md intacto, script fora dos repos) | — | revisão do estado dos repositórios | 12-UAT.md teste 8 — ✅ pass |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies (a única sem, 12-09-T4, é checkpoint humano de preparo do UAT)
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references (nenhuma MISSING)
- [x] No watch-mode flags
- [x] Feedback latency < 60s por tarefa
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-11-25

---

## Validation Audit 2026-11-25

| Metric | Count |
|--------|-------|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
