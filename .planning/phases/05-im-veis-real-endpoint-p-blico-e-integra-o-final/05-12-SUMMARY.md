---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 12
subsystem: data
tags: [opcoes-filtro, api-publica, bairros, caracteristicas, apifalsa, remocao-do-mock]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-11: parametrosDaApi completo, ApiFalsa com ultimaRequisicaoDaLista, fluxos da vitrine sobre o JSON capturado"
provides:
  - "OpcoesFiltroRemoteDataSource (dio) registrada no DI: bairros por id da cidade e catalogo de caracteristicas {id, nome}"
  - "CaracteristicaModel freezed + json (id inteiro, nome) lido no wire"
  - "ApiFalsa serve /api/publico/cidades/<id>/bairros/ e /api/publico/caracteristicas/"
  - "Falha por secao (TypeError incluido) vira Failure(FormatException) com 'Tentar de novo' proprio"
affects: [05-13, 05-15, 05-14]

plan_head_before: 4090150e0195ba6ed12131a1ceec99a57963150b
actuals:
  tokens: 8500
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "DataSource remota de opcoes valida linha a linha e descarta o invalido (mesma defesa de cidades)"
    - "Repositorio converte TypeError em Failure(FormatException) antes do catch generico de Exception"
    - "Fluxos de e2e montam o OpcoesFiltroCubit sobre OpcoesFiltroRemoteDataSource(apiFalsa.criarDio()), a mesma ApiFalsa da lista"

key-files:
  created:
    - lib/data/models/caracteristica_model.dart
    - lib/data/datasources/opcoes_filtro_remote_datasource.dart
    - test/data/opcoes_filtro_remote_datasource_test.dart
  modified:
    - lib/data/datasources/opcoes_filtro_datasource.dart
    - lib/data/repositories/opcoes_filtro_repository_impl.dart
    - lib/di/injection.config.dart
    - test/support/api_falsa.dart
    - test/data/opcoes_filtro_repository_impl_test.dart
    - test/presentation/vitrine_fluxo_test.dart
    - test/presentation/detalhe_navegacao_test.dart
  deleted:
    - lib/data/datasources/opcoes_filtro_mock_datasource.dart
    - test/data/opcoes_filtro_mock_datasource_test.dart

key-decisions:
  - "O dominio continua falando em nomes: o repositorio mapeia CaracteristicaModel -> nome na ordem recebida; a promocao para {id, nome} e do 05-13 e o envio por id do 05-15"
  - "ApiFalsa responde [] para os bairros de cidades que nao sao Campinas (so Campinas tem captura), no mesmo espirito da lista vazia"
  - "cidade.id nulo falha como FormatException antes de qualquer requisicao (T-05-12-03)"

requirements-completed: []  # API-03 so fecha em 05-18 (orientacao do coordenador); o frontmatter do plano declara [API-03]

coverage:
  - id: D1
    description: "A secao Bairros do modal lista o array de /api/publico/cidades/<id>/bairros/ na ordem recebida e marcar bairros continua enviando bairro em CSV"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#Filtros -> expandir Bairros -> digitar camb"
        status: pass
      - kind: test
        ref: "test/data/opcoes_filtro_remote_datasource_test.dart#bairros"
        status: pass
    human_judgment: false
  - id: D2
    description: "A secao Caracteristicas lista o catalogo {id, nome} de /api/publico/caracteristicas/ pelo nome, na ordem recebida; linha sem id inteiro ou com nome vazio e descartada"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/data/opcoes_filtro_remote_datasource_test.dart#caracteristicas"
        status: pass
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#Filtros -> marcar Piscina e Churrasqueira"
        status: pass
    human_judgment: false
  - id: D3
    description: "As opcoes vem de OpcoesFiltroRemoteDataSource registrada no DI e o servidor simulado de opcoes saiu do app (D-18)"
    requirement: API-03
    verification:
      - kind: test
        ref: "gate do plano: grep OpcoesFiltroRemoteDataSource em injection.config.dart && test ! -e opcoes_filtro_mock_datasource.dart && ! grep -rn OpcoesFiltroMockDataSource lib test"
        status: pass
    human_judgment: false
  - id: D4
    description: "Falha em bairros ou caracteristicas (rede, 5xx, JSON malformado, TypeError) mostra o 'Tentar de novo' da propria secao, que recarrega so a dimensao que falhou; cidade sem id falha a secao bairros sem requisicao"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#Filtros com o catalogo de caracteristicas fora do ar"
        status: pass
      - kind: test
        ref: "test/data/opcoes_filtro_repository_impl_test.dart#TypeError do datasource vira Failure com FormatException"
        status: pass
      - kind: test
        ref: "test/data/opcoes_filtro_remote_datasource_test.dart#cidade sem id: FormatException e nenhuma requisicao"
        status: pass
    human_judgment: false

duration: 30min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 12: Opcoes de filtro reais via API e fim do servidor simulado das opcoes Summary

**`OpcoesFiltroRemoteDataSource` (dio, no DI) le os bairros da cidade por id e o catalogo de caracteristicas como `{id, nome}` (`CaracteristicaModel`), cada secao falha e tenta de novo sozinha, e o mock das opcoes saiu do app.**

## O que mudou

- **Tracer (Task 1):** `OpcoesFiltroDataSource` agora tem `caminhoBairrosDaCidade(int)` (`/api/publico/cidades/<id>/bairros/`), `bairros(Cidade) -> List<String>` e `caracteristicas() -> List<CaracteristicaModel>`. `OpcoesFiltroRemoteDataSource` (`@LazySingleton(as: OpcoesFiltroDataSource)`) exige lista JSON, mantem as strings nao vazias dos bairros na ordem recebida e descarta linhas do catalogo sem `id` inteiro ou com `nome` vazio. O repositorio entrega os nomes das caracteristicas ao dominio (que so passa a `{id, nome}` no 05-13). `opcoes_filtro_mock_datasource.dart` e seu teste foram removidos com `git rm`; `build_runner` registra a remota no DI.
- **ApiFalsa:** duas rotas novas, `/api/publico/cidades/<id>/bairros/` (`bairros_campinas.json`; `[]` para as demais cidades) e `/api/publico/caracteristicas/` (`caracteristicas.json`).
- **Fluxos:** os harnesses de `vitrine_fluxo_test.dart` e `detalhe_navegacao_test.dart` montam o cubit de opcoes sobre `OpcoesFiltroRemoteDataSource(apiFalsa.criarDio())`. O fluxo de Bairros afirma que as opcoes listadas sao exatamente as de `bairros_campinas.json`, na ordem, a requisicao ao caminho com o id da cidade e `bairro=Cambuí,Taquaral` na lista. O fluxo de Piscina + Churrasqueira afirma um chip por nome de `caracteristicas.json`. `vitrine_fluxo_test.dart` nao importa mais nada de `lib/data/mocks/`.
- **Resiliencia (Task 2, TDD):** RED = dois testes de `TypeError` no repositorio; GREEN = `on TypeError` -> `Result.failure(FormatException('opções de filtro malformadas: $erro'))` nos dois metodos. Testes novos da DataSource real (rotas, ordem, linhas invalidas, corpo nao lista, 500, cidade sem id sem requisicao) e fluxo com `falharProximas('/api/publico/caracteristicas/')`: aparece 'Não foi possível carregar as características' com 'Tentar de novo'; ao tocar, os chips do catalogo aparecem, ha 2 requisicoes ao catalogo e 1 aos bairros.

## Task Commits (app, branch feat/APP05, politica app-a)

1. **Task 1 (tracer):** `41dfddd` feat(05-12): opções de filtro reais via DI
2. **Task 2 (auto, tdd):** `60e0d90` feat(05-12): opções de filtro resilientes por seção

Repo da API: zero commits e nenhuma mudanca. Nunca push. Nenhum formatador rodado (estilo ajustado a mao). Fixtures de `test/fixtures/api/` intocadas.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: `build_runner`, testes listados, `flutter analyze` e o gate de DI/remocao reexecutados e verdes antes da Task 2.

## Deviations from Plan

**1. [Detalhe] Contagem de requisicoes no fluxo Piscina + Churrasqueira.** Abrir Filtros agora dispara as requisicoes de bairros e caracteristicas na ApiFalsa, entao `requisicoes.length == antes + 1` deixou de valer. O fluxo passou a contar so as requisicoes da lista (`.../imoveis/`), que e o que a intencao do teste afirma (a nova consulta pede de novo a primeira pagina).

**2. [Detalhe] Factory do cubit de opcoes recebe a ApiFalsa.** `criarOpcoesFiltroCubitReal()` virou `criarOpcoesFiltroCubitApi(ApiFalsa)` em `vitrine_fluxo_test.dart`, porque a ApiFalsa e criada por teste.

**3. [Detalhe] Testes da DataSource e do fluxo de falha ja nasceram verdes.** Como a defesa (lista, id nulo, linhas invalidas) ja estava na Task 1, so o `TypeError` do repositorio ficou RED; os demais testes da Task 2 servem de regressao.

Sem auth gates, sem pacotes adicionados, sem bloqueios. Nenhum arquivo fora de `files_modified`.

**Total deviations:** 3 (organizacao de testes). **Impact:** nenhum no escopo nem nos contratos.

## Known Stubs

Nenhum. O dominio ainda fala em nomes de caracteristica (nao em `{id, nome}`), por desenho: 05-13 promove e 05-15 envia por id; o detalhe segue no dublê ate o 05-14.

## Threat Flags

Nenhum. T-05-12-01 (linhas validadas e descartadas; chips so com `Text`), T-05-12-02 (TypeError/Exception -> falha por secao com retry proprio), T-05-12-03 (so o `int` id do parse monta o caminho; id nulo falha antes de qualquer requisicao) mitigados; T-05-12-SC aceito (nenhum pacote).

## Verificacao

- `dart run build_runner build --delete-conflicting-outputs`: sem SEVERE. `flutter test` completo: 531 testes, todos verdes (de 524). `flutter analyze`: sem problemas.
- Gate de DI/remocao: `OpcoesFiltroRemoteDataSource` em `injection.config.dart`, mock inexistente, sem referencias em lib e test. `grep -n "data/mocks/" test/presentation/vitrine_fluxo_test.dart` imprime nada. `on TypeError` aparece 2 vezes no repositorio.
- API-03 e API-07 NAO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Arquivos criados e modificados em key-files existem; os dois arquivos do mock das opcoes nao existem mais.
- Commits `41dfddd` e `60e0d90` existem em feat/APP05; `git rev-list --count 4090150..HEAD` = 2 antes do commit do SUMMARY.
