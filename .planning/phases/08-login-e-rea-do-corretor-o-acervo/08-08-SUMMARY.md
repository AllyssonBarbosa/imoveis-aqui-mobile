---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 08
subsystem: acervo
tags: [flutter, dio, datasource, repository, usecase, injectable, acervo]

requires:
  - phase: 08-02
    provides: "Dio autenticado (@Named('autenticado')), InterceptadorSessao (401 tipado), mesmaOrigem"
  - phase: 08-05
    provides: "SemPermissaoException ao lado de SessaoExpiradaException"
  - phase: 08-06
    provides: "ConsultaAcervo, PaginaAcervo, AcervoEnvelopeModel, ImovelAcervoModel"
provides:
  - "parametrosDaConsultaAcervo e codigoDaSituacao (funcoes puras: busca so se nao vazia apos trim, situacao ausente em Todas)"
  - "AcervoDataSource / AcervoRemoteDataSource: GET /api/imoveis/ no Dio autenticado, seguir(next) so na mesma origem"
  - "AcervoRepository / AcervoRepositoryImpl: 401 -> SessaoExpiradaException, 403 -> SemPermissaoException, TypeError e FormatException -> Failure tipada"
  - "BuscarAcervoUseCase (call e seguir) pronto para o AcervoCubit (08-09)"
  - "ApiFalsa: rota GET /api/imoveis/ (401 sem token, fixtures por parametro)"
affects: [08-09 AcervoCubit, 08-10, 08-11, 08-12]

actuals:
  tokens: 14000
  tasks: 2
  commits: 2
plan_head_before: eb038e65fadf328d1af21ec8b10110fb9097273b
plan_head_after: a2018934deb865ba11fe61a93d6a536243524777

tech-stack:
  added: []
  patterns:
    - "DataSource fina sobre o Dio autenticado: nao captura DioException, nao loga, nao filtra nem ordena"
    - "Guarda de mesma origem do next via mesmaOrigem (08-02) antes de qualquer GET"
    - "Repositorio traduz por tipo: sessao expirada (direta ou em DioException.error) > 403 > DioException > TypeError > Exception"

key-files:
  created:
    - lib/data/datasources/acervo_datasource.dart
    - lib/data/datasources/parametros_consulta_acervo.dart
    - lib/data/datasources/acervo_remote_datasource.dart
    - lib/domain/repositories/acervo_repository.dart
    - lib/data/repositories/acervo_repository_impl.dart
    - lib/domain/usecases/buscar_acervo_usecase.dart
    - test/data/parametros_consulta_acervo_test.dart
    - test/data/acervo_remote_datasource_test.dart
    - test/data/acervo_repository_impl_test.dart
  modified:
    - lib/di/injection.config.dart
    - test/support/api_falsa.dart

key-decisions:
  - "A FormatException de finalidade desconhecida (T-08-33) ja e uma Exception: passa pelo ramo generico do repositorio como Failure, sem ramo proprio"
  - "A guarda de origem usa a funcao pura mesmaOrigem (08-02); as copias antigas das outras DataSources ficam intactas"

patterns-established:
  - "ApiFalsa serve rotas autenticadas checando Authorization e devolvendo erro_401.json sem token"

requirements-completed: [ACV-01, ACV-02, ACV-04]

coverage:
  - id: D1
    description: "Consulta do acervo vai ao servidor como busca (so nao vazia) e situacao (ausente em Todas)"
    requirement: "ACV-02"
    verification:
      - kind: unit
        ref: "test/data/parametros_consulta_acervo_test.dart#parametrosDaConsultaAcervo"
        status: pass
      - kind: integration
        ref: "test/data/acervo_remote_datasource_test.dart#buscar com busca manda ?busca="
        status: pass
    human_judgment: false
  - id: D2
    description: "next de outra origem nao gera pedido; o token nao sai da API"
    requirement: "ACV-01"
    verification:
      - kind: integration
        ref: "test/data/acervo_remote_datasource_test.dart#seguir com next de outra origem"
        status: pass
    human_judgment: false
  - id: D3
    description: "401, 403 e erros de parse chegam acima do repositorio como falhas tipadas"
    requirement: "ACV-04"
    verification:
      - kind: unit
        ref: "test/data/acervo_repository_impl_test.dart#AcervoRepositoryImpl"
        status: pass
    human_judgment: false
  - id: D4
    description: "BuscarAcervoUseCase repassa ao repositorio sem logica propria"
    requirement: "ACV-01"
    verification:
      - kind: unit
        ref: "test/data/acervo_repository_impl_test.dart#BuscarAcervoUseCase"
        status: pass
    human_judgment: false

duration: 22min
completed: 2026-11-21
status: complete
---

# Phase 8 Plan 08: Camada de dados do acervo Summary

**Acervo do corretor na camada de dados: GET /api/imoveis/ pelo Dio autenticado com busca e situacao na query, paginacao pelo next preso a origem da API, repositorio com 401/403 tipados e BuscarAcervoUseCase.**

## Performance

- **Duration:** 22 min
- **Completed:** 2026-11-21T14:48Z
- **Tasks:** 2
- **Files modified:** 11 (9 criados, 2 alterados)

## Accomplishments
- `parametrosDaConsultaAcervo`/`codigoDaSituacao`: unico lugar que conhece os nomes dos parametros do acervo; "Todas" (situacao nula) nao gera chave.
- `AcervoRemoteDataSource` (`@LazySingleton(as: AcervoDataSource)`) sobre o Dio `autenticado`; `seguir` exige `mesmaOrigem` antes do GET (T-08-30).
- `AcervoRepositoryImpl` traduz sessao expirada (direta ou no `DioException.error`), 403, `TypeError` e `FormatException`; nenhuma ordenacao ou filtro local (T-08-53).
- `ApiFalsa` ganhou `GET /api/imoveis/`; o 401 do repositorio e provado na pilha real (DataSource + ApiFalsa + InterceptadorSessao sem token).

## Task Commits

1. **Task 1: parametros + DataSource + rota na ApiFalsa** - `9391147` (feat)
2. **Task 2: repositorio + use case** - `a201893` (feat)

**Plan metadata:** commit docs(08-08) seguinte.

## Files Created/Modified
- `lib/data/datasources/acervo_datasource.dart` - interface (`buscar`, `seguir`)
- `lib/data/datasources/parametros_consulta_acervo.dart` - funcoes puras de parametros
- `lib/data/datasources/acervo_remote_datasource.dart` - GET /api/imoveis/ + guarda de origem
- `lib/domain/repositories/acervo_repository.dart` - interface de dominio
- `lib/data/repositories/acervo_repository_impl.dart` - traducao de falhas
- `lib/domain/usecases/buscar_acervo_usecase.dart` - `call` e `seguir`
- `lib/di/injection.config.dart` - registros gerados (DataSource, Repository, UseCase)
- `test/support/api_falsa.dart` - rota do acervo
- `test/data/{parametros_consulta_acervo,acervo_remote_datasource,acervo_repository_impl}_test.dart` - 12 + 13 testes novos

## Decisions Made
- A `FormatException` de finalidade desconhecida (T-08-33) e `Exception`, entao cai no ramo generico como `Failure` tipada; ha teste dedicado com a fixture adulterada (`PERMUTA`).
- `mesmaOrigem` do 08-02 reutilizada; as duas copias antigas nao foram tocadas, como o plano pediu.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Caminho do repositorio web desatualizado**
- O plano cita o repositorio web antigo em OneDrive; este plano nao altera o repositorio web (so app), entao nenhuma substituicao foi necessaria alem de registrar a diferenca.

**2. Criterio "flutter analyze lib limpo"**
- `flutter analyze lib` reporta 30 `info` `deprecated_member_use` preexistentes (material.dart no Flutter 3.47), todos fora dos arquivos deste plano; nenhum arquivo criado/alterado aqui aparece na lista. Nao corrigidos (fora de escopo, orientacao do orquestrador).

**3. Ciclo TDD**
- Task 1: RED observado (testes nao carregavam: simbolos inexistentes) antes da implementacao. Task 2: testes e implementacao escritos na mesma rodada; os testes passaram na primeira execucao. Cada task gerou um unico commit `feat` (o plano pede um commit por task), sem commit `test` separado.

---

**Total deviations:** 0 correcoes de codigo; 3 notas de processo.
**Impact on plan:** nenhum no escopo entregue.

## Issues Encountered
- Um heredoc grande no shell falhou sem escrever nada; os arquivos foram criados com a ferramenta Write.
- `build_runner` regenerou 30 arquivos so por CRLF; restaurados com `git checkout --` por lista explicita depois de confirmar `git diff --ignore-space-at-eol` vazio. Apenas `injection.config.dart` tinha mudanca real.

## Known Stubs
None.

## Threat Flags
None (os limites de confianca estao no threat_model do plano: next nao confiavel e token preso a origem, ambos mitigados e testados).

## Verification
- `flutter test` completo: 930 testes passando (905 antes + 25 novos).
- `flutter analyze lib`: 30 infos preexistentes, nenhum novo.

## Next Phase Readiness
- `BuscarAcervoUseCase` injetavel; o `AcervoCubit` (08-09) pode usar `call(ConsultaAcervo)` e `seguir(proximaPagina)` e decidir so pelo tipo da falha (`SessaoExpiradaException`, `SemPermissaoException`, demais).

## Self-Check: PASSED
- Arquivos criados existem; commits `9391147` e `a201893` estao no HEAD; testes e greps de aceitacao passaram.

---
*Phase: 08-login-e-rea-do-corretor-o-acervo*
*Completed: 2026-11-21*
