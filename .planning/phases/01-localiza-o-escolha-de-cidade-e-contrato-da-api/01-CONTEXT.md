# Phase 1: Localização, Escolha de Cidade e Contrato da API - Context

**Gathered:** 2026-09-21
**Status:** Ready for planning

<domain>
## Phase Boundary

O visitante abre o app e entra numa cidade atendida — por localização (GPS + reverse
geocoding) ou por escolha manual — com a cidade guardada localmente e trocável a qualquer
momento. Em paralelo, o **contrato escrito de `GET /cidades` e `GET /imoveis`** fica
congelado (nomes de campo, enums, params de filtro, envelope de paginação) para orientar
APP02/APP03 e o endpoint real da Fase 4.

Cobre: LOC-01..LOC-06, API-01.

Fora desta fase (só clarificamos COMO, não adicionamos capacidade): vitrine/lista de
imóveis (Fase 2), filtros (Fase 3), endpoint real de imóveis (Fase 4), `GET /cidades` real
via API (Fase 2 — nesta fase a lista é fixa embutida).
</domain>

<decisions>
## Implementation Decisions

### Contrato da API (API-01)
- **D-01:** Envelope de paginação = **cursor** (DRF `CursorPagination`), resposta
  `{next, previous, results}`. Escolhido porque imuniza a vitrine contra cards
  duplicados/embaralhados quando o acervo muda durante o scroll (critério de sucesso das
  Fases 2/3). Trade-off aceito: sem `count` total e sem pulo de página.
  — **Reversibility:** one-way — trocar o esquema de paginação depois quebra o contrato já
  acordado com a frente web e o parsing de todas as respostas paginadas do app.
- **D-02:** Congelar o **contrato completo** já incluindo os campos de tipologia que ainda
  NÃO existem no model (`natureza` casa/apto/terreno/lote, `quartos`, `suites`, `vagas`,
  `area`), marcados explicitamente como **pendente E2**. APP02/APP03 buildam contra fixtures
  completas; quando E2 entregar o model, o real já bate. Este é o ponto de coordenação com
  a frente web.
  — **Reversibility:** costly — renomear/reformatar esses campos depois obriga a mexer em
  fixtures, models Freezed do app e no serializer público da API ao mesmo tempo.
- **D-03:** Documento de contrato = **Markdown human-legível** (tabelas de campos, enums,
  params de filtro, envelope) **+ arquivos JSON de exemplo** que servem de fixture do mock
  (API-04). Versionado **no repo do app E no repo da API** (`../imoveis-aqui/Web`) para o E2
  enxergar e concordar antes de qualquer código de APP02/03.
- **D-04:** Idioma/estilo de campos e query params = **português snake_case**
  (`cidade`, `preco_min`, `preco_max`, `quartos_min`, `natureza`, `finalidade`,
  `ordenacao`, `cursor`). Coerente com a constraint "idioma do código em português" e com os
  models Django já em PT.

### Fluxo de permissão de localização
- **D-05:** Pedir a permissão com **tela de priming antes** — uma tela curta explicando o
  porquê, com CTA "Usar minha localização" que só então dispara o prompt nativo do OS.
  Reduz recusa e evita queimar a permissão. Ainda atende LOC-01.
- **D-06:** Desfecho `deniedForever` (bloqueado para sempre) → **cai na lista de cidades**
  (caminho normal) **+ CTA discreto "Ativar localização nas Ajustes"** que abre as
  configurações do sistema (`geolocator.openAppSettings`). Nunca uma tela de erro.
- **D-07:** Os **5 desfechos** de localização (autorizado / recusado / bloqueado-para-sempre
  / serviço-desligado / cidade-não-atendida) = estados explícitos (sealed class / enum) na
  **mesma tela de seleção de cidade**, variando só a mensagem do topo e o CTA. Coerente com
  "estado explícito, nunca exceção genérica" (LOC-06) e com o padrão sealed do projeto.
- **D-08:** Reabertura do app com cidade já guardada → **vai direto pra cidade guardada**,
  sem re-pedir GPS. Localização só roda na 1ª vez (sem cidade) ou quando o usuário pede pra
  trocar. Respeita LOC-04 e evita prompt repetido.

### Match da cidade detectada
- **D-09:** Casamento reverse geocoding → cidade atendida = **nome + UF normalizado**
  (acentos, caixa, espaços). Casa com o model `Cidade` (`unique(nome, uf)`). Evita
  falso-positivo entre homônimas de estados diferentes.
- **D-10:** Cidade detectada com sucesso E atendida → **entra direto** na vitrine dela
  (critério "já entra nela"), mostrando o nome no topo, trocável num toque. Sem passo de
  confirmação.
- **D-11:** Cidade detectada mas NÃO atendida → **lista de cidades + aviso leve**
  ("Ainda não atendemos [Cidade] — escolha uma das disponíveis"). Transparente, sem beco
  (LOC-02).
- **D-12:** Falha no reverse geocoding (sem internet / timeout / sem resultado) → tratada
  como **mais um desfecho explícito → cai na lista** de cidades, sem tela de erro (LOC-06).

### Lista fixa de cidades (Fase 1; vira API na Fase 2)
- **D-13:** Formato = **asset JSON** (`assets/cidades.json`) com a **mesma forma do contrato
  de `GET /cidades`**. Trocar por API na Fase 2 vira só mudar a fonte; o `fromJson` já é o
  definitivo e reaproveita a fixture do contrato.
- **D-14:** Acesso via **`CidadeRepository`/`DataSource` com impl local** (lê o asset) nesta
  fase; na Fase 2 entra a impl remota por **DI** (`get_it`/`injectable`) sem tocar
  UI/Cubit. Aplica o padrão trocável do API-04 já às cidades.
- **D-15:** Persistir a cidade escolhida por **nome + uf (chave natural)**, não por id.
  O model `Cidade` tem `unique(nome, uf)`, então resolve de forma estável tanto na lista
  fixa quanto na API — não depende de ids fixos casarem com os ids reais do banco na
  transição da Fase 2.
  — **Reversibility:** costly — mudar a chave persistida depois exige migração do valor já
  gravado no `shared_preferences` dos usuários existentes.
- **D-16:** Conteúdo da lista fixa = **espelhar as Cidades já cadastradas no banco da API**
  (as realmente atendidas), garantindo consistência com o que `GET /cidades` devolverá na
  Fase 2.

### Claude's Discretion
- Nenhuma decisão delegada — o usuário respondeu todas as áreas explicitamente.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Projeto / requisitos
- `.planning/PROJECT.md` — visão, constraints não-negociáveis (Clean Architecture, Cubit,
  Freezed, Result/sealed, Material 3, paleta verde/branco, código em PT). **Nota:** a seção
  Context afirma que "o model de Imóvel ainda não existe" — isto está DESATUALIZADO (ver
  code_context abaixo).
- `.planning/REQUIREMENTS.md` — LOC-01..06 e API-01..04 com rastreabilidade por fase.
- `.planning/ROADMAP.md` §Phase 1 — goal e success criteria congelados desta fase.
- `.claude/CLAUDE.md` — stack recomendada com versões (dio, flutter_bloc, freezed,
  geolocator, geocoding, shared_preferences, get_it, injectable) e o que NÃO usar.

### API irmã (contrato / auditoria — API-01)
- `../imoveis-aqui/Web/imoveis/models.py` — `Imovel`, `Caracteristica`, `FotoImovel` (estado
  real de campos hoje; base do contrato de `/imoveis`).
- `../imoveis-aqui/Web/localizacao/models.py` — `Cidade(nome, uf)` (base do contrato de
  `/cidades` e da chave natural persistida).
- `../imoveis-aqui/Web/core/models.py` — `Endereco(bairro, cidade FK, latitude, longitude)`
  e base multitenant `EmpresaOwnedModel` (isolamento é critério de maior peso da avaliação).
- `../imoveis-aqui/Web/imoveis/api/` (`serializers.py`, `views.py`, `urls.py`) — `ImovelViewSet`
  autenticado/empresa-scoped existente; referência para o serializer PÚBLICO com allowlist.
- `../imoveis-aqui/Web/config/urls.py` — roteamento atual; `/api/publico/` já existe para
  contas/empresas; falta `/api/publico/cidades/` e `/api/publico/imoveis/`.
- `../imoveis-aqui/README.md` e `../imoveis-aqui/CLAUDE.md` — contexto do repo da API.

### Histórias de origem
- `../APP 01 · Abertura, navegação, localização e escolha da cidade.md` — história A01.
- `../instruções.md` — diretrizes de stack/arquitetura da equipe.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Repo do app está vazio** (só `.DS_Store`) — greenfield. Sem scaffold Flutter ainda; a
  Fase 1 inclui criar o esqueleto de pastas Clean Architecture (`data/`, `domain/`,
  `presentation/`) e o `pubspec.yaml` com a stack do CLAUDE.md.
- **API irmã já tem base sólida:** `Cidade`, `Imovel`, `Endereco`, `FotoImovel`,
  `Caracteristica`, multitenant (`EmpresaOwnedModel` + `EmpresaScopedQuerySetMixin`), auth
  por Token, e um `ImovelViewSet` autenticado. O endpoint público reaproveita esses models.

### Established Patterns
- **Padrão trocável mock→real por DI** (API-04) é o eixo da arquitetura — aplicado nesta
  fase às cidades (D-14) e nas seguintes aos imóveis.
- **Estados como sealed/enum** (`Loading`/`Success<T>`/`Failure`) — reaproveitado para os 5
  desfechos de localização (D-07).
- **Multitenant / allowlist:** o serializer público NÃO pode vazar proprietário, documento
  ou dado interno, nem quebrar isolamento por empresa (peso alto na avaliação) — o contrato
  de `/imoveis` (D-02) precisa refletir isso.

### Integration Points
- `assets/cidades.json` (D-13) ← gerado a partir das Cidades do banco da API (D-16);
  mesma forma que `GET /cidades` devolverá na Fase 2.
- `shared_preferences` guarda `nome+uf` da cidade escolhida (D-15), lido na abertura (D-08).
- Documento de contrato versionado nos dois repos (D-03); seus JSONs viram as fixtures do
  mock DataSource.

### ⚠️ Divergência detectada (resolver no plan/execute)
O PROJECT.md diz "não existem `/cidades`, `/imoveis`, nem o model de Imóvel". Na verdade o
model `Imovel` **existe** (com finalidade, preços, descrição, caracteristicas, endereço,
fotos, publicado). O que realmente falta: **tipologia** (`natureza`, `quartos`, `suites`,
`vagas`, `area`) e os **endpoints públicos** `/api/publico/cidades/` e `/api/publico/imoveis/`.
A auditoria de API-01 deve partir daqui, não do zero.

</code_context>

<specifics>
## Specific Ideas

- O usuário é backend forte (Java/Spring, Python/FastAPI) — decisões priorizam tipagem
  forte, inversão de controle e tratamento explícito de erro; analogias Java/Python são
  bem-vindas nas explicações.
- Cursor pagination foi escolhida conscientemente contra o "count total", porque a
  consistência do scroll infinito pesa mais que a prévia "Ver N imóveis" (esta última é
  v2 / API-05).

</specifics>

<deferred>
## Deferred Ideas

- **`GET /cidades` real via API** — Fase 2 (VIT-06/API-02); nesta fase a lista é fixa.
- **Endpoint real de `/imoveis` + troca do DataSource por DI** — Fase 4 (API-03).
- **Result-count "Ver N imóveis"** no botão aplicar — v2 (API-05), depende de custo de
  contagem barato; reforça a escolha de cursor pagination sem count agora.
- **Tipologia do imóvel no model Django** (natureza/quartos/suítes/vagas/área) — dependência
  externa do E2 (frente web); nesta fase só é *congelada no contrato*, não implementada.

None além dos itens acima — a discussão ficou dentro do escopo da fase.

</deferred>

---

*Phase: 1-Localização, Escolha de Cidade e Contrato da API*
*Context gathered: 2026-09-21*
