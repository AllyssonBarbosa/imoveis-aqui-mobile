---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
plan: 05
subsystem: data
tags: [flutter, freezed, json_serializable, sealed-class, mock-server, contract, tdd, dart]

requires:
  - phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
    provides: "DetalheImovel/DetalheImovelModel, detalhesAcervoFixture() com detalhe gerado para todo card, urlHttpOuNula, contrato_detalhe_test com allowlists por bloco (planos 04-01..04-04)"
provides:
  - "sealed DadosNatureza (casa/terreno/apartamento/lote) + Topografia + DadosPredio/DadosQuadra/DadosLoteamento no dominio, em DetalheImovel.dados"
  - "CasaModel/TerrenoModel/ApartamentoModel/LoteModel/PredioModel/QuadraModel/LoteamentoModel parseados tolerantemente por DetalheImovelModel (switch (natureza) com curinga para null)"
  - "Servidor simulado emite as quatro chaves de bloco em todo detalhe, um bloco coerente com natureza e card; 57 (300/180/100), 63 (terreno aclive) e 103 (lote com quadra e preco proprio) curados"
  - "contrato/imovel_detalhe_lote.example.json identico ao detalhe 103 do mock e dentro da allowlist"
affects: [04-06 apresentacao da natureza, 04-07, 04-08, fase-05 endpoint real do detalhe]

actuals:
  tokens: 11760
  tasks: 2
  commits: 4

plan_head_before: 37ff3542a1c78d8c3c0dd435c879408c7b742d60

tech-stack:
  added: []
  patterns:
    - "Natureza como bloco irmao do discriminador: DetalheImovelModel carrega os 4 blocos nullable e escolhe um via switch (natureza), sem unionKey do freezed"
    - "Todo campo de bloco opcional; areas, medidas e preco ficam strings decimais do servidor; posicao_solar e texto cru (sem enum)"
    - "Fixture com blocos gerados por variante (id ~/ 4) e sobrepostos por _blocoCurado(id) que devolve mapas novos a cada chamada"

key-files:
  created:
    - lib/domain/entities/dados_natureza.dart
    - lib/data/models/dados_natureza_model.dart
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/contrato/imovel_detalhe_lote.example.json
  modified:
    - lib/domain/entities/detalhe_imovel.dart
    - lib/data/models/detalhe_imovel_model.dart
    - lib/data/mocks/imoveis_detalhe_fixture.dart
    - test/data/detalhe_imovel_model_test.dart
    - test/data/imovel_detalhe_mock_datasource_test.dart
    - test/data/contrato_detalhe_test.dart

key-decisions:
  - "Variacao dos blocos gerados usa variante = id ~/ 4, nao id % 4: os ids gerados de cada natureza andam de 4 em 4, entao id % 4 seria constante dentro da natureza"
  - "area_livre gerada pelo servidor simulado = terreno menos a projecao da construcao (area construida / pavimentos), nao a diferenca simples, para que so o 57 curado (300/180/100) e a geracao nao sugiram uma formula ao app"
  - "lote.preco do 103 e a literal '210500.50' (valor do servidor simulado, igual ao preco_venda do card, guardado por teste); nada o deriva em runtime"

patterns-established:
  - "Bloco por natureza: parse tolerante (natureza desconhecida, bloco ausente/nulo ou incoerente resultam em dados == null, nunca em excecao)"
  - "Exemplos do contrato sao deep-equal a uma entrada da fixture e passam pela mesma allowlist"

requirements-completed: [DET-04, API-06]

coverage:
  - id: D1
    description: "O detalhe carrega os dados proprios da natureza (casa com areas, terreno com medidas e topografia, apartamento com o predio, lote com quadra e loteamento) numa sealed class DadosNatureza, com area_livre exatamente como o servidor mandou"
    requirement: "DET-04"
    verification:
      - kind: unit
        ref: "test/data/detalhe_imovel_model_test.dart#dados da natureza (DET-04, D-02, D-05, D-14)"
        status: pass
      - kind: unit
        ref: "test/data/detalhe_imovel_model_test.dart#prédio, quadra e loteamento embutidos (DET-04, D-03)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Natureza desconhecida, bloco ausente, nulo ou incoerente resultam em dados == null sem derrubar o parse; posicao_solar e topografia tratadas defensivamente"
    requirement: "DET-04"
    verification:
      - kind: unit
        ref: "test/data/detalhe_imovel_model_test.dart#natureza desconhecida resulta em dados == null"
        status: pass
    human_judgment: false
  - id: D3
    description: "Todo detalhe do servidor simulado tem exatamente um bloco coerente com a natureza e com o card; o exemplo do lote 103 e identico ao mock e esta na allowlist"
    requirement: "API-06"
    verification:
      - kind: unit
        ref: "test/data/imovel_detalhe_mock_datasource_test.dart#blocos de natureza (DET-04, API-06, D-14, D-19)"
        status: pass
      - kind: unit
        ref: "test/data/contrato_detalhe_test.dart#imovel_detalhe_lote.example.json (§11, lote com quadra)"
        status: pass
    human_judgment: false

duration: 12min
completed: 2026-10-12
status: complete
---

# Phase 4 Plan 05: Bloco por natureza no detalhe Summary

**Sealed DadosNatureza (casa/terreno/apartamento/lote, com prédio e quadra/loteamento embutidos) parseada tolerantemente por DetalheImovelModel e servida pelo mock em todo detalhe, com area_livre vinda pronta do servidor e o exemplo do lote 103 no contrato**

## Performance

- **Duration:** 12 min
- **Started:** 2026-10-12T05:35:30Z
- **Completed:** 2026-10-12T05:47:30Z
- **Tasks:** 2
- **Files modified:** 15 (6 de código escrito à mão, 3 de testes/contrato, 6 gerados pelo build_runner)

## Accomplishments

- `DadosNatureza` (sealed, 4 variantes) + `Topografia` + `DadosPredio`/`DadosQuadra`/`DadosLoteamento` no domínio; `DetalheImovel.dados`. Todos os campos opcionais; áreas e preço continuam strings decimais, `posicaoSolar` é o texto cru da API.
- Models dos blocos (`CasaModel`, `TerrenoModel`, `ApartamentoModel`, `LoteModel`, `PredioModel`, `QuadraModel`, `LoteamentoModel`) e o `switch (natureza)` em `DetalheImovelModel.paraEntidade()`: natureza desconhecida, bloco ausente/nulo ou que não bate com a natureza dão `dados == null`; topografia desconhecida dá `null`; `infraestrutura`/`areas_lazer` ausentes viram listas vazias.
- Servidor simulado: toda entrada traz as quatro chaves de bloco com só a da natureza preenchida, derivada da linha do card (quartos/suítes/vagas e área do card). Curados: 57 (`area_terreno` 300,00 / `area_construida` 180,00 / `area_livre` 100,00 — deliberadamente não a diferença), 63 (terreno aclive 12 x 25) e 103 (Quadra B, Residencial Parque das Flores, único lote com `preco`). O 42 segue o §11 verbatim.
- `imovel_detalhe_lote.example.json` gerado do mapa exato do detalhe 103; `contrato_detalhe_test.dart` o parseia, compara por igualdade profunda com o mock e aplica a allowlist; o teste "um bloco por natureza" agora exige exatamente um bloco e as quatro chaves.

## Task Commits

1. **Task 1: Bloco por natureza (casa, terreno, apartamento, lote)** — RED `4bfc386` (test), GREEN `57d1409` (feat)
2. **Task 2: Prédio do apartamento e quadra/loteamento do lote embutidos, com exemplo de lote** — RED `405db30` (test), GREEN `f919f5b` (feat)

**Plan metadata:** commit `docs(04-05)` seguinte a este arquivo.

_Sem commit de REFACTOR: nenhuma limpeza necessária após o GREEN._

## TDD Gate Compliance

- Task 1: RED `4bfc386` (test) precede GREEN `57d1409` (feat). O teste-alvo `contrato_detalhe_test.dart` "exatamente um bloco de natureza preenchido" falhou por asserção (`Expected: <1> Actual: <0>`, fixture[57]); os testes de Model e do mock falharam ao carregar porque `DadosNatureza`/`dados` ainda não existiam.
- Task 2: RED `405db30` (test) precede GREEN `f919f5b` (feat). O teste-alvo `imovel_detalhe_mock_datasource_test.dart` "o lote 103 é da Quadra B..." falhou por asserção sobre o bloco ainda sem quadra.
- `gsd_run check tdd-red-evidence` valida saída TAP (node test) e o `flutter test` não emite TAP, então o registro de evidência não foi gerado; o RED foi conferido lendo a saída do `flutter test` (falha de asserção no teste-alvo, não erro de sintaxe).

## Files Created/Modified

- `lib/domain/entities/dados_natureza.dart` — sealed `DadosNatureza`, `Topografia`, `DadosPredio`, `DadosQuadra`, `DadosLoteamento`
- `lib/domain/entities/detalhe_imovel.dart` — `DadosNatureza? dados`
- `lib/data/models/dados_natureza_model.dart` — modelos de transporte dos blocos com `paraEntidade()`
- `lib/data/models/detalhe_imovel_model.dart` — os quatro blocos nullable e `_mapearDados()` com `switch (natureza)`
- `lib/data/mocks/imoveis_detalhe_fixture.dart` — blocos gerados por variante, `_blocoCurado` (57, 63, 103), prédio e quadra
- `.planning/phases/01-.../contrato/imovel_detalhe_lote.example.json` — exemplo de wire do lote 103
- `test/data/detalhe_imovel_model_test.dart`, `test/data/imovel_detalhe_mock_datasource_test.dart`, `test/data/contrato_detalhe_test.dart` — cobertura de parse, coerência da fixture e contrato
- Arquivos `*.freezed.dart` / `*.g.dart` regenerados pelo build_runner (rastreados no repositório)

## Decisions Made

- Variação dos blocos gerados por `id ~/ 4` (ver key-decisions): `id % 4` seria constante por natureza porque os ids gerados andam de 4 em 4.
- `area_livre` gerada pelo servidor simulado desconta só a projeção da construção; o 57 curado prova que o valor chega como veio.
- `lote.preco` do 103 é literal do servidor simulado, travado por teste contra o `preco_venda` do card.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Teste de "apartamento sem prédio" era vacuoso**
- **Found during:** Task 2 (GREEN)
- **Issue:** O plano pede prédio nulo para `id % 10 == 9`, mas os apartamentos gerados têm ids pares (k % 4 == 0), então nunca caem nesse caso; meu teste exigia `verificados > 0` e falhava.
- **Fix:** Removi esse teste e documentei no comentário de `_predioGerado` que o prédio ausente é provado pelo Model (`predio nulo ou ausente vira null`), não pela fixture. Regra do plano mantida: todo apartamento com `id % 10 != 9` tem prédio.
- **Files modified:** `test/data/imovel_detalhe_mock_datasource_test.dart`, `lib/data/mocks/imoveis_detalhe_fixture.dart`
- **Committed in:** `f919f5b`

**2. [Rule 1 - Bug] Variação por `id % 4` seria constante**
- **Found during:** Task 1 (fixture)
- **Issue:** O plano cita "from `id`" e "by `id % 4`" para nomes de prédio; com ids de 4 em 4 por natureza, todo prédio teria o mesmo nome e `posicao_solar` seria um único valor.
- **Fix:** Usei `variante = id ~/ 4` em todas as fórmulas da fixture; os testes provam os quatro rótulos de posição solar, as três topografias e os quatro nomes de prédio.
- **Files modified:** `lib/data/mocks/imoveis_detalhe_fixture.dart`
- **Committed in:** `57d1409`, `f919f5b`

---

**Total deviations:** 2 auto-fixed (2 Rule 1)
**Impact on plan:** Nenhuma mudança de escopo ou de contrato; só ajuste das fórmulas e de um teste do próprio plano.

## Issues Encountered

- Disco com 2,2 GiB livres (precondição de 2 GiB atendida); `build_runner` e a suíte completa rodaram sem problema.
- Um comando de shell meu ficou pendurado esperando stdin e foi encerrado; nenhum arquivo ficou para trás.

## Known Stubs

Nenhum stub de UI. Os blocos da fixture são dados do servidor simulado (dev-only, saem com o mock na Fase 5).

## Threat Flags

Nenhuma superfície nova além da já coberta pelo `<threat_model>` do plano (T-04-05-01 a 03): switch com curinga e enum tolerante testados; allowlists por bloco (incl. predio/quadra/loteamento) cobrem toda a fixture e os dois exemplos; o app não calcula nenhuma área.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plano 04-06 pode renderizar `DetalheImovel.dados` (rótulo/valor, destaques, card de prédio e de loteamento); o 57 (300/180/100) está pronto para o teste anti-cálculo e o 103 para o caminho "preço do lote só se vier".
- Pendências E2 (§11 itens b, d) seguem DEFERRED e tratadas de forma defensiva nos dados.

## Self-Check: PASSED

- Arquivos criados presentes: `lib/domain/entities/dados_natureza.dart`, `lib/data/models/dados_natureza_model.dart`, `imovel_detalhe_lote.example.json` (JSON válido).
- Commits presentes: `4bfc386`, `57d1409`, `405db30`, `f919f5b` (`git rev-list --count 37ff354..HEAD` = 4).
- `flutter test` (492 testes) e `flutter analyze` limpos; build_runner sem SEVERE.

---
*Phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza*
*Completed: 2026-10-12*
