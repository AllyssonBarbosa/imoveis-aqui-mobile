---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 01
subsystem: data
tags: [flutter, freezed, json_serializable, injectable, clean-architecture, mock-datasource]

requires:
  - phase: 04-detalhe-do-imovel
    provides: "padrão de DataSource trocável + servidor simulado + Result; corretores 7/8/9 do mock do detalhe"
provides:
  - "PerfilCorretor (entidade freezed) com os campos públicos da WEB 02"
  - "PerfilRepository + PerfilNaoEncontradoException (contrato de falha do 404)"
  - "PerfilCorretorModel.fromJson defensivo (textoOuNulo / urlHttpOuNula)"
  - "PerfilDataSource + PerfilMockDataSource (@LazySingleton(as: PerfilDataSource)) e corretoresPerfisFixture() com os corretores 7, 8, 9 e 10"
  - "PerfilRepositoryImpl (@LazySingleton(as: PerfilRepository)) -> Result"
affects: [07-02, 07-05, 07-07, 07-08, 07-09]

actuals:
  tokens: 11750
  tasks: 2
  commits: 3

tech-stack:
  added: []
  patterns:
    - "Model defensivo: texto opcional em branco vira null (textoOuNulo), foto fora de http(s) vira null (urlHttpOuNula)"
    - "Mock com construtor padrão (fixture + 500 ms) e .paraTeste(latencia zero), parseado pelo mesmo fromJson da remota"

key-files:
  created:
    - lib/domain/entities/perfil_corretor.dart
    - lib/domain/repositories/perfil_repository.dart
    - lib/data/models/texto_opcional.dart
    - lib/data/models/perfil_corretor_model.dart
    - lib/data/datasources/perfil_datasource.dart
    - lib/data/datasources/perfil_mock_datasource.dart
    - lib/data/mocks/perfis_fixture.dart
    - lib/data/repositories/perfil_repository_impl.dart
    - test/data/perfil_mock_datasource_test.dart
  modified:
    - lib/di/injection.config.dart

key-decisions:
  - "Corretor 10 (Bruno Sales, empresa 3) existe só na fixture de perfis, sem imóvel no acervo, para provar a vitrine vazia do anunciante pela pilha real."
  - "PerfilRepositoryImpl captura só Exception nesta fatia; a tradução de TypeError/DioException 404 entra com a fonte remota (07-05)."

patterns-established:
  - "Perfil público: a camada de dados normaliza vazios para ausentes; o app nunca completa, infere nem formata o dado."

requirements-completed: [PERF-04, PERF-02]

coverage:
  - id: D1
    description: "Buscar um corretor por id no servidor simulado devolve o perfil normalizado (vazios viram ausentes, foto não http(s) vira null) pelo repositório"
    requirement: PERF-04
    verification:
      - kind: unit
        ref: "test/data/perfil_mock_datasource_test.dart#buscarCorretor pela pilha repositório -> mock"
        status: pass
    human_judgment: false
  - id: D2
    description: "Id sem perfil resulta em Failure com PerfilNaoEncontradoException tipada, sem dados inventados"
    requirement: PERF-04
    verification:
      - kind: unit
        ref: "test/data/perfil_mock_datasource_test.dart#id sem perfil falha com PerfilNaoEncontradoException"
        status: pass
    human_judgment: false
  - id: D3
    description: "Fixture de perfis determinística, com as nove chaves da WEB 02 e corretores 7, 8, 9 e 10 (10 sem imóveis)"
    requirement: PERF-02
    verification:
      - kind: unit
        ref: "test/data/perfil_mock_datasource_test.dart#corretoresPerfisFixture"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-08
status: complete
plan_head_before: 76c463db6d0d9e627b2c0dc646d44a1e0915e834
plan_head_after: 6ab64f0d9fedfaddf3b698ed64adc5b4614cc624
---

# Phase 7 Plan 01: Dados do perfil do corretor Summary

**Camada de dados do perfil do corretor: entidade freezed, Model defensivo sobre o wire da WEB 02, DataSource trocável com servidor simulado (corretores 7, 8, 9 e 10) e repositório que devolve Result, com 404 tipado**

## Performance

- **Duration:** 25 min
- **Started:** 2026-11-08T17:44:00Z
- **Completed:** 2026-11-08T18:09:00Z
- **Tasks:** 2
- **Files modified:** 9 criados + 1 regenerado (mais 6 gerados pelo build_runner)

## Accomplishments
- `PerfilCorretor` + `PerfilNaoEncontradoException` + `PerfilRepository.buscarCorretor` no domínio, sem nenhuma dependência de data.
- `PerfilCorretorModel` com as 9 chaves da WEB 02: textos em branco viram `null`, foto fora de http(s) vira `null`, nada completado nem formatado no aparelho (D-01, D-04).
- `PerfilMockDataSource` e `corretoresPerfisFixture()` coerentes com os corretores do detalhe mock; Bruno Sales (id 10) é válido e sem imóveis.
- Registro no DI regenerado (`injection.config.dart`); suíte completa verde (594 testes) e `flutter analyze` limpo.

## Task Commits

1. **Task 1: entidade, contrato do 404 e Model defensivo** - `d6a92c1` (feat)
2. **Task 2 (TDD): teste de dados - RED** - `9b238f1` (test)
3. **Task 2 (TDD): DataSource, mock, fixture e repositório - GREEN** - `6ab64f0` (feat)

**Plan metadata:** commit docs(07-01) deste SUMMARY, em seguida.

## Files Created/Modified
- `lib/domain/entities/perfil_corretor.dart` - entidade freezed do perfil público
- `lib/domain/repositories/perfil_repository.dart` - contrato `PerfilRepository` e exceção do 404
- `lib/data/models/texto_opcional.dart` - `textoOuNulo`
- `lib/data/models/perfil_corretor_model.dart` - Model de transporte + `paraEntidade()`
- `lib/data/datasources/perfil_datasource.dart` - interface trocável e `caminhoPerfilCorretor`
- `lib/data/datasources/perfil_mock_datasource.dart` - servidor simulado
- `lib/data/mocks/perfis_fixture.dart` - wire da WEB 02 dos corretores 7, 8, 9 e 10
- `lib/data/repositories/perfil_repository_impl.dart` - repositório -> `Result`
- `test/data/perfil_mock_datasource_test.dart` - prova repositório -> mock -> Model -> entidade
- `lib/di/injection.config.dart` - registros do mock e do repositório (só regenerado)

## Decisions Made
- Seguido o plano. O repositório captura só `Exception`; `TypeError`/`DioException` 404 ficam para a 07-05, como o plano previu (T-07-02).

## Deviations from Plan

### Execution notes (não são correções de código)

**1. Precondição de branch.** A precondição da Task 1 pedia `feat/APP07`; este executor roda no worktree isolado `worktree-agent-a7f29da4d01f2f279` por instrução do orquestrador, que é o dono do ciclo de vida da branch. Espaço em disco verificado (239 GiB livres).

**2. Ruído de fim de linha nos gerados.** O build_runner reescreve com LF 18 arquivos gerados já versionados (`core.autocrlf=true`; `git diff --ignore-space-at-eol` vazio). Eles foram restaurados com `git checkout -- <arquivo>` e não entraram nos commits; só os arquivos novos e `injection.config.dart` (mudança real de 13 linhas) foram versionados.

Nenhuma correção por regras 1 a 3.

**Total deviations:** 0 auto-fixed. **Impact:** nenhum no escopo.

## Issues Encountered
None

## Known Stubs
Nenhum stub de UI. A fixture e o `PerfilMockDataSource` são intencionalmente dev-only (servidor simulado); a fonte remota é a 07-05.

## Threat Flags
Nenhum — nenhuma superfície nova além da registrada no threat_model (T-07-01 mitigado por `urlHttpOuNula` no Model).

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Pronto para o tracer 07-02 ligar `CartaoCorretor` -> Cubit -> UseCase -> este `PerfilRepository`.
- Ponto quente de merge: `lib/di/injection.config.dart` (resolver regenerando).

## Self-Check: PASSED
- Arquivos criados existem; commits `d6a92c1`, `9b238f1`, `6ab64f0` são ancestrais de HEAD.
- Critérios de aceitação das duas tasks, `flutter analyze`, `flutter test` (594) e as guardas grep/git passaram.

---
*Phase: 07-perfis-p-blicos-da-empresa-e-do-corretor*
*Completed: 2026-11-08*
