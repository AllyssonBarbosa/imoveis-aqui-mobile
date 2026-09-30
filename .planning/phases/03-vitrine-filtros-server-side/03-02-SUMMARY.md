---
phase: 03-vitrine-filtros-server-side
plan: 02
subsystem: data
tags: [flutter, freezed, flutter_bloc, cubit, csv, query-params, filter-chip, choice-chip]

requires:
  - phase: 03-vitrine-filtros-server-side
    provides: "FiltrosVitrine (freezed) completo, RascunhoFiltrosCubit e filtros_bottom_sheet.dart (casca com seção Finalidade), chipsDosFiltros cobrindo as 9 dimensões, VitrineCubit._aplicarConsulta (reinício de paginação), ConteudoVitrine.semResultadoComFiltros (03-01)"
provides:
  - "parametrosDaConsulta/filtrosDosParametros estendidos com natureza/bairro/características em CSV e quartos_min/suites_min/vagas_min, mais 3 parsers novos (naturezasDoParametro, listaDoParametro, minimoDoParametro), todos com FormatException simétrica (D-12)"
  - "ImovelMockDataSource._linhaCasaComFiltros resolve natureza (OU), bairro (OU, normalizarTexto) e características (E) — semântica server-side pronta para os planos 03-04/03-05 só adicionarem o controle"
  - "Fixture com variedade determinística (D-24): quartos 0..3/4+, suítes/vagas 0..4, todo o catálogo de características por cidade, janela circular (não-prefixo) garantindo combinações como Piscina+Churrasqueira e Terreno+quartos_min=1 zerando o resultado em toda cidade atendida"
  - "Sheet ganha 'Tipo de imóvel' (4 FilterChip) e Quartos/Suítes/Vagas (_SeletorMinimo reusável, 5 ChoiceChip cada) ponta a ponta — FIL-02/FIL-03 completos via pilha real"
  - "Contrato §10: adendo completo da Fase 3 para sign-off do E2 (limiar N-ou-mais, finalidade inclusiva, preço por finalidade, E/OU, CSV com risco da vírgula, faixas inteiras, 400 malformado, dois endpoints de opções)"
affects: [03-03, 03-04, 03-05]

# Measured (#3968) — git rev-list --count 1aa47e7f..HEAD, not narrated.
commits: 5
plan_head_before: 1aa47e7f1345077f5fc405547412891ff1417e22

actuals:
  tokens: 15995
  tasks: 3
  commits: 5

tech-stack:
  added: []
  patterns:
    - "Tradução wire<->domínio de natureza fica PRIVADA a cada arquivo de data/ (parametros_consulta_imoveis.dart tem a sua própria tabela, exposta como valorWireDaNatureza só para o mock reusar), nunca uma tabela compartilhada entre camadas — mesma disciplina de ImovelModel._mapearNatureza"
    - "_SeletorMinimo (widget privado do sheet) reusado por Quartos/Suítes/Vagas — uma única implementação de ChoiceChip 'N ou mais', nunca três cópias"
    - "Fixture: seleção de características como janela CIRCULAR de tamanho e início variáveis (funções de k), não mais um sublist(0,n) fixo — garante cobertura do catálogo inteiro por cidade E combinações específicas de co-ocorrência/exclusão por construção, não por sorte"

key-files:
  created:
    - test/data/parametros_consulta_imoveis_test.dart
  modified:
    - lib/data/datasources/parametros_consulta_imoveis.dart
    - lib/data/datasources/imovel_mock_datasource.dart
    - lib/data/mocks/imoveis_fixture.dart
    - lib/presentation/vitrine/rascunho_filtros_cubit.dart
    - lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart
    - .planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md
    - test/data/imovel_mock_datasource_test.dart
    - test/presentation/rascunho_filtros_cubit_test.dart
    - test/presentation/filtros_bottom_sheet_test.dart
    - test/presentation/vitrine_fluxo_test.dart

key-decisions:
  - "Task 1 e Task 2 seguiram TDD explícito (tdd=\"true\"): cada uma teve um commit RED (test(03-02), falha confirmada via flutter test — compilação para métodos/símbolos inexistentes, e asserção para o predicado do mock) antes do commit GREEN (feat(03-02)); nenhum REFACTOR commit foi necessário em nenhuma das duas"
  - "Fórmula de quartos da fixture mudou para 1 + (k ~/ 4) % 5 em casa/apartamento (cicla 1..5); terreno/lote continuam SEMPRE com 0 quartos — é essa constante que faz Terreno + '1+ quartos' zerar o resultado deterministicamente em toda cidade atendida (D-22)"
  - "Seleção de características da fixture reescrita de um sublist(0, 1+k%10) fixo (sempre prefixo a partir do índice 0) para uma janela circular de tamanho 1+k%10 começando em (k*7)%10 — a primeira fórmula tentada (índice incluído quando (k*3+i*7)%10 < 1+k%4) nunca produzia uma linha com Portão eletrônico E Piscina ao mesmo tempo (matematicamente impossível dentro do período), então foi substituída antes do commit GREEN"
  - "valorWireDaNatureza exposto (não `_`-prefixado) em parametros_consulta_imoveis.dart para o mock comparar a linha de wire contra o Set de domínio sem duplicar a tabela natureza<->wire numa segunda cópia privada"

patterns-established:
  - "Todo filtro novo estende parametrosDaConsulta E filtrosDosParametros simetricamente (nunca só um dos dois) — round trip coberto por teste dedicado em parametros_consulta_imoveis_test.dart"
  - "Todo predicado novo do mock entra em _linhaCasaComFiltros operando sobre o mapa de wire, ANTES do parse — nunca depois (grep gate: nenhum join(',') fora de data/)"

requirements-completed: [FIL-02]

coverage:
  - id: D1
    description: "Filtro de natureza (OU entre valores) aplicado ponta a ponta via FilterChip no sheet -> rascunho -> VitrineCubit -> query params CSV -> ImovelMockDataSource, com chip resumido 'Casa, Apto' e contagem no botão Filtros (FIL-02)"
    requirement: "FIL-02"
    verification:
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: Filtros -> Casa + Apartamento + \"2+\" quartos..."
        status: pass
      - kind: integration
        ref: "test/data/imovel_mock_datasource_test.dart#natureza=CASA,APARTAMENTO devolve exatamente as linhas casa OU apartamento de Campinas (D-05)"
        status: pass
      - kind: unit
        ref: "test/presentation/rascunho_filtros_cubit_test.dart#alternarNatureza(casa, marcada: true)/(marcada: false)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Filtros de quartos/suítes/vagas ('N ou mais', >=, nunca ==) aplicados via ChoiceChip N+ no sheet, resolvidos pelo servidor simulado, com o caso de inclusão de exatamente-2-quartos coberto explicitamente (FIL-03, D-01)"
    requirement: "FIL-03"
    verification:
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: Filtros -> Casa + Apartamento + \"2+\" quartos..."
        status: pass
      - kind: integration
        ref: "test/data/imovel_mock_datasource_test.dart#quartos_min=2 devolve todas as linhas com quartos >= 2, INCLUINDO as de exatamente 2 quartos (D-01, nunca ==)"
        status: pass
      - kind: unit
        ref: "test/presentation/filtros_bottom_sheet_test.dart#tocar \"2+\" em Quartos/\"1+\" em Suítes/\"4+\" em Vagas e \"Ver imóveis\" aplica o mínimo"
        status: pass
    human_judgment: false
  - id: D3
    description: "Semântica server-side de bairro (OU, acento-insensível) e características (E, todas marcadas) resolvida no ImovelMockDataSource — pronta para os planos 03-04/03-05 só adicionarem o controle no sheet, sem tocar no mecanismo (FIL-04, FIL-05)"
    requirement: "FIL-04"
    verification:
      - kind: integration
        ref: "test/data/imovel_mock_datasource_test.dart#bairro=Cambuí,Taquaral devolve linhas de qualquer um dos dois...; características=Portão eletrônico,Piscina devolve só linhas com AMBAS (E)..."
        status: pass
    human_judgment: false
  - id: D4
    description: "Fixture com variedade determinística suficiente para exercitar cada filtro (D-24): quartos 0..3/4+, suítes/vagas 0..4, catálogo inteiro de características por cidade, e a combinação Terreno + '1+ quartos' zerando o resultado em toda cidade atendida (D-22)"
    verification:
      - kind: unit
        ref: "test/data/imovel_mock_datasource_test.dart#linhasAcervoFixture (D-14, D-15) — 6 testes novos de variedade + natureza=TERRENO + quartos_min=1 devolve zero linhas em toda cidade atendida"
        status: pass
    human_judgment: false
  - id: D5
    description: "Contrato §10 registra o lote completo de adendos da Fase 3 para o E2, explicitamente marcado como aguardando sign-off, com §1–§9 preservados"
    verification:
      - kind: other
        ref: "grep -n \"## 10. Adendos da Fase 3\" / grep -n \"## 9. Adendos da Fase 2\" / sed + grep -cE (endpoints, vírgula, 400, quartos_min) 01-CONTRATO-API.md"
        status: pass
    human_judgment: false
  - id: D6
    description: "Layout visual das novas seções do sheet (Tipo de imóvel, Quartos/Suítes/Vagas) segue Material 3 / paleta verde-branco, espaçamento 16dp entre seções, na tela real do dispositivo"
    human_judgment: true
    rationale: "Testes de widget verificam estrutura/texto/comportamento (FilterChip/ChoiceChip presentes, seleção correta), não aparência visual final (cores, espaçamento, quebra de linha do Wrap em telas estreitas) — mesmo padrão de D4 em 03-01, julgamento humano necessário no app rodando"

duration: ~40min
completed: 2026-09-30
status: complete
---

# Phase 3 Plan 2: Tipo de Imóvel e Tipologia Summary

**Servidor simulado ganha natureza/bairro/características (OU/OU/E) e os três limiares "N ou mais" em CSV sobre uma fixture com variedade determinística; o sheet ganha as seções Tipo de imóvel e Quartos/Suítes/Vagas ponta a ponta; contrato §10 registra o lote de adendos da Fase 3 para o E2.**

## Performance

- **Duration:** ~40 min
- **Completed:** 2026-09-30
- **Tasks:** 3
- **Files modified/created:** 11 (1 novo, 10 alterados) — 5 em `lib/`, 5 em `test/`, 1 em `.planning/`

## Accomplishments

- `parametrosDaConsulta`/`filtrosDosParametros` estendidos simetricamente com `natureza` (CSV em ordem de enum), `quartos_min`/`suites_min`/`vagas_min` (decimais) e `bairro`/`caracteristicas` (CSV ordenado por `normalizarTexto`) — mais três parsers inversos (`naturezasDoParametro`, `listaDoParametro`, `minimoDoParametro`), todos lançando `FormatException` para valor desconhecido/item vazio/mínimo inválido (D-12, simula o 400).
- `ImovelMockDataSource._linhaCasaComFiltros` resolve natureza (OU), bairro (OU, `normalizarTexto`) e características (E, todas marcadas), além dos três limiares "N ou mais" (`>=`, nunca `==`) — dimensões diferentes combinam por E, mesma doutrina de `finalidade` já estabelecida em 03-01.
- Fixture com variedade determinística (D-24): quartos de casa/apartamento cicla 1..5 (terreno/lote sempre 0 — a constante que faz Terreno + "1+ quartos" zerar o resultado em toda cidade atendida, D-22); vagas cicla 0..4; características usam uma janela circular de tamanho/início rotativos, garantindo tanto o catálogo inteiro por cidade quanto combinações específicas (Piscina sem Portão eletrônico e vice-versa, Piscina+Churrasqueira em Campinas).
- Sheet ganha "Tipo de imóvel" (4 `FilterChip`, multi-seleção) logo após Finalidade, e "Quartos"/"Suítes"/"Vagas" (`_SeletorMinimo` privado reusável, 5 `ChoiceChip` cada: Qualquer/1+/2+/3+/4+) — dois e2e novos pela pilha real: Casa+Apartamento+"2+" quartos filtrando corretamente, e Terreno+"1+" quartos levando ao estado "Nenhum imóvel com esses filtros" (D-22) com "Limpar filtros" restaurando a lista completa.
- Contrato `01-CONTRATO-API.md` ganha `## 10. Adendos da Fase 3`: limiar N-ou-mais (resolve §7 item 1), finalidade inclusiva e `VENDA_E_ALUGUEL` nunca como valor de filtro, preço por finalidade com faixa-sem-finalidade = 400, E/OU entre natureza/bairro/características, CSV com o risco explícito da vírgula, faixas como inteiros não-negativos inclusivos, casos de malformado que respondem 400, os dois endpoints novos de opções (bairros/características) e "Ver N imóveis" como v2 — §5 e §7 item 1 anotados apontando para §10, §1–§9 preservados intactos.

## Task Commits

Task 1 e Task 2 são `type="auto" tdd="true"`, cada uma executada em RED -> GREEN (sem REFACTOR necessário). Task 3 é `type="auto"` (docs, sem TDD):

1. **Task 1 RED: testes falhando para natureza/bairro/características/mínimos e fixture variada** — `27c3d7c` (test)
2. **Task 1 GREEN: servidor simulado honra natureza, bairro, características e mínimos em CSV** — `f6986fd` (feat)
3. **Task 2 RED: testes falhando para Tipo de imóvel e Quartos/Suítes/Vagas no sheet** — `10bf153` (test)
4. **Task 2 GREEN: sheet ganha Tipo de imóvel e Quartos/Suítes/Vagas ponta a ponta** — `2e1aac9` (feat)
5. **Task 3: contrato §10 — adendos da Fase 3 para sign-off do E2** — `b65210d` (docs)

**Plan metadata:** commit pendente (este commit)

## Files Created/Modified

- `lib/data/datasources/parametros_consulta_imoveis.dart` - `natureza`/`bairro`/`caracteristicas` CSV, `quartos_min`/`suites_min`/`vagas_min`, parsers inversos com `FormatException`, `valorWireDaNatureza`
- `lib/data/datasources/imovel_mock_datasource.dart` - `_linhaCasaComFiltros` ganha natureza (OU)/bairro (OU)/características (E)/quartos-suítes-vagas (`>=`)
- `lib/data/mocks/imoveis_fixture.dart` - quartos 1..5 (casa/apto)/0 fixo (terreno/lote), vagas 0..4, características em janela circular não-prefixo
- `lib/presentation/vitrine/rascunho_filtros_cubit.dart` - `alternarNatureza`, `definirQuartosMin`, `definirSuitesMin`, `definirVagasMin`
- `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart` - seção "Tipo de imóvel" (`FilterChip` x4), `_SeletorMinimo` privado reusado por Quartos/Suítes/Vagas
- `.planning/phases/01-.../01-CONTRATO-API.md` - `## 10. Adendos da Fase 3`, anotações em §5 e §7 item 1
- Testes: `test/data/parametros_consulta_imoveis_test.dart` (novo); `test/data/imovel_mock_datasource_test.dart`, `test/presentation/rascunho_filtros_cubit_test.dart`, `test/presentation/filtros_bottom_sheet_test.dart`, `test/presentation/vitrine_fluxo_test.dart` (estendidos)

## Decisions Made

- TDD explícito nas Tasks 1 e 2: RED confirmado via `flutter test` (compilação para símbolos ainda inexistentes na Task 1's novo arquivo de teste, e asserção para o predicado do mock ainda não implementado) antes de cada GREEN; nenhum REFACTOR commit foi necessário em nenhuma das duas.
- Fórmula de quartos da fixture: `1 + (k ~/ 4) % 5` para casa/apartamento (cicla 1..5); terreno/lote continuam SEMPRE com 0 quartos — é essa constante que faz Terreno + "1+ quartos" zerar o resultado deterministicamente em toda cidade atendida (D-22), sem depender de sorte estatística.
- Seleção de características da fixture: a primeira fórmula tentada (`(k*3+i*7)%10 < 1+k%4`, seleção por índice individual) nunca produzia, matematicamente, uma linha com Portão eletrônico E Piscina simultaneamente dentro do período — substituída por uma janela CIRCULAR de tamanho `1+k%10` começando em `(k*7)%10` antes do commit GREEN, que garante por construção tanto o catálogo inteiro por cidade (quando o tamanho atinge 10) quanto as combinações de co-ocorrência/exclusão exigidas pelo comportamento da Task 1.
- `valorWireDaNatureza` exposto (não `_`-prefixado) em `parametros_consulta_imoveis.dart` para o mock reusar a mesma tradução natureza<->wire sem duplicar a tabela numa segunda cópia privada — a tabela em si continua isolada a este arquivo (mesma disciplina de `ImovelModel._mapearNatureza`).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `find.text('Qualquer')` ficou ambíguo em dois testes pré-existentes da Fase 3 Plano 1**
- **Found during:** Task 2 (GREEN) — ao rodar a suíte completa após adicionar os `ChoiceChip`s de mínimo
- **Issue:** `filtros_bottom_sheet_test.dart` (asserção `findsOneWidget`) e `vitrine_fluxo_test.dart` (um `tester.tap`) localizavam "Qualquer" assumindo que só o `SegmentedButton` de finalidade usava esse rótulo; os 3 novos `ChoiceChip`s de mínimo (Quartos/Suítes/Vagas) reusam o mesmo texto para a opção padrão, tornando o finder ambíguo (4 matches)
- **Fix:** ambos os arquivos passaram a escopar o finder com `find.descendant(of: find.byWidgetPredicate((w) => w is SegmentedButton), matching: find.text('Qualquer'))`
- **Files modified:** test/presentation/filtros_bottom_sheet_test.dart, test/presentation/vitrine_fluxo_test.dart
- **Verification:** `flutter test` volta a passar (281/281) com os dois arquivos ajustados
- **Committed in:** 2e1aac9 (Task 2 GREEN commit)

---

**Total deviations:** 1 auto-fixed (1 bug de arnês de teste)
**Impact on plan:** Ajuste mecânico no arnês de teste pré-existente, consequência direta e esperada de reusar o mesmo rótulo Material — nenhum impacto na implementação sob teste, nenhum scope creep.

## Issues Encountered

None além do já documentado em "Decisions Made" (iteração de fórmula da fixture, prevista pelo próprio texto do plano: "tune the formulas until every fixture assertion in the behavior block holds").

## User Setup Required

None - nenhuma configuração de serviço externo necessária (mock-first, sem pacote novo, nenhum endpoint real criado nesta fase — D-20 fica registrado só como adendo de contrato).

## Next Phase Readiness

- A semântica server-side de bairro (OU) e características (E) já está completa no mock — os planos 03-04/03-05 só precisam adicionar a seção `CheckboxListTile`/`FilterChip` correspondente no sheet, sem tocar em `_linhaCasaComFiltros` nem em `parametros_consulta_imoveis.dart`.
- O contrato §10 está pronto para ser copiado ao repositório irmão e revisado pelo E2, junto com os adendos de §9 já pendentes.
- Nenhum bloqueio conhecido para os planos 03-03 (preço/área) e 03-04/03-05 (bairro/características) da fase.

---
*Phase: 03-vitrine-filtros-server-side*
*Completed: 2026-09-30*

## Self-Check: PASSED

- All 1 new key-file (`test/data/parametros_consulta_imoveis_test.dart`) and all 10 modified key-files verified present on disk via `[ -f ]`.
- All 5 task commits (`27c3d7c`, `f6986fd`, `10bf153`, `2e1aac9`, `b65210d`) verified present via `git log --oneline --all`.
- Plan-level `<verification>` re-run: `flutter test` (281 passed), `flutter analyze` (no issues), grep gate `join(',')` in `lib/presentation`/`lib/domain` (0 matches), contract §10 heading present + §9 intact + 12 required-pattern lines (>= 5).
- Task 1/2/3 `<acceptance_criteria>` re-verified via targeted grep/test commands — all pass.
