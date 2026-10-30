# API Coverage — API pública Django do Imóveis Aqui (`/api/publico/`, repo `../imoveis-aqui/Web`)

> Full coverage by default. Opt-outs are explicit, reasoned decisions.

**Generated:** 2026-10-30 (plan-phase 5)
**Checkpoint:** Full API Coverage by Default — Opt Out, Never Opt In.

Fase 5 é a primeira fase em que o app faz requisições HTTP de verdade para o acervo (API-03, API-07).
A API é do próprio projeto (repo irmão), mas é um serviço separado consumido por rede, então a fase
registra a matriz completa em vez da declaração "no external API" usada na Fase 4 (precedente:
`04-pagina-do-imovel-galeria-e-dados-da-natureza/COVERAGE.md`). A superfície abaixo é a do branch
`feat/APP05` da API (WEB-09 + web-08 + o que os planos de API 05-01, 05-02, 05-04 e 05-05 adicionam).
Revisado em 2026-10-30 (revisão do plan-checker): endereço completo e `fotos[].ordem` passam a INTEGRATE (D-15
travado), e as linhas dos blocos de natureza (D-06/D-17) e dos campos removidos do app foram acrescentadas.

| capability | decision | reason |
|---|---|---|
| GET /api/publico/cidades/ (array, cidades com imóvel na vitrine) | INTEGRATE | |
| GET /api/publico/cidades/{id}/imoveis/ (rota por id, segue `next`) | INTEGRATE | |
| lista: param `busca` | INTEGRATE | |
| lista: param `ordenar` (recentes, preco, -preco, area, -area) | INTEGRATE | |
| lista: param `finalidade` | INTEGRATE | |
| lista: param `natureza` (CSV, inclui LOTE) | INTEGRATE | |
| lista: params `preco_min` / `preco_max` | INTEGRATE | |
| lista: params `area_min` / `area_max` | INTEGRATE | |
| lista: params `quartos` / `suites` / `vagas` (mínimo) | INTEGRATE | |
| lista: param `bairro` (CSV, sem diferenciar maiúsculas) | INTEGRATE | |
| lista: param `caracteristicas` (CSV de ids) | INTEGRATE | |
| lista: campo `count` do envelope | OPT-OUT | not needed yet — nenhuma tela mostra total; a prévia "Ver N imóveis" é API-05 (v2); D-11 só permite ("pode ser lido") e deixa o tratamento a critério do planner |
| lista: campo `previous` do envelope | OPT-OUT | not needed — a vitrine só rola para frente (scroll infinito) |
| lista: campo `preco_condominio` do item | OPT-OUT | not needed — o card da vitrine não mostra condomínio (VIT-02); o detalhe mostra |
| lista: resposta 400 `{campo: mensagem}` | INTEGRATE | vira `Result.failure` com "Tentar de novo" |
| GET /api/publico/cidades/{id}/bairros/ (novo, D-08) | INTEGRATE | |
| GET /api/publico/caracteristicas/ (novo, D-08, `[{id, nome}]`) | INTEGRATE | |
| GET /api/publico/imoveis/{id}/ (detalhe + blocos de natureza) | INTEGRATE | |
| detalhe: resposta 404 (fora da vitrine ou inexistente) | INTEGRATE | |
| detalhe: endereco bairro/cidade{id,nome,uf}/latitude/longitude | INTEGRATE | declarados no Model (D-15, 05-14); bairro e cidade aparecem em "bairro · cidade, UF" |
| detalhe: endereco logradouro/numero/cep | INTEGRATE | declarados e lidos no Model, conferidos contra o JSON capturado (D-15, 05-14); a página ainda não os exibe — endereço exato/mapa é APP 05 |
| detalhe: `fotos[].imagem`, `fotos[].capa` | INTEGRATE | |
| detalhe: `fotos[].ordem` | INTEGRATE | declarado no Model (D-15, 05-14); a API já entrega a capa primeiro (05-02) e o app nunca reordena |
| detalhe: `caracteristicas[].id` / `caracteristicas[].nome` | INTEGRATE | lidos como CaracteristicaModel (D-15); a página mostra o nome |
| detalhe: `casa` area_terreno, area_construida, area_livre | INTEGRATE | já no app (F4); conferidos no wire real (05-17) |
| detalhe: `casa` quartos, suites, vagas, ano_construcao | INTEGRATE | já no app (F4); conferidos no wire real (05-17) |
| detalhe: `casa` banheiros, salas, pavimentos | INTEGRATE | D-17: destaques + linhas, nulo omite (F4/D-13, D-14); conferidos no wire real (05-17) |
| detalhe: `casa` piscina, quintal, churrasqueira, mobiliada | INTEGRATE | D-17: destaques + linhas, nulo omite (F4/D-13, D-14); conferidos no wire real (05-17) |
| detalhe: `terreno` area_total, frente, fundo | INTEGRATE | |
| detalhe: `terreno` lateral_esquerda / lateral_direita | INTEGRATE | D-17: substituem `laterais`, duas linhas na UI (05-17) |
| detalhe: `terreno` topografia, murado, esquina | INTEGRATE | D-17 (05-17) |
| detalhe: `terreno` uso_permitido | INTEGRATE | D-17; código com rótulo em português no app (A-04, 05-17) |
| detalhe: `apartamento` andar, area_privativa, area_total, predio | INTEGRATE | |
| detalhe: `apartamento` quartos, suites, banheiros, vagas, varanda | INTEGRATE | |
| detalhe: `apartamento` posicao_solar | INTEGRATE | código com rótulo em português no app (A-04, 05-17) |
| detalhe: `predio` nome, andares, elevadores, portaria_24h | INTEGRATE | |
| detalhe: `predio` piscina, academia, salao_de_festas, playground | INTEGRATE | |
| detalhe: `predio` ano_construcao | INTEGRATE | D-17: substitui `predio.ano` (05-17) |
| detalhe: `lote` numero, area, frente, fundo | INTEGRATE | D-06 (05-02 na API, 05-17 no app) |
| detalhe: `lote` entrada_minima, parcelas_maximas, condicoes_parcelamento | INTEGRATE | D-06 (05-17) |
| detalhe: `lote.quadra` identificacao | INTEGRATE | D-06 (05-17) |
| detalhe: `lote.quadra.loteamento` nome, incorporadora | INTEGRATE | D-06 (05-17) |
| detalhe: `lote.quadra.loteamento` asfalto, agua, energia, esgoto, iluminacao | INTEGRATE | D-06; viram chips de infraestrutura (A-03, 05-17) |
| detalhe: `lote.quadra.loteamento` areas_de_lazer | INTEGRATE | D-06; texto corrido (A-03, 05-17) |
| app: `apartamento.numero` (a W09 não manda) | OPT-OUT | explicitly out of scope — D-17: campo que a API não manda é removido do Model, da entidade e da UI (05-17) |
| app: `predio.unidades_por_andar` (a W09 não manda) | OPT-OUT | explicitly out of scope — D-17: removido do app (05-17) |
| app: `predio.ano` / `terreno.laterais` (nomes antigos) | OPT-OUT | explicitly out of scope — D-17: renomeados para `ano_construcao` e `lateral_esquerda`/`lateral_direita` |
| app: `lote.preco` (a W07 não tem) | OPT-OUT | explicitly out of scope — D-06: o preço do lote é o `preco_venda` do imóvel; a linha "Preço do lote" sai (05-17) |
| app: `corretor.slug` (a W09 não manda) | OPT-OUT | explicitly out of scope — D-17: removido da entidade (05-16) |
| app: item da lista cidade, descricao, caracteristicas, criado_em | OPT-OUT | explicitly out of scope — D-17/A-06: removidos do Model e da entidade da lista (05-03, 05-09) |
| detalhe: corretor_responsavel id/nome/foto (ou null) | INTEGRATE | |
| detalhe: corretor_responsavel contatos, creci, apresentacao, empresa_id | OPT-OUT | explicitly out of scope — D-16: o app exibe só nome e foto; contato é APP 06; exposição sem token decidida no checkpoint do 05-02; revisão LGPD deferida (05-02-SUMMARY) |
| GET /api/publico/corretores/{id}/ (perfil público W02) | OPT-OUT | explicitly out of scope — Deferred da Fase 5: perfil completo do corretor é outra história (APP 07) |
| GET /api/publico/empresas/{id}/ (perfil público W02) | OPT-OUT | explicitly out of scope — perfil da empresa é APP 07 |
| endpoints autenticados /api/... do painel | OPT-OUT | explicitly out of scope — o app da vitrine não tem login (LOG-01 é v2) |
