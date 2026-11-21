---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 10
subsystem: ui
tags: [flutter, cubit, freezed, material3, login, sessao, autofill]

requires:
  - phase: 08-05
    provides: "enum Papel e falhas tipadas do login (CredenciaisInvalidas, LimiteTentativas, FalhaDeConexao, SemPermissao)"
  - phase: 08-07
    provides: "EntrarUseCase e SessaoCubit (marcarAutenticada, marcarAnonima, sair que sempre termina anonimo)"
  - phase: 08-09
    provides: "AcervoScreen({criarCubit, aoAbrirImovel}) e o estado ConteudoAcervo.sessaoExpirada"
provides:
  - "apresentacao_login.dart: textos fixos do login, textoLimiteDeTentativas e mensagemDeFalhaDoLogin por tipo de falha"
  - "LoginCubit (@injectable) e LoginState (editando, enviando, falha, entrou(papel)) sem e-mail nem senha"
  - "LoginScreen({aviso, criarCubit}) com AutofillGroup, mostrar/ocultar senha e roteamento por papel via pushReplacement"
  - "AvisoAreaScreen (gestor/administrador) e confirmarESair (dialogo Sair da conta? -> SessaoCubit.sair -> popUntil primeira rota)"
  - "AcervoScreen com acao Sair na AppBar e ouvinte de sessaoExpirada que volta ao login com aviso"
affects: [08-11 botao do topo da vitrine e rota Meu acervo, 08-12]

actuals:
  tokens: 36000
  tasks: 2
  commits: 2
plan_head_before: a72133d90d2512bcae4cd3120cdc1151fcacec51
plan_head_after: ff50ce11047c4c7c6ec8cd116125526da94815b5

tech-stack:
  added: []
  patterns:
    - "Mensagem de falha escolhida so pelo tipo da excecao de dominio (switch de padroes), nunca pelo texto do servidor"
    - "Estado do login sem credenciais: e-mail e senha vivem so nos controladores da tela e seguem direto ao use case"
    - "confirmarESair captura Navigator e SessaoCubit antes do await, entao nao depende de a tela de origem continuar montada"
    - "401 do acervo: marcarAnonima + pushAndRemoveUntil(LoginScreen, isFirst) deixa so a vitrine na pilha"

key-files:
  created:
    - lib/presentation/login/apresentacao_login.dart
    - lib/presentation/login/login_state.dart
    - lib/presentation/login/login_state.freezed.dart
    - lib/presentation/login/login_cubit.dart
    - lib/presentation/login/login_screen.dart
    - lib/presentation/sessao/dialogo_sair.dart
    - lib/presentation/sessao/aviso_area_screen.dart
    - test/presentation/apresentacao_login_test.dart
    - test/presentation/login_cubit_test.dart
    - test/presentation/login_screen_test.dart
    - test/presentation/aviso_area_screen_test.dart
  modified:
    - lib/presentation/acervo/acervo_screen.dart
    - lib/di/injection.config.dart
    - test/presentation/acervo_screen_test.dart

key-decisions:
  - "O e-mail segue com trim para o use case (teclado movel costuma deixar espaco no fim); a senha nunca passa por trim"
  - "confirmarESair captura o NavigatorState e o SessaoCubit antes do showDialog em vez de checar context.mounted depois; o popUntil confere navegador.mounted"
  - "Nos testes do login e do acervo a sessao e provida acima do MaterialApp e o destino usa o getIt com Cubit falso (registerFactory + getIt.reset no tearDown)"

patterns-established:
  - "Tela com criarCubit opcional e MockCubit + whenListen; rota inicial falsa que empurra a tela para provar o botao voltar"

requirements-completed: [AUTH-01, AUTH-02, AUTH-03, AUTH-05]

coverage:
  - id: D1
    description: "Mensagens fixas do login por tipo de falha e minutos do Retry-After arredondados para cima (minimo 1, singular)"
    requirement: "AUTH-03"
    verification:
      - kind: unit
        ref: "test/presentation/apresentacao_login_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "LoginCubit emite enviando e depois entrou(papel) ou falha(mensagem do app), ignora envio duplo e nao emite depois de fechado"
    requirement: "AUTH-01"
    verification:
      - kind: unit
        ref: "test/presentation/login_cubit_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "LoginScreen: campos com autofill, validacao de vazio, botao desabilitado em enviando, falha e aviso na tela"
    requirement: "AUTH-01"
    verification:
      - kind: automated_ui
        ref: "test/presentation/login_screen_test.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "Roteamento por papel apos o login: corretor ao acervo, gestor e administrador ao aviso, sem voltar ao login"
    requirement: "AUTH-05"
    verification:
      - kind: automated_ui
        ref: "test/presentation/login_screen_test.dart"
        status: pass
    human_judgment: false
  - id: D5
    description: "Sair com confirmacao na tela de aviso e na AppBar do acervo, terminando na vitrine com sessao anonima"
    requirement: "AUTH-02"
    verification:
      - kind: automated_ui
        ref: "test/presentation/aviso_area_screen_test.dart"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/acervo_screen_test.dart"
        status: pass
    human_judgment: false
  - id: D6
    description: "401 na lista do acervo deixa a sessao anonima e abre o login com o aviso, so com a vitrine embaixo"
    requirement: "AUTH-05"
    verification:
      - kind: automated_ui
        ref: "test/presentation/acervo_screen_test.dart"
        status: pass
    human_judgment: false
  - id: D7
    description: "Aparencia do login, do aviso e do dialogo no aparelho, e se o gerenciador de senhas oferece salvar a senha"
    verification: []
    human_judgment: true
    rationale: "Adequacao visual e o oferecimento de salvar a senha (TextInput.finishAutofillContext) dependem do aparelho; nao sao afirmados por teste. As telas ainda nao sao alcancaveis pelo app (08-11 liga o botao do topo)."

duration: 17min
completed: 2026-11-21
status: complete
---

# Phase 8 Plan 10: Login, aviso do gestor e Sair Summary

**Entrada do corretor no app: tela de login com textos fixos do app, roteamento por papel (corretor ao acervo, gestor/administrador ao aviso), Sair com confirmacao e volta ao login quando a lista do acervo da 401.**

## Performance

- **Duration:** 17 min
- **Started:** 2026-11-21T14:50:00Z (aprox.)
- **Completed:** 2026-11-21T15:08:00Z
- **Tasks:** 2
- **Files modified:** 14 (11 criados, 3 modificados)

## Accomplishments
- `mensagemDeFalhaDoLogin` decide so pelo tipo da falha: credencial invalida tem texto fixo, 429 mostra minutos do `Retry-After` (teto, minimo 1, "1 minuto" no singular, "alguns minutos" sem cabecalho), todo o resto vira "Nao foi possivel entrar agora" — nunca o texto do servidor (T-08-37).
- `LoginCubit` ignora um segundo `entrar` durante `enviando` (T-08-38) e nenhum estado guarda e-mail ou senha. `LoginScreen` usa `AutofillGroup`, senha oculta por padrao com `enableSuggestions: false` e `autocorrect: false` (T-08-39), botao desabilitado com progresso em `enviando`.
- Depois do login a rota e substituida (`pushReplacement`) por `AcervoScreen` ou `AvisoAreaScreen` conforme o `Papel` (T-08-40); o "voltar" leva a rota anterior, nunca ao login.
- `confirmarESair` (dialogo "Sair da conta?") serve a tela de aviso e a `AppBar` do acervo; `AcervoScreen` ouve a transicao para `sessaoExpirada`, chama `marcarAnonima()` e faz `pushAndRemoveUntil` para `LoginScreen(aviso: avisoSessaoTerminou)` (T-08-54).

## Task Commits

1. **Task 1: Textos fixos do login e LoginCubit** - `dfd8e2b` (feat)
2. **Task 2: LoginScreen, tela de aviso, Sair e 401 do acervo** - `ff50ce1` (feat)

**Plan metadata:** commit docs(08-10) logo apos este arquivo.

_Nota: o plano e `tdd="true"` por tarefa; testes e implementacao de cada tarefa foram commitados juntos num unico `feat` por tarefa (mesma pratica dos planos anteriores da fase)._

## Files Created/Modified
- `lib/presentation/login/apresentacao_login.dart` - textos fixos e funcoes puras de mensagem
- `lib/presentation/login/login_state.dart` (+ `.freezed.dart`) - `LoginState` com quatro variantes
- `lib/presentation/login/login_cubit.dart` - Cubit do login
- `lib/presentation/login/login_screen.dart` - tela com formulario, autofill e roteamento por papel
- `lib/presentation/sessao/dialogo_sair.dart` - `confirmarESair`
- `lib/presentation/sessao/aviso_area_screen.dart` - tela de aviso do gestor/administrador
- `lib/presentation/acervo/acervo_screen.dart` - acao Sair e ouvinte de `sessaoExpirada`
- `lib/di/injection.config.dart` - registro do `LoginCubit` (so as linhas novas)
- `test/presentation/apresentacao_login_test.dart`, `login_cubit_test.dart` (7), `login_screen_test.dart` (12), `aviso_area_screen_test.dart` (3), `acervo_screen_test.dart` (+4 casos)

## Decisions Made
Ver `key-decisions` no cabecalho. A principal: `confirmarESair` captura `Navigator` e `SessaoCubit` antes do `await` do dialogo, assim o Sair termina mesmo que a tela de origem saia da arvore durante a espera.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Verificacao `flutter analyze lib` nao fica "No issues found!"**
- **Found during:** Task 2 (verify)
- **Issue:** o criterio do plano pede analise limpa, mas o baseline do repositorio ja tem 33 `info` `deprecated_member_use` (`package:flutter/material.dart` esta marcado como deprecated no Flutter 3.47) em arquivos fora desta fase. Os tres arquivos novos que importam `material.dart` (`login_screen`, `dialogo_sair`, `aviso_area_screen`) somam 3 itens do MESMO tipo (33 para 36); nenhum outro tipo de aviso foi adicionado. Trocar o import em so alguns arquivos quebraria a consistencia do projeto.
- **Fix:** nenhum; seguida a orientacao do orquestrador (nao corrigir o baseline, so nao adicionar outros tipos).
- **Files modified:** nenhum

**2. [Rule 3 - Blocking] `pumpAndSettle` nao assenta com progresso em tela**
- **Found during:** Task 2 (testes)
- **Issue:** `LoginState.enviando` e `AcervoState` em `carregando` mostram um `CircularProgressIndicator` que anima para sempre e faz `pumpAndSettle` estourar.
- **Fix:** `montar` do `login_screen_test.dart` usa `pump` com 500 ms; os testes de roteamento partem de `editando` e o acervo falso do destino usa `ConteudoAcervo.vazio()`.
- **Files modified:** `test/presentation/login_screen_test.dart`

**3. [Decisao do plano] Substituicao do caminho do repositorio web**
- O plano nao toca o repositorio web; a orientacao de substituir o caminho obsoleto (`C:/Users/allys/OneDrive/...` por `C:/projetos/imoveis-aqui`) nao foi necessaria nesta execucao.

**Total deviations:** 2 auto-fixed (Rule 3), 0 afetam o escopo.
**Impact on plan:** nenhum — comportamento e arquivos conforme o plano.

## Issues Encountered
- Dois comandos Bash longos com varios heredocs falharam no parse do shell sem escrever nada; os arquivos foram criados com a ferramenta Write.
- `dart run build_runner build -d` marcou 30 arquivos gerados como modificados so por fim de linha (CRLF); conferido com `git diff --ignore-space-at-eol` (so `injection.config.dart` tinha conteudo novo) e restaurados por lista explicita.

## Known Stubs
None. `AvisoAreaScreen` e intencionalmente uma tela de aviso (D-B): a area do gestor (APP-12) a substitui sem mexer no login.

## Threat Flags
None. Nenhum endpoint, caminho de autenticacao ou acesso a arquivo novo alem do mapeado em T-08-37..T-08-54.

## Next Phase Readiness
- Falta a entrada pelo app: o botao do topo da vitrine ("Entrar"/"Meu acervo") e o provimento do `SessaoCubit` acima do `MaterialApp` (hoje so existe nos testes) entram no 08-11. `confirmarESair` e `AcervoScreen` ja leem o `SessaoCubit` via `context.read`, entao ele precisa estar provido la.

## Self-Check: PASSED
- Arquivos criados conferidos no disco; commits `dfd8e2b` e `ff50ce1` presentes em `HEAD`.
- `flutter test` completo: 1023 testes passando (991 + 32 novos); `flutter analyze lib`: 36 `info` `deprecated_member_use` (33 de baseline + 3 imports de `material.dart` dos arquivos novos).
