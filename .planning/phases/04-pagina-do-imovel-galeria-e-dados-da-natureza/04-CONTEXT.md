# Phase 4: Página do Imóvel — Galeria e Dados da Natureza - Context

**Gathered:** 2026-10-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Card APP 04 (tarefa A04). O visitante toca num card da vitrine e abre a página do
imóvel: galeria de fotos começando pela capa, preços (venda/aluguel, condomínio, IPTU),
os dados próprios da natureza (casa, terreno, apartamento com o prédio, lote com quadra e
loteamento), descrição, características e o corretor responsável com foto e caminho
para o perfil.

Tudo vem do detalhe da API (`GET /api/publico/imoveis/{id}/`). Como o endpoint e as
naturezas ainda não existem no backend (WEB 05/06/07 e WEB 09), esta fase **define o
contrato do detalhe como adendo** e constrói sobre uma DataSource mock que serve JSON de
wire nesse formato. A troca pela DataSource real fica na Phase 5.

Fora do escopo: mapa e favoritos (APP 05), botão de WhatsApp (APP 06), conteúdo real do
perfil do corretor/empresa (APP 07), qualquer endpoint no Django.

</domain>

<decisions>
## Implementation Decisions

### Contrato do detalhe (adendo ao contrato da Fase 1)
- **D-01:** Novo endpoint `GET /api/publico/imoveis/{id}/`, documentado como adendo
  (§11) em `01-CONTRATO-API.md`, para sign-off do E2. Responde 404 para imóvel
  inexistente ou não publicado. — **Reversibility:** costly — é contrato compartilhado
  com WEB 09; mudar depois mexe no serializer Django, no Model e no mock.
- **D-02:** Natureza em **bloco por tipo**: `natureza: "CASA"|"APARTAMENTO"|"TERRENO"|"LOTE"`
  e um único objeto preenchido entre `casa`, `apartamento`, `terreno`, `lote`. No Dart vira
  uma sealed class (`DadosNatureza` com 4 variantes). — **Reversibility:** costly —
  formato de wire compartilhado.
- **D-03:** Prédio e quadra/loteamento vêm **embutidos completos**:
  `apartamento.predio: {...}` e `lote.quadra: {identificacao, loteamento: {...}}`.
  Uma chamada só, sem endpoints extras.
- **D-04:** `area_livre` da casa **vem pronta da API** (calculada no Django, regra do
  WEB 05). O app nunca calcula.
- **D-05:** Campos de cada natureza (nomes snake_case, alinhados aos cards WEB):
  - casa: `area_terreno`, `area_construida`, `area_livre`, `quartos`, `suites`,
    `banheiros`, `salas`, `vagas`, `pavimentos`, `ano_construcao`, `piscina`, `quintal`,
    `churrasqueira`, `mobiliada`
  - terreno: `area_total`, `frente`, `fundo`, `laterais`, `topografia`
    (`PLANO|ACLIVE|DECLIVE`), `murado`, `esquina`, `uso_permitido`
  - apartamento: `andar`, `numero`, `area_privativa`, `area_total`, `quartos`, `suites`,
    `banheiros`, `vagas`, `varanda`, `posicao_solar`, `predio: {nome, andares,
    unidades_por_andar, ano, elevadores, portaria_24h, piscina, academia,
    salao_de_festas, playground}`
  - lote: `numero`, `area`, `frente`, `fundo`, `preco`, `condicoes_parcelamento`,
    `quadra: {identificacao, loteamento: {nome, incorporadora, infraestrutura: [..],
    areas_lazer: [..]}}`
  Áreas e valores monetários como **string decimal** (mesma regra F2/D-03).
- **D-06:** Parte comum do detalhe, além do que a lista já tem: `fotos: [{url, capa,
  ordem}]` (capa primeiro), `preco_condominio`, `preco_iptu`, `descricao`,
  `caracteristicas: [nome]`, `corretor: {id, nome, foto, slug}` e endereço público
  (`bairro`, `cidade`, `latitude`, `longitude`; lat/lng já pensando no APP 05).
  Allowlist pública: sem proprietário, documentos ou dados internos (§6 do contrato).

### Galeria
- **D-07:** `PageView` com contador "1/N" no canto, capa primeiro.
- **D-08:** Toque abre visualizador em tela cheia com swipe e pinch-zoom
  (`InteractiveViewer`), sem dependência nova.
- **D-09:** Galeria dentro de `SliverAppBar` colapsável (`CustomScrollView`), botão
  voltar sempre visível.
- **D-10:** Sem fotos: placeholder já usado na vitrine (`foto_capa_imovel.dart`), sem
  contador.

### Layout
- **D-11:** Ordem: título + bairro/cidade + preços → natureza → descrição →
  características → corretor.
- **D-12:** Sem barra inferior fixa nesta fase (o botão de WhatsApp é do APP 06).
- **D-13:** Natureza: linha de destaques com ícone (quartos, área, vagas, etc.) e depois
  lista rótulo/valor. Prédio e loteamento ficam num `Card` próprio.
- **D-14:** Campo nulo **omite a linha**. Seção vazia some inteira.

### Corretor e navegação
- **D-15:** O card do corretor (foto + nome) é tocável e abre uma **tela stub de perfil
  do corretor** (nome + foto vindos do detalhe), que o APP 07 vai completar.
- **D-16:** A abertura mostra na hora a **prévia que a vitrine já tem** (capa, título,
  preço) e carrega o detalhe. As seções completas aparecem quando ele chega.
- **D-17:** Erros: 404 mostra "Este imóvel não está mais disponível" com voltar à
  vitrine; os outros erros mostram "Tentar de novo". Estados explícitos
  Loading/Success/Failure num Cubit próprio (`DetalheImovelCubit`).
- **D-18:** Navegação por `Navigator.push` + `MaterialPageRoute`, como no resto do app.
  Sem go_router. O `ImovelCard` ganha `onTap`.

### Claude's Discretion
- Ícones exatos, rótulos de topografia/posição solar, formato das áreas ("120 m²").
- Fixtures do mock: pelo menos um imóvel por natureza, mais um sem fotos e um com campos
  nulos. Ids batendo com os imóveis do fixture da vitrine.
- Estrutura de pastas em `presentation/detalhe_imovel/`.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Contrato da API
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` — contrato de `/cidades` e `/imoveis`, §3 campos, §6 allowlist pública, §9–10 adendos; recebe o novo §11 (detalhe)
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imoveis.example.json` — exemplo de wire da lista; ganha um `imovel_detalhe.example.json`

### Decisões anteriores
- `.planning/phases/03-vitrine-filtros-server-side/03-CONTEXT.md` — padrões da vitrine (mock sobre wire, D-19 reinício)
- `.planning/phases/02-vitrine-lista-busca-e-ordena-o/` — F2/D-03 (preço como string), padrão do mock datasource

### Cards do kanban (origem dos campos)
- APP 04: critérios de aceite listados no ROADMAP Phase 4
- WEB 05 (casa/terreno), WEB 06 (prédio/apartamento), WEB 07 (loteamento/quadra/lote): campos resumidos em D-05
- Backend atual: `../imoveis-aqui/Web/imoveis/models.py` (`Imovel`, `FotoImovel`). Ainda não há natureza

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/presentation/vitrine/widgets/foto_capa_imovel.dart`: imagem com cache e placeholder (galeria e "sem fotos")
- `lib/presentation/vitrine/apresentacao_imovel.dart`: formatação de preço e finalidade, a ser reaproveitada
- `lib/domain/entities/imovel.dart`: a prévia (D-16) vem desta entidade
- `lib/data/datasources/imovel_mock_datasource.dart` + `lib/data/mocks/imoveis_fixture.dart`: padrão do mock sobre JSON de wire

### Established Patterns
- Clean Architecture data/domain/presentation; Model freezed + json_serializable; DI com injectable (`@LazySingleton(as: ...)`)
- Mock filtra/serve mapas de wire e parseia pelo mesmo Model que o remoto vai usar
- Cubit com estado freezed imutável; Result/sealed para erros

### Integration Points
- `lib/presentation/vitrine/widgets/imovel_card.dart`: adicionar `onTap` → push da página
- `ImovelDataSource`/`ImovelRepository`: novo método `buscarDetalhe(id)` (ou datasource separada para o detalhe)
- `lib/di/`: registrar a datasource mock do detalhe

</code_context>

<specifics>
## Specific Ideas

- Critérios do card APP 04 são o checklist de aceite (ROADMAP Phase 4, itens 1–6).
- O critério 6 fica atendido "por contrato" nesta fase e de fato na Phase 5.

</specifics>

<deferred>
## Deferred Ideas

- Barra inferior fixa com preço + botão WhatsApp: APP 06.
- Mapa do imóvel e favoritar: APP 05 (lat/lng já entram no contrato).
- Conteúdo real do perfil do corretor e da empresa: APP 07.
- Deep link e go_router: avaliar quando houver necessidade de links externos.

</deferred>
