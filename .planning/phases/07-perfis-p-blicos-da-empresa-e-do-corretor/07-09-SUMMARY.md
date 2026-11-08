---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 09
subsystem: data
tags: [flutter, perfis, empresa, mock, dio, contrato-web02]

requires:
  - phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
    provides: "PerfilEmpresa/PerfilEmpresaModel, _executar do repositorio, PerfilRemoteDataSource, corretoresPerfisFixture, exemplo do contrato"
provides:
  - "empresasPerfisFixture(): empresa 3 (IMOBILIARIA) == exemplo do §12; empresa 4 (AUTONOMO)"
  - "caminhoPerfilEmpresa(id) e buscarEmpresa na interface PerfilDataSource, no mock, na remota e no PerfilRepository"
  - "404 da empresa como PerfilNaoEncontradoException tipado"
affects: [07-10, 07-11, 07-12]

actuals:
  tokens: 14000
  tasks: 2
  commits: 2
plan_head_before: a97f69c43ca2e9457bef1fac0159c515880f112f
plan_head_after: 9c3e7d7e842a512efbb00c28b6fd18c95d06d3a5

tech-stack:
  added: []
  patterns:
    - "corretores_ativos da fixture da empresa montados a partir da fixture dos corretores (nunca copiados)"
    - "buscarEmpresa reaproveita o _executar do repositorio (mesma cadeia 404/Dio/TypeError)"

key-files:
  created: []
  modified:
    - lib/data/mocks/perfis_fixture.dart
    - lib/domain/repositories/perfil_repository.dart
    - lib/data/datasources/perfil_datasource.dart
    - lib/data/datasources/perfil_mock_datasource.dart
    - lib/data/datasources/perfil_remote_datasource.dart
    - lib/data/repositories/perfil_repository_impl.dart
    - test/data/contrato_perfis_test.dart
    - test/data/perfil_mock_datasource_test.dart
    - test/data/perfil_remote_datasource_test.dart

key-decisions:
  - "PerfilMockDataSource.paraTeste ganha empresas opcional (padrao vazio); construtor padrao carrega empresasPerfisFixture()"
  - "Empresa 4 (autonomo Camila Duarte) com telefone e descricao em branco, coerente com a heranca feita no servidor; o app nao completa nada"

patterns-established:
  - "Contrato: empresa 3 da fixture profundamente igual a perfil_empresa.example.json; toda empresa com exatamente as 11 chaves"

requirements-completed: [PERF-01, PERF-04]

coverage:
  - id: D1
    description: "Fixture das empresas (3 IMOBILIARIA == exemplo do §12, 4 AUTONOMO) coerente com os corretores"
    requirement: PERF-01
    verification:
      - kind: unit
        ref: "test/data/contrato_perfis_test.dart#fixture dos perfis de empresa"
        status: pass
    human_judgment: false
  - id: D2
    description: "buscarEmpresa pela camada de dados (mock, remota Dio, repositorio) com 404 e JSON ruim tipados"
    requirement: PERF-04
    verification:
      - kind: unit
        ref: "test/data/perfil_mock_datasource_test.dart#buscarEmpresa pela pilha repositório -> mock"
        status: pass
      - kind: unit
        ref: "test/data/perfil_remote_datasource_test.dart#buscarEmpresa"
        status: pass
    human_judgment: false

duration: 15min
completed: 2026-11-08
status: complete
---

# Phase 7 Plan 09: Fatia de dados da pagina da empresa Summary

**`buscarEmpresa` por toda a camada de dados (interface, servidor simulado, Dio e repositorio via `_executar`) sobre uma fixture de empresas identica ao exemplo do §12 e coerente com os corretores.**

## Performance

- **Duration:** ~15 min
- **Tasks:** 2
- **Files modified:** 9 (5 de producao, 1 fixture, 3 de teste)

## Accomplishments
- `empresasPerfisFixture()`: empresa 3 (Imobiliaria Jequitiba, 3 cidades, corretores 7, 8 e 10) igual ao exemplo e empresa 4 (autonoma Camila Duarte, campos em branco, corretor 9), com `corretores_ativos` derivados da fixture dos corretores.
- `caminhoPerfilEmpresa(id)` e `buscarEmpresa` na interface `PerfilDataSource`, no `PerfilMockDataSource` (404 para id ausente; `.paraTeste` com `empresas` opcional), no `PerfilRemoteDataSource` (GET `/api/publico/empresas/{id}/`) e no `PerfilRepositoryImpl` via `_executar`.
- Testes: contrato (empresa 3 == exemplo, 11 chaves, cidades `{id,nome,uf}`, coerencia empresa_id e corretores_ativos), mock (3, 4, 999, padrao vazio, construtor padrao) e remota (URL exata, 200, 404, corpo-lista, campo ausente).

## Task Commits

1. **Task 1: Fixture das empresas** - `3a96908` (feat)
2. **Task 2: buscarEmpresa pela camada de dados** - `9c3e7d7` (feat)

## Files Created/Modified
- `lib/data/mocks/perfis_fixture.dart` - `empresasPerfisFixture()`
- `lib/domain/repositories/perfil_repository.dart` - `buscarEmpresa`
- `lib/data/datasources/perfil_datasource.dart` - `caminhoPerfilEmpresa` + `buscarEmpresa`
- `lib/data/datasources/perfil_mock_datasource.dart` - `buscarEmpresa`, parametro `empresas`
- `lib/data/datasources/perfil_remote_datasource.dart` - `buscarEmpresa`
- `lib/data/repositories/perfil_repository_impl.dart` - `buscarEmpresa` via `_executar`
- `test/data/contrato_perfis_test.dart`, `test/data/perfil_mock_datasource_test.dart`, `test/data/perfil_remote_datasource_test.dart` - casos novos

## Decisions Made
- `empresas` em `.paraTeste` e opcional (padrao `const {}`), mantendo validas as chamadas existentes e as do plano 07-08.
- Nenhuma mudanca em DI, `modulo_rede.dart`, `pubspec`, `injection.config.dart` ou no Model.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None. `flutter test` completo (717 testes) e `flutter analyze` verdes; `git diff ba77b1e` em `modulo_rede.dart`/`pubspec.yaml`/`pubspec.lock` vazio.

## Known Stubs
None (a fixture e o servidor simulado dev-only sao intencionais por D-03).

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Camada de dados da empresa pronta para a pagina da empresa e o cartao (07-10/07-11). O caso "corretor 200 com empresa 404" (PENDENTE WEB 12.8 d) fica para a tela (07-12).

## Self-Check: PASSED

---
*Phase: 07-perfis-p-blicos-da-empresa-e-do-corretor*
*Completed: 2026-11-08*
