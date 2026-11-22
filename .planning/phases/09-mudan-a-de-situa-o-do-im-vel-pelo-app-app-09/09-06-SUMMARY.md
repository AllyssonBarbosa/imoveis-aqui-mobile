---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 06
subsystem: data
tags: [flutter, dart, freezed, injectable, dio, historico, situacao, repository]

requires:
  - phase: 09-mudança-de-situação (09-04)
    provides: GestaoImovelRepository/DataSource, _executar com as falhas tipadas e o Dio 'autenticado'
  - phase: 09-mudança-de-situação (09-03)
    provides: situacaoDoCodigo, o mapa único de códigos de situação
  - phase: 09-mudança-de-situação (09-01)
    provides: fixtures capturadas historico_vazio/um_item/contrato.json, erro_401.json, erro_404_historico.json
provides:
  - "ObterHistoricoSituacaoUseCase(id): GET /api/imoveis/{id}/historico/ pelo Dio autenticado até List<MudancaSituacao> de domínio, na ordem do servidor"
  - "MudancaSituacao (entidade) e MudancaSituacaoModel (6 chaves, freezed + json_serializable)"
  - "GestaoImovelRepository.obterHistorico / GestaoImovelDataSource.obterHistorico, com guardas de FormatException e lista imutável"
  - "ApiFalsa serve GET /api/imoveis/<id>/historico/ (401 sem token; historico_vazio.json com token)"
affects: [09-07 tela de gestão (seção de histórico), 09-08 mudança de situação, 09-09 desfechos]

actuals:
  tokens: 14000
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Item de lista traduzido dentro da ação do _executar: data inválida e TypeError viram FalhaDeConexaoException sem ramo novo"
    - "Lista de domínio entregue como List.unmodifiable: o Cubit não reordena nem edita o que o servidor mandou (D-11)"

key-files:
  created:
    - lib/domain/entities/mudanca_situacao.dart
    - lib/domain/usecases/obter_historico_situacao_usecase.dart
    - lib/data/models/mudanca_situacao_model.dart
    - lib/data/models/mudanca_situacao_model.freezed.dart
    - lib/data/models/mudanca_situacao_model.g.dart
    - test/data/mudanca_situacao_model_test.dart
  modified:
    - lib/domain/repositories/gestao_imovel_repository.dart
    - lib/data/datasources/gestao_imovel_datasource.dart
    - lib/data/datasources/gestao_imovel_remote_datasource.dart
    - lib/data/repositories/gestao_imovel_repository_impl.dart
    - lib/di/injection.config.dart
    - test/support/api_falsa.dart
    - test/data/gestao_imovel_remote_datasource_test.dart
    - test/data/gestao_imovel_repository_impl_test.dart

key-decisions:
  - "A guarda de corpo não-lista e de item não-objeto já nasceu no DataSource da Task 1 (a ação pedia a rota completa); a Task 2 provou por teste e acrescentou só List.unmodifiable"
  - "toString de MudancaSituacao omite alteradoPor e observacao (podem trazer nome de cliente, T-09-06)"
  - "Nenhum ramo novo de status no _executar: 401, 404 e demais já cobertos pela cadeia do 09-04"

requirements-completed: [SIT-03]

coverage:
  - id: D1
    description: "ObterHistoricoSituacaoUseCase(36) lê GET /api/imoveis/36/historico/ com Authorization: Token e devolve a lista de MudancaSituacao na ordem do servidor, sem reordenar"
    requirement: "SIT-03"
    verification:
      - kind: integration
        ref: "test/data/gestao_imovel_remote_datasource_test.dart#histórico — pilha de dados"
        status: pass
    human_judgment: false
  - id: D2
    description: "MudancaSituacaoModel mapeia as 6 chaves: situações pelo mapa único (desconhecida vira null), alterado_em UTC, observação ausente vira ''"
    requirement: "SIT-03"
    verification:
      - kind: unit
        ref: "test/data/mudanca_situacao_model_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Falhas do histórico: 401 vira SessaoExpiradaException, 404 vira ImovelNaoEncontradoException sem texto em inglês, corpo não-lista, item malformado, rede, 5xx e TypeError viram FalhaDeConexaoException; lista do Success imutável"
    requirement: "SIT-03"
    verification:
      - kind: unit
        ref: "test/data/gestao_imovel_repository_impl_test.dart#GestaoImovelRepositoryImpl.obterHistorico"
        status: pass
      - kind: unit
        ref: "test/data/gestao_imovel_remote_datasource_test.dart#GestaoImovelRemoteDataSource.obterHistorico"
        status: pass
    human_judgment: false
  - id: D4
    description: "ApiFalsa serve GET /api/imoveis/<id>/historico/ (401 sem token, historico_vazio.json com token), base dos fluxos de tela do 09-07"
    requirement: "SIT-03"
    verification:
      - kind: integration
        ref: "test/data/gestao_imovel_remote_datasource_test.dart#ApiFalsa: GET /api/imoveis/36/historico/ sem token é 401"
        status: pass
    human_judgment: false

duration: 5 min
completed: 2026-11-22
plan_head_before: 64cecabcb555a91e0895c3258b86c86d61161280
commits: 2
status: complete
---

# Phase 9 Plan 06: Histórico de situações na camada de dados Summary

**`ObterHistoricoSituacaoUseCase(id)` lê `GET /api/imoveis/{id}/historico/` pelo `Dio` autenticado e entrega `List<MudancaSituacao>` imutável na ordem do servidor, com falhas tipadas (401, 404, rede, corpo malformado) provadas sobre a `ApiFalsa` com as fixtures reais do 09-01**

## Performance

- **Duration:** 5 min
- **Started:** 2026-11-22T15:45:30Z (aprox.)
- **Completed:** 2026-11-22T15:50:30Z (aprox.)
- **Tasks:** 2
- **Files modified:** 14 (6 criados, 8 alterados)

## Accomplishments

- Camada de dados do histórico (AC-3) atravessando Model → DataSource → Repository → UseCase: `MudancaSituacaoModel` com exatamente as 6 chaves do wire, `paraEntidade()` com `situacaoDoCodigo` (código desconhecido vira `null`, T-09-10) e `DateTime.parse(...).toUtc()` (D-05); observação ausente vira `''`.
- `GestaoImovelRemoteDataSource.obterHistorico` faz `GET /api/imoveis/$id/historico/` (barra final) no `Dio` `'autenticado'` e mapeia na ordem recebida, sem `sort`, filtro nem paginação (D-11). Corpo que não é lista e item que não é objeto lançam `FormatException`.
- `GestaoImovelRepositoryImpl.obterHistorico` reaproveita a mesma `_executar` do 09-04 (tradução de cada item dentro da ação) e devolve `List.unmodifiable`: 401 → `SessaoExpiradaException`, 404 → `ImovelNaoEncontradoException` (sem o texto em inglês do Django), demais → `FalhaDeConexaoException`.
- `ApiFalsa` serve `GET /api/imoveis/<id>/historico/` (401 sem token, `historico_vazio.json` com token); a doc da classe foi atualizada. Teste da pilha real confere o método, o caminho e `Authorization: Token token-de-teste`.
- Prova de ordem: o servidor falso manda `[contrato (id 1), um_item (id 2)]` e a lista chega `[1, 2]`, ou seja, o app não reordena por data nem por id.
- `flutter analyze lib` limpo; `flutter test` inteiro verde: **1293** (1267 antes deste plano + 26).

## Task Commits

1. **Task 1: Histórico ponta a ponta na camada de dados** - `0b600ef` (feat; testes primeiro)
2. **Task 2: Histórico robusto, falhas tipadas e lista imutável** - `f005c7e` (feat; RED real só na imutabilidade, ver "Deviations")

**Plan metadata:** commits docs(09-06) logo após este SUMMARY.

## Files Created/Modified

- `lib/domain/entities/mudanca_situacao.dart` - entidade imutável à mão (molde `ImovelAcervo`), `toString` sem nome nem observação
- `lib/domain/usecases/obter_historico_situacao_usecase.dart` - `@injectable`, só delega ao repositório
- `lib/data/models/mudanca_situacao_model.dart` (+ `.freezed.dart`, `.g.dart`) - Model de transporte com as 6 chaves
- `lib/domain/repositories/gestao_imovel_repository.dart`, `lib/data/datasources/gestao_imovel_datasource.dart` - `obterHistorico(int id)` documentado
- `lib/data/datasources/gestao_imovel_remote_datasource.dart` - GET do histórico com guardas de `FormatException`
- `lib/data/repositories/gestao_imovel_repository_impl.dart` - `obterHistorico` com `List.unmodifiable` dentro da `_executar`
- `lib/di/injection.config.dart` - registro do `ObterHistoricoSituacaoUseCase` (único gerado tracked alterado; nenhum só-CRLF para restaurar)
- `test/support/api_falsa.dart` - rota do histórico e doc da classe
- `test/data/mudanca_situacao_model_test.dart` (novo), `gestao_imovel_remote_datasource_test.dart`, `gestao_imovel_repository_impl_test.dart` - casos do histórico

## Decisions Made

- A guarda de `FormatException` (corpo não-lista, item não-objeto) foi escrita já na Task 1, junto com a rota, porque a ação descrevia a rota completa; a Task 2 provou por teste e acrescentou só a imutabilidade, que foi o único RED real.
- `toString` da entidade omite `alteradoPor` e `observacao`: podem trazer nome de cliente e a regra é só em memória, sem log (T-09-06).
- Nenhum ramo novo de status: a cadeia do `_executar` do 09-04 cobre 401, 404 e o resto (conferido pelos testes).

## Deviations from Plan

None - plan executed as written.

### Observação de processo (não é desvio de escopo)

A Task 2 (`tdd="true"`) só teve RED genuíno em "a lista do Success é imutável" (`Expected: throws UnsupportedError`). Os demais casos (corpo não-lista, item malformado, 401, 404, 5xx, timeout, `TypeError`, `FormatException`) passaram de primeira porque a guarda e a cadeia do `_executar` já existiam (Task 1 e 09-04). Eles ficam como rede de proteção contra regressão.

## Issues Encountered

None.

## Verificação

- Task 1: `mudanca_situacao_model_test.dart` + `gestao_imovel_remote_datasource_test.dart` verdes; `flutter analyze lib` limpo; gate de `grep` (rota com barra final, DI, `situacaoDoCodigo`, `historico/` na `ApiFalsa`) passou.
- Task 2: `gestao_imovel_remote_datasource_test.dart` + `gestao_imovel_repository_impl_test.dart` verdes (35 casos); gate de `grep` (`List.unmodifiable`, `FormatException`) passou.
- Fim da onda 4 (D-16): `flutter analyze lib` limpo e `flutter test` inteiro, **1293 verdes**.
- Nenhum gerado só-CRLF deixado modificado; nenhum push.

## Threat Flags

None - nenhuma superfície nova além da planejada (T-09-04 `Authorization` conferido na pilha de dados e 401 na `ApiFalsa`; T-09-02 e T-09-05 404 vira `ImovelNaoEncontradoException` sem texto do servidor; T-09-10 guardas de `FormatException`, `TypeError` e situação desconhecida como `null`; T-09-06 só em memória, sem log; T-09-SC nenhum pacote novo).

## Known Stubs

Nenhum stub. A tela do histórico (lista, vazio, falha parcial) é o 09-07; aqui só existe a camada de dados.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 09-07 já pode consumir `ObterHistoricoSituacaoUseCase` no `GestaoImovelCubit` e renderizar a lista na ordem recebida (rótulos por `rotuloSituacao`), com `historico_vazio.json` como padrão da `ApiFalsa` para os fluxos de tela.
- Commits locais em `feat/APP09`; nenhum push.

## Self-Check: PASSED

- Os 6 arquivos criados existem em disco e estão commitados.
- Commits `0b600ef` e `f005c7e` existem em `feat/APP09`; `git rev-list --count 64cecab..HEAD` = 2.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
