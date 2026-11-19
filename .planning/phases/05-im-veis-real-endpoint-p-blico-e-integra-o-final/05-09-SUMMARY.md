---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 09
subsystem: data
tags: [imoveis, api-publica, dio, injectable, paginacao, ordenar, fixtures]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-03: Imovel sem cidade; 05-06: fixtures capturadas da lista; 05-08: Cidade.id e ApiFalsa"
provides:
  - "ImovelRemoteDataSource (dio) registrada no DI como ImovelDataSource: lista por cidade.id e next absoluto de mesma origem"
  - "ImovelModel no item da W09 (bairro nulo vira ''), sem descricao/cidade/caracteristicas/criado_em"
  - "caminhoImoveisDaCidade(int) e parametrosDaApi(ConsultaImoveis) com ordenar da W09 (recentes|preco|-preco|area|-area)"
  - "ApiFalsa serve /api/publico/cidades/<id>/imoveis/ (p1, p2 por page=2, vazia para outras cidades)"
affects: [05-10, 05-11, 05-12, 05-14]

plan_head_before: 14b6a2753d03b9c96dc036461ec0c0087663c0b0
actuals:
  tokens: 40000
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Troca mock->real só por DI: a anotação @LazySingleton(as: ImovelDataSource) saiu do mock e entrou no remoto"
    - "Próxima página = URL next absoluta, seguida só se scheme/host/porta batem com a baseUrl do Dio"
    - "Cidade no caminho pelo id da API; parâmetros só via queryParameters (codificados pelo dio)"

key-files:
  created:
    - lib/data/datasources/imovel_remote_datasource.dart
    - test/data/imovel_remote_datasource_test.dart
  modified:
    - lib/data/models/imovel_model.dart
    - lib/data/models/imoveis_envelope_model.dart
    - lib/data/datasources/imovel_datasource.dart
    - lib/data/datasources/imovel_mock_datasource.dart
    - lib/data/datasources/parametros_consulta_imoveis.dart
    - lib/di/injection.config.dart
    - test/support/api_falsa.dart
    - test/data/imovel_mock_datasource_test.dart
    - test/data/parametros_consulta_imoveis_test.dart
    - test/presentation/vitrine_fluxo_test.dart

key-decisions:
  - "O dublê ImovelMockDataSource continua existindo só para testes (sem anotação de DI) até a 05-11 apagá-lo (D-18); parametrosDaConsulta e os helpers inversos ficam intocados"
  - "parametrosDaApi começa só com ordenar; busca e filtros entram nos planos seguintes"
  - "No e2e a p2 é conferida por ids (as fixtures p1 e p2 repetem os títulos dos 4 primeiros imóveis do seed)"

requirements-completed: []  # API-03 só fecha em 05-18 (orientação do coordenador); o frontmatter do plano declara [API-03]

coverage:
  - id: D1
    description: "A vitrine de Campinas mostra os imóveis do JSON capturado da API (p1) e, rolando até o fim, a p2 pela URL next, pela DataSource dio, sem mudar contrato de widget/Cubit"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#API real (JSON capturado)"
        status: pass
    human_judgment: false
  - id: D2
    description: "A DataSource real chama a rota por id com ordenar, segue só next de mesma origem e falha antes de qualquer requisição (origem estranha, cidade sem id); corpo não-objeto vira FormatException"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/data/imovel_remote_datasource_test.dart"
        status: pass
      - kind: test
        ref: "test/data/parametros_consulta_imoveis_test.dart#parametrosDaApi (W09, D-12)"
        status: pass
    human_judgment: false
  - id: D3
    description: "O DI registra ImovelRemoteDataSource para ImovelDataSource; presentation/domain não alcançam dublês"
    verification:
      - kind: other
        ref: "grep ImovelRemoteDataSource lib/di/injection.config.dart; grep Mock*DataSource lib/presentation lib/domain (vazio)"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 09: Lista real da cidade via DI Summary

**A vitrine da cidade passa a ser servida por `ImovelRemoteDataSource` (dio) em `GET /api/publico/cidades/<id>/imoveis/` com `ordenar` da W09 e paginação pelo `next` absoluto de mesma origem, trocada só pelo DI, com o `ImovelModel` alinhado ao item real.**

## O que mudou

- **Modelo:** `ImovelModel` só com o que a lista manda (id, titulo, finalidade, preços, `String? bairro`, foto_capa, natureza, quartos, suites, vagas, area). `bairro` nulo vira `''` em `paraEntidade()`; `foto_capa` continua filtrada por `urlHttpOuNula`. Saíram `descricao`, `cidade`, `caracteristicas` e `criado_em`.
- **DataSource remota:** `buscar` exige `consulta.cidade.id` (senão `FormatException` antes de qualquer requisição), faz GET no caminho por id com `queryParameters: parametrosDaApi(consulta)`; `seguir` roda `_exigirMesmaOrigem` (scheme/host/porta contra a baseUrl do Dio) e só então busca a URL absoluta. Corpo que não é objeto vira `FormatException`.
- **Parâmetros:** `caminhoImoveisDaCidade(int)` e `parametrosDaApi` (por ora só `ordenar`, mapeado por switch exaustivo de `OrdenacaoVitrine`, sem mudar rótulos da UI). Nunca emite `cidade`.
- **DI:** `injection.config.dart` registra `ImovelRemoteDataSource(gh<Dio>())` para `ImovelDataSource`; o mock perdeu a anotação e virou dublê de teste (doc atualizada).
- **ApiFalsa:** rota da lista por cidade (p1; `page=2` serve p2; qualquer outra cidade que não Campinas recebe a lista vazia). O id de Campinas vem de `cidades.json`.
- **Testes:** grupo e2e "API real (JSON capturado)" na vitrine (p1, scroll até o fim, p2, requisições `[null, '2']`), `imovel_remote_datasource_test.dart` (6 testes), grupo `parametrosDaApi` (3 testes) e asserções do mock trocadas de `cidade` do modelo para os ids servidos por cidade.

## Task Commits (app, branch feat/APP05, política app-a)

1. **Task 1 (tracer):** `1d35c75` feat(05-09): lista real da cidade via DI
2. **Task 2 (tdd):** `d3ada05` test(05-09): datasource real da lista sob teste

Repo da API: zero commits e nenhuma mudança. Nunca push. Nenhum formatador rodado (estilo ajustado à mão).

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: reexecutado (build_runner, testes da vitrine/mock, `flutter analyze`, greps de DI e de camadas) e verde; seguiu para a Task 2.

## Deviations from Plan

**1. [Organização/TDD] Task 2 sem fase RED.** A implementação (`_exigirMesmaOrigem`, id nulo, corpo não-objeto, `parametrosDaApi`) já nasceu na Task 1, exigida pelo tracer. Os testes da Task 2 foram escritos depois e passaram de primeira; não houve código novo na Task 2, só testes (commit `test(...)`). Os comportamentos listados no `<behavior>` estão todos cobertos.

**2. [Rule 3 - Bloqueio] Turnos extras no e2e.** Com o dio sobre o `ApiFalsa` a resposta não chega em dois `pump()` como no mock em memória. Acrescentei um `pump(50 ms)` no teste e comentei o motivo. Sem `pumpAndSettle` com o spinner de pé.

**3. [Detalhe] Títulos repetidos entre p1 e p2.** As fixtures repetem os títulos dos 4 primeiros itens da p1 na p2 (ids 24..21 e 4..1), então o e2e confere a p2 por ids dos cards/estado, não por título.

Sem auth gates, sem pacotes adicionados.

**Total deviations:** 3 (1 organização, 1 Rule 3 em teste, 1 detalhe de fixture). **Impact:** nenhum no escopo nem nos contratos.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. T-05-09-01 (next de outra origem: `FormatException` sem requisição, testado), T-05-09-02 (id inteiro no caminho, resto por `queryParameters`) e T-05-09-03 (`urlHttpOuNula` mantido) mitigados; T-05-09-SC: nenhum pacote.

## Verificação

- `dart run build_runner build`: sem erro; `injection.config.dart` registra `ImovelRemoteDataSource`.
- `flutter test` completo: 604 testes, todos verdes. `flutter analyze`: sem problemas.
- `grep` de camadas em `lib/presentation` e `lib/domain` por dublês: vazio.
- API-03 e API-07 NÃO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Existem: lib/data/datasources/imovel_remote_datasource.dart e test/data/imovel_remote_datasource_test.dart.
- Commits 1d35c75 e d3ada05 existem em feat/APP05.
