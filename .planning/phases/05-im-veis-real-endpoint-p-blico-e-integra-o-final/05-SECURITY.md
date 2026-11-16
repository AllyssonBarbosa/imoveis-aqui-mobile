---
phase: "05"
slug: "im-veis-real-endpoint-p-blico-e-integra-o-final"
status: verified
# threats_open = count of OPEN threats at or above workflow.security_block_on severity (the blocking gate)
threats_open: 0
asvs_level: 1
block_on: high
created: "2026-11-16"
---

# Phase 05 — Security

> Per-phase security contract: threat register, accepted risks, and audit trail.

> **Escopo da verificação:** o veredito vale para as árvores de trabalho atuais dos dois repositórios
> (app `imovies-aqui-mobile` e API `imoveis-aqui/Web`, branch `feat/APP05`). Mitigações marcadas
> **[U]** existem só como alterações **não commitadas** (ou arquivos não rastreados) no repositório da API;
> um checkout, stash ou clean as perderia. Ver "Pendências" abaixo.

---

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| App ↔ API pública (`/api/publico/*`) | Cliente anônimo na internet chama rotas `AllowAny`, sem autenticação | Parâmetros de busca/filtro/ordenação (não confiáveis) → listas e detalhes de imóveis da vitrine (dados públicos por allowlist) |
| API ↔ banco (Postgres) | ORM do Django; só `imoveis_da_vitrine()` alimenta a vitrine | Imóveis, empresas, corretores; dados internos (situação, contato, endereço exato) não podem sair |
| API → mídia (`/media/`) | URLs absolutas de fotos montadas pela API | URLs de imagem consumidas pelo app (filtradas por `urlHttpOuNula`) |
| Ferramental de dev (seed, captura de fixtures, runserver) | Comandos só para desenvolvimento | Dados fictícios; guarda de `DEBUG`; `.env` nunca lido pelos agentes |

---

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-05-01-01 | Information Disclosure | W08 public viewset/serializer (exposes codigo, empresa, cor… | high | mitigate | Removed in the merge resolution (D-10a); grep gate on the router/route names; W08 tests reapointed to the W09 allowlisted serializers | closed |
| T-05-01-02 | Information Disclosure / Access Control… | `imoveis_da_vitrine()` | high | mitigate | Single rule `Imovel.objects.na_vitrine()` (publicado + DISPONIVEL + empresa ativa) for list, detail and cities; `VitrineSituacaoTests` **[U]** | closed |
| T-05-01-03 | Information Disclosure | detail 404 | medium | mitigate | Same queryset for every non-vitrine state, test asserts the reserved/sold 404 body equals the nonexistent-id body (no enumeration) **[U]** | closed |
| T-05-01-04 | Tampering | git in the shared API repo and in the app repo | medium | mitigate | Blocking checkpoint (Task 1) covering both repos before any branch/merge/commit; choices recorded in 05-01-SUMMARY and read by every later… | closed |
| T-05-01-05 | Information Disclosure | Web/.env credentials | low | mitigate | Tests override DATABASE_URL by process env; this plan never connects to the dev DB; .env and .gitignore untouched | closed |
| T-05-01-SC | Tampering | package installs | low | accept | No package is installed in either repo (RESEARCH Package Legitimacy Audit: none) | closed |
| T-05-02-01 | Information Disclosure | LotePublicoSerializer / nested quadra-loteamento | high | mitigate | Explicit `fields` per serializer, no subclassing of the painel ones; exact-key tests for lote, quadra, loteamento; deny-list extended with… **[U]** | closed |
| T-05-02-02 | Information Disclosure | corretor_responsavel (empresa_id, contacts) | medium | mitigate | Informed user decision (Task 2 lists every contact field exposed without token) before freezing; exact-key test; the app declares only id/n… **[U]** | closed |
| T-05-02-03 | Information Disclosure | any future field added to a public serializer | medium | mitigate | Equality-of-keys tests fail on any new key, so exposure needs a deliberate test change (D-10) **[U]** | closed |
| T-05-02-04 | Spoofing (wrong city) | Loteamento.cidade diverging from the Imóvel endereço | low | mitigate | Vitrine annotations read only the Imóvel endereço; test lists the lote in its endereço city and not in the loteamento's city **[U]** | closed |
| T-05-02-05 | Denial of Service | nested lote detail query | low | mitigate | `select_related("lote__quadra__loteamento")` keeps the detail at a fixed number of queries **[U]** | closed |
| T-05-02-SC | Tampering | package installs | low | accept | No package installed | closed |
| T-05-03-01 | Repudiation / Integrity | invented city on the list item | low | mitigate | Entity field removed; the prévia shows only data the list carries; the header city comes from the detail payload (A-06) | closed |
| T-05-03-02 | Tampering | git in the app repo | low | mitigate | Commits only per the app choice recorded in 05-01-SUMMARY (checkpoint of 05-01); never push | closed |
| T-05-03-SC | Tampering | package installs | low | accept | No package added | closed |
| T-05-04-01 | Information Disclosure | BairrosDaCidadeAPIView | medium | mitigate | Derived only from `imoveis_da_vitrine()` filtered by city; test proves rascunho/reservado/inactive/other-city bairros are absent **[U]** | closed |
| T-05-04-02 | Tampering (V5) | natureza/bairro CSV | medium | mitigate | `_escolhas` allowlists natureza values (400 otherwise); bairro goes only through ORM `iexact` (parametrized), never raw SQL **[U]** | closed |
| T-05-04-03 | Elevation of Privilege (V2) | new views | low | mitigate | `AllowAny` + `authentication_classes = []`, read-only (405 on POST); invalid-token test **[U]** | closed |
| T-05-04-04 | Denial of Service | huge CSV in bairro | low | accept | Each item becomes one OR clause over an already city-filtered queryset; the app sends only bairros offered by /bairros/; no rate limiting i… | closed |
| T-05-04-05 | Tampering (data) | bairro name containing a comma | low | accept | D-07 locks CSV; documented as accepted risk (A-05) in README and contract | closed |
| T-05-04-SC | Tampering | package installs | low | accept | No package installed (no django-filter) | closed |
| T-05-05-01 | Tampering (V14) | semear_vitrine_dev in production | high | mitigate | `settings.DEBUG` guard kept + test with DEBUG=False raising CommandError and creating nothing **[U]** | closed |
| T-05-05-02 | Spoofing | seeded corretor accounts | medium | mitigate | `set_unusable_password()` on every seeded user — no default credentials; test asserts `has_usable_password()` is False **[U]** | closed |
| T-05-05-03 | Tampering | other companies' data | medium | mitigate | Seed only looks up the `NOME_EMPRESA_DEMO` company; test proves an unrelated Empresa is untouched **[U]** | closed |
| T-05-05-04 | Information Disclosure | Web/.env / user's dev DB | low | mitigate | Seed runs here only on a scratch SQLite DB passed by process env; migrate uses .env without reading or printing it; .env never edited | closed |
| T-05-05-05 | Tampering | git in the shared API repo | low | mitigate | Commits only per the API choice of the 05-01 checkpoint; explicit `git add` of the three .py files (never __pycache__); never push | closed |
| T-05-05-SC | Tampering | package installs | low | accept | Pillow already in the venv; nothing installed | closed |
| T-05-06-01 | Information Disclosure | Web/.env / user's dev DB | low | mitigate | Capture uses a scratch SQLite DB passed by process env; Web/.env never read, printed or edited | closed |
| T-05-06-02 | Information Disclosure | captured fixtures committed to the app repo | low | accept | Fixtures contain only fictitious seed data from public endpoints (no real person data) | closed |
| T-05-06-03 | Denial of Service (local) | background runserver left running | low | mitigate | Procedure stops the server; verify proves port 8000 is free | closed |
| T-05-06-SC | Tampering | package installs | low | accept | Capture script is stdlib-only; nothing installed | closed |
| T-05-07-01 | Information Disclosure | broker contact fields inside captured details | low | accept | Values are fictitious seed data; the app never declares them (05-14) and the exposure decision is the web team's (05-02 checkpoint, LGPD de… | closed |
| T-05-07-02 | Information Disclosure | Web/.env / user's dev DB | low | mitigate | Scratch SQLite DB by process env; Web/.env never read, printed or edited | closed |
| T-05-07-03 | Denial of Service (local) | background runserver left running | low | mitigate | Procedure stops the server; verify proves port 8000 is free | closed |
| T-05-07-SC | Tampering | package installs | low | accept | Stdlib-only script; nothing installed | closed |
| T-05-08-01 | Denial of Service | malformed cities JSON | medium | mitigate | Non-list body -> FormatException -> repository failure -> city-selection retry; invalid rows discarded | closed |
| T-05-08-02 | Tampering | saved city value | low | mitigate | Strict 2/3-part parsing, `int.tryParse`; a corrupted value reads as no city or no id, never a crash | closed |
| T-05-08-03 | Tampering | git in the app repo | low | mitigate | Commits only per the app choice recorded in 05-01-SUMMARY; never push | closed |
| T-05-08-SC | Tampering | package installs | low | accept | No package added to pubspec | closed |
| T-05-09-01 | Spoofing / Tampering | `ImovelRemoteDataSource.seguir(next)` | medium | mitigate | `_exigirMesmaOrigem` checks scheme/host/port against `API_BASE_URL` before any request; test proves no request leaves for another host | closed |
| T-05-09-02 | Tampering (V5) | URL building | low | mitigate | Path carries only `int` city id; every parameter goes through dio `queryParameters` (encoded), never string concatenation of user text | closed |
| T-05-09-03 | Tampering (V12/V13) | `foto_capa` URLs | medium | mitigate | `urlHttpOuNula` kept in `ImovelModel.paraEntidade()` | closed |
| T-05-09-04 | Information Disclosure | cleartext HTTP in development | low | accept | Cleartext only in debug manifests/`NSAllowsLocalNetworking` (RESEARCH Pitfall 11); production transport is outside this phase | closed |
| T-05-09-SC | Tampering | package installs | low | accept | No package added to pubspec | closed |
| T-05-10-01 | Tampering (V5) | `busca` in `parametrosDaApi` | low | mitigate | Text goes only through dio `queryParameters` (percent-encoded); the server re-validates | closed |
| T-05-10-02 | Denial of Service | malformed list JSON | medium | mitigate | `on TypeError`/`on Exception` in the repository -> `Result.failure` -> "Tentar de novo"; captured-wire tests | closed |
| T-05-10-03 | Repudiation / Integrity | app-side filtering | medium | mitigate | No filtering/reordering code in the app; only duplicate-id integrity guard; flow tests assert requests and rendering only (FIL-05) | closed |
| T-05-10-04 | Information Disclosure | search text in logs | low | accept | dio has no logging interceptor (modulo_rede.dart); nothing is logged | closed |
| T-05-10-SC | Tampering | package installs | low | accept | No package added | closed |
| T-05-11-01 | Tampering (V5) | `parametrosDaApi` | low | mitigate | Values go only through dio `queryParameters` (percent-encoded); numbers come from typed `int` fields; the server re-validates (400) **[U]** | closed |
| T-05-11-02 | Repudiation / Integrity | app-side filtering | medium | mitigate | No filtering/reordering code in the app; flow tests assert requests and rendering only (FIL-05 prohibition) | closed |
| T-05-11-03 | Tampering | data with a comma in a bairro name | low | accept | D-07 CSV; documented risk A-05 (05-04) | closed |
| T-05-11-SC | Tampering | package installs | low | accept | No package added | closed |
| T-05-12-01 | Tampering | característica/bairro rows | low | mitigate | Row validation (int id, non-empty nome/string), invalid rows discarded; rendered only as `Text` in chips (no HTML/links) | closed |
| T-05-12-02 | Denial of Service | malformed options JSON | low | mitigate | `on TypeError`/`on Exception` -> section-level failure with its own retry; the vitrine keeps working | closed |
| T-05-12-03 | Tampering (V5) | city id in the bairros path | low | mitigate | Only the `int` id from the parsed city builds the path; null id fails before any request | closed |
| T-05-12-SC | Tampering | package installs | low | accept | No package added | closed |
| T-05-13-01 | Tampering | característica names in chips | low | mitigate | Only rows validated in 05-12 reach the entity; rendered as plain `Text` | closed |
| T-05-13-02 | Denial of Service | malformed catalog | low | mitigate | Repository failure -> section-level retry (kept and tested) | closed |
| T-05-13-SC | Tampering | package installs | low | accept | No package added | closed |
| T-05-14-01 | Information Disclosure | broker contact fields in the payload | medium | mitigate | `CorretorModel` declares only id/nome/foto (grep gate); UI shows only name/photo (D-16); LGPD review deferred to the web team (05-02-SUMMAR… | closed |
| T-05-14-02 | Tampering (V12/V13) | `fotos[].imagem`, broker `foto` | medium | mitigate | `urlHttpOuNula` on every image URL | closed |
| T-05-14-03 | Denial of Service | malformed detail JSON | medium | mitigate | Repository maps TypeError/Exception to typed failures -> 'Tentar de novo' | closed |
| T-05-14-04 | Information Disclosure | exact address (logradouro/número/CEP) | low | accept | Already public in the W09 allowlist; the app parses it (D-15) but does not render it in this phase | closed |
| T-05-14-05 | Repudiation / Integrity | contract drift between repos | medium | mitigate | Exact-key contract test on every captured detail, mirrored by the Django exact-key tests of 05-02 **[U]** | closed |
| T-05-14-SC | Tampering | package installs | low | accept | No package added | closed |
| T-05-15-01 | Tampering (V5) | `caracteristicas` param | low | mitigate | Only `int` ids from parsed entities are joined; dio encodes; the server validates `int()` and returns 400 otherwise **[U]** | closed |
| T-05-15-02 | Repudiation / Integrity | app-side filtering | low | mitigate | The app only sends ids; matching is the server's (FIL-05); flows assert requests and rendering | closed |
| T-05-15-SC | Tampering | package installs | low | accept | No package added | closed |
| T-05-16-01 | Tampering (V12/V13) | `fotos[].imagem`, broker `foto` | medium | mitigate | `urlHttpOuNula` on every image URL; test drops a `javascript:` URL | closed |
| T-05-16-02 | Information Disclosure | broker profile | low | mitigate | Profile built from the in-memory id/nome/foto only; test proves no request to the corretores endpoint (D-16) | closed |
| T-05-16-03 | Information Disclosure | enumeration via 404 | low | mitigate | Server returns the same 404 (05-01); the app shows one message for all not-found cases | closed |
| T-05-16-04 | Denial of Service | closed page with request in flight | low | mitigate | `isClosed` guards; test proves no emission after close | closed |
| T-05-16-SC | Tampering | package installs | low | accept | No package added | closed |
| T-05-17-01 | Tampering | free text (areas_de_lazer, condicoes_parcelamento) | low | mitigate | Rendered as plain `Text` (no HTML, no links, no Markdown) | closed |
| T-05-17-02 | Denial of Service | unknown enum code | low | mitigate | Label functions fall back to the raw code; parse of unknown natureza/topografia stays tolerant (F4/D-14) | closed |
| T-05-17-03 | Repudiation / Integrity | derived values | low | mitigate | No arithmetic on areas, measures or prices in the app (grep gate on the removed lote price line; F4/D-04) | closed |
| T-05-17-SC | Tampering | package installs | low | accept | No package added | closed |
| T-05-18-01 | Repudiation / Integrity | contract drift between repos | medium | mitigate | Examples are byte copies of captured responses; contract tests (deep equality + exact keys) on both list and detail; Django exact-key tests… | closed |
| T-05-18-02 | Information Disclosure | dev server bound to 0.0.0.0 | low | accept | Only fictitious seed data; started for the check and stopped by the task; DEBUG dev-only (user's .env) | closed |
| T-05-18-03 | Tampering | shared repo history (API) and app repo history | medium | mitigate | Final gate proves no remote contains the local API HEAD; commits in both repos only per the choices recorded in the 05-01 checkpoint | closed |
| T-05-18-04 | Information Disclosure | Web/.env | low | mitigate | Never read, printed or edited; commands rely on it implicitly | closed |
| T-05-18-SC | Tampering | package installs | low | accept | No package installed | closed |
| T-05-19-01 | Denial of Service / Tampering | `_numero` (preco_*, area_*, quartos/suites/vagas) | high | mitigate | ASVS V5.1.3/V5.1.4: formato allowlist ASCII por `fullmatch` antes de converter, `is_finite()`, negativo e teto da própria coluna (`MAXIMO_F… **[U]** | closed |
| T-05-19-02 | Denial of Service | `busca`/`bairro` com NUL (WR-01) | medium | mitigate | `_texto`/`_bairros_do_filtro` recusam NUL em Python antes da consulta (independe do banco); teste de NUL em todo parâmetro garante "nunca 5… **[U]** | closed |
| T-05-19-03 | Denial of Service | `busca` longa e CSV de bairro sem teto (WR-02) | medium | mitigate | `MAXIMO_CARACTERES_BUSCA = 200`, `MAXIMO_BAIRROS = 20`, `MAXIMO_CARACTERES_BAIRRO = 100` -> 400; custo por requisição limitado **[U]** | closed |
| T-05-19-04 | Information Disclosure | 500 com traceback (DEBUG=True em dev) | low | mitigate | ASVS V7.4.1: entrada hostil vira 400 com mensagem genérica em português, sem detalhe interno **[U]** | closed |
| T-05-19-05 | Repudiation / Integrity | promessa "400 {campo: mensagem}" do contrato | medium | mitigate | Testes travam status e mensagem; o 05-22 lista cada mensagem nova no contrato **[U]** | closed |
| T-05-19-SC | Tampering | instalação de pacotes | low | accept | Nenhum pacote instalado (`re` é da biblioteca padrão) | closed |
| T-05-20-01 | Denial of Service | filtro `caracteristicas` (CR-01) | high | mitigate | Teto `MAXIMO_CARACTERISTICAS = 20` antes da consulta + uma subconsulta agregada de forma constante; teste de formato do SQL com `CaptureQue… **[U]** | closed |
| T-05-20-02 | Tampering | ids `0`, negativos, `1_0`, dígito não ASCII | low | mitigate | ASVS V5.1.3: allowlist `_FORMATO_ID` + positivo -> 400 com mensagem do contrato **[U]** | closed |
| T-05-20-03 | Integrity | regra "tem todas" (D-13) | medium | mitigate | `test_filtro_caracteristicas_exige_todas` sem edição + teste com id inexistente; HAVING COUNT DISTINCT = quantidade pedida **[U]** | closed |
| T-05-20-SC | Tampering | instalação de pacotes | low | accept | Nenhum pacote instalado | closed |
| T-05-21-01 | Denial of Service | rotas públicas sem limite (WR-02, agravante do CR-01) | high | mitigate | ASVS V11.1.4 (anti-automação): `ThrottleVitrinePublica` nas 5 views, balde único por IP, 429 + Retry-After; testes de 429 por rota e de bal… **[U]** | closed |
| T-05-21-02 | Spoofing | identidade do cliente pelo X-Forwarded-For | medium | mitigate | `NUM_PROXIES = 0` por padrão (REMOTE_ADDR); teste com XFF forjado **[U]** | closed |
| T-05-21-03 | Elevation / regressão | throttle global atingindo a API autenticada | medium | mitigate | Sem lista global de throttles (checado por `api_settings` e por teste com corretor autenticado) **[U]** | closed |
| T-05-21-04 | Denial of Service (de usuário legítimo) | IP compartilhado (CGNAT, proxy sem NUM_PROXIES) | medium | accept | Taxa folgada (120/min) e ajustável por `VITRINE_TAXA_ANONIMA`; item de deploy documentado pelo 05-22 | closed |
| T-05-21-05 | Denial of Service | `LocMemCache` por processo (vários workers multiplicam o li… | low | accept | ASVS nível 1; cache compartilhado registrado como item de deploy pelo 05-22 | closed |
| T-05-21-06 | Repudiation | suíte instável escondendo regressão | low | mitigate | `cache.clear()` por teste nas 3 bases que chamam rota pública; suíte inteira duas vezes seguidas **[U]** | closed |
| T-05-21-07 | Denial of Service | rotas públicas da frente web (corretores/<id>/, empresas/<i… | low | accept | Fora do escopo desta rodada (não consumidas pelo app, donas: frente web); registrado no SUMMARY e no contrato | closed |
| T-05-21-SC | Tampering | instalação de pacotes | low | accept | Nenhum pacote instalado (throttle é do DRF já instalado) | closed |
| T-05-22-01 | Repudiation / Integrity | drift entre contrato, README e código | medium | mitigate | Cada mensagem e teto do contrato é conferido por grep contra o `views.py`; testes do app travam 400/429; testes Django travam o servidor **[U]** | closed |
| T-05-22-02 | Information Disclosure | corpo dos erros 400/429 | low | accept | Mensagens só citam o campo e o limite; `{detail}` padrão do DRF; nada interno | closed |
| T-05-22-03 | Tampering | histórico da API e do app | medium | mitigate | opcao-a: zero commits na API (HEAD 0592176 checado) e nenhum remoto com o HEAD; app: nenhum commit sem OK do usuário (gate `git log 5f8dc69… | closed |
| T-05-22-04 | Information Disclosure | `Web/.env` | low | mitigate | Nunca lido, impresso nem editado; os comandos dependem dele só implicitamente | closed |
| T-05-22-SC | Tampering | instalação de pacotes | low | accept | Nenhum pacote instalado | closed |

*Status: open · closed · open — below high threshold (non-blocking)*
*Severity: critical > high > medium > low — only open threats at or above workflow.security_block_on count toward threats_open*
*Disposition: mitigate (implementation required) · accept (documented risk) · transfer (third-party)*
*[U] = mitigação presente só em código não commitado do repositório da API (verificada na árvore de trabalho).*

### Evidência das ameaças de severidade alta

| Threat ID | Evidência (auditor) |
|-----------|---------------------|
| T-05-01-01 | Viewset/serializer/rota da W08 ausentes no HEAD `0592176` da API (remoção commitada); `Web/imoveis/api/urls_publico.py:10-23` sem router |
| T-05-01-02 | `Web/imoveis/models.py:15-19` `na_vitrine()`, `Web/imoveis/vitrine.py:39`, usado em lista/bairros/detalhe/cidades; testes `VitrineSituacaoTests` [U] |
| T-05-02-01 | Serializers públicos de Loteamento/Quadra/Lote independentes com `fields` explícitos (`serializers.py:483-512`); testes de chaves exatas [U] |
| T-05-05-01 | Guarda de `DEBUG` em `Web/empresas/management/commands/semear_vitrine_dev.py:137-141` (não rastreado); teste com `DEBUG=False` [U] |
| T-05-19-01 | Validação ASCII/finita/não negativa/tetos por coluna em `views.py:320-371`; testes `imoveis/tests.py:1424-1474` [U] |
| T-05-20-01 | Teto de 20 ids antes de qualquer query + subquery agregada única (`views.py:346,421-424,525-532`); testes de 0 queries e forma do SQL [U] |
| T-05-21-01 | `Web/core/throttles.py` (não rastreado), `throttle_classes` nas rotas públicas, taxa em `settings.py:138-143,162-164`; testes `imoveis/tests.py:1191-1222` [U] |

---

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---------|------------|-----------|-------------|------|
| AR-05-01 | T-05-01-SC | No package is installed in either repo (RESEARCH Package Legitimacy Audit: none) | plano 05-01 (registro do plano) | 2026-11-16 |
| AR-05-02 | T-05-02-SC | No package installed | plano 05-02 (registro do plano) | 2026-11-16 |
| AR-05-03 | T-05-03-SC | No package added | plano 05-03 (registro do plano) | 2026-11-16 |
| AR-05-04 | T-05-04-04 | Each item becomes one OR clause over an already city-filtered queryset; the app sends only bairros offered by /bairros/; no rate limiting in scope | plano 05-04 (registro do plano) | 2026-11-16 |
| AR-05-05 | T-05-04-05 | D-07 locks CSV; documented as accepted risk (A-05) in README and contract | plano 05-04 (registro do plano) | 2026-11-16 |
| AR-05-06 | T-05-04-SC | No package installed (no django-filter) | plano 05-04 (registro do plano) | 2026-11-16 |
| AR-05-07 | T-05-05-SC | Pillow already in the venv; nothing installed | plano 05-05 (registro do plano) | 2026-11-16 |
| AR-05-08 | T-05-06-02 | Fixtures contain only fictitious seed data from public endpoints (no real person data) | plano 05-06 (registro do plano) | 2026-11-16 |
| AR-05-09 | T-05-06-SC | Capture script is stdlib-only; nothing installed | plano 05-06 (registro do plano) | 2026-11-16 |
| AR-05-10 | T-05-07-01 | Values are fictitious seed data; the app never declares them (05-14) and the exposure decision is the web team's (05-02 checkpoint, LGPD deferred) | plano 05-07 (registro do plano) | 2026-11-16 |
| AR-05-11 | T-05-07-SC | Stdlib-only script; nothing installed | plano 05-07 (registro do plano) | 2026-11-16 |
| AR-05-12 | T-05-08-SC | No package added to pubspec | plano 05-08 (registro do plano) | 2026-11-16 |
| AR-05-13 | T-05-09-04 | Cleartext only in debug manifests/`NSAllowsLocalNetworking` (RESEARCH Pitfall 11); production transport is outside this phase | plano 05-09 (registro do plano) | 2026-11-16 |
| AR-05-14 | T-05-09-SC | No package added to pubspec | plano 05-09 (registro do plano) | 2026-11-16 |
| AR-05-15 | T-05-10-04 | dio has no logging interceptor (modulo_rede.dart); nothing is logged | plano 05-10 (registro do plano) | 2026-11-16 |
| AR-05-16 | T-05-10-SC | No package added | plano 05-10 (registro do plano) | 2026-11-16 |
| AR-05-17 | T-05-11-03 | D-07 CSV; documented risk A-05 (05-04) | plano 05-11 (registro do plano) | 2026-11-16 |
| AR-05-18 | T-05-11-SC | No package added | plano 05-11 (registro do plano) | 2026-11-16 |
| AR-05-19 | T-05-12-SC | No package added | plano 05-12 (registro do plano) | 2026-11-16 |
| AR-05-20 | T-05-13-SC | No package added | plano 05-13 (registro do plano) | 2026-11-16 |
| AR-05-21 | T-05-14-04 | Already public in the W09 allowlist; the app parses it (D-15) but does not render it in this phase | plano 05-14 (registro do plano) | 2026-11-16 |
| AR-05-22 | T-05-14-SC | No package added | plano 05-14 (registro do plano) | 2026-11-16 |
| AR-05-23 | T-05-15-SC | No package added | plano 05-15 (registro do plano) | 2026-11-16 |
| AR-05-24 | T-05-16-SC | No package added | plano 05-16 (registro do plano) | 2026-11-16 |
| AR-05-25 | T-05-17-SC | No package added | plano 05-17 (registro do plano) | 2026-11-16 |
| AR-05-26 | T-05-18-02 | Only fictitious seed data; started for the check and stopped by the task; DEBUG dev-only (user's .env) | plano 05-18 (registro do plano) | 2026-11-16 |
| AR-05-27 | T-05-18-SC | No package installed | plano 05-18 (registro do plano) | 2026-11-16 |
| AR-05-28 | T-05-19-SC | Nenhum pacote instalado (`re` é da biblioteca padrão) | plano 05-19 (registro do plano) | 2026-11-16 |
| AR-05-29 | T-05-20-SC | Nenhum pacote instalado | plano 05-20 (registro do plano) | 2026-11-16 |
| AR-05-30 | T-05-21-04 | Taxa folgada (120/min) e ajustável por `VITRINE_TAXA_ANONIMA`; item de deploy documentado pelo 05-22 | plano 05-21 (registro do plano) | 2026-11-16 |
| AR-05-31 | T-05-21-05 | ASVS nível 1; cache compartilhado registrado como item de deploy pelo 05-22 | plano 05-21 (registro do plano) | 2026-11-16 |
| AR-05-32 | T-05-21-07 | Fora do escopo desta rodada (não consumidas pelo app, donas: frente web); registrado no SUMMARY e no contrato | plano 05-21 (registro do plano) | 2026-11-16 |
| AR-05-33 | T-05-21-SC | Nenhum pacote instalado (throttle é do DRF já instalado) | plano 05-21 (registro do plano) | 2026-11-16 |
| AR-05-34 | T-05-22-02 | Mensagens só citam o campo e o limite; `{detail}` padrão do DRF; nada interno | plano 05-22 (registro do plano) | 2026-11-16 |
| AR-05-35 | T-05-22-SC | Nenhum pacote instalado | plano 05-22 (registro do plano) | 2026-11-16 |

*Accepted risks do not resurface in future audit runs.*

---

## Pendências e observações (não bloqueantes)

1. **Mitigações não commitadas na API.** Quatro das sete ameaças altas (T-05-02-01, T-05-19-01, T-05-20-01, T-05-21-01), o seed com a guarda de `DEBUG` (T-05-05-01) e os testes correspondentes estão só na árvore de trabalho de `imoveis-aqui/Web` (`feat/APP05`); `core/throttles.py`, `core/checks.py` e `empresas/management/` não são rastreados. Commitar na API (com OK do usuário) antes de considerar a fase entregue.
2. **App:** `test/data/imovel_remote_datasource_test.dart`, `test/data/imovel_detalhe_repository_impl_test.dart` e `01-CONTRATO-API.md` alterados e não commitados (T-05-22-01, T-05-19-05).
3. **Servidor de dev em `0.0.0.0:8000`** iniciado em 2026-11-16 para o UAT no emulador; parar ao terminar (premissa de T-05-06-03, T-05-07-03, T-05-18-02).
4. **Push de `origin/feat/APP05` no app** (até `5f8dc69`, 2026-11-16 14:15) sem registro no planejamento; confirmar que foi o usuário.
5. **Caminho de imagem sem filtro, não usado:** `FotoImovelModel.paraEntidade()` em `lib/data/models/detalhe_imovel_model.dart:163` não passa por `urlHttpOuNula`; nada o chama hoje. Remover ou rotear pelo filtro.
6. **WR-08:** sem `NUM_PROXIES` em produção, `check --deploy` só avisa (`core.W001`); item do checklist de deploy.

---

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-11-16 | 106 | 106 | 0 | gsd-security-auditor (ASVS L1, block_on high) |

---

## Sign-Off

- [x] All threats have a disposition (mitigate / accept / transfer)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed
- [x] `status: verified` set in frontmatter

**Approval:** verified 2026-11-16 (árvore de trabalho; ver Pendências 1–2)
