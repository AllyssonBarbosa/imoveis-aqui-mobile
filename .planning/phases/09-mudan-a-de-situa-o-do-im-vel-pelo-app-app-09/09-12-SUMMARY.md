---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 12
subsystem: ui
tags: [flutter, dart, cubit, freezed, bottom-sheet, sealed-class, mocktail]

requires:
  - phase: 09-mudança-de-situação (09-11)
    provides: folha com observação, envio protegido por PopScope e EnvioSituacao (ocioso, enviando, concluido, falhou)
  - phase: 09-mudança-de-situação (09-09)
    provides: MudarSituacaoUseCase devolvendo falhas tipadas (MudancaSituacaoRecusadaException, ImovelNaoEncontradoException, SessaoExpiradaException, FalhaDeConexaoException)
  - phase: 09-mudança-de-situação (09-08)
    provides: voltarAoLoginComSessaoTerminada e textoImovelForaDoAcervo
provides:
  - "EnvioSituacao com recusado(mensagem), naoEncontrado e sessaoExpirada"
  - "MudarSituacaoCubit decidindo o desfecho da falha por switch no TIPO da exceção"
  - "Folha com o texto de falha escolhido por switch exaustivo sobre EnvioSituacao (mensagem do servidor como texto simples, até 6 linhas, em colorScheme.error)"
  - "GestaoImovelScreen com BlocListener de EnvioSessaoExpirada que volta ao login"
affects: [09-13 UAT]

actuals:
  tokens: 60000
  tasks: 2
  commits: 2
plan_head_before: 6ae9d7dd9e031ef606a337c337bdcd58abe3e6b3

tech-stack:
  added: []
  patterns:
    - "Desfecho da falha por switch no tipo da exceção de domínio (molde ContatoCubit._motivoDe); a mensagem do servidor só é carregada para exibição"
    - "Texto da folha por switch exaustivo sobre a união selada, sem ramo curinga: variante nova de EnvioSituacao quebra a compilação até ser tratada"
    - "Teste de fluxo distingue a situação da TELA do chip da folha com find.descendant(of: SecaoSituacao)"

key-files:
  created: []
  modified:
    - lib/presentation/gestao_imovel/mudar_situacao_state.dart
    - lib/presentation/gestao_imovel/mudar_situacao_state.freezed.dart
    - lib/presentation/gestao_imovel/mudar_situacao_cubit.dart
    - lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart
    - lib/presentation/gestao_imovel/gestao_imovel_screen.dart
    - lib/presentation/gestao_imovel/apresentacao_gestao.dart
    - test/presentation/mudar_situacao_cubit_test.dart
    - test/presentation/mudar_situacao_sheet_test.dart
    - test/presentation/gestao_imovel_fluxo_test.dart

key-decisions:
  - "Só a recusa 400/403 exibe texto do servidor (já em português, de negócio e cortado em 300 no 09-09); 404 e rede/5xx usam texto fixo, então o detail em inglês do Django nunca aparece (T-09-05)"
  - "Mensagem do servidor como Text simples com maxLines 6, sem texto rico nem link montado a partir dela (T-09-13)"
  - "Sem nova tentativa automática: o reenvio é sempre do corretor; se um POST com tempo esgotado tiver gravado, o reenvio recebe o 400 'já está …', exibido pela recusa (Pitfall 4, T-09-11)"
  - "401 no envio reaproveita voltarAoLoginComSessaoTerminada; o pushAndRemoveUntil do helper tira a folha junto, e o PopScope (só vale para maybePop) não atrapalha"

requirements-completed: [SIT-04, SIT-06]

coverage:
  - id: D1
    description: "Recusa 400 (contrato assinado) mantém a folha aberta com a mensagem do servidor e a observação, a tela segue na situação anterior e nada é relido depois do POST"
    requirement: SIT-04
    verification:
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#contrato assinado (400)"
        status: pass
      - kind: unit
        ref: "test/presentation/mudar_situacao_sheet_test.dart#com a recusa a folha continua aberta, mostra a mensagem do servidor como texto simples"
        status: pass
    human_judgment: false
  - id: D2
    description: "403 de quem força a mudança aparece como recusa com 'Só o corretor responsável…', sem mudar a tela nem reler"
    requirement: SIT-06
    verification:
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#quem força a mudança (403)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Rede, tempo esgotado e 5xx mostram o texto fixo; o reenvio é do corretor e, com 200, fecha a folha"
    requirement: SIT-04
    verification:
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#falha 5xx no envio"
        status: pass
      - kind: unit
        ref: "test/presentation/mudar_situacao_cubit_test.dart#rede, tempo esgotado ou 5xx (FalhaDeConexaoException)"
        status: pass
    human_judgment: false
  - id: D4
    description: "404 no envio mostra 'Este imóvel não está mais no seu acervo.' e o texto em inglês do servidor não aparece"
    requirement: SIT-04
    verification:
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#404 no envio"
        status: pass
    human_judgment: false
  - id: D5
    description: "401 no envio volta ao login com 'Sua sessão terminou. Entre de novo.' e o token apagado"
    requirement: SIT-04
    verification:
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#401 no envio leva ao login"
        status: pass
    human_judgment: false
  - id: D6
    description: "Legibilidade e adequação visual da mensagem de recusa (até 6 linhas, cor de erro) na folha em aparelho real"
    verification: []
    human_judgment: true
    rationale: "Teste de widget prova o texto, o limite de linhas e a cor, mas não se a leitura é confortável no aparelho; entra no UAT do 09-13"

duration: 31 min
completed: 2026-11-22
status: complete
---

# Phase 9 Plan 12: Recusas e falhas do envio da mudança de situação Summary

**Recusa do servidor (400/403) mostrada com a mensagem do próprio Django na folha aberta, e 404, 401 e falhas de rede com desfechos próprios, decididos só pelo tipo da falha, sem reenvio automático**

## Performance

- **Duration:** 31 min
- **Started:** 2026-11-22T18:53:00Z
- **Completed:** 2026-11-22T19:24:12Z
- **Tasks:** 2
- **Files modified:** 9 (6 em `lib/`, 3 em `test/`)

## Accomplishments

- `EnvioSituacao` ganhou `EnvioRecusado(mensagem)`, `EnvioNaoEncontrado` e `EnvioSessaoExpirada`; o `MudarSituacaoCubit` escolhe o desfecho da falha por `switch` no tipo da exceção de domínio (molde `ContatoCubit._motivoDe`), sem `try/catch` e sem olhar mensagem nem status HTTP.
- Numa recusa (400 de contrato assinado, de mesma situação ou de validação; 403 de quem não é o responsável) a folha continua aberta, mantém a observação digitada e mostra a mensagem do servidor como `Text` simples (`maxLines: 6`, `colorScheme.error`); a tela de gestão não muda e não relê nada (provado no fluxo: nenhum GET depois do POST recusado).
- 404 no envio mostra `textoImovelForaDoAcervo`; rede, tempo esgotado e 5xx mostram "Não foi possível mudar a situação agora. Tente de novo." com Confirmar habilitado; o segundo POST só acontece por toque do corretor.
- 401 no envio chega à `GestaoImovelScreen` por um `BlocListener` de `EnvioSessaoExpirada` e chama `voltarAoLoginComSessaoTerminada`: login com o aviso, token apagado, só a vitrine embaixo.
- O texto da folha agora vem de um `switch` exaustivo sobre `EnvioSituacao`, sem ramo curinga.

## Task Commits

1. **Task 1: Recusa do servidor com a mensagem dele (D-10, D-07, AC-4)** - `5cabb31` (feat)
2. **Task 2: 404, 401 e falhas de rede no envio (D-10)** - `956fe22` (feat)

**Plan metadata:** commit `docs(09-12)` (summary, STATE, ROADMAP, REQUIREMENTS)

TDD: em cada task os testes foram escritos antes e falharam (RED confirmado: casos novos de Cubit/folha/fluxo quebrando ou sem compilar) antes da implementação; RED e GREEN ficam no mesmo commit de cada task, como nos planos anteriores da fase.

## Files Created/Modified

- `lib/presentation/gestao_imovel/mudar_situacao_state.dart` - variantes `recusado`, `naoEncontrado`, `sessaoExpirada` de `EnvioSituacao`
- `lib/presentation/gestao_imovel/mudar_situacao_state.freezed.dart` - regenerado por `build_runner` (diff real, não só CRLF)
- `lib/presentation/gestao_imovel/mudar_situacao_cubit.dart` - `_envioDaFalha` por `switch` no tipo
- `lib/presentation/gestao_imovel/widgets/mudar_situacao_sheet.dart` - `_textoDoEnvio` por `switch` exaustivo
- `lib/presentation/gestao_imovel/gestao_imovel_screen.dart` - `BlocListener` de `EnvioSessaoExpirada` → login
- `lib/presentation/gestao_imovel/apresentacao_gestao.dart` - só o comentário de `textoFalhaAoMudar` atualizado (dizia "a mensagem do servidor vem no 09-12")
- `test/presentation/mudar_situacao_cubit_test.dart` - recusa, 404, 401, rede (uma chamada ao UseCase em cada)
- `test/presentation/mudar_situacao_sheet_test.dart` - recusa com observação preservada, 404 e falha de conexão
- `test/presentation/gestao_imovel_fluxo_test.dart` - contrato assinado, 403, 5xx com reenvio, 404 e 401 na pilha real

## Decisions Made

Ver `key-decisions` no frontmatter. Em resumo: só a recusa exibe texto do servidor; texto simples com limite de linhas; nenhuma nova tentativa automática; 401 reaproveita o helper único de sessão terminada.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug de teste] Finder ambíguo para "Disponível" com a folha aberta**
- **Found during:** Task 1 (teste de fluxo)
- **Issue:** com a folha aberta, "Disponível" aparece duas vezes (a situação da tela e o chip desabilitado da situação atual), então `find.text('Disponível')` com `findsOneWidget` falhava; o teste antigo do 403 não conferia isso.
- **Fix:** helper `_situacaoNaTela` com `find.descendant(of: find.byType(SecaoSituacao), ...)` para provar a situação da TELA sem confundir com o chip.
- **Files modified:** `test/presentation/gestao_imovel_fluxo_test.dart`
- **Verification:** os dois testes de recusa passam.
- **Committed in:** `5cabb31`

**2. [Rule 1 - Teste desatualizado] Teste antigo do 403 esperava a falha genérica**
- **Found during:** Task 1
- **Issue:** o teste do 09-10/09-11 ("a mudança que o servidor recusa (403) … mostra a falha genérica") afirmava o comportamento que este plano substitui.
- **Fix:** substituído pelos testes de 403 ("Só o corretor responsável…") e de contrato assinado (400), mais fortes (provam também que nada é relido).
- **Files modified:** `test/presentation/gestao_imovel_fluxo_test.dart`
- **Committed in:** `5cabb31`

**3. [Escopo mínimo] Comentário de `textoFalhaAoMudar` atualizado**
- **Found during:** Task 2
- **Issue:** o comentário dizia que a mensagem do servidor "vem no 09-12", o que deixou de ser verdade; o arquivo não está na lista do plano.
- **Fix:** só o texto do comentário, sem mudança de comportamento.
- **Files modified:** `lib/presentation/gestao_imovel/apresentacao_gestao.dart`
- **Committed in:** `956fe22`

---

**Total deviations:** 3 auto-fixed (2 Rule 1 em testes, 1 comentário)
**Impact on plan:** nenhuma mudança de escopo nem de comportamento além do planejado.

## Issues Encountered

- O `dart format` reescreveu um trecho do Cubit depois da primeira edição e a substituição seguinte não casou; o `flutter analyze` acusou os imports sem uso e a correção foi imediata (sem impacto no resultado).
- `build_runner` regenerou só o `mudar_situacao_state.freezed.dart` (diff real); nenhum gerado só-CRLF ficou modificado, então não foi preciso restaurar nada.

## Verification

- `flutter test` dos três arquivos do plano: 52 testes verdes.
- `flutter analyze lib`: "No issues found!".
- `flutter test` inteiro (fim da onda 10, D-16): 1433 testes verdes.
- Gates de `grep` das duas tasks passaram (sem `Text.rich` na folha).
- Sem push; nenhum arquivo deletado nos commits.

## Known Stubs

Nenhum.

## Threat Flags

Nenhuma superfície nova além do modelo de ameaças do plano (T-09-01, T-09-03, T-09-05, T-09-08, T-09-13 mitigadas e provadas por teste; T-09-11 aceita e registrada para o UAT).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Pronto para o 09-13 (UAT). Pontos a registrar lá: o POST com tempo esgotado que pode ter gravado (Pitfall 4; o reenvio recebe o 400 "já está …", exibido na folha) e a legibilidade da mensagem de recusa em aparelho real (D6).

## Self-Check: PASSED

- `mudar_situacao_state.dart`, `mudar_situacao_cubit.dart`, `mudar_situacao_sheet.dart`, `gestao_imovel_screen.dart` existem e contêm `EnvioRecusado`, `EnvioNaoEncontrado` e `EnvioSessaoExpirada`.
- Commits `5cabb31` e `956fe22` existem em `feat/APP09`; `git rev-list --count 6ae9d7d..HEAD` = 2.

---
*Phase: 09-mudança-de-situação*
*Completed: 2026-11-22*
