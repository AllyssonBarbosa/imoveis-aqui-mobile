---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 10
subsystem: data
tags: [imoveis, api-publica, busca, ordenar, paginacao, resiliencia, apifalsa]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-09: ImovelRemoteDataSource, parametrosDaApi com ordenar, ApiFalsa com a lista por cidade"
provides:
  - "parametrosDaApi envia busca (aparada, só quando não vazia) junto de ordenar"
  - "ImovelRepositoryImpl converte TypeError do JSON da lista em Result.failure(FormatException) nos dois métodos"
  - "VitrineCubit acrescenta na próxima página só ids ainda não listados"
  - "ApiFalsa.ultimaRequisicaoDaLista e ApiFalsa.falharProximas"
  - "Fluxos e2e de busca, ordenação, rolagem por next, 500 e JSON malformado sobre o JSON capturado"
affects: [05-11, 05-12, 05-14]

plan_head_before: 283369409c642db80e87ad9c53e7253ae397508c
actuals:
  tokens: 6850
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "TypeError (Error, não Exception) capturado no repositório e convertido em FormatException, igual ao detalhe"
    - "Guarda de integridade da lista: id repetido entre páginas é descartado; nenhuma regra de negócio no app"
    - "Falha injetada por contagem em ApiFalsa (falharProximas) em vez de sobrescrita permanente"

key-files:
  created: []
  modified:
    - lib/data/datasources/parametros_consulta_imoveis.dart
    - lib/data/repositories/imovel_repository_impl.dart
    - lib/presentation/vitrine/vitrine_cubit.dart
    - test/support/api_falsa.dart
    - test/data/parametros_consulta_imoveis_test.dart
    - test/data/imovel_repository_impl_test.dart
    - test/presentation/vitrine_cubit_test.dart
    - test/presentation/vitrine_fluxo_test.dart

key-decisions:
  - "O JSON malformado dos testes é sempre uma cópia da p1 capturada com uma chave trocada (titulo numérico), nunca um mapa escrito à mão"
  - "Os cinco fluxos não-filtro baseados no mock foram removidos da vitrine_fluxo_test.dart e recriados sobre ApiFalsa; os fluxos de filtro continuam no mock até a 05-11"

requirements-completed: []  # API-03 só fecha em 05-18 (orientação do coordenador); o frontmatter do plano declara [API-03]

coverage:
  - id: D1
    description: "Buscar e ordenar na vitrine enviam busca e ordenar da W09 no caminho da cidade pelo id; uma resposta vazia mostra o estado 'nenhum resultado' da busca, sem o app filtrar nada"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#API real (JSON capturado)"
        status: pass
      - kind: test
        ref: "test/data/parametros_consulta_imoveis_test.dart#parametrosDaApi (W09, D-12)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Rolar segue o next como o servidor mandou (segunda requisição igual ao next da p1), ids únicos na ordem da fixture"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#API real (JSON capturado)"
        status: pass
    human_judgment: false
  - id: D3
    description: "500 na primeira página e ao carregar mais mostram 'Tentar de novo'; tocar repete a mesma requisição e continua a lista"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#API real (JSON capturado)"
        status: pass
    human_judgment: false
  - id: D4
    description: "JSON da lista malformado vira Result.failure (FormatException) nos dois métodos do repositório e a vitrine mostra 'Tentar de novo' em vez de ficar no carregando"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/data/imovel_repository_impl_test.dart"
        status: pass
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#API real (JSON capturado)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Edge API-03: página seguinte que repete um id já listado não duplica o card e mantém os demais itens na ordem"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_cubit_test.dart#carregarMais (VIT-05, D-13)"
        status: pass
    human_judgment: false

duration: 30min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 10: Busca, ordenação, rolagem e falhas na API real Summary

**`busca` entra em `parametrosDaApi` ao lado de `ordenar`, o repositório converte JSON malformado (TypeError) em "Tentar de novo", e a próxima página nunca repete um card já exibido, tudo provado sobre o JSON capturado servido pela `ApiFalsa`.**

## O que mudou

- **Parâmetros:** `parametrosDaApi` adiciona `busca` só quando o termo não é vazio depois do `trim` (D-12). O texto vai apenas por `queryParameters` do dio (percent-encoded), sem `cidade` na query.
- **Repositório:** `ImovelRepositoryImpl.buscarImoveis` e `buscarProximaPagina` capturam `on TypeError` e devolvem `Result.failure(FormatException('lista de imóveis malformada: ...'))`, o mesmo padrão do repositório de detalhe (Pitfall 1). Sem isso o `Error` escapava do `try` e a vitrine ficava presa no carregando.
- **Cubit:** `_carregarProximaPagina` monta o `Set` de ids já listados e acrescenta só os itens novos, mantendo a ordem. É guarda de integridade da lista sob publicação concorrente (edge API-03), não filtro de negócio; um comentário em português explica.
- **ApiFalsa:** `ultimaRequisicaoDaLista` (última `GET /cidades/<id>/imoveis/`) e `falharProximas(caminho, {status, vezes})` (as próximas N requisições naquele prefixo respondem o status com objeto JSON vazio e depois a rota volta ao normal).
- **Testes:** no grupo "API real (JSON capturado)" da `vitrine_fluxo_test.dart`: p1 e rolagem até o fim (segunda requisição igual ao `next` da p1, ids únicos), Indaiatuba (vazio da cidade), busca "Cambuí" (`busca=Cambuí` e `ordenar=recentes`), busca sem resultado, "Maior preço" (`ordenar=-preco` e volta ao topo), "Menor preço" (`ordenar=preco`), 500 na primeira página, 500 ao carregar mais e JSON malformado. Mais testes de unidade em parâmetros (busca), repositório (TypeError nos dois métodos) e cubit (id repetido). O helper `pumpVitrineApi` do grupo substitui a montagem inline da 05-09.
- Removidos de `vitrine_fluxo_test.dart` os cinco fluxos antigos sobre o mock (cabeçalho/cards, Indaiatuba, rolagem, busca "cambui", "Menor preço") e os imports/constantes que ficaram sem uso. Os fluxos de filtro seguem no mock até a 05-11.

## Task Commits (app, branch feat/APP05, política app-a)

1. **Task 1 (tracer):** `76b8859` feat(05-10): busca e ordenação na API real
2. **Task 2 (tdd):** `f8c1a39` feat(05-10): rolagem e falhas reais da lista sem card repetido

Repo da API: zero commits e nenhuma mudança. Nunca push. Nenhum formatador rodado (estilo ajustado à mão). Fixtures de `test/fixtures/api/` intocadas.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: reexecutado (testes de parâmetros e da vitrine e `flutter analyze`) e verde antes da Task 2.

## TDD

Task 2: os quatro testes novos (dois do repositório, um do cubit, um da vitrine com JSON malformado) foram executados antes da implementação e falharam (RED); depois da implementação, todos passam (GREEN). Um único commit por task, conforme a política app-a.

## Deviations from Plan

**1. [Detalhe] Janela de timeout (10 s) sem teste dedicado.** A requisição interrompida chega ao cubit como `DioException`, que já é `Exception` e vira rodapé de erro pelo mesmo caminho do 500 coberto nos testes. Não criei um teste só para o timeout; nenhum código novo foi necessário.

**2. [Detalhe] Rolagem e cabeçalho/cards em um único teste.** Em vez de um teste só para cabeçalho/cards, o teste existente "p1 aparece e, rolando até o fim, a p2 vem pela URL next" ganhou as asserções (segunda requisição igual ao `next` da p1, ids únicos). Cobre o mesmo comportamento.

Sem auth gates, sem pacotes adicionados, sem bloqueios.

**Total deviations:** 2 (ambas de organização de testes). **Impact:** nenhum no escopo nem nos contratos.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. T-05-10-01 (texto da busca só via `queryParameters`), T-05-10-02 (TypeError e Exception viram `Result.failure`, testado com a p1 capturada alterada), T-05-10-03 (o app só descarta id repetido; nenhum código filtra ou reordena, testes afirmam requisição e renderização) mitigados; T-05-10-04 e T-05-10-SC aceitos (sem log, sem pacote novo).

## Verificação

- `flutter test` completo: 611 testes, todos verdes. `flutter analyze`: sem problemas.
- `grep -c "on TypeError" lib/data/repositories/imovel_repository_impl.dart` imprime 2.
- API-03 e API-07 NÃO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Existem os arquivos modificados listados em key-files.
- Commits 76b8859 e f8c1a39 existem em feat/APP05; `git rev-list --count 2833694..HEAD` = 2 antes do commit do SUMMARY.
