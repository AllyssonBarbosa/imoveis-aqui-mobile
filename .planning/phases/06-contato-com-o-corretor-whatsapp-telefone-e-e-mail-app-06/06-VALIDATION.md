---
phase: "6"
slug: "contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-11-16"
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | App: `flutter_test` + `bloc_test ^10` + `mocktail ^1.0.5`. API: Django `APITestCase` (`manage.py test`) |
| **Config file** | none (app: `test/**_test.dart`; API: `Web/*/tests.py`) |
| **Quick run command** | App: `flutter test <arquivos tocados>` · API: `cd ../imoveis-aqui/Web && DATABASE_URL="sqlite://:memory:" .venv/bin/python manage.py test contatos imoveis --noinput` |
| **Full suite command** | `flutter test && flutter analyze` (baseline 588 verdes, analyze limpo) · API: `cd ../imoveis-aqui/Web && DATABASE_URL="sqlite://:memory:" .venv/bin/python manage.py test --noinput` |
| **Estimated runtime** | ~30 seconds (app) / ~20 seconds (API) |

Codegen antes dos testes quando freezed/json/injectable mudar: `dart run build_runner build -d`.

---

## Sampling Rate

- **After every task commit:** Run the quick run command for the files touched
- **After every plan wave:** Run both full suite commands
- **Before `/gsd-verify-work`:** Both suites green + device human-check
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

Preenchido pelo planner/executor por tarefa. Mapa de comportamento → teste (da pesquisa):

| Requirement | Behavior | Test Type | Automated Command | File Exists | Status |
|-------------|----------|-----------|-------------------|-------------|--------|
| APP06-API-1 | Detalhe traz `canais_contato` (só nomes, ordem fixa; vazio sem destino; allowlist exata atualizada) | Django | `manage.py test imoveis.tests.VitrineDetalheTests imoveis.tests.VitrineAllowlistExataTests` | ❌ W0 | ⬜ pending |
| APP06-API-2 | POST além da taxa → 429 com `Retry-After`; balde separado da vitrine | Django | `manage.py test contatos` | ❌ W0 | ⬜ pending |
| C2 (servidor) | Link `wa.me` do POST (API e site) com `%20` entre as palavras e nenhum `+` (`link_whatsapp` com `quote_via=quote`, decisão do usuário; Pitfall 7) | Django | `manage.py test contatos.tests.MensagemDoWhatsAppComEspacosTests` | ❌ W0 (06-02) | ⬜ pending |
| C4/C5/C6 (servidor) | POST sem token grava `Contato(imovel, corretor, canal)`; 400 sem destino; 404 fora da vitrine | Django | `manage.py test contatos` | ✅ (após merge W11) | ⬜ pending |
| C2/C3 (contrato) | App parseia `contato_201_*` capturado; link validado por canal | Flutter unit | `flutter test test/data/contato_repository_impl_test.dart test/data/contato_remote_datasource_test.dart` | ❌ W0 | ⬜ pending |
| C3 | `canais_contato` vira `List<CanalContato>`; desconhecido descartado; ausente → `[]` | Flutter unit | `flutter test test/data/detalhe_imovel_model_test.dart test/data/contrato_detalhe_test.dart` | ✅ + casos novos | ⬜ pending |
| C4 | Use case registra antes de abrir; falha de abertura não desfaz registro | Flutter unit | `flutter test test/domain/contatar_corretor_usecase_test.dart` | ❌ W0 | ⬜ pending |
| C2 | Gateway usa `externalApplication`; `PlatformException`/`false` → `false` | Flutter unit | `flutter test test/data/url_launcher_gateway_impl_test.dart` | ❌ W0 | ⬜ pending |
| C4/D-13 | Cubit: enviando → ocioso / falhou(motivo); ignora toque em `enviando` | bloc_test | `flutter test test/presentation/contato_cubit_test.dart` | ❌ W0 | ⬜ pending |
| C1/C3 | `BarraContato`: principal + ⋮ + sheet; loading; SnackBar por motivo | widget | `flutter test test/presentation/barra_contato_test.dart` | ❌ W0 | ⬜ pending |
| C1 | Barra no detalhe só em `DetalheCarregado` com canais; legenda D-07 = as linhas de preço do cabeçalho quando cabem, só a principal em VENDA_E_ALUGUEL longo demais | widget | `flutter test test/presentation/detalhe_imovel_screen_test.dart` | ✅ + casos novos | ⬜ pending |
| C1 | Perfil: barra só com contexto de imóvel | widget | `flutter test test/presentation/perfil_corretor_screen_test.dart` | ✅ + casos novos | ⬜ pending |
| C1..C6 | E2E: detalhe → WhatsApp → POST na `ApiFalsa` sem auth → gateway recebe `wa.me` do fixture | widget e2e | `flutter test test/presentation/detalhe_navegacao_test.dart` | ✅ + casos novos | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] API: branch `feat/APP06` = `main` + merge `origin/WEB-11` (3 conflitos aditivos) e `manage.py test contatos imoveis` verde
- [ ] API: `canais_contato` no detalhe + throttle do POST de contato
- [ ] App: `url_launcher` + dev deps `url_launcher_platform_interface`, `plugin_platform_interface`; `build_runner`
- [ ] Fixtures: `tool/capturar_fixtures_api.py` ganha POST + grupo `contato`; recapturar `detalhe_*.json` e `contrato/*.example.json`; atualizar `_chavesDetalhe`; adendo no contrato
- [ ] `test/support/api_falsa.dart`: suporte a POST (método + corpo registrados)
- [ ] Novos arquivos de teste do mapa acima

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| WhatsApp abre com a mensagem pré-preenchida; `tel:` abre discador; `mailto:` abre e-mail com assunto/corpo | C2, C3 | Precisa de aparelho/emulador com WhatsApp instalado | Abrir um imóvel com os 3 canais, tocar em cada um; conferir a mensagem (confirmar espaços entre as palavras — o `%20` já é garantido pelo teste Django do 06-02; Pitfall 7), o ícone do WhatsApp (Open Question 4) e o registro aparecendo na caixa do corretor |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
