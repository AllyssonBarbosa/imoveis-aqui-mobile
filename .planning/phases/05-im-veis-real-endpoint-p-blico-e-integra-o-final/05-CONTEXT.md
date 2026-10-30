# Phase 5: Imóveis Real — Endpoint Público e Integração Final - Context

**Gathered:** 2026-10-29
**Status:** Ready for planning

<domain>
## Phase Boundary

O app deixa de usar mocks: vitrine (lista, busca, ordenação, filtros, opções de filtro),
cidades e página do imóvel passam a vir da API Django real. A API pública **já existe**
(card WEB 09, branch `origin/WEB-09` da colega) — esta fase **não reescreve** essa API: junta
as branches da frente web numa branch do usuário, completa o que falta para o app (lote,
multi-seleção, endpoints de opções, regra de vitrine da W08, seed de dev) e **adapta o app ao
formato real**. A pendência da APP 04 (bloco `lote`, WEB 07) é resolvida aqui.

**Mudança de premissa em relação ao ROADMAP/contrato da Fase 1:** o contrato congelado no
`01-CONTRATO-API.md` (§3–§11) **não** é mais a fonte da verdade — a web é dona do dado e da
regra, e a API real da WEB-09 divergiu dele (rotas, paginação, nomes). O app segue a API real;
o contrato do app é atualizado para documentar o formato real.

</domain>

<decisions>
## Implementation Decisions

### Direção geral
- **D-01:** O **app se adapta à API real** (WEB-09 + ajustes desta fase). Não se pede à
  equipe web que volte ao contrato da Fase 1. UI, Cubits e `domain/` mudam o mínimo
  necessário; a adaptação fica concentrada em `data/` (Models, DataSources, params).
  — **Reversibility:** costly — reverter exigiria reescrever Models/DataSources de novo.
- **D-02:** `01-CONTRATO-API.md` e os `contrato/*.example.json` são **atualizados para o
  formato real** (exemplos regerados a partir de respostas reais da API semeada), com os
  itens §11.5 marcados como resolvidos pelo código da web onde couber.

### Repositório da API (`../imoveis-aqui`)
- **D-03:** O usuário trabalha numa branch **`feat/APP05` local, sem push** (push/PR só com
  OK explícito). Base: **`origin/WEB-09` + merge de `origin/feat/web-08`** (a web-08 já
  contém W05/W06/W07/W08). **`WEB-10` fica de fora** (usuário não a considera pronta).
  Conflitos de models/migrations/tests entre W08 e W09 são resolvidos nessa branch.
  — **Reversibility:** reversible — branch local, nada publicado.
- **D-04:** `imoveis_da_vitrine()` (W09, `Web/imoveis/vitrine.py`) passa a usar a **regra da
  W08**: só imóvel **publicado E situação DISPONÍVEL** de empresa ativa (reaproveitar o
  queryset/manager `na_vitrine` da W08 em vez de duplicar a regra). Isso vale para lista,
  detalhe e cidades atendidas.
- **D-05:** **`GET /api/publico/cidades/` da W09 vence** (lista simples, sem paginação; cidades
  com ao menos um imóvel na vitrine). A rota antiga do usuário em `feat/APP02`
  (`empresas.api` + `CidadeCursorPagination`) **não** entra na `feat/APP05`. O app passa a ler
  um array JSON simples (deixa de seguir cursor em cidades).
- **D-06:** **Lote no endpoint público** (pendência APP04/WEB 07):
  - `natureza=LOTE` passa a ser aceita no filtro e o detalhe ganha o bloco `lote`
    (`LotePublicoSerializer`), seguindo o padrão `SERIALIZER_PUBLICO_POR_NATUREZA` da W09
    (os outros blocos vêm `null`).
  - Conteúdo do bloco = **contrato da Fase 4 ajustado ao model W07**: `numero`, `area`,
    `frente`, `fundo`, parcelamento (`entrada_minima`, `parcelas_maximas`,
    `condicoes_parcelamento`), **quadra embutida** e **loteamento embutido** (nome,
    incorporadora, asfalto, água, energia, esgoto, iluminação, áreas de lazer).
    Sem `lote.preco` — no model W07 o preço do lote é o `preco_venda` do Imóvel (resolve
    §11.5 item d: o app deixa de ter a linha "Preço do lote").
  - Anotações da vitrine incluem o lote: `area_anuncio` do lote = `lote.area`; cidade/bairro
    do lote seguem o endereço do imóvel (verificar no model W07 se o lote usa o endereço do
    Imóvel ou a cidade do Loteamento e anotar coerentemente).
- **D-07:** **Multi-seleção via CSV** na busca da W09: `natureza=CASA,LOTE` e
  `bairro=Centro,Cambuí` viram filtros `__in` (OU entre valores, F3/D-05), retrocompatível
  com valor único. Bairro continua case-insensitive.
- **D-08:** **Novos endpoints públicos de opções** (sem token, `authentication_classes = []`
  como a W09):
  - `GET /api/publico/cidades/<id>/bairros/` — bairros com imóvel na vitrine naquela cidade
    (mesma `imoveis_da_vitrine()`/`bairro_anuncio`), array de strings ordenado.
  - `GET /api/publico/caracteristicas/` — catálogo `[{id, nome}]`.
- **D-09:** **`semear_vitrine_dev`** (hoje não rastreado em `Web/empresas/management/`) é
  estendido e versionado na `feat/APP05`: cria empresa demo, corretor, características,
  imóveis das **4 naturezas** (incluindo loteamento → quadra → lote) com fotos, publicados e
  disponíveis, nas 4 cidades. Continua idempotente e só com `DEBUG=True`.
- **D-10:** Toda mudança na API vem com testes no padrão de `Web/imoveis/tests.py`
  (inclusive o teste de allowlist "nada de proprietário/documento/dado interno" estendido ao
  bloco `lote` e aos endpoints novos).

### Lista, filtros e paginação (app)
- **D-11:** Lista = `GET /api/publico/cidades/<id>/imoveis/` (cidade pelo **id** na rota, não
  mais `nome-uf` em query). Paginação `PageNumberPagination` do DRF: o app **segue a URL
  `next`** da resposta (`{count, next, previous, results}`), mantendo o `seguir(proximaPagina)`
  atual e as defesas de mesma origem/limite de páginas. `count` pode ser lido no Model.
- **D-12:** Nomes de params seguem a W09: `quartos`/`suites`/`vagas` (mínimo — já é a
  semântica F3/D-01), `ordenar` com `recentes|preco|-preco|area|-area` mapeados a partir de
  `OrdenacaoVitrine` (rótulos da UI não mudam), `busca`, `finalidade`, `natureza`, `bairro`,
  `preco_min/max`, `area_min/max`, `caracteristicas`.
- **D-13:** **Características passam a ser `{id, nome}`** no app: opção de filtro carrega id,
  UI mostra o nome, query manda CSV de **ids**. Resolve o risco de vírgula em nome
  registrado na F3 (D-06).
- **D-14:** Regras de negócio da W09 que diferem de decisões antigas do app **valem as da
  web** (ex.: busca também em `descricao` vs F2/D-06; preço sem finalidade = venda ou
  aluguel via Coalesce vs F2/D-12). O app não compensa nada localmente.

### Detalhe e corretor (app)
- **D-15:** O Model do detalhe segue o JSON real da W09: `fotos[].imagem` (+`ordem`,`capa`),
  `endereco{logradouro,numero,bairro,cep,cidade{id,nome,uf},latitude,longitude}`,
  `caracteristicas[{id,nome}]`, `corretor_responsavel` (pode vir `null` — corretor
  desativado), blocos `casa|apartamento|terreno|lote`.
- **D-16:** **Corretor:** aceitar o que a API manda (perfil público da W02: nome, CRECI, foto,
  telefone, WhatsApp, e-mail, apresentação). O app **exibe só nome e foto** como na Fase 4;
  contato fica para o APP 06. O stub de perfil (F4/D-15) continua abrindo com os dados que
  vieram no detalhe — **sem** chamar `/api/publico/corretores/<id>/`.
- **D-17:** Campos que a API não manda são **removidos** do app; renomeados seguem a API:
  sem `apartamento.numero`, sem `predio.unidades_por_andar`, `predio.ano` →
  `ano_construcao`, `terreno.laterais` → `lateral_esquerda` + `lateral_direita` (duas linhas
  na UI). Campos novos que vierem (ex.: casa `banheiros`, `salas`, `pavimentos`, `piscina`,
  `quintal`, `churrasqueira`, `mobiliada`; terreno `topografia`, `murado`, `esquina`,
  `uso_permitido`) entram seguindo F4/D-13/D-14 (destaques + linhas; nulo omite).

### Mocks e testes (app)
- **D-18:** **Mocks removidos do app**: `ImovelMockDataSource`, `ImovelDetalheMockDataSource`,
  `OpcoesFiltroMockDataSource`, `imoveis_fixture.dart`, `imoveis_detalhe_fixture.dart` saem de
  `lib/`. O DI registra só as DataSources `dio` reais. Fixtures de wire (JSON capturado da API
  real semeada) vão para `test/`; testes de Cubit/Repository usam `mocktail`. Os gatilhos
  determinísticos de erro do mock (ids 338/339, F2/D-15) passam a ser cobertos por testes com
  DataSource mockada (`DioException` 404/500).
  — **Reversibility:** costly — reintroduzir mock offline exigiria reescrever fixtures no
  formato novo.

### Claude's Discretion
- Ordem e fatiamento dos planos (recomendado: API primeiro — merge + lote + CSV + opções +
  seed — depois app, com JSON real capturado para os testes).
- Mapeamento exato `OrdenacaoVitrine` → `ordenar`; tratamento de `count`.
- Formato de erro de validação 400 da W09 (`{campo: mensagem}`) → `Failure` do app.
- Resolução de conflitos de merge W08×W09 (preservar comportamento e testes de ambos).
- Como o app trata `corretor_responsavel: null` (omite o card, F4/D-14).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### API real (repo irmão `../imoveis-aqui`, ler via `git show <branch>:<path>`)
- `origin/WEB-09:Web/imoveis/api/views.py` — `VitrineCidadeAPIView` (params, ordenação, paginação) e `ImovelVitrineDetalheAPIView`
- `origin/WEB-09:Web/imoveis/api/serializers.py` — serializers públicos (allowlist) e `SERIALIZER_PUBLICO_POR_NATUREZA`
- `origin/WEB-09:Web/imoveis/vitrine.py` — `imoveis_da_vitrine()` e anotações `*_anuncio`
- `origin/WEB-09:Web/imoveis/api/urls_publico.py`, `origin/WEB-09:Web/localizacao/api/views.py` — rotas públicas e cidades atendidas
- `origin/WEB-09:README.md` — seção "Vitrine pública (API) — regras de negócio"
- `origin/feat/web-08:Web/imoveis/models.py` — `Loteamento`/`Quadra`/`Lote` (W07), `situacao`, `na_vitrine` (W08)
- `origin/WEB-09:Web/contas/api/serializers.py` — `CorretorPublicoSerializer`
- `../imoveis-aqui/Web/empresas/management/commands/semear_vitrine_dev.py` — seed de dev (não rastreado) a estender
- `../imoveis-aqui/CLAUDE.md` — regras do repo da API

### Contrato e fases anteriores do app
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` — contrato antigo (§3–§11) a ATUALIZAR; §11.5 lista as pendências E2
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/*.example.json` — exemplos a regerar
- `.planning/phases/03-vitrine-filtros-server-side/03-CONTEXT.md` — semântica dos filtros (D-01..D-06, D-20)
- `.planning/phases/04-pagina-do-imovel-galeria-e-dados-da-natureza/04-CONTEXT.md` — UI do detalhe (D-07..D-19)
- `.planning/phases/04-pagina-do-imovel-galeria-e-dados-da-natureza/04-VERIFICATION.md` — cadeia mock→DI a trocar

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/data/datasources/cidade_remote_datasource.dart`: já é `dio` real, com defesas de mesma origem e `maxPaginas` — reaproveitar o padrão de seguir `next` na lista de imóveis; ajustar cidades para array simples.
- `lib/data/datasources/{imovel,imovel_detalhe,opcoes_filtro}_datasource.dart`: interfaces trocáveis — criar implementações remotas e trocar a anotação de DI.
- `lib/data/datasources/parametros_consulta_imoveis.dart`: único lugar que monta query params — concentrar aqui a tradução para os nomes da W09.
- `lib/data/models/{imovel_model,detalhe_imovel_model,dados_natureza_model,imoveis_envelope_model}.dart`: Models freezed a ajustar ao wire real.
- `lib/data/models/url_segura.dart` (`urlHttpOuNula`): continuar filtrando `fotos[].imagem`/`foto_capa`/foto do corretor.
- `lib/di/modulo_rede.dart`: base URL por `--dart-define=API_BASE_URL`.

### Established Patterns
- Clean Architecture; tradução wire↔domínio privada em cada arquivo de `data/`; `Result` sealed; Cubit com estados freezed.
- Switch exaustivo de natureza sem `default` (LOTE já existe no domínio).
- Testes de contrato (`test/data/contrato_detalhe_test.dart`) comparam fixture × example JSON — reapontar para JSON real capturado.

### Integration Points
- `lib/di/injection.config.dart` l.98/101/110 registram os três mocks — trocar pelas remotas (gerado por `build_runner`).
- API: `Web/config/urls.py` inclui `localizacao`/`imoveis` `urls_publico`.

</code_context>

<specifics>
## Specific Ideas

- Usuário pediu explicitamente: "realize o merge e siga o trabalho" — a junção WEB-09 + web-08 é o primeiro passo da execução.
- Branch do app: `feat/APP05` (padrão `feat/<card>`), a partir de `feat/APP04`.

</specifics>

<deferred>
## Deferred Ideas

- Tela completa de perfil do corretor consumindo `/api/publico/corretores/<id>/` — outra história.
- Botão de contato/WhatsApp do corretor — APP 06.
- Revisar exposição pública de contato do corretor (LGPD, §11.5 g) — decisão da frente web/produto; o app só exibe nome e foto.
- Merge na `main` da API / PR para a equipe — só com OK do usuário.
- WEB-10 (site público) — fora desta fase.

</deferred>

---

*Phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final*
*Context gathered: 2026-10-29*
