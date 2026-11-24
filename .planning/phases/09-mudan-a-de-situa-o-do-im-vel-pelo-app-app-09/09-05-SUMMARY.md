---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 05
subsystem: ui
tags: [flutter, dart, cubit, freezed, injectable, gestao, acervo, tracer, navigator]

requires:
  - phase: 09-mudança-de-situação (09-04)
    provides: ObterImovelGestaoUseCase e as falhas tipadas da leitura de GET /api/imoveis/{id}/
  - phase: 09-mudança-de-situação (09-01)
    provides: fixtures capturadas imovel_gestao_*.json, erro_401.json, erro_404_imovel.json
provides:
  - "Todo cartão do Meu acervo abre, por Navigator.push, a tela de gestão do imóvel (supera o D-07 da Fase 8 e o ACV-04)"
  - "GestaoImovelCubit + GestaoImovelState/ConteudoImovelGestao (carregando | carregado | erro), com token de versão e isClosed"
  - "abrirGestaoImovel (dono do Cubit: cria, carrega, empurra a rota, fecha na volta) e AoAbrirGestao"
  - "GestaoImovelScreen com AppBar = código, título, situação atual e 'Tentar de novo' na primeira carga"
  - "ApiFalsa serve GET /api/imoveis/<id>/ e PilhaReal.entrarNoAcervo; conferirCabecalhosDeAutorizacao cobre todo /api/imoveis/..."
affects: [09-06 histórico, 09-07 tela de gestão, 09-08 mudança de situação, 09-10 recarga do acervo]

actuals:
  tokens: 6500
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Abridor dono do Cubit: getIt só no toque, criarCubit injetável, cubit.close() depois do await push"
    - "Estado freezed com campo persistente + união selada de desfechos (molde AcervoState/ConteudoAcervo)"
    - "Pilha real nos fluxos: ApiFalsa.responder(...) troca o wire de uma rota para cobrir o caso sem alterar fixture"

key-files:
  created:
    - lib/presentation/gestao_imovel/gestao_imovel_state.dart
    - lib/presentation/gestao_imovel/gestao_imovel_state.freezed.dart
    - lib/presentation/gestao_imovel/gestao_imovel_cubit.dart
    - lib/presentation/gestao_imovel/gestao_imovel_screen.dart
    - lib/presentation/gestao_imovel/apresentacao_gestao.dart
    - test/presentation/gestao_imovel_fluxo_test.dart
    - test/presentation/gestao_imovel_cubit_test.dart
  modified:
    - lib/presentation/acervo/acervo_screen.dart
    - lib/presentation/acervo/widgets/cartao_imovel_acervo.dart
    - lib/di/injection.config.dart
    - test/support/api_falsa.dart
    - test/support/pilha_real.dart
    - test/presentation/cartao_imovel_acervo_test.dart
    - test/presentation/acervo_screen_test.dart

key-decisions:
  - "O abridor não usa try/finally: await push seguido de cubit.close(), para manter a regra 'sem try/catch na UI' sem exceção"
  - "O título da tela de gestão é o código do imóvel (discrição registrada no plano); o título do imóvel vai no corpo em titleLarge"
  - "O Cubit completo (versão + isClosed + tentarNovamente) já nasce no tracer, como a ação da Task 1 especificava; a Task 2 virou prova por teste"

patterns-established:
  - "AcervoScreen recebe aoAbrirGestao (padrão abrirGestaoImovel) do ImovelAcervo inteiro, com na_vitrine incluso, e não mais a prévia pública"

requirements-completed: [SIT-07]

coverage:
  - id: D1
    description: "Tocar em QUALQUER cartão do acervo (na vitrine ou não) abre a tela de gestão com a situação atual vinda de GET /api/imoveis/{id}/, pela pilha real"
    requirement: "SIT-07"
    verification:
      - kind: e2e
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#tocar no cartão do acervo abre a gestão"
        status: pass
      - kind: e2e
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#cartão que o servidor diz não estar na vitrine"
        status: pass
      - kind: unit
        ref: "test/presentation/cartao_imovel_acervo_test.dart#toque (D-02 da Fase 9)"
        status: pass
      - kind: unit
        ref: "test/presentation/acervo_screen_test.dart#toque no cartão (D-02 da Fase 9)"
        status: pass
    human_judgment: false
  - id: D2
    description: "GestaoImovelCubit descarta resposta vencida, nunca emite fechado e repete a leitura com o id guardado"
    requirement: "SIT-07"
    verification:
      - kind: unit
        ref: "test/presentation/gestao_imovel_cubit_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Falha na primeira carga mostra 'Não foi possível carregar o imóvel.' e 'Tentar de novo' repete o GET e recupera a tela"
    requirement: "SIT-07"
    verification:
      - kind: e2e
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#falha na primeira carga"
        status: pass
    human_judgment: false
  - id: D4
    description: "Aparência da tela de gestão (espaçamento, hierarquia tipográfica) em aparelho real"
    verification: []
    human_judgment: true
    rationale: "A tela é um esqueleto do tracer (título e situação); o desenho final entra no 09-07 e o human-check de fim de fase confere no aparelho"

duration: 5 min
completed: 2026-11-22
plan_head_before: fc7f8ec4d2259ecc4cba5d411759318dde706c95
commits: 2
status: complete
---

# Phase 9 Plan 05: Tracer de UI da gestão do imóvel Summary

**Todo cartão do Meu acervo abre, por `Navigator.push`, a tela de gestão do imóvel, que mostra a situação vinda de `GET /api/imoveis/{id}/` por Cubit freezed (versão de leitura + `isClosed`) sobre a pilha real do app, com "Tentar de novo" na primeira carga**

## Performance

- **Duration:** 5 min
- **Started:** 2026-11-22T15:41:00Z (aprox.)
- **Completed:** 2026-11-22T15:46:00Z (aprox.)
- **Tasks:** 2
- **Files modified:** 14 (7 criados, 7 alterados)

## Accomplishments

- Tracer de UI: cartão do acervo → `abrirGestaoImovel` → `GestaoImovelCubit` → `ObterImovelGestaoUseCase` → Repository → DataSource no `Dio` `'autenticado'` → `GET /api/imoveis/36/` com `Authorization: Token <40 zeros>`. O fluxo ponta a ponta toca em `DEV-INDAIATUBA-04` e confere código na `AppBar`, título do imóvel, "Disponível" e o cabeçalho de autorização (`conferirCabecalhosDeAutorizacao` passa).
- D-02 aplicado: `CartaoImovelAcervo` cria o `InkWell` sempre que há `aoTocar` (antes só com `naVitrine`); `AcervoScreen` troca `aoAbrirImovel`/`abrirDetalheImovel` por `aoAbrirGestao`/`abrirGestaoImovel`, sem manter o nome antigo, e passa o `ImovelAcervo` inteiro (com `naVitrine`). Fluxo próprio prova o toque num cartão que o servidor marca `na_vitrine: false`.
- `GestaoImovelCubit` (`@injectable`): `carregar(id)` guarda o id, incrementa `_versao`, emite carregando e decide por `switch` no `Result`; `tentarNovamente()` repete com o id guardado; `isClosed` antes de todo `emit`. Provado por `bloc_test` (carregado, erro, retry, resposta antiga descartada, nada emitido depois de `close()`).
- Pilha de teste: `ApiFalsa` serve `GET /api/imoveis/<id>/` (401 sem token, 404 com `erro_404_imovel.json` para id sem fixture) e `PilhaReal.entrarNoAcervo(tester)`; `conferirCabecalhosDeAutorizacao` trata todo caminho `/api/imoveis/...` como autenticado (T-09-04).
- `flutter analyze lib` limpo; `flutter test` inteiro verde: **1267** (1256 antes deste plano + 11).

## Task Commits

1. **Task 1: TRACER de UI — tocar em qualquer cartão do acervo abre a tela de gestão** - `d0f4499` (feat; tracer, testes primeiro)
2. **Task 2: Cubit da tela com versão de consulta e "Tentar de novo" na primeira carga** - `937b797` (test; ver "Deviations")

**Plan metadata:** commit docs(09-05) logo após este SUMMARY.

## Files Created/Modified

- `lib/presentation/gestao_imovel/gestao_imovel_state.dart` (+ `.freezed.dart`) - `GestaoImovelState` e a união `ConteudoImovelGestao` (`ImovelGestaoCarregando`, `ImovelGestaoCarregado`, `ImovelGestaoErro`)
- `lib/presentation/gestao_imovel/gestao_imovel_cubit.dart` - `GestaoImovelCubit` com `carregar`, `tentarNovamente`, `_versao` e `isClosed`
- `lib/presentation/gestao_imovel/gestao_imovel_screen.dart` - `AoAbrirGestao`, `abrirGestaoImovel` e `GestaoImovelScreen` (`switch` exaustivo, `_CorpoDaGestao`, `_ErroDaGestao`)
- `lib/presentation/gestao_imovel/apresentacao_gestao.dart` - `textoErroGestao` e `rotuloTentarDeNovo`
- `lib/presentation/acervo/acervo_screen.dart` - `aoAbrirGestao` no lugar de `aoAbrirImovel`; import do detalhe removido
- `lib/presentation/acervo/widgets/cartao_imovel_acervo.dart` - `InkWell` em todo cartão com `aoTocar`; comentário cita o D-02 da Fase 9
- `lib/di/injection.config.dart` - registro do `GestaoImovelCubit` (único gerado tracked que mudou; nenhum só-CRLF para restaurar)
- `test/support/api_falsa.dart`, `test/support/pilha_real.dart` - rota da gestão, `entrarNoAcervo`, autorização em todo `/api/imoveis/...`
- `test/presentation/gestao_imovel_fluxo_test.dart`, `gestao_imovel_cubit_test.dart` - fluxo na pilha real (3 casos) e `bloc_test` (7 casos)
- `test/presentation/cartao_imovel_acervo_test.dart`, `acervo_screen_test.dart` - casos D-07 invertidos para o D-02 da Fase 9

## Decisions Made

- O abridor faz `await Navigator.push(...)` e depois `cubit.close()`, sem `try/finally`: a regra do plano é "sem `try/catch` na UI" e o custo de não fechar o Cubit numa exceção do próprio `push` é desprezível.
- Título da `AppBar` = código do imóvel (discrição registrada no plano); o título do imóvel aparece no corpo em `textTheme.titleLarge` e a situação em `titleMedium` só quando conhecida.
- A `ApiFalsa` escolhe a fixture da gestão por `id`, na ordem alfabética (`disponivel` antes de `reservado`), no mesmo molde de `_fixtureDoDetalhe`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Comentário de biblioteca solto em `apresentacao_gestao.dart`**
- **Found during:** Task 1 (`flutter analyze lib`)
- **Issue:** sem imports no arquivo, o primeiro bloco `///` virou `dangling_library_doc_comments` (o molde `apresentacao_acervo.dart` tem imports antes e não sofre disso)
- **Fix:** o bloco introdutório virou comentário `//`
- **Files modified:** `lib/presentation/gestao_imovel/apresentacao_gestao.dart`
- **Verification:** `flutter analyze lib` → No issues found
- **Committed in:** `d0f4499` (commit da Task 1)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** trivial, sem mudança de escopo.

### Observação de processo (não é desvio de escopo)

A ação da Task 1 já especificava o Cubit completo (versão de leitura, `isClosed`, `tentarNovamente`), então a Task 2 (`tdd="true"`) não teve RED genuíno: os testes novos passaram de primeira contra o código do tracer. Para não deixar testes que passam por acaso, fiz mutação manual: remover a guarda `minhaVersao != _versao` quebra o teste "resposta de uma carga antiga é descartada", e remover `isClosed` quebra "depois de close() nenhuma emissão acontece" (StateError em `BlocBase.emit`). Os dois códigos foram restaurados com `git checkout -- <arquivo>`. No tracer, o RED foi só o "falha ao carregar" do arquivo de fluxo (importava arquivos inexistentes) antes da implementação.

## Issues Encountered

None.

## Verificação

- Tracer (Task 1): `flutter test` dos quatro arquivos (fluxo da gestão, cartão, tela e fluxo do acervo) verde, `flutter analyze lib` limpo e o gate de `grep` (DI, `aoAbrirGestao`, ausência de `aoAbrirImovel` no acervo, `abrirGestaoImovel`, `/api/imoveis/` na pilha) passou. Feedback gate do tracer (modo interativo, `end-of-phase`, `<verify>` só automatizado): `<verify>` re-executado de ponta a ponta com sucesso antes de seguir para a Task 2.
- Task 2: `gestao_imovel_cubit_test.dart` + `gestao_imovel_fluxo_test.dart` verdes (10 casos); gate de `grep` (`_versao`, `isClosed`, `tentarNovamente` na tela) passou; `flutter analyze lib` limpo.
- Fim da onda 3 (D-16): `flutter test` inteiro, **1267 verdes**.
- Nenhum gerado só-CRLF deixado modificado; nenhum push.

## Threat Flags

None - nenhuma superfície nova além da planejada (T-09-04 coberto por `conferirCabecalhosDeAutorizacao` em todo `/api/imoveis/...`; T-09-02 o abridor só recebe o `ImovelAcervo` do próprio acervo; T-09-03 resposta vencida descartada por teste; T-09-05 a tela só mostra `textoErroGestao`; T-09-SC nenhum pacote novo).

## Known Stubs

Nenhum stub que impeça o objetivo do plano. A `GestaoImovelScreen` é deliberadamente um esqueleto (título e situação): histórico, "Mudar situação" e "Ver na vitrine" entram nos planos 09-06 a 09-08, conforme a ordem da fase. O parâmetro `previa` só alimenta o título da `AppBar` por enquanto.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 09-06 (histórico) e 09-07 (tela de gestão completa) já têm abridor, Cubit, estado e a tela sobre a pilha real; o estado ganha as seções de histórico e de envio nesses planos.
- O 09-10 (recarga do acervo ao voltar) vai trocar o retorno `Future<void>` do abridor pelo `bool` lido do Cubit (RESEARCH, Pattern 5), mexendo em `AoAbrirGestao` e no toque do cartão.
- Commits locais em `feat/APP09`; nenhum push.

## Self-Check: PASSED

- Os 7 arquivos criados existem em disco (verificados com `[ -f ]`).
- Commits `d0f4499` e `937b797` existem em `feat/APP09`; `git rev-list --count fc7f8ec..HEAD` = 2.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
