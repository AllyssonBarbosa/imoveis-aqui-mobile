---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 08
subsystem: data
tags: [cidades, api-publica, shared-preferences, dio, fixtures, api-falsa]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-06: test/fixtures/api/cidades.json (array real de {id, nome, uf})"
provides:
  - "Cidade.id (int?) como atributo de rota, fora de ==/hashCode (A-01)"
  - "CidadeRemoteDataSource.obterCidades() lendo o array simples, sem cursor"
  - "CidadePrefsDataSource: nome|uf|id, leitura de nome|uf antigo, id inválido vira null"
  - "test/support/api_falsa.dart: ApiFalsa (Dio sobre HttpClientAdapter falso que serve as fixtures por rota)"
affects: [05-09, 05-10, 05-12, 05-14]

plan_head_before: 7f5da63e1d9061b53b53fa2b74d9fe25d08822a3
actuals:
  tokens: 14000
  tasks: 2
  commits: 1   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Id da API entra como atributo de rota fora da igualdade; a identidade segue nome+uf"
    - "Testes de wire usam ApiFalsa sobre fixtures capturadas; wire malformado é cópia de uma linha real com uma chave alterada"

key-files:
  created:
    - test/support/api_falsa.dart
    - test/data/cidade_repository_impl_test.dart
  modified:
    - lib/domain/entities/cidade.dart
    - lib/data/models/cidade_model.dart
    - lib/data/datasources/cidade_remote_datasource.dart
    - lib/data/datasources/cidade_prefs_datasource.dart
    - lib/data/repositories/cidade_repository_impl.dart
    - test/data/cidade_remote_datasource_test.dart
    - test/data/cidade_prefs_datasource_test.dart

key-decisions:
  - "ApiFalsa.responder ganhou o parâmetro opcional `corpo` (além de `fixture`) para servir uma cópia de linha real com uma chave alterada, sem escrever wire à mão"
  - "Os 4 grupos de teste antigos de paginação/origem/maxPaginas foram removidos junto com o código de cursor"

requirements-completed: []  # API-03 só fecha em 05-18 (orientação do coordenador)

coverage:
  - id: D1
    description: "Cidades vêm do array real com ids; o id viaja na entidade fora da igualdade e na cidade salva (nome|uf|id)"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/data/cidade_remote_datasource_test.dart, test/data/cidade_repository_impl_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Valor salvo antigo, id inválido e valor corrompido nunca causam crash; invariante de ida e volta sobre todas as cidades de cidades.json"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/data/cidade_prefs_datasource_test.dart, test/data/cidade_repository_impl_test.dart"
        status: pass
    human_judgment: false

duration: 20min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 08: Cidades reais em array com id Summary

**`Cidade` carrega o id da API fora de `==`/`hashCode`, `obterCidades()` lê o array simples de `/api/publico/cidades/`, as prefs guardam `nome|uf|id` (lendo ainda `nome|uf`) e `ApiFalsa` serve as fixtures reais por rota para os próximos planos.**

## O que mudou

- **Domínio/modelo:** `Cidade({this.id, nome, uf})`; `==`/`hashCode` continuam em nome+uf; `CidadeModel.paraEntidade()` passa o id.
- **Remoto:** `obterCidades()` faz um GET, exige lista (senão `FormatException`), descarta linha sem id inteiro/nome/uf; sem cursor, sem `maxPaginas`, sem checagem de origem do `next`.
- **Prefs:** `salvar(nome, uf, id?)` grava `nome|uf` ou `nome|uf|id`; `obterSalva()` devolve `(nome, uf, id?)`: 2 partes -> id nulo, 3 partes -> `int.tryParse`, outras -> null.
- **Repositório:** salva `cidade.id` e restaura `Cidade(id: salva.$3, ...)`.
- **ApiFalsa:** `urlBaseApiFalsa`, `lerFixtureApi`, `ApiFalsa({latencia})` com `criarDio()`, `requisicoes`, `responder(quando, status:, fixture:, corpo:)`; rota de cidades -> `cidades.json`; qualquer outra -> 404 com `{}`.

## Task Commits (app, branch feat/APP05, política app-a)

1. **Task 1 (tracer)**: `54ccff1` feat(05-08): cidades reais em array com id
2. **Task 2**: sem commit próprio (ver desvio abaixo).

Repo da API: zero commits e nenhuma mudança. Nunca push. Nenhum formatador rodado.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: reexecutado e verde (3 arquivos de teste + `flutter analyze`), seguiu para a Task 2.

## Deviations from Plan

**1. [Organização] Testes da Task 2 escritos junto com a Task 1.** Ao reescrever os três arquivos de teste da Task 1 já cobri todos os comportamentos da Task 2 (formato antigo, id inválido, 1 ou 4+ partes, invariante sobre `cidades.json`, corpo não-lista, linhas malformadas descartadas). A implementação de `obterSalva()` e do datasource da Task 1 já satisfazia esses comportamentos, então não havia o que corrigir na Task 2 e nenhum commit extra foi feito. Os critérios de aceitação da Task 2 (`int? id`, `int.tryParse`, invariante com `==` e `id` por cidade, `flutter test` completo, `flutter analyze`) foram verificados com o commit `54ccff1`.

**2. [Interface] `ApiFalsa.responder` com `corpo` opcional.** O plano pede wire malformado "copiando uma linha capturada e mudando uma chave"; isso exige servir um corpo derivado, então `responder` aceita `corpo` além de `fixture`. Compatível com a interface do plano.

Nenhuma regra 1-3 aplicada; sem auth gates.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. T-05-08-01 (corpo não-lista -> FormatException -> falha do repositório; linhas inválidas descartadas) e T-05-08-02 (parse estrito de 2/3 partes, `int.tryParse`) mitigados e cobertos por testes; T-05-08-03 respeitado (um commit local, sem push); nenhum pacote adicionado.

## Verificação

- `flutter test` completo: 594 testes, todos verdes. `flutter analyze`: sem problemas.
- `grep -n "other.id" lib/domain/entities/cidade.dart`: vazio; `maxPaginas` removido do datasource; `cidade_model.dart` contém `id: id`.
- API-03 e API-07 NÃO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Existem: test/support/api_falsa.dart e test/data/cidade_repository_impl_test.dart.
- Commit 54ccff1 existe em feat/APP05.
