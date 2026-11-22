---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 09
subsystem: ui
tags: [flutter, cubit, freezed, material3, acervo, busca, paginacao]

requires:
  - phase: 08-06
    provides: "ImovelAcervo, PaginaAcervo, ConsultaAcervo, SituacaoImovel"
  - phase: 08-08
    provides: "BuscarAcervoUseCase com call(ConsultaAcervo) e seguir(next); falhas tipadas SessaoExpiradaException e SemPermissaoException"
provides:
  - "AcervoCubit (@injectable): carregar, buscar (400 ms, minimo 1 caractere), limparBusca, escolherSituacao, carregarMais, tentarNovamente"
  - "AcervoState + ConteudoAcervo (carregando, vazio, semResultado, erro, sessaoExpirada, carregada)"
  - "CartaoImovelAcervo: cartao compacto em linha com marcas e toque decididos pelo servidor"
  - "ChipsSituacao: ChoiceChips Todas/Disponivel/Reservado/Vendido/Alugado"
  - "AcervoScreen({criarCubit, aoAbrirImovel}): tela Meu acervo com SearchBar, chips, rolagem infinita e rodapes"
affects: [08-10 login cai no acervo e Sair, 08-11 botao Meu acervo na vitrine, 08-12]

actuals:
  tokens: 20000
  tasks: 3
  commits: 3
plan_head_before: 1840f03739b064d6871d652fc97a360c9d10ef67
plan_head_after: 136a2711270b665677e3cb4ab162efe0fd209367

tech-stack:
  added: []
  patterns:
    - "Cubit de lista paginada com busca: versao de consulta (descarta resposta obsoleta) + Timer de 400 ms cancelado em close()"
    - "Cartao so le os booleanos do servidor (naVitrine, meuImovel); sem InkWell quando o servidor nao libera o toque"
    - "Tela com criarCubit opcional para testes de widget sem DI (MockCubit + whenListen)"

key-files:
  created:
    - lib/presentation/acervo/acervo_state.dart
    - lib/presentation/acervo/acervo_state.freezed.dart
    - lib/presentation/acervo/acervo_cubit.dart
    - lib/presentation/acervo/apresentacao_acervo.dart
    - lib/presentation/acervo/widgets/cartao_imovel_acervo.dart
    - lib/presentation/acervo/widgets/chips_situacao.dart
    - lib/presentation/acervo/acervo_screen.dart
    - test/presentation/acervo_cubit_test.dart
    - test/presentation/cartao_imovel_acervo_test.dart
    - test/presentation/chips_situacao_test.dart
    - test/presentation/acervo_screen_test.dart
  modified:
    - lib/di/injection.config.dart

key-decisions:
  - "Busca com minimo de 1 caractere (A7): codigos como DEV-CAMPINAS-14 pedem busca curta; so o atraso de 400 ms e fixo (D-08)"
  - "termoBusca do AcervoState e String nao anulavel com padrao vazio (ConsultaAcervo.busca tambem e String), em vez do String? da vitrine"
  - "Os metodos que a UI chama sem esperar (carregar, buscar, limparBusca) sao void; escolherSituacao, carregarMais e tentarNovamente devolvem Future<void> para os testes poderem aguardar"
  - "Marcas do cartao sao um DecoratedBox+Text privado, nao Chip: marca nao e controle e nao leva ripple"

patterns-established:
  - "Estados freezed com variante propria para sessao terminada; quem navega para o login e a camada de sessao (08-10), nao o Cubit"

requirements-completed: [ACV-01, ACV-02, ACV-04]

coverage:
  - id: D1
    description: "AcervoCubit pagina e busca no servidor: debounce 400 ms, situacao imediata, resposta obsoleta descartada, sem id repetido, falhas por tipo"
    requirement: "ACV-02"
    verification:
      - kind: unit
        ref: "test/presentation/acervo_cubit_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Cartao compacto mostra codigo, titulo, preco e so as marcas situacao e Seu; toque so com naVitrine"
    requirement: "ACV-01"
    verification:
      - kind: automated_ui
        ref: "test/presentation/cartao_imovel_acervo_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Chips de situacao de escolha unica na ordem Todas, Disponivel, Reservado, Vendido, Alugado"
    requirement: "ACV-02"
    verification:
      - kind: automated_ui
        ref: "test/presentation/chips_situacao_test.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "AcervoScreen com SearchBar, chips, lista paginada, rodapes e os estados vazio/sem resultado/erro/sessao terminada"
    requirement: "ACV-04"
    verification:
      - kind: automated_ui
        ref: "test/presentation/acervo_screen_test.dart"
        status: pass
    human_judgment: false
  - id: D5
    description: "Aparencia da tela no aparelho (cartao em linha, chips, SearchBar) em verde e branco"
    verification: []
    human_judgment: true
    rationale: "Adequacao visual nao e afirmada por teste; a tela ainda nao e alcancavel pelo app (08-10 e 08-11 ligam a entrada)"

duration: 9min
completed: 2026-11-21
status: complete
---

# Phase 8 Plan 09: Tela Meu acervo Summary

**Tela "Meu acervo" em Material 3 sobre um AcervoCubit freezed: busca de 400 ms, chips de situacao, rolagem infinita sem repetidos e cartao compacto cujo toque e marcas vem do servidor.**

## Performance

- **Duration:** 9 min
- **Started:** 2026-11-21T14:50:23Z
- **Completed:** 2026-11-21T14:59:00Z
- **Tasks:** 3
- **Files modified:** 12 (11 criados, 1 gerado modificado)

## Accomplishments
- `AcervoCubit` combina o debounce/versao do `VitrineCubit` com a paginacao do `VitrineAnuncianteCubit`; decide so pelo tipo da falha (`SessaoExpiradaException` vira o estado `sessaoExpirada`, o resto vira `erro`) e nunca ordena nem filtra no aparelho.
- `CartaoImovelAcervo` e `ChipsSituacao` (D-05, D-06, D-07, D-09): miniatura 96 dp, titulo ate 2 linhas, preco por `linhasDePrecoPorFinalidade`, marcas so de situacao e "Seu"; sem `naVitrine` o cartao nao tem `InkWell`.
- `AcervoScreen` (D-08, D-10): `SearchBar` "Buscar por codigo ou titulo" com "Limpar busca", chips ligados ao Cubit, `ListView` com rolagem a 90% e pagina extra quando a primeira nao enche a tela, `RodapePaginacaoLista` no fim e seis estados distintos.

## Task Commits

1. **Task 1: AcervoCubit com busca de 400 ms, situacao, paginacao e sessao terminada** - `3c74f79` (feat)
2. **Task 2: Cartao compacto do acervo e chips de situacao** - `6d5da8e` (feat)
3. **Task 3: Tela Meu acervo** - `136a271` (feat)

**Plan metadata:** commit docs(08-09) logo apos este arquivo.

_Nota: o plano e `type: execute` com `tdd="true"` por tarefa; testes e implementacao de cada tarefa foram escritos juntos e commitados num unico `feat` por tarefa (mesma pratica dos planos 08-01 a 08-08), sem commits `test` separados._

## Files Created/Modified
- `lib/presentation/acervo/acervo_state.dart` (+ `.freezed.dart`) - `AcervoState` e `ConteudoAcervo` com as seis variantes
- `lib/presentation/acervo/acervo_cubit.dart` - Cubit da busca, situacao e paginacao
- `lib/presentation/acervo/apresentacao_acervo.dart` - rotulos de situacao, opcoes dos chips e textos da tela
- `lib/presentation/acervo/widgets/cartao_imovel_acervo.dart` - cartao em linha
- `lib/presentation/acervo/widgets/chips_situacao.dart` - chips de escolha unica
- `lib/presentation/acervo/acervo_screen.dart` - tela
- `lib/di/injection.config.dart` - registro do `AcervoCubit` (so as 4 linhas novas)
- `test/presentation/acervo_cubit_test.dart` (24 testes), `cartao_imovel_acervo_test.dart`, `chips_situacao_test.dart`, `acervo_screen_test.dart` (17 testes)

## Decisions Made
Ver `key-decisions` no cabecalho. Em resumo: busca a partir de 1 caractere; `termoBusca` como `String` vazia em vez de `null`; metodos `void` onde a UI nao espera e `Future<void>` onde o teste precisa aguardar; marcas do cartao sem `Chip` para nao ter interacao.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Substituicao do caminho do repositorio web**
- **Found during:** leitura do plano
- **Issue:** o plano cita o repo web em `C:/Users/allys/OneDrive/...`, que nao existe; este plano nao toca no repo web, entao nenhum arquivo ou comando foi afetado
- **Fix:** nenhuma acao necessaria (registro conforme `orchestrator_notes`)

**2. [Rule 1 - Bug de teste] Preco com espaco inseparavel**
- **Found during:** Task 2
- **Issue:** `formatarPrecoBrl` usa NBSP depois de `R$`; os `find.text` do teste do cartao usavam espaco comum
- **Fix:** os esperados passaram a usar `R\$\u00A0450.000` (mesma convencao de `apresentacao_imovel_test.dart`); sem mudanca no codigo de producao
- **Files modified:** test/presentation/cartao_imovel_acervo_test.dart
- **Committed in:** 6d5da8e

---

**Total deviations:** 1 auto-fixed (1 teste), 1 registro sem acao
**Impact on plan:** nenhum; sem scope creep.

## Issues Encountered
- `flutter analyze lib` nao devolve "No issues found!" (criterio de aceite literal da Task 3): ha 33 itens, todos `info` `deprecated_member_use` do proprio `import 'package:flutter/material.dart'` (Flutter 3.47) — a baseline ja tinha ~30. Os tres arquivos de widget novos (`cartao_imovel_acervo.dart`, `chips_situacao.dart`, `acervo_screen.dart`) somam 3 itens do mesmo tipo, inevitaveis enquanto o projeto usar `material.dart` (exigido pelo CLAUDE.md). Nenhum aviso ou erro de outro tipo. Nao corrigido, fora de escopo.
- `build_runner` deixou ~30 gerados so-CRLF modificados; confirmado `git diff --ignore-space-at-eol` vazio e restaurados por lista explicita. Apenas `injection.config.dart` (4 linhas do `AcervoCubit`) e `acervo_state.freezed.dart` foram commitados.

## User Setup Required
None - no external service configuration required.

## Known Stubs
Nenhum. A tela ainda nao e alcancavel pelo app (o login cai nela no 08-10 e o botao da vitrine no 08-11); isso e intencional e esta no objetivo do plano.

## Threat Flags
Nenhum: nenhuma superficie nova de rede, autenticacao ou arquivo; mitigacoes T-08-34 (toque so com `naVitrine`), T-08-35 (widgets so leem booleanos, teste de ausencia de `InkWell`) e T-08-36 (debounce de 400 ms e versao de consulta) aplicadas e testadas. T-08-SC: nenhum pacote novo.

## Next Phase Readiness
- 08-10 pode fazer o login cair em `AcervoScreen`, acrescentar o Sair na `AppBar` e reagir a `AcervoSessaoExpirada` voltando ao login.
- 08-11 liga o botao "Meu acervo" da vitrine a `AcervoScreen`.
- Verificacao: `flutter test` = 991 testes verdes (930 antes + 61 novos).

## Self-Check: PASSED

Arquivos criados conferidos em disco, commits `3c74f79`, `6d5da8e` e `136a271` presentes no historico da branch, criterios de aceite das tres tarefas reexecutados (testes das quatro suites e `flutter test` inteiro verdes; `flutter analyze lib` sem nada alem do `deprecated_member_use` ja existente).

---
*Phase: 08-login-e-rea-do-corretor-o-acervo*
*Completed: 2026-11-21*
