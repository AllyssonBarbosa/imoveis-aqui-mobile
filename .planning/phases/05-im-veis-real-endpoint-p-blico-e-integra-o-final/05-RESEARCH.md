# Phase 5: Imóveis Real — Endpoint Público e Integração Final - Research

**Researched:** 2026-10-30
**Domain:** Integração Flutter (Clean Architecture, dio, freezed, get_it/injectable) com a API Django/DRF real (`../imoveis-aqui`), mais completar essa API (merge WEB-09 + web-08, lote, multi-seleção CSV, endpoints de opções, regra de vitrine, seed)
**Confidence:** HIGH para o estado do repo da API e para o desvio de wire (lido do código das branches nesta sessão); MEDIUM para o resultado do merge (só `git merge-tree` foi rodado, nenhum teste executado); MEDIUM para UX/semântica de busca (acentos) e para o impacto exato nos testes do app.

> Pesquisa somente-leitura: nenhum arquivo de código foi alterado, nenhum commit/push/checkout foi feito em nenhum dos dois repositórios. O working tree do repo da API continua em `feat/APP02` (com `Web/empresas/management/` não rastreado).

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Direção geral**
- **D-01:** O **app se adapta à API real** (WEB-09 + ajustes desta fase). Não se pede à equipe web que volte ao contrato da Fase 1. UI, Cubits e `domain/` mudam o mínimo necessário; a adaptação fica concentrada em `data/` (Models, DataSources, params). — **Reversibility:** costly.
- **D-02:** `01-CONTRATO-API.md` e os `contrato/*.example.json` são **atualizados para o formato real** (exemplos regerados a partir de respostas reais da API semeada), com os itens §11.5 marcados como resolvidos pelo código da web onde couber.

**Repositório da API (`../imoveis-aqui`)**
- **D-03:** O usuário trabalha numa branch **`feat/APP05` local, sem push** (push/PR só com OK explícito). Base: **`origin/WEB-09` + merge de `origin/feat/web-08`** (a web-08 já contém W05/W06/W07/W08). **`WEB-10` fica de fora**. Conflitos de models/migrations/tests entre W08 e W09 são resolvidos nessa branch. — **Reversibility:** reversible.
- **D-04:** `imoveis_da_vitrine()` (W09, `Web/imoveis/vitrine.py`) passa a usar a **regra da W08**: só imóvel **publicado E situação DISPONÍVEL** de empresa ativa (reaproveitar o queryset/manager `na_vitrine` da W08 em vez de duplicar a regra). Vale para lista, detalhe e cidades atendidas.
- **D-05:** **`GET /api/publico/cidades/` da W09 vence** (lista simples, sem paginação; cidades com ao menos um imóvel na vitrine). A rota antiga do usuário em `feat/APP02` (`empresas.api` + `CidadeCursorPagination`) **não** entra na `feat/APP05`. O app passa a ler um array JSON simples (deixa de seguir cursor em cidades).
- **D-06:** **Lote no endpoint público** (pendência APP04/WEB 07): `natureza=LOTE` passa a ser aceita no filtro e o detalhe ganha o bloco `lote` (`LotePublicoSerializer`), seguindo o padrão `SERIALIZER_PUBLICO_POR_NATUREZA` da W09 (os outros blocos vêm `null`). Conteúdo do bloco = **contrato da Fase 4 ajustado ao model W07**: `numero`, `area`, `frente`, `fundo`, parcelamento (`entrada_minima`, `parcelas_maximas`, `condicoes_parcelamento`), **quadra embutida** e **loteamento embutido** (nome, incorporadora, asfalto, água, energia, esgoto, iluminação, áreas de lazer). Sem `lote.preco` — no model W07 o preço do lote é o `preco_venda` do Imóvel (resolve §11.5 item d: o app deixa de ter a linha "Preço do lote"). Anotações da vitrine incluem o lote: `area_anuncio` do lote = `lote.area`; cidade/bairro do lote seguem o endereço do imóvel (verificar no model W07 se o lote usa o endereço do Imóvel ou a cidade do Loteamento e anotar coerentemente).
- **D-07:** **Multi-seleção via CSV** na busca da W09: `natureza=CASA,LOTE` e `bairro=Centro,Cambuí` viram filtros `__in` (OU entre valores, F3/D-05), retrocompatível com valor único. Bairro continua case-insensitive.
- **D-08:** **Novos endpoints públicos de opções** (sem token, `authentication_classes = []` como a W09): `GET /api/publico/cidades/<id>/bairros/` — bairros com imóvel na vitrine naquela cidade (mesma `imoveis_da_vitrine()`/`bairro_anuncio`), array de strings ordenado; `GET /api/publico/caracteristicas/` — catálogo `[{id, nome}]`.
- **D-09:** **`semear_vitrine_dev`** (hoje não rastreado em `Web/empresas/management/`) é estendido e versionado na `feat/APP05`: cria empresa demo, corretor, características, imóveis das **4 naturezas** (incluindo loteamento → quadra → lote) com fotos, publicados e disponíveis, nas 4 cidades. Continua idempotente e só com `DEBUG=True`.
- **D-10a:** (verificação da `feat/web-07`/`feat/web-08`, 2026-10-29) A **W08 também criou uma vitrine pública** — `VitrineImovelViewSet` em `/api/publico/imoveis/` (lista + detalhe, sem filtros/paginação própria), com `VitrineImovelSerializer(ImovelSerializer)` que **já traz `lote`**, mas expõe `codigo`, `empresa`, `corretor_responsavel` (id) e o `endereco` interno. Colide com a rota `imoveis/<pk>/` da W09. No merge: **vencem as views e serializers públicos da W09**; a `VitrineImovelViewSet` da W08 sai e os testes dela são reapontados para a W09. A regra `na_vitrine()` da W08 é aproveitada em `imoveis_da_vitrine()` (D-04), e o `LoteSerializer`/`LoteamentoResumoSerializer` da W07 servem de base para o `LotePublicoSerializer` (sem ids internos de empresa). Conflitos previstos (`git merge-tree`): `config/urls.py`, `imoveis/api/{serializers,views,urls_publico}.py`, `imoveis/tests.py`.
- **D-10:** Toda mudança na API vem com testes no padrão de `Web/imoveis/tests.py` (inclusive o teste de allowlist "nada de proprietário/documento/dado interno" estendido ao bloco `lote` e aos endpoints novos).

**Lista, filtros e paginação (app)**
- **D-11:** Lista = `GET /api/publico/cidades/<id>/imoveis/` (cidade pelo **id** na rota, não mais `nome-uf` em query). Paginação `PageNumberPagination` do DRF: o app **segue a URL `next`** da resposta (`{count, next, previous, results}`), mantendo o `seguir(proximaPagina)` atual e as defesas de mesma origem/limite de páginas. `count` pode ser lido no Model.
- **D-12:** Nomes de params seguem a W09: `quartos`/`suites`/`vagas` (mínimo), `ordenar` com `recentes|preco|-preco|area|-area` mapeados a partir de `OrdenacaoVitrine` (rótulos da UI não mudam), `busca`, `finalidade`, `natureza`, `bairro`, `preco_min/max`, `area_min/max`, `caracteristicas`.
- **D-13:** **Características passam a ser `{id, nome}`** no app: opção de filtro carrega id, UI mostra o nome, query manda CSV de **ids**. Resolve o risco de vírgula em nome registrado na F3 (D-06).
- **D-14:** Regras de negócio da W09 que diferem de decisões antigas do app **valem as da web** (ex.: busca também em `descricao` vs F2/D-06; preço sem finalidade = venda ou aluguel via Coalesce vs F2/D-12). O app não compensa nada localmente.

**Detalhe e corretor (app)**
- **D-15:** O Model do detalhe segue o JSON real da W09: `fotos[].imagem` (+`ordem`,`capa`), `endereco{logradouro,numero,bairro,cep,cidade{id,nome,uf},latitude,longitude}`, `caracteristicas[{id,nome}]`, `corretor_responsavel` (pode vir `null` — corretor desativado), blocos `casa|apartamento|terreno|lote`.
- **D-16:** **Corretor:** aceitar o que a API manda (perfil público da W02). O app **exibe só nome e foto** como na Fase 4; contato fica para o APP 06. O stub de perfil (F4/D-15) continua abrindo com os dados que vieram no detalhe — **sem** chamar `/api/publico/corretores/<id>/`.
- **D-17:** Campos que a API não manda são **removidos** do app; renomeados seguem a API: sem `apartamento.numero`, sem `predio.unidades_por_andar`, `predio.ano` → `ano_construcao`, `terreno.laterais` → `lateral_esquerda` + `lateral_direita` (duas linhas na UI). Campos novos que vierem entram seguindo F4/D-13/D-14 (destaques + linhas; nulo omite).

**Mocks e testes (app)**
- **D-18:** **Mocks removidos do app**: `ImovelMockDataSource`, `ImovelDetalheMockDataSource`, `OpcoesFiltroMockDataSource`, `imoveis_fixture.dart`, `imoveis_detalhe_fixture.dart` saem de `lib/`. O DI registra só as DataSources `dio` reais. Fixtures de wire (JSON capturado da API real semeada) vão para `test/`; testes de Cubit/Repository usam `mocktail`. Os gatilhos determinísticos de erro do mock (ids 338/339, F2/D-15) passam a ser cobertos por testes com DataSource mockada (`DioException` 404/500). — **Reversibility:** costly.

### Claude's Discretion
- Ordem e fatiamento dos planos (recomendado: API primeiro — merge + lote + CSV + opções + seed — depois app, com JSON real capturado para os testes).
- Mapeamento exato `OrdenacaoVitrine` → `ordenar`; tratamento de `count`.
- Formato de erro de validação 400 da W09 (`{campo: mensagem}`) → `Failure` do app.
- Resolução de conflitos de merge W08×W09 (preservar comportamento e testes de ambos).
- Como o app trata `corretor_responsavel: null` (omite o card, F4/D-14).

### Deferred Ideas (OUT OF SCOPE)
- Tela completa de perfil do corretor consumindo `/api/publico/corretores/<id>/` — outra história.
- Botão de contato/WhatsApp do corretor — APP 06.
- Revisar exposição pública de contato do corretor (LGPD, §11.5 g) — decisão da frente web/produto; o app só exibe nome e foto.
- Merge na `main` da API / PR para a equipe — só com OK do usuário.
- WEB-10 (site público) — fora desta fase.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| API-03 | `GET /api/publico/imoveis/?cidade=...&filtros` público, sem token, busca/ordenação/filtros/paginação server-side, só publicados, serializer com allowlist, sem quebrar multitenant | A rota real é `GET /api/publico/cidades/<id>/imoveis/` (D-11) — **o texto de API-03 em REQUIREMENTS/ROADMAP descreve a rota antiga e deve ser atualizado**. A view `VitrineCidadeAPIView` da WEB-09 já cobre busca/ordenação/filtros/paginação/allowlist; falta: regra `na_vitrine` (D-04), `natureza=LOTE` com anotações, CSV (D-07), endpoints de opções (D-08). Ver "Estado atual da API". |
| API-07 | `GET /api/publico/imoveis/{id}/` público, só publicados, 404 igual para inexistente e não publicado, allowlist, e troca da DataSource do detalhe por DI | `ImovelVitrineDetalheAPIView` da WEB-09 já existe (404 via queryset filtrado). Falta bloco `lote` e `na_vitrine`; no app falta `ImovelDetalheRemoteDataSource` + Model novo (ver tabela de drift). |
</phase_requirements>

## Summary

A API pública **já existe** na `origin/WEB-09` (lista por cidade, detalhe, cidades atendidas), mas **diverge do contrato congelado da Fase 1 em quase tudo**: rota da lista (`cidades/<id>/imoveis/`), paginação (`PageNumberPagination`, page_size 20, não cursor), nomes de param (`ordenar`, `quartos`, `suites`, `vagas`), formato do item da lista (sem `cidade`, `descricao`, `caracteristicas`, `criado_em`) e do detalhe (`endereco{}` aninhado, `fotos[].imagem`, `caracteristicas[{id,nome}]`, `corretor_responsavel`, `lateral_esquerda/direita`). O app atual (Models freezed estritos, com campos `required` que a API não envia) **vai quebrar no parse** se só se trocar a anotação de DI — a adaptação em `data/` é o grosso da parte do app. Três mudanças de contrato **vazam para `domain/`/`presentation/`** apesar de D-01 (necessidade técnica, não escolha): (1) `Cidade` precisa carregar o `id` (rota usa id; hoje o `id` é descartado de propósito, D-15 da F1); (2) características `{id,nome}` mudam o tipo de `FiltrosVitrine.caracteristicas`/`OpcoesFiltroRepository`; (3) `DadosLote`/`DadosLoteamento`/`DadosTerreno`/`DadosApartamento`/`DadosPredio` perdem/ganham campos.

Na API, o trabalho é: criar `feat/APP05` a partir de `origin/WEB-09`, fazer merge de `origin/feat/web-08` (5 arquivos em conflito, **sem conflito de migrations** — a WEB-09 não adiciona migration), trocar a regra de `imoveis_da_vitrine()` para `Imovel.objects.na_vitrine()`, adicionar `LOTE` (anotações `area_anuncio`, `select_related("lote__quadra__loteamento")`, `LotePublicoSerializer`), CSV em `natureza`/`bairro`, os dois endpoints de opções e estender o seed. O seed e os testes dependem de **Postgres local** (porta 5432 respondeu a `nc`; credenciais/estado do banco não verificados) e da venv `Web/.venv` (Python 3.13, Django 5.2.17, DRF 3.18.1 — presentes).

Há três **decisões sutis que o CONTEXT não fechou** e que mudam código: (a) como o `Cidade` do app ganha `id` quando a cidade vem do prefs sem a lista (fallback de falha de rede); (b) `posicao_solar` e `uso_permitido` chegam como **códigos** (`NASCENTE`, `RESIDENCIAL`), não rótulos — o texto "como veio" de F4/D-19b mostraria `NASCENTE` em caixa alta; (c) `areas_de_lazer` do loteamento é **um TextField livre**, e a infraestrutura são **5 booleanos** — não as listas do contrato antigo. Ver "Open Questions".

**Primary recommendation:** Fatiar em fatias verticais com a API primeiro (Plano A: branch + merge + regra `na_vitrine` + testes verdes; Plano B: lote/CSV/opções/seed + captura de JSON real), depois o app em fatias "visitante vê a lista real" → "filtra de verdade (ids de característica, CSV)" → "abre o detalhe real (inclui lote)" → "remove mocks, migra testes, reescreve contrato". Toda fixture de teste do app deve ser **JSON capturado da API semeada**, nunca escrito à mão, para impedir drift silencioso.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Regra "o que aparece na vitrine" (publicado + DISPONÍVEL + empresa ativa) | API / Backend | — | `Imovel.objects.na_vitrine()` (W08); app nunca decide visibilidade (regra do projeto) |
| Busca, ordenação, filtros, paginação | API / Backend | — | `VitrineCidadeAPIView`; o app só monta query params e segue `next` |
| Allowlist pública (sem proprietário/documento/empresa/código) | API / Backend | — | Serializers `*Publico*` listam campo a campo; teste de vazamento no Django |
| Isolamento multitenant | API / Backend | Database | Vitrine é cross-empresa **por desenho** (sem usuário); isolamento = só publicado+ativa; o painel autenticado segue `EmpresaScopedQuerySetMixin` |
| Opções de filtro (bairros da cidade, catálogo de características) | API / Backend | — | Derivadas da mesma `imoveis_da_vitrine()`; o app não deriva opções de listas locais |
| Tradução wire → domínio (nomes, `endereco{}`, códigos de enum) | Cliente (`data/`) | — | Models freezed + `paraEntidade()`; `domain/` nunca vê nome de campo de wire |
| Rótulos pt-BR de enums (topografia, posição solar, uso permitido) | Cliente (`presentation/`) | — | Apresentação; a API manda códigos |
| Formatação de moeda/área | Cliente (`presentation/`) | — | Já existe (`formatarPrecoBrl`, `formatarAreaM2`); valores chegam como string decimal, nunca calculados |
| Escolha de DataSource (mock → real) | Cliente (DI) | — | `injectable`: remover mocks de `lib/` faz o gerador registrar só as remotas |
| Seed de desenvolvimento | API / Database | — | Management command `semear_vitrine_dev`, só com `DEBUG=True` |

## Estado atual da API (inspecionado em `../imoveis-aqui`)

**Working tree:** branch `feat/APP02`; único não rastreado = `Web/empresas/management/` (seed atual, 70 linhas) [VERIFIED: `git status --short` → `?? Web/empresas/management/`]. Branches remotas: `origin/WEB-09`, `origin/WEB-10`, `origin/feat/web-03-web-04`, `feat/web-05`, `feat/web-06`, `feat/web-07`, `feat/web-08`, `main`, `feat/APP02` [VERIFIED: `git branch -a`]. **O model Imóvel já pousou** (W04..W08) — o bloqueio externo do STATE.md ("Phase 5 externally blocked on Imóvel model") **está resolvido** e deve ser retirado dos Blockers.

**Grafo:** `merge-base(WEB-09, feat/web-08) = ae2f623` (W06). WEB-09 = W05 + W06 + `8ad1410` (W09, 10 arquivos); web-08 = W05 + W06 + W07 + W08 (+2 commits de máscara de data) [VERIFIED: `git log`/`git merge-base`]. A W09 **não adiciona migration** (stat do commit `8ad1410` não lista `migrations/`), logo não há conflito de numeração; a web-08 traz `0005_loteamento_quadra_lote` e `0006_situacao_historico_documentos` [VERIFIED: `git show --stat 8ad1410`; `git diff --stat ae2f623 origin/feat/web-08`].

**`git merge-tree --write-tree origin/WEB-09 origin/feat/web-08` (só leitura) lista conflito em exatamente 5 arquivos** [VERIFIED: saída do comando]:
```
Web/config/urls.py
Web/imoveis/api/serializers.py
Web/imoveis/api/urls_publico.py
Web/imoveis/api/views.py
Web/imoveis/tests.py
```
(igual ao previsto em D-10a). `models.py`/`forms.py`/templates mesclam sem conflito.

### O que existe na WEB-09 (e o app consome)

Rotas [VERIFIED: `origin/WEB-09:Web/imoveis/api/urls_publico.py`, `Web/localizacao/api/urls_publico.py`, `Web/config/urls.py`]:
```
path("cidades/<int:cidade_id>/imoveis/", VitrineCidadeAPIView.as_view(), name="publico-vitrine-cidade"),
path("imoveis/<int:pk>/", ImovelVitrineDetalheAPIView.as_view(), name="publico-imovel"),
path("cidades/", CidadeAtendidaAPIView.as_view(), name="publico-cidades"),
```
todas sob `path('api/publico/', include(...))`. **Não existe** `GET /api/publico/imoveis/` (lista) na WEB-09, nem bairros, nem características públicas.

Lista — `VitrineCidadeAPIView` [VERIFIED: `origin/WEB-09:Web/imoveis/api/views.py` l.165-290]:
- `permission_classes = [AllowAny]`, `authentication_classes = []` (token vencido não atrapalha); `PaginacaoVitrine(PageNumberPagination)` com `page_size = 20`, **sem** `page_size_query_param`; settings **não** definem `DEFAULT_PAGINATION_CLASS` (só auth/permissions) [VERIFIED: `settings.py` bloco `REST_FRAMEWORK`].
- Ordenações: `"recentes": [F("criado_em").desc()]`, `"preco"`, `"-preco"`, `"area"`, `"-area"` (nulls_last); desempate `"-id"`; `.distinct().prefetch_related("fotos")`.
- Params validados: `busca` (`titulo|bairro_anuncio|descricao` com `icontains`), `finalidade` (`VENDA|ALUGUEL|VENDA_E_ALUGUEL`; venda/aluguel também trazem `VENDA_E_ALUGUEL`), `natureza` (valor único, `Imovel.Natureza.values`), `preco_min/max`, `area_min/max` (Decimal ≥ 0), `quartos`/`suites`/`vagas` (int ≥ 0, mínimo), `bairro` (`bairro_anuncio__iexact`, **valor único**), `caracteristicas` (CSV de ids, **E** entre eles), `ordenar`. Valor inválido → `ValidationError({nome: "..."})` = HTTP 400 `{campo: mensagem}`.
- Cidade inexistente → `get_object_or_404(Cidade, pk=...)` = 404.

Item da lista — `ImovelVitrineSerializer` [VERIFIED: `origin/WEB-09:Web/imoveis/api/serializers.py` l.305-333]:
```
fields = [
    "id", "titulo", "natureza", "finalidade", "preco_venda", "preco_aluguel",
    "preco_condominio", "bairro", "area", "quartos", "suites", "vagas", "foto_capa",
]
```
`foto_capa` = URL absoluta (`request.build_absolute_uri`) da capa (ou primeira foto) ou `null`; decimais saem como string (DRF `COERCE_DECIMAL_TO_STRING` default; não sobrescrito em settings).

Detalhe — `ImovelVitrineDetalheSerializer` [VERIFIED: serializers.py l.334-]:
```
fields = [
    "id", "titulo", "natureza", "finalidade", "preco_venda", "preco_aluguel",
    "preco_condominio", "preco_iptu", "descricao", "caracteristicas", "casa",
    "terreno", "apartamento", "endereco", "fotos", "corretor_responsavel",
]
```
`endereco` = `EnderecoPublicoSerializer` (`["logradouro", "numero", "bairro", "cep", "cidade", "latitude", "longitude"]`, `cidade` = `CidadeSerializer` → `["id", "nome", "uf"]`); `fotos` = `FotoPublicaSerializer` (`["imagem", "ordem", "capa"]`); `caracteristicas` = `CaracteristicaSerializer` (`["id", "nome"]`); `corretor_responsavel` = `CorretorPublicoSerializer` ou `None` se `not corretor.is_active`. O queryset do detalhe é `imoveis_da_vitrine().select_related(...)` → rascunho/empresa inativa ⇒ 404 (mesma resposta para inexistente).

`corretor_responsavel` expõe [VERIFIED: `contas/api/serializers.py` + `Usuario.dados_perfil_publico`]: `id`, `empresa_id`, `foto` (URL absoluta ou `null`; faz fallback para `empresa.logomarca`), `nome`, `email`, `creci`, `telefone`, `whatsapp`, `apresentacao`. **Atenção:** o teste de vazamento da W09 só proíbe a chave `empresa`, não `empresa_id` (ver Pitfall 9).

Regra de vitrine atual — `imoveis_da_vitrine()` [VERIFIED: `origin/WEB-09:Web/imoveis/vitrine.py` l.35]: `Imovel.objects.filter(publicado=True, empresa__ativa=True)` — **sem checar `situacao`** (a coluna só existe depois do merge). Anotações: `cidade_anuncio`, `bairro_anuncio` (apartamento → endereço do prédio), `area_anuncio` (`CASA`→`casa__area_construida`, `APARTAMENTO`→`apartamento__area_privativa`, `TERRENO`→`terreno__area_total`), `quartos_anuncio/suites_anuncio/vagas_anuncio` (casa/apartamento). `APARTAMENTO/CASA/TERRENO` são as únicas constantes — **não há `LOTE`**.

Cidades — `CidadeAtendidaAPIView` [VERIFIED: `origin/WEB-09:Web/localizacao/api/views.py` l.21]: `Cidade.objects.filter(pk__in=imoveis_da_vitrine().values("cidade_anuncio"))`, sem paginação (retorna **array**), ordem pelo `Meta.ordering = ["nome", "uf"]` de `Cidade`; item `{id, nome, uf}`.

### O que a web-08 traz (e o merge precisa preservar)

- `ImovelQuerySet.na_vitrine()` [VERIFIED: `origin/feat/web-08:Web/imoveis/models.py` l.14-19]:
```python
class ImovelQuerySet(models.QuerySet):
    def na_vitrine(self):
        """O que a vitrine pública mostra: só disponível E publicado, de empresa ativa (W08)."""
        return self.filter(
            publicado=True, situacao=Imovel.Situacao.DISPONIVEL, empresa__ativa=True
        )
```
  com `objects = ImovelQuerySet.as_manager()` em `Imovel`. `Imovel.Situacao`: `DISPONIVEL`, `RESERVADO`, `VENDIDO`, `ALUGADO`; `situacao` é `editable=False`, `default=DISPONIVEL`. `Imovel.Natureza` ganha `LOTE = "LOTE", "Lote"`.
- Model `Lote` [VERIFIED: models.py l.576-]: `imovel` OneToOne (`related_name="lote"`), `quadra` FK, `numero` (Char 10), `area`, `frente`, `fundo` (Decimal), `entrada_minima` (Decimal, null), `parcelas_maximas` (PositiveSmallInt, null), `condicoes_parcelamento` (Text, blank). **Sem endereço próprio e sem preço** ("O preço é o preço de venda do Imovel"). `Lote.vendido` = `imovel.situacao == VENDIDO` (na vitrine sempre `False`, pois só DISPONÍVEL aparece).
- `Quadra`: `loteamento` FK, `identificacao` (Char 20). `Loteamento(EmpresaOwnedModel)`: `nome`, `cidade` FK, `incorporadora`, booleanos `asfalto`, `agua`, `energia`, `esgoto`, `iluminacao`, e `areas_de_lazer` = **TextField livre** ("Ex.: praça, quadra poliesportiva, pista de caminhada.").
- **Resposta à dúvida de D-06 (cidade/bairro do lote):** o lote **usa o endereço do Imóvel**. `Imovel.endereco_do_anuncio` só desvia para o prédio quando `natureza == APARTAMENTO`; para as demais retorna `self.endereco`, e `pendencias_para_publicar()` exige endereço completo (CEP, logradouro, número, bairro, cidade, lat/lng) para publicar. Logo a anotação `_do_anuncio("cidade_id", ...)`/`bairro_anuncio` da W09 **já funciona para LOTE sem mudança** (ramo `default`). `Loteamento.cidade` é um segundo campo de cidade independente — pode divergir do endereço do imóvel; a vitrine deve ignorá-lo e o seed deve usar a mesma cidade nos dois.
- Vitrine pública da W08 (`VitrineImovelViewSet` + `VitrineImovelSerializer(ImovelSerializer)`, rota `imoveis` via `SimpleRouter`) — **vazadora** (`codigo`, `empresa`, `corretor_responsavel` id): sai no merge (D-10a). O `LoteSerializer`/`LoteamentoResumoSerializer` (l.167-270 de `serializers.py` da web-08) mostram `quadra: {id, identificacao, loteamento: {...}}` + `vendido` — **não reaproveitar tal qual** (têm `id`s e `cidade` id internos); copiar o formato e listar campos à mão.

### Settings / infra da API [VERIFIED: `origin/WEB-09:Web/config/settings.py`]
- `ALLOWED_HOSTS = env.list("ALLOWED_HOSTS", default=["localhost", "127.0.0.1"])`; `.env.example` da `feat/APP02` inclui `10.0.2.2` (alias do emulador Android). **Não há CORS** (irrelevante para app nativo; **impede rodar o app no Chrome/web**).
- `MEDIA_URL = 'media/'`, `MEDIA_ROOT = BASE_DIR / 'media'`; `urls.py` serve `static(MEDIA_URL, ...)` só com `DEBUG`. `Web/media/` está no `.gitignore`.
- `DATABASES` via `DATABASE_URL` (padrão `postgres://postgres:postgres@localhost:5432/imoveis_aqui`) — **Postgres obrigatório** (testes também). `psycopg 3.3.5`, `pillow 12.3.0` na venv.
- Auth padrão `TokenAuthentication`+`SessionAuthentication`, permissão padrão `IsAuthenticated` — por isso as views públicas **precisam** de `permission_classes=[AllowAny]` **e** `authentication_classes=[]` (padrão a copiar para as duas views novas).

### Testes da API [VERIFIED: `origin/WEB-09:Web/imoveis/tests.py`]
Padrão a seguir: `APITestCase`; helpers `criar_empresa/criar_corretor/criar_proprietario/criar_imovel/criar_endereco/criar_predio/criar_apartamento/gerar_imagem`; `VitrineBase(APITestCase)` com `@override_settings(MEDIA_ROOT=MEDIA_DE_TESTE)`, cenário com São Paulo (casa, sobrado, apartamento, terreno), rascunho, empresa inativa e Campinas; helpers `buscar(cidade, **params)` e `ids(response)`; classes `VitrineCidadesTests`, `VitrineBuscaTests`, `VitrineDetalheTests`, `VitrineSemTokenESemVazamentoTests` (l.1005-1400). O teste de vazamento tem:
```python
CHAVES_PROIBIDAS = {
    "proprietario", "documento", "nome_razao_social", "codigo", "empresa", "publicado",
    "pode_publicar", "atualizado_em", "criado_em", "complemento", "valor_condominio_base",
    "unidades_por_andar", "imovel",
}
```
e `VALORES_PROIBIDOS` (nome do proprietário, CPF, códigos internos, complemento). É uma **lista de proibição** — não pega campo novo inocente (ex.: `id` de loteamento ou `empresa_id`). Para lote/opções, adicionar teste de **igualdade exata de chaves** (allowlist) além do deny-list.

## Desvio de wire: contrato congelado (F1/F4) × API real × impacto no app

Estas são as diferenças **verificadas** entre o que os Models atuais do app esperam (lidos em `lib/data/models/*.dart`) e o que a API real emite (lido dos serializers). Cada linha é uma tarefa concreta de `data/`.

### Lista (`ImovelModel` / `ImoveisEnvelopeModel` / `parametros_consulta_imoveis.dart`)

| Aspecto | App hoje | API real | Ação |
|---|---|---|---|
| Rota | `/api/publico/imoveis/` + `?cidade=nome-uf` | `/api/publico/cidades/<id>/imoveis/` | Montar path com `cidade.id`; remover param `cidade` |
| Envelope | `{next, previous, results}` (cursor) | `{count, next, previous, results}` (PageNumber) — D-11 | Adicionar `int? count` ao `ImoveisEnvelopeModel` (opcional); `next` continua URL absoluta |
| Item: `descricao`, `cidade`, `caracteristicas`, `criado_em` | **`required`** no `ImovelModel` | **não existem** na lista | Remover do Model/entidade ou tornar opcionais — senão `fromJson` lança `TypeError` em toda linha |
| Item: `bairro` | `required String` | `CharField(source="bairro_anuncio")` — pode vir `null` se o endereço não tiver bairro | Tolerar `null` (→ `''`) |
| Item: `preco_condominio`, `suites`, `vagas`, `area` | `area/suites/vagas` ok (`String?`/`int?`); `preco_condominio` ignorado | enviados | Nada obrigatório; `preco_condominio` pode ser ignorado |
| `Imovel.cidade` (entidade) | `required Cidade` (usada em `rotuloLocalizacao(bairro, cidade)` na prévia do detalhe e `==`) | não vem na lista | Preencher a partir da `ConsultaImoveis.cidade` na DataSource/Repository **para a 1ª página**; para `seguir(next)` não há consulta ⇒ ou tornar `Imovel.cidade` opcional, ou guardar a cidade no Repository. Recomendado: remover `cidade` de `Imovel` e a prévia mostrar só o bairro até o detalhe carregar (cidade vem do `endereco.cidade`) |
| `ordenacao` | `ordenacao=mais_recentes|preco_asc|preco_desc|area_asc|area_desc` | `ordenar=recentes|preco|-preco|area|-area` | Mapear em `parametrosDaConsulta` (ou trocar `OrdenacaoVitrine.valorApi`) |
| `quartos_min/suites_min/vagas_min` | sufixo `_min` | `quartos/suites/vagas` (mínimo) | Renomear chaves |
| `natureza` CSV | `natureza=CASA,LOTE` ordem do enum | igual após D-07 (hoje WEB-09 aceita **um** valor, e rejeita `LOTE`) | Sem mudança no app; depende da API |
| `bairro` CSV | `bairro=A,B` | igual após D-07 | idem |
| `caracteristicas` CSV de **nomes** | nomes | CSV de **ids** inteiros (`int(item)`; nome ⇒ 400) | Ver "Características" abaixo |
| `finalidade`, `busca`, `preco_min/max`, `area_min/max` | iguais | iguais | Sem mudança |
| Erros 400 | `FormatException` simulada | `{campo: "mensagem"}` | `Failure(DioException)`; UI já mostra "Tentar de novo" |

`parametrosDaConsulta` também tem o **inverso** `filtrosDosParametros`/`*DoParametro` usado só pelo mock — sai junto com os mocks (D-18).

### Cidades (`CidadeRemoteDataSource` / `CidadeModel`)
| App hoje | API real | Ação |
|---|---|---|
| Espera objeto `{next, results}` e segue cursor, `maxPaginas=20` | **array simples** `[{id,nome,uf}]`, sem paginação (D-05) | Reescrever `obterCidades` para `List`; descartar linhas inválidas como hoje; manter a defesa de linha sem campos |
| `CidadeModel.paraEntidade()` **descarta o `id`** (F1/D-15) | rota nova usa o `id` | `Cidade` precisa carregar `id` (ver Open Question 1) |

### Opções de filtro (`OpcoesFiltroDataSource`)
| App hoje | API real (após D-08) | Ação |
|---|---|---|
| `caminhoBairrosPublico = '/api/publico/bairros/'` com cidade em query | `GET /api/publico/cidades/<id>/bairros/` → `["Bela Vista", ...]` (array de strings ordenado) | Atualizar o caminho; `List<String>` |
| `caminhoCaracteristicasPublico = '/api/publico/caracteristicas/'` → `List<String>` | `GET /api/publico/caracteristicas/` → `[{id, nome}]` | Novo `CaracteristicaModel`; **`OpcoesFiltroRepository.caracteristicas()` e `FiltrosVitrine.caracteristicas` mudam de tipo** (D-13) |

### Detalhe (`DetalheImovelModel`, `dados_natureza_model.dart`)

| Campo app | Wire atual do app | API real | Ação |
|---|---|---|---|
| `bairro`, `cidade`, `latitude`, `longitude` | top-level (`required`) | dentro de `endereco{logradouro,numero,bairro,cep,cidade{id,nome,uf},latitude,longitude}` | Ler de `endereco`; `endereco` pode ser `null` ⇒ tolerar (fallback `''`/`null`) |
| `fotos[].url` | `url` (required) | `fotos[].imagem` (+`ordem`,`capa`) | `@JsonKey(name:'imagem')`; continuar com `urlHttpOuNula` |
| `caracteristicas` | `List<String>` | `List<{id,nome}>` | Model `CaracteristicaModel`; entidade do detalhe pode manter `List<String>` (nomes) |
| `corretor{id,nome,foto,slug}` | `corretor` | `corretor_responsavel` (pode ser `null`) com `id, empresa_id, foto, nome, email, creci, telefone, whatsapp, apresentacao` | Renomear chave; `slug` some (era PENDENTE a); ignorar e-mail/telefone/etc. (Model só declara o que usa) |
| `descricao` | required | `descricao` (TextField, pode ser `""`) | ok |
| `natureza` | string | string `CASA|APARTAMENTO|TERRENO|LOTE` | ok |
| `terreno.laterais` | `String? laterais` | `lateral_esquerda`, `lateral_direita` (DecimalField → string) | Dois campos; duas linhas na UI (D-17) |
| `terreno.topografia` | enum `PLANO|ACLIVE|DECLIVE` | idem [VERIFIED: `Topografia(models.TextChoices)`: `PLANO`, `ACLIVE`, `DECLIVE`] | ok |
| `terreno.uso_permitido` | texto cru | **código** `RESIDENCIAL|COMERCIAL|MISTO|INDUSTRIAL|RURAL` [VERIFIED: `UsoPermitido`] | Mapear para rótulo pt-BR em `presentation/` (como `rotuloTopografia`) |
| `apartamento.numero` | existe | **não enviado** (omitido de propósito: "Sem o número da unidade") | Remover campo/linha "Unidade" |
| `apartamento.posicao_solar` | "texto livre legível" (F4/D-19b) | **código** `NASCENTE|POENTE|NORTE|SUL` [VERIFIED: `PosicaoSolar`], pode ser `""` (blank=True) | Rótulo em `presentation/`; `""` ⇒ omitir linha |
| `apartamento.predio.unidades_por_andar` | existe | **não enviado** | Remover |
| `apartamento.predio.ano` | `ano` | `ano_construcao` | Renomear |
| `apartamento.predio` demais | `nome, andares, elevadores, portaria_24h, piscina, academia, salao_de_festas, playground` | idem [VERIFIED: `PredioPublicoSerializer.fields`] | ok |
| `lote.preco` | existe → linha "Preço do lote" | **não existe** (D-06) | Remover do Model/entidade/linha |
| `lote.{numero,area,frente,fundo,condicoes_parcelamento}` | ok | previstos em D-06 | ok |
| `lote.entrada_minima`, `lote.parcelas_maximas` | não existem | novos (D-06) | Novos campos em `DadosLote` + 2 linhas (`formatarPrecoBrl`, inteiro) |
| `lote.quadra.loteamento.infraestrutura` | `List<String>` | **5 booleanos**: `asfalto, agua, energia, esgoto, iluminacao` | Traduzir em `data/` para lista de rótulos dos verdadeiros (mantém `DadosLoteamento.infraestrutura: List<String>`) |
| `lote.quadra.loteamento.areas_lazer` | `List<String>` (`areas_lazer`) | `areas_de_lazer` = **string livre** | Ver Open Question 3 |
| `casa.*` | igual | `CasaPublicaSerializer.fields` = os 14 campos atuais [VERIFIED] | ok (nenhuma mudança) |
| `fotos` ordem/capa | capa primeiro | **ordem do queryset `fotos` (`ordering = ["ordem","id"]`)** — a capa NÃO é forçada para o início, só `capa: true` marca | Verificar: o app "nunca reordena". Se `capa` não for a primeira, a galeria não começa pela capa (DET-02). Ver Pitfall 6 |

### Fotos: a capa não vem primeiro
`FotoPublicaSerializer` serve `FotoImovel` na ordem `["ordem","id"]` e a capa é só uma marca [VERIFIED: `FotoImovel.Meta.ordering`, `FotoPublicaSerializer.fields = ["imagem","ordem","capa"]`; no detalhe `fotos = FotoPublicaSerializer(many=True, read_only=True)` sem ordenação por capa]. Como `definir_como_capa` não muda `ordem`, a capa pode estar no meio da lista. DET-02 exige "começando pela capa". Decisão necessária: ou a API ordena (`ordem` com capa primeiro — regra de negócio da web) ou o app faz um *stable partition* (apresentação, não regra). Recomendação: **corrigir na API** no `ImovelVitrineDetalheSerializer` (ordenar `capa` desc, `ordem`, `id`) + teste; é a mesma regra que escolhe `foto_capa` da lista.

## Standard Stack

Nenhum pacote novo em nenhum dos dois repositórios. [VERIFIED: `pubspec.yaml` e `Web/requirements.txt` lidos]

### Core (app — já no projeto)
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| dio | ^5.11.1 | HTTP; `DioException` com `response.statusCode` | Já usado por `CidadeRemoteDataSource`; padrão de teste com `HttpClientAdapter` falso já existe |
| freezed + json_serializable + build_runner | ^4.0.1 / ^6.14.1 / ^2.16.1 | Models/entidades; regenera `*.freezed.dart`, `*.g.dart`, `injection.config.dart` | Padrão do repo |
| injectable + get_it | ^3.0.0 / ^9.3.0 | DI; remover mocks de `lib/` + `build_runner` troca o registro | Padrão do repo |
| mocktail | ^1.0.5 | Fakes de DataSource/Repository nos testes | Já no repo (D-18 manda usar) |
| intl | ^0.20.3 | `formatarPrecoBrl`/`formatarAreaM2` | Já usado |

### Core (API — já no projeto)
| Library | Version | Purpose |
|---------|---------|---------|
| Django | 5.2.17 | ORM, `TestCase`, management commands |
| djangorestframework | 3.18.1 | `ListAPIView`, `PageNumberPagination`, serializers |
| Pillow | 12.3.0 | Gerar JPEG/PNG de seed (o `validar_imagem` abre a imagem de verdade) |
| psycopg / psycopg-binary | 3.3.5 | Postgres |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `django-filter` para CSV/`__in` | filtros manuais na view (como a W09) | Não adicionar dependência; a view já tem o padrão `_numero/_escolha` — estender com `_csv_escolha` |
| `http_mock_adapter` nos testes de dio | `HttpClientAdapter` falso escrito à mão (já no repo) | Sem pacote novo |
| Teste de contrato app × API por geração automática | JSON capturado versionado em `test/fixtures/api/` | Simples; regenerar com `curl` contra o seed (documentar o comando) |

**Installation:** nenhuma.

**Version verification:** versões lidas de `pubspec.yaml`/`requirements.txt` (não reconsultadas em registry — nenhuma dependência é adicionada).

## Package Legitimacy Audit

Esta fase **não instala pacotes externos** (app e API). Gate `package-legitimacy` não aplicável.

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
 Visitante (sem login)
        │
        ▼
 ┌───────────────── App Flutter ─────────────────────────────────────────────┐
 │ presentation: CidadeSelecao → VitrineCubit/OpcoesFiltroCubit/DetalheCubit  │
 │        │ ConsultaImoveis(cidade{id,..}, busca, ordenacao, FiltrosVitrine)   │
 │        ▼                                                                    │
 │ domain: UseCases → Repository (interfaces; Result<T>)                       │
 │        ▼                                                                    │
 │ data: RepositoryImpl ─► DataSource(remote, dio) ─► Model.fromJson ─► Entidade│
 │        parametros_consulta_imoveis.dart = ÚNICO lugar de nomes de param     │
 │        seguir(next): mesma origem + limite de páginas (defesas)             │
 └──────────────────────────────┬──────────────────────────────────────────────┘
                                │ HTTP GET (API_BASE_URL, sem token)
                                ▼
 ┌────────────────────── Django / DRF (api/publico/) ───────────────────────────┐
 │ cidades/                    → CidadeAtendidaAPIView  (array)                 │
 │ cidades/<id>/imoveis/       → VitrineCidadeAPIView   (filtros, ordenar, page)│
 │ cidades/<id>/bairros/   [novo] → bairros da vitrine da cidade                │
 │ caracteristicas/        [novo] → [{id,nome}]                                 │
 │ imoveis/<pk>/               → ImovelVitrineDetalheAPIView (404 = não na vitrine)│
 │            └── todos partem de imoveis_da_vitrine() ─► Imovel.objects.na_vitrine()│
 │                  (publicado ∧ DISPONÍVEL ∧ empresa ativa) + anotações *_anuncio│
 │ serializers públicos (allowlist campo a campo; SERIALIZER_PUBLICO_POR_NATUREZA)│
 └──────────────────────────────┬──────────────────────────────────────────────┘
                                ▼
                        PostgreSQL (Imovel, Casa/Terreno/Apartamento/Lote, FotoImovel…)
```

### Recommended Project Structure (mudanças)

```
imoveis-aqui/Web/                      (branch feat/APP05, local)
├── imoveis/vitrine.py                 # imoveis_da_vitrine() usa na_vitrine(); +LOTE nas anotações
├── imoveis/api/serializers.py         # +LotePublicoSerializer, +Quadra/LoteamentoPublico, +CaracteristicaPublica reaproveitada
├── imoveis/api/views.py               # CSV (natureza/bairro); +BairrosDaCidade, +CaracteristicasPublicas; −VitrineImovelViewSet
├── imoveis/api/urls_publico.py        # +bairros/, +caracteristicas/ (sem router da W08)
├── empresas/management/commands/semear_vitrine_dev.py   # estendido e versionado
└── imoveis/tests.py                   # testes novos + os da W08 reapontados

imovies-aqui-mobile/
├── lib/data/datasources/{imovel,imovel_detalhe,opcoes_filtro}_remote_datasource.dart   # novos (dio)
├── lib/data/datasources/cidade_remote_datasource.dart      # array simples
├── lib/data/datasources/parametros_consulta_imoveis.dart   # só ida (sem inverso); nomes W09
├── lib/data/models/*                                       # ajustados ao wire real
├── lib/data/mocks/ , *_mock_datasource.dart                # REMOVIDOS (D-18)
└── test/fixtures/api/*.json + test/support/*               # JSON capturado + fakes
```

### Pattern 1: DataSource remota da lista (copiar a defesa do `CidadeRemoteDataSource`)
**What:** `buscar(consulta)` faz `GET caminho(cidade.id)` com `queryParameters = parametrosDaConsulta(consulta)`; `seguir(next)` valida que `next` tem mesmo scheme/host/port da `baseUrl` e faz `GET next` (URL absoluta; dio ignora `baseUrl`). Limite de páginas não se aplica a `seguir` (uma página por chamada); a defesa de origem se aplica sempre.
**When to use:** única DataSource da lista.
```dart
// Source: padrão já presente em lib/data/datasources/cidade_remote_datasource.dart (_resolverProximaUrl)
Future<ImoveisEnvelopeModel> seguir(String proximaPagina) async {
  _exigirMesmaOrigem(proximaPagina);                 // lança FormatException se outra origem
  final r = await _dio.get<Object?>(proximaPagina);
  return ImoveisEnvelopeModel.fromJson(_comoMapa(r.data));
}
```
Extrair `_exigirMesmaOrigem` para um helper compartilhado em vez de duplicar entre datasources.

### Pattern 2: Repository captura `TypeError` do `fromJson`
O detalhe já faz (`on TypeError` → `FormatException`). **A lista não faz** (`ImovelRepositoryImpl` só tem `on Exception`): campo ausente na lista real lançaria `TypeError` (que é `Error`, não `Exception`) e travaria o Cubit no carregando. Replicar o `on TypeError` em `buscarImoveis`/`buscarProximaPagina`/opções.

### Pattern 3: Tradução booleanos → lista (loteamento) privada ao Model
```dart
// em dados_natureza_model.dart (data/), nunca em domain/
List<String> get _infraestrutura => [
  if (asfalto == true) 'Asfalto',
  if (agua == true) 'Água',
  if (energia == true) 'Energia',
  if (esgoto == true) 'Esgoto',
  if (iluminacao == true) 'Iluminação pública',
];
```

### Pattern 4 (API): CSV → `__in` com validação
```python
# Source: padrão _escolha/_numero de origin/WEB-09:Web/imoveis/api/views.py (estender)
def _escolhas(params, nome, opcoes):
    bruto = params.get(nome, "").strip()
    if not bruto:
        return []
    valores = [v.strip() for v in bruto.split(",") if v.strip()]
    invalidos = [v for v in valores if v not in opcoes]
    if invalidos:
        raise ValidationError({nome: f"Opções válidas: {', '.join(opcoes)}."})
    return valores
# natureza: queryset.filter(natureza__in=naturezas)
# bairro (case-insensitive, OU): reduce(or_, (Q(bairro_anuncio__iexact=b) for b in bairros))
```
`bairro_anuncio__in` seria **case-sensitive** — D-07 exige insensível; usar OR de `iexact`.

### Pattern 5 (API): `imoveis_da_vitrine()` com a regra única
```python
# Source: troca de 1 linha em origin/WEB-09:Web/imoveis/vitrine.py:35
return (
    Imovel.objects.na_vitrine()          # publicado ∧ DISPONIVEL ∧ empresa__ativa
    .annotate(...)                        # + When(natureza=LOTE, then=F("lote__area")) em area_anuncio
)
```
O queryset do detalhe passa a incluir `"lote__quadra__loteamento"` no `select_related`.

### Anti-Patterns to Avoid
- **Reaproveitar `LoteSerializer`/`LoteamentoResumoSerializer` da W08 no público:** carregam `id`/`cidade` internos e `vendido`. Escrever `LotePublicoSerializer` com `fields` explícito.
- **Ordenar/filtrar no app para "consertar" a capa ou os bairros:** viola FIL-05/regra do projeto — corrigir na API.
- **Fixture de teste escrita à mão:** foi assim que o drift de F1→W09 passou despercebido. Fixture = resposta capturada do seed.
- **`default:` nos `switch` exaustivos de natureza/estado:** mantém a checagem de exaustividade (padrão do repo).
- **Mudar `Cidade ==`/`hashCode` para incluir `id`:** quebra a chave natural usada em prefs/sessão (D-15 da F1). `id` deve ficar fora da igualdade.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Paginação do servidor | cursor/offset próprio | `PageNumberPagination` (já na W09) | `next/previous/count` prontos |
| Validação de params numéricos/enum | `if/else` solto | `_numero`/`_escolha` (+ `_escolhas`) já na view | 400 `{campo: msg}` padronizado |
| Visibilidade da vitrine | `filter(publicado=True)` repetido | `Imovel.objects.na_vitrine()` | Regra única (W08); evita lista/detalhe/cidades divergirem |
| Imagem de seed | PNG binário embutido | `PIL.Image.new(...).save(BytesIO, "JPEG")` + `SimpleUploadedFile` | Pillow já na venv; o `validar_imagem` precisa de imagem válida |
| JSON → objetos no app | `Map` à mão | freezed + json_serializable | Constraint do projeto |
| Origem do `next` | comparar strings | `Uri.parse` + scheme/host/port (já em `CidadeRemoteDataSource`) | Padrão defensivo existente |
| Teste HTTP de dio | pacote de mock | `HttpClientAdapter` falso do repo (`cidade_remote_datasource_test.dart`) | Sem dependência nova |

**Key insight:** o trabalho difícil é de **fronteira** (wire, nulls, enums como código, drift entre dois repos), não de algoritmo. Quase tudo que a fase precisa já tem padrão no repo.

## Runtime State Inventory

Fase de integração, não de rename — mas há um estado persistido afetado:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | `SharedPreferencesAsync` chave `cidade_selecionada` = `"nome|uf"` (sem id) [VERIFIED: `cidade_prefs_datasource.dart`] | Código: continua válido (chave natural); o `id` vem da lista atendida na revalidação (`ValidarCidadeAtendidaUseCase` devolve a entidade **da lista**). Sem migração de dados. Cuidado só no ramo "lista falhou" (Open Question 1) |
| Live service config | Banco Postgres local de dev: precisa `migrate` até a `0006` após o merge; seed precisa rodar | Passo explícito no plano (Wave 0 da API) |
| OS-registered state | None — verificado: nada registra a string/rota antiga | — |
| Secrets/env vars | `Web/.env` (não lido, protegido). `ALLOWED_HOSTS` deve incluir `10.0.2.2` para o emulador; o app usa `--dart-define=API_BASE_URL` | Documentar no README/plano; não commitar `.env` |
| Build artifacts | `lib/di/injection.config.dart` e `*.freezed.dart/*.g.dart` regenerados por `build_runner` | `dart run build_runner build -d` após remover mocks e mudar Models |

## Common Pitfalls

### Pitfall 1: `TypeError` do `fromJson` não é `Exception`
**What goes wrong:** com o JSON real faltando um campo `required` (`descricao`, `cidade`, `criado_em` na lista), `json_serializable` faz `as String` e lança `TypeError`; `on Exception` não captura ⇒ Cubit preso em loading.
**How to avoid:** tornar opcionais/remover os campos que a lista não manda **e** adicionar `on TypeError` nos três repositórios; teste com JSON capturado.
**Warning signs:** tela de vitrine eternamente "carregando" ao trocar para o remoto.

### Pitfall 2: `next` com host diferente do da base URL
**What goes wrong:** `next` é montado com `request.build_absolute_uri` (Host da requisição). Se o app chamar `http://10.0.2.2:8000` mas o servidor não aceitar esse host, a request falha por `DisallowedHost`; se um proxy reescrever o host, a defesa de mesma origem do app recusa o `next`.
**How to avoid:** `ALLOWED_HOSTS` inclui `10.0.2.2` (já no `.env.example` da feat/APP02); rodar `runserver 0.0.0.0:8000`; iOS Simulator usa `127.0.0.1`. [CITED: `README`/`modulo_rede.dart`]

### Pitfall 3: Busca sem acento
**What goes wrong:** `icontains` no Postgres é sensível a acento: "cambui" não acha "Cambuí". O mock antigo era acento-insensível (`normalizarTexto`); D-14 diz que vale a regra da web.
**How to avoid:** aceitar (D-14) **e registrar** como regressão conhecida; opção futura é `unaccent`. Teste do app não deve assumir acento-insensível.

### Pitfall 4: Bairro e vírgula
**What goes wrong:** D-07 usa CSV para `bairro`; um bairro com vírgula no nome ("Jd. Bela Vista, 2ª Gleba") quebra o split. Características já foram resolvidas por id (D-13), bairros não.
**How to avoid:** manter CSV (decisão travada) e registrar o risco; mitigação barata na API: aceitar também `getlist("bairro")` (parâmetro repetido) e fazer o app enviar repetido — **não decidido**, ver Open Question 5.

### Pitfall 5: `natureza` único → CSV quebra `_escolha`
**What goes wrong:** hoje `_escolha(params,"natureza",...)` rejeita `"CASA,LOTE"` com 400; sem trocar por `_escolhas` o filtro multi-natureza do app (já existente) falha.
**How to avoid:** implementar D-07 e testar `natureza=CASA,LOTE` e valor único.

### Pitfall 6: Capa não vem primeiro no detalhe
Ver seção "Fotos". O app "nunca reordena"; DET-02 exige capa primeiro.

### Pitfall 7: `posicao_solar`/`uso_permitido` aparecem em CAIXA ALTA
**What goes wrong:** F4/D-19b diz "mostrar como veio"; com a API real vira "NASCENTE", "RESIDENCIAL".
**How to avoid:** `rotuloPosicaoSolar`/`rotuloUsoPermitido` em `presentation/` (padrão `rotuloTopografia`), com fallback para o texto cru em código desconhecido (nunca derrubar) e `""` ⇒ omitir.

### Pitfall 8: Remover mocks quebra ~10 arquivos de teste
**What goes wrong:** 587 testes passam hoje [VERIFIED: `flutter test` → "All tests passed!" +587]. Dependem dos mocks/fixtures: `imovel_mock_datasource_test`, `imovel_detalhe_mock_datasource_test`, `opcoes_filtro_mock_datasource_test`, `contrato_detalhe_test`, `detalhe_imovel_model_test`, `imovel_detalhe_repository_impl_test`, `vitrine_fluxo_test`, `detalhe_navegacao_test`, `vitrine_screen_test` e outros (lista por `grep` de `imoveis_fixture|imoveis_detalhe_fixture|MockDataSource`). `imovel_mock_datasource_test` sozinho tem 1.500+ linhas que testam **lógica de filtro/ordenação do servidor simulado** — passam a ser testes de Django, não do app.
**How to avoid:** planejar a migração de testes como tarefa própria (fakes `mocktail` + JSON capturado); não apagar mocks antes de ter os fakes. Testes de fluxo de widget (`vitrine_fluxo_test`, `detalhe_navegacao_test`) precisam de um `FakeImovelDataSource` em `test/support/` que sirva o JSON capturado.

### Pitfall 9: `empresa_id` e contatos no payload do corretor
**What goes wrong:** `CorretorPublicoSerializer` devolve `empresa_id`, `email`, `telefone`, `whatsapp`, `creci`; o deny-list da W09 só proíbe `empresa`. É um vazamento *aceito* por D-16 (LGPD deferida), mas `empresa_id` é um id interno.
**How to avoid:** o app só declara `id`, `nome`, `foto` no Model (campos extras são ignorados). Registrar na seção de segurança; sugerir à frente web remover `empresa_id` (fora do escopo).

### Pitfall 10: Reservado/vendido some também do detalhe e das cidades
Com `na_vitrine`, imóvel `RESERVADO/VENDIDO/ALUGADO` → 404 no detalhe (app mostra "Este imóvel não está mais disponível" — coerente) e cidade cujos únicos imóveis estão reservados some da lista de cidades. Esperado (D-04); o teste de cidades da W09 deve ganhar caso de situação.

### Pitfall 11: Android release sem cleartext
HTTP puro só funciona em debug/profile (manifest de debug com `usesCleartextTraffic="true"`; main sem) e iOS só com `NSAllowsLocalNetworking`. Para aparelho físico com IP de rede local isso pode não bastar no iOS. [VERIFIED: `android/app/src/debug/AndroidManifest.xml`, `ios/Runner/Info.plist`] — não é bloqueio da fase (E2E em emulador/simulador), mas registrar.

## Code Examples

### Fake de DataSource com JSON capturado (padrão de teste do repo)
```dart
// Source: padrão HttpClientAdapter falso de test/data/cidade_remote_datasource_test.dart
final adaptador = _HttpClientAdapterFalso((uri) {
  if (uri.contains('/api/publico/cidades/1/imoveis/')) {
    return _RespostaFalsa(status: 200, corpo: jsonDecode(File('test/fixtures/api/lista_campinas_p1.json').readAsStringSync()));
  }
  return _RespostaFalsa(status: 404, corpo: {'detail': 'Não encontrado.'});
});
```

### Gatilho de erro que substitui os ids 338/339 do mock (D-18)
```dart
// 404 -> ImovelNaoEncontradoException (já tratado em ImovelDetalheRepositoryImpl)
when(() => ds.buscarDetalhe(339)).thenThrow(DioException(
  requestOptions: RequestOptions(path: ''),
  response: Response(requestOptions: RequestOptions(path: ''), statusCode: 404),
));
```

### Teste Django de allowlist exata (além do deny-list)
```python
# Source: padrão de VitrineSemTokenESemVazamentoTests (origin/WEB-09 tests.py l.1318+), estendido
def test_detalhe_de_lote_tem_exatamente_as_chaves_publicas(self):
    dados = self.client.get(reverse("publico-imovel", args=[self.lote.pk])).json()
    self.assertEqual(
        set(dados["lote"]),
        {"numero", "area", "frente", "fundo", "entrada_minima", "parcelas_maximas",
         "condicoes_parcelamento", "quadra"},
    )
    self.assertEqual(set(dados["lote"]["quadra"]), {"identificacao", "loteamento"})
```

### Captura de JSON real para fixtures/contrato (D-02)
```bash
# com seed aplicado e runserver ativo (Web/):  .venv/bin/python manage.py runserver 0.0.0.0:8000
curl -s "http://127.0.0.1:8000/api/publico/cidades/" > test/fixtures/api/cidades.json
curl -s "http://127.0.0.1:8000/api/publico/cidades/1/imoveis/" > test/fixtures/api/lista_p1.json
curl -s "http://127.0.0.1:8000/api/publico/imoveis/<id-de-cada-natureza>/" > test/fixtures/api/detalhe_<natureza>.json
```
(URLs de mídia no JSON terão `127.0.0.1:8000`; normalizar host nos testes ou capturar com o host que o app usará.)

## State of the Art

| Old Approach (contrato F1/F4) | Current Approach (API real) | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `GET /imoveis?cidade=nome-uf`, cursor | `GET /cidades/<id>/imoveis/`, page number | WEB-09 | Rota/params/envelope do app mudam |
| Mocks no app como fonte | DataSources `dio` + fixtures capturadas | Esta fase (D-18) | Testes migram |
| `lote.preco` + infra/lazer em listas | preço = `preco_venda`; infra = 5 booleanos; lazer = texto | W07 | Domínio do lote muda |
| `corretor{id,nome,foto,slug}` mínimo | `corretor_responsavel` completo (W02) | WEB-09 | App ignora o excedente |

**Deprecated/outdated:**
- `ImovelMockDataSource`/`ImovelDetalheMockDataSource`/`OpcoesFiltroMockDataSource` e as fixtures — removidos.
- `01-CONTRATO-API.md` §3–§11 como fonte da verdade — reescrito para o formato real (D-02).
- STATE.md "Blockers: Phase 5 externally blocked on Imóvel model" — resolvido.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `PageNumberPagination` emite `{count,next,previous,results}` e página inválida devolve 404 `{"detail": ...}` (comportamento padrão do DRF) | Desvio de wire | Baixo; confirmar na primeira captura real |
| A2 | `git merge-tree` sem conflito além dos 5 arquivos listados implica merge resolvível sem mudar semântica de migrations | Estado da API | Médio; confirmar rodando a suíte Django após o merge |
| A3 | A suíte Django (W08 + W09 + novos) roda verde no Postgres local; credenciais/estado do banco `imoveis_aqui` não foram verificados (`nc` indicou porta 5432 aberta; `lsof` não confirmou o processo) | Environment | Médio; Wave 0 deve rodar `manage.py test` antes de mexer |
| A4 | Corrigir a ordem das fotos na API (capa primeiro) é aceitável para a frente web | Fotos / Pitfall 6 | Médio; alternativa é partição estável no app |
| A5 | Busca acento-sensível é tolerável (D-14) | Pitfall 3 | Baixo/UX; usuário pode querer `unaccent` |
| A6 | `Imovel.cidade` pode sair da entidade de lista sem quebrar UI além da prévia do detalhe | Desvio de wire (lista) | Baixo; `rotuloLocalizacao` é o único consumidor lido |
| A7 | `iOS Simulator` + `127.0.0.1` e Android `10.0.2.2` funcionam com os `ALLOWED_HOSTS` do `.env.example` | Pitfall 2 | Baixo |

## Open Questions

1. **Como `Cidade` ganha `id` no app (e no ramo de falha de rede)?**
   - Sabemos: rota exige `cidades/<id>/...`; `CidadeModel.paraEntidade()` hoje descarta o id; prefs guardam só `nome|uf`; `ValidarCidadeAtendidaUseCase` devolve a cidade **da lista** (com id) quando a lista carrega, mas no ramo `Failure` entra com a cidade salva (sem id).
   - Falta: política quando não há id.
   - Recomendação: `Cidade` ganha `final int? id` **fora de `==`/`hashCode`** (chave natural continua a identidade); `CidadeModel.paraEntidade()` passa o id; `ImovelRemoteDataSource`/`OpcoesFiltroRemoteDataSource` lançam `FormatException` clara se `cidade.id == null` (cai em "Tentar de novo"; sem rede a vitrine falharia de qualquer jeito). Opcional: persistir `nome|uf|id` com leitura retrocompatível.

2. **Fotos: onde garantir "capa primeiro"?** (ver Pitfall 6) — Recomendação: na API (ordenar por `-capa, ordem, id` no detalhe) + teste.

3. **`areas_de_lazer` (texto livre) e infraestrutura (booleanos) no app.**
   - Recomendação: infraestrutura → lista de rótulos no Model (domínio inalterado); `areas_de_lazer` → `DadosLoteamento.areasLazer: String?` mostrado como linha de texto "Áreas de lazer" (chips com frase longa ficam ruins). Não dividir por vírgula no app (heurística de dado).

4. **Rótulos de `posicao_solar`/`uso_permitido`.** Recomendação: tabelas pequenas em `presentation/` (`NASCENTE`→"Nascente", ...) com fallback para o texto cru.

5. **Bairro com vírgula (CSV).** Recomendação: manter CSV (D-07 travado); opcionalmente a view lê também `getlist("bairro")`. Decidir antes do plano da API ou registrar como risco aceito.

6. **`vendido` e `empresa_id`.** Não incluir `vendido` no bloco `lote` público (sempre `false` na vitrine); sugerir à web remover `empresa_id` do corretor público (fora do escopo).

7. **REQUIREMENTS/ROADMAP descrevem a rota antiga** (`/api/publico/imoveis/?cidade=`). Recomendação: o plano inclui atualizar o texto de API-03 (e Success Criteria 1) para `cidades/<id>/imoveis/`, para a verificação da fase não reprovar por texto desatualizado.

8. **E2E manual:** não há emulador/simulador aberto (`flutter devices` = macOS desktop + Chrome; o projeto **não tem pasta `macos/`** e a API não tem CORS, logo web/desktop não servem). iOS 17.5 simulators e AVDs (`Medium_Phone_API_36.0`, `Pixel_API_24`) existem. O check humano de fim de fase deve usar um deles.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter / Dart | Todo o app | ✓ | Flutter 3.47.5 stable (2026-09-17) | — |
| `flutter test` baseline | Regressão | ✓ | 587 testes passando | — |
| Python (venv `Web/.venv`) | API + testes | ✓ | 3.13.18; Django 5.2.17, DRF 3.18.1, psycopg 3.3.5, Pillow 12.3.0 | — |
| PostgreSQL | API, testes, seed | ? | `nc localhost 5432` conectou; processo/credenciais não confirmados; container `imoveis-aqui-db` (postgres:16) existe **parado** | `docker start imoveis-aqui-db` (daemon Docker respondeu) |
| Docker | Postgres alternativo | ✓ | 29.7.2 (daemon ativo) | — |
| iOS Simulator / Android AVD | E2E manual | ✓ (não iniciados) | iPhone 15 etc. (iOS 17.5); `Medium_Phone_API_36.0` | — |
| Servidor Django rodando | Captura de JSON, E2E | ✗ | porta 8000 sem listener | `manage.py runserver 0.0.0.0:8000` |
| `timeout` (coreutils) | scripts | ✗ | — | não usar |

**Missing dependencies with no fallback:** nenhuma.
**Missing dependencies with fallback:** servidor Django (iniciar no plano); Postgres (verificar/`docker start`).

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework (app) | `flutter_test` + `bloc_test ^10.0.0` + `mocktail ^1.0.5` (+ `fake_async`) |
| Framework (API) | Django `TestCase`/DRF `APITestCase` (runner Django), Postgres |
| Config file | app: nenhum (`test/**_test.dart`); API: nenhum (`manage.py test`) |
| Quick run (app) | `flutter test <arquivos tocados>` |
| Full suite (app) | `flutter test && flutter analyze` (baseline: 587 verdes) |
| Quick run (API) | `cd ../imoveis-aqui/Web && .venv/bin/python manage.py test imoveis.tests.<Classe> -v 1` |
| Full suite (API) | `cd ../imoveis-aqui/Web && .venv/bin/python manage.py test` |
| Codegen | `dart run build_runner build -d` antes de testes que dependem de `*.freezed.dart`/`*.g.dart`/DI |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| API-03 | Lista só `na_vitrine` (publicado ∧ DISPONÍVEL ∧ ativa); reservado/rascunho/inativa/outra cidade não aparecem | Django integração | `manage.py test imoveis.tests.VitrineBuscaTests` | parcial (W09) — ❌ casos de situação (Wave 0) |
| API-03 | `natureza=LOTE`, `natureza=CASA,LOTE`, `bairro=A,B` (iexact, OU), valor único retrocompatível, valor inválido ⇒ 400 | Django | `manage.py test imoveis.tests.VitrineBuscaTests` | ❌ Wave 0 |
| API-03 | `area_anuncio` do lote = `lote.area`; filtro/ordenação por área inclui lote | Django | idem | ❌ Wave 0 |
| API-03 | Allowlist exata do item da lista e do detalhe (chaves == conjunto esperado), incl. `lote` | Django | `manage.py test imoveis.tests.VitrineSemTokenESemVazamentoTests` | parcial — ❌ igualdade exata (Wave 0) |
| API-03 | `bairros/` e `caracteristicas/`: sem token, só da vitrine/da cidade, ordenados, 404 em cidade inexistente | Django | `manage.py test imoveis.tests` (classe nova) | ❌ Wave 0 |
| API-03 | App monta URL `cidades/<id>/imoveis/` + params W09; `seguir(next)` rejeita outra origem | Flutter unit | `flutter test test/data/parametros_consulta_imoveis_test.dart test/data/imovel_remote_datasource_test.dart` | ❌ Wave 0 |
| API-03 | App parseia a lista **real capturada** (sem campos extras/ausentes quebrarem) e trata `TypeError` | Flutter unit | `flutter test test/data/imovel_model_test.dart test/data/imovel_repository_impl_test.dart` | parcial |
| API-03 | Vitrine ponta a ponta com DataSource fake servindo JSON capturado (busca, ordenar, filtrar, scroll infinito) | Flutter widget | `flutter test test/presentation/vitrine_fluxo_test.dart` | existe (reescrever) |
| API-07 | Detalhe: 404 igual p/ inexistente, rascunho, reservado, empresa inativa; bloco `lote`; `corretor_responsavel: null` com corretor inativo | Django | `manage.py test imoveis.tests.VitrineDetalheTests` | parcial — ❌ lote/situação |
| API-07 | App parseia o detalhe **real capturado** das 4 naturezas (endereco, fotos.imagem, caracteristicas{id,nome}, corretor_responsavel, lateral_*, ano_construcao, lote) | Flutter unit | `flutter test test/data/detalhe_imovel_model_test.dart` | existe (reescrever) |
| API-07 | 404/500 → `ImovelNaoEncontradoException`/`Failure` (substitui ids 338/339) | Flutter unit | `flutter test test/data/imovel_detalhe_repository_impl_test.dart` | existe (reapontar) |
| API-07 | DI registra só remotas (sem mock em `lib/`) | Flutter unit/greps | `flutter test test/di_registro_test.dart` ou `grep -r "Mock" lib/` = vazio | ❌ Wave 0 |
| API-03/07 | Contrato: `.example.json` regerados == fixtures capturadas; sem drift | Flutter unit | `flutter test test/data/contrato_detalhe_test.dart` (+ `contrato_lista_test.dart`) | existe (reescrever) / ❌ lista |
| API-03/07 | E2E real: visitante vê/busca/ordena/filtra e abre detalhe das 4 naturezas | Manual (simulador/AVD + seed) | `flutter run --dart-define=API_BASE_URL=...` | manual-only: exige dispositivo + servidor |

### Sampling Rate
- **Per task commit:** testes tocados (`flutter test <arquivos>` / `manage.py test imoveis.tests.<Classe>`).
- **Per wave merge:** `manage.py test` (API) e `flutter test && flutter analyze` (app).
- **Phase gate:** ambas as suítes verdes + checagem E2E humana contra o seed antes de `/gsd-verify-work`.

### Wave 0 Gaps
- [ ] Criar `feat/APP05` (API) a partir de `origin/WEB-09` e mergear `origin/feat/web-08`; **rodar `manage.py migrate` e `manage.py test` para baseline verde** antes de qualquer mudança (A2/A3).
- [ ] Testes Django novos: situação (`RESERVADO`…), `LOTE`, CSV, bairros, características, allowlist exata, seed idempotente (rodar 2× não duplica; recusa com `DEBUG=False`).
- [ ] `test/fixtures/api/*.json` capturados da API semeada (cidades, lista p1/p2, detalhe das 4 naturezas, bairros, características, 400 de validação) + `test/support/` com fakes (`HttpClientAdapter` falso e `FakeImovelDataSource`).
- [ ] Testes novos de DataSources remotas (lista, detalhe, opções) e de `parametros_consulta_imoveis` (só ida).
- [ ] Teste de contrato da lista (hoje só existe o do detalhe).
- [ ] Migração dos ~10 arquivos de teste que dependem de mocks **antes** de apagar os mocks.

## Security Domain

`security_enforcement` está habilitado (ASVS nível 1, `block_on: high`).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (endpoints públicos) | `authentication_classes = []` + `AllowAny` explícitos; token inválido não pode quebrar a consulta |
| V3 Session Management | no | app sem sessão |
| V4 Access Control | yes | Vitrine cross-empresa **só** de `na_vitrine()`; 404 idêntico para inexistente/não publicado/não disponível (sem enumeração); nenhum endpoint de escrita público (`405` testado) |
| V5 Input Validation | yes | Servidor: `_numero/_escolha/_escolhas` ⇒ 400; ids de característica `int()`. App: `id` de rota sempre inteiro; query params só via `queryParameters` do dio (sem concatenar texto do usuário na URL) |
| V6 Cryptography | no | HTTP puro só em dev (cleartext só em debug/localhost) |
| V12/V13 Files & API | yes | URLs de imagem do servidor tratadas como não confiáveis: `urlHttpOuNula` em `fotos[].imagem`, `foto_capa`, foto do corretor; `next` só de mesma origem |
| V14 Configuration | yes | Seed só com `DEBUG=True`; sem segredo no código; `.env` não lido nem commitado |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Vazamento de campo interno por serializer herdado (ex.: `VitrineImovelSerializer` da W08 expõe `codigo`/`empresa`) | Information Disclosure | Serializers públicos com `fields` explícitos + teste de igualdade exata de chaves; remover a viewset da W08 |
| `next` malicioso (SSRF/redirect para outro host) | Spoofing/Tampering | Validar scheme/host/port contra a base URL antes de `GET next` |
| Enumeração de rascunhos/reservados por diferença de resposta | Information Disclosure | Mesmo 404 (queryset `na_vitrine`) |
| Injeção via `busca`/`bairro` | Tampering | ORM parametrizado (`icontains`/`iexact`), nada de SQL cru |
| URL de imagem `javascript:`/`file:` | Tampering | `urlHttpOuNula` (já existe) |
| Exposição de contato do corretor (LGPD) / `empresa_id` | Information Disclosure | Aceito por D-16/deferido; app só declara `id,nome,foto`; registrar para a frente web |
| Seed rodando em produção | Tampering | `settings.DEBUG` guard (já existe) + teste |

## Sources

### Primary (HIGH confidence — lidos nesta sessão)
- `git show origin/WEB-09:Web/imoveis/api/{views,serializers,urls_publico}.py`, `Web/imoveis/vitrine.py`, `Web/localizacao/api/{views,urls_publico}.py`, `Web/config/{urls,settings}.py`, `Web/contas/api/serializers.py`, `Web/contas/models.py`, `Web/core/models.py`, `Web/localizacao/models.py`, `README.md` (seção "Vitrine pública"), `Web/imoveis/tests.py` (l.990-1400), `Web/core/management/commands/seed_demo.py`
- `git show origin/feat/web-08:Web/imoveis/models.py` (`ImovelQuerySet.na_vitrine`, `Imovel`, `Lote`, `Quadra`, `Loteamento`), `Web/imoveis/api/{serializers,views,urls,urls_publico}.py`
- `git merge-tree --write-tree origin/WEB-09 origin/feat/web-08` (conflitos), `git log/merge-base/--stat`
- App: `lib/data/**`, `lib/domain/**`, `lib/di/**`, `lib/presentation/{detalhe_imovel,vitrine}/**`, `pubspec.yaml`, manifests Android/iOS, `test/data/cidade_remote_datasource_test.dart`, baseline `flutter test` (587 passando)
- `.planning/phases/05-*/05-CONTEXT.md`, `01-CONTRATO-API.md` (§11), `04-RESEARCH.md`, `REQUIREMENTS.md`, `STATE.md`, `.claude/CLAUDE.md`

### Secondary (MEDIUM confidence)
- Comportamento padrão do DRF (`PageNumberPagination`, `COERCE_DECIMAL_TO_STRING`, 404 de página inválida) — conhecimento de treino, coerente com o uso nos testes da W09 [ASSUMED — A1]

### Tertiary (LOW confidence)
- Nenhuma fonte web consultada (pesquisa 100% sobre o código dos repositórios).

## Project Constraints (from CLAUDE.md)

- **Arquitetura:** Clean Architecture em `data/`/`domain/`/`presentation/`; widgets sem lógica de negócio nem rede. **Não negociável.**
- **Estado:** Cubit; estados freezed imutáveis. **Modelos de API:** freezed + json_serializable; nunca `dynamic` onde a tipagem couber.
- **Erros:** `Result`/sealed; sem `try/catch` genérico na UI.
- **Regra de negócio:** nada que "valha dinheiro" é decidido no app (nem ordenar capa por regra, nem derivar preço do lote).
- **UI:** Material 3 estrito; paleta Verde e Branco. **Idioma do código:** português.
- **Branches:** `feat/<card>` — app em `feat/APP05` a partir de `feat/APP04`; API em `feat/APP05` local.
- **GSD:** edições de arquivo só por fluxo GSD; **nunca commitar/pushar sem OK explícito** (memória do usuário e `../imoveis-aqui/CLAUDE.md`); explicar em PT antes de mexer em vários arquivos; API: toda consulta de acervo filtra pela empresa do usuário **exceto a vitrine pública** (sem usuário — mostra só `na_vitrine`).
- **API `CLAUDE.md`:** não editar `.gitignore` sem avisar; segredos só em `.env`.
- **Skill `flutter-frontend`:** `.claude/skills/flutter-frontend/` contém apenas o diretório `skill` (sem `SKILL.md` na raiz do skill); não foi usado como fonte.

## Plano sugerido (fatiamento MVP, vertical, API primeiro)

1. **API-A — Base:** `git checkout -b feat/APP05 origin/WEB-09` (com OK) → merge `origin/feat/web-08` → resolver 5 conflitos (W09 vence nas views públicas; manter testes das duas frentes, reapontando os da W08) → `migrate` → suíte verde. *(checkpoint humano: usuário autoriza criar branch/merge)*
2. **API-B — Regra e lote:** `imoveis_da_vitrine()` → `na_vitrine()`; `LOTE` nas anotações; `LotePublicoSerializer` + `SERIALIZER_PUBLICO_POR_NATUREZA`; `select_related` do detalhe; capa primeiro; testes (situação, lote, allowlist exata).
3. **API-C — Filtros e opções:** CSV `natureza`/`bairro`; `bairros/` e `caracteristicas/`; remover `VitrineImovelViewSet`; testes.
4. **API-D — Seed e captura:** estender `semear_vitrine_dev` (4 naturezas, fotos geradas por Pillow, idempotente, `DEBUG`); subir servidor; capturar JSON para `test/fixtures/api/`.
5. **APP-1 — Fatia "ver a lista real":** `Cidade.id`, cidades como array, `ImovelRemoteDataSource`, `ImovelModel`/envelope ajustados, params W09, `on TypeError`, DI da lista; cidades + lista funcionam ponta a ponta.
6. **APP-2 — Fatia "filtrar de verdade":** `Caracteristica{id,nome}` no domínio/filtros, `OpcoesFiltroRemoteDataSource`, CSV de ids.
7. **APP-3 — Fatia "abrir o detalhe real":** `ImovelDetalheRemoteDataSource`, `DetalheImovelModel` e blocos ajustados, domínio de lote/terreno/apartamento/prédio, rótulos de enums.
8. **APP-4 — Fechamento:** remover mocks e migrar testes (Pitfall 8), reescrever contrato + `.example.json` (D-02), atualizar texto de API-03/ROADMAP, README (como rodar contra a API), check humano E2E.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — sem pacotes novos; versões lidas dos manifests.
- Architecture / estado da API: HIGH — código das branches lido; MEDIUM no resultado do merge (não executado).
- Desvio de wire: HIGH — Models do app × serializers lidos lado a lado.
- Pitfalls: HIGH para os derivados de leitura de código; MEDIUM para UX (acento, capa).

**Research date:** 2026-10-30
**Valid until:** ~2026-11-13 (14 dias — as branches da web mudam rápido; revalidar `git log origin/WEB-09 origin/feat/web-08` antes de planejar)
