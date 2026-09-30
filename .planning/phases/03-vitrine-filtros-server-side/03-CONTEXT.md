# Phase 3: Vitrine — Filtros Server-Side - Context

**Gathered:** 2026-09-30
**Status:** Ready for planning

<domain>
## Phase Boundary

O visitante refina a vitrine da cidade escolhida com o conjunto completo de filtros de
APP03: finalidade, natureza, faixa de preço, quartos, suítes, vagas, bairro, faixa de
área e características. Os filtros são editados num bottom sheet, os ativos aparecem
como chips acima da lista, e qualquer mudança de filtro ou ordenação reinicia a
paginação. **Toda a filtragem é resolvida pela camada `data/`**: a
`ImovelMockDataSource` simula o servidor, honrando o contrato da Fase 1 mais os adendos
desta fase. O Cubit e os widgets nunca filtram o acervo.

Cobre: FIL-01..FIL-06.

Fora desta fase: endpoint real `GET /imoveis`, endpoints reais de opções (bairros,
características) e a troca da DataSource mock pela real ficam na Fase 4. Contagem
"Ver N imóveis" é v2 (API-05), já que a paginação por cursor não tem `count`.

Numeração: as decisões abaixo são D-01..D-24 **desta fase**. Referências a fases
anteriores usam prefixo: `F1/D-xx`, `F2/D-xx`.
</domain>

<decisions>
## Implementation Decisions

### Semântica dos filtros (regra do servidor, simulada pelo mock)
- **D-01:** Quartos, suítes e vagas significam **"N ou mais"**, com os params
  `quartos_min`, `suites_min` e `vagas_min` já presentes no contrato §5. Isso resolve,
  do lado do app, o item §7.1 do contrato e vira adendo para sign-off do E2.
  — **Reversibility:** costly — trocar para "exato" muda nomes de params no contrato,
  no mock, no mapeamento de params, nos rótulos dos chips ("2+") e nos testes.
- **D-02:** Finalidade é **inclusiva**. O filtro `finalidade=VENDA` traz `VENDA` e
  `VENDA_E_ALUGUEL`; `finalidade=ALUGUEL` traz `ALUGUEL` e `VENDA_E_ALUGUEL`. A UI só
  oferece Qualquer, Venda e Aluguel (FIL-01) e quem aplica a inclusão é o servidor/mock.
  Adendo ao contrato.
- **D-03:** `preco_min`/`preco_max` **dependem da finalidade**: com Venda comparam
  `preco_venda` e com Aluguel comparam `preco_aluguel`. **Sem finalidade escolhida, a
  faixa de preço fica desabilitada no modal**, para não misturar escalas (é o mesmo
  racional de F2/D-12). Com `finalidade=ALUGUEL`, a ordenação por preço passa a usar
  `preco_aluguel`, cumprindo o que F2/D-12 e o contrato §7.5 já previam. O mock
  implementa as duas regras. Adendo ao contrato.
- **D-04:** `caracteristicas` combina com **E**: o imóvel precisa ter todas as marcadas.
- **D-05:** `natureza` e `bairro` aceitam **multi-seleção com OU entre valores**
  (`natureza=CASA,APARTAMENTO` traz casa ou apartamento). Filtros diferentes combinam
  entre si com E. Adendo ao contrato: o §5 hoje trata os dois como singulares.
- **D-06:** Params multivalor (`natureza`, `bairro`, `caracteristicas`) usam **CSV numa
  única chave** (`?caracteristicas=Piscina,Quintal`). O mapeamento fica em
  `parametros_consulta_imoveis.dart`, isolado. Fica registrado um risco para o E2:
  vírgula dentro de um nome (bairro ou característica) exigiria escape ou identificador.
  — **Reversibility:** costly — mudar para params repetidos mexe no contrato, no
  mapeamento do app, no parser do mock e no filter backend do Django.

### Modal de filtros (FIL-01..FIL-04)
- **D-07:** O modal é um **bottom sheet em tela cheia** (`showModalBottomSheet` com
  `isScrollControlled` e `useSafeArea`), com seções roláveis e **rodapé fixo com
  "Limpar" e "Ver imóveis"** (aplicar). É da mesma família do sheet de Ordenar (F2/D-10).
- **D-08:** O sheet edita um **rascunho local e só aplica no botão**. Mexer nos
  controles não dispara consulta. "Ver imóveis" aplica tudo de uma vez (uma consulta) e
  fechar o sheet sem aplicar descarta o rascunho. O rascunho vive num
  Cubit/estado próprio do sheet, imutável, e não no `VitrineState` aplicado.
- **D-09:** Faixas de preço e de área usam **dois campos numéricos, mín e máx**, com
  teclado numérico e máscara ("R$", "m²", e "/mês" para aluguel). Não é `RangeSlider`,
  porque não há endpoint de estatísticas que dê os limites do acervo.
- **D-10:** Quartos, suítes e vagas usam **`ChoiceChip` de seleção única**, com as
  opções "Qualquer", "1+", "2+", "3+" e "4+".
- **D-11:** Finalidade usa **`SegmentedButton`** (Qualquer | Venda | Aluguel, seleção
  única). Natureza usa **`FilterChip` multi** (Casa, Apartamento, Terreno, Lote).
- **D-12:** Mín maior que máx, ou valor inválido, mostra **erro inline (`errorText`) e
  desabilita "Ver imóveis"** até corrigir. É validação de formulário, não regra de
  negócio; o servidor revalida e responde 400 (o mock simula com `FormatException`,
  seguindo o padrão de `ordenacaoDoParametro`).
- **D-13:** Trocar a finalidade no modal **limpa a faixa de preço** do rascunho e troca
  máscara e sufixo.
- **D-14:** Trocar de cidade **mantém os filtros gerais** (finalidade, natureza, faixas,
  quartos/suítes/vagas, características) e **limpa os bairros**, que pertencem à cidade
  anterior. Busca e ordenação seguem o comportamento atual da F2.

### Chips ativos (FIL-06)
- **D-15:** O botão **"Filtros" com contagem** ("Filtros (3)", usando `Badge` ou texto)
  fica **na mesma linha do botão "Ordenar"**, abaixo da `SearchBar` (espaço reservado
  em F2/D-10). Os chips ativos ficam numa **linha horizontal rolável logo abaixo**, que
  só aparece quando há filtro ativo.
- **D-16:** Os chips são **um por filtro, com texto resumido**, por exemplo "Venda",
  "Casa, Apto", "R$ 200 mil–500 mil", "2+ quartos", "Cambuí +1" e "Piscina +2". A
  contagem do botão Filtros é o número de filtros ativos, não de valores.
- **D-17:** O **"x" do chip remove aquele filtro e reconsulta na hora**, sem passar pelo
  "Ver imóveis", reiniciando a lista pelo mecanismo de F2/D-13. **Tocar no corpo do chip
  abre o sheet** com o rascunho inicializado a partir dos filtros aplicados.
- **D-18:** "Limpar filtros" existe em dois lugares: como **`ActionChip` no fim da linha
  de chips**, que aplica na hora, e como **"Limpar" no rodapé do sheet**, que zera só o
  rascunho (o visitante ainda precisa aplicar). Nenhum dos dois mexe na busca por texto
  nem na ordenação.
- **D-19:** Qualquer mudança de filtros aplicados (aplicar, remover chip, limpar) usa o
  **mesmo caminho de reinício da F2/D-13**: descarta o cursor, limpa os itens, mostra
  loading, volta o scroll ao topo e descarta respostas atrasadas por id de requisição.
  Resultado: zero cards duplicados ou embaralhados (critério 4).

### Fonte das opções e estados (FIL-04, FIL-05)
- **D-20:** As listas de opções de **bairros e características vêm de endpoints
  próprios**, adicionados ao contrato como adendo:
  `GET /api/publico/caracteristicas/` (a partir do model `Caracteristica`) e
  `GET /api/publico/bairros/?cidade=<nome-uf>` (bairros com imóvel publicado na cidade).
  **Nesta fase uma DataSource mock responde a partir da fixture**; os endpoints reais
  entram na Fase 4 junto com `/imoveis`. O app nunca mantém lista fixa de opções.
  — **Reversibility:** costly — são dois endpoints novos no contrato com o E2; mudar
  a forma depois mexe no contrato, no mock, nos models e no Django.
- **D-21:** O bairro é escolhido numa **lista de `CheckboxListTile`** dentro de uma
  seção expansível do sheet, com um **campo que filtra só a lista de opções visível**
  (nunca o acervo). É multi-seleção (D-05).
- **D-22:** Filtros sem resultado ganham um **estado próprio**: "Nenhum imóvel com esses
  filtros", com a ação "Limpar filtros". Ele é distinto de `vazioNaCidade` e de
  `semResultado` da busca (F2/D-09). Com busca **e** filtros ativos, a mensagem cita os
  dois e oferece limpar ambos.
- **D-23:** Os filtros **não são persistidos**: valem só durante a sessão, como a busca
  e a ordenação. Só a cidade é guardada (F1/D-15).
- **D-24:** A fixture/mock precisa de **variedade suficiente** para exercitar cada
  filtro de forma determinística: todas as naturezas e finalidades, faixas de
  preço e área, 0 a 4+ quartos, suítes e vagas, vários bairros por cidade e
  combinações de características, incluindo pelo menos uma combinação que zera o
  resultado (D-22). Nada aleatório (F2/D-15).

### Claude's Discretion
- Forma do filtro no domínio (ex.: `FiltrosVitrine` freezed dentro de
  `ConsultaImoveis`, com `toQueryParameters` no `data/`, conforme o CLAUDE.md) e como o
  rascunho do sheet é modelado (Cubit próprio ou estado local imutável).
- Formato exato dos valores de faixa enviados (inteiro em reais ou decimal string) e
  como a máscara converte, desde que a conversão fique fora do widget.
- Loading e erro ao carregar as opções de bairros e características dentro do sheet
  (spinner na seção e retry), e se as opções são carregadas ao abrir o sheet ou
  pré-carregadas com a cidade.
- Layout fino do sheet (ordem das seções, seções expansíveis), rótulos exatos dos
  chips e abreviações ("Apto", "mil"), seguindo Material 3, a paleta verde/branco e o
  01-UI-SPEC.
- Nomes e forma dos endpoints de opções no adendo (paginação ou não, formato
  `{id, nome}` versus string), desde que registrados no contrato §9 (ou numa nova §10)
  para o E2.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Contrato da API (base de toda a camada de dados)
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` —
  §3 (campos, incluindo a tipologia PENDENTE E2), §4 (cursor), §5 (params de filtro),
  §7.1 (quartos min/exato, resolvido por D-01), §7.5 (preço-base e nulls last, com
  `preco_aluguel` quando `finalidade=ALUGUEL`) e §9 (adendos da F2). **Esta fase registra
  novos adendos**: D-01, D-02, D-03, D-04, D-05, D-06 e D-20 (endpoints de opções).
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imoveis.example.json`
  — forma de cada linha da fixture.

### Decisões anteriores
- `.planning/phases/02-vitrine-lista-busca-e-ordena-o/02-CONTEXT.md` — F2/D-09 (vazios
  distintos), F2/D-10 (espaço reservado para Filtros), F2/D-12 (preço-base da
  ordenação), F2/D-13 (reinício da lista e descarte de respostas atrasadas),
  F2/D-14/D-15 (mock como servidor simulado, determinístico).
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTEXT.md` —
  F1/D-01 (cursor), F1/D-04 (PT snake_case), F1/D-15 (chave natural nome+uf).
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-UI-SPEC.md` —
  contrato visual (tema, tipografia, espaçamentos).
- `.planning/phases/02-vitrine-lista-busca-e-ordena-o/02-UAT.md` — itens de verificação
  humana ainda pendentes da F2, incluindo a posição do botão Ordenar (D-10), que afeta
  onde o botão Filtros entra.

### Projeto / requisitos
- `.planning/PROJECT.md` — constraints não negociáveis (Clean Architecture, Cubit,
  Freezed, Result selado, Material 3, paleta verde/branco, código em PT, nada decidido
  no app).
- `.planning/REQUIREMENTS.md` — FIL-01..FIL-06.
- `.planning/ROADMAP.md` §Phase 3 — goal e success criteria.
- `.claude/CLAUDE.md` — stack e o padrão `FiltrosVitrine` freezed com
  `toQueryParameters()` mantido dentro de `data/`.

### API irmã (referência para os adendos, sem código nesta fase)
- `../imoveis-aqui/Web/imoveis/models.py` — `Imovel`, `Caracteristica` (base do
  endpoint de características, D-20).
- `../imoveis-aqui/Web/core/models.py` — `Endereco.bairro` (base do endpoint de
  bairros, D-20).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/domain/entities/consulta_imoveis.dart`: `ConsultaImoveis(cidade, busca,
  ordenacao)` é a única entrada que atravessa UseCase → Repository → DataSource. Ganha
  os filtros aqui.
- `lib/data/datasources/parametros_consulta_imoveis.dart`:
  `parametrosDaConsulta` e os parsers inversos (`cidadeDoParametro`,
  `ordenacaoDoParametro` com `FormatException`). É onde entram os novos params, o CSV
  (D-06) e o parsing simétrico no mock.
- `lib/data/datasources/imovel_mock_datasource.dart`: servidor simulado que filtra e
  ordena sobre mapas de wire e só então parseia via `ImoveisEnvelopeModel.fromJson`.
  Ganha os filtros (D-01..D-05) e a ordenação por `preco_aluguel` (D-03).
- `lib/data/mocks/imoveis_fixture.dart`: fixture de ~40 imóveis por cidade, já com
  `natureza`, `bairro` e `caracteristicas`. Precisa de variedade (D-24) e é a fonte do
  mock de opções (D-20).
- `lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart`: padrão de bottom sheet
  a seguir no sheet de filtros.
- `lib/core/texto_normalizado.dart`: normalização de texto, útil para o filtro local da
  lista de opções de bairro (D-21) e para comparar bairros no mock.
- `lib/core/result.dart`: `Result<T>` selado para as novas chamadas de opções.

### Established Patterns
- `VitrineState` com `ordenacao`/`termoBusca` persistindo através de `conteudo`
  (união selada freezed). Os filtros aplicados entram como mais um campo do estado, e
  o novo vazio "sem resultado com filtros" (D-22) entra como variante de
  `ConteudoVitrine`.
- Reinício da lista com id de requisição e `jumpTo(0)` explícito num
  `BlocConsumer.listener` (F2-05: `keepScrollOffset:false` não basta). Filtros reusam
  esse mesmo caminho (D-19).
- DI com `injectable` + `get_it`. Nova DataSource/Repository de opções anotada, com mock
  trocável por DI (padrão API-04), e `build_runner` depois.
- Testes com `bloc_test` + `mocktail` em `test/presentation`, `test/domain` e
  `test/data`; o mock tem testes próprios de filtragem e ordenação.

### Integration Points
- `lib/presentation/vitrine/vitrine_screen.dart`: linha de controles abaixo da
  `SearchBar` (botão Filtros ao lado de Ordenar, D-15) e a nova linha de chips.
- `lib/presentation/vitrine/vitrine_cubit.dart`: novos métodos para aplicar filtros,
  remover um filtro, limpar e reagir à troca de cidade (D-14), todos passando pelo
  reinício de D-19.
- `lib/domain/repositories/imovel_repository.dart` + um novo repositório/usecase de
  opções (bairros por cidade, características).

</code_context>

<specifics>
## Specific Ideas

- O usuário escolheu a opção recomendada em todas as perguntas. Isso mantém o padrão das
  fases anteriores: caminho convencional de marketplace (ZAP/QuintoAndar), uma única
  fonte da verdade (opções vindas do "servidor", nunca listas fixas no app) e
  comportamento determinístico.
- Os chips são como os de apps de imóveis: resumidos ("Cambuí +1", "2+ quartos"), o "x"
  tem efeito imediato e o toque reabre o sheet para editar.
- Esta fase gera um lote novo de adendos ao contrato para o E2 (semântica min,
  finalidade inclusiva, preço por finalidade, E/OU, multivalor CSV e os dois endpoints
  de opções), no mesmo processo de sign-off da §8.

</specifics>

<deferred>
## Deferred Ideas

- Prévia "Ver N imóveis" no botão aplicar: v2 (API-05), depende de contagem barata.
- Endpoints reais `/api/publico/caracteristicas/` e `/api/publico/bairros/`: Fase 4,
  junto com `/imoveis`.
- Persistir os filtros entre aberturas: descartado (D-23); reavaliar se virar pedido
  de usuário.
- `RangeSlider` para preço e área: descartado por falta de limites vindos do servidor;
  reavaliar se surgir um endpoint de estatísticas.

</deferred>

---

*Phase: 3-Vitrine — Filtros Server-Side*
*Context gathered: 2026-09-30*
