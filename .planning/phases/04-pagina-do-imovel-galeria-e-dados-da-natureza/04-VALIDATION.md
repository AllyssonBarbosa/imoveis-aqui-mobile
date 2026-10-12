---
phase: "4"
slug: "pagina-do-imovel-galeria-e-dados-da-natureza"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-12"
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test + bloc_test ^10.0.0 + mocktail ^1.0.5 |
| **Config file** | none — convenção `test/**_test.dart` |
| **Quick run command** | `flutter test <arquivos de teste tocados pela task>` |
| **Full suite command** | `flutter test && flutter analyze` |
| **Codegen** | `dart run build_runner build -d` antes de testes que dependem de `*.freezed.dart` / `*.g.dart` / DI |
| **Estimated runtime** | ~20 seconds (baseline 382 testes em ~14 s) |

---

## Sampling Rate

- **After every task commit:** Run the quick command on the touched test files
- **After every plan wave:** Run `flutter test && flutter analyze`
- **Before `/gsd-verify-work`:** Full suite must be green, analyze sem issues
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

Preenchido pelo planner/executor a partir do mapa abaixo (Requirement → Test).

| Req ID | Critério | Behavior | Test Type | Automated Command | File Exists | Plan/Task |
|--------|----------|----------|-----------|-------------------|-------------|-----------|
| DET-02 | 1 | Galeria começa pela capa, contador "1/N", swipe, sem fotos → placeholder | unit + widget | `flutter test test/data/imovel_detalhe_mock_datasource_test.dart test/presentation/galeria_imovel_test.dart` | ❌ W0 | 04-04 T1 (fixture), 04-07 T1 |
| DET-02 | 1 | Toque abre `VisualizadorFotos` com `InteractiveViewer` no índice tocado | widget | `flutter test test/presentation/visualizador_fotos_test.dart` | ❌ W0 | 04-07 T2 |
| DET-04 | 2 | Casa: terreno/construída/livre; terreno: frente/fundo/topografia | unit + widget | `flutter test test/presentation/apresentacao_natureza_test.dart test/presentation/detalhe_imovel_screen_test.dart` | ❌ W0 | 04-05 T1 (dados), 04-06 T1 (tela) |
| DET-04 | 2/6 | Anti-cálculo: `area_livre` do wire exibida como veio | unit | idem | ❌ W0 | 04-05 T1 (fixture 57), 04-06 T1 |
| DET-04 | 3 | Apartamento: card do prédio; lote: card quadra + loteamento | unit + widget | idem | ❌ W0 | 04-05 T2 (dados), 04-06 T2 (cards) |
| DET-04 | D-14 | Nulo omite linha; seção vazia some; natureza desconhecida não derruba | unit | `flutter test test/data/detalhe_imovel_model_test.dart test/presentation/apresentacao_natureza_test.dart` | ❌ W0 | 04-05 T1/T2, 04-06 T1/T2 |
| DET-03 | 4 | Venda/aluguel/ambos, condomínio, IPTU; ausentes omitidos | unit + widget | `flutter test test/presentation/apresentacao_imovel_test.dart test/presentation/detalhe_imovel_screen_test.dart` | ⚠ estender | 04-08 T1 |
| DET-05 | 5 | Card do corretor com foto/nome; toque abre `PerfilCorretorScreen` | widget | `flutter test test/presentation/cartao_corretor_test.dart test/presentation/perfil_corretor_screen_test.dart` | ❌ W0 | 04-01 T1 (descrição), 04-08 T2 |
| DET-01 | — | Card abre detalhe; prévia visível durante carregamento | widget | `flutter test test/presentation/imovel_card_test.dart test/presentation/vitrine_screen_test.dart test/presentation/detalhe_navegacao_test.dart` | ⚠ estender | 04-01 T1 (tracer), 04-04 T1 |
| DET-06 | — | Cubit carregando→carregado/naoEncontrado/erro; retry; UI de 404 e "Tentar de novo" | bloc_test + widget | `flutter test test/presentation/detalhe_imovel_cubit_test.dart test/presentation/detalhe_imovel_screen_test.dart` | ❌ W0 | 04-01 T2 (retry e2e), 04-03 T2 |
| DET-06 | — | Repo: 404 → `ImovelNaoEncontradoException`; outros → Failure; `TypeError` → `FormatException` | unit | `flutter test test/data/imovel_detalhe_repository_impl_test.dart` | ❌ W0 | 04-03 T1 |
| API-06 | 6 | Contrato §11: exemplo JSON parseia; chaves ⊆ allowlist (sem dado interno) | unit | `flutter test test/data/contrato_detalhe_test.dart` | ❌ W0 | 04-02 T1, 04-05 T2 (lote) |
| API-06 | 6 | Consistência lista↔detalhe na fixture; ids reservados de 404/erro | unit | `flutter test test/data/imovel_detalhe_mock_datasource_test.dart` | ❌ W0 | 04-04 T1, 04-05 T1/T2 |
| segurança | — | URL de foto com esquema ≠ http/https descartada | unit | `flutter test test/data/detalhe_imovel_model_test.dart` | ❌ W0 | 04-04 T2 |
| (DI) | — | `getIt<DetalheImovelCubit>()` resolve com a pilha mock após `configureDependencies()` | unit | `flutter test test/presentation/detalhe_navegacao_test.dart` (grupo 'DI real') | ❌ W0 | 04-01 T1 |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/data/detalhe_imovel_model_test.dart`
- [ ] `test/data/imovel_detalhe_mock_datasource_test.dart`
- [ ] `test/data/imovel_detalhe_repository_impl_test.dart`
- [ ] `test/data/contrato_detalhe_test.dart`
- [ ] `test/presentation/apresentacao_natureza_test.dart`, `detalhe_imovel_cubit_test.dart`, `detalhe_imovel_screen_test.dart`, `galeria_imovel_test.dart`, `visualizador_fotos_test.dart`, `cartao_corretor_test.dart`, `perfil_corretor_screen_test.dart`, `detalhe_navegacao_test.dart`
- [ ] Estender `imovel_card_test.dart`, `vitrine_screen_test.dart`, `apresentacao_imovel_test.dart`
- Framework: nenhum install — tudo já presente.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Pinch-zoom real e conflito zoom × swipe | DET-02 | Gesto multitoque não é fiel em widget test | Abrir foto em tela cheia, dar zoom e tentar arrastar; o swipe só troca de foto sem zoom |
| SliverAppBar colapsando, botão voltar legível sobre fotos | DET-02 | Aparência visual | Rolar a página de um imóvel com fotos claras e escuras |
| Fluxo 404 e "Tentar de novo" com latência do mock | DET-06 | Fluxo ponta a ponta | Abrir os ids reservados de 404 e de falha a partir da vitrine |
| Rótulos e ícones da natureza | DET-04 | Julgamento visual | Abrir um imóvel de cada natureza |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
