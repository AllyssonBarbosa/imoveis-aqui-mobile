---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 08
subsystem: ui
tags: [flutter, dart, cubit, freezed, refresh-indicator, sessao-expirada, gestao]

requires:
  - phase: 09-mudança-de-situação (09-05)
    provides: GestaoImovelCubit/State, abrirGestaoImovel, GestaoImovelScreen, PilhaReal.entrarNoAcervo
  - phase: 09-mudança-de-situação (09-07)
    provides: leitura paralela de imóvel e histórico, tentarNovamenteHistorico, HistoricoSituacao
  - phase: 08-acervo
    provides: padrão de sessão expirada (SessaoCubit.encerrarPorExpiracao, LoginScreen(aviso), eRotaDaVitrine)
provides:
  - "voltarAoLoginComSessaoTerminada(BuildContext): caminho único de volta ao login por 401, usado pelo acervo e pela gestão"
  - "ConteudoImovelGestao.naoEncontrado e .sessaoExpirada; 401 em qualquer das duas leituras vale para a tela toda; 404 só do histórico vira falha do histórico"
  - "Textos fixos em português: textoImovelForaDoAcervo e textoFalhaAoAtualizar (o detail do Django nunca aparece)"
  - "GestaoImovelCubit.recarregar(): releitura sem emitir carregando, que mantém o conteúdo numa falha e conta falhasAoAtualizar"
  - "RefreshIndicator na tela de gestão e SnackBar de falha de atualização"
affects: [09-09 desfechos da mudança, 09-10 recarga depois de uma mudança (usa recarregar()), 09-13]

actuals:
  tokens: 7700
  tasks: 2
  commits: 2
plan_head_before: 52fdb3afa8928b47b5da6e62f8182c8b602a1f0f

tech-stack:
  added: []
  patterns:
    - "Helper único de sessão expirada em presentation/sessao/, chamado por BlocListener com listenWhen de transição"
    - "Mapeamento único de falha por tipo no Cubit (SessaoExpiradaException, ImovelNaoEncontradoException, demais) — sem try/catch na UI"
    - "recarregar() mantém o conteúdo na falha e aumenta um contador (falhasAoAtualizar); a tela reage ao aumento com SnackBar"
    - "Tela confere também o estado já presente ao abrir (o abridor pede a leitura antes de empurrar a rota, e o BlocListener só vê transições)"

key-files:
  created:
    - lib/presentation/sessao/sessao_expirada.dart
  modified:
    - lib/presentation/gestao_imovel/gestao_imovel_state.dart
    - lib/presentation/gestao_imovel/gestao_imovel_state.freezed.dart
    - lib/presentation/gestao_imovel/gestao_imovel_cubit.dart
    - lib/presentation/gestao_imovel/gestao_imovel_screen.dart
    - lib/presentation/gestao_imovel/apresentacao_gestao.dart
    - lib/presentation/acervo/acervo_screen.dart
    - test/presentation/gestao_imovel_cubit_test.dart
    - test/presentation/gestao_imovel_screen_test.dart
    - test/presentation/gestao_imovel_fluxo_test.dart

key-decisions:
  - "401 em qualquer das duas leituras (imóvel, histórico, e também a repetição do histórico) leva a tela toda para sessão expirada; 404 só do histórico é falha do histórico (discrição do CONTEXT)"
  - "Falha de recarregar() só do histórico, com histórico já na tela, troca o imóvel lido, mantém o histórico anterior e conta a falha"
  - "GestaoImovelScreen virou StatefulWidget só para tratar sessão já expirada na abertura (resposta antes do primeiro quadro), sem duplicar a navegação"

patterns-established:
  - "Um helper de navegação compartilhado em vez de método privado copiado por tela"
  - "Falha de atualização = contador + SnackBar, nunca estado montado no app (AC-2)"

requirements-completed: [SIT-04, SIT-02]

coverage:
  - id: D1
    description: "404 na leitura do imóvel mostra 'Este imóvel não está mais no seu acervo.' sem 'Tentar de novo' e sem texto em inglês"
    requirement: SIT-04
    verification:
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#404 na leitura do imóvel mostra o texto fixo em português e nenhum texto em inglês"
        status: pass
      - kind: unit
        ref: "test/presentation/gestao_imovel_screen_test.dart#não encontrado: texto fixo em português, sem Tentar de novo"
        status: pass
    human_judgment: false
  - id: D2
    description: "401 em qualquer das duas leituras apaga o token e volta ao login com 'Sua sessão terminou. Entre de novo.', só com a vitrine embaixo"
    requirement: SIT-04
    verification:
      - kind: integration
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#401 na leitura do imóvel leva ao login / #401 só na leitura do histórico"
        status: pass
      - kind: unit
        ref: "test/presentation/gestao_imovel_cubit_test.dart#401 no imóvel / 401 só no histórico / 401 ao repetir o histórico"
        status: pass
    human_judgment: false
  - id: D3
    description: "Helper único voltarAoLoginComSessaoTerminada usado por acervo e gestão; os testes do acervo passam sem mudança de expectativa"
    requirement: SIT-04
    verification:
      - kind: unit
        ref: "test/presentation/acervo_screen_test.dart#Sair e sessão terminada (08-10)"
        status: pass
      - kind: integration
        ref: "test/presentation/acervo_fluxo_test.dart#401 no acervo leva ao login"
        status: pass
    human_judgment: false
  - id: D4
    description: "recarregar() relê imóvel e histórico sem apagar o conteúdo; falha mantém o anterior e conta falhasAoAtualizar"
    requirement: SIT-02
    verification:
      - kind: unit
        ref: "test/presentation/gestao_imovel_cubit_test.dart#recarregar (puxar para atualizar)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Puxar para atualizar (RefreshIndicator) chama recarregar() e a falha mostra o SnackBar 'Não foi possível atualizar agora.'"
    requirement: SIT-02
    verification:
      - kind: unit
        ref: "test/presentation/gestao_imovel_screen_test.dart#arrastar para baixo (RefreshIndicator) chama recarregar() / falhasAoAtualizar aumentando mostra o SnackBar"
        status: pass
    human_judgment: true
    rationale: "O gesto de puxar e o aparecimento do SnackBar em aparelho real (sensação, posição, duração) dependem de olho humano; o human-check de fim de fase cobre"

duration: 40min
completed: 2026-11-22
status: complete
---

# Phase 9 Plan 08: Desfechos de leitura e puxar para atualizar Summary

**Tela de gestão com 404 em português fixo, 401 de volta ao login por um helper único compartilhado com o acervo, e "puxar para atualizar" via `GestaoImovelCubit.recarregar()` que mantém o conteúdo e avisa por SnackBar quando falha**

## Performance

- **Duration:** ~40 min
- **Completed:** 2026-11-22
- **Tasks:** 2
- **Files modified:** 10 (1 criado, 9 alterados)

## Accomplishments

- `voltarAoLoginComSessaoTerminada` em `lib/presentation/sessao/sessao_expirada.dart`: captura `Navigator` e `SessaoCubit` antes do `await`, chama `encerrarPorExpiracao()`, confere `navegador.mounted` e faz `pushAndRemoveUntil` até `eRotaDaVitrine`. O método privado do acervo foi apagado; acervo e gestão usam o mesmo helper.
- `ConteudoImovelGestao` ganhou `naoEncontrado()` e `sessaoExpirada()`. O Cubit tem um mapeamento único de falha por tipo; 401 do histórico (na carga, no `recarregar()` e em `tentarNovamenteHistorico()`) leva a tela toda para sessão expirada, e 404 só do histórico vira `HistoricoErro` com o imóvel carregado.
- A tela mostra "Este imóvel não está mais no seu acervo." (sem "Tentar de novo") e, na transição para sessão expirada, abre o login com "Sua sessão terminou. Entre de novo.". O `detail` em inglês do Django nunca é usado como texto de UI (gate de `grep` e fluxo conferem).
- `recarregar()`: relê os dois em paralelo sem emitir `carregando`; no sucesso troca imóvel e histórico pelos lidos; falha genérica com conteúdo mantém tudo e soma 1 em `falhasAoAtualizar`; sem conteúdo anterior aplica o desfecho normal; 401 e 404 viram sessão expirada e não encontrado. É o caminho único de releitura que o 09-10 vai usar.
- `RefreshIndicator(onRefresh: recarregar)` com `AlwaysScrollableScrollPhysics` e um segundo `BlocListener` que mostra o SnackBar "Não foi possível atualizar agora." a cada aumento de `falhasAoAtualizar`.

## Task Commits

1. **Task 1: 404 com texto fixo e 401 de volta ao login por helper compartilhado (D-10)** - `9543f6a` (feat)
2. **Task 2: Puxar para atualizar com recarregar() (D-10, AC-2)** - `32fe053` (feat)

**Plan metadata:** commit docs deste SUMMARY, STATE e ROADMAP (a seguir).

_Os testes foram escritos antes da implementação em cada tarefa (RED confirmado: suítes não carregavam sem os tipos novos), e commitados junto com a implementação, como nos planos anteriores da fase._

## Files Created/Modified

- `lib/presentation/sessao/sessao_expirada.dart` - helper único de volta ao login por sessão terminada
- `lib/presentation/acervo/acervo_screen.dart` - usa o helper; método privado e imports de login/rota/sessão removidos
- `lib/presentation/gestao_imovel/gestao_imovel_state.dart` (+ `.freezed.dart`) - variantes `naoEncontrado`/`sessaoExpirada` e campo `falhasAoAtualizar`
- `lib/presentation/gestao_imovel/gestao_imovel_cubit.dart` - mapeamento único por tipo, `recarregar()`, 401 do histórico
- `lib/presentation/gestao_imovel/gestao_imovel_screen.dart` - dois `BlocListener`, `RefreshIndicator`, mensagens fixas, conferência do estado na abertura
- `lib/presentation/gestao_imovel/apresentacao_gestao.dart` - `textoImovelForaDoAcervo`, `textoFalhaAoAtualizar`
- `test/presentation/gestao_imovel_cubit_test.dart`, `gestao_imovel_screen_test.dart`, `gestao_imovel_fluxo_test.dart` - casos novos de 404, 401, recarregar, SnackBar e pull-to-refresh

## Decisions Made

- 401 em qualquer leitura vale para a tela toda (discrição registrada no CONTEXT), inclusive o 401 da repetição só do histórico, para nunca deixar a tela viva depois do servidor recusar o token.
- Falha só do histórico em `recarregar()` com histórico já na tela: o imóvel lido entra, o histórico anterior fica e a falha é contada (cada um dos dois mostra sempre o último que a API devolveu; nada é montado no app).
- `GestaoImovelScreen` virou `StatefulWidget` para tratar o 401 que chega antes do primeiro quadro (ver desvio 1).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] 401 chegando antes de a tela existir não levava ao login**
- **Found during:** Task 1 (teste de fluxo do 401 na pilha real)
- **Issue:** o abridor chama `carregar()` antes de empurrar a rota; se a resposta 401 chega antes do primeiro quadro, o `BlocListener` (que só enxerga transições a partir do estado em que se inscreveu) nunca dispara. A tela ficava mostrando o aviso, sem navegar e com o token já apagado.
- **Fix:** `GestaoImovelScreen` passou a `StatefulWidget` com `initState` que, se o estado já for sessão expirada, agenda a navegação no primeiro pós-quadro. Sem navegação dupla (o listener parte desse mesmo estado). Teste de widget novo cobre o caso.
- **Files modified:** `lib/presentation/gestao_imovel/gestao_imovel_screen.dart`, `test/presentation/gestao_imovel_screen_test.dart`
- **Verification:** fluxos do 401 (imóvel e histórico) e teste de widget passam
- **Committed in:** `9543f6a` (Task 1)

**2. [Rule 2 - Missing Critical] 401 da repetição só do histórico**
- **Found during:** Task 1
- **Issue:** o plano trata o 401 na carga; `tentarNovamenteHistorico()` ignoraria um 401 e deixaria a tela viva depois de o servidor recusar o token.
- **Fix:** a repetição do histórico também leva a tela para sessão expirada; teste de Cubit novo.
- **Files modified:** `lib/presentation/gestao_imovel/gestao_imovel_cubit.dart`, `test/presentation/gestao_imovel_cubit_test.dart`
- **Committed in:** `9543f6a` (Task 1)

---

**Total deviations:** 2 auto-fixed (1 bug, 1 missing critical)
**Impact on plan:** ambos necessários para o 401 sempre terminar a sessão (T-09-08); sem aumento de escopo.

## Issues Encountered

- O `dart format lib/presentation` reformatou arquivos fora do plano (vitrine, `apresentacao_natureza.dart`); foram restaurados com `git checkout --` dos arquivos específicos antes do commit, e nada fora do plano entrou nos commits.

## Verificação

- `flutter analyze lib`: No issues found!
- `flutter test` inteiro: 1343 testes verdes (fim da onda 6, D-16).
- Gates de `grep` das duas tarefas passam (helper usado nas duas telas, método privado antigo removido, sem o texto do Django em `apresentacao_gestao.dart`, `RefreshIndicator`/`recarregar()`/`falhasAoAtualizar` presentes).
- Nenhum gerado só-CRLF deixado modificado; nenhum push.

## Known Stubs

None - nenhum stub, placeholder ou dado vazio ligado à UI foi introduzido.

## Threat Flags

None - nenhuma superfície nova além da planejada (T-09-03 `recarregar()` só troca o conteúdo pelo que a API devolveu e falha mantém o anterior, provado em teste de Cubit; T-09-08 helper apaga o token e abre o login com a vitrine embaixo, provado em fluxo com o armazenamento vazio; T-09-05 só textos fixos, fluxo confere ausência de inglês; T-09-SC nenhum pacote novo).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `recarregar()` e `falhasAoAtualizar` prontos para o 09-10 recarregar a tela depois de uma mudança de situação.
- O helper único de sessão expirada já serve a qualquer tela autenticada nova da fase (ex.: o desfecho 401 da mudança de situação no 09-09).

## Self-Check: PASSED

- `lib/presentation/sessao/sessao_expirada.dart` existe; commits `9543f6a` e `32fe053` existem em `feat/APP09`; `commits: 2` medido de `52fdb3a..HEAD`.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
