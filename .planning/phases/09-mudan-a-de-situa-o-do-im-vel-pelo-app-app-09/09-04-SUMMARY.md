---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 04
subsystem: data
tags: [flutter, dart, dio, freezed, injectable, gestao, situacao, tracer, tdd]

requires:
  - phase: 09-mudança-de-situação (09-01)
    provides: fixtures capturadas imovel_gestao_*.json, erro_401.json, erro_404_imovel.json
  - phase: 09-mudança-de-situação (09-03)
    provides: finalidadeDoCodigo e situacaoDoCodigo (mapa único código → enum)
provides:
  - "ImovelGestao: entidade de domínio do imóvel lido da gestão (9 campos, situacaoDesde em UTC)"
  - "ObterImovelGestaoUseCase → GestaoImovelRepositoryImpl → GestaoImovelRemoteDataSource: GET /api/imoveis/{id}/ pelo Dio autenticado"
  - "ImovelGestaoModel com só as 9 chaves lidas"
  - "Falhas tipadas da leitura: 401 SessaoExpiradaException, 404 ImovelNaoEncontradoException, demais FalhaDeConexaoException"
affects: [09-05 tracer de UI da gestão, 09-07 tela de gestão, 09-08 mudança de situação]

actuals:
  tokens: 6200
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Model de detalhe só com as chaves lidas (chaves extras do servidor ignoradas, nunca em memória)"
    - "Repositório com _executar<T> genérico e cadeia única de tradução: sessão → DioException (sessão, 404, resto) → TypeError → Exception"

key-files:
  created:
    - lib/domain/entities/imovel_gestao.dart
    - lib/domain/repositories/gestao_imovel_repository.dart
    - lib/domain/usecases/obter_imovel_gestao_usecase.dart
    - lib/data/models/imovel_gestao_model.dart
    - lib/data/models/imovel_gestao_model.freezed.dart
    - lib/data/models/imovel_gestao_model.g.dart
    - lib/data/datasources/gestao_imovel_datasource.dart
    - lib/data/datasources/gestao_imovel_remote_datasource.dart
    - lib/data/repositories/gestao_imovel_repository_impl.dart
    - test/data/imovel_gestao_model_test.dart
    - test/data/gestao_imovel_remote_datasource_test.dart
    - test/data/gestao_imovel_repository_impl_test.dart
  modified:
    - lib/di/injection.config.dart

key-decisions:
  - "O 404 do imóvel de gestão reaproveita ImovelNaoEncontradoException do detalhe público (discrição registrada no plano); o detail em inglês do Django nunca sobe"
  - "situacao_desde é convertida com DateTime.parse(...).toUtc(), garantindo isUtc mesmo se o servidor mandar data sem offset"
  - "Falhas que não são sessão nem 404 (5xx, timeout, FormatException, TypeError) viram FalhaDeConexaoException sem carregar o erro original, para nenhum texto do servidor chegar à apresentação"

patterns-established:
  - "Model de gestão lê finalidade e situação só por codigos_imovel_api.dart (gate de grep proíbe case 'DISPONIVEL'/'VENDA' no Model)"

requirements-completed: [SIT-07]

coverage:
  - id: D1
    description: "O app lê, autenticado, o imóvel de gestão (GET /api/imoveis/36/ com token) até a entidade ImovelGestao, pela pilha de dados inteira sobre o wire capturado"
    requirement: "SIT-07"
    verification:
      - kind: integration
        ref: "test/data/gestao_imovel_remote_datasource_test.dart#pilha de dados"
        status: pass
    human_judgment: false
  - id: D2
    description: "ImovelGestaoModel com só as 9 chaves, situacao_desde em UTC, situação desconhecida → null, finalidade desconhecida → FormatException, sem pode_mudar_situacao → TypeError"
    requirement: "SIT-07"
    verification:
      - kind: unit
        ref: "test/data/imovel_gestao_model_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Falhas tipadas da leitura: 401 → SessaoExpiradaException, 404 → ImovelNaoEncontradoException sem texto do servidor, rede/5xx/JSON ruim → FalhaDeConexaoException"
    requirement: "SIT-07"
    verification:
      - kind: unit
        ref: "test/data/gestao_imovel_repository_impl_test.dart"
        status: pass
      - kind: integration
        ref: "test/data/gestao_imovel_remote_datasource_test.dart#401 e corpo inválido"
        status: pass
    human_judgment: false

duration: 3 min
completed: 2026-11-22
plan_head_before: 495977c9838c6ece2a7d6e14d073ed68f58e3113
commits: 2
status: complete
---

# Phase 9 Plan 04: Camada de dados do imóvel de gestão Summary

**Leitura autenticada de `GET /api/imoveis/{id}/` até `ImovelGestao` (UseCase → Repository → DataSource no `Dio` `'autenticado'` → Model de 9 chaves), com 401, 404 e falhas de conexão tipados e sem texto do servidor**

## Performance

- **Duration:** 3 min
- **Started:** 2026-11-22T15:36:33Z
- **Completed:** 2026-11-22T15:39:34Z
- **Tasks:** 2
- **Files modified:** 13 (12 criados, 1 alterado: `injection.config.dart`)

## Accomplishments

- Tracer de dados: `ObterImovelGestaoUseCase(36)` sobre a pilha real (`GestaoImovelRepositoryImpl` → `GestaoImovelRemoteDataSource` → `Dio` de `criarDioAutenticado` com `InterceptadorSessao`) pede `GET /api/imoveis/36/` (barra final, `Authorization: Token token-de-teste`) e devolve `Success(ImovelGestao)` com o wire capturado no 09-01 (id 36, `DEV-INDAIATUBA-04`, disponível, `podeMudarSituacao` verdadeiro). Tudo registrado no DI gerado.
- `ImovelGestaoModel` declara só as 9 chaves lidas (`id`, `codigo`, `titulo`, `finalidade`, `preco_venda`, `preco_aluguel`, `situacao`, `situacao_desde`, `pode_mudar_situacao`); um teste trava que o `toJson` tem exatamente essas chaves (nada de dono, descrição ou endereço, T-09-06). `paraEntidade()` usa `finalidadeDoCodigo`/`situacaoDoCodigo` do 09-03, sem mapa próprio.
- Falhas tipadas no repositório (`_executar<T>`): sessão expirada (direta ou dentro do `DioException.error`), 404 → `ImovelNaoEncontradoException` (o `No Imovel matches...` do Django nunca sobe, provado por teste), e 5xx/timeout/`FormatException`/`TypeError` → `FalhaDeConexaoException`.
- 24 testes novos (1232 → 1256 no total).

## Task Commits

1. **Task 1: TRACER de dados — leitura de GET /api/imoveis/36/ até ImovelGestao** - `a15cf0b` (feat; tracer, testes primeiro)
2. **Task 2: Falhas tipadas da leitura (401, 404, rede, JSON ruim)** - `2358d97` (feat; TDD, RED observado com os 2 testes de 404 falhando antes do ramo 404)

**Plan metadata:** commit docs(09-04) logo após este SUMMARY.

## Files Created/Modified

- `lib/domain/entities/imovel_gestao.dart` - entidade imutável do imóvel de gestão (`==`/`hashCode`/`toString` à mão)
- `lib/domain/repositories/gestao_imovel_repository.dart` - interface com `obterImovel(int id)` e doc das falhas tipadas
- `lib/domain/usecases/obter_imovel_gestao_usecase.dart` - UseCase `@injectable` sem lógica
- `lib/data/models/imovel_gestao_model.dart` (+ `.freezed.dart`, `.g.dart`) - Model freezed de 9 chaves e `paraEntidade()`
- `lib/data/datasources/gestao_imovel_datasource.dart` / `gestao_imovel_remote_datasource.dart` - interface e implementação remota (`@Named('autenticado')`, `'/api/imoveis/$id/'`, guarda de corpo)
- `lib/data/repositories/gestao_imovel_repository_impl.dart` - tradução de falhas
- `lib/di/injection.config.dart` - registro dos quatro tipos novos
- `test/data/imovel_gestao_model_test.dart`, `gestao_imovel_remote_datasource_test.dart`, `gestao_imovel_repository_impl_test.dart` - 24 casos

## Decisions Made

- O 404 reaproveita `ImovelNaoEncontradoException` do detalhe público, como o plano registrou.
- `situacaoDesde` usa `DateTime.parse(...).toUtc()`: o plano pedia `DateTime.parse`, mas o `.toUtc()` extra garante UTC também para uma data sem offset (sem custo para o wire real, que já traz `-03:00`).
- Falhas genéricas não carregam o erro original (`FalhaDeConexaoException` const), diferente do acervo, que repassa a `DioException`; assim nenhum corpo de 5xx chega à tela (T-09-05).

## Deviations from Plan

None - plan executed exactly as written.

(O `.toUtc()` é um reforço de uma linha dentro da mesma instrução da `paraEntidade()`, não um desvio de escopo.)

## Issues Encountered

None. O `build_runner` já ignora `--delete-conflicting-outputs` (opção removida nesta versão, apenas um aviso) e não alterou nenhum gerado existente; só `injection.config.dart` mudou, com diff real (sem gerados só-CRLF para restaurar).

## Verificação

- Tracer (Task 1): `flutter test` dos três arquivos (13 + acervo) verde; `flutter analyze lib` sem problemas; gates de `grep` passaram (rota com barra final, `@Named('autenticado')`, DI, mapa compartilhado, sem `case 'DISPONIVEL'`/`'VENDA'`, sem `proprietario|descricao|endereco` no Model). Feedback gate do tracer (modo interativo, `end-of-phase`, `<verify>` só automatizado): `<verify>` re-executado de ponta a ponta com sucesso, então seguiu para a Task 2.
- Task 2: RED com 2 falhas (404), GREEN com 15 testes de repositório + DataSource; gate de `grep` do repositório passou (sem o texto em inglês do Django).
- `flutter analyze lib`: No issues found.
- `flutter test` inteiro: **1256 verdes** (1232 antes deste plano + 24).
- Nenhum gerado só-CRLF deixado modificado; nenhum push.

## Threat Flags

None - nenhuma superfície nova além da planejada (T-09-04, T-09-02, T-09-06, T-09-05, T-09-10 mitigados por teste e gate de grep; T-09-SC: nenhum pacote novo).

## Known Stubs

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 09-05 (tracer de UI: cartão → tela → Cubit) já pode consumir `ObterImovelGestaoUseCase` e tratar `SessaoExpiradaException`, `ImovelNaoEncontradoException` e `FalhaDeConexaoException` por tipo.
- Commits locais em `feat/APP09`; nenhum push.

## Self-Check: PASSED

- Os 12 arquivos criados existem em disco (verificados pelo `git status` e pelos testes verdes).
- Commits `a15cf0b` e `2358d97` existem em `feat/APP09`; `git rev-list --count 495977c..HEAD` = 2.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
