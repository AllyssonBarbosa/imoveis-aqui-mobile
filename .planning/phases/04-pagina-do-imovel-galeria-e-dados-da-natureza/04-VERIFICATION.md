---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
verified: 2026-10-12T00:00:00Z
status: human_needed
score: 6/6 must-haves verified
covered_files:
  - ".planning/REQUIREMENTS.md"
  - "lib/data/datasources/imovel_detalhe_mock_datasource.dart"
  - "lib/data/mocks/imoveis_detalhe_fixture.dart"
  - "lib/data/models/dados_natureza_model.dart"
  - "lib/data/models/detalhe_imovel_model.dart"
  - "lib/data/repositories/imovel_detalhe_repository_impl.dart"
  - "lib/domain/entities/dados_natureza.dart"
  - "lib/domain/entities/detalhe_imovel.dart"
  - "lib/presentation/detalhe_imovel/apresentacao_natureza.dart"
  - "lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart"
  - "lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart"
  - "lib/presentation/detalhe_imovel/perfil_corretor_screen.dart"
  - "lib/presentation/detalhe_imovel/widgets/cards_natureza.dart"
  - "lib/presentation/detalhe_imovel/widgets/cartao_corretor.dart"
  - "lib/presentation/detalhe_imovel/widgets/galeria_imovel.dart"
  - "lib/presentation/detalhe_imovel/widgets/secao_natureza.dart"
  - "lib/presentation/detalhe_imovel/widgets/visualizador_fotos.dart"
covered_digest: "v1:sha256:30bd396609bf9b462787f38abf6ebff541031663111fb943124a7d98dee72bf8"
behavior_unverified: 0
overrides_applied: 0
re_verification: false
human_verification:
  - test: "Em aparelho real, abrir um imóvel com 3+ fotos, tocar na galeria, dar pinch-zoom e arrastar/dar swipe no visualizador em tela cheia."
    expected: "Sem zoom o swipe troca de foto; ampliada, o arrasto move a imagem (não troca de foto); ao voltar a 1x o swipe volta. Zoom até 4x."
    why_human: "A arbitragem de gestos zoom x swipe foi provada nos testes só pela physics do PageView (PageScrollPhysics vs NeverScrollableScrollPhysics), não por gestos de dois dedos reais."
  - test: "Abrir um imóvel e rolar a página sobre fotos claras e escuras (SliverAppBar fixo)."
    expected: "O botão voltar continua visível e legível (contraste do IconButton.filled translúcido) em qualquer foto, também com a barra colapsada."
    why_human: "Legibilidade visual sobre imagem arbitrária não é verificável por teste."
  - test: "Abrir uma casa, um terreno, um apartamento e um lote; olhar a seção 'Sobre ...'."
    expected: "Ícones, rótulos e ordem da linha de destaques e da ficha fazem sentido e estão legíveis; cards 'Prédio' e 'Quadra e loteamento' aparecem só para apartamento/lote."
    why_human: "Adequação visual/usabilidade de ícones e rótulos (human_judgment declarado no SUMMARY do plano 06)."
  - test: "No Vinhedo ordenado por 'Mais recentes', abrir o último card (id 339) e o penúltimo (id 338)."
    expected: "339 mostra 'Este imóvel não está mais disponível' com 'Voltar à vitrine' (sem 'Tentar de novo'); 338 mostra 'Não foi possível carregar este imóvel.' com 'Tentar de novo' que repete a busca."
    why_human: "Adequação visual e do texto dos cartões de erro/404 em dispositivo (comportamento já coberto por teste de widget)."
  - test: "(Advisório, 04-REVIEW WR-01) Rodar o app em Windows/macOS e tentar paginar a galeria com o mouse."
    expected: "Decisão do dono: o PageView não aceita arrasto de mouse por padrão; sem botões/atalhos o usuário de desktop não alcança as fotos 2..N."
    why_human: "CLAUDE.md lista Windows/macOS como plataformas-alvo; é decisão de produto se isso entra nesta fase ou numa posterior."
---

# Phase 4: Página do Imóvel — Galeria e Dados da Natureza — Verification Report

**Phase Goal:** O visitante abre um imóvel a partir da vitrine e vê tudo sobre ele para decidir se vale falar com o corretor; o que aparece abaixo da galeria depende da natureza do imóvel (card APP 04 / A04).
**Verified:** 2026-10-12
**Status:** human_needed (nenhuma lacuna; só itens de verificação humana)
**Re-verification:** Não — verificação inicial

Verificado contra o código, não contra os SUMMARYs. Além do `flutter analyze` (limpo) e dos 587 testes do orquestrador, rodei os 12 arquivos de teste da fase (contrato, modelos, repositório, mock, tela, navegação, galeria, visualizador, natureza, cartão do corretor, perfil, cubit): 190 testes, todos passando.

## Goal Achievement

### Observable Truths (ROADMAP Success Criteria = contrato)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Galeria mostra todas as fotos, começando pela capa | VERIFIED | `galeria_imovel.dart`: `PageView.builder(itemCount: urls.length)` + contador "N/M"; `detalhe_imovel_screen.dart` passa `[for foto in detalhe.fotos] foto.url` sem reordenar. `DetalheImovelModel.paraEntidade` filtra por `urlHttpOuNula` preservando a ordem. Fixture (`_fotosGeradas`) e id 42 trazem a capa em `ordem 0`. Sem fotos: `ImagemPadraoImovel`, sem contador. Testes `galeria_imovel_test`, `detalhe_imovel_screen_test` (3 fotos -> "1/3"). |
| 2 | Casa: terreno, construída, livre; terreno: frente, fundo, topografia | VERIFIED | `linhasDe(DadosCasa)` -> "Área do terreno/construída/livre" via `formatarAreaM2` (só formata). `destaquesDe(DadosTerreno)` -> área/frente/fundo e `linhasDe(DadosTerreno)` -> "Topografia" (`rotuloTopografia` em PT). Imóvel 57 serve `area_livre: 100.00` (terreno 300, construída 180); teste afirma "100 m²" e `findsNothing` para "120 m²". Nenhum cálculo de área em `lib/presentation` ou `lib/domain` (grep). |
| 3 | Apartamento: dados do prédio; lote: quadra e loteamento | VERIFIED | `secao_natureza.dart` switch exaustivo (sem `default`) -> `CardPredio` (`linhasDoPredio`) / `CardQuadraLoteamento` (quadra, loteamento, incorporadora + Chips de infraestrutura e áreas de lazer). Lote 103 e apto 42 cobertos em teste de tela. Card/seção vazios somem (D-14). |
| 4 | Valores de venda ou aluguel, condomínio e IPTU | VERIFIED | `_Cabecalho` alimentado por `linhasDePrecoPorFinalidade` + `linhasDeCustos` ("Condomínio R$ X/mês", "IPTU R$ Y" sem período — PENDENTE E2 c). Strings decimais só formatadas (`formatarPrecoBrl`), nunca somadas. Testes: VENDA_E_ALUGUEL, nulos omitem linha, IPTU sem "/mês" nem "/ano". |
| 5 | Corretor responsável com foto e caminho para o perfil | VERIFIED | `CartaoCorretor` (`AvatarCorretor` com foto/placeholder + nome, tocável) -> `abrirPerfilCorretor` -> `PerfilCorretorScreen` (nome + foto do objeto em memória, sem rede, sem contato). Seção some sem corretor. Testes `cartao_corretor_test`, `perfil_corretor_screen_test` ("não mostra nenhum dado de contato"), fluxo de navegação. Perfil completo é do APP 07 por escopo. |
| 6 | Tudo vem do detalhe da API (contrato), sem dado montado no app; DataSource mock honrando o contrato | VERIFIED | Cadeia: `DetalheImovelScreen` -> `DetalheImovelCubit` -> `ObterDetalheImovelUseCase` -> `ImovelDetalheRepositoryImpl` -> `ImovelDetalheDataSource` (interface) -> `ImovelDetalheMockDataSource` (`@LazySingleton(as: ImovelDetalheDataSource)`, registrada em `injection.config.dart` l.100). O mock serve mapas de wire e passa por `DetalheImovelModel.fromJson` (mesmo parse do remoto da Fase 5). §11 de `01-CONTRATO-API.md` existe (§11.1–11.5, PENDENTE E2 listados); `imovel_detalhe.example.json` e `imovel_detalhe_lote.example.json` existem e `contrato_detalhe_test` os compara por deep-equals com `detalhesAcervoFixture()[42]`/`[103]` e varre chaves proibidas. |

**Score:** 6/6 truths verified (0 present, behavior-unverified)

### Must-haves de PLAN (complementares, todos checados no código)

| Plano | Truth chave | Status | Evidência |
|-------|-------------|--------|-----------|
| 01 | Toque no card abre a página via `Navigator.push`, prévia na hora + spinner; DI só no toque | VERIFIED | `vitrine_screen.dart:34,41,354` (`aoAbrirImovel`, default `abrirDetalheImovel`); `getIt<DetalheImovelCubit>()` só dentro de `abrirDetalheImovel`; estado `carregando` mostra `previa` + `CircularProgressIndicator`. |
| 03 | 404 -> `ImovelNaoEncontradoException` -> "Este imóvel não está mais disponível" + "Voltar à vitrine" (sem retry); demais falhas -> "Tentar de novo" | VERIFIED | Repositório traduz `DioException` 404 e `TypeError`; Cubit decide por `is ImovelNaoEncontradoException`; nenhum `try/catch` em `lib/presentation` (grep vazio). |
| 04 | Ids reservados 338 (falha) e 339 (404) determinísticos; só URLs http(s) | VERIFIED | `idDetalheFalhaMock`/`idDetalheDespublicadoMock` no mock; `urlHttpOuNula` usado em fotos e foto do corretor. |
| 05 | Natureza em `DadosNatureza` sealed; bloco incoerente/ausente -> `dados == null` sem derrubar parse; `area_livre` como veio | VERIFIED | `_mapearDados()` com `switch (natureza)` e `_ => null`; `CasaModel.paraEntidade` copia `areaLivre` sem cálculo. |
| 06/07/08 | Switch exaustivo sem `default`; sem pacote novo (`InteractiveViewer` do SDK); sem barra inferior fixa; sem WhatsApp/mapa/favoritar | VERIFIED | `pubspec.yaml` sem dependência nova; sem `bottomNavigationBar`; teste "sem barra inferior fixa (D-12)". |

### Behavior-dependent truths

| Invariante | Status | Evidência comportamental |
|------------|--------|--------------------------|
| Zoom trava o swipe; voltar a 1x destrava; trocar de página destrava | VERIFIED (nível de physics) | `visualizador_fotos_test.dart` l.93–125 afirma `PageScrollPhysics` <-> `NeverScrollableScrollPhysics`. Gesto de pinça real em aparelho vai para verificação humana (abaixo). |
| Cubit não emite após `close()`; retry volta a `carregando` e repete a busca | VERIFIED | `detalhe_imovel_cubit_test.dart` passa; `isClosed` checado antes de cada `emit`. |

### Required Artifacts

| Artefato | Status | Detalhes |
|----------|--------|----------|
| entidades `detalhe_imovel.dart`, `dados_natureza.dart` (+ freezed) | VERIFIED | substantivas, usadas por model e tela |
| models `detalhe_imovel_model.dart`, `dados_natureza_model.dart`, `url_segura.dart` (+ g/freezed) | VERIFIED | `fromJson` + `paraEntidade` reais |
| `imovel_detalhe_{datasource,mock_datasource}.dart`, `imoveis_detalhe_fixture.dart` | VERIFIED | registrados no DI; fixture parte de `linhasAcervoFixture()` |
| `imovel_detalhe_repository_impl.dart`, use case, cubit, state | VERIFIED | WIRED (DI `injection.config.dart` l.125–176) |
| telas/widgets em `presentation/detalhe_imovel/` | VERIFIED | todos importados e usados por `detalhe_imovel_screen.dart` |
| §11 do contrato + 2 exemplos JSON | VERIFIED | presentes e cobertos por teste de contrato |

### Key Link Verification

| De | Para | Via | Status |
|----|------|-----|--------|
| `vitrine_screen.dart` | `detalhe_imovel_screen.dart` | `aoAbrirImovel` -> `abrirDetalheImovel` | WIRED |
| `detalhe_imovel_screen.dart` | `galeria_imovel.dart` / `visualizador_fotos.dart` | `GaleriaImovel(...)`, `abrirVisualizadorFotos` | WIRED |
| `detalhe_imovel_screen.dart` | `secao_natureza.dart` / `perfil_corretor_screen.dart` / `linhasDeCustos` | `SecaoNatureza`, `abrirPerfilCorretor`, `_Cabecalho` | WIRED |
| mock datasource | `DetalheImovelModel.fromJson` | `buscarDetalhe` | WIRED |
| repository impl | `ImovelNaoEncontradoException` -> cubit | `statusCode == 404` / `is ImovelNaoEncontradoException` | WIRED |

### Data-Flow Trace (Nível 4)

| Artefato | Variável | Fonte | Dados reais | Status |
|----------|----------|-------|-------------|--------|
| `detalhe_imovel_screen.dart` | `detalhe` (fotos, preços, dados, corretor) | Cubit <- repo <- `ImovelDetalheMockDataSource` <- `detalhesAcervoFixture()` -> `fromJson` | Sim (servidor simulado em forma de wire; troca por remoto é API-07/Fase 5) | FLOWING |
| cabeçalho durante `carregando` | `previa` | `Imovel` já recebido pela vitrine | Sim | FLOWING |

### Behavioral Spot-Checks / Probes

| Comportamento | Comando | Resultado | Status |
|---------------|---------|-----------|--------|
| Testes da fase (12 arquivos) | `flutter test <12 arquivos>` | `+190: All tests passed!` | PASS |
| Suíte completa / analyze | executados pelo orquestrador | 587 passando / analyze limpo | PASS (não repetido) |
| Probes `scripts/*/tests/probe-*.sh` | n/d | fase não declara probes | SKIPPED |

### Requirements Coverage (PLAN frontmatter x REQUIREMENTS.md)

| Requisito | Plano(s) | Descrição | Status | Evidência |
|-----------|----------|-----------|--------|-----------|
| DET-01 | 04-01, 04-04 | Card abre a página; prévia na hora + carrega detalhe | SATISFIED | `abrirDetalheImovel`, estado `carregando` com prévia; teste de navegação |
| DET-02 | 04-04, 04-07 | Galeria da capa, "N/M", visualizador com swipe/pinch-zoom, placeholder sem fotos | SATISFIED | `galeria_imovel.dart`, `visualizador_fotos.dart`; humano para gesto real |
| DET-03 | 04-08 | Preços venda/aluguel, condomínio, IPTU exatamente da API | SATISFIED | `linhasDeCustos`, `linhasDePrecoPorFinalidade` |
| DET-04 | 04-05, 04-06 | Dados da natureza; campo nulo omite linha, seção vazia some | SATISFIED | `apresentacao_natureza.dart`, `secao_natureza.dart`, `cards_natureza.dart` |
| DET-05 | 04-01, 04-08 | Descrição, características, corretor com foto, toque abre perfil | SATISFIED | `SecaoDescricao`, `SecaoCaracteristicas` (chips), `CartaoCorretor` -> `PerfilCorretorScreen` |
| DET-06 | 04-03 | 404 -> "não está mais disponível"; demais -> "Tentar de novo" | SATISFIED | repo + cubit + `_CorpoNaoEncontrado`/`_CorpoErro` |
| API-06 | 04-02, 04-04, 04-05 | Contrato congelado no §11 + exemplo JSON; DataSource trocável (mock honrando o contrato) | SATISFIED | §11, 2 exemplos, `contrato_detalhe_test`, DI por interface |

Todos os 7 IDs do ROADMAP estão declarados em algum PLAN e mapeados em REQUIREMENTS.md (tabela l.104–110, "Complete"). **Órfãos: nenhum** (API-07 está mapeado à Fase 5, fora do escopo).

### Anti-Patterns

| Arquivo | Padrão | Severidade | Impacto |
|---------|--------|-----------|---------|
| arquivos da fase | `TBD`/`FIXME`/`XXX`/`TODO`/`HACK` | nenhum | grep vazio |
| `lib/presentation` | `try/catch` | nenhum | grep vazio |
| `lib/presentation`, `lib/domain` | cálculo de área/valor | nenhum | só `double.tryParse` em formatadores (`formatarAreaM2`, `formatarMedidaM`, `formatarPrecoBrl`) |
| stubs / retornos vazios | — | nenhum encontrado em código de produção da fase |

### Avisos do 04-REVIEW.md (consultivo: 0 críticos, 8 warnings)

Nenhum bloqueia os critérios de sucesso do ROADMAP; ficam como backlog/decisão do dono:

- WR-01: galeria/visualizador sem arrasto por mouse (Windows/macOS) — listado em human_verification.
- WR-02: `FotoImovelModel.paraEntidade()` morto e sem o filtro de URL; `ordem` obrigatória mas não usada para ordenar (a capa-primeiro depende da ordem do wire, conforme §11.2).
- WR-03: teste de contrato lê JSONs de `.planning/` por caminho relativo.
- WR-04: toque duplo no card empilha duas páginas.
- WR-05: visualizador mostra ícone de imagem quebrada durante o carregamento.
- WR-06: mapeadores `finalidade`/`natureza` duplicados em dois models.
- WR-07: Cubit/repositório sem catch-all para `Error` que não seja `TypeError`; sem token de requisição.
- WR-08: no 404 a capa da prévia ainda aparece na barra superior.

### Gaps Summary

Nenhuma lacuna encontrada: os 6 critérios de sucesso do ROADMAP e os 7 requisitos (DET-01..06, API-06) têm implementação substantiva, ligada (UI -> Cubit -> use case -> repositório -> DataSource trocável por DI) e coberta por testes que passam. Não há dado de detalhe montado ou calculado no app (grep e testes, incluindo o caso 57 com área livre 100 vs 120). O status é `human_needed` apenas porque a fase tem itens de julgamento visual/gesto em aparelho (frontmatter `human_verification`), não por falha de código.

Observações de processo: `ROADMAP.md` ainda mostra a Fase 4 como `[ ]` (a ser marcada pelo orquestrador após o resultado da verificação); REQUIREMENTS.md já marca DET-01..06/API-06 como Complete. Este relatório não foi commitado (regra do verificador: commit fica com o orquestrador/usuário).

---

_Verified: 2026-10-12_
_Verifier: Claude (gsd-verifier)_
