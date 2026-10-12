---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
plan: 06
subsystem: ui
tags: [flutter, material3, presentation, pure-functions, sealed-class, tdd, dart, intl]

requires:
  - phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
    provides: "DetalheImovel.dados (sealed DadosNatureza com DadosPredio/DadosQuadra/DadosLoteamento), servidor simulado com 57 (300/180/100), 63, 42 e 103 curados (plano 04-05); DetalheImovelScreen com cabecalho e descricao (04-03)"
provides:
  - "apresentacao_natureza.dart: funcoes puras destaquesDe/linhasDe/linhasDoPredio/linhasDaQuadra/quadraTemConteudo/tituloSecaoNatureza e formatadores formatarAreaM2/formatarMedidaM/rotuloTopografia/rotuloSimNao"
  - "SecaoDetalhe, SecaoDescricao e LinhasDeDados compartilhados pelas secoes da pagina"
  - "SecaoNatureza (destaques com icone + ficha rotulo/valor + card) entre o cabecalho e a descricao"
  - "CardPredio (apartamento) e CardQuadraLoteamento (lote, com Chips de infraestrutura e areas de lazer)"
affects: [04-07, 04-08, fase-05 endpoint real do detalhe]

actuals:
  tokens: 11176
  tasks: 2
  commits: 4

plan_head_before: 3cd22fae736c851a85e14d481265af02a172ab1a

tech-stack:
  added: []
  patterns:
    - "Quais linhas existem e decidido em funcoes puras (switch exaustivo sobre DadosNatureza, sem default); widgets so desenham"
    - "Campo nulo omite a linha; card e secao sem conteudo viram SizedBox.shrink (D-14)"
    - "Records tipados (Destaque, LinhaDado) como contrato entre apresentacao pura e widgets"

key-files:
  created:
    - lib/presentation/detalhe_imovel/apresentacao_natureza.dart
    - lib/presentation/detalhe_imovel/widgets/secoes_detalhe.dart
    - lib/presentation/detalhe_imovel/widgets/secao_natureza.dart
    - lib/presentation/detalhe_imovel/widgets/cards_natureza.dart
    - test/presentation/apresentacao_natureza_test.dart
  modified:
    - lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart
    - test/presentation/detalhe_imovel_screen_test.dart

key-decisions:
  - "LinhasDeDados (lista rotulo/valor) mora em secoes_detalhe.dart para ser usada por SecaoNatureza e pelos cards sem import circular"
  - "quadraTemConteudo e funcao pura em apresentacao_natureza.dart, usada pelo card e pela secao, para a secao sumir quando so ha um card vazio"
  - "Card da secao escolhido por switch exaustivo com guardas (when) e uma ultima alternativa que lista as quatro variantes, sem ramo default"
  - "Numeros formatados com NumberFormat('#,##0.##', 'pt_BR'); valor nao-parseavel volta como veio"

patterns-established:
  - "Apresentacao pura + widget burro: SecaoNatureza so chama destaquesDe/linhasDe e desenha"
  - "Teste anti-calculo em dois niveis: funcao pura (linhasDe) e pagina renderizada (100 m2 presente, 120 m2 ausente)"

requirements-completed: [DET-04]

coverage:
  - id: D1
    description: "Casa mostra area do terreno, construida e livre exatamente como vieram (57: 300/180/100 m2, nunca 120 m2); terreno mostra frente, fundo e topografia em PT; apartamento mostra unidade, areas, varanda e posicao solar como a API manda"
    requirement: "DET-04"
    verification:
      - kind: unit
        ref: "test/presentation/apresentacao_natureza_test.dart#casa (imóvel 57)"
        status: pass
      - kind: unit
        ref: "test/presentation/apresentacao_natureza_test.dart#terreno (imóvel 63)"
        status: pass
      - kind: unit
        ref: "test/presentation/apresentacao_natureza_test.dart#apartamento (imóvel 42)"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/detalhe_imovel_screen_test.dart#natureza (DET-04)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Apartamento mostra os dados do predio num Card proprio; lote mostra quadra e loteamento (nome, incorporadora, infraestrutura e areas de lazer em Chips) num Card proprio; 'Preco do lote' so quando lote.preco vem preenchido"
    requirement: "DET-04"
    verification:
      - kind: unit
        ref: "test/presentation/apresentacao_natureza_test.dart#linhasDoPredio"
        status: pass
      - kind: unit
        ref: "test/presentation/apresentacao_natureza_test.dart#linhasDaQuadra"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/detalhe_imovel_screen_test.dart#prédio e loteamento (DET-04)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Campo nulo omite a linha; card ou secao sem nenhuma linha some inteiro; detalhe sem dados de natureza nao mostra a secao e a descricao continua"
    requirement: "DET-04"
    verification:
      - kind: automated_ui
        ref: "test/presentation/detalhe_imovel_screen_test.dart#sem dados de natureza não há título \"Sobre\" e a descrição continua"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/detalhe_imovel_screen_test.dart#natureza sem nenhum campo preenchido faz a seção sumir"
        status: pass
    human_judgment: false
  - id: D4
    description: "Escolha de icones, rotulos e densidade visual da secao 'Sobre a ...' e dos cards (D-20: sem UI-SPEC, confirmados na checagem humana da 04-08)"
    verification: []
    human_judgment: true
    rationale: "Icones e rotulos sao decisao de design (Claude's discretion); nenhum teste afirma que o resultado e adequado"

duration: 16min
completed: 2026-10-12
status: complete
---

# Phase 4 Plan 06: Apresentação da natureza Summary

**Seção "Sobre a casa/o apartamento/o terreno/o lote" com destaques de ícone e ficha rótulo/valor vindos de funções puras sem cálculo (área livre 100 m² como o servidor mandou), mais cards de prédio e de quadra/loteamento com Chips, nulos omitidos e seções vazias escondidas**

## Performance

- **Duration:** 16 min de trabalho ativo (a execução foi interrompida por limite de taxa da API e retomada horas depois; o tempo de espera não conta)
- **Started:** 2026-10-12T05:48:00Z
- **Completed:** 2026-10-12T14:31:00Z (relógio de parede, incluindo a pausa)
- **Tasks:** 2
- **Files modified:** 7 (5 de código/teste novos ou alterados à mão em `lib/`, 2 arquivos de teste)

## Accomplishments

- `apresentacao_natureza.dart`: `destaquesDe`, `linhasDe`, `linhasDoPredio`, `linhasDaQuadra`, `quadraTemConteudo`, `tituloSecaoNatureza` e formatadores (`formatarAreaM2`, `formatarMedidaM`, `rotuloTopografia`, `rotuloSimNao`). Switches exaustivos sem `default`; nenhuma soma ou diferença de áreas; posição solar e preço do lote exatamente como vêm.
- `SecaoNatureza` entre o cabeçalho e a descrição (D-11), com linha de destaques (ícone em `primary`) e ficha rótulo/valor; `SecaoDetalhe`/`SecaoDescricao` extraídos da tela e `LinhasDeDados` compartilhado.
- `CardPredio` e `CardQuadraLoteamento` (`Card.outlined`), este com `Chip` por item de infraestrutura e de áreas de lazer; cada lista vazia é omitida e o card vazio some; a seção só some quando destaques, linhas e card estão todos vazios.
- Teste anti-cálculo em dois níveis (função pura e página renderizada): casa 57 mostra `100 m²`, nunca `120 m²`.

## Task Commits

1. **Task 1: Seção 'Sobre a …' com destaques e ficha** — RED `d2df6b6` (test), GREEN `4cb80bc` (feat)
2. **Task 2: Card do prédio e card da quadra e do loteamento** — RED `7f21ed7` (test), GREEN `2bea051` (feat)

**Plan metadata:** commit `docs(04-06)` seguinte a este arquivo.

_Sem commit de REFACTOR: nenhuma limpeza necessária após o GREEN._

## TDD Gate Compliance

- Task 1: RED `d2df6b6` precede GREEN `4cb80bc`. Os testes de tela (`natureza (DET-04)`) falharam por asserção (`Found 0 widgets with text "Sobre o lote"` etc.) com o código de produção ainda sem `SecaoNatureza`; `apresentacao_natureza_test.dart` falhou ao carregar (funções inexistentes), o que no RED é aceitável porque o alvo por asserção estava no teste de tela.
- Task 2: RED `7f21ed7` precede GREEN `2bea051`. Os testes de tela positivos (`Prédio`, `Quadra e loteamento`, Chips) falharam por asserção; os negativos já passavam (comportamento de omissão).
- `gsd_run check tdd-red-evidence` espera saída TAP e o `flutter test` não a emite; o RED foi conferido lendo a saída do `flutter test` (mesma prática do plano 04-05).

## Files Created/Modified

- `lib/presentation/detalhe_imovel/apresentacao_natureza.dart` — funções puras e formatadores
- `lib/presentation/detalhe_imovel/widgets/secoes_detalhe.dart` — `SecaoDetalhe`, `SecaoDescricao`, `LinhasDeDados`
- `lib/presentation/detalhe_imovel/widgets/secao_natureza.dart` — `SecaoNatureza` (destaques, linhas, card)
- `lib/presentation/detalhe_imovel/widgets/cards_natureza.dart` — `CardPredio`, `CardQuadraLoteamento`
- `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart` — `SecaoNatureza` antes de `SecaoDescricao`; descrição privada removida
- `test/presentation/apresentacao_natureza_test.dart` — testes das funções puras
- `test/presentation/detalhe_imovel_screen_test.dart` — testes de página (natureza, prédio, loteamento)

## Decisions Made

- `LinhasDeDados` em `secoes_detalhe.dart` para evitar import circular entre `secao_natureza.dart` e `cards_natureza.dart`.
- `quadraTemConteudo` como função pura compartilhada pelo card e pela seção.
- Valores monetários nos testes usam NBSP após `R$` (` `), como `formatarPrecoBrl` já faz.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Promoção de tipo no switch sobre `DadosNatureza`**
- **Found during:** Task 1 (GREEN)
- **Issue:** `case DadosCasa() =>` não promove `dados`, então acessar `dados.areaTerreno` não compilaria.
- **Fix:** Usei padrões com variável (`final DadosCasa casa =>`), mantendo o switch exaustivo e sem `default`.
- **Files modified:** `lib/presentation/detalhe_imovel/apresentacao_natureza.dart`
- **Committed in:** `4cb80bc`

**2. [Rule 1 - Bug] Teste esperava espaço comum no preço**
- **Found during:** Task 1 (GREEN)
- **Issue:** `formatarPrecoBrl` devolve NBSP depois de `R$`; meu teste usava espaço comum.
- **Fix:** Teste ajustado para `R\$ 210.500,50`.
- **Files modified:** `test/presentation/apresentacao_natureza_test.dart`, `test/presentation/detalhe_imovel_screen_test.dart`
- **Committed in:** `4cb80bc`

**3. [Rule 1 - Bug] Card encolhia ao conteúdo**
- **Found during:** Task 2 (GREEN)
- **Issue:** Com `CrossAxisAlignment.start` o `Card` ocuparia só a largura do texto.
- **Fix:** A coluna da seção usa `CrossAxisAlignment.stretch`.
- **Files modified:** `lib/presentation/detalhe_imovel/widgets/secao_natureza.dart`
- **Committed in:** `2bea051`

---

**Total deviations:** 3 auto-fixed (1 Rule 3, 2 Rule 1)
**Impact on plan:** Nenhuma mudança de escopo; ajustes de compilação, de teste e de layout.

## Issues Encountered

- A execução foi cortada por limite de taxa da API durante o GREEN da Task 2 e retomada com o diff da árvore de trabalho intacto; o diff foi revisado, a suíte completa rodou e o GREEN foi commitado.
- Espaço em disco: 3,5 GiB livres (precondição de 2 GiB atendida).

## Known Stubs

Nenhum stub. Ícones e rótulos são escolhas de design a confirmar na checagem humana do plano 04-08 (D-20).

## Threat Flags

Nenhuma superfície nova além da coberta pelo `<threat_model>` do plano: textos livres (uso permitido, condições de parcelamento, itens das listas, posição solar) são renderizados só com `Text`/`Chip`; formatadores devolvem o texto cru quando não parseiam (T-04-06-01..03).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- A página do imóvel já mostra a natureza completa (DET-04); os planos 04-07 e 04-08 seguem.
- Pendente na checagem humana da 04-08: confirmar ícones, rótulos e densidade visual (D-20).

## Self-Check: PASSED

- Arquivos criados presentes: `apresentacao_natureza.dart`, `secoes_detalhe.dart`, `secao_natureza.dart`, `cards_natureza.dart`, `apresentacao_natureza_test.dart`.
- Commits presentes: `d2df6b6`, `4cb80bc`, `7f21ed7`, `2bea051` (`git rev-list --count 3cd22fa..HEAD` = 4).
- `flutter analyze` sem problemas; `flutter test` 536 testes passando; `grep default:` nos arquivos de apresentação = 0; nenhuma referência a mock/fixture em `lib/presentation` e `lib/domain`.

---
*Phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza*
*Completed: 2026-10-12*
