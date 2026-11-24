---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 11
subsystem: ui
tags: [flutter, dart, cubit, bottom-sheet, popscope, textfield, mocktail]

requires:
  - phase: 09-mudança-de-situação (09-10)
    provides: MudarSituacaoCubit com a guarda de toque duplo, mostrarMudarSituacaoSheet e a folha com chips e Confirmar
  - phase: 09-mudança-de-situação (09-09)
    provides: DataSource que manda observacao sem espaços nas pontas e só quando não vazia
provides:
  - "Folha de mudança completa: observação opcional com limite de 500 (D-17), dica do site e Data: hoje informativo"
  - "Envio protegido: Confirmar com carregamento, chips e campo desabilitados, PopScope que segura barreira e botão voltar, sem alça nem arrasto"
  - "apresentacao_gestao.dart com rotuloObservacao, dicaObservacao, textoDataHoje e limiteObservacao = 500"
  - "test/presentation/mudar_situacao_sheet_test.dart: folha com Cubit real sobre UseCase falso controlado por Completer"
affects: [09-12 mensagem do servidor na folha, 09-13 UAT]

actuals:
  tokens: 10000
  tasks: 2
  commits: 2
plan_head_before: 2f729ea2cea8733c49b89827931036e262a6a576

tech-stack:
  added: []
  patterns:
    - "Folha StatefulWidget dona do TextEditingController (dispose no State); o texto só vive em memória e sobrevive a uma falha porque a folha não fecha"
    - "PopScope(canPop: envio não está em voo) dentro do BlocConsumer: barreira e botão voltar usam maybePop e respeitam o PopScope"
    - "Alça de arrasto desligada (showDragHandle e enableDrag falsos): no SDK a alça fecha por Navigator.pop direto, por fora do PopScope"
    - "Teste da folha com Completer segurando o UseCase falso para observar o estado em voo"

key-files:
  created:
    - test/presentation/mudar_situacao_sheet_test.dart
  modified:
    - lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart
    - lib/presentation/gestao_imovel/apresentacao_gestao.dart
    - test/presentation/gestao_imovel_fluxo_test.dart

key-decisions:
  - "Limite de 500 caracteres na observação só na interface (D-17, decisão do usuário, exceção à D-06): o servidor não limita (§16.6)"
  - "Alça de arrasto da folha desligada, em vez de ligada com enableDrag falso como no exemplo da pesquisa: a alça fecharia a folha por fora do PopScope"
  - "A leitura do controlador fica num método _confirmar do State; o trim e a omissão da observação vazia continuam no DataSource (09-09)"

requirements-completed: [SIT-01, SIT-02, SIT-04]

coverage:
  - id: D1
    description: "Observação opcional com a dica do site e limite de 500 caracteres; texto acima de 500 não entra"
    requirement: SIT-01
    verification:
      - kind: unit
        ref: "test/presentation/mudar_situacao_sheet_test.dart#texto acima de 500 caracteres não entra no campo (D-17)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Data: hoje só informa; o app não envia data e a data gravada é a do servidor"
    requirement: SIT-01
    verification:
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#a observação digitada vai no corpo do POST e, depois da releitura, aparece no histórico (D-10, AC-1)"
        status: pass
    human_judgment: false
  - id: D3
    description: "A observação digitada vai no corpo do POST e aparece no histórico relido (pilha real)"
    requirement: SIT-01
    verification:
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#a observação digitada vai no corpo do POST e, depois da releitura, aparece no histórico (D-10, AC-1)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Durante o envio Confirmar mostra carregamento e fica desabilitado, chips e campo desabilitados, toque duplo gera uma só chamada e a folha não fecha por barreira, botão voltar nem arrasto"
    requirement: SIT-02
    verification:
      - kind: unit
        ref: "test/presentation/mudar_situacao_sheet_test.dart#envio protegido (D-09, D-10, T-09-07)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Depois de uma falha a folha continua aberta com o texto da observação e Confirmar volta a ficar habilitado"
    requirement: SIT-04
    verification:
      - kind: unit
        ref: "test/presentation/mudar_situacao_sheet_test.dart#depois de uma falha a folha continua aberta com o texto da observação no campo e Confirmar volta a ficar habilitado"
        status: pass
    human_judgment: false
  - id: D6
    description: "A folha parece certa no aparelho: teclado sobre o campo, contador de 500, carregamento no botão"
    verification: []
    human_judgment: true
    rationale: "Aparência e comportamento do teclado só um humano confere; vai para o human-check do 09-13"

duration: 5min
completed: 2026-11-22
status: complete
---

# Phase 9 Plan 11: Observação, Data hoje e envio protegido na folha Summary

**Folha "Mudar situação" completa: observação opcional de até 500 caracteres com a dica do site, "Data: hoje" informativo, e envio protegido por Confirmar com carregamento, campos desabilitados e PopScope sem alça de arrasto**

## Performance

- **Duração:** 5 min
- **Início:** 2026-11-22T19:09:38Z
- **Fim:** 2026-11-22T19:14:48Z
- **Tarefas:** 2
- **Arquivos modificados:** 4 (1 criado, 3 alterados)

## Accomplishments

- A folha ganhou o campo "Observação (opcional)" com a dica do `SituacaoForm` do site, contador e `maxLength: limiteObservacao` (500, D-17); o texto vai ao Cubit por `confirmar(observacao: ...)` e o `trim` e a omissão do vazio seguem no DataSource.
- "Data: hoje" aparece só como informação; o POST leva apenas `situacao` e `observacao`, e a data mostrada no histórico é a do servidor (D-05).
- Pela pilha real, a observação digitada chega ao corpo do POST e aparece no histórico relido; depois de uma falha a folha continua aberta com o texto no campo e Confirmar habilitado.
- Envio protegido: Confirmar troca o rótulo por um `CircularProgressIndicator` e fica desabilitado, chips e campo ficam desabilitados, e o `PopScope(canPop: !enviando)` impede o fechamento pela barreira e pelo botão voltar.
- A folha não tem alça nem arrasto (`showDragHandle: false`, `enableDrag: false`), porque no SDK a alça fecha a folha por `Navigator.pop` direto, por fora do `PopScope`.
- Verificação: `flutter analyze lib` limpo e `flutter test` inteiro verde (1420 testes), fim da onda 9.

## Task Commits

1. **Task 1: observação opcional com limite de 500, dica do site e Data: hoje** - `58289e1` (feat)
2. **Task 2: envio protegido, sem alça de arrasto** - `69a7a61` (feat)

**Metadados do plano:** commit docs do SUMMARY e, em seguida, do STATE e ROADMAP.

_TDD: testes escritos antes de cada implementação e vistos falhar (5 falhas na Task 1 e 4 na Task 2) antes do código; os dois ciclos foram commitados juntos em cada tarefa, como nos planos anteriores da fase._

## Files Created/Modified

- `lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart` - `_FolhaMudarSituacao` vira `StatefulWidget` dono do controlador, com observação, "Data: hoje", `PopScope` e Confirmar com carregamento; o abridor desliga alça e arrasto.
- `lib/presentation/gestao_imovel/apresentacao_gestao.dart` - `rotuloObservacao`, `dicaObservacao`, `textoDataHoje` e `limiteObservacao = 500`.
- `test/presentation/mudar_situacao_sheet_test.dart` - 12 casos da folha com Cubit real sobre `MudarSituacaoUseCase` falso (mocktail) e `Completer`.
- `test/presentation/gestao_imovel_fluxo_test.dart` - caso novo: observação no POST e no histórico relido.

## Decisions Made

- O limite de 500 vive só na interface (D-17); o servidor não limita (§16.6), então a proteção contra observação gigante (T-09-09) é do campo.
- Alça de arrasto desligada em vez do exemplo da pesquisa (alça ligada com `enableDrag: false`), conforme o objetivo do plano e conferido no SDK.
- `_confirmar(context)` no State lê o controlador, mantendo `confirmar(observacao: ...)` numa linha só.

## Deviations from Plan

None - plan executed exactly as written.

Ajuste de teste, sem mudar o plano: a alça de arrasto é um widget privado do SDK (`BottomSheetDragHandle` não é exportado), então o teste confere `BottomSheet.showDragHandle` e `BottomSheet.enableDrag` em vez de procurar o widget da alça.

## Issues Encountered

Nenhum. O `flutter test` inteiro passou de 120 s e rodou em segundo plano; terminou verde.

## Known Stubs

Nenhum.

## Threat Flags

Nenhuma superfície nova além da já prevista no `<threat_model>` (T-09-06, T-09-07, T-09-09 mitigadas: observação só em memória, `PopScope` e carregamento, `maxLength` de 500; nenhum pacote novo).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Pronto para o 09-12: a folha já fica aberta depois de uma falha, com a observação no campo; falta mostrar a mensagem do servidor nas recusas 400/403.
- O 09-13 confere à mão a aparência (teclado, contador, carregamento) e a D-17.

## Self-Check: PASSED

- Arquivos: `test/presentation/mudar_situacao_sheet_test.dart`, `mudar_situacao_sheet.dart`, `apresentacao_gestao.dart` e `gestao_imovel_fluxo_test.dart` existem.
- Commits `58289e1` e `69a7a61` existem em `feat/APP09`; `git rev-list --count 2f729ea..HEAD` = 2.
- `<acceptance_criteria>` e `<verification>` reexecutados: testes da folha, do Cubit e do fluxo verdes, `flutter analyze lib` sem problemas, `flutter test` inteiro com 1420 testes verdes, greps do `<verify>` passam.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
