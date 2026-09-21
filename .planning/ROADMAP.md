# Roadmap: Imóveis Aqui — App (Vitrine)

## Overview

O app abre com zero dependência de API: localização/entrada na cidade (APP01) sobre uma
lista fixa, com o contrato de `/cidades` e `/imoveis` congelado em paralelo para não deixar
o trabalho de UI refém do model de Imóvel que a frente web (E2) ainda vai construir. A
vitrine (APP02) e os filtros (APP03) nascem em cima desse contrato contra uma DataSource
mock/fixture, ganhando `GET /cidades` real no caminho — só a lista de imóveis continua
simulada. A última fase é curta por desenho: quando o model de Imóvel pousar no repo da
API, o endpoint público `/imoveis` é implementado seguindo o contrato já congelado e o app
troca a DataSource mock pela real com uma mudança de DI, sem tocar em UI/Cubit/domain.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Localização, Escolha de Cidade e Contrato da API** - Abertura do app, permissão de localização e entrada na cidade (com fallback de escolha), mais o contrato escrito de `/cidades` e `/imoveis`.
- [ ] **Phase 2: Vitrine — Lista, Busca e Ordenação** - Vitrine da cidade escolhida com lista paginada, busca e ordenação, cidades já vindas da API, imóveis ainda sobre mock.
- [ ] **Phase 3: Vitrine — Filtros Server-Side** - Filtros completos da vitrine (finalidade, natureza, faixas, características), chips ativos e paginação sempre consistente.
- [ ] **Phase 4: Imóveis Real — Endpoint Público e Integração Final** - Endpoint público real de imóveis e troca da DataSource mock pela real via DI.

## Phase Details

### Phase 1: Localização, Escolha de Cidade e Contrato da API

**Goal**: O visitante abre o app e entra numa cidade atendida — por localização ou por escolha manual — com a cidade guardada e trocável a qualquer momento; em paralelo, o contrato de `GET /cidades` e `GET /imoveis` fica escrito e congelado para orientar as fases seguintes.
**Mode:** mvp
**Depends on**: Nothing (first phase)
**Requirements**: LOC-01, LOC-02, LOC-03, LOC-04, LOC-05, LOC-06, API-01
**Success Criteria** (what must be TRUE):

  1. Na primeira abertura, o app pede a permissão de localização; autorizada, descobre a cidade por reverse geocoding e já entra nela (ou cai no fallback de escolha se a cidade descoberta não for atendida).
  2. Recusada ou bloqueada, o app mostra a lista de cidades atendidas para escolha — caminho normal, nunca uma tela de erro.
  3. Cada desfecho de localização (autorizado / recusado / bloqueado-para-sempre / serviço-desligado / cidade-não-atendida) tem UI própria, tratado como estado explícito, nunca como exceção genérica.
  4. A cidade escolhida é guardada no aparelho (sem conta e sem senha), reusada nas próximas aberturas, e trocável num toque no topo da tela.
  5. Existe um documento de contrato (nomes de campo, enums, nomes de parâmetro de filtro, envelope de paginação) para `GET /cidades` e `GET /imoveis`, escrito e acordado com a frente web antes de qualquer código de APP02/APP03 ou do endpoint real de imóveis.

**Plans**: 4 plans
Plans:
**Wave 1**

- [ ] 01-01-PLAN.md — Walking Skeleton: scaffold + manual city-select-and-persist tracer (LOC-04)
- [ ] 01-02-PLAN.md — Frozen API contract for GET /cidades e GET /imoveis + example fixtures (API-01)

**Wave 2** *(blocked on Wave 1 completion)*

- [ ] 01-03-PLAN.md — Location flow: priming, detection, 5 sealed outcomes, city-selection screen (LOC-01/02/03/06)

**Wave 3** *(blocked on Wave 2 completion)*

- [ ] 01-04-PLAN.md — City switcher + returning-visitor launch routing (LOC-05)

**UI hint**: yes

### Phase 2: Vitrine — Lista, Busca e Ordenação

**Goal**: O visitante navega a vitrine da cidade escolhida — lista paginada, busca por texto e ordenação — com a lista de cidades agora vinda da API pública e o acervo de imóveis servido por uma camada de dados pronta para trocar de mock para real sem tocar em UI/Cubit.
**Mode:** mvp
**Depends on**: Phase 1
**Requirements**: VIT-01, VIT-02, VIT-03, VIT-04, VIT-05, VIT-06, API-02, API-04
**Success Criteria** (what must be TRUE):

  1. A vitrine mostra a lista de imóveis da cidade escolhida, com cada card em layout consistente (foto de capa, título, preço, natureza, bairro, quartos).
  2. O visitante busca imóveis por texto com debounce e vê o estado de "nenhum resultado" quando aplicável.
  3. O visitante ordena a lista por preço, área ou mais recentes.
  4. A lista rola infinita com os quatro estados (loading, vazio, erro/retry, fim-da-lista), sem cards duplicados ou embaralhados.
  5. O seletor de cidade passa a listar as cidades vindas de `GET /api/publico/cidades/` (endpoint público real, substituindo a lista fixa de APP01), enquanto o acervo de imóveis é servido por uma DataSource trocável (mock/fixture hoje, honrando o contrato da Fase 1; real depois, via DI).

**Plans**: TBD
**UI hint**: yes

### Phase 3: Vitrine — Filtros Server-Side

**Goal**: O visitante refina a vitrine com o conjunto completo de filtros de APP03, todos resolvidos no servidor (ainda sobre mock), com chips ativos e paginação sempre consistente ao mudar filtro ou ordenação.
**Mode:** mvp
**Depends on**: Phase 2
**Requirements**: FIL-01, FIL-02, FIL-03, FIL-04, FIL-05, FIL-06
**Success Criteria** (what must be TRUE):

  1. O visitante filtra por finalidade (venda/aluguel) e natureza (casa/apartamento/terreno/lote) num modal de filtros.
  2. O visitante filtra por faixa de preço, quartos, suítes, vagas, bairro, faixa de área e características.
  3. Filtros ativos aparecem como chips acima da lista, com opções de aplicar e limpar tudo.
  4. Mudar filtro ou ordenação reseta a paginação — sem cards duplicados ou embaralhados.
  5. Toda a filtragem é resolvida pela camada de dados (mock hoje, honrando o contrato da Fase 1) — o app nunca filtra o acervo localmente no aparelho.

**Plans**: TBD
**UI hint**: yes

### Phase 4: Imóveis Real — Endpoint Público e Integração Final

**Goal**: A API expõe o acervo real de imóveis com busca, ordenação, filtros e paginação resolvidos no servidor, sem dado interno; o app troca a DataSource mock pela real, e a vitrine com filtros passa a funcionar ponta a ponta com dados reais.
**Mode:** mvp
**Depends on**: Phase 3 (also blocked externally on the `Imóvel` model landing in the sibling API repo `../imoveis-aqui/Web`, owned by teammate E2 and outside this project's phases)
**Requirements**: API-03
**Success Criteria** (what must be TRUE):

  1. `GET /api/publico/imoveis/?cidade=...&filtros` responde sem token, só com imóveis publicados, com busca/ordenação/filtros/paginação resolvidos no servidor.
  2. A resposta usa um serializer público com allowlist explícita (sem proprietário/documento/dado interno) e não quebra o isolamento multitenant — nenhum imóvel de outra empresa ou não publicado aparece.
  3. A resposta segue o contrato congelado na Fase 1 (nomes de campo, envelope de paginação, nomes de parâmetro de filtro), sem drift silencioso.
  4. O app troca a DataSource mock pela real via injeção de dependência (troca de uma linha), sem mudar UI/Cubit/domain; de ponta a ponta, o visitante vê, busca, ordena e filtra imóveis reais na vitrine.

**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Localização, Escolha de Cidade e Contrato da API | 0/4 | Planned | - |
| 2. Vitrine — Lista, Busca e Ordenação | 0/TBD | Not started | - |
| 3. Vitrine — Filtros Server-Side | 0/TBD | Not started | - |
| 4. Imóveis Real — Endpoint Público e Integração Final | 0/TBD | Not started | - |
