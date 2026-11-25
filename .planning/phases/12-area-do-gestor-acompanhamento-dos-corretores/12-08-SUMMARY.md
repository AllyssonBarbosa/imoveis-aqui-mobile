---
phase: 12-area-do-gestor-acompanhamento-dos-corretores
plan: 08
subsystem: presentation
tags: [widgets, area-gestor, material3, bloc-selector, tdd, sessao-401]

requires:
  - phase: 12
    provides: "12-07: AreaGestorCubit, AreaGestorState/EstadoSecao e apresentacao_area_gestor.dart; 12-05: Models do wire; APP-10: seletor de período; sessão: voltarAoLoginComSessaoTerminada e confirmarESair"
provides:
  - "MolduraSecao<T>: Card com título, cabeçalho opcional e o switch carregando/falha/carregada"
  - "SecaoTotais, SecaoAcervoCorretores, SecaoContatosCorretores e SecaoMudancas (só apresentam, sem toque nas linhas)"
  - "AreaGestorScreen({criarCubit, escolherPeriodo}): uma tela com as 4 seções na ordem de D-06, Sair na AppBar e 401 para o login"
affects: [12-09]

# Medido: git rev-list --count ${PLAN_HEAD_BEFORE}..HEAD (ledger gsd-plan-head-before-12-08), antes do commit do SUMMARY
commits: 4
plan_head_before: 37ed76ab341aa4bd9892dfe58d3c53455af6fc07
plan_head_after: 3395e10f508337a9aea367b745103b91523a22dd

estimate_actuals_note: "tokens = chars/4 sobre o diff do plano (~52 mil chars, 1458 linhas inseridas em 8 arquivos, nenhum gerado)"
actuals:
  tokens: 13000
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Moldura genérica por seção (MolduraSecao<T>) com switch exaustivo sobre EstadoSecao<T>: carregando, falha com retry e conteúdo"
    - "Um BlocSelector por seção na tela, para uma seção não reconstruir as outras (os contatos selecionam o par seção + período)"
    - "Cabeçalho da moldura visível em qualquer estado, para o chip do período sobreviver à falha da seção de contatos"

key-files:
  created:
    - lib/presentation/area_gestor/widgets/moldura_secao.dart
    - lib/presentation/area_gestor/widgets/secao_totais.dart
    - lib/presentation/area_gestor/widgets/secao_acervo_corretores.dart
    - lib/presentation/area_gestor/widgets/secao_contatos_corretores.dart
    - lib/presentation/area_gestor/widgets/secao_mudancas.dart
    - lib/presentation/area_gestor/area_gestor_screen.dart
    - test/presentation/secoes_area_gestor_test.dart
    - test/presentation/area_gestor_screen_test.dart
  modified: []

key-decisions:
  - "A linha da empresa usa textoLinhaDaEmpresa quando daEmpresa; o nome que o servidor mandou nela nunca chega ao widget (D-17, T-12-20)"
  - "O título de SecaoMudancas leva o N só quando a seção está carregada; carregando ou em falha usa tituloSecaoMudancas(null)"
  - "A tela não expõe um helper de abertura (abrirAreaGestor): ligar a tela ao login e ao botão do topo é o 12-09"

patterns-established:
  - "Seção de relatório: Card + título + estado da seção; widgets StatelessWidget sem rede, sem Cubit e sem conta"

requirements-completed: [GES-01, GES-02, GES-03, GES-04, GES-05, GES-06]

coverage:
  - id: D1
    description: "MolduraSecao: carregando, falha (403 e indisponível) com Tentar de novo uma vez, carregada e cabeçalho nos três estados"
    requirement: "GES-06"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/secoes_area_gestor_test.dart#MolduraSecao (6 testes)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Totais da empresa em grade 2x2 na ordem Disponível, Reservado, Vendido, Alugado, com o total do servidor"
    requirement: "GES-01"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/secoes_area_gestor_test.dart#SecaoTotais (fixture relatorio_acervo.json)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Acervo por corretor: nome, (desativado), singular/plural/zero, total do servidor, vazio e linhas sem toque"
    requirement: "GES-02"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/secoes_area_gestor_test.dart#SecaoAcervoCorretores (fixture relatorio_acervo_por_corretor.json)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Contatos por corretor: chip Período com e sem valor, linha do período, linha da empresa com texto fixo, rodapé do servidor, chip e linha visíveis em falha"
    requirement: "GES-03, GES-04"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/secoes_area_gestor_test.dart#SecaoContatosCorretores (fixture relatorio_contatos.json)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Mudanças de situação: título com N do servidor, item com código, de-para, quando e quem, observação opcional, vazio e itens sem toque"
    requirement: "GES-05"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/secoes_area_gestor_test.dart#SecaoMudancas (fixture relatorio_mudancas.json)"
        status: pass
    human_judgment: false
  - id: D6
    description: "AreaGestorScreen: carregar() uma vez, título e Sair, sem abas, ordem das seções, falha isolada com retry só da seção, período (aplicar, nulo, limpar), diálogo de Sair e 401 para o login com a vitrine embaixo"
    requirement: "GES-06"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/area_gestor_screen_test.dart (9 testes, Cubit falso)"
        status: pass
    human_judgment: false
  - id: D7
    description: "A tela lê bem em aparelho real: grade 2x2, cada seção num Card, textos e espaçamento"
    verification: []
    human_judgment: true
    rationale: "Aparência e legibilidade não são asseridas por teste; fica para o human-check do 12-09, que liga a tela ao login e ao botão do topo"

# Metrics
duration: ~7 min
completed: 2026-11-25
status: complete
---

# Phase 12 Plan 08: Tela da Área do gestor Summary

**`AreaGestorScreen` numa tela só, com rolagem, em Material 3 verde e branco: Totais, Acervo, Contatos (chip Período da APP-10) e Mudanças nesta ordem, cada seção num `Card` com carregando e falha próprios e "Tentar de novo" só dela, Sair na `AppBar` e o 401 levando ao login com a vitrine embaixo, tudo sem regra, conta ou rede no widget.**

## Performance

- **Duration:** ~7 min
- **Started:** 2026-11-25T21:36:00Z (aproximado)
- **Completed:** 2026-11-25T21:43:00Z (gate; o SUMMARY e o STATE vêm depois)
- **Tasks:** 2
- **Files modified:** 8 (todos criados)

## Accomplishments

- `MolduraSecao<T>`: `Card` com título em `titleMedium`, `cabecalho` opcional e `switch` exaustivo sobre `EstadoSecao<T>`; a falha mostra o texto fixo de `textoDaFalha` e o `TextButton` "Tentar de novo" (D-07, D-23).
- Quatro seções `StatelessWidget`: `SecaoTotais` (grade 2x2 com `surfaceContainerHighest` e o `total` do servidor), `SecaoAcervoCorretores`, `SecaoContatosCorretores` (`InputChip` com `selected`, "x" só com valor e a linha "Todo o período."/"Período: ... a ...", ambos no cabeçalho para sobreviver à falha) e `SecaoMudancas` (molde do histórico da APP-09). Nenhum tratador de toque nas linhas (D-08), nenhuma cor fixa, nenhum `.fold`/`.reduce`.
- `AreaGestorScreen({criarCubit, escolherPeriodo})`: `BlocProvider` com `carregar()`, `BlocListener` de `sessaoExpirada` com `voltarAoLoginComSessaoTerminada`, `AppBar` com título e Sair por `confirmarESair`, `SingleChildScrollView` com 4 `BlocSelector`; `_aoTocarPeriodo` lê o Cubit antes do `await` e confere `mounted`. Sem abas, sem `NavigationBar` e sem puxar para atualizar.
- 30 testes novos (21 das seções, 9 da tela), montados a partir das fixtures reais pelos Models do 12-05. Gate da onda 8 (D-30): `flutter test` inteiro com **1918 testes, All tests passed** (1888 ao fim do 12-07 + 30 deste plano); `flutter analyze lib --no-fatal-infos` sem erro nem warning e sem nenhum info que não seja o `deprecated_member_use` do import de `material.dart` (59 infos; eram 53, os 6 a mais são os 6 arquivos novos de `lib/` que importam `material.dart`, o mesmo baseline).

## Task Commits

1. **Task 1 RED: teste dos widgets das 4 seções** - `017b63b` (test)
2. **Task 1 GREEN: widgets das 4 seções** - `948922e` (feat)
3. **Task 2 RED: teste da AreaGestorScreen** - `56fdcc6` (test)
4. **Task 2 GREEN: AreaGestorScreen** - `3395e10` (feat)

**Plan metadata:** commit `docs(12-08)` (este SUMMARY, STATE e ROADMAP)

## TDD Gate Compliance

- **RED (`017b63b`, `56fdcc6`):** nos dois casos `flutter test <arquivo>` terminou com "Some tests failed" por falha de carga do arquivo ("Failed to load": os widgets e `area_gestor_screen.dart` ainda não existiam), o RED que o plano pede. Avaliação semântica: o alvo falhou pelo motivo planejado (símbolos inexistentes), não por sintaxe nem fixture. O `gsd_run check tdd-red-evidence` não foi usado: `flutter test` não emite nenhum dos formatos que o classificador aceita (mesmo critério do 12-03, 12-04 e 12-07).
- **GREEN (`948922e`, `3395e10`):** os testes passam (Task 1: 21 + os da apresentação; Task 2: tela + seções + Cubit + caixa de contatos, 94 no total do comando).
- **REFACTOR:** nenhum.

## Files Created/Modified

- `lib/presentation/area_gestor/widgets/moldura_secao.dart` - moldura comum das seções
- `lib/presentation/area_gestor/widgets/secao_totais.dart`, `secao_acervo_corretores.dart`, `secao_contatos_corretores.dart`, `secao_mudancas.dart` - as 4 seções
- `lib/presentation/area_gestor/area_gestor_screen.dart` - a tela
- `test/presentation/secoes_area_gestor_test.dart`, `test/presentation/area_gestor_screen_test.dart` - testes

## Decisions Made

- A linha da empresa usa `textoLinhaDaEmpresa`; o nome do servidor nela nunca é lido pelo widget (T-12-20).
- O título de `SecaoMudancas` só leva o N do servidor quando a seção está carregada.
- A tela não traz um helper `abrirAreaGestor`: ligar a tela ao login e ao botão do topo é do 12-09.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Asserção de teste com texto repetido na fixture de mudanças**
- **Found during:** Task 1 (primeira rodada do GREEN)
- **Issue:** as duas mudanças de `relatorio_mudancas.json` têm o mesmo minuto e o mesmo autor, então "quando e quem" aparece duas vezes e `findsOneWidget` falhava (erro do teste, não do widget).
- **Fix:** `findsWidgets` nessa linha, com comentário explicando.
- **Files modified:** `test/presentation/secoes_area_gestor_test.dart`
- **Committed in:** `948922e`

**2. [Rule 1 - Bug] Teste do Sair sem `SessaoCubit` no contexto**
- **Found during:** Task 2 (primeira rodada do GREEN)
- **Issue:** `confirmarESair` faz `context.read<SessaoCubit>()`; o teste do Sair montava a tela sem o provider e levantava `ProviderNotFoundException`.
- **Fix:** `montar` envolve a tela num `BlocProvider<SessaoCubit>.value` com um `SessaoCubit` falso.
- **Files modified:** `test/presentation/area_gestor_screen_test.dart`
- **Committed in:** `3395e10`

---

**Total deviations:** 2 auto-fixed (2 bugs de teste, apanhados antes do commit do GREEN)
**Impact on plan:** nenhum; sem mudança de escopo nem de código de produção.

## Issues Encountered

None.

## Known Stubs

Nenhum. Os widgets só apresentam o que o Cubit entrega; a tela ainda não tem ponto de entrada no app (botão do topo e login), o que é o 12-09 por desenho.

## Threat Flags

Nenhum. T-12-20 (texto do servidor na tela) mitigado por `textoLinhaDaEmpresa`/`textoDaFalha` e coberto por teste; T-12-21 (toque abrindo outra tela) por ausência de tratador de toque, gate de grep e `NavigatorObserver`; T-12-22 (tela logada após o 401) pelo teste do 401 com a rota "Vitrine" embaixo; T-12-SC sem pacote novo.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- O 12-09 liga `AreaGestorScreen` ao login (gestor entra na área) e ao botão do topo, e faz o human-check da aparência (grade 2x2, `Card`s) e do texto do 403 com "Tentar de novo".
- Sem bloqueios.

## Self-Check: PASSED

- Arquivos: os 5 widgets, a tela e os 2 testes existem.
- Commits `017b63b`, `948922e`, `56fdcc6` e `3395e10` são ancestrais de `HEAD`.
- Verificação do plano: greps das duas tasks ok, analyze sem erro, warning nem info novo além do import de `material.dart`, `flutter test` inteiro com 1918 testes verdes, nenhum gerado pendente (nenhum `build_runner` foi necessário).

---
*Phase: 12-area-do-gestor-acompanhamento-dos-corretores*
*Completed: 2026-11-25*
