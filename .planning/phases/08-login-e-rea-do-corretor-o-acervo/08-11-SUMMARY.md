---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 11
subsystem: ui
tags: [flutter, cubit, freezed, material3, sessao, navegacao, injectable]

requires:
  - phase: 08-07
    provides: "SessaoCubit (lazySingleton; carregar, marcarAnonima) e ObterPapelUseCase"
  - phase: 08-09
    provides: "AcervoScreen"
  - phase: 08-10
    provides: "LoginScreen(aviso), AvisoAreaScreen, avisoSessaoTerminou e confirmarESair"
provides:
  - "EntradaAreaCubit (@injectable) e EntradaAreaState (carregando, papel, erro, sessaoExpirada)"
  - "EntradaAreaScreen: pergunta o papel ao servidor e substitui a rota por acervo, aviso ou login com aviso"
  - "BotaoSessaoTopo: Entrar (anonima), Meu acervo (autenticada), espaco sem rotulo em verificando"
  - "Slot opcional acaoSessao em VitrineScreen, CidadeSelecaoScreen e PrimingScreen"
  - "ImoveisAquiApp como StatefulWidget que carrega o SessaoCubit sem await e o provê acima do MaterialApp"
affects: [08-12]

actuals:
  tokens: 40000
  tasks: 2
  commits: 2
plan_head_before: 7da81b01813e7ae21e93a52d42479ba89e955a2d
plan_head_after: 9c63e28d77307dcbec93eae7293a2cf991f05b16

tech-stack:
  added: []
  patterns:
    - "Slot opcional de Widget repassado pelas telas (padrao do aoAbrirImovel) para a vitrine nao depender da sessao"
    - "Rota de entrada que pergunta ao servidor e se substitui por pushReplacement, entao o voltar nunca reabre a entrada"
    - "SessaoCubit carregado sem await no initState da raiz: a abertura nunca espera o armazenamento seguro"

key-files:
  created:
    - lib/presentation/sessao/entrada_area_state.dart
    - lib/presentation/sessao/entrada_area_state.freezed.dart
    - lib/presentation/sessao/entrada_area_cubit.dart
    - lib/presentation/sessao/entrada_area_screen.dart
    - lib/presentation/sessao/botao_sessao_topo.dart
    - test/presentation/entrada_area_cubit_test.dart
    - test/presentation/entrada_area_screen_test.dart
    - test/presentation/botao_sessao_topo_test.dart
  modified:
    - lib/presentation/vitrine/vitrine_screen.dart
    - lib/presentation/cidade_selecao/cidade_selecao_screen.dart
    - lib/presentation/priming/priming_screen.dart
    - lib/main.dart
    - lib/di/injection.config.dart
    - test/main_launch_routing_test.dart

key-decisions:
  - "Sem acaoSessao a VitrineScreen mantem o SeletorCidadeTopo como filho direto da Column (so com a acao ele entra numa Row com Expanded), para o teste antigo que inspeciona os filhos da Column passar sem mudanca"
  - "O botao do topo mostra so o rotulo pela sessao guardada; quem pergunta o papel ao servidor e a EntradaAreaScreen"
  - "tentarNovamente do EntradaAreaCubit nao faz nada enquanto ja esta em carregando (sem pedido duplo num toque duplo)"

patterns-established:
  - "Teste de AC-6: carregar() do SessaoCubit falso devolve um Future que nunca termina e a vitrine ainda assim aparece"

requirements-completed: [AUTH-04, AUTH-05]

coverage:
  - id: D1
    description: "EntradaAreaCubit emite papel(corretor/gestor/administrador), sessaoExpirada para SessaoExpiradaException e erro para o resto; tentarNovamente refaz sem pedido duplo"
    requirement: "AUTH-05"
    verification:
      - kind: unit
        ref: "test/presentation/entrada_area_cubit_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "EntradaAreaScreen: indicador, erro com Tentar de novo, corretor ao acervo, gestor/administrador ao aviso, 401 marca anonima e abre o login com aviso; o voltar leva a rota anterior"
    requirement: "AUTH-04"
    verification:
      - kind: automated_ui
        ref: "test/presentation/entrada_area_screen_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "BotaoSessaoTopo: verificando sem rotulo, anonima Entrar (abre o login), autenticada Meu acervo (abre a entrada)"
    requirement: "AUTH-04"
    verification:
      - kind: automated_ui
        ref: "test/presentation/botao_sessao_topo_test.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "AC-6: o app abre direto na vitrine mesmo com a leitura da sessao nunca terminando; carregar() chamado uma vez; Entrar/Meu acervo na linha do seletor de cidade"
    requirement: "AUTH-04"
    verification:
      - kind: automated_ui
        ref: "test/main_launch_routing_test.dart"
        status: pass
    human_judgment: false
  - id: D5
    description: "Aparencia do botao no topo da vitrine em telas estreitas (360 dp) e fluxo completo no aparelho"
    verification: []
    human_judgment: true
    rationale: "Adequacao visual do botao ao lado do seletor de cidade e o fluxo ponta a ponta no aparelho nao sao afirmados por teste de widget."

duration: 22min
completed: 2026-11-21
status: complete
---

# Phase 8 Plan 11: Botao do topo e rota Meu acervo Summary

**Entrada pelo app: botao Entrar/Meu acervo no topo da vitrine por slot opcional, SessaoCubit provido acima do MaterialApp sem atrasar a abertura, e rota Meu acervo que pergunta o papel ao servidor e volta ao login com aviso num 401.**

## Performance

- **Duration:** 22 min
- **Tasks:** 2
- **Files modified:** 14 (8 criados, 6 modificados)

## Accomplishments
- `EntradaAreaScreen` pergunta o papel a cada toque em "Meu acervo" (nunca do aparelho) e se substitui por `pushReplacement`: corretor vai ao `AcervoScreen`, gestor/administrador ao `AvisoAreaScreen`, e o "voltar" leva a vitrine (T-08-42, T-08-43).
- Um 401 nessa pergunta (`SessaoExpiradaException`) chama `marcarAnonima()` e abre `LoginScreen(aviso: avisoSessaoTerminou)` no lugar da entrada; o botao do topo volta para "Entrar" (T-08-41).
- `ImoveisAquiApp` virou `StatefulWidget`: `initState` pega o `SessaoCubit` do `getIt`, chama `carregar()` sem `await` e provê o singleton acima do `MaterialApp` com `BlocProvider.value` — `AcervoScreen` e `confirmarESair` ja conseguem `context.read` em producao (T-08-44, AC-6).
- `BotaoSessaoTopo` entra pelo slot `acaoSessao` (`PrimingScreen` → `CidadeSelecaoScreen` → `VitrineScreen`); os testes antigos dessas telas nao mudaram.

## Task Commits

1. **Task 1: Meu acervo pergunta o papel e roteia; 401 volta ao login com aviso** - `b159b4c` (feat)
2. **Task 2: Botao Entrar/Meu acervo e SessaoCubit acima do MaterialApp** - `9c63e28` (feat)

**Plan metadata:** commit docs(08-11) logo apos este arquivo.

_Nota: o plano e `tdd="true"` por tarefa; testes e implementacao de cada tarefa foram commitados juntos num unico `feat` por tarefa (mesma pratica dos planos anteriores)._

## Files Created/Modified
- `lib/presentation/sessao/entrada_area_state.dart` (+ `.freezed.dart`), `entrada_area_cubit.dart`, `entrada_area_screen.dart` - rota de "Meu acervo"
- `lib/presentation/sessao/botao_sessao_topo.dart` - botao do topo
- `lib/presentation/vitrine/vitrine_screen.dart`, `cidade_selecao/cidade_selecao_screen.dart`, `priming/priming_screen.dart` - slot `acaoSessao`
- `lib/main.dart` - provimento e carga do `SessaoCubit`, botao passado as duas telas iniciais
- `lib/di/injection.config.dart` - registro do `EntradaAreaCubit` (so as linhas novas)
- `test/presentation/entrada_area_cubit_test.dart` (10), `entrada_area_screen_test.dart` (6), `botao_sessao_topo_test.dart` (4), `main_launch_routing_test.dart` (+4 casos e `SessaoCubit` falso no `setUp`)

## Decisions Made
Ver `key-decisions` no cabecalho. A principal: sem `acaoSessao` a `VitrineScreen` nao ganha `Row` nenhuma — o seletor segue filho direto da `Column`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `Row` incondicional quebrava um teste antigo da vitrine**
- **Found during:** Task 2 (verify)
- **Issue:** o plano manda envolver o `SeletorCidadeTopo` numa `Row` sempre; o teste `vitrine_screen_test.dart` ("SearchBar aparece abaixo do SeletorCidadeTopo") procura o seletor entre os filhos diretos da `Column` e falhava, contra o criterio "testes antigos nao mudam".
- **Fix:** `Row` com `Expanded` so quando `acaoSessao` existe; sem ela o seletor continua filho direto da `Column`.
- **Files modified:** `lib/presentation/vitrine/vitrine_screen.dart`
- **Commit:** `9c63e28`

**2. [Rule 3 - Blocking] `flutter analyze lib` nao fica "No issues found!"**
- **Issue:** baseline de 36 `info` `deprecated_member_use` (`package:flutter/material.dart` esta deprecated no Flutter 3.47). Os 2 arquivos novos com `material.dart` (`entrada_area_screen`, `botao_sessao_topo`) somam 2 itens do MESMO tipo (36 para 38); nenhum outro tipo de aviso foi adicionado.
- **Fix:** nenhum, conforme orientacao do orquestrador.

**3. [Rule 3 - Blocking] `pumpAndSettle` nao assenta com progresso em tela**
- Os testes de tela usam `pump` com duracoes fixas; depois de um `pop` sao necessarios dois `pump` (um para iniciar, outro de 500 ms para a rota sair da arvore).

**Total deviations:** 3 auto-fixed, 0 afetam o escopo.

## Issues Encountered
- Um comando Bash com varios heredocs falhou no parse do shell sem escrever nada; os testes foram criados com a ferramenta Write.
- `dart format` nos arquivos tocados reformatou trechos antigos de `main_launch_routing_test.dart` e `entrada_area_cubit_test.dart` (estilo diferente do formatador do ambiente); em `vitrine_screen.dart` o ruido foi desfeito por reaplicar a edicao, nos demais o diff de formatacao ficou pequeno.
- `build_runner` marcou 30 arquivos gerados como modificados so por CRLF; conferido com `git diff --ignore-space-at-eol` (so `injection.config.dart` tinha conteudo novo) e restaurados por lista explicita.

## Known Stubs
None. O espaco sem rotulo em `verificando` e intencional (D-C).

## Threat Flags
None. Nenhum endpoint, caminho de autenticacao ou acesso a arquivo novo alem do mapeado em T-08-41..T-08-44.

## Next Phase Readiness
- O circuito da sessao esta fechado na interface: Entrar, login, acervo, Sair e 401 sao alcancaveis pelo app. Falta o 08-12 (fechamento da fase). Conferir no aparelho a aparencia do botao ao lado do seletor de cidade em 360 dp.

## Self-Check: PASSED
- Arquivos criados conferidos no disco; commits `b159b4c` e `9c63e28` presentes em `HEAD`.
- `flutter test` completo: 1046 testes passando (1023 + 23 novos); `flutter analyze lib`: 38 `info` `deprecated_member_use` (36 de baseline + 2 imports de `material.dart` dos arquivos novos).
