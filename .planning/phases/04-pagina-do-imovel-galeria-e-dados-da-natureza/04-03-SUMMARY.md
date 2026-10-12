---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
plan: 03
subsystem: ui
tags: [flutter, cubit, freezed, dio, error-handling, tdd]

requires:
  - phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
    provides: "ImovelNaoEncontradoException, ImovelDetalheRepositoryImpl, DetalheImovelCubit/State/Screen e o mock do detalhe (plano 04-01)"
provides:
  - "Repositório do detalhe que traduz DioException 404 em ImovelNaoEncontradoException e TypeError em FormatException"
  - "Estado DetalheNaoEncontrado (404) separado de DetalheErro, com mensagem própria e 'Voltar à vitrine'"
  - "Testes de repositório (incl. cadeia Dio real com adaptador falso), de modelo, de Cubit e de tela"
affects: [04-04, 04-05, 04-06, 04-07, 04-08, fase-05-api-real]

actuals:
  tokens: 17000
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Camada de dados devolve só Result tipado; o Cubit decide pelo tipo da exceção de domínio, nunca por mensagem ou status HTTP"
    - "DataSource remota só deixa a DioException subir; o repositório traduz (Fase 5 troca a DataSource sem tocar acima)"

key-files:
  created:
    - test/data/imovel_detalhe_repository_impl_test.dart
    - test/data/detalhe_imovel_model_test.dart
    - test/presentation/detalhe_imovel_cubit_test.dart
    - test/presentation/detalhe_imovel_screen_test.dart
  modified:
    - lib/data/repositories/imovel_detalhe_repository_impl.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_state.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_state.freezed.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart

key-decisions:
  - "404 detectado só em data/ (DioException.response.statusCode == 404); presentation vê apenas ImovelNaoEncontradoException"
  - "No 404 o cabeçalho da prévia (título e preço) não é renderizado: o imóvel saiu do ar"
  - "TypeError (Error, não Exception) do fromJson é capturado no repositório e vira FormatException"

patterns-established:
  - "Catch em ordem no repositório: domínio, DioException (404 vs outro), TypeError, Exception"
  - "Teste de cadeia real: Dio + HttpClientAdapter falso + DataSource de teste chamando dio.get e fromJson"

requirements-completed: [DET-06]

plan_head_before: 4d1d6d59a3fa4db915400a3ab819889d57f91a0f
duration: 15min
completed: 2026-10-12
status: complete

coverage:
  - id: D1
    description: "Falhas da DataSource saem do repositório como Result.failure tipado: 404 (mock ou DioException) vira ImovelNaoEncontradoException; 500/timeout seguem como DioException; TypeError e finalidade desconhecida viram FormatException"
    requirement: DET-06
    verification:
      - kind: unit
        ref: "test/data/imovel_detalhe_repository_impl_test.dart#buscarDetalhe"
        status: pass
      - kind: integration
        ref: "test/data/imovel_detalhe_repository_impl_test.dart#cadeia Dio real com adaptador falso (A5)"
        status: pass
      - kind: unit
        ref: "test/data/detalhe_imovel_model_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Cubit emite naoEncontrado só para ImovelNaoEncontradoException e erro para as demais falhas; retry e fechamento antes da resposta são seguros"
    requirement: DET-06
    verification:
      - kind: unit
        ref: "test/presentation/detalhe_imovel_cubit_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Tela mostra 'Este imóvel não está mais disponível' com 'Voltar à vitrine' (sem prévia nem 'Tentar de novo') no 404 e 'Não foi possível carregar este imóvel.' com 'Tentar de novo' nas demais falhas"
    requirement: DET-06
    verification:
      - kind: automated_ui
        ref: "test/presentation/detalhe_imovel_screen_test.dart"
        status: pass
    human_judgment: true
    rationale: "Adequação visual e do texto do estado de 404 depende de julgamento humano em dispositivo; o comportamento está coberto por teste de widget"
---

# Phase 4 Plan 03: Erros do detalhe (404 vs falha) Summary

**Repositório do detalhe traduz DioException 404 em ImovelNaoEncontradoException e TypeError em FormatException, e a página do imóvel mostra um estado `naoEncontrado` próprio com 'Voltar à vitrine', mantendo 'Tentar de novo' para as demais falhas**

## Performance

- **Duration:** ~15 min
- **Completed:** 2026-10-12
- **Tasks:** 2 (ambas TDD)
- **Files modified:** 9 (4 novos de teste, 5 de produção, incluindo o `.freezed.dart` regenerado)

## Accomplishments

- A camada de dados nunca deixa uma exceção escapar do `Result`: 404 vira `ImovelNaoEncontradoException`, JSON malformado vira `FormatException`, o resto segue como falha tipada. A Fase 5 só troca a DataSource.
- A suposição A5 (dio lança `DioException` em 404) ficou provada por um teste que roda um `Dio` real sobre um `HttpClientAdapter` falso até o repositório.
- A página distingue 404 (mensagem própria, sem prévia de preço, 'Voltar à vitrine') de qualquer outra falha ('Tentar de novo'), decidido apenas pelo tipo de domínio no Cubit.

## Task Commits

1. **Task 1: Erros tipados na camada de dados**
   - RED `5d7d4da` (test) — 4 testes alvo falham por assertiva
   - GREEN `24f0d3e` (feat)
2. **Task 2: 404 com estado e mensagem próprios**
   - RED `daf0c53` (test) — variante de estado declarada com placeholder vazio na tela; 2 testes alvo falham por assertiva
   - GREEN `b6743b9` (feat)

**Plan metadata:** commit docs(04-03) separado (SUMMARY) e outro para STATE/ROADMAP.

## Files Created/Modified

- `lib/data/repositories/imovel_detalhe_repository_impl.dart` — cadeia de catch: domínio, `DioException` (404 vs outro), `TypeError`, `Exception`
- `lib/presentation/detalhe_imovel/detalhe_imovel_state.dart` (+ `.freezed.dart`) — variante `naoEncontrado()` = `DetalheNaoEncontrado`
- `lib/presentation/detalhe_imovel/detalhe_imovel_cubit.dart` — `Failure(:final erro)` separado por `is ImovelNaoEncontradoException`
- `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart` — cabeçalho escondido no 404; `_CorpoNaoEncontrado` com ícone, mensagem e `FilledButton` 'Voltar à vitrine'
- `test/data/imovel_detalhe_repository_impl_test.dart`, `test/data/detalhe_imovel_model_test.dart`, `test/presentation/detalhe_imovel_cubit_test.dart`, `test/presentation/detalhe_imovel_screen_test.dart` — novos

## Decisions Made

- 404 é reconhecido só em `data/`; `presentation/` nunca lê mensagem nem status HTTP (T-04-03-03).
- A prévia (título e preço) não é renderizada no 404, pois o imóvel não é mais público (T-04-03-02).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Placeholder de tela no commit RED da Task 2**
- **Found during:** Task 2 (RED)
- **Issue:** O `switch` exaustivo da tela não compila depois de declarar a variante `naoEncontrado`, e testes que não compilam são RED inválido (não falham por assertiva).
- **Fix:** O commit RED inclui a variante de estado (+ regeneração freezed) e um caso `DetalheNaoEncontrado` provisório (`SizedBox.shrink`) na tela; os testes alvo então falham por assertiva do comportamento planejado. O GREEN substitui o placeholder.
- **Files modified:** `detalhe_imovel_state.dart`, `detalhe_imovel_state.freezed.dart`, `detalhe_imovel_screen.dart`
- **Committed in:** `daf0c53`

**2. [Rule 1 - Bug de teste] Viewport padrão (800x600) escondia 'Tentar de novo'**
- **Found during:** Task 2 (RED)
- **Fix:** o harness da tela usa viewport 400x1200 (mesmo padrão de `vitrine_screen_test.dart`).
- **Committed in:** `daf0c53`

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 de teste)
**Impact on plan:** Nenhum desvio de escopo; só garantem RED válido e testes estáveis.

## Issues Encountered

- Um `dart format test/presentation` acidental reformatou outros testes; foram revertidos com `git checkout --` nos arquivos afetados antes do commit (nenhuma mudança alheia foi commitada).
- A verificação `gsd_run check tdd-red-evidence` não foi executada (registro de evidência não persistido); o RED foi conferido manualmente: os testes alvo falharam por assertiva do comportamento (saída em Expected/Actual), sem erro de compilação ou zero testes.

## Known Stubs

Nenhum. O `SizedBox.shrink` provisório do commit RED foi substituído no GREEN.

## Threat Flags

Nenhum — nenhuma superfície nova além do modelo de ameaças do plano (T-04-03-01..03 mitigados e testados).

## TDD Gate Compliance

RED (`test(04-03)`) precede GREEN (`feat(04-03)`) nas duas tasks. Sem commit de refactor (não houve limpeza necessária).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Estados do detalhe são carregando, carregado, erro e naoEncontrado; os próximos planos (galeria, dados, natureza) estendem o caso `DetalheCarregado` sem mexer no tratamento de erro.
- `flutter analyze` limpo e `flutter test` com 421 testes passando.

## Self-Check: PASSED

---
*Phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza*
*Completed: 2026-10-12*
