---
phase: "10"
slug: "contatos-recebidos-e-retorno-anotado"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-11-22"
---

# Phase 10 — Validation Strategy

> Contrato de validação da fase, para a amostragem de feedback durante a execução.
> Fonte: `10-RESEARCH.md` § Validation Architecture (linhas de base medidas em 2026-11-22).

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework (web)** | Django `TestCase` / DRF `APITestCase` (`manage.py test`) — 743 testes hoje |
| **Framework (app)** | `flutter_test` + `bloc_test` + `mocktail` — 1194 testes hoje |
| **Config file** | `Web/manage.py` / `pubspec.yaml` (sem config extra) |
| **Quick run command (web)** | `cd "/c/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web" && DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test contatos --noinput` |
| **Full suite command (web)** | `cd "/c/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui/Web" && DATABASE_URL="sqlite://:memory:" ./venv/Scripts/python.exe manage.py test --noinput` |
| **Quick run command (app)** | `flutter test test/<arquivo>_test.dart` |
| **Full suite command (app)** | `flutter analyze lib` + `flutter test` |
| **Estimated runtime** | web ~20 s; app completo ~3–5 min |

---

## Sampling Rate

- **After every task commit:** `flutter test <arquivos da tarefa>` e/ou `manage.py test contatos --noinput`.
- **After every plan wave:** `flutter analyze lib` (0 errors/warnings; infos só `deprecated_member_use` do import de `material.dart`: 41 hoje + 1 por arquivo novo que importe `material.dart`) **e** `flutter test` completo; e `manage.py test --noinput` completo (743 + novos). Rodados à mão — o gate pós-merge do GSD pula os testes Flutter (D-29).
- **Before `/gsd-verify-work`:** as três suítes verdes + human-check de fim de fase.
- **Max feedback latency:** ~60 s por tarefa (teste do arquivo); suíte completa só por onda.

---

## Per-Task Verification Map

> Os IDs de tarefa nascem no planejamento. Mapa por requisito (IDs propostos pela pesquisa:
> `CXA-01..06`, `API-11`, `API-12`; o planejador confirma os nomes — D-27). O planejador/executor
> preenche `Task ID`/`Plan`/`Wave` e o `Status`.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 10-01-T1 | 10-01 | 1 | API-12 / CXA-01 | — | lista paginada, tamanho fixo (cliente não muda), `next` mantém filtros, `page` inválida 404 | integration (Django) | `manage.py test contatos.tests.PaginacaoDaCaixaTests --noinput` | ❌ W0 | ⬜ pending |
| 10-01-T2 | 10-01 | 1 | API-12 / CXA-05 | IDOR (Information Disclosure) | `resumo` conta só `PENDENTE` dos visíveis, ignora filtros; admin 403; anônimo 401 | integration (Django) | `manage.py test contatos.tests.ResumoSemRetornoTests --noinput` | ❌ W0 | ⬜ pending |
| 10-01-T2 | 10-01 | 1 | API-12 / CXA-02 | IDOR (Information Disclosure) | `imoveis` só com imóveis de contatos visíveis (`id/codigo/titulo`); admin 403; anônimo 401 | integration (Django) | `manage.py test contatos.tests.OpcoesDeImovelDaCaixaTests --noinput` | ❌ W0 | ⬜ pending |
| 10-01-T2 | 10-01 | 1 | CXA-04 | IDOR (Information Disclosure) | outra empresa / outro corretor nunca aparece em nenhuma rota (lista, filtro, resumo, imoveis) | integration (Django) | `manage.py test contatos.tests.IsolamentoTests --noinput` | ✅ estender | ⬜ pending |
| 10-01-T2 | 10-01 | 1 | CXA-03 / API-11 | Tampering / Information Disclosure | PATCH 200 item completo; 400 (PENDENTE/XYZ/""/`{}` — sem 500); 404 outro corretor/empresa; 405 PUT; fuso `-03:00` | integration (Django) | `manage.py test contatos.tests.AnotarRetornoTests --noinput` | ✅ estender | ⬜ pending |
| 10-02-T2 | 10-02 | 2 | API-11 / CXA-04 | IDOR (Information Disclosure) | fixtures reais; a empresa B tem 1 contato que nunca aparece na caixa, na contagem nem nas opções da empresa A (`count` 25, `sem_retorno` 25, sem id em comum) | capture (tool) | asserções Python do `<verify>` da Task 2 do 10-02 sobre `test/fixtures/api/contatos_*.json` | ❌ W0 | ⬜ pending |
| 10-03-T1 | 10-03 | 3 | API-11 | — | contrato: chaves exatas (envelope, item com 12, `resumo` com 1, opções com 3); exemplo = fixture | contract (app) | `flutter test test/data/contrato_contatos_test.dart` | ❌ W0 | ⬜ pending |
| 10-04-T1, 10-04-T2 | 10-04 | 4 | CXA-01..05 | Tampering (enum desconhecido) | entidades com igualdade por valor; `anotaveis` sem `PENDENTE`; wire ↔ enum com `FormatException` para valor desconhecido | unit (app) | `flutter test test/domain/entidades_caixa_contatos_test.dart test/data/canal_e_retorno_api_test.dart` | ❌ W0 | ⬜ pending |
| 10-05-T1, 10-06-T1, 10-06-T2 | 10-05, 10-06 | 5, 6 | CXA-01 | token via `next` (Information Disclosure) | parse do envelope; `FormatException` em enum desconhecido; 401/403/404 tipados; `seguir` rejeita outra origem | unit (app) | `flutter test test/data/caixa_contatos_remote_datasource_test.dart test/data/caixa_contatos_repository_impl_test.dart test/data/contato_recebido_model_test.dart` | ❌ W0 | ⬜ pending |
| 10-06-T1 | 10-06 | 6 | CXA-02 | — | `imovel`, `de`, `ate` `AAAA-MM-DD` (sem `toUtc`); vazio não gera chave | unit (app) | `flutter test test/data/parametros_consulta_contatos_test.dart` | ❌ W0 | ⬜ pending |
| 10-08-T1, 10-09-T1, 10-10-T1 | 10-08, 10-09, 10-10 | 8, 9, 10 | CXA-01..05 | sessão (401) | Cubit: carregar, vazio×sem resultado, erro, 401, paginação, filtro com versão, contagem falhando não derruba a lista, anotação sucesso/404/401/falha/duplo toque, aviso one-shot | unit (app) | `flutter test test/presentation/caixa_contatos_cubit_test.dart` | ❌ W0 | ⬜ pending |
| 10-07-T1 | 10-07 | 7 | CXA-01 / CXA-05 | texto do servidor nunca na UI | apresentação (0/1/N sem retorno, data `dd/MM/yyyy HH:mm` sem locale, rótulos de canal e retorno) e `ItemContato` | widget/unit (app) | `flutter test test/presentation/apresentacao_contatos_test.dart test/presentation/item_contato_test.dart` | ❌ W0 | ⬜ pending |
| 10-08-T2, 10-09-T2, 10-10-T2 | 10-08, 10-09, 10-10 | 8, 9, 10 | CXA-01..06 | texto do servidor nunca na UI | tela: linha do número (0/1/N/ausente), item, chips com "x", folha das 4 opções, item em voo sem toque, SnackBar fixa, estados, 401 → login com aviso | widget (app) | `flutter test test/presentation/caixa_contatos_screen_test.dart` | ❌ W0 | ⬜ pending |
| 10-07-T2 | 10-07 | 7 | CXA-02 | — | seletor de período em pt-BR ("Salvar", "Data de início") | widget (app) | `flutter test test/presentation/seletor_periodo_pt_br_test.dart` | ❌ W0 | ⬜ pending |
| 10-07-T2, 10-08-T2 | 10-07, 10-08 | 7, 8 | CXA-06 | — | ícone "Meus contatos" no acervo; `MaterialApp` de produção com `supportedLocales == [pt_BR]` | widget (app) | `flutter test test/presentation/acervo_screen_test.dart test/main_launch_routing_test.dart` | ✅ estender | ⬜ pending |
| 10-08-T3, 10-09-T2, 10-10-T3 | 10-08, 10-09, 10-10 | 8, 9, 10 | CXA-01..06 / API-11 | sessão (401) | ponta a ponta com `ApiFalsa` + fixtures reais: entrada pelo acervo, lista e número, página 2, 401, token (10-08); filtro por imóvel (10-09); anotar → resumo atualizado; 404 recarrega (10-10) | integration (app) | `flutter test test/presentation/caixa_contatos_fluxo_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `Web/contatos/tests.py` — ajustar `ids_api` (`response.data["results"]`); classes `PaginacaoDaCaixaTests`, `ResumoSemRetornoTests`, `OpcoesDeImovelDaCaixaTests`; estender `IsolamentoTests`/`AnotarRetornoTests` (PATCH vazio, fuso).
- [ ] `tool/capturar_fixtures_api.py` — novo grupo `contatos` (25 contatos via POST público; `CONTATO_TAXA_ANONIMA=1000/min` só se a variável existir; 1 contato da empresa B criado pelo ORM no SQLite temporário; credenciais só por variável de ambiente).
- [ ] `test/fixtures/api/contatos_*.json`, `contato_patch_200.json`, `erro_400_retorno.json`, `erro_404_contato.json` — capturadas do Django, nunca à mão; cópias byte a byte em `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/*.example.json`.
- [ ] `test/support/api_falsa.dart` — rotas `GET /api/contatos/` (p1/p2/filtrada/vazia), `GET /api/contatos/resumo/`, `GET /api/contatos/imoveis/`, `PATCH /api/contatos/<id>/` (200 / 404), todas exigindo token (senão 401).
- [ ] `test/data/contrato_contatos_test.dart` + testes de data/domain/presentation listados acima.
- [ ] `lib/app_localizacao.dart` + `pubspec.yaml` (`flutter_localizations: sdk: flutter`).
- [ ] `build_runner` para `*.freezed.dart`, `*.g.dart` e `injection.config.dart` (restaurar com `git checkout --` os gerados reescritos só com CRLF).

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Ícone da entrada, cor do chip "Aguardando retorno", textos longos do item | CXA-01, CXA-06 | Julgamento visual (Material 3 verde e branco) | Emulador com o Django da `feat/APP10` rodando: entrar como corretor → "Meu acervo" → ícone "Meus contatos"; conferir item, chip e quebra de linha de títulos longos |
| Seletor de período em português num aparelho real | CXA-02 | Locale do aparelho / renderização do diálogo | Abrir o chip "Período", conferir textos em pt-BR, escolher um intervalo e ver a lista filtrar |
| Anotar retorno contra o Django real | CXA-03, CXA-05 | Ponta a ponta com servidor real | Anotar "Falei" num pendente: o chip muda, aparece "anotado em …" e o número de sem retorno cai 1 (vindo do servidor) |
| Hora mostrada × site | CXA-01 | Fuso do aparelho (risco aceito A3) | Comparar a hora de um contato no app e na caixa do site (aparelho em fuso de Brasília) |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s (por tarefa)
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
