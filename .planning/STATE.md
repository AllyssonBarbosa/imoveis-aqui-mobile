---
gsd_state_version: "1.0"
current_phase: 08
current_phase_name: Login e Área do Corretor — o Acervo
status: executing
stopped_at: Completed 08-01-PLAN.md
last_updated: "2026-11-21T12:58:37.158Z"
last_activity: 2026-11-21
last_activity_desc: Phase 08 execution started
state_head: 6a3676617f50bbee204e90b179068b7264cfaea4
progress:
  total_phases: 8
  completed_phases: 2
  total_plans: 74
  completed_plans: 63
  percent: 25
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-11-20)

**Core value:** A vitrine do app abre na cidade do usuário e mostra imóveis reais vindos da API, com a busca e o filtro resolvidos no servidor — o mesmo dado e a mesma regra do site, nunca recalculados dentro do aparelho.
**Current focus:** Phase 08 — Login e Área do Corretor — o Acervo

## Current Position

Phase: 08 (Login e Área do Corretor — o Acervo) — EXECUTING
Plan: 2 of 12
Status: Ready to execute
Last activity: 2026-11-21 — Phase 08 execution started

Progress: [████████████████████] 62/62 plans ([███░░░░░░░] 25%)

## Performance Metrics

**Velocity:**

- Total plans completed: 40
- Average duration: - min
- Total execution time: 0 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 05 | 22 | - | - |
| 07.1 | 6 | - | - |
| 07 | 12 | - | - |

**Recent Trend:**

- Last 5 plans: -
- Trend: -

*Updated after each plan completion*
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 01 P02 | 6 min | 2 tasks | 3 files |
| Phase 02 P01 | 25min | 2 tasks | 36 files |
| Phase 02 P02 | 11min | 2 tasks | 8 files |
| Phase 02 P03 | 22 min | 3 tasks | 9 files |
| Phase 02 P04 | 27 min | 2 tasks | 22 files |
| Phase 02 P05 | 17min | 3 tasks | 12 files |
| Phase 03 P01 | 50min | 2 tasks | 21 files |
| Phase 4 P01 | 25 min | 2 tasks | 24 files |
| Phase 04 P02 | 3 min | 2 tasks | 6 files |
| Phase 04 P03 | 15 min | 2 tasks | 9 files |
| Phase 04 P04 | 9 min | 2 tasks | 10 files |
| Phase 04 P05 | 12 min | 2 tasks | 15 files |
| Phase 04 P06 | 16 min | 2 tasks | 7 files |
| Phase 04 P07 | 10 min | 2 tasks | 8 files |
| Phase 04 P08 | 5 min | 2 tasks | 10 files |
| Phase 05 P01 | 5 min | 3 tasks | 6 files |
| Phase 05 P02 | 12min | 3 tasks | 4 files |
| Phase 05 P03 | 25min | 2 tasks | 11 files |
| Phase 05 P04 | 15min | 2 tasks | 4 files |
| Phase 05 P05 | 25min | 3 tasks | 6 files |
| Phase 05 P06 | 15min | 2 tasks | 9 files |
| Phase 05 P07 | 8min | 2 tasks | 8 files |
| Phase 05 P08 | 20min | 2 tasks | 9 files |
| Phase 05 P09 | 25 min | 2 tasks | 12 files |
| Phase 05 P10 | 30min | 2 tasks | 8 files |
| Phase 05 P11 | 45min | 2 tasks | 17 files |
| Phase 05 P12 | 30min | 2 tasks | 12 files |
| Phase 05 P13 | 25min | 2 tasks | 11 files |
| Phase 05 P14 | 45min | 2 tasks | 18 files |
| Phase 05 P15 | 20min | 2 tasks | 13 files |
| Phase 05 P16 | 25min | 2 tasks | 9 files |
| Phase 05 P17 | 40min | 2 tasks | 8 files |
| Phase 05 P18 | 35min | 3 tasks | 12 files |
| Phase 05 P19 | 12 min | 2 tasks | 2 files |
| Phase 05 P20 | 10min | 2 tasks | 2 files |
| Phase 05 P21 | 15min | 2 tasks | 7 files |
| Phase 05 P22 | 20min | 2 tasks | 4 files |
| Phase 07.1 P01 | 11 min | 2 tasks | 12 files |
| Phase 07.1 P02 | 28 min | 2 tasks | 8 files |
| Phase 07.1 P03 | 7 min | 2 tasks | 15 files |
| Phase 07.1 P04 | 15 min | 2 tasks | 8 files |
| Phase 07.1 P05 | 25min | 2 tasks | 1 files |
| Phase 07.1 P06 | 25min | 3 tasks | 5 files |
| Phase 08 P01 | 5 min | 2 tasks | 4 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: API-01 (contract freeze) bundled into Phase 1 alongside APP01 rather than as a standalone phase — research called it parallelizable with zero-API-dependency APP01; keeps it from being a thin, non-user-observable single-requirement phase.
- [Roadmap]: API-02 (`GET /cidades` real endpoint) folded into Phase 2 rather than a standalone phase — Phase 2 is where the app actually consumes it (VIT-06), so build+consume ship as one coherent, user-observable capability.
- [Roadmap]: API-03 (`GET /imoveis` real endpoint) kept as its own final Phase 5 (renumbered from 4 when APP 04 was inserted) per explicit project constraint — genuinely gated on the teammate's (E2) `Imóvel` model landing in the sibling API repo.
- [Phase 01]: GET /cidades e GET /imoveis frozen contract written (01-CONTRATO-API.md), grounded in real sibling Django models; corrected stale PROJECT.md note that the Imovel model didn't exist. — Public serializer must use an explicit allowlist and never the authenticated ImovelSerializer; tipologia fields marked PENDENTE E2; four semantically-open items (quartos/suites/vagas range-vs-exact, cidade param format, VENDA_E_ALUGUEL card price, ordenacao values) flagged for web-team sign-off instead of guessed.
- [Phase 02]: ImovelMockDataSource filtra/ordena sobre mapas de wire (snake_case) e só então parseia via ImoveisEnvelopeModel.fromJson — Garante que o parsing exercitado nos testes é idêntico ao usado contra o endpoint real na Fase 5
- [Phase 02]: [Phase 02-02]: GET /api/publico/cidades/ real criado no repo irmão (AllowAny, cursor page_size=50, servido-only) + seed idempotente semear_vitrine_dev; tudo uncommitted em feat/APP02 aguardando autorização do usuário
- [Phase 02]: [Phase 02-02]: Adendos da Fase 2 (busca D-05, ordenacao D-11, preço-base nulls-last D-12 + risco CursorPagination) registrados em 01-CONTRATO-API.md §9, pendentes de sign-off do E2
- [Phase 02]: [Phase 02-03]: Instante-base da fixture (2026-07-20) escolhido anterior a todas as 3 datas verbatim do contrato — linhas 42/57/63 continuam na 1a pagina apos expandir para 40 imoveis/cidade
- [Phase 02]: [Phase 02-04]: Cidades trocadas do asset fixo para GET /api/publico/cidades/ via Dio (D-16/D-17); falha do endpoint nao bloqueia mais quem ja tem cidade salva (autorizadaEAtendida direto)
- [Phase 02]: [Phase 02-05]: D-10 interpretado como botão Ordenar na linha logo abaixo da SearchBar (nao lado a lado) - a 360dp os dois nao cabem juntos; sinalizado no human-check de fim de fase para confirmacao do usuario
- [Phase 02]: [Phase 02-05]: keepScrollOffset:false so restaura o topo com um ScrollPosition NOVO; troca de busca/ordenacao reconstroi o mesmo ListView/controller in-place, entao D-13 precisou de jumpTo(0) explicito num BlocConsumer.listener quando ConteudoVitrine.carregando reaparece
- [Phase 03]: [Phase 03-01]: TDD explícito na Task 2 (RED->GREEN, sem REFACTOR necessário); ImovelMockDataSource refatorado em pipeline não-async (_paginarPelosParametros) + async (_montarPagina), preservando o throw síncrono de FormatException para cidade/ordenacao/cursor inválidos
- [Phase 03]: [Phase 03-01]: next/previous do mock passam a carregar o mesmo mapa de query params recebido (menos cursor) em vez de reconstruir via parametrosDaConsulta — todo filtro futuro sobrevive à paginação automaticamente
- [Phase 4]: 04-01: abrirDetalheImovel e o unico ponto que resolve o DetalheImovelCubit no DI (no toque); VitrineScreen recebe aoAbrirImovel (default abrirDetalheImovel) para manter testes da vitrine sem DI — Mantem widgets testaveis e sem dependencia oculta (T-04-01-04)
- [Phase 4]: 04-01: mock do detalhe serve mapas de wire parseados por DetalheImovelModel.fromJson; ImovelNaoEncontradoException simula o 404 (D-01) — Troca mock->real na Fase 5 vira so mudanca de DI (API-07)
- [Phase 04]: 04-02: §11 do contrato lista pendencias E2 a-k com tratamento defensivo do app; teste de contrato guarda allowlist por objeto e coerencia natureza x bloco em toda entrada da fixture — Congela o wire do detalhe por escrito sem decidir pelo E2; fixtures futuras (04-04/04-05) sao checadas automaticamente
- [Phase 04]: 404 detectado só em data/ (DioException 404 -> ImovelNaoEncontradoException); presentation decide só pelo tipo de domínio e esconde a prévia (preço) no 404 — Repetir não resolve um imóvel despublicado; a Fase 5 troca a DataSource sem tocar acima do repositório
- [Phase 04]: 04-04: detalhe gerado deriva de linhasAcervoFixture (id%10==9 = campos nulos; fotos extras id%4; corretores id%3; ids 338 falha / 339 404) — Todo card abre um detalhe coerente e os fluxos de erro/404 ficam provaveis a mao, sem Random nem relogio
- [Phase 04]: 04-04: urlHttpOuNula (data/models/url_segura.dart) filtra http/https em fotos, capa da lista e foto do corretor — URLs vindas da API sao nao confiaveis (V12/V13); filtro na camada de dados mantem a ordem recebida
- [Phase 04]: 04-05: blocos de natureza parseados por switch (natureza) com curinga para null; fixture varia por id ~/ 4 (id % 4 e constante por natureza); area_livre vem pronta do servidor (57: 300/180/100) e lote.preco so existe no 103 — Natureza desconhecida/bloco incoerente nunca derruba o parse (D-14); o app nunca calcula area (D-04); lote.preco nunca derivado de preco_venda (D-19 d)
- [Phase 04]: 04-06: LinhasDeDados em secoes_detalhe.dart e quadraTemConteudo pura compartilhada; card da secao por switch exaustivo com guardas, sem default — Evita import circular e mantem a decisao de quais linhas existem em funcoes puras (D-13, D-14)
- [Phase 04]: 04-07: @visibleForTesting only on DetalheImovelScreen and FotoCapaImovel; ImagemRede/GaleriaImovel pass the test hook through without the annotation (analyzer warns otherwise)
- [Phase 04]: 04-07: viewer locks PageView swipe via NeverScrollableScrollPhysics while the visible photo is zoomed (A1); real pinch feel left to end-of-phase human check
- [Phase 04]: 04-08: IPTU sem periodo ate o E2 (D-19 c); cabecalho usa precos da parte comum inclusive para lote (D-19 d); perfil do corretor abre com o objeto em memoria, sem rede nem contato (D-15) — Regras de negocio pendentes do E2 nao sao decididas no app
- [Phase 05]: Fase 5 git: opcao-a + app-a (API: só commit do merge, resto sem commit; app: commit por task na feat/APP05; nunca push)
- [Phase 05]: 05-02: opcao-a — empresa_id mantido em corretor_responsavel (W02); PENDENTE para a frente web, junto com a revisão LGPD de contato (§11.5 g)
- [Phase 05]: 05-03: Imovel.cidade removida (A-06); cidade da vitrine vem da consulta, a do imovel vem do detalhe
- [Phase 05]: 05-04: bairros por cidade e catálogo de características públicos; natureza/bairro em CSV (OU); vírgula em bairro é risco aceito A-05
- [Phase 05]: 05-05: seed pula imóvel já existente inteiro (fotos e situação preservadas); apartamento sem endereço próprio; guarda de DEBUG testada em banco vazio
- [Phase 05]: 05-11: parametrosDaApi e o unico mapeamento de params (nomes W09); ImovelMockDataSource removido; FalhaSimuladaDoMock movida para o mock do detalhe ate o 05-14
- [Phase 05]: 05-12: dominio segue com nomes de caracteristica; repositorio mapeia CaracteristicaModel -> nome ate 05-13/05-15
- [Phase 05]: 05-14: DetalheImovel.cidade nula; Model le endereco completo mas a pagina mostra so bairro · cidade, UF; CorretorModel so id/nome/foto
- [Phase 05]: 05-17: infraestrutura do lote = booleanos verdadeiros traduzidos em data/ (ordem fixa); areas_de_lazer texto corrido; codigos de posicao solar/uso permitido rotulados em presentation/ (A-03, A-04)
- [Phase 05]: 05-18: contrato reescrito para o formato real; PENDENTE web: IPTU, LGPD de contato do corretor e empresa_id
- [Phase 05]: 05-19: preço e área têm tetos separados (9999999999.99 / 99999999.99); NUL, busca>200, bairro>20 itens ou >100 caracteres e número fora da allowlist ASCII viram 400 {campo: mensagem}
- [Phase 05]: 05-20: filtro caracteristicas com teto de 20 ids distintos e tem-todas por uma subconsulta agregada na tabela M2M (CR-01); risco aceito de 21+ marcadas virar erro no app, a registrar no contrato pelo 05-22
- [Phase 05]: 05-21: ThrottleVitrinePublica (balde unico por IP, 120/min via VITRINE_TAXA_ANONIMA, NUM_PROXIES=0) so nas 5 rotas publicas da vitrine; sem throttle global
- [Phase 07.1]: 07.1-01: merge (nao rebase) de origin/main 43dd41d em feat/APP07; DataSource remota da vitrine do anunciante copia _lerEnvelope/_exigirMesmaOrigem do ImovelRemoteDataSource em vez de extrai-los; lib/ sem mock (PerfilRemoteDataSource ativo no DI)
- [Phase 07.1]: 07.1-02: vitrine do anunciante no Django em rotas aninhadas corretores|empresas/<id>/imoveis/; 404 uniforme (texto do detail varia entre as rotas) e 200 vazio para anunciante ativo sem imoveis
- [Phase 07.1]: 07.1-03: capturar so os grupos perfis e anunciante (nunca todos) para manter as 15 fixtures da APP-05 intactas; 404 da vitrine do anunciante reaproveita erro_404_perfil.json na ApiFalsa
- [Phase 07.1]: 07.1-04: VitrineAnuncianteCubit descarta id ja listado ao anexar a proxima pagina (integridade da lista, ordem do servidor); teste 'pilha real' removido, garantia passa ao wire capturado e ao e2e do 07.1-05
- [Phase 07.1]: 07.1-05: e2e dos perfis registra detalhe e perfis sobre o mesmo Dio da ApiFalsa (registrarDetalheEPerfis); rolagem infinita provada pelo estado do Cubit; grupo DI real da APP-07 nao portado (coberto por injection_perfis_test)
- [Phase 07.1]: Contrato §13 registra o 404 de anunciante inexistente/inativo (muda o antigo nunca 404) e os PENDENTE WEB (f), (g), (h)
- [Phase 08]: 08-01: rota do acervo = ImovelViewSet.list adaptado (envelope paginado 20/pagina, 10 chaves com emenda finalidade, ordem -criado_em/-pk); filtro invalido anula todos os filtros como no site

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 5]: Externally blocked on the `Imóvel` model (owned by teammate E2 in `../imoveis-aqui/Web`) — Phases 1-3 do not require it (mock-first build), but Phase 5 cannot complete until that model lands.
- [Phase 07.1]: PENDENTE WEB no §13.7 do contrato (D-20): limite de taxa nas views de perfil e extensão do seed — aceito fora do escopo do app, depende da frente web.
- [Phase 1]: API-AUDIT needs live coordination with the teammate on exact `Imóvel` field names/enum values (natureza, finalidade, características shape, quartos/suítes/vagas exact-vs-range semantics) — not resolvable from docs alone.

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 260922-jk3 | Reescrever README com preparo do ambiente e execução do app | 2026-09-22 | e738540 | [260922-jk3-reescrever-o-readme-md-do-projeto-hoje-b](./quick/260922-jk3-reescrever-o-readme-md-do-projeto-hoje-b/) |
| 2 | Adicionar setup de ambiente Windows ao README | 2026-09-22 | b40437b | — |
| 3 | Corrigir compileSdk 35→36 (plugins exigem 36+); verificado com build real no emulador | 2026-09-22 | 559486a | — |

### Roadmap Evolution

- Phase 7 added: Perfis Públicos da Empresa e do Corretor (card APP 07); número 7 escolhido para casar com o card — fase 6 reservada ao APP 06
- Phase 07.1 inserted after Phase 7: Integração da APP-07 com a API real (merge da APP-05, perfis na API real, endpoint da vitrine do anunciante no Django) (URGENT)
- Phase 8 added: Login e Área do Corretor — o Acervo (card APP 08, tarefa A08)

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-11-21T12:58:36.470Z
Stopped at: Completed 08-01-PLAN.md
Resume file: None
