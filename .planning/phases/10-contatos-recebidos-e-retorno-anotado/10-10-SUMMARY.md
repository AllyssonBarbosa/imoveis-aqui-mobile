---
phase: 10-contatos-recebidos-e-retorno-anotado
plan: 10
subsystem: presentation
tags: [cubit, freezed, caixa-contatos, anotar-retorno, bottom-sheet, snackbar, fluxo-ponta-a-ponta, fechamento-de-fase]

requires:
  - phase: 10-06
    provides: "AnotarRetornoUseCase, ContatoNaoEncontradoException, rota PATCH e o resumo 'apos' na ApiFalsa"
  - phase: 10-08
    provides: "CaixaContatosCubit/State/Screen, listener de sessao expirada, fluxo ponta a ponta da caixa"
  - phase: 10-09
    provides: "_trocarConsulta, tokens de versao, opcoes de imovel, grupo 'Caixa de contatos ponta a ponta'"
provides:
  - "CaixaContatosCubit.anotarRetorno(id, retorno): item em voo, troca pelo item do servidor, resumo pedido de novo, aviso one-shot, 404 recarrega, 401 terminal"
  - "AvisoCaixa (falhouAoAnotar, contatoSumiu) e CaixaCarregada.anotando no CaixaContatosState"
  - "mostrarFolhaAnotarRetorno (4 opcoes anotaveis, atual marcada, um toque grava)"
  - "ItemContato.anotando (LinearProgressIndicator + toque desligado)"
  - "CaixaContatosScreen: toque no item abre a folha; BlocListener do aviso -> SnackBar com texto fixo"
  - "fluxo ponta a ponta com anotacao 'Falei' e 404 sobre a pilha real"
  - "CXA-01..06, API-13 e API-14 completos em REQUIREMENTS.md"
affects: []

commits: 5
plan_head_before: 3778b863686287d01e4a258c72cd3d5612a03689
plan_head_after: c45d47bca872b197edaa55249802577bf0e157a2

estimate_actuals_note: "tokens = chars/4 sobre o diff do app 3778b86..c45d47b fora de .planning (76094 chars, inclui os testes)"
actuals:
  tokens: 19023
  tasks: 3
  commits: 5

tech-stack:
  added: []
  patterns:
    - "Aviso one-shot no estado: toda anotacao comeca limpando o aviso (aviso: null), entao duas falhas seguidas sao duas emissoes diferentes e o listenWhen (b.aviso != null && a.aviso != b.aviso) as dispara"
    - "Item em voo por Set<int> anotando dentro de CaixaCarregada; o item so muda com o 200 do servidor"
    - "Folha por valor: o callback aoEscolher vem da tela, a rota do modal fica fora do BlocProvider"

key-files:
  created:
    - lib/presentation/contatos/widgets/folha_anotar_retorno.dart
  modified:
    - lib/presentation/contatos/caixa_contatos_state.dart
    - lib/presentation/contatos/caixa_contatos_state.freezed.dart
    - lib/presentation/contatos/caixa_contatos_cubit.dart
    - lib/presentation/contatos/apresentacao_contatos.dart
    - lib/presentation/contatos/widgets/item_contato.dart
    - lib/presentation/contatos/caixa_contatos_screen.dart
    - lib/di/injection.config.dart
    - test/presentation/caixa_contatos_cubit_test.dart
    - test/presentation/apresentacao_contatos_test.dart
    - test/presentation/item_contato_test.dart
    - test/presentation/caixa_contatos_screen_test.dart
    - test/presentation/caixa_contatos_fluxo_test.dart
    - .planning/REQUIREMENTS.md

key-decisions:
  - "Sem atualizacao otimista (D-16): o retorno do item so muda no Success; durante o PATCH o id fica em anotando e o toque e ignorado no Cubit e desligado no item"
  - "Aviso de falha e do tipo da falha, nunca texto do servidor (D-17): ContatoNaoEncontradoException -> contatoSumiu (e recarrega lista e numero), SessaoExpiradaException -> CaixaSessaoExpirada terminal, demais -> falhouAoAnotar"
  - "Tocar a opcao que ja e a atual nao chama a API (A6); a guarda fica no Cubit, a folha continua marcando a atual e fechando"
  - "O resumo e pedido de novo depois de qualquer resposta do servidor (sucesso e 404), mesmo se a lista foi reiniciada por troca de filtro enquanto o PATCH estava em voo (Pitfall 3); nesse caso o item so e trocado se a lista atual ainda for CaixaCarregada com ele"

requirements-completed: [CXA-01, CXA-02, CXA-03, CXA-04, CXA-05, CXA-06, API-13, API-14]

coverage:
  - id: D1
    description: "Cubit anota o retorno esperando o servidor: item em voo, troca pelo item devolvido, numero de sem retorno pedido de novo (nunca somado/subtraido), sem emissao otimista"
    requirement: "CXA-03"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_cubit_test.dart#anotarRetorno (D-06, D-15, D-16, D-17, D-23)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Guardas do Cubit: duplo toque, opcao igual a atual (A6), id fora da lista, PENDENTE e estado sem lista nao chamam a API; contato ja anotado aceita outra opcao"
    requirement: "CXA-03"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_cubit_test.dart#anotarRetorno (D-06, D-15, D-16, D-17, D-23)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Falhas: generica e FormatException -> falhouAoAnotar, 404 -> contatoSumiu com lista e numero recarregados, 401 -> sessao expirada terminal; duas falhas seguidas emitem o aviso duas vezes"
    requirement: "CXA-03"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_cubit_test.dart#anotarRetorno (D-06, D-15, D-16, D-17, D-23)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Folha 'Anotar retorno' com exatamente as 4 opcoes anotaveis (sem Aguardando retorno, sem Salvar), atual marcada, um toque fecha e chama o Cubit uma vez"
    requirement: "CXA-03"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_screen_test.dart#anotar retorno (D-11, D-14, D-15, D-16, D-17)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Item em voo mostra LinearProgressIndicator e ignora o toque"
    requirement: "CXA-03"
    verification:
      - kind: test
        ref: "test/presentation/item_contato_test.dart#ItemContato em voo (D-16)"
        status: pass
      - kind: test
        ref: "test/presentation/caixa_contatos_screen_test.dart#item em voo mostra carregamento e nao abre a folha"
        status: pass
    human_judgment: false
  - id: D6
    description: "SnackBar com texto fixo (falhouAoAnotar e contatoSumiu), repetida numa segunda falha e nao repetida quando o mesmo aviso e mantido"
    requirement: "CXA-03"
    verification:
      - kind: test
        ref: "test/presentation/apresentacao_contatos_test.dart#anotar retorno (D-14, D-17)"
        status: pass
      - kind: test
        ref: "test/presentation/caixa_contatos_screen_test.dart#SnackBar do aviso (D-17)"
        status: pass
    human_judgment: false
  - id: D7
    description: "Fluxo ponta a ponta sobre o DI de producao: anotar Falei grava o PATCH {retorno: FALEI}, item mostra Falei e anotado em, numero vem de contatos_resumo_apos.json; 404 mostra o aviso e recarrega lista (sem page) e numero"
    requirement: "CXA-03"
    verification:
      - kind: test
        ref: "test/presentation/caixa_contatos_fluxo_test.dart#tocar o item -> Falei grava o PATCH"
        status: pass
      - kind: test
        ref: "test/presentation/caixa_contatos_fluxo_test.dart#404 ao anotar mostra Este contato nao esta mais na sua caixa."
        status: pass
    human_judgment: false
  - id: D8
    description: "Aspecto visual da caixa no aparelho (icone, cor do chip Aguardando retorno, textos longos, seletor pt-BR, anotar contra o Django real, hora x site)"
    requirement: "CXA-01"
    verification: []
    human_judgment: true
    rationale: "Escolhas visuais e de fuso que nenhum teste automatizado julga; roteiro de fim de fase abaixo (modo end-of-phase)"

duration: 10min
completed: 2026-11-24
status: complete
---

# Phase 10 Plan 10: Anotar retorno e fechamento da fase Summary

**O corretor anota o retorno de um contato com um toque na folha "Anotar retorno": o `CaixaContatosCubit` espera o servidor (item em voo, sem otimismo), troca o item pelo que o Django devolve e pede de novo o numero de sem retorno; falhas viram SnackBar com texto fixo (404 recarrega lista e numero, 401 volta ao login) e tudo e provado ponta a ponta sobre o DI de producao; CXA-01..06, API-13 e API-14 estao completos e os gates dos dois repositorios passam.**

## Performance

- **Duration:** ~10 min (2026-11-24T00:11Z a 00:21Z)
- **Tasks:** 3 (todas em TDD; Tasks 1 e 2 com RED e GREEN commitados separados)
- **Files:** 14 (1 criado, 13 modificados, contando 2 gerados e o REQUIREMENTS)

## Accomplishments

- `CaixaContatosState` ganha `AvisoCaixa? aviso` (one-shot da SnackBar) e `enum AvisoCaixa { falhouAoAnotar, contatoSumiu }`; `CaixaCarregada` ganha `Set<int> anotando` com `@Default`. `.freezed.dart` e `injection.config.dart` regenerados e commitados.
- `CaixaContatosCubit.anotarRetorno(int id, RetornoContato retorno)`: guardas (so `CaixaCarregada`, id nao em voo, opcao anotavel, item existe, retorno diferente do atual, `isClosed`), `emit` com o id em `anotando` e `aviso: null`, `await` do use case; `Success` troca o item por id e tira o id de `anotando`, e SEMPRE `unawaited(_recarregarResumo())`; `SessaoExpiradaException` vira `sessaoExpirada` terminal; `ContatoNaoEncontradoException` vira `contatoSumiu` e recarrega a lista (`_aplicarConsulta`) e o resumo; demais falhas viram `falhouAoAnotar`. Sem `try`, sem aritmetica no numero.
- `apresentacao_contatos.dart`: `tituloFolhaAnotarRetorno` e `textoDoAviso(AvisoCaixa)` com `switch` exaustivo e os dois textos fixos de D-17.
- `mostrarFolhaAnotarRetorno`: `showModalBottomSheet` com titulo, um `ListTile` por `RetornoContato.anotaveis`, check na atual, `onTap` fecha e entrega a escolha por callback; sem Salvar e sem confirmacao.
- `ItemContato.anotando`: `LinearProgressIndicator` no pe do cartao e `onTap: null`.
- `CaixaContatosScreen`: toque no item abre a folha (Cubit lido antes de abrir), item recebe `anotando`, e um segundo `BlocListener` (`listenWhen: atual.aviso != null && anterior.aviso != atual.aviso`) mostra a SnackBar com `if (state.aviso case final aviso?)`.
- Fluxo ponta a ponta: "Falei" no primeiro contato (PATCH `/api/contatos/26/` com `{'retorno': 'FALEI'}`, item com "Falei" e "anotado em <retorno_em local>", linha "24 contatos sem retorno" vinda de `contatos_resumo_apos.json`, um resumo a mais pedido) e 404 num outro contato (SnackBar fixa, lista sem `page` e resumo pedidos de novo, item segue "Aguardando retorno").
- REQUIREMENTS: CXA-01..06, API-13 e API-14 em `- [x]` e `Complete`; `Last updated` atualizado.

## Task Commits

1. **Task 1 (RED)** - `5a1a365` (test)
2. **Task 1 (GREEN)** - `139da32` (feat)
3. **Task 2 (RED)** - `cbca08b` (test)
4. **Task 2 (GREEN)** - `9d311cc` (feat)
5. **Task 3** - `c45d47b` (test: fluxo ponta a ponta + REQUIREMENTS)

**Plan metadata:** commit `docs(10-10)` (este SUMMARY + STATE + ROADMAP + REQUIREMENTS).

## TDD Gate Compliance

- **RED (Task 1):** `5a1a365` — o arquivo de testes do Cubit nao compila (faltam `anotarRetorno`, `AvisoCaixa`, `anotando` e o 4o argumento do construtor); a carga falha em "loading ...caixa_contatos_cubit_test.dart". `semanticAssessment`: e RED por simbolo ausente (build_failure), seguindo a precedente dos planos 10-06..10-09 neste projeto (RED so com testes, sem stub de producao); nenhum teste passou por engano. GREEN `139da32`: 55 testes verdes no arquivo.
- **RED (Task 2):** `cbca08b` — os testes da tela compilam (o estado ja existia) e 7 dos novos falharam em assercao (folha ausente, SnackBar ausente, sem `LinearProgressIndicator`); `item_contato_test.dart` e `apresentacao_contatos_test.dart` nao compilam por simbolo ausente (`anotando`, `textoDoAviso`, `tituloFolhaAnotarRetorno`). GREEN `9d311cc`: 69 testes verdes nos tres arquivos.
- **Task 3 (tdd="true", so teste/doc):** a producao ja existia dos GREENs anteriores, entao os dois casos novos passam de primeira. Prova de que pegam o defeito: com `aoTocar: null` na tela os dois falham (5 passam, 2 falham); restaurado, os 7 passam. Nao ha commit RED separado (a anotacao so existe depois das Tasks 1 e 2; comportamento do plano).
- Nenhum commit `refactor` (nada a limpar).

## Verification

- `flutter test` do Cubit (55), da tela, do item, da apresentacao (69 juntos) e do fluxo ponta a ponta (7): verdes.
- **Gate final da fase (D-29, a mao):**
  - `flutter analyze lib --no-fatal-infos`: exit 0, 0 errors/warnings, **47 infos** (46 do gate anterior + 1 do `material.dart` do arquivo novo `folha_anotar_retorno.dart`), 0 infos fora do `package:flutter/material.dart' is deprecated`.
  - `flutter analyze --no-fatal-infos lib test`: exit 0, **81 infos** (80 + 1), 0 errors/warnings.
  - `flutter test` inteiro: **1495 verdes** (1468 + 27 novos).
  - Suite Django completa (`Web`, `feat/APP10`): `Ran 766 tests ... OK`.
- Repositorios: web limpo (`git status --porcelain` vazio, `feat/APP10` em `d046bdc`) e sem `origin/feat/APP10`; app sem `origin/feat/APP10`; nenhum `git push` em nenhum dos dois; `.claude/CLAUDE.md` sem diff desde `825a113`.
- Greps dos `<automated>` das tasks 1 e 2 e a checagem dos 8 IDs no REQUIREMENTS: todos passam; gerados limpos depois do commit (`git status --porcelain` vazio para `*.freezed.dart`, `*.g.dart` e `injection.config.dart`).
- Roteiro `<human-check>` (modo `end-of-phase`): abaixo, **pendente de execucao humana** (nao bloqueia a onda).

## Roteiro de verificacao humana de fim de fase

Pre-requisitos: emulador Android; Django da `feat/APP10` num SQLite temporario semeado (`semear_vitrine_dev` + contatos criados pela rota publica).

1. Entrar como corretor -> "Meu acervo" -> o icone de caixa de entrada (`Icons.inbox_outlined`) ao lado do Sair, tooltip "Meus contatos", abre a caixa e o voltar retorna ao acervo. Como gestor a entrada nao aparece (tela de aviso da Phase 8). Conferir tambem o icone da linha "N contatos sem retorno" (`Icons.mark_email_unread_outlined`).
2. A cor do chip "Aguardando retorno" (`tertiaryContainer`/`onTertiaryContainer`) destaca os pendentes dentro do verde e branco do tema; titulos longos quebram em ate 2 linhas com reticencias; o texto de erro da folha de imovel ("Nao foi possivel carregar os imoveis.") e o check em "Todos os imoveis" estao aceitaveis; aparencia dos chips Imovel e Periodo.
3. O chip "Periodo" abre o seletor em portugues no aparelho; escolher um intervalo filtra a lista; o "x" limpa.
4. Anotar "Falei" num pendente: o item mostra o carregamento, o chip muda, aparece "anotado em ..." e o numero de sem retorno cai 1, vindo do servidor; trocar depois para "Visita agendada" funciona; tocar na opcao atual so fecha a folha. Derrubar o servidor e anotar: SnackBar "Nao foi possivel anotar o retorno. Tente de novo." e o item fica como estava. Anotar um contato removido: "Este contato nao esta mais na sua caixa." e a lista recarrega.
5. Com o aparelho no fuso de Brasilia, a hora de um contato no app bate com a da caixa do site (risco aceito A3 para outros fusos).

## Deviations from Plan

None - plan executed exactly as written.

Detalhes de execucao (nao sao desvios): `dart run build_runner build -d` reescreveu com LF todos os gerados pre-existentes; foram restaurados com `git checkout --` (D-29) e so `caixa_contatos_state.freezed.dart` e `lib/di/injection.config.dart` (registro do Cubit com o 4o argumento, e a ordem alfabetica do `AcervoCubit` mudou) ficaram, em CRLF. `dart format` foi aplicado so aos arquivos da fase; o diff de formatacao ficou restrito a trechos meus (a reindentacao do `build` da tela, por causa do `BlocListener` aninhado, e visivel no diff do `caixa_contatos_screen.dart`). Nenhum arquivo foi deletado pelos commits. O teste do item em voo usa `pump` com duracao em vez de `pumpAndSettle`, porque o indicador indeterminado anima sem parar.

## Issues Encountered

None.

## Known Stubs

None.

Observacao de comportamento (nao e stub): se o usuario trocar o filtro enquanto um PATCH esta em voo, a lista e reiniciada e `anotando` volta a vazio; o sucesso ainda pede o resumo e so troca o item se ele estiver na lista nova. Um segundo toque no mesmo contato nessa janela poderia iniciar outro PATCH, que o servidor trata normalmente (idempotente por valor). Coberto pelo caso "filtro trocado com o PATCH em voo".

## Threat Flags

None - T-10-25 (o retorno so muda com o 200 e o numero vem do servidor: testes de Cubit sem emissao otimista e fluxo ponta a ponta com o numero de `contatos_resumo_apos.json`), T-10-26 (`anotando` por id + item com toque desligado), T-10-27 (`textoDoAviso` com `switch` exaustivo e textos fixos), T-10-28 (401 -> `CaixaSessaoExpirada` terminal -> login com aviso, caso do 10-08) e T-10-SC (nenhum pacote novo) conforme o plano.

## Next Phase Readiness

Fase 10 completa no codigo: todos os 10 planos tem SUMMARY. Falta o fechamento da fase pelo orquestrador (verificacao da fase) e o roteiro humano acima. Nenhum `git push` foi feito; empurrar `feat/APP10` nos dois repositorios depende da autorizacao explicita do Allysson.

## Self-Check: PASSED

- Arquivo criado `lib/presentation/contatos/widgets/folha_anotar_retorno.dart` existe; os 13 modificados existem.
- Commits `5a1a365`, `139da32`, `cbca08b`, `9d311cc` e `c45d47b` presentes na `feat/APP10` (`git rev-list --count 3778b86..HEAD` = 5 antes deste SUMMARY).
- Os 8 IDs estao `- [x]` e `Complete` no REQUIREMENTS.
