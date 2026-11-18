---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 08
subsystem: apresentacao
tags: [contato, bottomSheet, snackbar, bloc_consumer, e2e, widget-test]
status: complete

requires:
  - phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
    provides: "BarraContato com canal principal, ContatoCubit/ContatoState, rotulos_contato.dart (06-07); ApiFalsa com POST de contato e fixtures contato_201_* (06-03, 06-05)"
provides:
  - "mostrarContatoBottomSheet: sheet 'Outras formas de contato' com os canais alem do principal"
  - "BarraContato completa: botao ⋮ (tooltip 'Mais formas de contato'), spinner por canal em curso, tudo desabilitado durante o POST e SnackBar por motivo (D-14/D-15)"
  - "e2e da pagina: ⋮ -> 'Ligar' -> POST TELEFONE sem credencial -> tel: exato do servidor ao lancador"
  - "test/presentation/barra_contato_test.dart (21 testes de widget)"
affects: [06-09, 06-10]

plan_head_before: d3731f26a8cb636ffd5a1874d7060eded9d0da1b
actuals:
  tokens: 7500   # chars/4 sobre as linhas alteradas
  tasks: 2
  commits: 2     # MEDIDO: git rev-list --count d3731f2..HEAD antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Cubit lido do contexto da barra (dentro do BlocProvider) antes de showModalBottomSheet; o sheet so recebe um callback"
    - "Spinner no lugar do icone do canal em curso (SizedBox.square 18 + CircularProgressIndicator strokeWidth 2); botoes seguem no lugar com onPressed null"
    - "BlocConsumer com listenWhen: atual is ContatoFalhou; hideCurrentSnackBar antes de showSnackBar"

key-files:
  created:
    - lib/presentation/contato/widgets/contato_bottom_sheet.dart
    - test/presentation/barra_contato_test.dart
  modified:
    - lib/presentation/contato/widgets/barra_contato.dart
    - test/presentation/detalhe_navegacao_test.dart

key-decisions:
  - "O ⋮ so existe quando sobra canal alem do principal; durante o envio por canal secundario o spinner substitui o icone do ⋮ (que continua IconButton desabilitado)"
  - "Cada falha nova substitui a SnackBar anterior (hideCurrentSnackBar); a repeticao aparece porque enviando entre duas falhas torna as emissoes distintas"

requirements-completed: [APP06-C3, APP06-C4]

coverage:
  - id: E1
    description: "Ponta a ponta: ⋮ abre o sheet com exatamente 'Ligar' e 'Enviar e-mail'; 'Ligar' fecha o sheet, faz POST {canal: TELEFONE} sem authorization/cookie e entrega ao lancador exatamente o link de contato_201_telefone.json"
    requirement: APP06-C3
    verification:
      - kind: widget
        ref: "test/presentation/detalhe_navegacao_test.dart 'tocar em Ligar no menu de mais formas...'"
        status: pass
    human_judgment: false
  - id: E2
    description: "Combinacoes de canais ([3], [telefone], [telefone,email], [email,whatsapp], [whatsapp]): principal, presenca do ⋮ e conteudo do sheet; escolher um canal chama contatar(42, canal)"
    requirement: APP06-C3
    verification:
      - kind: widget
        ref: "test/presentation/barra_contato_test.dart 'canais e sheet (D-05, D-06, C3)'"
        status: pass
    human_judgment: false
  - id: E3
    description: "Durante o POST: spinner no principal ou no ⋮ conforme o canal em curso, principal e ⋮ desabilitados, toques ignorados (D-13)"
    requirement: APP06-C4
    verification:
      - kind: widget
        ref: "test/presentation/barra_contato_test.dart 'loading e bloqueio durante o POST (D-13)'"
        status: pass
    human_judgment: false
  - id: E4
    description: "SnackBar com o texto exato de cada um dos cinco motivos, falhas seguidas mostram de novo, e nenhum Text da barra/sheet/SnackBar contem wa.me, tel:, mailto: ou @"
    requirement: APP06-C4
    verification:
      - kind: widget
        ref: "test/presentation/barra_contato_test.dart 'SnackBar por motivo de falha' e 'sem dado de contato na tela'"
        status: pass
    human_judgment: false
  - id: E5
    description: "Aparencia real do ⋮, do sheet e do spinner no aparelho (espacamento, toque, ordem visual)"
    requirement: APP06-C3
    verification: []
    human_judgment: true
    rationale: "Testes de widget nao julgam layout fino; fica para a verificacao manual da fase (06-10)"
---

# Phase 6 Plan 08: ⋮, loading e SnackBars da barra de contato Summary

**A `BarraContato` agora esta completa: ⋮ com bottom sheet dos demais canais (Ligar / Enviar e-mail), spinner no botao do canal em curso com tudo desabilitado durante o POST e SnackBar em portugues por motivo de falha, provado ponta a ponta com ⋮ -> "Ligar" entregando o `tel:` exato do servidor sem credencial.**

## Performance

- **Duration:** ~20 min
- **Completed:** 2026-11-18
- **Tasks:** 2 (1 tracer, 1 auto/tdd)
- **Files modified:** 4 (2 criados, 2 modificados)

## Accomplishments

- `mostrarContatoBottomSheet(context, {canais, aoEscolher})`: `showModalBottomSheet(showDragHandle: true)`, titulo 'Outras formas de contato', um `ListTile` por canal; ao tocar fecha o sheet e chama o callback.
- `BarraContato`: `IconButton(Icons.more_vert, tooltip: 'Mais formas de contato')` so quando ha canais secundarios; o Cubit e lido do contexto da barra antes de abrir o sheet (sem `getIt` em widget).
- D-13: `BlocConsumer` calcula o canal em curso; principal e ⋮ ficam `onPressed: null`; o spinner (18 px, strokeWidth 2) ocupa o icone do principal ou o do ⋮.
- D-14/D-15: `listenWhen: atual is ContatoFalhou` + `hideCurrentSnackBar()`/`showSnackBar(Text(motivo.mensagem))`; so os cinco textos fixos, nunca link, numero ou e-mail.
- Tracer (e2e): na pagina da casa, ⋮ lista exatamente 'Ligar' e 'Enviar e-mail'; 'Ligar' fecha o sheet, faz POST `/api/publico/imoveis/<id>/contato/` com `{'canal': 'TELEFONE'}` sem `authorization`/`cookie` e o lancador recebe exatamente o `link` de `contato_201_telefone.json`.

## Task Commits

1. **Task 1 (tracer): ⋮ com bottom sheet de contato** - `131c175` (feat)
2. **Task 2: loading e SnackBars do contato** - `cc245a8` (feat)

Repo da API: nenhum commit (opcao-a). Nada de push.

## Verificacao

- `flutter test test/presentation/detalhe_navegacao_test.dart --plain-name "Ligar no menu de mais formas"`: passou (o e2e roda).
- `flutter test test/presentation/barra_contato_test.dart test/presentation/detalhe_navegacao_test.dart`: 25 passaram (inclui o e2e do WhatsApp de 06-07).
- Task 2 em TDD: testes de loading/SnackBar escritos primeiro e vistos falhar (10 falhas) antes da implementacao; depois `barra_contato_test.dart`: 21 passaram.
- `flutter test test/presentation/`: 407 passaram. `flutter analyze`: sem issues.
- Verificacao "spec-less probe fallback": pulada no planejamento, conforme registrado no plano.

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None.

## Threat Flags

None - sem superficie nova alem da coberta pelo threat model (T-06-08-01 a T-06-08-04 mitigados: botoes desabilitados durante `ContatoEnviando` e testados para principal e secundario, so rotulos/mensagens fixos com teste de ausencia de `wa.me`/`tel:`/`mailto:`/`@`, Cubit capturado do contexto da barra, e2e sem `authorization`/`cookie`).

## Issues Encountered

None.

## Self-Check: PASSED

- Arquivos presentes: contato_bottom_sheet.dart, barra_contato.dart, barra_contato_test.dart, detalhe_navegacao_test.dart.
- Commits `131c175` e `cc245a8` existem em feat/APP06; `git rev-list --count d3731f2..HEAD` = 2.
