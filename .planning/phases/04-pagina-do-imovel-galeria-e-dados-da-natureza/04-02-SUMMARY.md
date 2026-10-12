---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
plan: 02
subsystem: api
tags: [contrato, drf, allowlist, json, flutter_test, requirements]

# Dependency graph
requires:
  - phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
    provides: "04-01: detalhesAcervoFixture() com a entrada 42, DetalheImovelModel.fromJson/paraEntidade e o e2e de navegacao"
provides:
  - "01-CONTRATO-API.md §11: contrato de GET /api/publico/imoveis/{id}/ (404 igual, campos comuns, blocos por natureza, area_livre do servidor, pendencias E2 a-k) + emenda do §6"
  - "contrato/imovel_detalhe.example.json: apartamento 42 com predio, identico a entrada 42 da fixture"
  - "test/data/contrato_detalhe_test.dart: parse, igualdade exemplo x fixture, allowlists nomeadas por objeto e varredura de chaves proibidas aplicadas a toda entrada da fixture"
  - "REQUIREMENTS.md/ROADMAP.md com DET-01..06 e API-06 na Phase 4 e API-07 na Phase 5"
affects: [04-03, 04-04, 04-05, 04-06, 04-07, 04-08, 05]

# Actuals (#2632) — chars/4 over files actually changed
actuals:
  tokens: 6000
  tasks: 2
  commits: 2
plan_head_before: 43c9c118191d9a4979e77c2b76594c26dfe75086

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Teste de contrato: exemplo JSON do contrato lido do disco e comparado por igualdade profunda com a fixture do mock"
    - "Allowlists por objeto como constantes nomeadas; toda entrada nova da fixture e checada automaticamente"
    - "Varredura recursiva de chaves proibidas (proprietario, email, telefone, whatsapp, creci, empresa, logradouro, cep, cpf, cnpj, documento)"

key-files:
  created:
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_detalhe.example.json
    - test/data/contrato_detalhe_test.dart
  modified:
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md
    - lib/data/mocks/imoveis_detalhe_fixture.dart
    - .planning/REQUIREMENTS.md
    - .planning/ROADMAP.md

key-decisions:
  - "§11 lista os itens PENDENTE E2 a-k, cada um com o tratamento defensivo do app (slug nullable, posicao_solar como texto da API, IPTU sem periodo, lote.preco so se vier); nenhum e tratado como decidido pelo app"
  - "Emenda do §6 e um paragrafo no fim do §6 apontando para o §11, sem reescrever a allowlist da lista"
  - "Alem das pendencias a-g do plano, o §11 registra j (lat/lng como string decimal, assuncao A3) e k (natureza/blocos dependem de WEB 05/06/07)"

patterns-established:
  - "Contrato escrito + exemplo + mock + teste de contrato andam juntos: mudar um sem os outros quebra o teste"

requirements-completed: []  # API-06 e declarado tambem por 04-04 e 04-05 (requirements.ready-ids: 0/1); fica Pending ate o ultimo plano que o declara

coverage:
  - id: D1
    description: "O adendo §11 de GET /api/publico/imoveis/{id}/ esta escrito em 01-CONTRATO-API.md para sign-off do E2, com 404 igual para inexistente e nao publicado, natureza em bloco por tipo, predio e quadra/loteamento embutidos, area_livre calculada no servidor, allowlist explicita e pendencias PENDENTE E2"
    requirement: API-06
    verification:
      - kind: other
        ref: "grep -q '^## 11\\.' e grep -q 'PENDENTE E2' em 01-CONTRATO-API.md"
        status: pass
    human_judgment: true
    rationale: "Adequacao e completude do texto do contrato para o E2 sao julgamento humano; o grep so prova que as secoes existem"
  - id: D2
    description: "imovel_detalhe.example.json e identico ao detalhe 42 servido pelo mock e todo detalhe da fixture usa so chaves da allowlist, sem chave proibida em nenhum nivel"
    requirement: API-06
    verification:
      - kind: unit
        ref: "test/data/contrato_detalhe_test.dart#imovel_detalhe.example.json (§11) é idêntico ao detalhe 42 que o mock serve"
        status: pass
      - kind: unit
        ref: "test/data/contrato_detalhe_test.dart#fixture do detalhe toda entrada respeita a allowlist e não vaza chave proibida"
        status: pass
      - kind: unit
        ref: "test/data/contrato_detalhe_test.dart#guarda da allowlist (prova de que o teste falha ao vazar)"
        status: pass
    human_judgment: false
  - id: D3
    description: "O exemplo do contrato parseia pelo DetalheImovelModel do app (id 42, venda, 3 fotos com a primeira capa, corretor Marina Lopes) e o e2e do 04-01 segue verde"
    requirement: API-06
    verification:
      - kind: unit
        ref: "test/data/contrato_detalhe_test.dart#imovel_detalhe.example.json (§11) parseia pelo Model do app e vira a entidade esperada"
        status: pass
      - kind: e2e
        ref: "test/presentation/detalhe_navegacao_test.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "REQUIREMENTS.md tem DET-01..06 e API-06 mapeados a Phase 4 e API-07 a Phase 5; o ROADMAP aponta esses IDs nas duas fases e nada mais mudou"
    verification:
      - kind: other
        ref: "grep gates do plano (Requirements do ROADMAP, 7 linhas Phase 4 + API-07 Phase 5, ausencia de 'to be detailed in discuss' e do bullet v2 DET-01)"
        status: pass
    human_judgment: false

# Metrics
duration: 3min
completed: 2026-10-12
status: complete
---

# Phase 4 Plan 02: Contrato do Detalhe Summary

**Contrato do detalhe congelado por escrito (§11 + exemplo) para sign-off do E2, servido tal e qual pelo mock sob um teste de allowlist por objeto, e IDs DET-01..06/API-06/API-07 rastreados em REQUIREMENTS e ROADMAP**

## Performance

- **Duration:** ~3 min
- **Started:** 2026-10-12T05:21:42Z
- **Completed:** 2026-10-12T05:25:00Z
- **Tasks:** 2
- **Files modified:** 6 (2 criados, 4 modificados)

## Accomplishments

- §11 de `01-CONTRATO-API.md`: endpoint `GET /api/publico/imoveis/{id}/` (`AllowAny`, `publicado=True`, 404 igual para inexistente e nao publicado), tabela dos campos comuns, uma tabela por bloco de natureza (casa, terreno, apartamento com predio, lote com quadra e loteamento), regra de `area_livre` vinda do servidor (`null`, nunca `0`) e lista PENDENTE E2 (a-k) com o tratamento defensivo do app ao lado de cada item. O §6 ganhou a emenda apontando para o §11 (condominio e IPTU publicos so no detalhe; corretor so `id/nome/foto/slug`).
- `contrato/imovel_detalhe.example.json` (apartamento 42) e a entrada 42 de `detalhesAcervoFixture()` passam a ser identicas, com `natureza`, `apartamento.predio`, `casa/terreno/lote: null`.
- `test/data/contrato_detalhe_test.dart` (7 testes): parse pelo Model, igualdade profunda exemplo x fixture, allowlist por objeto (comum, cidade, foto, corretor, casa, terreno, apartamento, predio, lote, quadra, loteamento) para o exemplo E para toda entrada da fixture, coerencia natureza x bloco, varredura recursiva de chaves proibidas e dois testes que provam que a guarda realmente falha ao vazar.
- REQUIREMENTS.md: secao `Página do imóvel (APP04)` com DET-01..06, API-06/API-07 em "API pública", bullet v2 de DET-01 removido, rastreabilidade e contagem (30/30). ROADMAP: so as duas linhas `**Requirements**` das Phases 4 e 5.

## Task Commits

1. **Task 1: Contrato do detalhe (§11 + exemplo), mock servindo o exemplo, guarda de allowlist** - `3e63b82` (feat)
2. **Task 2: IDs de requisito registrados e rastreados** - `1f68f1e` (docs)

**Plan metadata:** commit `docs(04-02)` seguinte a este arquivo

## Files Created/Modified

- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` - §11 novo + emenda no fim do §6
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_detalhe.example.json` - exemplo de wire do detalhe 42
- `lib/data/mocks/imoveis_detalhe_fixture.dart` - entrada 42 = exemplo, verbatim
- `test/data/contrato_detalhe_test.dart` - teste de contrato e guarda de allowlist
- `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md` - requisitos da fase

## Decisions Made

- Pendencias do E2 registradas como a-k no §11: as sete do plano (a-g), mais h (`laterais`: uma medida ou duas) e i (qual area a `area` da lista espelha) que o plano pedia, e j (lat/lng string decimal, assuncao A3) e k (natureza e blocos dependem de WEB 05/06/07) que o proprio texto do contrato ja implicava. Nenhuma foi decidida pelo app.
- O teste de contrato exige no maximo um bloco de natureza preenchido e coerente com `natureza`; `natureza` ausente exige zero blocos. Assim as proximas fixtures (04-05) nao conseguem violar o "exatamente um bloco" do §11.
- `requirements-completed` fica vazio: API-06 tambem e declarado por 04-04 e 04-05 (`requirements.ready-ids` 0/1), entao nao foi marcado como completo agora.

## Deviations from Plan

None - plan executed exactly as written.

(Acrescimos de escopo minimo dentro da Task 1: o teste inclui a checagem natureza x bloco e dois testes de prova da guarda; nenhum e um arquivo ou comportamento fora do plano.)

## Issues Encountered

None. Disco com 2,2 GiB livres no inicio (acima do minimo de 2 GiB da precondicao); `flutter test` e `flutter analyze` rodaram sem problema.

## Known Stubs

None. (A fixture continua servindo so o id 42; isso ja estava registrado no 04-01 e e ampliado nos planos 04-04/04-05.)

## Threat Flags

None - nenhuma superficie nova alem do `<threat_model>` do plano. T-04-02-01 mitigado pelo teste de allowlist/chaves proibidas; T-04-02-02 e T-04-02-03 transferidos ao E2 (§11.1 e §11.5 g).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Contrato, exemplo e guarda prontos: os planos 04-04/04-05 ampliam a fixture e o Model com os blocos de natureza e o teste de contrato ja cobre as entradas novas.
- Pendente fora do app: copiar o §11 e o exemplo para `../imoveis-aqui/Web` e obter o sign-off do E2 (passo manual do §8/§11.6).

## Self-Check: PASSED

- Arquivos criados conferidos no disco; commits `3e63b82` e `1f68f1e` presentes em `git log`.
- `flutter test` (392 testes) e `flutter analyze` sem issues; verificacoes do plano (grep §11/PENDENTE E2, `json.tool` do exemplo, gates de REQUIREMENTS/ROADMAP) verdes.

---
*Phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza*
*Completed: 2026-10-12*
