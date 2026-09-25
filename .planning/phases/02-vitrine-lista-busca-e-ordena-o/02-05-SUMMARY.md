---
phase: 02-vitrine-lista-busca-e-ordena-o
plan: 05
subsystem: ui
tags: [flutter, bloc_test, fake_async, mocktail, search-filter, cursor-pagination]

# Dependency graph
requires:
  - phase: 02-vitrine-lista-busca-e-ordena-o
    provides: "Plan 02-03: ImovelMockDataSource servidor simulado com paginação cursor real e hooks de busca/ordenação pass-through; VitrineCubit.carregarMais() guardado por token de versão"
provides:
  - "core/texto_normalizado.dart — normalização única de texto (acento/caixa/espaços), reusada por Cidade.chaveNatural e pela busca do mock (elimina a duplicação que o RESEARCH da fase apontou)"
  - "ImovelMockDataSource — busca palavra-a-palavra em título+bairro (descrição excluída, D-06), gatilho determinístico FalhaSimuladaDoMock no termo \"erro\" (D-15), ordenação mais_recentes/preco_asc/preco_desc/area_asc/area_desc com nulls-last em ambos os sentidos (D-11/D-12)"
  - "VitrineCubit.buscar()/limparBusca() — debounce de 400ms/2 caracteres com Timer próprio, campo vazio recarrega na hora, mesmo termo nunca redispara, close() cancela o debounce pendente (VIT-03, D-08)"
  - "VitrineCubit.ordenarPor() + _aplicarConsulta() — reinício único do topo (D-13) compartilhado por busca/ordenação/tentarNovamente, token de versão descarta qualquer resposta atrasada (inclusive um carregarMais() em voo)"
  - "SearchBar Material 3 abaixo do SeletorCidadeTopo + bottom sheet \"Ordenar por\" (RadioGroup) com botão \"Ordenar: <opção>\" e slot reservado para o filtro da Fase 3 (VIT-03, VIT-04, D-07, D-10)"
affects: ["03 (filtros da vitrine reaproveitam o mesmo Row de ações e o slot reservado; ordenação por preco_aluguel quando finalidade=ALUGUEL estende _comparadorDe)", "04 (busca/ordenação/gatilho de erro saem do mock e viram parâmetros reais de GET /imoveis, mesma semântica já provada aqui)"]

# Actuals (#2632)
actuals:
  tokens: 16679
  tasks: 3
  commits: 3
  plan_head_before: ec385cd

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "normalizarTexto (core/) como ÚNICA normalização de texto do app — Cidade.chaveNatural e a busca do mock delegam a ela, nunca duplicam a tabela de acentos"
    - "_aplicarConsulta() unifica todo reinício-do-topo (D-13): carregar()/_reiniciar(), buscar()/limparBusca() e ordenarPor() convergem nele — um único emit de carregando descartando itens/cursor, um único ponto que bumpa o token de versão"
    - "Debounce com Timer próprio no Cubit (sem easy_debounce, CLAUDE.md): cancela+reagenda a cada tecla, decide synchronamente para 0/1/2+ caracteres, dispara comparando contra o termo já aplicado (nunca contra o texto em digitação)"
    - "RadioGroup<T> como fonte única do valor selecionado — RadioListTile.groupValue/onChanged são deprecados nesta versão do Flutter (3.47.5) e flutter analyze trata deprecation info como fatal neste projeto"
    - "BlocConsumer com listener dedicado a jumpTo(0) quando ConteudoVitrine.carregando reaparece — keepScrollOffset:false só reresolve o topo num ScrollPosition NOVO (nova tela), nunca quando o mesmo ListView/ScrollController é reconstruído in-place por uma troca de busca/ordenação"

key-files:
  created:
    - lib/core/texto_normalizado.dart
    - lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart
    - test/core/texto_normalizado_test.dart
    - test/presentation/ordenacao_bottom_sheet_test.dart
  modified:
    - lib/domain/entities/cidade.dart
    - lib/data/datasources/imovel_mock_datasource.dart
    - lib/presentation/vitrine/vitrine_cubit.dart
    - lib/presentation/vitrine/vitrine_screen.dart
    - test/data/imovel_mock_datasource_test.dart
    - test/presentation/vitrine_cubit_test.dart
    - test/presentation/vitrine_fluxo_test.dart
    - test/presentation/vitrine_screen_test.dart

key-decisions:
  - "D-10 interpretado como 'botão Ordenar na linha logo abaixo da SearchBar' em vez de 'na mesma linha da busca': a 360dp, SearchBar + 'Ordenar: Mais recentes' não cabem lado a lado — sinalizado no human-check de fim de fase para confirmação do usuário"
  - "Descoberta durante Task 3 (Rule 2 - missing critical): keepScrollOffset:false não reseta o scroll ao trocar busca/ordenação, porque o MESMO ScrollController/ScrollPosition continua anexado ao ListView reconstruído in-place — precisa de um jumpTo(0) explícito disparado sempre que ConteudoVitrine.carregando reaparece (D-13), via listener de um BlocConsumer"
  - "Busca (D-05/D-06) e ordenação (D-11/D-12) implementadas inteiramente sobre os MAPAS de wire (snake_case) na DataSource, antes do parsing via ImoveisEnvelopeModel.fromJson — mesma disciplina de Plan 02-03, garante que a Fase 4 troca só a fonte dos dados, nunca a regra"

requirements-completed: [VIT-03, VIT-04]

coverage:
  - id: D1
    description: "Servidor simulado busca palavra-a-palavra em título+bairro, acento/caixa-insensível, descrição excluída, e falha deterministicamente no termo 'erro' (D-05, D-06, D-15)"
    requirement: "VIT-03"
    verification:
      - kind: unit
        ref: "test/data/imovel_mock_datasource_test.dart (grupos 'busca por texto' e 'gatilho erro determinístico': 6 casos, incluindo o caminho via ImovelRepositoryImpl -> Result.failure)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Ordenação mais_recentes/preco_asc/preco_desc/area_asc/area_desc com nulls-last em ambos os sentidos, aplicada só na DataSource, sem duplicar ids ao paginar (D-11, D-12)"
    requirement: "VIT-04"
    verification:
      - kind: unit
        ref: "test/data/imovel_mock_datasource_test.dart (grupo 'ordenação nulls-last': 5 casos, expectativas derivadas da própria fixture)"
        status: pass
    human_judgment: false
  - id: D3
    description: "VitrineCubit.buscar() debounce 400ms/2 caracteres: 1 caractere não dispara, digitação rápida coalesce numa única chamada, campo vazio recarrega na hora só se havia termo aplicado, mesmo termo nunca redispara, resposta atrasada descartada, close() cancela o debounce pendente"
    requirement: "VIT-03"
    verification:
      - kind: unit
        ref: "test/presentation/vitrine_cubit_test.dart (grupo 'buscar', 8 casos com fake_async)"
        status: pass
    human_judgment: false
  - id: D4
    description: "VitrineCubit.ordenarPor() reinicia do topo mantendo o termo de busca, é idempotente na ordenação já atual, e descarta resposta atrasada de uma ordenação anterior (D-13)"
    requirement: "VIT-04"
    verification:
      - kind: unit
        ref: "test/presentation/vitrine_cubit_test.dart (grupo 'ordenarPor', 3 casos incl. blocTest de sequência de estados)"
        status: pass
    human_judgment: false
  - id: D5
    description: "SearchBar sob o seletor de cidade, 'Nenhum imóvel encontrado para \"termo\"' + 'Limpar busca' distinto do vazio-de-cidade (D-07, D-09); bottom sheet 'Ordenar por' com as 5 opções via RadioGroup, sem groupValue/onChanged deprecados (D-10, D-11)"
    requirement: "VIT-03"
    verification:
      - kind: automated_ui
        ref: "test/presentation/vitrine_screen_test.dart (grupo SearchBar + semResultado, 4 casos) e test/presentation/ordenacao_bottom_sheet_test.dart (3 casos)"
        status: pass
    human_judgment: false
  - id: D6
    description: "Ponta a ponta pela pilha real: buscar 'cambui' mostra só os imóveis com título/bairro correspondentes; escolher 'Menor preço' após rolar duas páginas reordena pelo menor preco_venda e volta o scroll ao topo"
    requirement: "VIT-03"
    verification:
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart (2 casos: busca 'cambui'; ordenação 'Menor preço' + reset de scroll)"
        status: pass
    human_judgment: false
  - id: D7
    description: "Sensação real de digitação/debounce, do gatilho 'erro' e da troca de ordenação num teclado/tela físicos (Android + iOS), com o dev server Django do plano 02-02 no ar, incluindo confirmação visual se o layout do botão 'Ordenar' satisfaz a leitura de D-10 adotada nesta plan"
    verification: []
    human_judgment: true
    rationale: "flutter test não reproduz teclado físico, timing de debounce percebido pelo usuário, nem o dev server Django (dependência do plano 02-02, aguardando autorização); consolidado no UAT de fim de fase (human_verify_mode: end-of-phase). Registrado em WINDOWS.md (id 4, unrun-verify)."

duration: 17min
completed: 2026-09-25
status: complete
---

# Phase 2 Plan 5: Busca e Ordenação da Vitrine Summary

**Servidor simulado ganhou busca palavra-a-palavra em título+bairro (acento/caixa-insensível, descrição excluída), o gatilho determinístico "erro" e ordenação com nulls-last em cinco modos; o Cubit ganhou debounce de 400ms/2 caracteres e reinício único do topo compartilhado entre busca/ordenação; a tela ganhou a SearchBar Material 3 e o bottom sheet "Ordenar por" via RadioGroup — fechando VIT-03 e VIT-04 com o mesmo texto/normalizador único que a Fase 1 já havia resolvido para cidades.**

## Performance

- **Duration:** 17 min
- **Started:** 2026-09-25T20:07:00Z
- **Completed:** 2026-09-25T20:25:00Z
- **Tasks:** 3
- **Files modified:** 12 (4 novos, 8 alterados)

## Accomplishments
- `core/texto_normalizado.dart` extraído de `Cidade._normalizar` — única normalização de acento/caixa do app, reusada pela busca do mock (elimina a duplicação que o RESEARCH da fase apontou como risco de drift)
- `ImovelMockDataSource` virou o servidor simulado completo do contrato: busca DRF-like (toda palavra em título OU bairro), `FalhaSimuladaDoMock` no termo "erro", e as 5 ordenações do domínio com nulls-last em ambos os sentidos para preço e área — tudo sobre os mapas de wire, antes do parsing
- `VitrineCubit.buscar()`/`limparBusca()` com debounce de `Timer` próprio (400ms/2 caracteres), e `_aplicarConsulta()` unificando todo reinício-do-topo (D-13) reusado por `_reiniciar()`, `buscar`/`limparBusca` e `ordenarPor`
- `VitrineCubit.ordenarPor()` idempotente na ordenação já atual, descarta resposta atrasada de uma ordenação anterior (mesmo token de versão que já protegia busca/paginação)
- `VitrineScreen` ganhou a `SearchBar` M3 abaixo do seletor de cidade e o botão "Ordenar: <opção>" + bottom sheet `ordenacao_bottom_sheet.dart` (RadioGroup, sem API deprecada), com slot reservado para o filtro da Fase 3
- Descoberto e corrigido durante a Task 3: `keepScrollOffset: false` não reseta o scroll ao trocar busca/ordenação dentro da MESMA tela — um `BlocConsumer.listener` agora chama `jumpTo(0)` sempre que `ConteudoVitrine.carregando` reaparece (D-13)

## Task Commits

Cada task foi commitada atomicamente:

1. **Task 1: Servidor simulado — busca título+bairro sem acento, ordenação com nulls last e gatilho 'erro' (D-05, D-06, D-12, D-15)** - `69b37c5` (feat)
2. **Task 2: Busca na vitrine — SearchBar abaixo do seletor, debounce 400 ms/2 caracteres, 'Limpar busca' (VIT-03, D-07, D-08, D-09)** - `0f60c05` (feat)
3. **Task 3: Ordenação — botão 'Ordenar: <opção>' + bottom sheet com RadioGroup, reinício do topo (VIT-04, D-10, D-11, D-13)** - `00259e2` (feat)

## Files Created/Modified
- `lib/core/texto_normalizado.dart` - `normalizarTexto` extraída de `Cidade._normalizar`, única normalização do app
- `lib/domain/entities/cidade.dart` - `chaveNatural` delega a `normalizarTexto`, `_normalizar` privado removido
- `lib/data/datasources/imovel_mock_datasource.dart` - `FalhaSimuladaDoMock`, busca palavra-a-palavra, `_comparadorDe`/`_compararPorCampoNumericoNullsLast`
- `lib/presentation/vitrine/vitrine_cubit.dart` - `buscar`, `limparBusca`, `ordenarPor`, `_aplicarConsulta`, `Timer? _debounce`, `close()` override
- `lib/presentation/vitrine/vitrine_screen.dart` - `SearchBar`, `TextEditingController`, linha de ações "Ordenar: …" + `Spacer`, `BlocConsumer` com reset de scroll
- `lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart` - `RotuloOrdenacaoVitrine`, `mostrarOrdenacaoBottomSheet` (novo)
- `test/core/texto_normalizado_test.dart` - normalização + regressão de `chaveNatural` (novo)
- `test/data/imovel_mock_datasource_test.dart` - +16 testes (busca, gatilho erro, ordenação nulls-last)
- `test/presentation/vitrine_cubit_test.dart` - +8 testes `fake_async` de `buscar`, +3 blocTests de `ordenarPor`
- `test/presentation/vitrine_screen_test.dart` - +3 testes de `SearchBar`, `semResultado` estendido com "Limpar busca"
- `test/presentation/vitrine_fluxo_test.dart` - +2 e2e (busca "cambui"; ordenação "Menor preço" + reset de scroll)
- `test/presentation/ordenacao_bottom_sheet_test.dart` - 4 testes de widget (novo)

## Decisions Made
- D-10 interpretado como "botão Ordenar na linha logo abaixo da SearchBar" (não na mesma linha) — a 360dp os dois não cabem lado a lado; sinalizado no human-check de fim de fase para o usuário confirmar essa leitura.
- `keepScrollOffset: false` só restaura o topo quando um `ScrollPosition` NOVO é criado (nova `VitrineScreen`, ex.: troca de cidade); uma troca de busca/ordenação reconstrói o MESMO `ListView`/`ScrollController` in-place, então o D-13 "volta o scroll ao início" precisou de um `jumpTo(0)` explícito no `BlocConsumer.listener`, disparado toda vez que `ConteudoVitrine.carregando` reaparece — nunca durante `carregarMais()` (que permanece em `VitrineCarregada`), então nunca interfere com a paginação.
- Busca e ordenação implementadas sobre os mapas de wire (snake_case) na `DataSource`, antes do parsing — mesma disciplina do plano 02-03, garante que a Fase 4 troca só a fonte dos dados, nunca a regra.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Teste pré-existente de `imovel_mock_datasource_test.dart` quebrado pela busca passar a filtrar de verdade**
- **Found during:** Task 1, ao rodar a suíte completa depois de implementar a busca real
- **Issue:** O teste "busca aparece no next quando a consulta tem termo não-vazio" (do plano 02-03, quando `busca` era um hook pass-through) usava o `tamanhoPagina` padrão (10); com a busca "cambuí" agora filtrando de verdade, os poucos resultados de Campinas cabem numa única página, e `envelope.next` vira `null` — quebrando o `Uri.parse(envelope.next!)`.
- **Fix:** Reduzido o `tamanhoPagina` do teste para 2, garantindo que a busca continue exigindo mais de uma página.
- **Files modified:** test/data/imovel_mock_datasource_test.dart
- **Verification:** `flutter test test/data/imovel_mock_datasource_test.dart` — 33/33 passando.
- **Committed in:** 69b37c5 (Task 1 commit)

**2. [Rule 2 - Missing Critical] `RenderFlex overflow` no botão "Ordenar" a 360-400dp**
- **Found during:** Task 3, ao rodar `flutter test` completo depois de adicionar a linha de ações
- **Issue:** `OutlinedButton.icon(label: Text('Ordenar: Mais recentes'))` dentro de um `Row` com `Spacer` estourava a largura disponível (352px após o padding de 24px de cada lado) em telas estreitas — comportamento que quebraria em qualquer dispositivo real de 360-400dp, não só no teste.
- **Fix:** Envolvido o botão num `Flexible` e adicionado `overflow: TextOverflow.ellipsis` ao rótulo, permitindo que o botão encolha graciosamente em telas estreitas sem estourar o `Row`.
- **Files modified:** lib/presentation/vitrine/vitrine_screen.dart
- **Verification:** `flutter test test/presentation/vitrine_screen_test.dart` — 11/11 passando, sem overflow.
- **Committed in:** 00259e2 (Task 3 commit)

**3. [Rule 2 - Missing Critical] Scroll não voltava ao topo ao trocar de ordenação (D-13)**
- **Found during:** Task 3, ao escrever o teste e2e de "Menor preço" — a asserção de `scrollableDepois.position.pixels == 0` falhava com `1303.0`
- **Issue:** `keepScrollOffset: false` no `ScrollController` só reseta o offset quando um `ScrollPosition` NOVO é anexado (ex.: uma tela nova); como `VitrineScreen` é a MESMA instância ao longo de trocas de busca/ordenação, o `ListView` é reconstruído in-place com o mesmo controller/posição, então o scroll simplesmente permanecia onde estava — violando D-13 ("reinicia a lista do topo... volta o scroll ao início").
- **Fix:** Trocado o `BlocBuilder` por um `BlocConsumer` com um `listener` que chama `_controleDeRolagem.jumpTo(0)` sempre que `state.conteudo` vira `VitrineCarregando` (o único desfecho que representa um reinício real, D-13) — nunca durante `carregarMais()`, que mantém `VitrineCarregada`.
- **Files modified:** lib/presentation/vitrine/vitrine_screen.dart
- **Verification:** `flutter test test/presentation/vitrine_fluxo_test.dart` — e2e de "Menor preço" confirma `scrollableDepois.position.pixels == 0` depois de rolar duas páginas.
- **Committed in:** 00259e2 (Task 3 commit)

**4. [Rule 1 - Bug] Bottom sheet estourava a altura no ambiente de teste**
- **Found during:** Task 3, ao escrever `ordenacao_bottom_sheet_test.dart`
- **Issue:** `Column` com o título + 5 `RadioListTile` não cabia na altura constrangida que `showModalBottomSheet` aplica no `flutter_test` (`BoxConstraints(...h<=289.5)`), gerando `RenderFlex overflowed by 43 pixels on the bottom`.
- **Fix:** Envolvido o `Column` num `SingleChildScrollView` — sem efeito visual normal (5 opções cabem na tela real), mas remove o overflow determinístico e protege contra telas muito baixas.
- **Files modified:** lib/presentation/vitrine/widgets/ordenacao_bottom_sheet.dart
- **Verification:** `flutter test test/presentation/ordenacao_bottom_sheet_test.dart` — 4/4 passando, sem overflow.
- **Committed in:** 00259e2 (Task 3 commit)

---

**Total deviations:** 4 auto-fixed (2 Rule 1 — bugs de teste/layout introduzidos pela própria expansão de escopo desta plan, 2 Rule 2 — funcionalidade crítica faltante: layout responsivo do botão e reset de scroll exigido por D-13).
**Impact on plan:** Nenhum scope creep — as duas correções Rule 2 são requisitos literais do plano (D-13 "volta o scroll ao início"; qualquer tela real de 360-400dp precisa do botão não estourar). Nenhuma mudança de comportamento além do que a Task já especificava.

## Issues Encountered
None.

## User Setup Required
None - todo o trabalho desta plan roda inteiramente sobre o mock em memória; nenhuma configuração de serviço externo nova.

## Next Phase Readiness
- VIT-03 e VIT-04 completos e testados (unit + fake_async + bloc_test + widget + e2e); busca e ordenação resolvidas inteiramente na `DataSource`, nunca no Cubit/tela (negativo `grep -nE "\.where\(|\.sort\("` no Cubit confirmado vazio).
- `_aplicarConsulta()` e o token de versão já cobrem qualquer reinício futuro (ex.: filtros da Fase 3) sem precisar de um quarto caminho de reset — a Fase 3 só precisa chamar `_aplicarConsulta` com os novos parâmetros.
- O `Spacer` reservado na linha de ações e o mesmo `_comparadorDe`/`OrdenacaoVitrine` ficam prontos para a Fase 3 acrescentar filtros e a troca `preco_venda` -> `preco_aluguel` quando `finalidade=ALUGUEL`.
- Human-check de busca/ordenação em dispositivo real (Android/iOS + dev server Django) registrado em `WINDOWS.md` (id 4, `unrun-verify`) — consolidado no UAT de fim de fase (`human_verify_mode: end-of-phase`), mesmo padrão dos planos 02-01/02-02/02-03. Inclui pedido explícito de confirmação da leitura de D-10 adotada nesta plan.
- Fase 2 completa: todos os 5 planos (02-01..02-05) têm SUMMARY — pronta para `/gsd-verify-work 2` e, na sequência, `/gsd-plan-phase 3`.

---
*Phase: 02-vitrine-lista-busca-e-ordena-o*
*Completed: 2026-09-25*

## Self-Check: PASSED

- Todos os 12 arquivos criados/modificados (4 novos + 8 alterados) verificados presentes em disco (`[ -f ]`).
- Os 3 commits de task (`69b37c5`, `0f60c05`, `00259e2`) verificados presentes em `git log --oneline --all`.
- `flutter test` (suíte completa, 162 testes), `flutter analyze` (clean, incluindo `RadioListTile.groupValue`/`onChanged` deprecados) e o grep negativo `\.where\(|\.sort\(` no Cubit (vazio) re-executados nesta sessão, no HEAD final, todos passando.
- Os dois testes e2e do critério de sucesso da fase (busca "cambui"; ordenação "Menor preço" + reset de scroll) re-confirmados verdes na mesma execução da suíte completa.
- Commit ledger: `plan_head_before` = `ec385cd`; `git rev-list --count ec385cd..HEAD` = 3, batendo com `actuals.commits`.
