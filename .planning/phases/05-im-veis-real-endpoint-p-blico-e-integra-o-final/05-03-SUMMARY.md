---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 03
subsystem: ui
tags: [flutter, clean-architecture, vitrine, entidade, a-06]

requires:
  - phase: 05-01
    provides: "Política de git da fase (app-a) e branch feat/APP05 no app"
provides:
  - "Imovel (item da vitrine) sem cidade — só o que o item da lista da W09 manda"
  - "rotuloLocalizacao(String bairro, Cidade? cidade) com cidade anulável"
  - "Prévia do detalhe só com o bairro; cabeçalho carregado com 'bairro · cidade, UF'"
affects: [05-09]

plan_head_before: 09eba48fcd0075871f34c8548ff8d9d0c493f391
actuals:
  tokens: 20000
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count 09eba48..HEAD antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Prova de 'só a cidade X' nos testes por ids servidos para a consulta (linhas do próprio mock), não por campo no item"

key-files:
  created: []
  modified:
    - lib/domain/entities/imovel.dart
    - lib/data/models/imovel_model.dart
    - lib/presentation/vitrine/apresentacao_imovel.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart
    - test/presentation/apresentacao_imovel_test.dart
    - test/presentation/imovel_card_test.dart
    - test/presentation/vitrine_screen_test.dart
    - test/presentation/vitrine_cubit_test.dart
    - test/presentation/detalhe_imovel_screen_test.dart
    - test/presentation/vitrine_fluxo_test.dart
    - test/presentation/detalhe_navegacao_test.dart

key-decisions:
  - "A-06 aplicada: Imovel.cidade removida; campos do ImovelModel ficam para o 05-09"
  - "Helper imovelDe(int id) em vitrine_cubit_test (sem parâmetro de cidade) e idsDaCidade(Cidade) em vitrine_fluxo_test, lido de linha['cidade'] do mock"

requirements-completed: []
requirements-note: "API-03 NÃO marcado aqui — fecha só no plano 05-18 (decisão do orquestrador)."

coverage:
  - id: D1
    description: "Imovel sem cidade; ImovelModel.paraEntidade não repassa cidade; nenhum Cubit/caso de uso mudou de contrato"
    requirement: API-03
    verification:
      - kind: other
        ref: "! grep -nE 'final Cid[a]de|this\\.cidad[e]' lib/domain/entities/imovel.dart (vazio); flutter analyze sem issues"
        status: pass
    human_judgment: false
  - id: D2
    description: "rotuloLocalizacao aceita cidade nula (4 casos); prévia do detalhe só com o bairro e cabeçalho carregado com a cidade"
    requirement: API-03
    verification:
      - kind: unit
        ref: "test/presentation/apresentacao_imovel_test.dart#rotuloLocalizacao"
        status: pass
      - kind: integration
        ref: "test/presentation/detalhe_navegacao_test.dart#tracer"
        status: pass
    human_judgment: false
  - id: D3
    description: "A cidade da vitrine vem da consulta/cabeçalho, nunca do item (ConsultaImoveis.cidade; ids servidos por cidade)"
    requirement: API-03
    verification:
      - kind: unit
        ref: "test/presentation/vitrine_cubit_test.dart (ConsultaImoveis.cidade; igualdade de Imovel sem cidade)"
        status: pass
      - kind: integration
        ref: "test/presentation/vitrine_fluxo_test.dart (idsDaCidade)"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-10-30
status: complete
---

# Phase 5 Plan 03: Item da vitrine sem cidade Summary

**`Imovel` deixa de carregar cidade (o item da lista da W09 não manda), `rotuloLocalizacao` aceita cidade nula, a prévia do detalhe mostra só o bairro e o cabeçalho carregado completa com 'bairro · cidade, UF' vindo do detalhe.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 2 (1 tracer, 1 auto/tdd)
- **Files modified:** 11 (4 em lib, 7 em test)

## Accomplishments

- `Imovel`: campo, construtor, `==`, `hashCode` e `toString` sem cidade; doc explica a origem da cidade (consulta/detalhe).
- `ImovelModel.paraEntidade()` não passa cidade (campos do model intactos até o 05-09).
- `rotuloLocalizacao(String, Cidade?)`: 'Cambuí · Campinas, SP', 'Campinas, SP', 'Cambuí', ''.
- Tela de detalhe: prévia chama `rotuloLocalizacao(previa.bairro, null)`; carregado usa `detalhe.cidade`.
- Testes: `cidade:` removida de todo `Imovel(...)`; as três asserções `.cidade` de `vitrine_fluxo_test` viraram asserções por ids que o mock serve para a cidade; `vitrine_cubit_test` afirma por ids; navegação afirma 'Cambuí' (sem ', SP') durante o spinner e 'Cambuí · Campinas, SP' depois do detalhe. Task 2 acrescentou os casos `null`, a asserção de `ConsultaImoveis.cidade` capturada e a igualdade de `Imovel` sem cidade.

## Task Commits

1. **Task 1 (tracer)** — `4ddd681` refactor(05-03): item da vitrine sem cidade (A-06)
2. **Task 2 (auto, tdd)** — `24c7366` test(05-03): rótulo de localização com cidade nula e cidade da vitrine vinda da consulta

Tracer gate (modo end-of-phase, `<verify>` só automatizado): `flutter analyze` e os 8 arquivos de teste verdes antes de seguir para a Task 2.

## Verificação

- `flutter analyze`: No issues found.
- `flutter test` completo: 591 passam, 0 falham (rodado duas vezes seguidas após a Task 2).
- `filtros_bottom_sheet_test`: **não instável**. Uma suspeita inicial (linha de progresso do runner) foi falso alarme — a única falha real daquele run era o `detalhe_navegacao_test`, corrigido; o arquivo passou isolado (32/32) e nas duas execuções completas finais.

## Deviations from Plan

### Auto-fixed / incidentes

**1. [Incidente de processo] `dart format test lib` reformatou 49 arquivos fora do escopo**
- **Found during:** Task 1 (tentativa de padronizar os arquivos editados)
- **Issue:** o projeto nunca foi formatado com `dart format`; o comando gerou ~2678 inserções/3223 remoções em arquivos sem relação com o plano, inclusive nos arquivos do plano (vitrine_cubit_test, vitrine_screen_test, vitrine_fluxo_test, imovel_card_test).
- **Fix:** o `git checkout` dos arquivos fora do plano foi negado pelo classificador de permissão; reportei o bloqueio e o usuário autorizou o revert (feito pelo orquestrador nos 38 arquivos fora do plano; backup do diff em `scratchpad/05-03-working-tree-antes-do-revert.patch`). Nos 4 arquivos do plano com ruído, regerei cada um a partir de `git show HEAD:<arquivo>` reaplicando só as edições do plano, de modo que o diff final contra o HEAD contém apenas mudanças do plano. Nenhum `dart format`/`dart fix` foi rodado depois.
- **Files modified:** nenhum fora do plano permaneceu alterado; commits só com os 11 arquivos do plano.
- **Commit:** n/a (incidente resolvido antes do commit `4ddd681`).

**2. [Rule 1 - Bug de teste] Substituição de expectativa da prévia não aplicada na primeira passada**
- **Found during:** Task 1 (`flutter test` completo)
- **Issue:** a substituição automática da asserção da prévia em `detalhe_navegacao_test.dart` não casou (texto com NBSP) e o teste ainda esperava 'Cambuí · Campinas, SP' durante o spinner.
- **Fix:** edição pontual do trecho. Teste passa.
- **Commit:** `4ddd681`.

Fora isso, plano executado como escrito.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum — sem superfície nova; T-05-03-01 mitigado (cidade inventada saiu do item).

## Self-Check: PASSED

- `lib/domain/entities/imovel.dart` sem campo cidade; `apresentacao_imovel.dart` contém `Cidade? cidade`.
- Commits `4ddd681` e `24c7366` existem em feat/APP05; sem push.
