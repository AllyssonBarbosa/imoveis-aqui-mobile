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
- [ ] **Phase 4: Página do Imóvel — Galeria e Dados da Natureza** - Tela de detalhe (card APP 04): galeria a partir da capa, preços, corretor e bloco por natureza (casa, terreno, apartamento, lote), sobre mock seguindo o contrato de `GET /api/publico/imoveis/{id}/`.
- [ ] **Phase 5: Imóveis Real — Endpoint Público e Integração Final** - Endpoints públicos reais de lista e detalhe de imóveis e troca das DataSources mock pelas reais via DI.
- [ ] **Phase 7: Perfis Públicos da Empresa e do Corretor** - Card APP 07: página da empresa e página do corretor com a vitrine do anunciante, dados da API de perfis públicos (WEB 02) e aviso para corretor desativado. (Fase 6 reservada ao card APP 06, de outro colega — fase N = card APP 0N.)

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

**Plans**: 4/4 plans executed
Plans:
**Wave 1**

- [x] 01-01-PLAN.md — Walking Skeleton: scaffold + manual city-select-and-persist tracer (LOC-04)
- [x] 01-02-PLAN.md — Frozen API contract for GET /cidades e GET /imoveis + example fixtures (API-01)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 01-03-PLAN.md — Location flow: priming, detection, 5 sealed outcomes, city-selection screen (LOC-01/02/03/06)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 01-04-PLAN.md — City switcher + returning-visitor launch routing (LOC-05)

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

**Plans**: 5/5 plans executed
Plans:
**Wave 1**

- [x] 02-01-PLAN.md — Tracer: vitrine da cidade escolhida ponta a ponta sobre a DataSource mock + card completo (VIT-01, VIT-02, API-04)
- [x] 02-02-PLAN.md — `GET /api/publico/cidades/` no repo irmão (feat/APP02, sem commit sem aval) + seed de dev + adendos ao contrato (API-02)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 02-03-PLAN.md — Scroll infinito: servidor simulado com cursor (~40/cidade), carregarMais guardado, rodapés loading/erro/fim (VIT-05)
- [x] 02-04-PLAN.md — Cidades vindas da API via Dio (API_BASE_URL), asset removido, cidade salva entra sem depender da lista (VIT-06)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 02-05-PLAN.md — Busca com debounce (título+bairro) e ordenação por bottom sheet com nulls last (VIT-03, VIT-04)

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

**Plans**: 5/5 plans executed
Plans:
**Wave 1**

- [x] 03-01-PLAN.md — Tracer: filtro de finalidade ponta a ponta (sheet + rascunho + query params + mock) + chips, remover/limpar e vazio com filtros sobre o reinício da F2 (FIL-01, FIL-05, FIL-06)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 03-02-PLAN.md — Natureza + quartos/suítes/vagas "N+", semântica CSV/OU/E no servidor simulado, fixture variada (D-24) e contrato §10 (FIL-02, FIL-03, FIL-04, FIL-05)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 03-03-PLAN.md — Faixas de preço (por finalidade) e área com máscara, validação inline + 400 simulado, ordenação por aluguel (FIL-03, FIL-04, FIL-05)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 03-04-PLAN.md — Opções de bairro/característica do servidor simulado (D-20) + seção Bairros com filtro local (FIL-04, FIL-05)

**Wave 5** *(blocked on Wave 4 completion)*

- [x] 03-05-PLAN.md — Seção Características + filtros sobrevivem à troca de cidade sem bairros, só em memória, e gates finais (FIL-04, FIL-05, FIL-06)

**UI hint**: yes

### Phase 4: Página do Imóvel — Galeria e Dados da Natureza

**Goal**: O visitante abre um imóvel a partir da vitrine e vê tudo sobre ele para decidir se vale falar com o corretor; o que aparece abaixo da galeria depende da natureza do imóvel. Card APP 04 (tarefa A04).
**Mode:** mvp
**Depends on**: Phase 3 (externally: WEB 05/06/07 for the nature data and WEB 09 for the public detail endpoint, in `../imoveis-aqui/Web` — this phase builds over a mock that follows the detail contract)
**Requirements**: DET-01, DET-02, DET-03, DET-04, DET-05, DET-06, API-06
**Success Criteria** (what must be TRUE):

  1. A galeria mostra todas as fotos do imóvel, começando pela capa.
  2. Casa mostra terreno, área construída e área livre; terreno mostra frente, fundo e topografia.
  3. Apartamento mostra os dados do prédio; lote mostra a quadra e o loteamento a que pertence.
  4. Mostra valores de venda ou aluguel, condomínio e IPTU.
  5. Mostra o corretor responsável com foto e o caminho para o perfil dele.
  6. Tudo vem do detalhe da API (contrato de `GET /api/publico/imoveis/{id}/`), sem dado montado dentro do app — nesta fase via DataSource mock que respeita o contrato; a troca pela real fica na Phase 5.

**Plans**: 8/8 plans executed
Plans:
**Wave 1**

- [x] 04-01-PLAN.md — Tracer: card da vitrine abre a página (prévia na hora -> descrição do detalhe do mock por toda a pilha) + 'Tentar de novo' (DET-01, DET-05)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 04-02-PLAN.md — Contrato §11 + `imovel_detalhe.example.json` servido tal e qual pelo mock (teste de allowlist) + IDs DET-01..06/API-06/API-07 (API-06)
- [x] 04-03-PLAN.md — Erros tipados na camada de dados (404/TypeError) + estado "Este imóvel não está mais disponível" separado de "Tentar de novo" (DET-06)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 04-04-PLAN.md — Detalhe determinístico para todo card + ids reservados 338/339, testes de entrada da vitrine, só URLs de imagem http(s) (DET-01, DET-02, API-06)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 04-05-PLAN.md — Dados da natureza: sealed DadosNatureza, blocos casa/terreno/apartamento/lote com prédio e quadra/loteamento, fixture + exemplo de lote no contrato (DET-04, API-06)

**Wave 5** *(blocked on Wave 4 completion)*

- [x] 04-06-PLAN.md — Apresentação da natureza: destaques + ficha, cards do prédio e da quadra/loteamento, anti-cálculo (DET-04)

**Wave 6** *(blocked on Wave 5 completion)*

- [x] 04-07-PLAN.md — Galeria no SliverAppBar com contador N/M e visualizador tela cheia com pinch-zoom (InteractiveViewer) (DET-02)

**Wave 7** *(blocked on Wave 6 completion)*

- [x] 04-08-PLAN.md — Cabeçalho do detalhe com condomínio/IPTU, características, corretor com foto + tela de perfil, fluxo completo e gates da fase (DET-03, DET-05)

**UI hint**: yes

### Phase 5: Imóveis Real — Endpoint Público e Integração Final

**Goal**: A API expõe o acervo real de imóveis com busca, ordenação, filtros e paginação resolvidos no servidor, sem dado interno; o app troca a DataSource mock pela real, e a vitrine com filtros passa a funcionar ponta a ponta com dados reais.
**Mode:** mvp
**Depends on**: Phase 4 (also blocked externally on the `Imóvel` model landing in the sibling API repo `../imoveis-aqui/Web`, owned by teammate E2 and outside this project's phases)
**Requirements**: API-03, API-07
**Success Criteria** (what must be TRUE):

  1. `GET /api/publico/imoveis/?cidade=...&filtros` responde sem token, só com imóveis publicados, com busca/ordenação/filtros/paginação resolvidos no servidor.
  2. A resposta usa um serializer público com allowlist explícita (sem proprietário/documento/dado interno) e não quebra o isolamento multitenant — nenhum imóvel de outra empresa ou não publicado aparece.
  3. A resposta segue o contrato congelado na Fase 1 (nomes de campo, envelope de paginação, nomes de parâmetro de filtro), sem drift silencioso.
  4. O app troca a DataSource mock pela real via injeção de dependência (troca de uma linha), sem mudar UI/Cubit/domain; de ponta a ponta, o visitante vê, busca, ordena e filtra imóveis reais na vitrine.
  5. O detalhe (`GET /api/publico/imoveis/{id}/`) também passa a vir da API real, incluindo os dados de natureza, e a página do imóvel da Phase 4 funciona ponta a ponta.

**Plans**: TBD

### Phase 7: Perfis Públicos da Empresa e do Corretor

**Goal**: O visitante vê quem está anunciando para saber com quem vai negociar: a página da empresa traz logomarca, CRECI, apresentação, contato e cidades de atuação; a do corretor traz foto, CRECI, apresentação e contato; as duas mostram a vitrine dos imóveis daquele anunciante. Card APP 07 (tarefa A07).
**Mode:** mvp
**Depends on**: Phase 4 (cartão do corretor e tela de perfil do DET-05). Externamente: WEB 02 (feito, na main da web) para `GET /api/publico/corretores/{id}/` e `GET /api/publico/empresas/{id}/`. A vitrine do anunciante ainda não tem endpoint na web — esta fase a constrói sobre mock que segue um contrato escrito, como nas fases 2–4.
**Requirements**: PERF-01, PERF-02, PERF-03, PERF-04, PERF-05, PERF-06, API-08
**Success Criteria** (what must be TRUE):

  1. Página da empresa com logomarca, CRECI, apresentação, contato e cidades de atuação.
  2. Página do corretor com foto, CRECI, apresentação e contato.
  3. As duas páginas mostram a vitrine dos imóveis daquele anunciante.
  4. Os dados vêm da API dos perfis públicos (nada montado ou decidido no app).
  5. Perfil de corretor desativado mostra um aviso, e não uma tela quebrada.
  6. Dá para chegar ao perfil a partir da página do imóvel.

**Plans**: 7/12 plans executed

Plans:
**Wave 1**
- [x] 07-01-PLAN.md — Dados do perfil do corretor (domain/data): entidade, Model defensivo da WEB 02, mock coerente com o detalhe (7, 8, 9 + corretor 10 sem imóveis), repositório (PERF-04, PERF-02)

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 07-02-PLAN.md — TRACER: tocar no corretor da página do imóvel abre o perfil buscado por id (prévia na hora -> CRECI do mock por toda a pilha) + DI de produção (PERF-06, PERF-02, PERF-04)
- [x] 07-03-PLAN.md — Registro de PERF-01..06/API-08 + adendo §12 do contrato + exemplos de wire dos perfis protegidos por teste de contrato (API-08, PERF-04)

**Wave 3** *(blocked on Wave 2 completion)*
- [x] 07-04-PLAN.md — Corretor completo: 404 'Este corretor não está mais disponível' + 'Tentar de novo', apresentação e contato como texto (PERF-02, PERF-05)
- [x] 07-05-PLAN.md — API real dos perfis (Dio) com 404/JSON ruim tipados no repositório + entidade/Model defensivo da empresa (PERF-04, PERF-05, PERF-01)

**Wave 4** *(blocked on Wave 3 completion)*
- [x] 07-06-PLAN.md — Dados da vitrine do anunciante: AnuncianteRef, §12 no mock com cursor, repositório e use case (PERF-03, API-08)
- [x] 07-07-PLAN.md — Corretor desativado reproduzível à mão: id reservado 99 via imóvel 337 + e2e até o aviso (PERF-05)

**Wave 5** *(blocked on Wave 4 completion)*
- [ ] 07-08-PLAN.md — Vitrine do anunciante na página do corretor: Cubit, sliver de ImovelCard, vazio (corretor 10) e erro com 'Tentar de novo' (PERF-03, API-08)
- [ ] 07-09-PLAN.md — Dados da empresa: fixture IMOBILIARIA/AUTONOMO = exemplo do §12, buscarEmpresa no mock, na remota e no repositório (PERF-01, PERF-04)

**Wave 6** *(blocked on Wave 5 completion)*
- [ ] 07-10-PLAN.md — Rolagem infinita da vitrine do anunciante: carregarMais, rodapés, página curta, corpo rolável compartilhado (PERF-03, API-08)

**Wave 7** *(blocked on Wave 6 completion)*
- [ ] 07-11-PLAN.md — Página da empresa a partir do perfil do corretor ('Ver página do anunciante'): logomarca, nome, tipo, CRECI pela pilha de perfis (PERF-01, PERF-06, PERF-04)

**Wave 8** *(blocked on Wave 7 completion)*
- [ ] 07-12-PLAN.md — Desfechos da empresa (404/erro/cartão ausente), empresa completa (apresentação, contato, cidades, vitrine), fluxo completo, guardas e human-check (PERF-01..PERF-06, API-08)

**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 7 (6 reservada ao APP 06)

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Localização, Escolha de Cidade e Contrato da API | 4/4 | In Progress|  |
| 2. Vitrine — Lista, Busca e Ordenação | 5/5 | In Progress|  |
| 3. Vitrine — Filtros Server-Side | 5/5 | In Progress|  |
| 4. Página do Imóvel — Galeria e Dados da Natureza | 8/8 | In Progress|  |
| 5. Imóveis Real — Endpoint Público e Integração Final | 0/TBD | Not started | - |
| 7. Perfis Públicos da Empresa e do Corretor | 7/12 | In Progress | - |
