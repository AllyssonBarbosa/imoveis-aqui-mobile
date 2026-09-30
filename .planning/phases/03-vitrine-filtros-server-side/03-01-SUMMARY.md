---
phase: 03-vitrine-filtros-server-side
plan: 01
subsystem: ui
tags: [flutter, freezed, flutter_bloc, cubit, material3, filtros, query-params]

requires:
  - phase: 02-vitrine-lista-busca-e-ordenacao
    provides: "VitrineCubit._aplicarConsulta com token de versão (reinício da lista), ImovelMockDataSource como servidor simulado sobre linhas de wire, VitrineState/ConteudoVitrine"
provides:
  - "FiltrosVitrine (freezed) — contrato de domínio completo da fase (finalidade, naturezas, preço, quartos/suítes/vagas, bairros, área, características), com quantidadeAtiva/ativos/semFiltro"
  - "Filtro de finalidade ponta a ponta: sheet -> rascunho -> VitrineCubit.aplicarFiltros -> query params -> ImovelMockDataSource (finalidade inclusiva, D-02)"
  - "Chips resumidos (9 formatos), remover/limpar na hora, 'Filtros (N)', estado vazio-com-filtros (D-22), tudo sobre o reinício único da F2 (D-19)"
affects: [03-02, 03-03, 03-04, 03-05]

# Measured (#3968) — git rev-list --count 0644d5bb..HEAD, not narrated.
commits: 3
plan_head_before: 0644d5bb9f193e9fed35a906b06942229483d6cc

actuals:
  tokens: 34615
  tasks: 2
  commits: 3

tech-stack:
  added: []
  patterns:
    - "FiltrosVitrine imutável em domain/, mapeamento de query params isolado em data/parametros_consulta_imoveis.dart (nunca no domínio/presentation)"
    - "ImovelMockDataSource dividido em _paginarPelosParametros (síncrono, valida cidade/ordenacao antes de qualquer await) + _montarPagina (async, latência/filtros/ordenação/paginação) — preserva o throw síncrono de FormatException que buscar()/seguir() já tinham"
    - "RascunhoFiltrosCubit: Cubit de vida curta, criado inline pelo showModalBottomSheet, nunca registrado no get_it"
    - "FiltrosVitrine.ativos como fonte única tanto da contagem quanto dos chips (quantidadeAtiva == ativos.length)"

key-files:
  created:
    - lib/domain/entities/filtros_vitrine.dart
    - lib/presentation/vitrine/rascunho_filtros_cubit.dart
    - lib/presentation/vitrine/apresentacao_filtros.dart
    - lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart
    - lib/presentation/vitrine/widgets/chips_filtros_ativos.dart
    - test/domain/filtros_vitrine_test.dart
    - test/presentation/rascunho_filtros_cubit_test.dart
    - test/presentation/filtros_bottom_sheet_test.dart
    - test/presentation/apresentacao_filtros_test.dart
  modified:
    - lib/domain/entities/consulta_imoveis.dart
    - lib/data/datasources/parametros_consulta_imoveis.dart
    - lib/data/datasources/imovel_mock_datasource.dart
    - lib/presentation/vitrine/vitrine_state.dart
    - lib/presentation/vitrine/vitrine_cubit.dart
    - lib/presentation/vitrine/vitrine_screen.dart
    - test/data/imovel_mock_datasource_test.dart
    - test/presentation/vitrine_cubit_test.dart
    - test/presentation/vitrine_screen_test.dart
    - test/presentation/vitrine_fluxo_test.dart

key-decisions:
  - "Task 2 seguiu TDD explícito (tdd=\"true\"): commit test(03-02) com todos os testes falhando (RED, confirmado via flutter test) antes do commit feat(03-02) com a implementação (GREEN); nenhum REFACTOR commit foi necessário"
  - "ImovelMockDataSource._paginarPelosParametros permanece NÃO-async de propósito: cidade/ordenacao são validados e lançam FormatException sincronamente antes de delegar à parte async (_montarPagina), preservando o comportamento síncrono que os testes de seguir() com ordenacao/cursor inválidos já exigiam"
  - "'Qualquer' é um terceiro segmento real do SegmentedButton (nunca ausência de seleção com emptySelectionAllowed), conforme RESEARCH Pattern 3/Pitfall 1"
  - "next/previous do mock agora carregam o MESMO mapa de query params recebido (menos cursor) em vez de reconstruir via parametrosDaConsulta — todo filtro futuro sobrevive à paginação automaticamente, sem precisar estender essa função de novo"

patterns-established:
  - "Toda mudança de filtro aplicado (aplicar/remover/limpar) passa OBRIGATORIAMENTE por _aplicarConsulta — grep-gated (\"++_versaoConsulta\" aparece 1 vez em vitrine_cubit.dart)"
  - "chipsDosFiltros/formatarValorCompacto centralizam TODOS os 9 rótulos de filtro desde já, mesmo para dimensões sem controle no sheet ainda — planos 03-03..03-05 só precisam expor o controle"

requirements-completed: [FIL-01, FIL-05, FIL-06]

coverage:
  - id: D1
    description: "Filtro de finalidade (Qualquer/Venda/Aluguel) aplicado ponta a ponta via sheet -> VitrineCubit -> query params -> ImovelMockDataSource, com semântica inclusiva (D-02)"
    requirement: "FIL-01"
    verification:
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: tocar Filtros -> Venda -> Ver imóveis filtra pela pilha real..."
        status: pass
      - kind: integration
        ref: "test/data/imovel_mock_datasource_test.dart#ImovelMockDataSource — filtro finalidade (D-02, D-19)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Toda a filtragem é resolvida pela DataSource sobre query params — nunca no app (FIL-05)"
    requirement: "FIL-05"
    verification:
      - kind: other
        ref: "grep -rnE \"itens\\.(where|sort|retainWhere|removeWhere)\" lib/presentation lib/domain (0 matches) + grep -rlnE \"MockDataSource|linhasAcervoFixture\" lib/presentation lib/domain (0 matches)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Chips resumidos, contagem \"Filtros (N)\", remover/limpar na hora e o estado vazio-com-filtros (D-22), tudo sobre o reinício único de paginação da F2 (D-19)"
    requirement: "FIL-06"
    verification:
      - kind: unit
        ref: "test/presentation/apresentacao_filtros_test.dart (9 formatos + formatarValorCompacto)"
        status: pass
      - kind: integration
        ref: "test/presentation/vitrine_cubit_test.dart#aplicarFiltros / removerFiltro / limparFiltros + Decisão de vazio com 4 combinações"
        status: pass
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#aplicar Venda mostra o chip 'Venda'...; aplicar Aluguel e tocar Limpar filtros..."
        status: pass
    human_judgment: false
  - id: D4
    description: "Layout visual do botão 'Filtros' ao lado de 'Ordenar', a linha de chips e o sheet em tela cheia seguem Material 3 / paleta verde-branco na tela real do dispositivo"
    human_judgment: true
    rationale: "Testes de widget verificam estrutura/texto/comportamento, não aparência visual final (cores, espaçamento, responsividade real) — julgamento humano necessário para confirmar o resultado visual no app rodando, mesmo padrão já usado nas Fases 1/2 para os elementos de UI"

duration: 50min
completed: 2026-09-30
status: complete
---

# Phase 3 Plan 1: Tracer do Filtro de Finalidade + Chips Ativos Summary

**Filtro de finalidade ponta a ponta (sheet -> rascunho -> Cubit -> query params -> servidor simulado, com inclusão VENDA_E_ALUGUEL) mais o ciclo completo de chips ativos — contagem, remover, limpar e o estado vazio-com-filtros — tudo reaproveitando o reinício de paginação com token de versão da Fase 2.**

## Performance

- **Duration:** ~50 min
- **Completed:** 2026-09-30
- **Tasks:** 2
- **Files modified/created:** 21 (10 novos, 11 alterados) — 9 em `lib/`, 12 em `test/`

## Accomplishments

- `FiltrosVitrine` (freezed) criado em `domain/entities/` com a forma completa da fase (finalidade, naturezas, preço, quartos/suítes/vagas, bairros, área, características), `enum FiltroAtivo`, `ativos`, `quantidadeAtiva` e `semFiltro` — os planos 03-02..03-05 só precisam expor controles, o contrato de domínio já está fechado.
- Filtro de finalidade funcionando de ponta a ponta: botão "Filtros" -> bottom sheet em tela cheia com `SegmentedButton` de 3 segmentos (Qualquer/Venda/Aluguel) -> rascunho local (`RascunhoFiltrosCubit`) -> "Ver imóveis" aplica uma única vez -> `VitrineCubit.aplicarFiltros` -> query param `finalidade` -> `ImovelMockDataSource` filtra de forma inclusiva (D-02: `VENDA` traz `VENDA` e `VENDA_E_ALUGUEL`).
- `ImovelMockDataSource` refatorado para uma pipeline única (`_paginarPelosParametros` -> `_montarPagina`) que lê filtros/busca/ordenação/cidade SÓ do mapa de query params — `next`/`previous` carregam automaticamente qualquer filtro futuro, sem precisar estender a construção de URL de novo.
- Chips resumidos (9 formatos: finalidade, naturezas, preço com/sem "/mês", quartos/suítes/vagas "N+", bairros/características "nome +N", área) com `formatarValorCompacto` ("1 mil", "3,5 mil", "1,2 mi"); "x" remove na hora, corpo reabre o sheet, `ActionChip` "Limpar filtros" zera tudo.
- Estado "Nenhum imóvel com esses filtros" (D-22), distinto de `vazioNaCidade` e `semResultado`, com mensagem combinada quando busca e filtros estão ativos ao mesmo tempo — decisão de vazio agora cobre as 4 combinações.

## Task Commits

Task 1 é `type="tracer"` (produção, sem checkpoint de feedback — verify automatizado re-executado com sucesso, expansão liberada). Task 2 é `type="auto" tdd="true"`, executado em RED -> GREEN (sem REFACTOR):

1. **Task 1: Tracer do filtro de finalidade ponta a ponta** — `a1d0b07` (feat)
2. **Task 2 RED: testes falhando para chips/remover/limpar/vazio-com-filtros** — `6197927` (test)
3. **Task 2 GREEN: implementação** — `f37c7b1` (feat)

**Plan metadata:** commit pendente (este commit)

## Files Created/Modified

- `lib/domain/entities/filtros_vitrine.dart` - `FiltrosVitrine` freezed completo, `FinalidadeFiltro`, `FiltroAtivo`, `ativos`/`quantidadeAtiva`/`semFiltro`
- `lib/domain/entities/consulta_imoveis.dart` - ganha o campo `filtros` (triade `==`/`hashCode`/`toString` estendida)
- `lib/data/datasources/parametros_consulta_imoveis.dart` - mapeia/parseia `finalidade`; `filtrosDosParametros` como inverso exato
- `lib/data/datasources/imovel_mock_datasource.dart` - pipeline única `_paginarPelosParametros`/`_montarPagina`; `_linhaCasaComFiltros`
- `lib/presentation/vitrine/vitrine_state.dart` - campo `filtros`; variante `semResultadoComFiltros`
- `lib/presentation/vitrine/vitrine_cubit.dart` - `aplicarFiltros`/`removerFiltro`/`limparFiltros`/`limparBuscaEFiltros`; decisão de vazio com 4 combinações
- `lib/presentation/vitrine/rascunho_filtros_cubit.dart` - rascunho de vida curta do sheet (D-08)
- `lib/presentation/vitrine/apresentacao_filtros.dart` - `rotuloBotaoFiltros`, `ChipDeFiltro`, `chipsDosFiltros`, `formatarValorCompacto`
- `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart` - sheet em tela cheia, rodapé fixo, `SegmentedButton`
- `lib/presentation/vitrine/widgets/chips_filtros_ativos.dart` - linha rolável de `InputChip` + `ActionChip`
- `lib/presentation/vitrine/vitrine_screen.dart` - botão "Filtros (N)", linha de chips, caso `VitrineSemResultadoComFiltros`
- Testes: `test/domain/filtros_vitrine_test.dart`, `test/presentation/rascunho_filtros_cubit_test.dart`, `test/presentation/filtros_bottom_sheet_test.dart`, `test/presentation/apresentacao_filtros_test.dart` (novos); `test/data/imovel_mock_datasource_test.dart`, `test/presentation/vitrine_cubit_test.dart`, `test/presentation/vitrine_screen_test.dart`, `test/presentation/vitrine_fluxo_test.dart` (estendidos)

## Decisions Made

- TDD explícito na Task 2: commit RED (`test(03-02)`, todos os testes novos falhando — confirmado rodando `flutter test` antes de qualquer implementação) seguido do commit GREEN (`feat(03-02)`); nenhum REFACTOR commit foi necessário (implementação já limpa na primeira passada).
- `ImovelMockDataSource._paginarPelosParametros` continua **não-async** de propósito: valida `cidade`/`ordenacao` e lança `FormatException` SINCRONAMENTE antes de delegar à parte `async` (`_montarPagina`) — preserva o comportamento síncrono que os testes existentes de `seguir()` com cursor/ordenação inválidos já exigiam (evita quebrar 2 testes pré-existentes que dependem do throw sair antes de qualquer `await`).
- "Qualquer" é um terceiro segmento real do `SegmentedButton` (nunca ausência de seleção com `emptySelectionAllowed`), conforme RESEARCH Pattern 3/Pitfall 1.
- `next`/`previous` do mock passaram a carregar o MESMO mapa de query params recebido (menos `cursor`) em vez de reconstruir via `parametrosDaConsulta` — todo filtro futuro (03-02..03-05) sobrevive à paginação automaticamente, sem precisar tocar nessa função de novo.

## Deviations from Plan

None - plan executado como escrito, incluindo a disciplina de TDD explícita da Task 2.

## Issues Encountered

- Durante a Task 2 (fase GREEN), dois testes recém-escritos tinham bugs no PRÓPRIO teste (não na implementação): (1) uma asserção `verify(...).called(1)` em `vitrine_cubit_test.dart` estava ambígua — remover a finalidade também limpa o preço (D-03), então a consulta final bate com a consulta inicial e soma 2 chamadas, não 1; corrigido para `.called(2)` com comentário explicando. (2) um teste em `vitrine_screen_test.dart` usava `conteudo: ConteudoVitrine.carregando()` (spinner indeterminado) junto de `pumpAndSettle()` para aguardar a animação do bottom sheet — o spinner nunca deixa `pumpAndSettle` estabilizar (armadilha já documentada no topo do arquivo); trocado para `conteudo: ConteudoVitrine.carregada(itens: [])`. Ambas as correções foram commitadas junto do GREEN (`f37c7b1`), já que eram bugs no arnês de teste, não na implementação sob teste.

## User Setup Required

None - nenhuma configuração de serviço externo necessária (mock-first, sem pacote novo).

## Next Phase Readiness

- O contrato de domínio `FiltrosVitrine` está completo e estável — os planos 03-02 (natureza/preço), 03-03..03-05 (quartos/suítes/vagas, bairros, área/características) só precisam adicionar o controle no sheet e o predicado correspondente em `_linhaCasaComFiltros`, sem tocar em `ativos`/`quantidadeAtiva`/`semFiltro`/`chipsDosFiltros`.
- Nenhum bloqueio conhecido para os próximos planos da fase.

---
*Phase: 03-vitrine-filtros-server-side*
*Completed: 2026-09-30*

## Self-Check: PASSED

- All 9 key-files (created) verified present on disk via `[ -f ]`.
- All 3 task commits (`a1d0b07`, `6197927`, `f37c7b1`) verified present via `git log --oneline --all`.
- Plan-level `<verification>` re-run: `flutter test` (237 passed), `flutter analyze` (no issues), both grep gates (0 matches — no item filter/sort in presentation/domain, no presentation/domain reference to the mock).
- Task 1 and Task 2 `<acceptance_criteria>` re-verified via targeted grep/test commands — all pass.
