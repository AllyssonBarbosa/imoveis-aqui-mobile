---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 08
subsystem: presentation
tags: [cubit, freezed, caixa-contatos, tela, rolagem-infinita, sessao-expirada, fluxo-ponta-a-ponta]

requires:
  - phase: 10-06
    provides: "BuscarContatosUseCase, ObterSemRetornoUseCase, rotas da caixa na ApiFalsa"
  - phase: 10-07
    provides: "ItemContato, apresentacao_contatos.dart, RodapePaginacaoLista.mensagemErro, pt-BR do Material"
provides:
  - "CaixaContatosState (consulta, semRetorno, conteudo) e ConteudoCaixa (6 variantes)"
  - "CaixaContatosCubit: carregar, carregarMais, tentarNovamente; versao da consulta e do resumo; 401 terminal"
  - "CaixaContatosScreen, AoAbrirCaixaContatos e abrirCaixaContatos"
  - "icone 'Meus contatos' (Icons.inbox_outlined) na AppBar do acervo, antes do Sair, destino injetavel"
  - "fluxo ponta a ponta base da caixa sobre a pilha real (lista, numero, pagina 2, 401, token)"
affects: [10-09, 10-10]

commits: 5
plan_head_before: 55cd54b31f6e9096133be885e80cdd90ab9d0587
plan_head_after: 2fde07989d75a31f246773cc16f11bcbe793d107

estimate_actuals_note: "tokens = chars/4 sobre o diff do app 55cd54b..2fde079 fora de .planning (90020 chars, inclui os testes)"
actuals:
  tokens: 22505
  tasks: 3
  commits: 5

tech-stack:
  added: []
  patterns:
    - "Cubit com dois pedidos independentes (lista e contagem), cada um com seu token de versao"
    - "Estado terminal (CaixaSessaoExpirada): toda continuacao assincrona confere e retorna sem emitir"
    - "copyWith (nunca estado novo) ao trocar de consulta, para nao apagar o numero do servidor"
    - "Destino de navegacao injetado por callback padrao (aoAbrirContatos = abrirCaixaContatos)"

key-files:
  created:
    - lib/presentation/contatos/caixa_contatos_state.dart
    - lib/presentation/contatos/caixa_contatos_state.freezed.dart
    - lib/presentation/contatos/caixa_contatos_cubit.dart
    - lib/presentation/contatos/caixa_contatos_screen.dart
    - test/presentation/caixa_contatos_cubit_test.dart
    - test/presentation/caixa_contatos_screen_test.dart
    - test/presentation/caixa_contatos_fluxo_test.dart
  modified:
    - lib/presentation/acervo/acervo_screen.dart
    - lib/di/injection.config.dart
    - test/presentation/acervo_screen_test.dart
    - test/support/pilha_real.dart

key-decisions:
  - "Um unico Cubit para a tela inteira (A7): lista e contagem agora, filtros no 10-09 e anotacao no 10-10, com um so caminho de 401"
  - "O numero de sem retorno so recebe o inteiro do ObterSemRetornoUseCase; nenhuma aritmetica no Cubit nem na tela (T-10-20)"
  - "Linha do numero com Icons.mark_email_unread_outlined e cores do ColorScheme; escolha de Claude's Discretion, a confirmar no human-check do fim da fase"
  - "Itens da lista com ValueKey('contato-<id>'), que o fluxo ponta a ponta usa para achar itens sem depender de texto repetido (varios contatos do mesmo imovel)"

requirements-completed: []

coverage:
  - id: D1
    description: "Cubit da caixa entrega lista paginada na ordem do servidor (dedupe por id, erroAoCarregarMais, retry so da mesma pagina) e o numero de sem retorno que falha sozinho sem derrubar a lista"
    requirement: "CXA-01"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_cubit_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Linha 'N contatos sem retorno' logo abaixo da AppBar com o numero vindo do servidor (plural, singular, zero, ausente) e nunca calculado no app"
    requirement: "CXA-05"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_screen_test.dart#linha do numero"
        status: pass
      - kind: test
        ref: "test/presentation/caixa_contatos_fluxo_test.dart#acervo -> icone Meus contatos"
        status: pass
    human_judgment: false
  - id: D3
    description: "Entrada pelo icone 'Meus contatos' do acervo, estados com texto fixo e 401 em qualquer pedido da caixa levando ao login com aviso, so a vitrine embaixo"
    requirement: "CXA-06"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_screen_test.dart"
        status: pass
      - kind: test
        ref: "test/presentation/acervo_screen_test.dart#entrada Meus contatos"
        status: pass
      - kind: test
        ref: "test/presentation/caixa_contatos_fluxo_test.dart#401 na lista"
        status: pass
    human_judgment: false
  - id: D4
    description: "Escolha do icone de caixa de entrada e do icone da linha do numero, e o aspecto da tela"
    requirement: "CXA-01"
    verification: []
    human_judgment: true
    rationale: "Escolhas visuais de Claude's Discretion, confirmadas no human-check do fim da fase"

duration: 55min
completed: 2026-11-23
status: complete
---

# Phase 10 Plan 08: Caixa de contatos — Cubit, tela e entrada no acervo Summary

**`CaixaContatosCubit` com estado freezed e dois pedidos independentes (lista paginada e numero de sem retorno do servidor, cada um com seu token de versao e 401 terminal), `CaixaContatosScreen` com linha do numero, rolagem infinita e textos fixos, o icone "Meus contatos" no acervo e o fluxo ponta a ponta sobre o DI de producao.**

## Performance

- **Duration:** ~55 min
- **Tasks:** 3 (Tasks 1 e 2 em TDD com RED e GREEN commitados separados; Task 3 so de teste)
- **Files:** 11 (7 criados, 4 modificados)

## Accomplishments

- `CaixaContatosState` (`consulta`, `semRetorno` nulo = ainda nao veio ou falhou, `conteudo`) e `ConteudoCaixa` com `carregando/vazio/semResultado/erro/sessaoExpirada/carregada`. A consulta troca por `copyWith`, entao o numero sobrevive (D-05).
- `CaixaContatosCubit`: `carregar` dispara lista e resumo juntos; `tentarNovamente` em `CaixaErro` repete a consulta E o resumo (D-22), em `erroAoCarregarMais` repete so a mesma pagina; `carregarMais` com dedupe por id; `_versaoConsulta` descarta lista antiga, `_versaoResumo` impede que numero antigo cubra o novo; `CaixaSessaoExpirada` e terminal (resposta tardia de lista ou resumo nao a desfaz); nenhum `try`/`catch`, decisao so pelo tipo da falha.
- `CaixaContatosScreen`: titulo "Meus contatos", linha do numero (`textoSemRetorno`) so quando `semRetorno != null`, `switch` exaustivo sobre `ConteudoCaixa`, `ListView.builder` com `ItemContato` e `RodapePaginacaoLista(mensagemErro: textoErroAoCarregarMaisContatos)`, rolagem a 90% e auto-carga quando a lista nao enche a tela (Pitfall 7), `BlocListener` de sessao expirada que encerra a sessao e abre o login com `avisoSessaoTerminou` via `pushAndRemoveUntil(eRotaDaVitrine)`.
- `AcervoScreen`: parametro `aoAbrirContatos` (padrao `abrirCaixaContatos`) e `IconButton(Icons.inbox_outlined, tooltip: 'Meus contatos')` antes do Sair, sem selo (D-01, D-02).
- Fluxo ponta a ponta sobre a pilha real: acervo -> ícone -> primeiro item e numero lidos de `contatos_p1.json`/`contatos_resumo.json` -> voltar ao acervo; rolar ate o ultimo item de `contatos_p2.json` com `page=2` pela URL `next`; 401 -> login com aviso e token apagado; toda requisicao `/api/contatos/...` com `Authorization: Token ...`. O teste foi visto falhar ao desligar o tooltip do ícone.

## Task Commits

1. **Task 1 (RED)** - `2f57f51` (test)
2. **Task 1 (GREEN)** - `73fc14b` (feat)
3. **Task 2 (RED)** - `4ba5c3a` (test)
4. **Task 2 (GREEN)** - `8c44214` (feat)
5. **Task 3** - `2fde079` (test)

**Plan metadata:** commit `docs(10-08)` (este SUMMARY + STATE + ROADMAP).

## Verification

- `flutter test` dos testes do Cubit, da tela, do acervo, do item e do fluxo (mais `acervo_cubit_test` e `acervo_fluxo_test`): verdes.
- Gate da onda 8 (D-29): `flutter analyze lib --no-fatal-infos` sai 0, 0 errors/warnings, 44 infos (41 pre-existentes + 3 do `material.dart` dos arquivos novos da fase: `item_contato.dart`, `seletor_periodo.dart` e `caixa_contatos_screen.dart`), 0 infos fora do `material.dart`. `flutter analyze --no-fatal-infos lib test`: 78 infos, 0 errors/warnings, 0 infos fora do `material.dart`. `flutter test` inteiro: **1419 verdes** (1374 + 45 novos).
- Greps dos `<automated>` das tres tasks: todos passam.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `PilhaReal.conferirCabecalhosDeAutorizacao` nao conhecia as rotas da caixa**
- **Found during:** Task 3
- **Issue:** o conferidor da pilha real so tratava `eu`, `sair` e `/api/imoveis/` como autenticadas; qualquer `/api/contatos/...` era exigida SEM token, o que faria o conferidor falhar em todo fluxo da caixa (este e os do 10-09/10-10).
- **Fix:** `caminho.startsWith('/api/contatos/')` na lista de rotas autenticadas e comentario atualizado. Arquivo fora do `files_modified` do plano, mas pre-requisito do fluxo.
- **Files modified:** `test/support/pilha_real.dart`
- **Commit:** `2fde079`

**Total deviations:** 1 auto-fixed (1 blocking). **Impact:** nenhum no escopo ou nos contratos do plano.

Detalhe de execucao: `dart run build_runner build -d` reescreveu com LF todos os gerados pre-existentes; foram restaurados com `git checkout --` (D-29), e `lib/di/injection.config.dart` (+8 linhas, so o registro do Cubit) e o novo `caixa_contatos_state.freezed.dart` ficaram em CRLF. Nenhum arquivo foi deletado pelos commits.

## Issues Encountered

None.

## Known Stubs

None. O toque no item ainda nao faz nada (`aoTocar` nulo) por desenho do plano: a anotacao do retorno (D-11, D-14) entra no 10-10 preenchendo esse callback.

## Threat Flags

None - T-10-18 (401 na lista, na pagina seguinte ou na contagem: estado terminal + listener + login com aviso, provado em Cubit, tela e fluxo), T-10-20 (numero so do servidor, sem aritmetica; teste de versao do resumo e fluxo lendo o esperado da fixture), T-10-21 (aceito: entrada so no `AcervoScreen`) e T-10-SC (nenhum pacote novo) conforme o plano.

## Next Phase Readiness

Pronto para o 10-09: o Cubit ja guarda `consulta` e reaplica por `_aplicarConsulta` (que preserva o numero); a tela ja volta ao topo quando o conteudo volta a `CaixaCarregando`; o fluxo ponta a ponta esta num `group` que o 10-09 e o 10-10 estendem. O icone `Icons.inbox_outlined` e o da linha do numero ficam para o human-check do fim da fase. Nenhum `git push`.

## Self-Check: PASSED

- Os 11 arquivos existem; commits `2f57f51`, `73fc14b`, `4ba5c3a`, `8c44214` e `2fde079` presentes na `feat/APP10`; `git rev-list --count 55cd54b..HEAD` = 5 antes deste SUMMARY.
