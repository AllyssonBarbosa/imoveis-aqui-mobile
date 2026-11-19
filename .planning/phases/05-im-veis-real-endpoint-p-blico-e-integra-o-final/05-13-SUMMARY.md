---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 13
subsystem: domain
tags: [caracteristica, opcoes-filtro, freezed, generics, d-13]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-12: OpcoesFiltroRemoteDataSource, CaracteristicaModel {id, nome}, ApiFalsa com bairros e catalogo"
provides:
  - "Entidade de dominio Caracteristica({id, nome}) freezed (igualdade por id e nome)"
  - "OpcoesFiltroRepository.caracteristicas() e ObterCaracteristicasUseCase devolvem Result<List<Caracteristica>> na ordem do servidor"
  - "CarregamentoOpcoes<T> generico: bairros String, caracteristicas Caracteristica"
  - "Chips do modal rotulados por caracteristica.nome"
affects: [05-15, 05-14]

plan_head_before: 38eb1a74261890d9f3eb7490e99efb633dcf0f26
actuals:
  tokens: 9000
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Uniao selada generica (CarregamentoOpcoes<T>) com inferencia do T pelo tipo do campo; o cubit nao precisou de mudanca"
    - "e2e do modal sobre a pilha real de opcoes + ApiFalsa; carregar() sem await dentro do testWidgets (o relogio so avanca com pump)"

key-files:
  created:
    - lib/domain/entities/caracteristica.dart
    - lib/domain/entities/caracteristica.freezed.dart
  modified:
    - lib/domain/repositories/opcoes_filtro_repository.dart
    - lib/domain/usecases/obter_caracteristicas_usecase.dart
    - lib/data/repositories/opcoes_filtro_repository_impl.dart
    - lib/presentation/vitrine/opcoes_filtro_state.dart
    - lib/presentation/vitrine/opcoes_filtro_state.freezed.dart
    - lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart
    - test/data/opcoes_filtro_repository_impl_test.dart
    - test/presentation/opcoes_filtro_cubit_test.dart
    - test/presentation/filtros_bottom_sheet_test.dart

key-decisions:
  - "Ponte ate o 05-15: o rascunho (FiltrosVitrine.caracteristicas Set<String>) continua guardando o nome; o chip marca e alterna por caracteristica.nome"
  - "opcoes_filtro_cubit.dart nao mudou: os emits ja inferem CarregamentoOpcoes<String>/<Caracteristica> pelo tipo dos campos do estado"

requirements-completed: []  # API-03 so fecha em 05-18 (orientacao do coordenador); o frontmatter do plano declara [API-03]

coverage:
  - id: D1
    description: "O catalogo real chega ao modal como {id, nome}: o dominio guarda o id e o chip mostra o nome, na ordem do servidor"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/filtros_bottom_sheet_test.dart#e2e sobre a pilha real de opcoes (ApiFalsa)"
        status: pass
      - kind: test
        ref: "test/data/opcoes_filtro_repository_impl_test.dart#modelos {id, nome} do datasource viram entidades Caracteristica na ordem recebida"
        status: pass
    human_judgment: false
  - id: D2
    description: "Falha de uma secao continua isolada e tentarNovamente recarrega so a dimensao que falhou, agora tipada com Caracteristica"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/opcoes_filtro_cubit_test.dart#tentarNovamente() com so as caracteristicas em falha"
        status: pass
      - kind: test
        ref: "test/presentation/opcoes_filtro_cubit_test.dart#tentarNovamente() recarrega SO a dimensao em falha"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 13: Caracteristica como entidade {id, nome} nas opcoes Summary

**`Caracteristica({id, nome})` (freezed) percorre repositorio, use case, `CarregamentoOpcoes<Caracteristica>` e o modal de filtros, que mostra cada chip pelo nome na ordem em que o servidor mandou.**

## O que mudou

- **Tracer (Task 1):** nova entidade `lib/domain/entities/caracteristica.dart`; `OpcoesFiltroRepository.caracteristicas()` e `ObterCaracteristicasUseCase.call()` passam a `Result<List<Caracteristica>>`; `OpcoesFiltroRepositoryImpl` mapeia `CaracteristicaModel` para `Caracteristica(id:, nome:)` sem reordenar (o `on TypeError` ficou). `CarregamentoOpcoes` virou `sealed class CarregamentoOpcoes<T>` e `OpcoesFiltroState` guarda `CarregamentoOpcoes<String> bairros` e `CarregamentoOpcoes<Caracteristica> caracteristicas`. No `_SecaoCaracteristicas` o `FilterChip` mostra `Text(caracteristica.nome)`; selecao e alternancia usam `caracteristica.nome` contra o rascunho atual (ponte ate o 05-15). `build_runner` regenerou os freezed.
- **e2e do tracer:** em `filtros_bottom_sheet_test.dart`, um `OpcoesFiltroCubit` real sobre os use cases reais e `OpcoesFiltroRepositoryImpl(OpcoesFiltroRemoteDataSource(ApiFalsa().criarDio()))`: o modal de Campinas mostra os nomes de `caracteristicas.json` na ordem e tocar em "Piscina" marca o chip.
- **Task 2 (TDD):** teste do repositorio com ordem do servidor ({3, Piscina}, {1, Churrasqueira}) mantida; teste do cubit em que so as caracteristicas falham: `tentarNovamente()` chama so o use case de caracteristicas (bairros 1 chamada, caracteristicas 2) e termina com `carregadas<Caracteristica>`; o teste de `close()` em voo ja existia e segue verde.

## Task Commits (app, branch feat/APP05, politica app-a)

1. **Task 1 (tracer):** `6a07bd4` feat(05-13): característica {id, nome} nas opções
2. **Task 2 (auto, tdd):** `0253695` test(05-13): retry só das características tipadas

Repo da API: zero commits e nenhuma mudanca. Nunca push. Nenhum formatador rodado (estilo ajustado a mao). Fixtures de `test/fixtures/api/` intocadas.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: `build_runner` (sem SEVERE), os quatro testes listados e `flutter analyze` verdes antes da Task 2.

## Deviations from Plan

**1. [Detalhe] `opcoes_filtro_cubit.dart` e `vitrine_screen_test.dart` sem edicao.** Listados em `files_modified`, mas a inferencia de tipos do Dart resolve `CarregamentoOpcoes<String>`/`<Caracteristica>` nos emits e nos `carregadas([])` vazios; nenhuma mudanca era necessaria (um import adicionado ao cubit foi desfeito por ficar sem uso).

**2. [Detalhe] Task 2 sem RED real.** O comportamento tipado ja estava coberto pela implementacao da Task 1; os testes novos da Task 2 (ordem, retry so das caracteristicas) nasceram verdes e servem de regressao.

**3. [Detalhe] Escopo do assert de ordem no e2e.** O modal tem outros `FilterChip` (tipo de imovel), entao o teste compara os ultimos N chips (Caracteristicas e a ultima secao) com os nomes da fixture.

**4. [Ambiente] Primeira execucao do e2e travou.** O `await cubit.carregar(...)` dentro do `testWidgets` nunca completava (relogio falso); corrigido com `unawaited(...)` + `pumpAndSettle` do `abrirSheet`. O processo `flutter_tester` dessa primeira execucao ficou preso e o `pkill` foi negado pelo sistema de permissao; nao foi contornado. Pode restar 1 `flutter_tester` ocioso, que o usuario pode encerrar manualmente.

Sem auth gates, sem pacotes adicionados. Nenhum arquivo fora de `files_modified`.

**Total deviations:** 4 (detalhes de teste/ambiente). **Impact:** nenhum no escopo nem nos contratos.

## Known Stubs

Nenhum. A ponte por nome (rascunho `Set<String>`) e intencional e sai no 05-15.

## Threat Flags

Nenhum. T-05-13-01 (so linhas validadas no 05-12 chegam a entidade; chips so com `Text`) e T-05-13-02 (falha do repositorio -> retry por secao, testado) mitigados; T-05-13-SC aceito (nenhum pacote).

## Verificacao

- `dart run build_runner build --delete-conflicting-outputs`: sem SEVERE. `flutter analyze`: sem problemas. `flutter test` completo: 533 testes, todos verdes (de 531).
- API-03 e API-07 NAO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Arquivos de key-files existem; commits `6a07bd4` e `0253695` existem em feat/APP05; `git rev-list --count 38eb1a7..HEAD` = 2 antes do commit do SUMMARY.
