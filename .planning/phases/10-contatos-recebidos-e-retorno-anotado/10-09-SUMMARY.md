---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 09
subsystem: presentation
tags: [cubit, freezed, caixa-contatos, filtros, chips, bottom-sheet, seletor-periodo, fluxo-ponta-a-ponta]

requires:
  - phase: 10-06
    provides: "ListarImoveisDosContatosUseCase, ConsultaContatos com imovel/periodo, parametros imovel/de/ate na ApiFalsa"
  - phase: 10-07
    provides: "seletor_periodo.dart (EscolherPeriodo, escolherPeriodoComSeletor), apresentacao_contatos.dart, pt-BR do Material"
  - phase: 10-08
    provides: "CaixaContatosCubit/State/Screen com _aplicarConsulta que preserva o numero, fluxo ponta a ponta da caixa"
provides:
  - "CaixaContatosCubit: aplicarImovel, limparImovel, aplicarPeriodo, limparPeriodo (sem pedir o resumo) e carregarOpcoesDeImovel"
  - "OpcoesDeImovel (naoCarregadas/carregando/carregadas/erro) no CaixaContatosState"
  - "ChipsFiltrosContatos (Imovel e Periodo com limpar) e mostrarFolhaFiltroImovel"
  - "CaixaContatosScreen com parametro escolherPeriodo e os chips entre a linha do numero e a lista"
  - "caso do filtro por imovel no fluxo ponta a ponta da caixa"
affects: [10-10]

commits: 4
plan_head_before: a32da045ddfc5a780996f0a5793a02573f29598d
plan_head_after: b3de25c0f1ced1700b8fc80084aae3bea7cadb74

estimate_actuals_note: "tokens = chars/4 sobre o diff do app a32da04..b3de25c fora de .planning (77880 chars, inclui os testes)"
actuals:
  tokens: 19470
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Troca de filtro so reinicia a lista (_trocarConsulta): consulta igual nao chama a API e o resumo nunca e pedido de novo"
    - "Folha modal com o Cubit da tela passado por valor (BlocProvider.value), pedindo as opcoes a cada abertura"
    - "Seletor de periodo injetavel por parametro da tela (padrao escolherPeriodoComSeletor)"

key-files:
  created:
    - lib/presentation/contatos/widgets/chips_filtros_contatos.dart
    - lib/presentation/contatos/widgets/folha_filtro_imovel.dart
  modified:
    - lib/presentation/contatos/caixa_contatos_state.dart
    - lib/presentation/contatos/caixa_contatos_state.freezed.dart
    - lib/presentation/contatos/caixa_contatos_cubit.dart
    - lib/presentation/contatos/caixa_contatos_screen.dart
    - lib/presentation/contatos/apresentacao_contatos.dart
    - lib/di/injection.config.dart
    - test/presentation/caixa_contatos_cubit_test.dart
    - test/presentation/apresentacao_contatos_test.dart
    - test/presentation/caixa_contatos_screen_test.dart
    - test/presentation/caixa_contatos_fluxo_test.dart

key-decisions:
  - "Filtros no mesmo Cubit da tela (A7): _trocarConsulta compara com a consulta atual e so entao chama _aplicarConsulta, que nao toca no resumo (D-05)"
  - "Opcoes do imovel pedidas a cada abertura da folha (R3); 401 vira CaixaSessaoExpirada (terminal) e a folha sai junto com o pushAndRemoveUntil da tela"
  - "Em 'Todos os imoveis' o check aparece quando nenhum imovel esta escolhido, para o estado atual da folha ficar sempre marcado"
  - "Texto 'Nao foi possivel carregar os imoveis.' e rotuloOpcaoDeImovel('codigo — titulo') ficam em apresentacao_contatos.dart; o texto e Claude's Discretion, a confirmar no human-check"

requirements-completed: []

coverage:
  - id: D1
    description: "Cubit filtra por imovel e periodo combinados pelo servidor, limpa cada filtro sem tocar no outro, nao refaz o resumo e descarta resposta de filtro antigo"
    requirement: "CXA-02"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_cubit_test.dart#filtros (D-05, D-18, D-19, D-20)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Chips Imovel e Periodo sempre visiveis, selecionados com codigo/datas e 'x' que limpa so aquele filtro, fora de CaixaSessaoExpirada"
    requirement: "CXA-02"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_screen_test.dart#chips de filtro (D-18)"
        status: pass
      - kind: test
        ref: "test/presentation/apresentacao_contatos_test.dart#filtros da caixa"
        status: pass
    human_judgment: false
  - id: D3
    description: "Folha 'Filtrar por imovel' com Todos os imoveis e codigo — titulo vindos do servidor, escolhido marcado, estados carregando/erro com Tentar de novo"
    requirement: "CXA-02"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_screen_test.dart#folha Filtrar por imovel (D-19, D-23)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Seletor de periodo em pt-BR ligado ao chip Periodo pelo parametro escolherPeriodo (intervalo escolhido aplica, fechar nao faz nada)"
    requirement: "CXA-02"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_screen_test.dart#chip Periodo (D-20)"
        status: pass
      - kind: test
        ref: "test/presentation/seletor_periodo_pt_br_test.dart"
        status: pass
    human_judgment: false
  - id: D5
    description: "401 ao carregar as opcoes do imovel leva a sessao terminada (estado terminal no Cubit)"
    requirement: "CXA-06"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_cubit_test.dart#carregarOpcoesDeImovel (D-19, D-23)"
        status: pass
    human_judgment: false
  - id: D6
    description: "Fluxo ponta a ponta sobre o DI de producao: chip -> folha com contatos_imoveis.json -> GET /api/contatos/?imovel=<id> -> itens de contatos_imovel.json, sem novo resumo"
    requirement: "CXA-02"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_fluxo_test.dart#chip Imovel -> folha"
        status: pass
    human_judgment: false
  - id: D7
    description: "Aspecto dos chips e da folha, o texto de erro das opcoes e o check em 'Todos os imoveis'"
    requirement: "CXA-02"
    verification: []
    human_judgment: true
    rationale: "Escolhas visuais e de texto de Claude's Discretion, confirmadas no human-check do fim da fase"

duration: 40min
completed: 2026-11-23
status: complete
---

# Phase 10 Plan 09: Filtros da caixa por imovel e periodo Summary

**`CaixaContatosCubit` ganha filtro por imovel e por periodo combinados (resolvidos no servidor, sem tocar no numero de sem retorno) e as opcoes do imovel sob demanda; a tela mostra os chips "Imovel" e "Periodo" com limpar, a folha "Filtrar por imovel" com as opcoes do servidor e o seletor de periodo em pt-BR, provado ponta a ponta sobre o DI de producao.**

## Performance

- **Duration:** ~40 min
- **Tasks:** 2 (ambas em TDD: RED e GREEN commitados separados)
- **Files:** 12 (2 criados, 10 modificados, contando os 2 gerados)

## Accomplishments

- `OpcoesDeImovel` (`naoCarregadas/carregando/carregadas/erro`) no `CaixaContatosState`, com o `.freezed.dart` regenerado.
- `CaixaContatosCubit` recebe `ListarImoveisDosContatosUseCase` e ganha `aplicarImovel`, `limparImovel`, `aplicarPeriodo`, `limparPeriodo` (todos passam por `_trocarConsulta`: consulta igual nao chama a API; troca reinicia a lista pelo `_aplicarConsulta` e NUNCA chama `_recarregarResumo`, D-05/D-18) e `carregarOpcoesDeImovel` (guarda de `OpcoesCarregando`, `isClosed`, 401 -> `CaixaSessaoExpirada` terminal, sem `try/catch`).
- `apresentacao_contatos.dart`: `rotuloChipImovel`, `rotuloChipPeriodo` (`01/11/2026 – 22/11/2026`), `rotuloOpcaoDeImovel` e os textos fixos da folha, dos chips e das tooltips.
- `ChipsFiltrosContatos`: dois `InputChip` sempre visiveis; com valor ficam `selected`, com "x" e tooltip; sem valor, sem "x".
- `mostrarFolhaFiltroImovel`: pede as opcoes ao abrir, `showModalBottomSheet` com `BlocProvider<CaixaContatosCubit>.value`, "Todos os imoveis" + "codigo — titulo" na ordem do servidor, check no escolhido, indicador ao carregar e erro com "Tentar de novo".
- `CaixaContatosScreen`: parametro `escolherPeriodo` (padrao `escolherPeriodoComSeletor`) e chips entre a linha do numero e a lista, em todos os estados menos `CaixaSessaoExpirada`.
- Fluxo ponta a ponta: chip "Imovel" -> folha com as opcoes de `contatos_imoveis.json` -> escolher a primeira -> `?imovel=<id>` gravado, itens de `contatos_imovel.json`, chip com o codigo e zero `GET /api/contatos/resumo/` novo.

## Task Commits

1. **Task 1 (RED)** - `0396012` (test)
2. **Task 1 (GREEN)** - `14f26ec` (feat)
3. **Task 2 (RED)** - `83c8899` (test)
4. **Task 2 (GREEN)** - `b3de25c` (feat)

**Plan metadata:** commit `docs(10-09)` (este SUMMARY + STATE + ROADMAP).

## Verification

- `flutter test` dos testes do Cubit (42), da apresentacao, da tela, do seletor e do fluxo ponta a ponta: verdes.
- Gate da onda 9 (D-29): `flutter analyze lib --no-fatal-infos` sai 0, 0 errors/warnings, 46 infos (44 do gate anterior + 2 do `material.dart` dos arquivos novos `chips_filtros_contatos.dart` e `folha_filtro_imovel.dart`), 0 infos fora do `material.dart`. `flutter analyze --no-fatal-infos lib test`: 80 infos, 0 errors/warnings. `flutter test` inteiro: **1468 verdes** (1419 + 49 novos).
- Greps dos `<automated>` das duas tasks: todos passam; gerados limpos depois do commit (`git status --porcelain` vazio para `*.freezed.dart`, `*.g.dart` e `injection.config.dart`).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical] `rotuloOpcaoDeImovel` em `apresentacao_contatos.dart`**
- **Found during:** Task 2
- **Issue:** o plano pede o rotulo "codigo — titulo" na folha, mas so listava `rotuloChipImovel`/`rotuloChipPeriodo`; montar o texto dentro do widget espalharia formatacao fora das funcoes puras da apresentacao (convencao da fase).
- **Fix:** funcao pura `rotuloOpcaoDeImovel(ImovelComContato)` ao lado das demais, com teste.
- **Files modified:** `lib/presentation/contatos/apresentacao_contatos.dart`, `test/presentation/apresentacao_contatos_test.dart`
- **Commit:** `b3de25c`

**Total deviations:** 1 auto-fixed (1 missing critical). **Impact:** nenhum no escopo ou nos contratos do plano.

Detalhe de execucao: `dart run build_runner build -d` reescreveu com LF todos os gerados pre-existentes; foram restaurados com `git checkout --` (D-29), e `lib/di/injection.config.dart` (so o registro do Cubit com o terceiro argumento, que mudou de posicao na ordenacao alfabetica) e `caixa_contatos_state.freezed.dart` ficaram em CRLF. Um `dart format test/presentation` reformatou 15 testes alheios; todos restaurados com `git checkout --` antes do commit. Nenhum arquivo foi deletado pelos commits.

## Issues Encountered

None.

## Known Stubs

None. O toque no item ainda nao faz nada (`aoTocar` nulo) por desenho do plano 10-08: a anotacao do retorno entra no 10-10.

## Threat Flags

None - T-10-22 (o id do imovel so vem das opcoes do servidor e as datas sao formatadas de `DateTime` em `data/`), T-10-23 (a lista de opcoes e do servidor, o app nao a monta), T-10-24 (401 ao abrir as opcoes -> `CaixaSessaoExpirada` terminal, coberto em teste de Cubit; o `pushAndRemoveUntil` da tela remove a folha) e T-10-SC (nenhum pacote novo) conforme o plano.

## Next Phase Readiness

Pronto para o 10-10: o `CaixaContatosCubit` ja tem todos os pedidos de leitura da caixa; falta a anotacao do retorno (D-11, D-14) preenchendo o `aoTocar` dos itens, no mesmo Cubit e no mesmo `group` do fluxo ponta a ponta. O texto de erro da folha, o check em "Todos os imoveis" e o aspecto dos chips ficam para o human-check do fim da fase. Nenhum `git push`.

## Self-Check: PASSED

- Os 12 arquivos existem; commits `0396012`, `14f26ec`, `83c8899` e `b3de25c` presentes na `feat/APP10`; `git rev-list --count a32da04..HEAD` = 4 antes deste SUMMARY.
