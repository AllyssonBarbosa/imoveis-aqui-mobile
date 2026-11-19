---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 15
subsystem: presentation
tags: [filtros, caracteristica, query-params, freezed, d-13]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-13: Caracteristica({id, nome}) e CarregamentoOpcoes<Caracteristica> no modal"
provides:
  - "FiltrosVitrine.caracteristicas e Set<Caracteristica> (rascunho, filtro aplicado, chips e consulta falam Caracteristica)"
  - "parametrosDaApi envia caracteristicas como CSV de ids em ordem numerica crescente, so quando nao vazio"
  - "Chip de caracteristicas com os nomes em ordem normalizada (normalizarTexto)"
affects: [05-18]

plan_head_before: 9efb742436cf45ad28d7e86d0a72db670149977b
actuals:
  tokens: 14000
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Set de entidade freezed nao e const: testes usam final/nao-const nos FiltrosVitrine com caracteristicas"
    - "Invariante id/nome gerada em loop de testWidgets sobre caracteristicas.json (um teste por entrada)"

key-files:
  created: []
  modified:
    - lib/domain/entities/filtros_vitrine.dart
    - lib/domain/entities/filtros_vitrine.freezed.dart
    - lib/presentation/vitrine/rascunho_filtros_cubit.dart
    - lib/presentation/vitrine/apresentacao_filtros.dart
    - lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart
    - lib/data/datasources/parametros_consulta_imoveis.dart
    - test/domain/filtros_vitrine_test.dart
    - test/presentation/rascunho_filtros_cubit_test.dart
    - test/presentation/apresentacao_filtros_test.dart
    - test/presentation/filtros_bottom_sheet_test.dart
    - test/presentation/sessao_filtros_vitrine_test.dart
    - test/data/parametros_consulta_imoveis_test.dart
    - test/presentation/vitrine_fluxo_test.dart

key-decisions:
  - "Ids ordenados como int (2 antes de 10), nunca como texto; so ids de entidades ja parseadas entram na URL"
  - "Chip: nomes ordenados por normalizarTexto antes de _rotuloMultiSelecao (que passou a aceitar Iterable<String>)"

requirements-completed: []  # API-03 so fecha em 05-18 (orientacao do coordenador); o frontmatter do plano declara [API-03]

coverage:
  - id: D1
    description: "Marcar caracteristicas envia os ids ao servidor e o visitante so ve nomes"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#Filtros -> marcar Piscina e Churrasqueira mostra o chip \"Churrasqueira +1\""
        status: pass
      - kind: test
        ref: "test/data/parametros_consulta_imoveis_test.dart#caracteristicas viajam como CSV de ids em ordem crescente"
        status: pass
    human_judgment: false
  - id: D2
    description: "Invariante: toda caracteristica do catalogo capturado, marcada sozinha, vai como id e volta ao chip como nome"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#caracteristica \"<nome>\" marcada sozinha envia caracteristicas=<id>"
        status: pass
    human_judgment: false
  - id: D3
    description: "Trocar de cidade mantem as caracteristicas e limpa so os bairros"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/sessao_filtros_vitrine_test.dart#lembrar(campinas, f) -> filtrosPara(valinhos) devolve f com bairros limpos"
        status: pass
    human_judgment: false

duration: 20min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 15: Filtro de caracteristicas por id Summary

**`FiltrosVitrine.caracteristicas` virou `Set<Caracteristica>` de ponta a ponta: o rascunho e o chip trabalham com a entidade, a consulta envia `caracteristicas=<ids crescentes>` e a ponte por nome do 05-13 deixou de existir (D-13 completo).**

## O que mudou

- **Tracer (Task 1):** dominio, `RascunhoFiltrosCubit.alternarCaracteristica(Caracteristica, {marcada})`, `FilterChip` selecionado por `rascunho.caracteristicas.contains(caracteristica)` e `parametrosDaApi` com `'caracteristicas'` = ids ordenados e unidos por `,` (ausente quando vazio). O chip resumido ordena os nomes por `normalizarTexto` (primeiro nome + " +N"). `build_runner` regenerou `filtros_vitrine.freezed.dart`.
- **Testes da Task 1:** todos os listados passaram a construir `Caracteristica(id:, nome:)`; parametros: `1,2,10` (ordem numerica), nome com virgula viaja so por id, chave ausente quando vazio; fluxo Piscina + Churrasqueira assere `caracteristicas=<ids do JSON capturado em ordem crescente>` e o chip "Churrasqueira +1".
- **Task 2 (TDD):** a regra de sessao (manter caracteristicas, limpar bairros ao trocar de cidade) ja valia, entao `sessao_filtros_vitrine_test.dart` ficou como regressao com `Caracteristica`; chip com ordem alfabetica ignorando caixa/acento (`Área gourmet +2`); invariante id/nome em `vitrine_fluxo_test.dart`, um teste por entrada de `caracteristicas.json` (6 testes).

## Task Commits (app, branch feat/APP05, politica app-a)

1. **Task 1 (tracer):** `6ad987c` feat(05-15): filtro de características por id
2. **Task 2 (auto, tdd):** `6417b96` test(05-15): invariante id/nome das características sobre o catálogo capturado

Repo da API: zero commits e nenhuma mudanca. Nunca push. Nenhum formatador rodado (estilo ajustado a mao). Fixtures de `test/fixtures/api/` intocadas. `.gsd/dispatch-isolation-sentinel.json` e `.planning/state.json` deixados como estavam.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: `build_runner` (sem SEVERE), os sete arquivos de teste listados e `flutter analyze` verdes antes da Task 2.

## Deviations from Plan

**1. [Detalhe] `sessao_filtros_vitrine.dart` sem edicao.** Previsto no plano ("expected unchanged"); o teste de sessao ja passava com `Caracteristica`.

**2. [Detalhe] Task 2 sem RED real.** Sessao e chip ja estavam corretos pela Task 1; os testes novos (ordem alfabetica do chip, invariante) nasceram verdes e servem de regressao.

**3. [Detalhe] `apresentacao_filtros_test.dart`: expectativa do chip mudou de "Piscina +2" para "Elevador +2".** E a consequencia pedida pelo plano (nomes em ordem normalizada, em vez da ordem de iteracao do Set); o conjunto do teste e {Piscina, Elevador, Quintal}.

**4. [Detalhe] Testes sem `const` nos filtros com caracteristicas.** `Caracteristica` (freezed) sobrescreve `==`/`hashCode` e por isso nao pode ser elemento de `Set` constante (`const_set_element_not_primitive_equality`); os `FiltrosVitrine(...)` com caracteristicas nos testes passaram a `final`/nao-const. Sem efeito em producao (o `@Default(<Caracteristica>{})` vazio continua const).

Sem auth gates, sem pacotes adicionados. Nenhum arquivo fora de `files_modified`.

**Total deviations:** 4 (detalhes de teste). **Impact:** nenhum no escopo nem nos contratos.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. T-05-15-01 (so `int` de entidades parseadas entram no CSV; dio codifica) e T-05-15-02 (o app so envia ids; os fluxos assertam requisicao e renderizacao) mitigados; T-05-15-SC aceito (nenhum pacote).

## Verificacao

- `dart run build_runner build --delete-conflicting-outputs`: sem SEVERE. `flutter analyze`: sem problemas. `flutter test --timeout 60s` completo: 530 testes, todos verdes (de 521 apos o 05-14).
- API-03 e API-07 NAO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Arquivos de key-files existem; commits `6ad987c` e `6417b96` existem em feat/APP05; `git rev-list --count 9efb742..HEAD` = 2 antes do commit do SUMMARY.
