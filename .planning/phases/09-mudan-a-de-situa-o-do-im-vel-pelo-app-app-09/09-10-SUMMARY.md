---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 10
subsystem: ui
tags: [flutter, dart, cubit, freezed, bottom-sheet, snackbar, injectable, bloc_test]

requires:
  - phase: 09-mudança-de-situação (09-08)
    provides: GestaoImovelCubit.recarregar() que relê imóvel e histórico mantendo o conteúdo na tela
  - phase: 09-mudança-de-situação (09-09)
    provides: MudarSituacaoUseCase (POST /api/imoveis/{id}/situacao/) e a rota da ApiFalsa
provides:
  - "MudarSituacaoCubit/MudarSituacaoState/EnvioSituacao: escolha de chips, Confirmar só com escolha diferente da atual e guarda de toque duplo"
  - "mostrarMudarSituacaoSheet: folha inferior com ChoiceChip das quatro situações (a atual desabilitada) e FilledButton Confirmar, via BlocProvider.value"
  - "GestaoImovelState.mudou e GestaoImovelCubit.registrarMudanca() (mudou = true e recarregar())"
  - "Tela de gestão com botão Mudar situação só com podeMudarSituacao, SnackBar do site e Ver na vitrine que some depois da mudança"
  - "abrirGestaoImovel fornece o MudarSituacaoCubit por MultiBlocProvider (criarMudarSituacaoCubit para teste)"
affects: [09-11 observação, Data hoje e envio protegido na mesma folha, 09-12 mensagem do servidor na folha, 09-13 UAT]

actuals:
  tokens: 22000
  tasks: 2
  commits: 2
plan_head_before: cd7a1721d0511f6cb251f75333d16d60a48c3748

tech-stack:
  added: []
  patterns:
    - "Cubit próprio da folha (A5), criado pelo abridor da rota com BlocProvider(create:) e passado à folha por BlocProvider.value (a rota do modal fica fora do provider da tela)"
    - "A tela nunca monta o estado novo: o sucesso do POST só dispara SnackBar + registrarMudanca(), e a situação nova aparece depois da releitura da API"
    - "Flag de tela mudou que sobrevive a nova carga e à falha da releitura (Pitfalls 2 e 3)"
    - "Teste de fluxo na pilha real com responder() simulando o servidor já mudado antes do Confirmar"

key-files:
  created:
    - lib/presentation/gestao_imovel/mudar_situacao_state.dart
    - lib/presentation/gestao_imovel/mudar_situacao_state.freezed.dart
    - lib/presentation/gestao_imovel/mudar_situacao_cubit.dart
    - lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart
    - test/presentation/mudar_situacao_cubit_test.dart
  modified:
    - lib/presentation/gestao_imovel/apresentacao_gestao.dart
    - lib/presentation/gestao_imovel/gestao_imovel_state.dart
    - lib/presentation/gestao_imovel/gestao_imovel_state.freezed.dart
    - lib/presentation/gestao_imovel/gestao_imovel_cubit.dart
    - lib/presentation/gestao_imovel/gestao_imovel_screen.dart
    - lib/di/injection.config.dart
    - test/presentation/gestao_imovel_cubit_test.dart
    - test/presentation/gestao_imovel_screen_test.dart
    - test/presentation/gestao_imovel_fluxo_test.dart

key-decisions:
  - "O SnackBar usa a situação escolhida, que o servidor aceitou com 200 (textoSituacaoAlterada em minúsculas, como o site); o estado da tela só muda pela releitura"
  - "GestaoImovelCubit.carregar() passa a emitir GestaoImovelState(mudou: state.mudou) em vez do estado vazio, para que Tentar de novo depois de uma mudança não faça Ver na vitrine voltar (D-18)"
  - "Nesta fatia as recusas 400/403 aparecem como a falha genérica da folha; a mensagem do servidor na folha é o 09-12"
  - "Os testes de tela com o Cubit da folha usam MockCubit; a folha aberta pela tela usa pump com tempo fixo (nunca pumpAndSettle, por causa do indicador do histórico)"

patterns-established:
  - "Botão de ação protegido por permissão do servidor: o widget só lê podeMudarSituacao, nunca decide quem pode"
  - "Fechar a folha pelo listener do próprio Cubit (EnvioConcluido) e avisar/reler pelo listener da tela"

requirements-completed: [SIT-01, SIT-02, SIT-06, SIT-07]

coverage:
  - id: D1
    description: "Folha com chips de escolha única (a situação atual desabilitada) e Confirmar desabilitado até haver uma escolha diferente da atual"
    requirement: SIT-01
    verification:
      - kind: unit
        ref: "test/presentation/mudar_situacao_cubit_test.dart#escolha (D-09)"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/gestao_imovel_screen_test.dart#mudar situação (D-04, D-09, D-10, D-18) tocar no botão inicia o Cubit da folha"
        status: pass
    human_judgment: false
  - id: D2
    description: "Confirmar pede a mudança pelo MudarSituacaoUseCase (36, reservado, observacao vazia) e dois confirmar() seguidos geram UMA chamada"
    requirement: SIT-01
    verification:
      - kind: unit
        ref: "test/presentation/mudar_situacao_cubit_test.dart#confirmar"
        status: pass
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#toque duplo no Confirmar manda um POST só (T-09-07)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Depois do 200 a folha fecha, o SnackBar diz Situação alterada para reservado. e a tela relê imóvel e histórico; a situação nova só aparece depois da releitura"
    requirement: SIT-02
    verification:
      - kind: unit
        ref: "test/presentation/gestao_imovel_cubit_test.dart#registrarMudanca (depois de mudar a situação, D-10, D-18)"
        status: pass
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#Mudar situação → chip Reservado → Confirmar"
        status: pass
    human_judgment: false
  - id: D4
    description: "O botão Mudar situação só existe com pode_mudar_situacao do servidor; o colega vê situação e histórico sem botão"
    requirement: SIT-06
    verification:
      - kind: automated_ui
        ref: "test/presentation/gestao_imovel_screen_test.dart#com pode_mudar_situacao falso o botão não existe"
        status: pass
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#colega (pode_mudar_situacao falso)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Depois de uma mudança bem-sucedida a tela marca mudou e esconde Ver na vitrine, mesmo que a releitura falhe"
    requirement: SIT-07
    verification:
      - kind: unit
        ref: "test/presentation/gestao_imovel_cubit_test.dart#se a releitura falhar, mudou continua verdadeiro"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/gestao_imovel_screen_test.dart#com mudou verdadeiro Ver na vitrine não aparece"
        status: pass
    human_judgment: false
  - id: D6
    description: "Aparência e ergonomia da folha e do botão (D-18 conferida pelo usuário no human-check do 09-13)"
    verification: []
    human_judgment: true
    rationale: "Julgamento visual e de uso (posição do botão, folha em aparelho real) que nenhum teste de widget assegura; fica para o UAT do 09-13"

duration: 25min ativos (a execução teve uma pausa por limite de taxa entre as duas tarefas)
completed: 2026-11-22
status: complete
---

# Phase 9 Plan 10: Folha de mudança de situação e releitura na tela Summary

**Caminho feliz da escrita na interface: o corretor responsável toca em Mudar situação, escolhe a situação numa folha inferior e confirma; o app pede a mudança pelo MudarSituacaoUseCase, fecha a folha, avisa com o texto do site e relê imóvel e histórico da API, e Ver na vitrine some.**

## Performance

- **Duration:** ~25 min ativos (começou 2026-11-22T16:13:00Z; o relógio de parede passou de 19:07Z por causa da pausa de limite de taxa)
- **Started:** 2026-11-22T16:13:00Z
- **Completed:** 2026-11-22T19:08:00Z
- **Tasks:** 2
- **Files modified:** 14 (5 criados, 9 alterados, contando o `.freezed.dart` e o `injection.config.dart` gerados)

## Accomplishments

- `MudarSituacaoCubit` (`iniciar`, `escolher`, `confirmar`) com `MudarSituacaoState` (`podeConfirmar` só com imóvel, escolha diferente da atual e envio fora de voo) e `EnvioSituacao` (ocioso, enviando, concluído, falhou). O toque duplo gera uma chamada só ao UseCase, `escolher` durante o envio é ignorado e nada é emitido depois de `close()`.
- `mostrarMudarSituacaoSheet` com `ChoiceChip` das quatro situações (a atual com `onSelected: null`), o texto de falha em `colorScheme.error` e o `FilledButton` Confirmar de largura total; o Cubit entra na rota do modal por `BlocProvider.value`, e a folha fecha sozinha na transição para `EnvioConcluido`.
- `GestaoImovelCubit.registrarMudanca()` marca `mudou` sem tocar na situação exibida e relê por `recarregar()`; a situação nova só aparece depois da releitura (T-09-03) e `mudou` fica verdadeiro mesmo se a releitura falhar.
- Tela de gestão: botão `FilledButton.icon` Mudar situação só com `imovel.podeMudarSituacao` (D-04), `BlocListener` do `MudarSituacaoCubit` que mostra Situação alterada para reservado. e chama `registrarMudanca()`, e Ver na vitrine com `previa.naVitrine && !state.mudou` (D-18). `abrirGestaoImovel` monta `MultiBlocProvider` com os dois Cubits e ganhou `criarMudarSituacaoCubit` (o `getIt` continua só no toque).
- Fluxo na pilha real provado: POST `/api/imoveis/36/situacao/` com `{"situacao": "RESERVADO"}` e token, seguido de um GET do imóvel e um GET do histórico, folha fechada, SnackBar do site, tela com Reservado e Disponível → Reservado, sem Ver na vitrine; toque duplo = um POST; 403 mantém a folha aberta com a falha genérica e sem releitura; colega sem botão e com o histórico à vista.

## Task Commits

1. **Task 1: Folha e Cubit da folha** - `7a62d47` (feat)
2. **Task 2: Mudar a situação ponta a ponta na tela** - `ceea189` (feat)

**Plan metadata:** commit docs(09-10) deste SUMMARY, do STATE, do ROADMAP e dos requisitos (hash no log do git)

_Nota: os testes de cada tarefa entraram no mesmo commit da implementação (TDD com testes escritos primeiro, RED confirmado pelo analisador por URI inexistente e GREEN depois da geração)._

## Files Created/Modified

- `lib/presentation/gestao_imovel/mudar_situacao_state.dart` (+ `.freezed.dart`) - estado da folha, getter `podeConfirmar` e união `EnvioSituacao`
- `lib/presentation/gestao_imovel/mudar_situacao_cubit.dart` - Cubit da folha com guarda de toque duplo, `@injectable`
- `lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart` - `mostrarMudarSituacaoSheet` e `_FolhaMudarSituacao`
- `lib/presentation/gestao_imovel/apresentacao_gestao.dart` - `rotuloBotaoMudarSituacao`, `tituloFolhaMudarSituacao`, `rotuloConfirmar`, `textoFalhaAoMudar`, `textoSituacaoAlterada`
- `lib/presentation/gestao_imovel/gestao_imovel_state.dart` (+ `.freezed.dart`) - campo `mudou`
- `lib/presentation/gestao_imovel/gestao_imovel_cubit.dart` - `registrarMudanca()` e `carregar` preservando `mudou`
- `lib/presentation/gestao_imovel/gestao_imovel_screen.dart` - botão, listener, `MultiBlocProvider` no abridor e Ver na vitrine condicionado a `!mudou`
- `lib/di/injection.config.dart` - registro do `MudarSituacaoCubit` (único gerado tracked alterado além dos `.freezed.dart`; nenhum só-CRLF para restaurar)
- `test/presentation/mudar_situacao_cubit_test.dart` (novo), `gestao_imovel_cubit_test.dart`, `gestao_imovel_screen_test.dart`, `gestao_imovel_fluxo_test.dart` - casos novos de Cubit, tela (com `MudarSituacaoCubit` falso) e fluxo

## Decisions Made

- O SnackBar usa a situação escolhida que o servidor aceitou com 200; o app não monta o estado novo, só relê (D-10, T-09-03).
- Recusas 400/403 aparecem como a falha genérica da folha nesta fatia; a mensagem do servidor é do 09-12.
- Cubit próprio para a folha (A5, discrição do CONTEXT), criado pelo `BlocProvider(create:)` da rota, que também o fecha na volta.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `carregar` zerava o `mudou`**
- **Found during:** Task 2 (ao desenhar os testes de `registrarMudanca`)
- **Issue:** `GestaoImovelCubit.carregar` emitia `const GestaoImovelState()`, então Tentar de novo depois de uma mudança devolvia `mudou` a falso e Ver na vitrine reaparecia, contrariando D-18 (a vitrine pode já não mostrar o imóvel).
- **Fix:** `carregar` passa a emitir `GestaoImovelState(mudou: state.mudou)`; o teste de `tentarNovamente` depois de `registrarMudanca` prova que `mudou` continua verdadeiro. Com `mudou` falso o estado emitido é idêntico ao anterior, então os testes antigos seguem valendo.
- **Files modified:** `lib/presentation/gestao_imovel/gestao_imovel_cubit.dart`, `test/presentation/gestao_imovel_cubit_test.dart`
- **Verification:** `flutter test test/presentation/gestao_imovel_cubit_test.dart` verde
- **Committed in:** `ceea189`

**2. [Ajuste de teste] Nomes da `ApiFalsa` no fluxo**
- **Found during:** Task 2
- **Issue:** a interface do plano cita `chamadas` com `ChamadaApiFalsa`; a prova de método, caminho e cabeçalho vem de `requisicoesGravadas` e o corpo do POST vem de `chamadas`. Os testes usam as duas listas.
- **Fix:** nenhuma mudança de código de produção; só a escolha de qual lista assertar.
- **Committed in:** `ceea189`

---

**Total deviations:** 1 auto-fixed (1 bug, Regra 1) e 1 ajuste só de teste
**Impact on plan:** a correção é necessária para D-18 e não aumentou o escopo.

## Issues Encountered

- `pumpAndSettle` estourava o tempo nos testes de tela com a folha aberta, porque o indicador de progresso do histórico mantém a animação de pé; resolvido com `pump` de tempo fixo (`_deixarAFolhaSubir`), como já era a regra dos fluxos desta fase.
- A execução foi interrompida por um limite de taxa entre a escrita dos testes do Cubit e a verificação final; retomada com o estado do disco conferido por `git status` e `git diff` antes de continuar.

## Known Stubs

Nenhum stub de dados. O que a folha ainda não tem é escopo declarado do 09-11 (observação com a dica e o limite de 500, Data: hoje, carregamento no botão e folha que não fecha no meio do envio) e do 09-12 (mensagem do servidor na folha); o `confirmar` do Cubit já aceita `observacao`.

## Threat Flags

Nenhuma superfície nova além das do `<threat_model>` do plano: o POST já foi coberto no 09-09 e aqui só há o botão (T-09-01), a releitura (T-09-03), a conferência de `Authorization` no fluxo (T-09-04) e a guarda de toque duplo (T-09-07). Nenhum pacote novo (T-09-SC).

## Verification

- `flutter analyze lib`: No issues found!
- `flutter test` inteiro: 1407 testes verdes (fim da onda 8, D-16).
- `flutter test` dos quatro arquivos do plano: 78 verdes.
- Greps de aceitação da Task 1 e da Task 2: todos passam.
- Nenhum gerado só-CRLF deixado modificado; nenhum push. `dart format` aplicado só nos arquivos do plano.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- O 09-11 completa a MESMA folha: observação com dica e limite de 500 (D-17), Data: hoje (D-05) e envio protegido (carregamento no botão, folha que não fecha no meio do envio).
- Pendência registrada em 09-05/09-08: a recarga do acervo ao voltar da gestão exige trocar o retorno `Future<void>` do abridor pelo `bool` lido do Cubit (RESEARCH, Pattern 5); não era escopo deste plano e `mudou` já está no estado para isso.

## Self-Check: PASSED

- Arquivos criados existem: `mudar_situacao_state.dart`, `mudar_situacao_state.freezed.dart`, `mudar_situacao_cubit.dart`, `widgets/mudar_situacao_sheet.dart`, `test/presentation/mudar_situacao_cubit_test.dart`.
- Commits `7a62d47` e `ceea189` existem em `feat/APP09`; `git rev-list --count cd7a172..HEAD` = 2.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
