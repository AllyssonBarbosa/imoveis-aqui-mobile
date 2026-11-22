---
phase: "07"
slug: "perfis-p-blicos-da-empresa-e-do-corretor"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-11-08"
---

# Phase 07 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test + bloc_test ^10.0.0 + mocktail ^1.0.5 |
| **Config file** | none — convenção `test/**_test.dart` |
| **Quick run command** | `flutter test <arquivos de teste da task>` |
| **Full suite command** | `flutter test && flutter analyze` |
| **Codegen (antes dos testes que dependem dele)** | `dart run build_runner build --delete-conflicting-outputs` |
| **Estimated runtime** | ~45 seconds (suíte completa; baseline 587 testes verdes) |

---

## Sampling Rate

- **After every task commit:** Run `flutter test <arquivos de teste da task>`
- **After every plan wave:** Run `flutter test && flutter analyze`
- **Before `/gsd-verify-work`:** Full suite must be green + guardas vazias
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

Preenchido por requisito a partir do `07-RESEARCH.md` (§ Validation Architecture); os Task IDs
são ligados pelos PLAN.md da fase.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 07-TBD | TBD | TBD | PERF-01 | T-07 (V5/V12) | Logomarca só http(s) (`urlHttpOuNula`); `""`/`null`→`null`; texto puro | widget + unit | `flutter test test/presentation/perfil_empresa_screen_test.dart test/data/perfil_model_test.dart` | ❌ W0 | ⬜ pending |
| 07-TBD | TBD | TBD | PERF-02 | T-07 (V5) | Contato como `SelectableText`, sem ações (`tel:`/`mailto:`/`wa.me`) | widget + unit | `flutter test test/presentation/perfil_corretor_screen_test.dart test/presentation/apresentacao_perfil_test.dart` | ⚠ reescrever / ❌ W0 | ⬜ pending |
| 07-TBD | TBD | TBD | PERF-03 | T-07 (V8) | Linhas da vitrine sem `corretor`/`empresa`/`proprietario` (allowlist §6) | unit + bloc_test + widget | `flutter test test/data/vitrine_anunciante_mock_datasource_test.dart test/presentation/vitrine_anunciante_cubit_test.dart` | ❌ W0 | ⬜ pending |
| 07-TBD | TBD | TBD | PERF-04 | T-07 (V13) | Parse defensivo; 404 por status; corpo inválido → `FormatException`; mensagens fixas | unit (Dio falso) | `flutter test test/data/perfil_remote_datasource_test.dart test/data/perfil_repository_impl_test.dart test/data/contrato_perfis_test.dart test/data/perfil_mock_datasource_test.dart` | ❌ W0 | ⬜ pending |
| 07-TBD | TBD | TBD | PERF-05 | T-07 (V7) | 404 → aviso sem retry e sem prévia; outros → "Tentar de novo" | bloc_test + widget | `flutter test test/presentation/perfil_corretor_cubit_test.dart test/presentation/perfil_empresa_cubit_test.dart` | ❌ W0 | ⬜ pending |
| 07-TBD | TBD | TBD | PERF-06 | — | N/A | widget e2e (pilha mock) | `flutter test test/presentation/detalhe_navegacao_test.dart test/presentation/detalhe_imovel_screen_test.dart` | ⚠ estender | ⬜ pending |
| 07-TBD | TBD | TBD | API-08 | T-07 (V8) | §12 mantém a allowlist do §6 | unit + grep | `flutter test test/data/vitrine_anunciante_mock_datasource_test.dart` ; `grep -n "^## 12\." .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

### Guardas (gates de fim de fase, molde 04-08)

- `! grep -rnE "try *\{" lib/presentation/perfis`
- `! grep -rlnE "Mock[D]ataSource|perfis[F]ixture|Fixture\(" lib/presentation lib/domain`
- `! grep -rn "getIt<" lib/presentation/detalhe_imovel/perfil_corretor_screen.dart`
- `! grep -rnE "url_launcher|launchUrl|tel:|mailto:|wa\.me" lib pubspec.yaml`
- `git diff --exit-code pubspec.yaml pubspec.lock`
- `! grep -rnE "Color\(0x|Colors\." lib/presentation/perfis`
- `flutter analyze` sem issues

---

## Wave 0 Requirements

- [ ] `test/data/perfil_model_test.dart`, `perfil_remote_datasource_test.dart`, `perfil_repository_impl_test.dart`, `perfil_mock_datasource_test.dart`, `vitrine_anunciante_mock_datasource_test.dart`, `contrato_perfis_test.dart` — stubs para PERF-01..05 / API-08
- [ ] `test/presentation/perfil_corretor_cubit_test.dart`, `perfil_empresa_cubit_test.dart`, `vitrine_anunciante_cubit_test.dart`, `perfil_empresa_screen_test.dart`, `apresentacao_perfil_test.dart`
- [ ] Reescrever `test/presentation/perfil_corretor_screen_test.dart`; ajustar 1 teste de `detalhe_imovel_screen_test.dart` e o grupo "fluxo completo"/"DI real" de `detalhe_navegacao_test.dart`
- [ ] JSONs de exemplo do wire dos perfis + §12 do contrato

Framework install: nenhum (infra de teste já existe).

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Aparência das páginas (cabeçalho, ícones/rótulos de contato, chips de cidades, cores verde/branco) | PERF-01/02 | julgamento visual (D-16) | Abrir um imóvel → tocar no corretor; abrir um corretor com campos vazios |
| Aviso de corretor desativado | PERF-05 | transição real | Seguir o caminho reservado no mock para o corretor desativado → aviso + "Voltar" |
| Rolagem e paginação da vitrine do anunciante | PERF-03 | gesto e fluidez | Rolar a vitrine de um corretor com várias páginas até o rodapé de fim |
| Corretor → "Ver página do anunciante" → imóvel → detalhe → voltar | PERF-06 | fluxo | Percorrer a navegação completa |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
