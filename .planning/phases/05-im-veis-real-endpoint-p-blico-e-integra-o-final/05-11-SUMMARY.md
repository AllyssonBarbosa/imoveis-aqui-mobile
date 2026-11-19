---
phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
plan: 11
subsystem: data
tags: [imoveis, api-publica, filtros, w09, apifalsa, remocao-do-mock]

requires:
  - phase: 05-im-veis-real-endpoint-p-blico-e-integra-o-final
    provides: "05-10: parametrosDaApi com busca e ordenar, ApiFalsa com ultimaRequisicaoDaLista, fluxos da vitrine sobre o JSON capturado"
provides:
  - "parametrosDaApi completo, exceto caracteristicas: busca, finalidade, natureza, quartos, suites, vagas, bairro, preco_min, preco_max, area_min, area_max, ordenar"
  - "OrdenacaoVitrine como enum simples (sem valor de wire no dominio)"
  - "Fluxos de filtro da vitrine e harness da lista do detalhe sobre ApiFalsa (JSON capturado)"
affects: [05-12, 05-14, 05-15]

plan_head_before: 07a241db0606855497b8272244abcc2c8e159388
actuals:
  tokens: 8500
  tasks: 2
  commits: 2   # MEDIDO: git rev-list --count plan_head_before..HEAD, antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "parametrosDaApi e o unico mapeamento ConsultaImoveis -> query params; nao ha inverso no app (o servidor filtra, ordena e pagina)"
    - "Testes de filtro afirmam a requisicao enviada e a renderizacao da resposta, nunca uma regra calculada no app (FIL-05)"
    - "Resposta especifica por filtro via ApiFalsa.responder (ex.: natureza=CASA,LOTE serve lista_campinas_casa_lote.json)"

key-files:
  created: []
  modified:
    - lib/data/datasources/parametros_consulta_imoveis.dart
    - lib/domain/entities/ordenacao_vitrine.dart
    - lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart
    - lib/presentation/vitrine/rascunho_filtros_cubit.dart
    - lib/data/datasources/imovel_detalhe_mock_datasource.dart
    - lib/data/datasources/imovel_datasource.dart
    - lib/data/datasources/opcoes_filtro_mock_datasource.dart
    - lib/data/mocks/imoveis_fixture.dart
    - test/data/parametros_consulta_imoveis_test.dart
    - test/data/opcoes_filtro_mock_datasource_test.dart
    - test/data/imovel_detalhe_mock_datasource_test.dart
    - test/data/imovel_detalhe_repository_impl_test.dart
    - test/presentation/vitrine_fluxo_test.dart
    - test/presentation/detalhe_navegacao_test.dart
    - test/presentation/vitrine_screen_test.dart
  deleted:
    - lib/data/datasources/imovel_mock_datasource.dart
    - test/data/imovel_mock_datasource_test.dart

key-decisions:
  - "Nomes da W09 no wire: quartos/suites/vagas (nao mais *_min), natureza e bairro em CSV, sem cidade e sem caracteristicas (ids entram no 05-15)"
  - "Tabela de natureza virou privada (_valorWireDaNatureza) ao apagar o unico consumidor externo, o mock da lista"
  - "O dublê do detalhe (sai no 05-14) segue com mapas reindexados para os ids dos cards capturados; titulo do card capturado mantido no mapa para o cabecalho nao mudar quando o detalhe chega"

requirements-completed: []  # API-03 so fecha em 05-18 (orientacao do coordenador); o frontmatter do plano declara [API-03]

coverage:
  - id: D1
    description: "Filtrar na vitrine envia ao servidor os nomes da W09: finalidade, natureza (CSV na ordem do enum, com LOTE), quartos/suites/vagas, bairro (CSV ordenado), preco_min/max, area_min/max, junto de ordenar; a cidade segue no caminho pelo id"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/data/parametros_consulta_imoveis_test.dart#parametrosDaApi (W09, D-12)"
        status: pass
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#API real (JSON capturado)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Casa + Lote envia natureza=CASA,LOTE e a tela mostra exatamente os cards da resposta capturada; resposta vazia mostra 'Nenhum imovel com esses filtros'; o app nao refiltra nem reordena"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#API real (JSON capturado)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Trocar de cidade com filtros ativos mantem finalidade e quartos e limpa os bairros na requisicao para o id da nova cidade (F3/D-19)"
    requirement: API-03
    verification:
      - kind: test
        ref: "test/presentation/vitrine_fluxo_test.dart#API real (JSON capturado)"
        status: pass
    human_judgment: false
  - id: D4
    description: "O servidor simulado da lista saiu do app: ImovelMockDataSource, seu teste, o mapeamento antigo, os inversos e o valor de wire do enum de dominio foram removidos"
    requirement: API-03
    verification:
      - kind: test
        ref: "gate do plano: test ! -e imovel_mock_datasource.dart && ! grep -rnE (ImovelMockDataSource|parametrosDaConsulta(|filtrosDosParametros|cidadeDoParametro|valorApi) lib test"
        status: pass
    human_judgment: false

duration: 45min
completed: 2026-11-01
status: complete
---

# Phase 5 Plan 11: Filtros da vitrine com os nomes da W09 e fim do servidor simulado da lista Summary

**`parametrosDaApi` agora leva todos os filtros (menos caracteristicas) com os nomes da W09, cada fluxo de filtro da vitrine e provado sobre o JSON capturado afirmando requisicao e renderizacao, e `ImovelMockDataSource` com o mapeamento antigo foi apagado do app.**

## O que mudou

- **Parametros (Task 1):** `parametrosDaApi` ganhou `finalidade` (VENDA/ALUGUEL), `natureza` (CSV na ordem do enum, LOTE incluso), `quartos`/`suites`/`vagas` (minimo), `bairro` (CSV ordenado por `normalizarTexto`), `preco_min`/`preco_max` e `area_min`/`area_max`. Set vazio e campo nulo nao geram chave; nao ha `cidade` nem `caracteristicas`.
- **Tracer (Task 1):** marcar Casa e Lote envia `natureza=CASA,LOTE` e a vitrine mostra exatamente os 12 cards de `lista_campinas_casa_lote.json`, na ordem do servidor, com o chip "Casa, Lote".
- **Limpeza (Task 2):** `parametros_consulta_imoveis.dart` ficou so com `caminhoImoveisDaCidade`, `parametrosDaApi` e helpers privados (`_valorOrdenar`, `_paraCsvOrdenado`, `_valorWireDaNatureza`). Foram removidos `caminhoImoveisPublico`, `parametrosDaConsulta`, `cidadeDoParametro`, `ordenacaoDoParametro`, `finalidadeDoParametro`, `naturezasDoParametro`, `listaDoParametro`, `minimoDoParametro`, `inteiroNaoNegativoDoParametro` e `filtrosDosParametros`. `OrdenacaoVitrine` virou enum simples.
- **Fluxos migrados (`vitrine_fluxo_test.dart`, grupo "API real"):** Venda e Qualquer; chip "x"; "Limpar filtros" (so `ordenar`); Casa + Apartamento + "2+" (`natureza=CASA,APARTAMENTO&quartos=2`); Terreno + "1+" com resposta vazia e volta pela limpeza; Venda + preco 250.000..300.000; area 80..120; Bairros "camb" (`bairro=Cambuí,Taquaral`); Piscina + Churrasqueira (chip e nova primeira pagina; ids no 05-15); Venda + "2+" + bairro e troca para Valinhos (requisicao do id 2 com finalidade e quartos, sem bairro). Os fluxos antigos sobre o mock foram removidos junto com `criarVitrineCubitReal`, `pumpVitrineDe` e `idsDaCidade`.
- **Detalhe:** o harness da lista de `detalhe_navegacao_test.dart` usa `ImovelRemoteDataSource` sobre `ApiFalsa` e toca os dois primeiros cards da p1 (ids 24 e 23); o dublê do detalhe segue ate o 05-14, com os mapas do 42 e do 57 reindexados para esses ids.

## Task Commits (app, branch feat/APP05, politica app-a)

1. **Task 1 (tracer):** `741b0a7` feat(05-11): filtros da vitrine com os nomes da W09
2. **Task 2 (auto):** `72c2f7a` refactor(05-11): servidor simulado da lista removido (deleta `imovel_mock_datasource.dart` e seu teste com `git rm`)

Repo da API: zero commits e nenhuma mudanca. Nunca push. Nenhum formatador rodado (estilo ajustado a mao). Fixtures de `test/fixtures/api/` intocadas.

## Gate do tracer

Modo `end-of-phase` com `<verify>` somente automatizado: testes de parametros e da vitrine e `flutter analyze` reexecutados e verdes antes da Task 2.

## Deviations from Plan

**1. [Rule 3 - Blocking] `FalhaSimuladaDoMock` movida para `imovel_detalhe_mock_datasource.dart`.** A classe morava em `imovel_mock_datasource.dart`, mas o mock do detalhe (que so sai no 05-14) e dois testes a importavam; apagar o arquivo quebraria a compilacao. A classe foi para o proprio arquivo do mock do detalhe (doc ajustada: gatilho e o id reservado 338) e os imports dos dois testes foram corrigidos. Arquivos fora de `files_modified`: `lib/data/datasources/imovel_detalhe_mock_datasource.dart`, `test/data/imovel_detalhe_mock_datasource_test.dart`, `test/data/imovel_detalhe_repository_impl_test.dart`. Commit `72c2f7a`.

**2. [Rule 3 - Blocking] Referencias residuais a `ImovelMockDataSource` fora da lista do plano.** O gate do plano (`grep` em lib e test sem nenhuma ocorrencia) falharia por: `test/data/opcoes_filtro_mock_datasource_test.dart` (um teste usava o mock da lista para provar que todo bairro oferecido tem imovel publicado; essa regra de servidor ja e coberta pelos testes do Django, entao o teste e os tres imports foram removidos) e comentarios de doc em `opcoes_filtro_mock_datasource.dart`, `imovel_datasource.dart` e `mocks/imoveis_fixture.dart` (reescritos por conceito, sem comportamento). Commit `72c2f7a`.

**3. [Detalhe] Bairros no fluxo "camb".** O plano pede `bairro=<opcao escolhida>`; mantive a intencao original do fluxo (Cambuí e depois Taquaral) e afirmei o CSV completo `bairro=Cambuí,Taquaral`, que cobre tambem a ordenacao do CSV.

**4. [Detalhe] Detalhe reindexado.** Alem de trocar a chave do mapa para o id tocado, o `titulo` do mapa recebe o titulo do card capturado, para o cabecalho da pagina nao mudar de texto quando o detalhe (ainda um dublê) chega; os demais campos do dublê (preco, bairro "Cambuí", natureza) continuam os do 42 e so valem ate o 05-14.

Sem auth gates, sem pacotes adicionados, sem bloqueios.

**Total deviations:** 4 (2 de Rule 3, 2 de organizacao de testes). **Impact:** nenhum no escopo nem nos contratos.

## Known Stubs

Nenhum. `caracteristicas` nao viaja de proposito ate o 05-15 (documentado em `parametrosDaApi` e em teste); as opcoes de bairro/caracteristica seguem no dublê ate o 05-12.

## Threat Flags

Nenhum. T-05-11-01 (valores so por `queryParameters` do dio, numeros de campos `int` tipados), T-05-11-02 (nenhum codigo de filtro/ordenacao no app; os testes afirmam requisicao e renderizacao) mitigados; T-05-11-03 e T-05-11-SC aceitos.

## Verificacao

- `flutter test` completo: 524 testes, todos verdes (de 611: sairam os testes do servidor simulado da lista e os grupos do mapeamento antigo, cuja logica esta nos testes do Django). `flutter analyze`: sem problemas.
- Gate de remocao (`test ! -e imovel_mock_datasource.dart` e grep dos simbolos antigos em lib e test): sem ocorrencias. `grep -c "final String" lib/domain/entities/ordenacao_vitrine.dart` imprime 0.
- API-03 e API-07 NAO marcadas em REQUIREMENTS.md (fecham em 05-18).

## Self-Check: PASSED

- Os arquivos modificados em key-files existem; `imovel_mock_datasource.dart` e `imovel_mock_datasource_test.dart` nao existem mais.
- Commits `741b0a7` e `72c2f7a` existem em feat/APP05; `git rev-list --count 07a241d..HEAD` = 2 antes do commit do SUMMARY.
