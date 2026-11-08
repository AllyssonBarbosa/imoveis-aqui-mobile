---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 05
subsystem: data
tags: [dio, freezed, json_serializable, injectable, result, perfis]

requires:
  - phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
    provides: PerfilDataSource, PerfilCorretorModel, PerfilRepositoryImpl, contrato §12 e exemplos de wire (07-01, 07-03)
provides:
  - Cadeia única de tradução de erros dos perfis (_executar) no repositório
  - PerfilRemoteDataSource (Dio) pronta e testada, registrada sem as: (mock segue ativo)
  - PerfilEmpresa + TipoEmpresa e PerfilEmpresaModel defensivo
affects: [07-09 buscarEmpresa, 07-11 pagina da empresa, Phase 5 troca mock->real]

actuals:
  tokens: 14000
  tasks: 3
  commits: 3
  plan_head_before: 7455cb930434d0b9ffdcfaadf99b89bd65c8ed0d
  plan_head_after: e73fe1d075dd9defffc42f69b98e8e37b0b79ae4

tech-stack:
  added: []
  patterns:
    - "Tradução de erros num _executar<T> genérico (PerfilNaoEncontrada > DioException 404 > TypeError > Exception)"
    - "Remota fina sem as: — a troca mock->real é mover a anotação e rodar build_runner"
    - "Model da empresa não declara corretores_ativos (minimização de dados)"

key-files:
  created:
    - lib/data/datasources/perfil_remote_datasource.dart
    - lib/domain/entities/perfil_empresa.dart
    - lib/data/models/perfil_empresa_model.dart
    - test/data/perfil_model_test.dart
    - test/data/perfil_repository_impl_test.dart
    - test/data/perfil_remote_datasource_test.dart
  modified:
    - lib/data/repositories/perfil_repository_impl.dart
    - lib/di/injection.config.dart
    - test/di/injection_perfis_test.dart

key-decisions:
  - "Só o mock leva as: PerfilDataSource; a remota usa @lazySingleton simples (duas anotações as: quebrariam o getIt)"
  - "tipo desconhecido da empresa vira null (sem rótulo) em vez de lançar"
  - "Remota sem interceptador de log: o corpo traz e-mail e telefone"

patterns-established:
  - "Cadeia de erros dos perfis centralizada em _executar; 07-09 só acrescenta buscarEmpresa por ela"

requirements-completed: [PERF-04, PERF-05, PERF-01]

coverage:
  - id: D1
    description: "Repositório traduz 404/DioException/TypeError/Exception em Result tipado"
    requirement: PERF-05
    verification:
      - kind: unit
        ref: "test/data/perfil_repository_impl_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "PerfilRemoteDataSource lê GET /api/publico/corretores/{id}/ com Dio real, 404/500/corpo ruim tipados e buscas concorrentes isoladas"
    requirement: PERF-04
    verification:
      - kind: integration
        ref: "test/data/perfil_remote_datasource_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "DI mantém o mock como PerfilDataSource ativa e registra a remota"
    requirement: PERF-04
    verification:
      - kind: unit
        ref: "test/di/injection_perfis_test.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "PerfilEmpresaModel/PerfilEmpresa parseiam o exemplo do §12 de forma defensiva (tipo, textos, logomarca, cidades, sem corretores_ativos)"
    requirement: PERF-01
    verification:
      - kind: unit
        ref: "test/data/perfil_model_test.dart#empresa"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-08
status: complete
---

# Phase 7 Plan 05: Camada de dados real dos perfis Summary

**Repositório dos perfis com `_executar` tipado (404/Dio/TypeError), `PerfilRemoteDataSource` Dio provada pela pilha real com o mock ainda ativo no DI, e `PerfilEmpresa`/`PerfilEmpresaModel` defensivos provados contra o exemplo do §12.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 3
- **Files modified:** 9 (6 criados + 3 modificados, mais 3 gerados freezed/g)

## Accomplishments
- `PerfilRepositoryImpl` passa por `_executar<T>`: `PerfilNaoEncontradoException` > `DioException` (404 vira `PerfilNaoEncontradoException`) > `TypeError` (vira `FormatException`) > `Exception`.
- `PerfilRemoteDataSource` (`@lazySingleton` sem `as:`): URL exata `/api/publico/corretores/7/`, corpo não-objeto vira `FormatException`, sem interceptador de log; provada com Dio real + adaptador falso (200, 404, 500, lista, sem nome, duas buscas concorrentes).
- DI: `getIt<PerfilDataSource>()` continua o mock; `getIt<PerfilRemoteDataSource>()` resolve.
- `TipoEmpresa`, `PerfilEmpresa` e `PerfilEmpresaModel` (10 chaves, `corretores_ativos` não declarado), provados contra `perfil_empresa.example.json`.

## Task Commits

1. **Task 1: Tradução tipada de erros e parse defensivo do corretor** - `a79ec60` (feat)
2. **Task 2: PerfilRemoteDataSource com mock ativo no DI** - `cb7b7b3` (feat)
3. **Task 3: PerfilEmpresa e PerfilEmpresaModel defensivo** - `e73fe1d` (feat)

## Files Created/Modified
- `lib/data/repositories/perfil_repository_impl.dart` - `_executar` genérico
- `lib/data/datasources/perfil_remote_datasource.dart` - remota Dio
- `lib/domain/entities/perfil_empresa.dart` - entidade + enum
- `lib/data/models/perfil_empresa_model.dart` - Model defensivo (+ `.freezed.dart`/`.g.dart`)
- `lib/di/injection.config.dart` - registro da remota
- `test/data/perfil_model_test.dart`, `perfil_repository_impl_test.dart`, `perfil_remote_datasource_test.dart`, `test/di/injection_perfis_test.dart`

## Decisions Made
- Seguiu o plano: remota sem `as:`, `tipo` desconhecido vira `null`, sem log de corpo.

## Deviations from Plan

None - plan executed exactly as written. (Erros menores de teste corrigidos durante o RED/GREEN: campo `Success.data` e índice do segmento da URI no adaptador do teste de concorrência; sem mudança de código de produção.)

Observação operacional: o `build_runner` reescreveu ~22 arquivos gerados só com diferença de fim de linha (CRLF); foram restaurados com `git checkout` e só `injection.config.dart` e os gerados novos foram commitados.

## Issues Encountered
None

## Known Stubs
Nenhum. A remota existe mas não é a `PerfilDataSource` ativa por decisão do plano (D-03); a troca é da Phase 5.

## Threat Flags
Nenhum fora do `<threat_model>` do plano.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- 07-09 pode acrescentar `buscarEmpresa` na interface, na remota, no mock e no `_executar`; 07-11 consome `PerfilEmpresa`.
- `lib/di/injection.config.dart` é ponto quente de merge com a Phase 5 e com o plano irmão 07-04 (resolver regenerando).

## Self-Check: PASSED
- Arquivos criados existem; commits `a79ec60`, `cb7b7b3`, `e73fe1d` presentes; `flutter test test/data test/di` (272 testes) e `flutter analyze` limpos.

---
*Phase: 07-perfis-p-blicos-da-empresa-e-do-corretor*
*Completed: 2026-11-08*
