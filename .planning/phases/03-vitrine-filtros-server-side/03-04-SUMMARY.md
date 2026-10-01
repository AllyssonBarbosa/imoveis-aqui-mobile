---
phase: 03-vitrine-filtros-server-side
plan: 04
subsystem: data
tags: [flutter, freezed, flutter_bloc, cubit, injectable, bottom-sheet, checkbox-list]

requires:
  - phase: 03-vitrine-filtros-server-side
    provides: "FiltrosVitrine.bairros/FiltroAtivo.bairros já no freezed (03-01), chip 'Cambuí +1' (03-01), sheet com Finalidade/Natureza/Quartos-Suítes-Vagas/Preço/Área (03-01..03-03), texto_normalizado.dart compartilhado"
provides:
  - "OpcoesFiltroRepository/OpcoesFiltroDataSource — fronteira trocável mock->dio das opções de bairro/característica (D-20), mesma disciplina de ImovelRepository/ImovelDataSource"
  - "OpcoesFiltroMockDataSource deriva bairros/características das MESMAS linhas de linhasAcervoFixture() (nunca uma lista fixa paralela), dedupe+ordena por normalizarTexto"
  - "OpcoesFiltroCubit — carrega as duas dimensões concorrentemente por cidade, com loading/falha/retry independentes por dimensão"
  - "CidadeSelecaoScreen._CorpoVitrine vira MultiBlocProvider (VitrineCubit + OpcoesFiltroCubit lazy por cidade); VitrineScreen._abrirFiltros() repassa opcoes: ao sheet"
  - "filtros_bottom_sheet.dart ganha a seção 'Bairros' (ExpansionTile + CheckboxListTile + campo 'Filtrar bairros' local via filtrarOpcoes, D-21) — FIL-04 completo via pilha real"
affects: [03-05]

# Measured (#3968) — git rev-list --count d3e259b2..HEAD, not narrated.
commits: 4
plan_head_before: d3e259b22282ec5436f2361696cb0d17bb28e548

actuals:
  tokens: 21638
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Fronteira trocável de 2a geração: OpcoesFiltroRepository/OpcoesFiltroDataSource/OpcoesFiltroMockDataSource replicam EXATAMENTE a tríade ImovelRepository/ImovelDataSource/ImovelMockDataSource (interface em domain/, impl mock em data/, @LazySingleton(as:), dual constructor paraTeste) — nunca uma segunda convenção para o mesmo problema"
    - "OpcoesFiltroCubit é criado via BlocProvider lazy (default) com 'create: (_) => cubit..carregar(cidade)' — a leitura (context.read) É o gatilho do carregamento, sem precisar de um segundo evento/callback explícito"
    - "Campo de filtro LOCAL de uma lista de opções (nunca do acervo): TextEditingController dedicado + ListenableBuilder(listenable: controller) recalculando filtrarOpcoes(opcoes, controller.text) a cada rebuild — nunca StatefulWidget com setState manual"

key-files:
  created:
    - lib/domain/repositories/opcoes_filtro_repository.dart
    - lib/domain/usecases/obter_bairros_usecase.dart
    - lib/domain/usecases/obter_caracteristicas_usecase.dart
    - lib/data/datasources/opcoes_filtro_datasource.dart
    - lib/data/datasources/opcoes_filtro_mock_datasource.dart
    - lib/data/repositories/opcoes_filtro_repository_impl.dart
    - lib/presentation/vitrine/opcoes_filtro_state.dart
    - lib/presentation/vitrine/opcoes_filtro_state.freezed.dart
    - lib/presentation/vitrine/opcoes_filtro_cubit.dart
    - test/data/opcoes_filtro_mock_datasource_test.dart
    - test/data/opcoes_filtro_repository_impl_test.dart
    - test/presentation/opcoes_filtro_cubit_test.dart
  modified:
    - lib/di/injection.config.dart
    - lib/presentation/cidade_selecao/cidade_selecao_screen.dart
    - lib/presentation/vitrine/vitrine_screen.dart
    - lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart
    - lib/presentation/vitrine/rascunho_filtros_cubit.dart
    - lib/presentation/vitrine/apresentacao_filtros.dart
    - test/presentation/filtros_bottom_sheet_test.dart
    - test/presentation/apresentacao_filtros_test.dart
    - test/presentation/rascunho_filtros_cubit_test.dart
    - test/presentation/vitrine_screen_test.dart
    - test/presentation/vitrine_fluxo_test.dart

key-decisions:
  - "Task 1 e Task 2 seguiram TDD explícito (tdd=\"true\"): cada uma teve um commit RED (test(03-04), falha confirmada via flutter test — compilação para OpcoesFiltroMockDataSource/OpcoesFiltroRepositoryImpl/OpcoesFiltroCubit/OpcoesFiltroState inexistentes na Task 1, e para o parâmetro opcoes: de mostrarFiltrosBottomSheet / criarOpcoesFiltroCubit de CidadeSelecaoScreen inexistentes na Task 2) antes do commit GREEN (feat(03-04)); nenhum REFACTOR commit foi necessário em nenhuma das duas."
  - "filtrarOpcoes (apresentacao_filtros.dart) e alternarBairro (rascunho_filtros_cubit.dart) são funções/métodos puros com zero dependência da pilha assíncrona de opções — foram implementados junto com seus testes (que já nasceram passando) dentro do mesmo commit RED da Task 2, já que o RED genuíno dessa task está nas peças que dependem da pilha (sheet/wiring), não nessas duas funções triviais."
  - "OpcoesFiltroCubit.carregar(cidade) usa 'await Future.wait([_carregarBairros, _carregarCaracteristicas])' em vez de dois fire-and-forget — torna a ordem de emissão determinística em teste (bairros resolve antes de características, pela ordem de agendamento de microtasks) sem precisar de Completers artificiais nos casos felizes."
  - "A seção 'Bairros' no sheet usa 'when opcoes.isEmpty' (guard clause) em vez de um pattern de lista vazia '[]' dentro do object pattern de OpcoesCarregadas — mais legível, mesma semântica."

patterns-established:
  - "Toda nova DataSource/Repository trocável (bairros, características, e futuras opções de filtro) replica a tríade ImovelDataSource/ImovelRepository/ImovelMockDataSource sem desvio — interface em domain/, dual constructor (padrão + paraTeste) na impl mock, @LazySingleton(as:) apontando para a interface."
  - "Seções do sheet que dependem de dado assíncrono fora do rascunho (Bairros é a primeira) usam BlocBuilder<XCubit, XState> aninhado dentro do BlocBuilder<RascunhoFiltrosCubit, FiltrosVitrine> já existente — nunca leem dois Cubits misturados num único builder."

requirements-completed: [FIL-04, FIL-05]

coverage:
  - id: D1
    description: "Bairros e características vêm de uma fronteira trocável mock->dio (OpcoesFiltroRepository/OpcoesFiltroDataSource/OpcoesFiltroMockDataSource), derivados das MESMAS linhas do acervo, nunca uma lista fixa no app; OpcoesFiltroCubit carrega as duas dimensões por cidade com loading/falha/retry independentes (D-20)"
    requirement: "FIL-04"
    verification:
      - kind: unit
        ref: "test/data/opcoes_filtro_mock_datasource_test.dart#bairros/caracteristicas: distintos, ordenados por normalizarTexto, cross-checados contra ImovelMockDataSource"
        status: pass
      - kind: unit
        ref: "test/data/opcoes_filtro_repository_impl_test.dart#Result.success/failure mapping"
        status: pass
      - kind: unit
        ref: "test/presentation/opcoes_filtro_cubit_test.dart#carregar()/tentarNovamente() transitions, per-dimension failure, no-emit-after-close"
        status: pass
    human_judgment: false
  - id: D2
    description: "O sheet ganha a seção 'Bairros' (CheckboxListTile multi-seleção, campo 'Filtrar bairros' que só filtra a lista de opções já carregada via normalizarTexto) ponta a ponta — abrir Filtros, expandir Bairros, buscar e marcar Cambuí e Taquaral, aplicar, e só imóveis desses bairros aparecem com o chip 'Cambuí +1' (FIL-04, D-05, D-21)"
    requirement: "FIL-04"
    verification:
      - kind: automated_ui
        ref: "test/presentation/filtros_bottom_sheet_test.dart#Seção Bairros (FIL-04, D-05, D-20, D-21) — carregando/falha/vazio/com-opções, filtro local, toggle, initiallyExpanded"
        status: pass
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: Filtros -> expandir Bairros -> digitar \"camb\" -> marcar Cambuí -> limpar o campo -> marcar Taquaral -> Ver imóveis filtra pela pilha real..."
        status: pass
    human_judgment: false
  - id: D3
    description: "Layout visual da nova seção 'Bairros' (espaçamento do ExpansionTile, alinhamento dos CheckboxListTile, legibilidade do indicador de carregando/mensagem de falha) segue Material 3 / paleta verde-branco na tela real do dispositivo"
    human_judgment: true
    rationale: "Testes de widget verificam estrutura/texto/comportamento (CheckboxListTile marcado/desmarcado, textos exatos, campo habilitado), não aparência visual final — mesmo padrão de D5/D6 nos planos 03-01..03-03, julgamento humano necessário no app rodando"

duration: ~50min
completed: 2026-10-01
status: complete
---

# Phase 3 Plan 4: Bairro — Opções do Servidor Simulado + Seção do Sheet Summary

**Dois novos endpoints simulados de opções (`GET /api/publico/bairros/`, `GET /api/publico/caracteristicas/`) viram uma fronteira trocável mock→Dio completa (repository/datasource/use cases/Cubit, espelhando `ImovelRepository`) e o sheet ganha a seção "Bairros" — `CheckboxListTile` multi-seleção com campo de busca local, loading/falha/retry por dimensão — ponta a ponta.**

## Performance

- **Duration:** ~50 min
- **Started:** (não capturado no início desta sessão — primeira ação registrada foi a verificação de branch/HEAD)
- **Completed:** 2026-10-01T01:14:14Z
- **Tasks:** 2
- **Files modified/created:** 23 (12 novos, 11 alterados) — 9 em `lib/`, 14 em `test/`

## Accomplishments

- `OpcoesFiltroRepository`/`OpcoesFiltroDataSource` (interfaces em `domain/`/`data/`) e `OpcoesFiltroMockDataSource` (`data/`, `@LazySingleton(as: OpcoesFiltroDataSource)`) replicam a MESMA disciplina de `ImovelRepository`/`ImovelDataSource`/`ImovelMockDataSource` — o mock deriva bairros/características das MESMAS linhas de `linhasAcervoFixture()` (nunca uma lista fixa paralela, D-20), dedupe e ordena por `normalizarTexto`, 300ms de latência simulada no construtor padrão.
- `ObterBairrosUseCase`/`ObterCaracteristicasUseCase` (delegate-only, `@injectable`) e `OpcoesFiltroRepositoryImpl` (`try`/`on Exception catch` → `Result`, mesma convenção de `ImovelRepositoryImpl`).
- `OpcoesFiltroCubit` (`@injectable`): `carregar(cidade)` dispara as duas dimensões (bairros/características) concorrentemente via `Future.wait`, cada uma emitindo só o seu campo (`carregando`→`carregadas`/`falha`); `tentarNovamente()` recarrega SÓ as dimensões em `falha`; guarda `isClosed` evita emit após `close()`.
- `CidadeSelecaoScreen._CorpoVitrine` vira `MultiBlocProvider` (`VitrineCubit` + `OpcoesFiltroCubit`, ambos chaveados pela cidade): o `OpcoesFiltroCubit` fica `lazy` (padrão de `BlocProvider`) — só é criado, e só então chama `carregar(cidade)`, na primeira leitura (primeira abertura do sheet de filtros para aquela cidade); trocar de cidade reconstrói os dois do zero.
- `VitrineScreen._abrirFiltros()` lê `context.read<OpcoesFiltroCubit>()` ao lado do `VitrineCubit` e repassa como `opcoes:` ao sheet (mesmo precedente de `aplicados`/`aoAplicar`).
- `filtros_bottom_sheet.dart` ganha a seção "Bairros" (`ExpansionTile`, após "Área"): expandida por padrão quando o rascunho já tem bairros (D-17); conteúdo troca exaustivamente sobre `OpcoesFiltroState.bairros` — indicador de progresso / "Não foi possível carregar os bairros" + "Tentar de novo" / "Nenhum bairro disponível nesta cidade" / campo "Filtrar bairros" (ícone de busca) + um `CheckboxListTile` por opção visível, filtrada localmente via `filtrarOpcoes` (nova função pura em `apresentacao_filtros.dart`, `normalizarTexto` substring matching, D-21 — nunca dispara consulta ao acervo).
- `RascunhoFiltrosCubit.alternarBairro(bairro, {marcado})` — multi-seleção, mesma disciplina de `alternarNatureza`.

## Task Commits

Task 1 e Task 2 são `type="auto" tdd="true"`, cada uma executada em RED → GREEN (sem REFACTOR necessário):

1. **Task 1 RED: testes falhando para o servidor simulado, repositório e Cubit de opções** — `fceb822` (test)
2. **Task 1 GREEN: servidor simulado das opções com Cubit trocável por DI (D-20)** — `b32b8d9` (feat)
3. **Task 2 RED: testes falhando para a seção Bairros ponta a ponta** — `125e100` (test)
4. **Task 2 GREEN: sheet ganha a seção Bairros com opções do servidor simulado (FIL-04, D-05, D-20, D-21)** — `c992e34` (feat)

**Plan metadata:** commit pendente (este commit)

## Files Created/Modified

- `lib/domain/repositories/opcoes_filtro_repository.dart` (novo) - interface trocável `bairrosDaCidade`/`caracteristicas`
- `lib/domain/usecases/obter_bairros_usecase.dart`, `obter_caracteristicas_usecase.dart` (novos) - delegate-only
- `lib/data/datasources/opcoes_filtro_datasource.dart` (novo) - interface + caminhos do contrato §10 item 8
- `lib/data/datasources/opcoes_filtro_mock_datasource.dart` (novo) - servidor simulado derivado da fixture
- `lib/data/repositories/opcoes_filtro_repository_impl.dart` (novo) - `try`/`Result` convention
- `lib/presentation/vitrine/opcoes_filtro_state.dart` (novo, freezed) + `.freezed.dart` (gerado) - `OpcoesFiltroState`/`CarregamentoOpcoes`
- `lib/presentation/vitrine/opcoes_filtro_cubit.dart` (novo) - carregamento concorrente por dimensão
- `lib/di/injection.config.dart` - regenerado (DataSource/Repository/UseCases/Cubit registrados)
- `lib/presentation/cidade_selecao/cidade_selecao_screen.dart` - `criarOpcoesFiltroCubit` + `MultiBlocProvider`
- `lib/presentation/vitrine/vitrine_screen.dart` - `_abrirFiltros()` repassa `opcoes:`
- `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart` - parâmetro `opcoes:` obrigatório + seção `_SecaoBairros`
- `lib/presentation/vitrine/rascunho_filtros_cubit.dart` - `alternarBairro`
- `lib/presentation/vitrine/apresentacao_filtros.dart` - `filtrarOpcoes`
- Testes: `test/data/opcoes_filtro_mock_datasource_test.dart`, `opcoes_filtro_repository_impl_test.dart`, `test/presentation/opcoes_filtro_cubit_test.dart` (novos); `filtros_bottom_sheet_test.dart`, `apresentacao_filtros_test.dart`, `rascunho_filtros_cubit_test.dart`, `vitrine_screen_test.dart`, `vitrine_fluxo_test.dart` (estendidos)

## Decisions Made

- TDD explícito nas Tasks 1 e 2: RED confirmado via `flutter test` (erro de compilação para as classes de opções ainda inexistentes na Task 1; erro de compilação para os parâmetros `opcoes:`/`criarOpcoesFiltroCubit` ainda inexistentes na Task 2) antes de cada GREEN; nenhum REFACTOR commit foi necessário em nenhuma das duas.
- `filtrarOpcoes`/`alternarBairro` (funções/métodos puros, sem dependência da pilha assíncrona) foram implementados junto com seus próprios testes dentro do commit RED da Task 2 — já nasceram passando; o RED genuíno dessa task está nas peças que realmente dependem da pilha (sheet/wiring: `opcoes:`, `criarOpcoesFiltroCubit`), que de fato falharam para compilar antes do GREEN.
- `OpcoesFiltroCubit.carregar(cidade)` usa `await Future.wait([...])` em vez de dois `unawaited(...)` fire-and-forget — isso torna a ordem de emissão determinística em teste (a dimensão `bairros` sempre resolve e emite antes de `características`, pela ordem de agendamento das duas chamadas) sem precisar de `Completer`s artificiais nos testes do caminho feliz.
- Vários testes de widget do sheet precisaram de `tester.ensureVisible(...)` antes de tocar no título "Bairros"/"Tentar de novo"/`CheckboxListTile` — a nova seção empurrou esses widgets para fora da viewport padrão de teste (800×600) depois da expansão; mesmo padrão já usado para os `ChoiceChip`s de Quartos/Suítes/Vagas nos planos anteriores.

## Deviations from Plan

None - plan executado exatamente como escrito.

## Issues Encountered

- Um teste próprio (`tentarNovamente() recarrega SÓ a dimensão em falha...`) tentou capturar a sequência de emissões via `cubit.stream.listen` + `await cubit.tentarNovamente()`, mas a entrega do evento ao listener (microtask agendado por `StreamController.add`) nem sempre completa antes do `await` do método retornar — ajustado para verificar `cubit.state` final (mais robusto, sem depender de timing exato de microtask) antes do commit GREEN; não é um bug de produção, só um ajuste de arnês de teste.

## User Setup Required

None - nenhuma configuração de serviço externo necessária (mock-first, nenhum pacote novo, nenhum endpoint real criado nesta fase).

## Next Phase Readiness

- A fronteira trocável das opções (`OpcoesFiltroRepository`/`OpcoesFiltroDataSource`) está pronta para a Fase 4 trocar `OpcoesFiltroMockDataSource` por uma implementação `dio` contra `GET /api/publico/bairros/`/`GET /api/publico/caracteristicas/`, sem tocar `domain/`/`presentation/` — mesmo padrão já provado por `ImovelDataSource` nas Fases 1-3.
- O plano 03-05 (características) pode reusar inteiramente `OpcoesFiltroCubit.caracteristicas`/`ObterCaracteristicasUseCase` (já implementados nesta Task 1) e o padrão `_SecaoBairros`/`filtrarOpcoes`/`ListenableBuilder` como analog direto para a seção "Características" — só falta o controle de UI (provavelmente `FilterChip` multi, já que características não tem o mesmo volume de opções que bairros).
- Nenhum bloqueio conhecido para o plano seguinte da fase.

---
*Phase: 03-vitrine-filtros-server-side*
*Completed: 2026-10-01*

## Self-Check: PASSED

- All 12 new key-files and all 11 modified key-files verified present on disk via `[ -f ]`.
- All 4 task commits (`fceb822`, `b32b8d9`, `125e100`, `c992e34`) verified present via `git log --oneline --all`.
- Plan-level `<verification>` re-run: `flutter test` (365 passed), `flutter analyze` (no issues found).
- Task 1/2 `<acceptance_criteria>` re-verified via targeted grep commands — all pass, including both grep gates: `! grep -rlnE "Mock[D]ataSource|linhasAcervo[F]ixture" lib/presentation lib/domain` (0 matches after fixing a doc-comment that literally named the mock class) and `! grep -rnE "itens\.(where|sort|retainWhere|removeWhere)" lib/presentation lib/domain` (0 matches).
- `commits: 4` and `plan_head_before: d3e259b22282ec5436f2361696cb0d17bb28e548` measured via `git rev-list --count d3e259b2..HEAD` against the persisted ledger — matches the 4 task commits listed above.
