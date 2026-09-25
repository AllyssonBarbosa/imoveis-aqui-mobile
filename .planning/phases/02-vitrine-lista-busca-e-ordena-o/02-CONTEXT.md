# Phase 2: Vitrine — Lista, Busca e Ordenação - Context

**Gathered:** 2026-09-25
**Status:** Ready for planning

<domain>
## Phase Boundary

O visitante navega a vitrine da cidade escolhida: lista paginada com scroll infinito,
busca por texto e ordenação, tudo resolvido na camada de dados (nunca no widget/Cubit).
A lista de cidades passa a vir do endpoint público real `GET /api/publico/cidades/`,
criado nesta fase no repo irmão `../imoveis-aqui/Web` (API-02), substituindo o asset fixo
da Fase 1. O acervo de imóveis é servido por uma DataSource mock que simula o servidor,
honrando o contrato da Fase 1, e é trocável pela real por DI (API-04).

Cobre: VIT-01..VIT-06, API-02, API-04.

Fora desta fase: filtros (finalidade, natureza, faixas, bairro, características, chips
ativos) ficam na Fase 3. O endpoint real `GET /imoveis` e a troca da DataSource ficam
na Fase 4. Detalhe do imóvel é v2 (DET-01).

Numeração: as decisões abaixo são D-01..D-17 **desta fase**. Referências à Fase 1 usam
o prefixo `F1/` (ex.: F1/D-15).
</domain>

<decisions>
## Implementation Decisions

### Card e layout da lista (VIT-01, VIT-02)
- **D-01:** Layout = **lista vertical**, um card por linha, com foto de capa larga em cima
  e as informações embaixo (título, preço, natureza, bairro, quartos). `Card` do
  Material 3.
- **D-02:** Quando `finalidade == VENDA_E_ALUGUEL`, o card mostra **os dois preços
  empilhados** ("Venda R$ 450.000" / "Aluguel R$ 2.500/mês"). Resolve o item §7.3 do
  contrato (decisão de UI da Fase 2). Para `VENDA` mostra só o de venda e para `ALUGUEL`
  só o de aluguel (com "/mês").
- **D-03:** Formato de preço = **moeda BRL completa, sem centavos quando forem zero**
  ("R$ 450.000"), aluguel com sufixo "/mês", via `intl` em `pt_BR`. É só apresentação de
  um valor que já vem pronto do servidor (string decimal), não regra de negócio. A
  conversão string→número/format fica fora do widget (model/presenter).
- **D-04:** `foto_capa` null ou imagem que falha ao carregar → **placeholder verde claro
  com ícone de casa, na mesma proporção da foto**, para que todos os cards tenham a mesma
  altura (VIT-02: formato consistente). Carregamento com `cached_network_image`
  (placeholder/errorWidget), conforme a stack do CLAUDE.md.

### Busca por texto (VIT-03)
- **D-05:** Nome do param de busca em `GET /imoveis` = **`busca`**
  (`?busca=cambuí`), em português snake_case e coerente com F1/D-04. No Django:
  `SearchFilter` com `search_param = "busca"`. **É um adendo ao contrato**: registrar no
  `01-CONTRATO-API.md` (§5) como item novo para o E2 aprovar.
- **D-06:** O servidor busca em **título + bairro** (`titulo`, `endereco__bairro`),
  case/acento-insensível no que o backend permitir. Descrição fica de fora para evitar
  ruído. O mock replica exatamente essa semântica.
- **D-07:** Barra de busca = **`SearchBar` do Material 3 fixa logo abaixo do seletor de
  cidade no topo**. A lista atualiza no lugar, sem trocar de tela.
- **D-08:** **Debounce de 400 ms** e disparo **a partir de 2 caracteres**. Apagar tudo
  (campo vazio) volta imediatamente à lista completa, sem esperar o debounce. Com 1
  caractere, nada é disparado e a lista atual continua. O debounce vive no Cubit
  (`Timer` próprio, sem `easy_debounce`, conforme o CLAUDE.md).
- **D-09:** Estado "nenhum resultado" para busca é **distinto** do estado "cidade sem
  imóveis": o primeiro menciona o termo buscado e oferece limpar a busca.

### Ordenação (VIT-04)
- **D-10:** Controle = **botão "Ordenar: <opção atual>" ao lado da busca**, que abre um
  **bottom sheet** com as opções em `RadioListTile`. O espaço ao lado fica reservado para
  o botão de filtros da Fase 3.
- **D-11:** Opções = **`mais_recentes` (padrão), `preco_asc`, `preco_desc`, `area_asc`,
  `area_desc`**, adotando a proposta da §7.4 do contrato como valores de trabalho (ainda
  sujeitos ao aval do E2; os rótulos em PT ficam na UI e os valores no enum do domínio).
  `mais_recentes` equivale ao ordering `-criado_em` do cursor.
- **D-12:** Ordenar por preço usa **`preco_venda`; imóveis sem preço de venda (só
  aluguel) vão para o fim (nulls last)**, sem misturar escalas de venda e aluguel. Na
  Fase 3, com filtro `finalidade=ALUGUEL`, a ordenação por preço passa a usar
  `preco_aluguel`. Regra do **servidor** (e do mock que o simula), nunca do app. Registrar
  como adendo ao contrato para o E2. `area_*` com `area` null também usa nulls last.
- **D-13:** Trocar ordenação ou texto de busca **reinicia a lista do topo**: descarta o
  cursor, limpa os itens, mostra loading e volta o scroll ao início. Respostas atrasadas
  de uma consulta anterior são **descartadas** (ex.: token/id de requisição no estado do
  Cubit), garantindo zero cards duplicados/embaralhados (critério 4 da fase).
  Paginação: próxima página só com o `next` do envelope cursor; `next == null` gera o
  estado fim-da-lista.

### Mock de imóveis e cidades via API (VIT-05, VIT-06, API-02, API-04)
- **D-14:** A DataSource mock de imóveis é um **servidor simulado**: fixture com cerca de
  40 imóveis por cidade atendida (forma exata de `contrato/imoveis.example.json`,
  incluindo os campos PENDENTE E2), aplicando `cidade` + `busca` + `ordenacao` + `cursor`
  e devolvendo o envelope `{next, previous, results}` com **latência de ~500 ms**. É a
  camada `data/` simulando o Django, e sai inteira na Fase 4 (troca por DI). Não conta
  como "filtrar no aparelho": UI/Cubit/domain nunca veem o acervo inteiro.
- **D-15:** Estados de erro/vazio são provocados por **gatilhos determinísticos** no mock:
  a busca "erro" faz a chamada falhar (exercita erro/retry) e pelo menos uma cidade
  atendida fica **sem imóveis** na fixture (exercita o vazio). Nada aleatório.
- **D-16:** Se `GET /api/publico/cidades/` falhar, o app mostra **erro com "Tentar de
  novo"**, reusando o estado `erroCarregarCidades` que já existe. O **asset
  `assets/cidades.json` e a `CidadeLocalDataSource` são removidos**, ficando uma única fonte
  da verdade. Quem já tem cidade salva entra direto na vitrine (F1/D-08) sem depender da
  lista.
  — **Reversibility:** reversible — o asset e a DataSource local estão no git e podem
  voltar como fallback se precisar.
- **D-17:** Base URL da API via **`--dart-define=API_BASE_URL=...`**, com padrão
  `http://10.0.2.2:8000` (emulador Android → localhost do Mac). Aparelho físico/iOS passa
  o IP da rede local. Documentar no README.

### Claude's Discretion
- Navegação seleção de cidade → vitrine: a vitrine substitui o `_CorpoCidadeEntrada`
  placeholder (estado `AutorizadaEAtendida`); a estrutura exata de rotas/telas fica com o
  planner.
- Indicador de loading (skeleton de cards ou spinner), tamanho de página do cursor e
  layout visual fino do card (seguir Material 3 + paleta verde/branco + UI-SPEC se a
  fase gerar um).
- Como alternar mock/real no DI (ex.: `@Environment` do injectable ou registro
  condicional), desde que seja uma troca de uma linha na Fase 4.
- Implementação do endpoint Django de cidades (view `AllowAny` + `CidadeSerializer`
  reaproveitado + `CursorPagination` ordering `["nome", "uf"]`, queryset
  `Cidade.objects.filter(empresas_atuantes__ativa=True).distinct()` conforme contrato §2.3),
  testes do DRF e se o app percorre todas as páginas de `/cidades` (provável: sim, o
  conjunto é pequeno).
- Representação do param `cidade` no mock: segue a recomendação provisória do contrato
  §7.2 (chave natural nome+uf), isolado na DataSource para trocar fácil se o E2 decidir
  por id.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Contrato da API (base de toda a camada de dados)
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` —
  campos de `/cidades` e `/imoveis`, envelope cursor (§4), params (§5), allowlist (§6), e
  itens pendentes do E2 (§7). Esta fase adiciona os adendos D-05 (`busca`), D-11
  (valores de `ordenacao`) e D-12 (preço-base da ordenação), que devem ser registrados nele.
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imoveis.example.json`
  — forma exata das linhas da fixture do mock (D-14).
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/cidades.example.json`
  — forma de `GET /cidades`.

### Decisões e UI da Fase 1
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTEXT.md` —
  F1/D-01 (cursor), F1/D-04 (PT snake_case), F1/D-08 (entra direto com cidade salva),
  F1/D-14 (repositório trocável por DI), F1/D-15 (chave natural nome+uf).
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-UI-SPEC.md` —
  contrato visual já estabelecido (tema, tipografia, espaçamentos) que a vitrine deve seguir.

### Projeto / requisitos
- `.planning/PROJECT.md` — constraints não negociáveis (Clean Architecture, Cubit,
  Freezed, Result selado, Material 3, paleta verde/branco, código em PT).
- `.planning/REQUIREMENTS.md` — VIT-01..06, API-02, API-04.
- `.planning/ROADMAP.md` §Phase 2 — goal e success criteria.
- `.claude/CLAUDE.md` — stack com versões (`dio`, `cached_network_image`, `injectable`,
  paginação com `ScrollController` + Cubit em vez de `infinite_scroll_pagination`,
  debounce com `Timer` próprio).

### API irmã (endpoint real de cidades, API-02)
- `../imoveis-aqui/Web/localizacao/models.py` — `Cidade(nome, uf)`.
- `../imoveis-aqui/Web/empresas/models.py` — `Empresa.cidades_atuacao`
  (`related_name="empresas_atuantes"`), base da regra "atendidas".
- `../imoveis-aqui/Web/empresas/api/serializers.py` — `CidadeSerializer` reaproveitável.
- `../imoveis-aqui/Web/empresas/api/views.py` — `EmpresaPublicaAPIView` (precedente
  `AllowAny`).
- `../imoveis-aqui/Web/config/urls.py` — `api/publico/` já roteado para `contas` e
  `empresas`; falta `cidades/`.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/core/result.dart`: `Result<T>` selado (`loading`/`success`/`failure`), usado para
  toda chamada falível do repositório de imóveis e de cidades.
- `lib/data/models/cidade_model.dart` + `lib/domain/entities/cidade.dart`: o `fromJson`
  já é o definitivo (F1/D-13) e serve direto para a resposta real de `/cidades`.
- `lib/data/repositories/cidade_repository_impl.dart` (`@LazySingleton(as:
  CidadeRepository)`): ponto onde a DataSource local é trocada pela remota (`dio`).
- `lib/presentation/cidade_selecao/widgets/seletor_cidade_topo.dart`: seletor de cidade
  do topo, que fica acima da `SearchBar` da vitrine (D-07).
- `lib/presentation/cidade_selecao/cidade_selecao_state.dart`: estado
  `erroCarregarCidades` reaproveitado para a falha de `GET /cidades` (D-16).
- `lib/app_theme.dart`: tema M3 verde/branco (`ColorScheme.fromSeed`).

### Established Patterns
- Estados de tela como unions `freezed` seladas, com `switch` exaustivo na UI (ver
  `cidade_selecao_screen.dart`). O estado da vitrine segue o mesmo padrão
  (carregando / sucesso com itens + cursor + fim / vazio / sem resultado / erro).
- DI com `injectable` + `get_it` (`lib/di/injection.dart`); rodar `build_runner` após
  novas anotações.
- Testes: `bloc_test` + `mocktail` em `test/presentation`, `test/domain`, `test/data`.

### Integration Points
- `lib/presentation/cidade_selecao/cidade_selecao_screen.dart`: o estado
  `AutorizadaEAtendida` hoje renderiza `_CorpoCidadeEntrada` (placeholder), que é onde a
  vitrine entra.
- `lib/data/datasources/cidade_local_datasource.dart` + `assets/cidades.json` +
  `test/data/cidade_local_datasource_test.dart`: removidos/substituídos pela DataSource
  remota (D-16).
- `pubspec.yaml`: faltam `cached_network_image` e `intl`.
- Repo irmão `../imoveis-aqui/Web`: novo endpoint `api/publico/cidades/` (branch no
  padrão `feat/<card>`, ex. `feat/APP02`).

</code_context>

<specifics>
## Specific Ideas

- O usuário escolheu a opção recomendada em todas as perguntas: prefere o caminho
  convencional e previsível, com uma única fonte da verdade e comportamento
  determinístico (mock sem aleatoriedade, sem fallback que diverge da API).
- A vitrine deve deixar espaço no topo (ao lado de "Ordenar") para o botão de filtros e
  os chips da Fase 3, sem precisar redesenhar.
- Três adendos ao contrato surgem desta fase e precisam de sign-off do E2 junto com os
  itens já pendentes da §7: param `busca`, valores de `ordenacao`, e a regra de preço-base
  com nulls last.

</specifics>

<deferred>
## Deferred Ideas

- Filtros, chips ativos e ordenação por `preco_aluguel` quando `finalidade=ALUGUEL`:
  Fase 3.
- Endpoint real `GET /imoveis` e troca da DataSource mock pela real: Fase 4.
- Cache offline da lista de cidades (última resposta boa em `shared_preferences`):
  descartado agora (D-16); reavaliar se o uso offline virar requisito.
- Busca também na descrição: descartada por ruído (D-06); reavaliar com dados reais.

</deferred>

---

*Phase: 2-Vitrine — Lista, Busca e Ordenação*
*Context gathered: 2026-09-25*
