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
- [x] **Phase 5: Imóveis Real — Endpoint Público e Integração Final** - Endpoints públicos reais de lista e detalhe de imóveis e troca das DataSources mock pelas reais via DI. (completed 2026-11-16)
- [x] **Phase 6: Contato com o Corretor — WhatsApp, Telefone e E-mail (APP 06)** - Botão de contato (WhatsApp, telefone e e-mail) na página do imóvel e no perfil do corretor, com o contato registrado pela API pública sem login. (completed 2026-11-22)
- [x] **Phase 7: Perfis Públicos da Empresa e do Corretor** - Card APP 07: página da empresa e página do corretor com a vitrine do anunciante, dados da API de perfis públicos (WEB 02) e aviso para corretor desativado. (Fase 6 reservada ao card APP 06, de outro colega — fase N = card APP 0N.) (completed 2026-11-20)
- [x] **Phase 07.1: Integração da APP-07 com a API real** (completed 2026-11-20)
- [x] **Phase 8: Login e Área do Corretor — o Acervo** (completed 2026-11-21)
- [ ] **Phase 9: Mudança de Situação do Imóvel pelo App (APP 09)** - Corretor responsável troca a situação do imóvel (disponível/reservado/vendido/alugado) com observação pela API (a data é a do servidor; o gestor segue pela web até a APP-12), vê o histórico na tela do imóvel; recusa do servidor mantém a situação anterior.

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

  1. `GET /api/publico/cidades/<id>/imoveis/?filtros` responde sem token, só com imóveis publicados, com busca/ordenação/filtros/paginação resolvidos no servidor.
  2. A resposta usa um serializer público com allowlist explícita (sem proprietário/documento/dado interno) e não quebra o isolamento multitenant — nenhum imóvel de outra empresa ou não publicado aparece.
  3. A resposta segue o contrato do formato real da API (01-CONTRATO-API.md reescrito na Fase 5, com exemplos copiados de respostas capturadas e testes de contrato nos dois repositórios), sem drift silencioso.
  4. O app troca as DataSources mock pelas reais via injeção de dependência; a adaptação ao formato real fica concentrada em data/ e UI, Cubits e domain/ mudam só o mínimo necessário (D-01); de ponta a ponta, o visitante vê, busca, ordena e filtra imóveis reais na vitrine.
  5. O detalhe (`GET /api/publico/imoveis/{id}/`) também passa a vir da API real, incluindo os dados de natureza, e a página do imóvel da Phase 4 funciona ponta a ponta.

**Plans**: 22/22 plans executed (18/18 executed + 4 gap closure from 05-VERIFICATION: CR-01, CR-02, WR-01, WR-02)
Plans:
**Wave 1**

- [x] 05-01-PLAN.md — API: autorização git dos dois repositórios (API e app), feat/APP05 = WEB-09 + merge da web-08 (W09 vence o público), regra única na_vitrine, situação fora da vitrine (API-03, API-07) [checkpoint]

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 05-02-PLAN.md — API: lote na vitrine pública (LotePublicoSerializer, área do lote), decisão informada sobre o corretor público (contatos expostos, empresa_id, LGPD adiada), allowlist exata, galeria começando pela capa (API-03, API-07) [checkpoint]
- [x] 05-03-PLAN.md — App: item da vitrine sem cidade (A-06), prévia só com o bairro (API-03)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 05-04-PLAN.md — API: bairros da cidade e catálogo de características públicos, natureza/bairro em CSV, README da vitrine (API-03)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 05-05-PLAN.md — API: seed das 4 naturezas nas 4 cidades (versionado, idempotente) + [BLOCKING] migrações no banco de dev (API-03, API-07)

**Wave 5** *(blocked on Wave 4 completion)*

- [x] 05-06-PLAN.md — Captura do JSON real de lista e opções para test/fixtures/api/ (tool/capturar_fixtures_api.py) (API-03)

**Wave 6** *(blocked on Wave 5 completion)*

- [x] 05-07-PLAN.md — Captura do JSON real dos detalhes (4 naturezas, sem fotos, sem corretor, 404) (API-07)
- [x] 05-08-PLAN.md — App: cidades em array com id, cidade salva com id, ApiFalsa (API-03)

**Wave 7** *(blocked on Wave 6 completion)*

- [x] 05-09-PLAN.md — App: lista real por GET /cidades/<id>/imoveis/ via DI, Model no wire da W09, next de mesma origem (API-03)

**Wave 8** *(blocked on Wave 7 completion)*

- [x] 05-10-PLAN.md — App: busca e ordenação reais, rolagem e falhas (500, JSON malformado), sem card repetido (API-03)

**Wave 9** *(blocked on Wave 8 completion)*

- [x] 05-11-PLAN.md — App: filtros com os nomes da W09 + servidor simulado da lista removido (API-03)

**Wave 10** *(blocked on Wave 9 completion)*

- [x] 05-12-PLAN.md — App: opções reais de bairro/característica via DI, mock de opções removido (API-03)

**Wave 11** *(blocked on Wave 10 completion)*

- [x] 05-13-PLAN.md — App: característica {id, nome} nas opções (domínio, cubit, modal) (API-03)
- [x] 05-14-PLAN.md — App: detalhe real via DI (endereco completo, fotos imagem/ordem/capa, corretor_responsavel), últimos mocks fora de lib/, contrato do detalhe (API-07)

**Wave 12** *(blocked on Wave 11 completion)*

- [x] 05-15-PLAN.md — App: filtro de características por id na consulta, sessão entre cidades (API-03)
- [x] 05-16-PLAN.md — App: detalhe nas bordas (404, 500, sem fotos, sem corretor, fechada em voo) + corretor sem slug (API-07)

**Wave 13** *(blocked on Wave 12 completion)*

- [x] 05-17-PLAN.md — App: blocos de natureza no wire real (lote com parcelamento/quadra/loteamento, laterais, prédio) + rótulos de códigos (API-07)

**Wave 14** *(blocked on Wave 13 completion)*

- [x] 05-18-PLAN.md — Fechamento: contrato e exemplos = respostas reais + testes de contrato, rota real e critérios 3/4 em REQUIREMENTS/ROADMAP, README, gates dos dois repos, roteiro E2E (API-03, API-07)

**Gap closure** *(05-VERIFICATION gaps_found; WR-03..WR-06 e IN-01..IN-09 adiados pelo usuário)*

**Wave 15**

- [x] 05-19-PLAN.md — API: número e texto hostis na lista pública viram 400 (NaN/Infinity/1e400/_ e tetos em _numero; NUL e tetos em busca/bairro) (CR-02, WR-01, WR-02) (API-03)

**Wave 16** *(blocked on Wave 15 completion)*

- [x] 05-20-PLAN.md — API: características com até 20 ids positivos e "tem todas" numa única subconsulta agregada (CR-01) (API-03)

**Wave 17** *(blocked on Wave 16 completion)*

- [x] 05-21-PLAN.md — API: limite de taxa anônimo (429) nas 5 rotas públicas da vitrine, sem tocar a API autenticada, NUM_PROXIES=0, suíte estável (WR-02) (API-03, API-07)

**Wave 18** *(blocked on Wave 17 completion)*

- [x] 05-22-PLAN.md — Contrato (tetos, mensagens 400, 429, riscos) + README da API + guarda do app para 400/429 + gates finais; check humano de fim de fase pendente (API-03, API-07)

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

**Plans**: 12/12 plans complete

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

- [x] 07-08-PLAN.md — Vitrine do anunciante na página do corretor: Cubit, sliver de ImovelCard, vazio (corretor 10) e erro com 'Tentar de novo' (PERF-03, API-08)
- [x] 07-09-PLAN.md — Dados da empresa: fixture IMOBILIARIA/AUTONOMO = exemplo do §12, buscarEmpresa no mock, na remota e no repositório (PERF-01, PERF-04)

**Wave 6** *(blocked on Wave 5 completion)*

- [x] 07-10-PLAN.md — Rolagem infinita da vitrine do anunciante: carregarMais, rodapés, página curta, corpo rolável compartilhado (PERF-03, API-08)

**Wave 7** *(blocked on Wave 6 completion)*

- [x] 07-11-PLAN.md — Página da empresa a partir do perfil do corretor ('Ver página do anunciante'): logomarca, nome, tipo, CRECI pela pilha de perfis (PERF-01, PERF-06, PERF-04)

**Wave 8** *(blocked on Wave 7 completion)*

- [x] 07-12-PLAN.md — Desfechos da empresa (404/erro/cartão ausente), empresa completa (apresentação, contato, cidades, vitrine), fluxo completo, guardas e human-check (PERF-01..PERF-06, API-08)

**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 07.1 → 8 → 9

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Localização, Escolha de Cidade e Contrato da API | 4/4 | In Progress|  |
| 2. Vitrine — Lista, Busca e Ordenação | 5/5 | In Progress|  |
| 3. Vitrine — Filtros Server-Side | 5/5 | In Progress|  |
| 4. Página do Imóvel — Galeria e Dados da Natureza | 8/8 | In Progress|  |
| 5. Imóveis Real — Endpoint Público e Integração Final | 22/22 | Complete    | 2026-11-16 |
| 6. Contato com o Corretor — WhatsApp, Telefone e E-mail (APP 06) | 10/10 | Complete    | 2026-11-22 |
| 7. Perfis Públicos da Empresa e do Corretor | 12/12 | Complete    | 2026-11-20 |

### Phase 6: Contato com o Corretor — WhatsApp, Telefone e E-mail (APP 06)

**Goal:** O visitante fala com o corretor com um toque, sem login e sem formulário: na página do imóvel e no perfil do corretor, o botão de WhatsApp (e as alternativas telefone e e-mail) dispara `POST /api/publico/imoveis/{id}/contato/` (WEB 11), que registra o contato (imóvel, corretor, canal) e devolve o link pronto — com a mensagem padrão montada pelo servidor — que o app apenas abre. Card APP 06 (tarefa A06).
**Success Criteria** (card APP 06, todos obrigatórios):

  1. Botão de contato na página do imóvel e no perfil do corretor.
  2. O botão abre o WhatsApp com a mensagem padrão já preenchida.
  3. Telefone e e-mail como alternativas de contato.
  4. O contato é registrado na API no momento em que o visitante o dispara.
  5. O registro guarda o imóvel, o corretor e o canal usado.
  6. Tudo funciona sem login.

**Requirements**: APP06-C1, APP06-C2, APP06-C3, APP06-C4, APP06-C5, APP06-C6, APP06-API-1, APP06-API-2
**Depends on:** Phase 5
**Plans:** 10/10 plans complete

Plans:

- [x] 06-01-PLAN.md — API: autorização git (checkpoint), feat/APP06 = main + merge WEB-11 (POST de contato provado) e `canais_contato` no detalhe público
- [x] 06-02-PLAN.md — API: limite próprio do POST de contato (ThrottleContatoPublico, CONTATO_TAXA_ANONIMA 10/min) + link do WhatsApp com %20 (`link_whatsapp` com quote_via=quote, teste Django) + docs
- [x] 06-03-PLAN.md — App: captura real da API — recaptura do detalhe com `canais_contato` (allowlist exata) e do POST de contato (grupo contato, link com %20)
- [x] 06-04-PLAN.md — App: CanalContato no domínio, parse tolerante de `canais_contato`, contrato do POST no app e docs (contrato + README)
- [x] 06-05-PLAN.md — App: POST de contato (ApiFalsa com POST, DataSource) e ContatoRepository com falhas tipadas e link validado
- [x] 06-06-PLAN.md — App: url_launcher atrás de LinkLauncherGateway (externalApplication) e ContatarCorretorUseCase
- [x] 06-07-PLAN.md — App: BarraContato + ContatoCubit na página do imóvel (botão principal) — e2e vitrine → WhatsApp; Cubit travado por bloc_test
- [x] 06-08-PLAN.md — App: barra completa — ⋮ com bottom sheet (e2e ⋮ → Ligar), loading por botão e SnackBars por motivo
- [x] 06-09-PLAN.md — App: contato no perfil do corretor aberto do imóvel ("Sobre: título") + testes de widget das duas telas
- [x] 06-10-PLAN.md — Portões finais, README e verificação no aparelho com WhatsApp (checkpoint; confirma %20 e ícone)

### Phase 07.1: Integração da APP-07 com a API real (INSERTED)

**Goal:** Os perfis do corretor e da empresa e a vitrine do anunciante funcionam ponta a ponta com dados reais, sobre a `main` que já tem a APP-05: a branch `feat/APP07` recebe a `main` com os conflitos resolvidos, os perfis passam a usar a API real da WEB 02, e a vitrine do anunciante passa a vir de um endpoint novo no Django (imóveis por corretor e por empresa), no padrão da API pública da APP-05.
**Requirements**: PERF-03, PERF-04, API-08
**Success Criteria**:

  1. `feat/APP07` contém a `main` atual (APP-05) com todos os conflitos resolvidos; `flutter analyze` limpo e `flutter test` verde.
  2. O DI registra a DataSource real dos perfis (`GET /api/publico/corretores/{id}/` e `/empresas/{id}/`); nenhum mock de perfil ou de imóvel ativo no app.
  3. O Django expõe a vitrine do anunciante (imóveis publicados de um corretor e de uma empresa) com a mesma paginação, allowlist e limite de taxa da API pública da APP-05, com testes no repositório web.
  4. O app consome esse endpoint com a paginação nova; o adendo do contrato da vitrine do anunciante fica renumerado (o §12 da `main` passou a ser outro assunto) e alinhado ao que o Django entrega.
  5. Com o Django rodando e `semear_vitrine_dev`, dá para ir de um imóvel real até o corretor, a empresa e a vitrine deles, e de volta a um imóvel.

**Depends on:** Phase 7
**Plans:** 6/6 plans complete

Plans:
**Wave 1**

- [x] 07.1-01-PLAN.md — Merge de origin/main (APP-05) em feat/APP07 com os 10 conflitos resolvidos + TRACER: perfis e vitrine do anunciante nas DataSources Dio pelo DI de produção, zero mock em lib/ (PERF-04, PERF-03, API-08)
- [x] 07.1-02-PLAN.md — Django (repo web, branch feat/APP07): rotas corretores/<id>/imoveis/ e empresas/<id>/imoveis/ no padrão da APP-05, D-11 (corretor de empresa inativa -> 404), site usando as mesmas consultas (D-19), testes (PERF-03, API-08)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 07.1-03-PLAN.md — Wire real: captura dos perfis e da vitrine do anunciante do Django, ApiFalsa com as rotas novas, teste da DataSource remota, perfil_remote/contrato_perfis e exemplos do contrato copiados (PERF-04, PERF-03, API-08)
- [x] 07.1-04-PLAN.md — Cubit da vitrine do anunciante sem id repetido ao anexar página + testes de tela/repositório da APP-07 sobre as entidades da main (PERF-03)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 07.1-05-PLAN.md — Fluxos e2e da APP-07 portados para a ApiFalsa (perfil, empresa, rolagem infinita, 404, vazio) e suíte completa verde — SC-1 (PERF-03, PERF-04)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 07.1-06-PLAN.md — Contrato §13, REQUIREMENTS (D-17), README, COVERAGE da Phase 7, 07-UAT.md com dados reais do seed e gates finais dos dois repositórios (API-08, PERF-03, PERF-04)

### Phase 8: Login e Área do Corretor — o Acervo

**Goal:** Como corretor, eu quero entrar no aplicativo para ver os imóveis que eu e a imobiliária temos, de onde eu estiver. O login é do mesmo aplicativo — não existe app separado. Quem entra vê a área do seu papel; o visitante continua usando o app sem login, como antes. O corretor vê os imóveis dele e os da imobiliária, com busca e filtro por situação. Imóvel de outra empresa não aparece, de jeito nenhum. Card APP 08 (tarefa A08).
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05, AUTH-06, ACV-01, ACV-02, ACV-03, ACV-04, API-09, API-10
**Depends on:** Phase 7. Externamente: WEB 01 (feito, na main da web) — `POST /api/auth/login/` (DRF Token), `Usuario.perfil` e o isolamento por empresa (`EmpresaScopedQuerySetMixin`).
**Success Criteria** (what must be TRUE):

  1. Login pelo aplicativo, com o token vindo da API.
  2. A sessão fica guardada; sair apaga o token do aparelho.
  3. Erro de login genérico, sem revelar se o e-mail existe.
  4. Lista do acervo com os imóveis do corretor e os da imobiliária, com busca e filtro por situação.
  5. Imóvel de outra empresa não aparece nem forçando a consulta.
  6. Sem login, o app continua abrindo direto na vitrine.

**Plans:** 12/12 plans complete

Plans:
**Wave 1**

- [x] 08-01-PLAN.md — Web (feat/APP08): TRACER do acervo autenticado (login → token → `GET /api/imoveis/` paginado e enxuto, 10 chaves) + busca/situação por `FiltroImovelForm`, isolamento (AC-5), allowlist e README (API-10, ACV-01..04)
- [x] 08-02-PLAN.md — App: `flutter_secure_storage` atrás de `ArmazenamentoToken`, `allowBackup=false`, segundo `Dio` `@Named('autenticado')` com `InterceptadorSessao` (token só na mesma origem, 401 → sessão expirada) e `ApiFalsa` gravando cabeçalhos; override do D-D sobre a nota do CLAUDE.md registrado (AUTH-02)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 08-03-PLAN.md — Web: login endurecido (`authentication_classes=[]`, limite por e-mail e por IP com `Retry-After`), `GET /api/auth/eu/` e `POST /api/auth/sair/` com testes e README (AUTH-06, AUTH-05, AUTH-02, AUTH-03, API-10)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 08-04-PLAN.md — Wire real: grupo `acervo` em `tool/capturar_fixtures_api.py`, fixtures capturadas, §14 do contrato e `contrato_acervo_test.dart` (API-09)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 08-05-PLAN.md — App: autenticação na camada de dados (DataSource login/eu/sair, `EuModel` → `Papel`, falhas tipadas 400/429/403/rede/401, repositório cujo sair/descarte nunca lançam) (AUTH-01, AUTH-02, AUTH-03, AUTH-05)
- [x] 08-06-PLAN.md — App: acervo no domínio e nos Models (entidades `ImovelAcervo`/`PaginaAcervo`/`ConsultaAcervo`, Models das 10 chaves, fixtures lidas pelos Models) (ACV-01, ACV-04)

**Wave 5** *(blocked on Wave 4 completion)*

- [x] 08-07-PLAN.md — App: use cases Entrar/ObterPapel/Sair/LerSessao e `SessaoCubit` singleton (Sair sempre anônimo, rollback do login que nunca lança) (AUTH-01, AUTH-02, AUTH-04, AUTH-05)

**Wave 6** *(blocked on Wave 5 completion)*

- [x] 08-08-PLAN.md — App: acervo na camada de dados (parâmetros da consulta, DataSource no Dio autenticado com `next` só na mesma origem, repositório e `BuscarAcervoUseCase`) (ACV-01, ACV-02, ACV-04)

**Wave 7** *(blocked on Wave 6 completion)*

- [x] 08-09-PLAN.md — App: `AcervoCubit` (busca 400 ms, chips de situação, rolagem) + cartão compacto, chips e `AcervoScreen` (ACV-01, ACV-02, ACV-04)

**Wave 8** *(blocked on Wave 7 completion)*

- [x] 08-10-PLAN.md — App: tela de login (textos fixos D-03/D-04, roteamento pelo papel), tela de aviso do gestor/administrador com Sair, e Sair + 401 na tela do acervo (AUTH-01, AUTH-02, AUTH-03, AUTH-05)

**Wave 9** *(blocked on Wave 8 completion)*

- [x] 08-11-PLAN.md — App: "Meu acervo" roteando pelo papel (401 da entrada → login com aviso) e botão "Entrar"/"Meu acervo" no topo da vitrine sem atrasar a abertura (AUTH-04, AUTH-05)

**Wave 10** *(blocked on Wave 9 completion)*

- [x] 08-12-PLAN.md — Fluxos ponta a ponta sobre a `ApiFalsa`, README do app, REQUIREMENTS e gates finais dos dois repositórios + human-check (emulador, iOS no Mac, taxas, autorização da nota do CLAUDE.md) (AUTH-01..06, ACV-01..04, API-09, API-10)

### Phase 9: Mudança de Situação do Imóvel pelo App (APP 09)

**Goal:** Como corretor, eu quero mudar a situação do imóvel pelo celular para marcar o reservado na hora da conversa, sem esperar chegar ao computador. A troca entre disponível, reservado, vendido e alugado leva data e observação, e o histórico da mudança aparece na própria tela. Quem decide é o servidor: o app pede a mudança; se a API recusar, a mensagem é mostrada e a tela não muda de estado por conta própria. Card APP 09 (tarefa A09). Depende da WEB 08 (Documentos, publicação, situação e histórico — Feito no Kanban).
**Requirements**: SIT-01, SIT-02, SIT-03, SIT-04, SIT-05, SIT-06, SIT-07, API-11, API-12
**Depends on:** Phase 8. Externamente: WEB 08 (feito, na `origin/main` da web `8bf4448`) — `GET /api/imoveis/{id}/`, `POST /api/imoveis/{id}/situacao/` e `GET /api/imoveis/{id}/historico/`.
**Success Criteria** (what must be TRUE — os 6 critérios do card):

  1. Trocar a situação do imóvel com observação (opcional); a data da mudança é a do servidor (`alterado_em`), informada como "Data: hoje" na troca e mostrada com data e hora no histórico — como no site (D-05 da fase; o card fala em "data e observação").
  2. A mudança é feita pela API; o app não altera nada localmente.
  3. O histórico das mudanças aparece na tela do imóvel.
  4. Recusa do servidor mostra a mensagem e mantém a situação anterior.
  5. A vitrine reflete a mudança na consulta seguinte (o servidor decide a publicação; verificado no UAT).
  6. Só quem o servidor autoriza consegue mudar: pelo app, só o corretor responsável (botão só com `pode_mudar_situacao`; quem forçar recebe 403); o gestor da empresa continua mudando pela web e a área dele no app é da APP-12 (D-07 da fase).

**Plans:** 6/13 plans executed

Plans:
**Wave 1**

- [x] 09-01-PLAN.md — TRACER do wire: grupo `situacao` em `tool/capturar_fixtures_api.py` capturando login → detalhe → POST 200 → detalhe/histórico relidos, as recusas 400/403 e o 404 de outra empresa no detalhe e no histórico contra o código da `origin/main` (via `git archive`, sem depender do clone), gate de credenciais, §16 do contrato e `contrato_gestao_situacao_test.dart` (API-11)
- [x] 09-02-PLAN.md — Web (D-19): worktree `../imoveis-aqui-APP09` na `feat/APP09` da `origin/main` e testes de caracterização L1–L7 das rotas do corretor (inclui 404 do histórico de outra empresa), commit local sem push (API-12, SIT-06)
- [x] 09-03-PLAN.md — Mapa único código do Django → enum (`finalidadeDoCodigo`/`situacaoDoCodigo` em `codigos_imovel_api.dart`), usado pelo acervo e pelos Models novos da fase, sem mudança no Meu acervo (SIT-07, SIT-03)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 09-04-PLAN.md — Dados da leitura do imóvel de gestão: tracer de dados UseCase → Repository → DataSource autenticado → `GET /api/imoveis/{id}/` → Model (9 chaves), usando o mapa único do 09-03, e falhas tipadas (SIT-07)

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 09-05-PLAN.md — TRACER de UI: todo cartão do Meu acervo abre a tela de gestão com a situação atual vinda da API, pela pilha real; Cubit com versão e "Tentar de novo" (SIT-07)

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 09-06-PLAN.md — Dados do histórico: `GET /api/imoveis/{id}/historico/` até a lista de domínio na ordem do servidor, rota da `ApiFalsa` e falhas tipadas (SIT-03)

**Wave 5** *(blocked on Wave 4 completion)*

- [ ] 09-07-PLAN.md — Tela de leitura completa: cabeçalho, "desde dd/MM/yyyy HH:mm", "Ver na vitrine" só com `na_vitrine` e histórico na tela (carga em paralelo, vazio do site, falha parcial) (SIT-07, SIT-01, SIT-03)

**Wave 6** *(blocked on Wave 5 completion)*

- [ ] 09-08-PLAN.md — Desfechos da leitura: 404 fixo, 401 → login por helper compartilhado com o acervo, puxar para atualizar sem apagar o conteúdo (SIT-04, SIT-02)

**Wave 7** *(blocked on Wave 6 completion; depois do 09-08 para serializar o `build_runner`)*

- [ ] 09-09-PLAN.md — Dados da escrita: `POST /api/imoveis/{id}/situacao/` com o corpo exato, recusa 400/403 com a mensagem do servidor achatada e falhas tipadas do envio (SIT-02, SIT-04, SIT-01)

**Wave 8** *(blocked on Wave 7 completion)*

- [ ] 09-10-PLAN.md — Folha de mudança, caminho feliz: folha e Cubit da folha (chips, Confirmar, POST com guarda de toque duplo) e tela (botão só com `pode_mudar_situacao` → POST → SnackBar e releitura; "Ver na vitrine" some após a mudança, D-18) (SIT-01, SIT-02, SIT-06, SIT-07)

**Wave 9** *(blocked on Wave 8 completion)*

- [ ] 09-11-PLAN.md — Folha completa: observação opcional com a dica do site e limite de 500 (D-17), "Data: hoje", envio protegido (carregamento, toque duplo, folha que não fecha no meio, sem alça) (SIT-01, SIT-02, SIT-04)

**Wave 10** *(blocked on Wave 9 completion)*

- [ ] 09-12-PLAN.md — Recusas e falhas na folha: 400/403 com a mensagem do servidor e a folha aberta, rede/5xx com texto fixo, 404 e 401 no envio (SIT-04, SIT-06)

**Wave 11** *(blocked on Wave 10 completion)*

- [ ] 09-13-PLAN.md — Volta ao acervo recarrega da API (D-12), fluxos ponta a ponta, README, REQUIREMENTS (todos Complete, nota no ACV-04), gates dos dois repositórios + human-check do UAT (SIT-01..07, API-11, API-12)
