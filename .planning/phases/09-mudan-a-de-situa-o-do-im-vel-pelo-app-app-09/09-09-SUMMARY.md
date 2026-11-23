---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 09
subsystem: api
tags: [flutter, dart, dio, injectable, post, recusa-do-servidor, result]

requires:
  - phase: 09-mudança-de-situação (09-04/09-06)
    provides: GestaoImovelRepository/DataSource/Impl com _executar, ApiFalsa com rotas de leitura da gestão
  - phase: 09-mudança-de-situação (09-01)
    provides: fixtures capturadas (situacao_200, erro_400_*, erro_403_situacao, erro_404_imovel, erro_401)
provides:
  - "MudarSituacaoUseCase(id, nova, {observacao}) — primeiro POST autenticado do app, POST /api/imoveis/{id}/situacao/"
  - "GestaoImovelRepository.mudarSituacao e GestaoImovelDataSource.mudarSituacao (corpo sem data nem autor; observacao só quando não vazia; 200 ignorado)"
  - "MudancaSituacaoRecusadaException(mensagem) — recusa 400/403 com a mensagem do servidor"
  - "mensagemDeRecusa(Object? corpo) e limiteMensagemDeRecusa (300) em lib/data/network/mensagem_de_recusa.dart"
  - "ApiFalsa serve POST /api/imoveis/<id>/situacao/ (405 fora do POST, 401 sem token, 200 situacao_200.json)"
affects: [09-10 folha de mudança e releitura, 09-11, 09-12 mensagem de recusa na folha, 09-13 UAT (Pitfall 4)]

actuals:
  tokens: 8100
  tasks: 2
  commits: 2
plan_head_before: a1b868826e4352a494f7cd5827b43ad1fb2e32c7

tech-stack:
  added: []
  patterns:
    - "Escrita sem leitura do 200: o DataSource só faz o POST e ignora o corpo; o estado novo vem da releitura (D-10)"
    - "Recusa tipada com mensagem do servidor achatada na camada de dados (detail + listas de texto de qualquer chave, trim, corte em 300 com reticências)"
    - "Exceção de falha junto da interface do repositório; toString sem o texto do servidor"
    - "Sem nova tentativa automática em nenhum ponto do POST (Pitfall 4)"

key-files:
  created:
    - lib/domain/usecases/mudar_situacao_usecase.dart
    - lib/data/network/mensagem_de_recusa.dart
    - test/data/mensagem_de_recusa_test.dart
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
  - "O ramo 400/403 fica dentro do _executar compartilhado (antes do 404), em vez de um tratamento só da escrita: as leituras não esperam 400/403 e, se vierem, a tela mostra o erro genérico dela (como o plano manda)"
  - "Recusa sem texto aproveitável (corpo vazio, HTML, lista) vira FalhaDeConexaoException, nunca uma recusa com mensagem vazia"
  - "Corte em 300 caracteres acrescenta '…' depois dos 300 primeiros; texto com exatamente 300 não é cortado"

patterns-established:
  - "Um só mapa enum → código (codigoDaSituacao) reaproveitado pelo POST"
  - "Teste do contrato de uma chamada só: ApiFalsa.chamadas com hasLength(1) prova a ausência de reenvio"

requirements-completed: [SIT-02, SIT-04, SIT-01]

coverage:
  - id: D1
    description: "MudarSituacaoUseCase faz POST /api/imoveis/{id}/situacao/ pelo Dio autenticado com corpo {situacao: CÓDIGO} e observacao só quando não vazia (sem espaços nas pontas), sem data nem autor; o 200 não é parseado"
    requirement: SIT-02
    verification:
      - kind: integration
        ref: "test/data/gestao_imovel_remote_datasource_test.dart#mudar situação — pilha de dados (UseCase → Repository → DataSource → ApiFalsa)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Recusa 400/403 vira MudancaSituacaoRecusadaException com a mensagem do servidor achatada (detail + listas, trim, 300); corpo sem texto vira FalhaDeConexaoException"
    requirement: SIT-04
    verification:
      - kind: unit
        ref: "test/data/mensagem_de_recusa_test.dart; test/data/gestao_imovel_repository_impl_test.dart#GestaoImovelRepositoryImpl.mudarSituacao"
        status: pass
    human_judgment: false
  - id: D3
    description: "404 → ImovelNaoEncontradoException (inglês não sobe), 401 → SessaoExpiradaException, rede/tempo esgotado/5xx → FalhaDeConexaoException, sem nova tentativa automática (DataSource chamado uma vez; ApiFalsa recebe um POST)"
    requirement: SIT-04
    verification:
      - kind: unit
        ref: "test/data/gestao_imovel_repository_impl_test.dart#GestaoImovelRepositoryImpl.mudarSituacao"
        status: pass
    human_judgment: false
  - id: D4
    description: "ApiFalsa serve POST /api/imoveis/<id>/situacao/ (405 em outro método, 401 sem token, 200 situacao_200.json)"
    requirement: SIT-01
    verification:
      - kind: integration
        ref: "test/data/gestao_imovel_remote_datasource_test.dart#ApiFalsa: POST sem token é 401; ApiFalsa: GET /api/imoveis/36/situacao/ é 405"
        status: pass
    human_judgment: false

duration: 3min
completed: 2026-11-22
status: complete
---

# Phase 9 Plan 09: Camada de dados da escrita Summary

**Primeiro POST autenticado do app: MudarSituacaoUseCase manda `POST /api/imoveis/{id}/situacao/` (corpo sem data nem autor, observação só quando não vazia, 200 ignorado) e toda recusa do servidor chega tipada, com a mensagem dele achatada e cortada em 300 caracteres.**

## Performance

- **Duration:** 3 min
- **Started:** 2026-11-22T16:08:20Z
- **Completed:** 2026-11-22T16:11:25Z
- **Tasks:** 2
- **Files modified:** 11 (3 criados, 8 alterados)

## Accomplishments

- `MudarSituacaoUseCase` → `GestaoImovelRepository.mudarSituacao` → `GestaoImovelDataSource.mudarSituacao` → `Dio` `'autenticado'` → `POST /api/imoveis/{id}/situacao/` (barra final), reaproveitando `codigoDaSituacao`; corpo `{"situacao": "RESERVADO"}` e, com texto, `"observacao"` já sem espaços nas pontas; nunca chave nula, nunca data nem autor.
- O 200 é ignorado de propósito (D-10): a pilha continua `Success` mesmo com corpo `{}` ou lista; o estado só muda pela releitura (09-10).
- `ApiFalsa` ganhou a rota `POST /api/imoveis/<id>/situacao/` (405 fora do POST, 401 sem token, 200 `situacao_200.json` com token) e a doc da classe foi atualizada.
- `MudancaSituacaoRecusadaException(mensagem)` junto da interface do repositório, com `toString` sem a mensagem do servidor.
- `mensagemDeRecusa` pura (`detail` e todas as listas de texto de qualquer chave, `trim`, sem vazios, unidos por espaço, corte em 300 + "…", `null` sem texto) e o ramo 400/403 do `_executar`: com texto vira recusa, sem texto vira `FalhaDeConexaoException`; 404, 401, rede, tempo esgotado e 5xx tipados; sem nova tentativa.

## Task Commits

1. **Task 1: POST ponta a ponta na camada de dados** - `2c7fa26` (feat)
2. **Task 2: Falhas tipadas do envio (recusa 400/403 com mensagem do servidor)** - `bbab20e` (feat)

TDD: em cada tarefa os testes foram escritos antes e falharam (RED: método/arquivo inexistente) antes da implementação.

**Plan metadata:** commit docs deste SUMMARY e, em seguida, atualização de STATE/ROADMAP.

## Files Created/Modified

- `lib/domain/usecases/mudar_situacao_usecase.dart` - `MudarSituacaoUseCase` (`@injectable`, só delega)
- `lib/data/network/mensagem_de_recusa.dart` - `mensagemDeRecusa` e `limiteMensagemDeRecusa = 300`
- `test/data/mensagem_de_recusa_test.dart` - formatos reais das fixtures e dos erros medidos pela pesquisa, limites do corte
- `lib/domain/repositories/gestao_imovel_repository.dart` - `mudarSituacao` e `MudancaSituacaoRecusadaException`
- `lib/data/datasources/gestao_imovel_datasource.dart` - contrato `mudarSituacao`
- `lib/data/datasources/gestao_imovel_remote_datasource.dart` - POST autenticado, 200 ignorado
- `lib/data/repositories/gestao_imovel_repository_impl.dart` - `mudarSituacao` e ramo 400/403 do `_executar`
- `lib/di/injection.config.dart` - registro do `MudarSituacaoUseCase` (regenerado; nenhum outro gerado ficou modificado)
- `test/support/api_falsa.dart` - rota `POST /api/imoveis/<id>/situacao/`
- `test/data/gestao_imovel_remote_datasource_test.dart` - pilha de dados do POST, corpo exato, 200 não parseado, 401, 405
- `test/data/gestao_imovel_repository_impl_test.dart` - tradução de 400/403/404/401/rede/5xx, uma chamada só, pilha real

## Decisions Made

- O ramo 400/403 mora no `_executar` compartilhado (antes do 404), como o plano manda; as leituras não esperam 400/403.
- Recusa sem texto aproveitável nunca vira recusa com mensagem vazia: cai em `FalhaDeConexaoException`.
- Corte: os 300 primeiros caracteres + "…"; exatamente 300 não corta.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. `dart run build_runner build` alterou só `lib/di/injection.config.dart` (o registro novo); nenhum gerado só-CRLF ficou modificado. `dart format` não foi aplicado nos arquivos de teste existentes, para não reformatar trechos de planos anteriores.

## Known Stubs

None.

## Threat Flags

None - nenhuma superfície nova além da já coberta pelo threat model (T-09-03/04/05/07 mitigados: só o `Dio` `'autenticado'` com barra final, 200 não parseado, só 400/403 trazem texto do servidor cortado em 300 e `toString` sem a mensagem, nenhuma nova tentativa). T-09-11 (POST ambíguo por tempo esgotado) segue aceito e registrado para o UAT (09-13).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- A folha do 09-10/09-12 já pode chamar `MudarSituacaoUseCase`, mostrar `MudancaSituacaoRecusadaException.mensagem` e reler o imóvel com `recarregar()` (09-08).
- `flutter analyze lib` limpo e `flutter test` inteiro verde: 1378 testes.
- Para o UAT (09-13): reenvio depois de tempo esgotado recebe o 400 "O imóvel já está …", que aparece como recusa com a mensagem (Pitfall 4).

## Self-Check: PASSED

- Arquivos criados existem: `mudar_situacao_usecase.dart`, `mensagem_de_recusa.dart`, `mensagem_de_recusa_test.dart`.
- Commits `2c7fa26` e `bbab20e` presentes em `feat/APP09`; contagem medida desde `plan_head_before`: 2.
- Critérios de aceitação das duas tarefas re-executados: testes dos três arquivos de dados verdes, `flutter analyze lib` limpo, greps do `<verify>` ok, `flutter test` inteiro verde.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
