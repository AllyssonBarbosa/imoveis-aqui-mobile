---
phase: 12-area-do-gestor-acompanhamento-dos-corretores
plan: 06
subsystem: data
tags: [dio, repository, datasource, injectable, area-do-gestor, relatorios, api-falsa]

requires:
  - phase: 12-04
    provides: interface AreaGestorRepository, entidades e use cases da Área do gestor
  - phase: 12-05
    provides: Models TotaisPorSituacaoModel, AcervoPorCorretorModel, ContatosPorCorretorModel e MudancasRecentesModel
provides:
  - AreaGestorDataSource (interface) e AreaGestorRemoteDataSource no Dio @Named('autenticado') com as 4 rotas /api/relatorios/
  - AreaGestorRepositoryImpl com a cadeia única de tradução de falhas (401, 403, genérica, wire malformado)
  - rotas /api/relatorios/ na ApiFalsa dos testes (fixtures reais do 12-02; 401 sem token) e o getter requisicoesDosRelatorios
  - DI de produção resolvendo use case -> repositório -> DataSource -> Dio autenticado
affects: [12-07, 12-08, 12-09]

plan_head_before: 3778aacbe05244c5e390a17e5520a076c5ff9322
plan_head_after: f7aef88149761041858132f08717d9ad33fdd88d

actuals:
  tokens: 9100
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "DataSource fina no Dio autenticado: uma chamada por relatório, _lerObjeto recusa corpo que não é objeto, sem try/catch e sem log"
    - "Repositório com _executar<M, T>: sessão expirada (direta, via interceptador ou 401) antes do 403, TypeError vira FormatException, o mapeamento do Model roda dentro do try"
    - "ApiFalsa não decide papel: o 403 de quem não é gestor é simulado nos testes com responder(..., status: 403, fixture: 'erro_403_relatorio.json')"

key-files:
  created:
    - lib/data/datasources/area_gestor_datasource.dart
    - lib/data/datasources/area_gestor_remote_datasource.dart
    - lib/data/repositories/area_gestor_repository_impl.dart
    - test/data/area_gestor_remote_datasource_test.dart
    - test/data/area_gestor_repository_impl_test.dart
  modified:
    - test/support/api_falsa.dart
    - lib/di/injection.config.dart

key-decisions:
  - "Contatos reaproveitam parametrosDaConsultaContatos(ConsultaContatos(periodo: periodo)): o único lugar que conhece de/ate; imóvel nunca é passado (D-15) e as outras 3 leituras não levam query (D-19)"
  - "O repositório não tem ramo de 404 tipado (aqui não existe recurso por id); 400/404/5xx/rede/timeout saem como a DioException original"
  - "A checagem de 401 por status fica dentro do ramo DioException, junto com erro.error is SessaoExpiradaException (o interceptador da Phase 8 já converte, mas o repositório não depende disso)"

requirements-completed: [GES-01, GES-02, GES-03, GES-04, GES-05, GES-06]

coverage:
  - id: D1
    description: "AreaGestorRemoteDataSource pede as 4 rotas /api/relatorios/ pelo Dio autenticado, com token, sem imovel nem dias; contatos só com de/ate quando há período"
    requirement: GES-01
    verification:
      - kind: unit
        ref: "test/data/area_gestor_remote_datasource_test.dart (11 testes)"
        status: pass
    human_judgment: false
  - id: D2
    description: "AreaGestorRepositoryImpl traduz 401 em SessaoExpiradaException e 403 em SemPermissaoException, devolve falha genérica para o resto e nunca lança (inclusive situação desconhecida)"
    requirement: GES-06
    verification:
      - kind: unit
        ref: "test/data/area_gestor_repository_impl_test.dart (19 testes)"
        status: pass
    human_judgment: false
  - id: D3
    description: "ApiFalsa serve as 4 rotas com as fixtures reais (401 sem token) e grava as requisições dos relatórios"
    verification:
      - kind: unit
        ref: "test/data/area_gestor_remote_datasource_test.dart#requisicoesDosRelatorios e 401 nas 4 rotas; test/data/caixa_contatos_*_test.dart (ApiFalsa compartilhada) verdes"
        status: pass
    human_judgment: false

duration: 25min
completed: 2026-11-25
status: complete
---

# Phase 12 Plan 06: Acesso a dados da Área do gestor Summary

**DataSource remota no Dio autenticado com as 4 rotas /api/relatorios/, repositório que traduz 401/403 e nunca lança, e as rotas na ApiFalsa com as fixtures reais do 12-02.**

## Performance

- **Duration:** ~25 min
- **Completed:** 2026-11-25T21:25Z
- **Tasks:** 2 (ambos TDD: RED -> GREEN)
- **Files modified:** 7 (5 criados, 2 alterados)

## Accomplishments

- `AreaGestorRemoteDataSource` (`@LazySingleton(as: AreaGestorDataSource)`, `@Named('autenticado')`) faz os 4 `GET` com barra final; só os contatos levam query (`de`/`ate` `AAAA-MM-DD`, via `parametrosDaConsultaContatos`), e nenhum pedido leva `imovel` nem `dias` (D-15, D-16, D-19).
- `AreaGestorRepositoryImpl` (`@LazySingleton(as: AreaGestorRepository)`) com `_executar`: 401 (direto, via interceptador ou status) vira `SessaoExpiradaException`, 403 vira `SemPermissaoException`, `TypeError` vira `FormatException`, o resto passa como `Failure` genérica; o mapeamento do Model roda dentro do `try`, então situação desconhecida (`EM_OBRA`) vira falha (D-22, D-23, D-24).
- `ApiFalsa` ganhou `_atenderRelatorios` (4 rotas, 401 sem token, `relatorio_contatos_periodo.json` quando há `de`/`ate`) e o getter `requisicoesDosRelatorios`; doc da classe atualizada.
- `lib/di/injection.config.dart` regenerado: a pilha use case -> repositório -> DataSource -> `Dio` autenticado resolve no DI de produção.

## Task Commits

1. **Task 1: DataSource + rotas da ApiFalsa**
   - RED: `4c39d32` (test) — 11 testes + interface + esqueleto com `UnimplementedError` + rotas da ApiFalsa
   - GREEN: `93df76d` (feat) — implementação remota e DI
2. **Task 2: AreaGestorRepositoryImpl**
   - RED: `b01704f` (test) — 19 testes + esqueleto
   - GREEN: `f7aef88` (feat) — `_executar` e DI

**Plan metadata:** commit `docs(12-06)` seguinte a este SUMMARY.

## Files Created/Modified

- `lib/data/datasources/area_gestor_datasource.dart` — interface com os 4 métodos que devolvem Models.
- `lib/data/datasources/area_gestor_remote_datasource.dart` — implementação remota, fina, com `_lerObjeto`.
- `lib/data/repositories/area_gestor_repository_impl.dart` — repositório e cadeia de tradução de falhas.
- `lib/di/injection.config.dart` — registra DataSource e repositório (gerado).
- `test/support/api_falsa.dart` — `_atenderRelatorios`, `requisicoesDosRelatorios` e doc.
- `test/data/area_gestor_remote_datasource_test.dart`, `test/data/area_gestor_repository_impl_test.dart` — 30 testes novos.

## Decisions Made

Ver `key-decisions` no frontmatter. Em resumo: contatos reutilizam o mapeamento de query da caixa da APP-10 sem imóvel; sem ramo de 404 tipado; 401 por status e por `erro.error` coexistem.

## TDD Gate Compliance

- RED (Task 1): `test(12-06)` `4c39d32` — os 11 testes da DataSource falham com `UnimplementedError` do esqueleto (alvo executou e falhou por comportamento ausente, não por erro de compilação). Avaliação semântica: válido.
- RED (Task 2): `test(12-06)` `b01704f` — os 19 testes do repositório falham com `UnimplementedError`. Avaliação semântica: válido.
- GREEN: `feat(12-06)` `93df76d` e `f7aef88`, cada um depois do seu RED. Sem commit de REFACTOR (nada a limpar).
- Nota: `gsd_run check tdd-red-evidence` não tem adaptador para o relatório do `flutter test`, então a evidência RED foi conferida pela saída real do comando (falhas por `UnimplementedError`), não pelo classificador. O esqueleto sem comportamento foi incluído no commit RED para que o teste compile e falhe na asserção, em vez de falhar por símbolo inexistente (que seria `build_failure`).

## Deviations from Plan

None - plan executed exactly as written. (O esqueleto no commit RED é a forma de cumprir "ver falhar" em Dart, não um desvio de escopo.)

## Issues Encountered

- `dart run build_runner build -d` reescreveu 60 arquivos gerados só com diferença de fim de linha; foram restaurados com `git checkout --` e só `lib/di/injection.config.dart` (mudança real) foi commitado, como nos planos 12-04 e 12-05.

## Verification

- `flutter test` das 4 suítes do plano (DataSource, repositório, use cases e caixa) verde; suíte inteira: **1855 testes verdes** (1825 + 30 novos).
- `flutter analyze lib --no-fatal-infos`: 53 infos, todos o `deprecated_member_use` do `material.dart` (baseline), nenhum erro, warning ou info novo; arquivos novos de teste e `api_falsa.dart` sem problemas.
- Greps de aceitação do plano: OK (`@Named('autenticado')`, `parametrosDaConsultaContatos(`, `'/api/relatorios/mudancas-situacao/'`, sem `'dias'`/`'imovel'`, sem `LogInterceptor` em `lib`).

## Known Stubs

None.

## Threat Flags

None - sem nova superfície além da já coberta pelo threat_model (T-12-14: só o Dio autenticado e teste confere `Authorization` em todo pedido; T-12-15: o repositório devolve só tipos; T-12-16: nenhum método lança, coberto por teste).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Camada de dados completa; o 12-07 (Cubits/apresentação) pode consumir os 4 use cases já registrados no DI, com `SessaoExpiradaException` e `SemPermissaoException` tipadas e a `Failure` genérica para texto fixo (D-23).

## Self-Check: PASSED

- Arquivos criados existem: `area_gestor_datasource.dart`, `area_gestor_remote_datasource.dart`, `area_gestor_repository_impl.dart`, os 2 testes.
- Commits `4c39d32`, `93df76d`, `b01704f`, `f7aef88` presentes no histórico (`commits: 4` medido por `rev-list`).

---
*Phase: 12-area-do-gestor-acompanhamento-dos-corretores*
*Completed: 2026-11-25*
