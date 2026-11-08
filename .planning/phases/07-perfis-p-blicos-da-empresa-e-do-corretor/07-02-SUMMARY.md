---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 02
subsystem: ui
tags: [flutter, cubit, freezed, injectable, perfis, tracer]

requires:
  - phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
    provides: "PerfilCorretor, PerfilRepository.buscarCorretor, PerfilCorretorModel, PerfilMockDataSource, corretoresPerfisFixture (plano 07-01)"
provides:
  - "ObterPerfilCorretorUseCase (@injectable)"
  - "PerfilState<T> freezed (carregando / carregado / erro), reutilizavel pela empresa"
  - "PerfilCorretorCubit com carregar(id)"
  - "abrirPerfilCorretor + PerfilCorretorScreen (previa na hora, CRECI buscado por id)"
  - "caminho tracer: cartao do corretor no detalhe -> perfil -> use case -> repositorio -> DataSource mock -> Model"
affects: [07-03, 07-04, 07-05, 07-06, 07-11]

actuals:
  tokens: 24000
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Cubit de perfil resolvido no DI so dentro de abrirPerfilCorretor (unico getIt<> em perfis/)"
    - "Re-export em detalhe_imovel/perfil_corretor_screen.dart para o detalhe nao ser editado"
    - "Previa do detalhe + spinner, avatar e nome na mesma posicao em carregando e carregado"

key-files:
  created:
    - lib/domain/usecases/obter_perfil_corretor_usecase.dart
    - lib/presentation/perfis/perfil_state.dart
    - lib/presentation/perfis/perfil_state.freezed.dart
    - lib/presentation/perfis/perfil_corretor_cubit.dart
    - lib/presentation/perfis/perfil_corretor_screen.dart
    - test/di/injection_perfis_test.dart
  modified:
    - lib/presentation/detalhe_imovel/perfil_corretor_screen.dart
    - lib/di/injection.config.dart
    - test/presentation/perfil_corretor_screen_test.dart
    - test/presentation/detalhe_navegacao_test.dart
    - test/presentation/detalhe_imovel_screen_test.dart

key-decisions:
  - "PerfilCorretorCubit nao guarda o id em campo: nada o le ainda (o retry chega na 07-04) e um campo so escrito acusaria unused_field no analyzer."
  - "O estado PerfilState<T> nasce generico para o perfil da empresa reutilizar a mesma forma."

patterns-established:
  - "abrirPerfilCorretor(context, previa, {criarPerfilCubit, construirImagemDeRede}): unico ponto de DI do perfil"
  - "Teste do detalhe registra no getIt uma fabrica de MockCubit parado em carregando"

requirements-completed: [PERF-06, PERF-02, PERF-04]

coverage:
  - id: D1
    description: "Tocar no cartao do corretor abre o perfil com a previa (foto + nome) e spinner na hora"
    requirement: "PERF-06"
    verification:
      - kind: e2e
        ref: "test/presentation/detalhe_navegacao_test.dart#fluxo completo vitrine -> detalhe 42 -> perfil da Marina Lopes"
        status: pass
      - kind: unit
        ref: "test/presentation/perfil_corretor_screen_test.dart#carregando mostra a previa"
        status: pass
    human_judgment: false
  - id: D2
    description: "Perfil carregado mostra nome e 'CRECI <numero>' buscados por id, sem avatar/nome mudarem de lugar"
    requirement: "PERF-02"
    verification:
      - kind: e2e
        ref: "test/presentation/detalhe_navegacao_test.dart#fluxo completo vitrine -> detalhe 42 -> perfil da Marina Lopes"
        status: pass
      - kind: unit
        ref: "test/presentation/perfil_corretor_screen_test.dart#o nome fica no mesmo lugar em carregando e carregado"
        status: pass
    human_judgment: false
  - id: D3
    description: "O app de verdade (DI real, sem fabrica de teste) abre o perfil servido pelo mock dos perfis"
    requirement: "PERF-04"
    verification:
      - kind: integration
        ref: "test/presentation/detalhe_navegacao_test.dart#DI real abrirPerfilCorretor sem fabrica de teste"
        status: pass
      - kind: unit
        ref: "test/di/injection_perfis_test.dart#a PerfilDataSource ativa e a PerfilMockDataSource"
        status: pass
    human_judgment: false

duration: 30min
completed: 2026-11-08
status: complete
plan_head_before: c7276fd4cced2dfa2e8aa6a1fe0ae997c5ffce49
plan_head_after: b191a2c8f1a6ba9ae29c07cb19d6b750327a4f9e
---

# Phase 7 Plan 02: Tracer do perfil do corretor Summary

**Perfil publico do corretor ponta a ponta: cartao do detalhe -> abrirPerfilCorretor -> PerfilCorretorCubit -> use case -> repositorio -> PerfilMockDataSource -> PerfilCorretorModel, com previa na hora e 'CRECI <numero>' buscado por id.**

## Performance

- **Duration:** ~30 min
- **Tasks:** 2 (1 tracer + 1 auto/tdd)
- **Files modified:** 11 (6 criados, 5 alterados)

## Accomplishments
- Tocar no corretor da pagina do imovel abre `PerfilCorretorScreen` por `Navigator.push` e mostra na hora foto + nome da previa com spinner; quando o perfil chega aparece 'CRECI 12345-F' sem o avatar/nome mudarem de lugar.
- `PerfilState<T>` generico, `PerfilCorretorCubit` e `ObterPerfilCorretorUseCase` registrados no DI (`injection.config.dart` regenerado).
- `detalhe_imovel_screen.dart` e `widgets/cartao_corretor.dart` nao foram editados; `detalhe_imovel/perfil_corretor_screen.dart` virou re-export de uma linha.
- Canario de DI + teste 'DI real' provam o mesmo caminho pelo DI de producao, com `PerfilMockDataSource` ativa. Tracer verificado de ponta a ponta (suite completa: 601 testes, `flutter analyze` sem problemas).

## Task Commits

1. **Task 1: Tracer cartao do corretor -> perfil** - `4210a36` (feat)
2. **Task 2: Mesmo caminho pelo DI de producao** - `b191a2c` (test)

**Plan metadata:** commit docs(07-02) seguinte a este arquivo.

## Files Created/Modified
- `lib/domain/usecases/obter_perfil_corretor_usecase.dart` - delega ao `PerfilRepository`
- `lib/presentation/perfis/perfil_state.dart` (+ `.freezed.dart`) - uniao `PerfilState<T>`
- `lib/presentation/perfis/perfil_corretor_cubit.dart` - `carregar(int id)`
- `lib/presentation/perfis/perfil_corretor_screen.dart` - `abrirPerfilCorretor`, `PerfilCorretorScreen`, `_CabecalhoCorretor`
- `lib/presentation/detalhe_imovel/perfil_corretor_screen.dart` - re-export
- `lib/di/injection.config.dart` - regenerado (use case e Cubit)
- `test/presentation/perfil_corretor_screen_test.dart` - reescrito com `MockCubit`
- `test/presentation/detalhe_navegacao_test.dart` - e2e com pilha real do perfil + 'DI real'
- `test/presentation/detalhe_imovel_screen_test.dart` - fabrica de Cubit de perfil parado
- `test/di/injection_perfis_test.dart` - canario do DI dos perfis

## Decisions Made
- `PerfilCorretorCubit` nao guarda o id (ver key-decisions): o retry entra na 07-04, quando o campo passar a ser lido.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug evitado] Cubit sem campo `_id`**
- **Found during:** Task 1
- **Issue:** o plano manda "guarda o id", mas nenhum codigo le o campo ainda; um campo privado so escrito gera `unused_field` e quebraria o gate `flutter analyze`.
- **Fix:** `carregar(int id)` apenas busca; o campo volta quando o retry (07-04) o ler.
- **Files modified:** lib/presentation/perfis/perfil_corretor_cubit.dart
- **Committed in:** 4210a36

**2. [Rule 3 - Blocking] Gate de verificacao com `git diff --exit-code ba77b1e` recusado pelo sandbox do worktree**
- **Found during:** Task 1 (verificacao)
- **Fix:** equivalente com `git diff --stat ba77b1e HEAD -- <arquivos>` e `git diff --stat HEAD -- <arquivos>`: sem nenhuma diferenca em detalhe_imovel_screen.dart, cartao_corretor.dart, pubspec.yaml e pubspec.lock.

---

**Total deviations:** 2 (1 lint-driven, 1 verificacao equivalente)
**Impact on plan:** nenhum desvio de escopo.

## Issues Encountered
- `build_runner` regravou arquivos gerados nao relacionados so com diferenca de fim de linha (CRLF); foram restaurados com `git checkout -- <arquivo>` e apenas `injection.config.dart` e `perfil_state.freezed.dart` foram versionados.
- O teste "o nome fica no mesmo lugar" precisou desmontar o app (`pumpWidget(SizedBox.shrink())`) antes de reabrir o perfil, senao a rota anterior permanecia empilhada.

## Known Stubs
None. O corpo do perfil ainda mostra so nome e CRECI por desenho do tracer; contato, empresa e imoveis chegam nas 07-03 a 07-06.

## Threat Flags
None. T-07-03 mitigado: `getIt<` aparece uma unica vez em `perfis/` (dentro de `abrirPerfilCorretor`) e o re-export nao resolve servicos. Nenhum pacote novo (pubspec inalterado).

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- A forma `PerfilState<T>` e o canario `test/di/injection_perfis_test.dart` estao prontos para as proximas fatias (contato, 404, vitrine do anunciante, empresa).
- Ponto quente de merge: `lib/di/injection.config.dart` (resolver regenerando com build_runner).

## Self-Check: PASSED

---
*Phase: 07-perfis-p-blicos-da-empresa-e-do-corretor*
*Completed: 2026-11-08*
