---
phase: 03-vitrine-filtros-server-side
plan: 05
subsystem: presentation
tags: [flutter, freezed, flutter_bloc, cubit, injectable, bottom-sheet, filter-chip, session-memory]

requires:
  - phase: 03-vitrine-filtros-server-side
    provides: "OpcoesFiltroCubit.caracteristicas (opções de característica derivadas do servidor simulado, 03-04); FiltrosVitrine.caracteristicas (E semântico, 03-02); chipsDosFiltros já cobre características (03-01)"
provides:
  - "Seção 'Características' do sheet — FilterChips vindas de OpcoesFiltroCubit.caracteristicas, E ponta a ponta (FIL-04, D-04, D-16, D-20)"
  - "SessaoFiltrosVitrine (@lazySingleton) — memória EM SESSÃO dos filtros aplicados, só em processo, nunca persistida (D-23); filtrosPara(cidade) limpa bairros ao trocar de cidade (D-14)"
  - "VitrineCubit(BuscarImoveisUseCase, SessaoFiltrosVitrine) — carregar(cidade) parte de filtrosPara(cidade); _aplicarConsulta registra lembrar(cidade, filtros) a cada reinício"
  - "Gates de fim de fase (FIL-05, D-06, D-23): grep estático confirma que presentation/domain nunca referencia o servidor simulado, nunca filtra/ordena o acervo em memória, nunca monta CSV fora de data/, e nunca persiste filtros"
affects: []

commits: 4
plan_head_before: f61886436e38c61baf94c0ab479e9f522b63a3c5

actuals:
  tokens: 11410
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Seção do sheet sempre visível (sem ExpansionTile), para dimensões com poucas opções e sem necessidade de busca local — mesmo switch exaustivo sobre CarregamentoOpcoes que a seção 'Bairros' usa, mas sem o controle de expansão/filtro: 'Características' segue o padrão simples de 'Tipo de imóvel', não o padrão completo de 'Bairros'"
    - "SessaoFiltrosVitrine como @lazySingleton separado do Cubit que o consome — sobrevive à recriação de VitrineCubit a cada troca de cidade (MultiBlocProvider chaveado por cidade.chaveNatural) porque o DI resolve a MESMA instância do singleton a cada factory de VitrineCubit"
    - "lembrar(cidade, filtros) chamado SÍNCRONO, junto com o emit de carregando — nunca após o await da consulta — garante que a memória sempre reflete a última consulta DISPARADA, mesmo que o Cubit feche ou a resposta nunca chegue"

key-files:
  created:
    - lib/presentation/vitrine/sessao_filtros_vitrine.dart
    - test/presentation/sessao_filtros_vitrine_test.dart
  modified:
    - lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart
    - lib/presentation/vitrine/rascunho_filtros_cubit.dart
    - lib/presentation/vitrine/vitrine_cubit.dart
    - lib/di/injection.config.dart
    - test/presentation/rascunho_filtros_cubit_test.dart
    - test/presentation/filtros_bottom_sheet_test.dart
    - test/presentation/vitrine_cubit_test.dart
    - test/presentation/vitrine_fluxo_test.dart

key-decisions:
  - "Task 1 e Task 2 seguiram TDD explícito (tdd=\"true\"): cada uma teve um commit RED (test(03-05), falha de compilação confirmada — alternarCaracteristica/seção 'Características' inexistentes na Task 1; SessaoFiltrosVitrine inexistente e construtor de VitrineCubit com um parâmetro a menos na Task 2) antes do commit GREEN (feat(03-05)); nenhum REFACTOR commit foi necessário em nenhuma das duas."
  - "Seção 'Características' NUNCA fica atrás de um ExpansionTile (diferente de 'Bairros') — fica sempre visível, igual a 'Tipo de imóvel', porque o comportamento do plano não pede nem campo de busca local (a lista de características é curta) nem controle de expandir/colapsar; isso também expôs que o estado 'carregando' passa a aparecer já na abertura do sheet, exigindo trocar pumpAndSettle() por pump(duration) nesses testes específicos (ver Issues Encountered)."
  - "carregar(cidade) deixou de delegar a _reiniciar() (que lê state.filtros) e passou a chamar _aplicarConsulta diretamente com SessaoFiltrosVitrine.filtrosPara(cidade) como filtro inicial — _reiniciar() continua existindo só para o caminho de retry de VitrineErro em tentarNovamente(), que de fato deve reler o estado atual, não a sessão."
  - "lembrar(cidade, filtros) entra em _aplicarConsulta ANTES do emit de carregando (síncrono, antes do await da consulta) — não depois da resposta — para que a memória sempre corresponda à ÚLTIMA consulta disparada, mesmo com o Cubit fechando ou a resposta nunca resolvendo, conforme pedido explicitamente pelo plano."
  - "test/presentation/vitrine_fluxo_test.dart: criarVitrineCubitReal fecha sobre UMA variável sessaoFiltros de escopo de teste (recriada no setUp()), replicando o padrão do @lazySingleton real do DI — garante que o novo VitrineCubit criado para Valinhos (key diferente no MultiBlocProvider) enxergue os filtros lembrados de Campinas."

patterns-established:
  - "Nova seção de filtro sem necessidade de busca/expansão replica o padrão 'Tipo de imóvel' (Wrap de FilterChip sempre visível) em vez do padrão 'Bairros' (ExpansionTile + CheckboxListTile + campo de busca) — a escolha depende só do volume/necessidade de busca da dimensão, nunca um padrão único obrigatório para 'seções com dado assíncrono'."
  - "Estado de sessão que precisa sobreviver à recriação de um Cubit filho (troca de cidade) é um @lazySingleton PRÓPRIO, injetado como dependência do Cubit — nunca um campo estático nem um Cubit pai guardando estado adicional."

requirements-completed: [FIL-04, FIL-05, FIL-06]

coverage:
  - id: D1
    description: "Seção 'Características' do sheet — FilterChips vindas do servidor simulado (OpcoesFiltroCubit.caracteristicas), com loading/falha/vazio próprios; o servidor combina as marcadas com E (D-04); chip resumido 'Piscina +1' (D-16)"
    requirement: "FIL-04"
    verification:
      - kind: unit
        ref: "test/presentation/rascunho_filtros_cubit_test.dart#alternarCaracteristica(Piscina, marcada: true/false)"
        status: pass
      - kind: automated_ui
        ref: "test/presentation/filtros_bottom_sheet_test.dart#Seção Características (FIL-04, D-04, D-16, D-20) — carregando/falha/vazio/com-opções/aplicar"
        status: pass
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: Filtros -> marcar Piscina e Churrasqueira -> Ver imóveis filtra pela pilha real (E entre as duas, D-04); chip \"Piscina +1\", botão \"Filtros (1)\""
        status: pass
    human_judgment: false
  - id: D2
    description: "SessaoFiltrosVitrine — filtros gerais sobrevivem à troca de cidade (sem o bairro, que pertence à cidade anterior), valem só durante a sessão em memória de processo, nunca persistidos (D-14, D-23)"
    requirement: "FIL-06"
    verification:
      - kind: unit
        ref: "test/presentation/sessao_filtros_vitrine_test.dart#SessaoFiltrosVitrine (D-14, D-23) — sessão nova/mesma cidade/outra cidade/sobrescrita"
        status: pass
      - kind: unit
        ref: "test/presentation/vitrine_cubit_test.dart#SessaoFiltrosVitrine integrada ao VitrineCubit (D-14, D-23)"
        status: pass
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: aplicar Venda + \"2+\" quartos + bairro Cambuí, trocar para Valinhos pelo cabeçalho -> filtros gerais sobrevivem sem o bairro..."
        status: pass
    human_judgment: false
  - id: D3
    description: "Gates estáticos de fim de fase (FIL-05, D-06): nenhuma parte de presentation/domain referencia o servidor simulado ou a fixture, filtra/ordena o acervo em memória, monta CSV fora de data/, ou persiste filtros no aparelho"
    requirement: "FIL-05"
    verification:
      - kind: other
        ref: "grep -rlnE \"Mock[D]ataSource|linhasAcervo[F]ixture\" lib/presentation lib/domain — 0 matches"
        status: pass
      - kind: other
        ref: "grep -rnE \"itens\\.(where|sort|retainWhere|removeWhere)\" lib/presentation lib/domain — 0 matches"
        status: pass
      - kind: other
        ref: "grep -nE \"\\.where\\(|\\.sort\\(\" nos 4 Cubits de vitrine — 0 matches"
        status: pass
      - kind: other
        ref: "grep -rnF \"join(',')\" lib/presentation lib/domain — 0 matches"
        status: pass
      - kind: other
        ref: "grep -rnE \"SharedPreferences|shared_preferences\" lib/presentation/vitrine — 0 matches"
        status: pass
    human_judgment: false
  - id: D4
    description: "Verificação humana de fim de fase em aparelho real: modal completo (Material 3, verde/branco, rodapé fixo, teclado numérico, máscaras), fluxo de chips, estado vazio-com-filtros (D-22), troca de cidade (D-14) e não-persistência ao reabrir o app (D-23)"
    verification: []
    human_judgment: true
    rationale: "Fidelidade visual Material 3/paleta, ergonomia do sheet em tela cheia com teclado, sensação de digitação da máscara e o layout em 360dp exigem os olhos do usuário num aparelho real — testes de widget verificam estrutura/texto/comportamento, não aparência final (mesmo padrão de D3 em 03-04). human_verify_mode=end-of-phase: este <human-check> fica embutido no <verify> da Task 2 e é colhido pelo verificador de fim de fase, não um checkpoint em tempo de execução."

duration: ~30min
completed: 2026-09-30
status: complete
---

# Phase 3 Plan 5: Características, Sessão de Filtros e Troca de Cidade Summary

**Seção "Características" do sheet (FilterChips do servidor simulado, E ponta a ponta) fecha o conjunto FIL-04, e uma `SessaoFiltrosVitrine` em memória de processo faz os filtros gerais sobreviverem à troca de cidade sem os bairros da cidade anterior — nada é persistido no aparelho.**

## Performance

- **Duration:** ~30 min
- **Started:** 2026-09-30 (sessão de execução única, worktree isolado)
- **Completed:** 2026-09-30T22:33:50-03:00
- **Tasks:** 2
- **Files modified/created:** 10 (2 novos, 8 alterados) — 4 em `lib/`, 6 em `test/`

## Accomplishments

- `RascunhoFiltrosCubit.alternarCaracteristica(String, {required bool marcada})` — multi-seleção no rascunho, mesma disciplina de `alternarBairro`/`alternarNatureza`.
- `filtros_bottom_sheet.dart` ganha a última seção "Características": SEMPRE visível (sem `ExpansionTile`, diferente de "Bairros"), switch exaustivo sobre `OpcoesFiltroState.caracteristicas` (carregando → indicador; falha → texto + "Tentar de novo"; vazio → texto; carregadas → um `FilterChip` por opção na ordem recebida, nunca reordenada ou fixa no app). O servidor simulado já combinava as marcadas com E desde 03-02; o chip resumido "Piscina +1" já existia desde 03-01.
- `SessaoFiltrosVitrine` (novo, `@lazySingleton`): `lembrar(Cidade, FiltrosVitrine)` e `filtrosPara(Cidade)` — campos privados só em memória do processo (D-23); `filtrosPara` devolve o filtro vazio para uma sessão nova, os filtros tal como lembrados para a MESMA cidade, e os mesmos filtros gerais com `bairros` limpos para OUTRA cidade (D-14).
- `VitrineCubit(BuscarImoveisUseCase, SessaoFiltrosVitrine)`: `carregar(cidade)` agora dispara a primeira consulta com `filtrosPara(cidade)` em vez do `FiltrosVitrine()` default; `_aplicarConsulta` chama `lembrar(cidade, filtros)` SÍNCRONO, junto com o emit de `carregando` — a memória sempre reflete a última consulta DISPARADA, mesmo que o Cubit feche antes da resposta.
- `lib/di/injection.config.dart` regenerado (`dart run build_runner build`): `SessaoFiltrosVitrine` registrada como `lazySingleton` e injetada em `VitrineCubit`.
- Gates estáticos de fim de fase (FIL-05, D-06, D-23) — 5 greps de verificação, todos sem matches: nenhuma referência ao servidor simulado/fixture em `presentation`/`domain`, nenhuma filtragem/ordenação do acervo em memória, nenhum CSV fora de `data/`, nenhuma persistência de filtros via `shared_preferences`.

## Task Commits

Task 1 e Task 2 são `type="auto" tdd="true"`, cada uma executada em RED → GREEN (sem REFACTOR necessário):

1. **Task 1 RED: testes falhando para a seção Características ponta a ponta** — `a024e21` (test)
2. **Task 1 GREEN: sheet ganha a seção Características com FilterChips do servidor simulado (FIL-04, D-04, D-16, D-20)** — `98c7435` (feat)
3. **Task 2 RED: testes falhando para a sessão em memória dos filtros + troca de cidade** — `4c28244` (test)
4. **Task 2 GREEN: filtros sobrevivem à troca de cidade sem os bairros, só em memória (FIL-05, FIL-06, D-14, D-23)** — `1fddde3` (feat)

**Plan metadata:** commit pendente (este commit)

## Files Created/Modified

- `lib/presentation/vitrine/sessao_filtros_vitrine.dart` (novo) — `@lazySingleton class SessaoFiltrosVitrine` com `lembrar`/`filtrosPara`
- `lib/presentation/vitrine/widgets/filtros_bottom_sheet.dart` — seção `_SecaoCaracteristicas`, sempre visível
- `lib/presentation/vitrine/rascunho_filtros_cubit.dart` — `alternarCaracteristica`
- `lib/presentation/vitrine/vitrine_cubit.dart` — segundo parâmetro `SessaoFiltrosVitrine`; `carregar`/`_aplicarConsulta` reescritos para usar `filtrosPara`/`lembrar`
- `lib/di/injection.config.dart` — regenerado (`SessaoFiltrosVitrine` registrada, injetada em `VitrineCubit`)
- Testes: `test/presentation/sessao_filtros_vitrine_test.dart` (novo); `rascunho_filtros_cubit_test.dart`, `filtros_bottom_sheet_test.dart`, `vitrine_cubit_test.dart`, `vitrine_fluxo_test.dart` (estendidos)

## Decisions Made

- TDD explícito nas Tasks 1 e 2: RED confirmado via `flutter test` (erro de compilação — método/seção inexistentes na Task 1; `SessaoFiltrosVitrine` inexistente e assinatura de `VitrineCubit` com um parâmetro a menos na Task 2) antes de cada GREEN; nenhum REFACTOR commit necessário.
- "Características" ficou SEMPRE visível (sem `ExpansionTile`), replicando o padrão simples de "Tipo de imóvel" em vez do padrão completo de "Bairros" — o comportamento do plano não pedia busca local nem controle de expandir/colapsar para esta dimensão.
- `carregar(cidade)` passou a chamar `_aplicarConsulta` diretamente com `_sessaoFiltros.filtrosPara(cidade)`, em vez de delegar a `_reiniciar()` (que lê `state.filtros`) — `_reiniciar()` continua existindo só para o retry de `VitrineErro` em `tentarNovamente()`, que deve mesmo reler o estado atual, não a sessão.
- `lembrar(cidade, filtros)` entra em `_aplicarConsulta` ANTES do emit de `carregando`, nunca depois da resposta — garante que a memória sempre corresponda à última consulta disparada, exatamente como pedido pelo plano.
- `test/presentation/vitrine_fluxo_test.dart`: `criarVitrineCubitReal` fecha sobre UMA variável `sessaoFiltros` de escopo de teste (recriada em `setUp()`), replicando o `@lazySingleton` real do DI — o `VitrineCubit` novo criado para Valinhos (nova `key` no `MultiBlocProvider`) enxerga os filtros lembrados de Campinas.

## Deviations from Plan

None - plan executado exatamente como escrito.

## Issues Encountered

- A seção "Características" ficou sempre visível (sem `ExpansionTile`), então um estado `carregando` já expõe o `CircularProgressIndicator` indeterminado logo na abertura do sheet — diferente de "Bairros" (colapsada por padrão, onde o spinner só aparece após expandir). Isso travava `pumpAndSettle()` nos testes desse grupo (timeout, animação nunca assenta); ajustado o helper `abrirSheet` LOCAL ao grupo "Seção Características" para usar `pump()` + `pump(Duration(milliseconds: 300))` em vez de `pumpAndSettle()` — não é um bug de produção, só um ajuste de arnês de teste, isolado a esse grupo (os demais grupos do arquivo continuam usando `pumpAndSettle()` sem problema).
- O e2e de troca de cidade precisou de `registerFallbackValue(campinas)` em `vitrine_fluxo_test.dart` — o mock de `CidadeSelecaoCubit.entrarDireto(any())` usa `any<Cidade>()` pela primeira vez neste arquivo, e mocktail exige um fallback registrado antes do primeiro uso de `any()`/`captureAny()` para esse tipo.

## User Setup Required

None - nenhuma configuração de serviço externo necessária (mock-first, nenhum pacote novo, nenhum endpoint real criado nesta fase).

## Next Phase Readiness

- FIL-01..FIL-06 completos: todos os filtros da vitrine (finalidade, natureza, faixa de preço, quartos/suítes/vagas, bairro, faixa de área, características) funcionam ponta a ponta contra o servidor simulado, com chips resumidos, sessão em memória e troca de cidade sem vazamento de bairro.
- A Fase 4 pode trocar `ImovelMockDataSource`/`OpcoesFiltroMockDataSource` pela implementação `dio` real (`GET /imoveis`, `GET /api/publico/bairros/`, `GET /api/publico/caracteristicas/`) sem tocar `domain/`/`presentation/` — mesmo padrão de fronteira trocável já provado nas Fases 1-3; nenhum dos dois novos Cubits/entidades desta fase (`SessaoFiltrosVitrine`, `OpcoesFiltroCubit`) depende da forma do transporte.
- **Human-check de fim de fase pendente** (embutido no `<verify>` da Task 2, `human_verify_mode: end-of-phase`): modal completo em aparelho real (Android + iOS, 360dp), fluxo de chips, estado vazio-com-filtros (D-22), troca de cidade (D-14) e não-persistência ao reabrir o app (D-23) — a colher pelo verificador de fim de fase, consolidado num `03-UAT.md`.
- Nenhum bloqueio conhecido para o fechamento da fase.

---
*Phase: 03-vitrine-filtros-server-side*
*Completed: 2026-09-30*

## Self-Check: PASSED

- All 2 new key-files and all 8 modified key-files verified present on disk via `[ -f ]`.
- All 4 task commits (`a024e21`, `98c7435`, `4c28244`, `1fddde3`) verified present via `git log --oneline --all`.
- Plan-level `<verification>` re-run: `flutter test` (382 passed, up from the 365-test baseline after 03-04), `flutter analyze` (no issues found).
- Task 1/2 `<acceptance_criteria>` re-verified via targeted grep commands — all pass:
  - `filtros_bottom_sheet.dart` contains 'Características', 'Não foi possível carregar as características', 'Nenhuma característica disponível', `alternarCaracteristica`, and no literal característica name such as 'Piscina'.
  - `rascunho_filtros_cubit.dart` contains `alternarCaracteristica`.
  - `sessao_filtros_vitrine.dart` contains `@lazySingleton`, `class SessaoFiltrosVitrine`, `lembrar`, `filtrosPara`, and clears `bairros` for a different `chaveNatural`.
  - `vitrine_cubit.dart` contains `SessaoFiltrosVitrine`, `filtrosPara(` and `lembrar(`; `injection.config.dart` registers `SessaoFiltrosVitrine` and passes it to `VitrineCubit`.
  - All 5 phase-level grep gates (FIL-05, D-06, D-23) print nothing.
- `commits: 4` and `plan_head_before: f61886436e38c61baf94c0ab479e9f522b63a3c5` measured via `git rev-list --count f61886436e38c61baf94c0ab479e9f522b63a3c5..HEAD` against the persisted ledger — matches the 4 task commits listed above.
