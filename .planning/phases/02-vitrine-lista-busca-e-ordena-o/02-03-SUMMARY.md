---
phase: 02-vitrine-lista-busca-e-ordena-o
plan: 03
subsystem: ui
tags: [flutter, bloc_test, mocktail, cursor-pagination, scroll-infinito]

# Dependency graph
requires:
  - phase: 02-vitrine-lista-busca-e-ordena-o
    provides: "Plan 02-01: stack completa de imóveis (domain/data/presentation), ImovelMockDataSource tracer, VitrineCubit/VitrineScreen base, ImovelCard completo (VIT-01/VIT-02/API-04)"
provides:
  - "ImovelMockDataSource — servidor simulado completo: 40 imóveis/cidade atendida, paginação cursor real (base64Url opaco), next/previous como URL absoluta em /api/publico/imoveis/, sem estado mutável entre chamadas (D-14, D-15, API-04)"
  - "parametros_consulta_imoveis.dart — mapeamento ConsultaImoveis <-> query params do contrato, reusável pela Fase 4 (DataSource remota)"
  - "VitrineCubit.carregarMais() — scroll infinito guardado (token de versão, isClosed, sem auto-retry após erro), tentarNovamente() estendido ao erro de \"carregar mais\" (VIT-05, D-13)"
  - "VitrineScreen com ScrollController + rodapés carregando-mais/erro-ao-carregar-mais/fim-da-lista, e auto-carregamento quando a primeira página não preenche a tela"
affects: ["02-04 (VIT-06 troca cidades fixa/mock pelo endpoint real, mesma DataSource de imóveis)", "02-05 (busca/ordenação usam os hooks pass-through já deixados na pipeline do mock)", "04 (endpoint real de /imoveis herda a mesma forma de cursor/next provada aqui)"]

# Actuals (#2632)
actuals:
  tokens: 15567
  tasks: 3
  commits: 3
  plan_head_before: e418343

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Pipeline única de paginação no mock (_paginar): filtra por cidade -> hooks de busca/ordenação (pass-through até 02-05) -> ordena por recência -> corta [offset, offset+tamanhoPagina) — usada tanto por buscar() quanto por seguir(), sem estado mutável entre chamadas"
    - "Cursor opaco base64Url de \"o=<offset>\" — nunca interpretado fora de ImovelMockDataSource; Cubit/UI só repassam o valor de next adiante (contrato §4, D-13)"
    - "_carregarProximaPagina() privado reaproveitado por carregarMais() (scroll) e tentarNovamente() (retry explícito do erro de \"carregar mais\") — um único caminho de emissão evita estados intermediários redundantes"
    - "Instante-base fixo anterior a todas as datas verbatim do contrato, para que as 3 linhas de contrato/imoveis.example.json continuem na 1ª página depois da expansão para 40 linhas/cidade"

key-files:
  created:
    - lib/data/datasources/parametros_consulta_imoveis.dart
    - test/presentation/vitrine_screen_test.dart
  modified:
    - lib/data/mocks/imoveis_fixture.dart
    - lib/data/datasources/imovel_mock_datasource.dart
    - lib/presentation/vitrine/vitrine_cubit.dart
    - lib/presentation/vitrine/vitrine_screen.dart
    - test/data/imovel_mock_datasource_test.dart
    - test/presentation/vitrine_cubit_test.dart
    - test/presentation/vitrine_fluxo_test.dart

key-decisions:
  - "Instante-base da geração de criado_em (2026-07-20, sem relógio de sistema) escolhido para ficar ANTES de todas as 3 datas verbatim do contrato (a mais antiga é 2026-07-30) — garante que as linhas 42/57/63 continuam nas primeiras posições da ordenação por recência depois da expansão para 40 linhas/cidade, preservando os testes/asserts que já dependiam delas"
  - "ids gerados usam a faixa 100*(cidade+1)+k (100-139/200-239/300-339) — nunca colide com 42/57/63 por construção, sem precisar de checagem de colisão em runtime"
  - "carregarMais()/tentarNovamente() delegam para um único _carregarProximaPagina() privado — tentarNovamente() não precisa limpar erroAoCarregarMais manualmente antes de chamar, porque o primeiro emit de _carregarProximaPagina() já zera a flag junto com carregandoMais: true"

requirements-completed: [VIT-05]

coverage:
  - id: D1
    description: "ImovelMockDataSource simula um servidor real: 40 imóveis por cidade atendida (Campinas/Valinhos/Vinhedo), Indaiatuba sem nenhum, paginação cursor opaca base64Url, next/previous como URL absoluta no shape do contrato, latência configurável, sem estado mutável entre chamadas concorrentes"
    requirement: "VIT-05"
    verification:
      - kind: unit
        ref: "test/data/imovel_mock_datasource_test.dart (16 casos: fixture determinística/verbatim/cobertura, buscar 1ª página, seguir até o fim, idempotência, concorrência entre cidades, FormatException de cursor/ordenacao)"
        status: pass
    human_judgment: false
  - id: D2
    description: "VitrineCubit.carregarMais() pagina exatamente uma vez por cursor, nunca perde os itens visíveis numa falha, descarta páginas atrasadas após reinício de consulta ou close(), e só re-tenta explicitamente via tentarNovamente()"
    requirement: "VIT-05"
    verification:
      - kind: unit
        ref: "test/presentation/vitrine_cubit_test.dart (grupo \"carregarMais\", 8 casos: append em ordem, chamada dupla em voo, fim-de-lista, fora de VitrineCarregada, falha+retry, cidade trocada em voo, close em voo)"
        status: pass
    human_judgment: false
  - id: D3
    description: "VitrineScreen renderiza os 4 estados de lista (carregando/vazio/sem-resultado/erro) e os 3 desfechos de rodapé (carregando-mais/erro-ao-carregar-mais/fim-da-lista), com o scroll disparando carregarMais() a 90% do fim"
    requirement: "VIT-05"
    verification:
      - kind: automated_ui
        ref: "test/presentation/vitrine_screen_test.dart (8 casos)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Rolar Campinas até o fim (pilha real Cubit->UseCase->Repository->DataSource) mostra exatamente os 40 imóveis, ids únicos, mesma ordem de andar o mock diretamente — critério de sucesso 4 da fase"
    requirement: "VIT-05"
    verification:
      - kind: e2e
        ref: "test/presentation/vitrine_fluxo_test.dart#Campinas: rolar até o fim mostra as 40 linhas, ids únicos, mesma ordem da pilha real do mock (VIT-05, critério 4 da fase)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Sensação real de scroll físico, latência (~0.5s) e ausência de duplicatas visuais durante flings rápidos num emulador Android, com o dev server Django do plano 02-02 no ar"
    verification: []
    human_judgment: true
    rationale: "flutter test não reproduz física de scroll real nem o dev server Django (dependência do plano 02-02, ainda aguardando setup do usuário); consolidado no UAT de fim de fase (human_verify_mode: end-of-phase). Registrado em WINDOWS.md (id 3, unrun-verify)."

duration: 22min
completed: 2026-09-25
status: complete
---

# Phase 2 Plan 3: Scroll Infinito da Vitrine Summary

**Vitrine com scroll infinito completo (VIT-05): mock virou um servidor simulado com paginação cursor real (~40 imóveis/cidade, `next`/`previous` absolutos, base64Url opaco), o Cubit ganhou `carregarMais()` guardado por token de versão, e a tela ganhou o `ScrollController` + rodapés de carregando/erro/fim — provado ponta a ponta rolando Campinas até seus 40 imóveis únicos, na ordem do servidor.**

## Performance

- **Duration:** 22 min
- **Started:** 2026-09-25T20:16:44Z
- **Completed:** 2026-09-25T20:38:47Z
- **Tasks:** 3
- **Files modified:** 9 (2 novos, 7 alterados)

## Accomplishments
- `ImovelMockDataSource` deixou de ser um tracer (`seguir()` lançava `FormatException` deliberada) e virou o servidor simulado completo do contrato: 40 imóveis por cidade atendida, cursor opaco `base64Url`, `next`/`previous` absolutos em `/api/publico/imoveis/`, sem estado mutável entre chamadas concorrentes (D-14, D-15, API-04)
- Novo `parametros_consulta_imoveis.dart` isola o mapeamento `ConsultaImoveis <-> query params` do contrato — reusável tal e qual pela Fase 4 quando a DataSource remota substituir o mock
- `VitrineCubit.carregarMais()` pagina exatamente uma vez por cursor (guarda + token de versão + `isClosed`), nunca derruba os itens visíveis numa falha, e só re-tenta via `tentarNovamente()` explícito (scroll nunca re-dispara sozinho após erro)
- `VitrineScreen` virou `StatefulWidget` com `ScrollController` (gatilho a 90% do fim) e rodapés distintos para carregando-mais/erro-ao-carregar-mais/fim-da-lista, incluindo auto-carregamento quando a primeira página não preenche telas altas
- Teste end-to-end (`vitrine_fluxo_test.dart`) rola Campinas pela pilha real até "Você chegou ao fim da lista" e prova 40 ids únicos, todos de Campinas, na mesma ordem de andar o mock diretamente — critério de sucesso 4 da fase

## Task Commits

Cada task foi commitada atomicamente:

1. **Task 1: Servidor simulado — acervo de ~40 imóveis por cidade e paginação cursor seguindo o 'next' (D-14, D-15, API-04)** - `b510a80` (feat)
2. **Task 2: VitrineCubit.carregarMais com guarda, token de versão e retry explícito (VIT-05, D-13)** - `3acda3c` (feat)
3. **Task 3: Scroll infinito na tela — gatilho a 90%, rodapés carregando/erro/fim e estados cheios (VIT-05)** - `137c4bc` (feat)

## Files Created/Modified
- `lib/data/mocks/imoveis_fixture.dart` - Fixture expandida deterministicamente para 40 linhas/cidade atendida (mantendo 42/57/63 verbatim), Indaiatuba continua sem nenhuma
- `lib/data/datasources/parametros_consulta_imoveis.dart` - `caminhoImoveisPublico`, `parametrosDaConsulta`, `cidadeDoParametro`, `ordenacaoDoParametro`
- `lib/data/datasources/imovel_mock_datasource.dart` - `seguir()` real via cursor `base64Url`; pipeline única `_paginar()` para `buscar`/`seguir`
- `lib/presentation/vitrine/vitrine_cubit.dart` - `carregarMais()`, `_carregarProximaPagina()`, `tentarNovamente()` estendido ao erro de "carregar mais"
- `lib/presentation/vitrine/vitrine_screen.dart` - `StatefulWidget` + `ScrollController` + `_RodapePaginacao`
- `test/data/imovel_mock_datasource_test.dart` - 16 testes (fixture + paginação + concorrência + erros)
- `test/presentation/vitrine_cubit_test.dart` - +8 testes de `carregarMais`
- `test/presentation/vitrine_screen_test.dart` - novo, 8 testes de widget (4 estados de lista + 2 de rodapé + drag)
- `test/presentation/vitrine_fluxo_test.dart` - novo teste e2e de scroll; teste pré-existente ajustado para primeira página (10 de 40 itens)

## Decisions Made
- Instante-base da geração de `criado_em` (2026-07-20, fixo) escolhido para ficar ANTES das 3 datas verbatim do contrato (a mais antiga é 2026-07-30) — garante que as linhas 42/57/63 continuam nas primeiras posições da ordenação por recência, preservando as asserções que já dependiam delas.
- ids gerados usam a faixa `100*(cidade+1)+k` — nunca colide com 42/57/63 por construção (sempre ≥100), sem checagem de colisão em runtime.
- `carregarMais()`/`tentarNovamente()` delegam para um único `_carregarProximaPagina()` privado — evita um segundo `emit` intermediário só para limpar `erroAoCarregarMais` antes do retry.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Comentários da fixture continham as substrings "DateTime.now"/"Random", violando o próprio verify negativo do plano**
- **Found during:** Task 1, depois de escrever os comentários de `imoveis_fixture.dart` explicando a ausência de aleatoriedade
- **Issue:** O `<verify>` da Task 1 roda `! grep -nE "Random|DateTime\.now" ...` — o próprio plano avisa que esse grep também casa com comentários. Meus comentários explicativos citavam literalmente "DateTime.now" e "Random" para dizer que NÃO eram usados, o que fazia o grep negativo falhar.
- **Fix:** Reescrevi os comentários para descrever a mesma garantia sem as substrings literais ("nunca lido do relógio do sistema", "nada sorteado").
- **Files modified:** lib/data/mocks/imoveis_fixture.dart
- **Verification:** `grep -nE "Random|DateTime\.now" lib/data/mocks/imoveis_fixture.dart lib/data/datasources/imovel_mock_datasource.dart lib/data/datasources/parametros_consulta_imoveis.dart` — vazio.
- **Committed in:** b510a80 (Task 1 commit)

**2. [Rule 1 - Bug] Teste pré-existente de `vitrine_fluxo_test.dart` quebrado pela expansão da fixture (2 -> 40 imóveis/cidade)**
- **Found during:** Task 3, ao rodar a suíte completa depois de integrar o scroll infinito
- **Issue:** O teste "Campinas: cabeçalho..." (do plano 02-01) fixava `findsNWidgets(2)` — correto quando a fixture tinha só 2 linhas de Campinas. Com a expansão da Task 1 para 40, a primeira página passou a ter até 10 itens (variando com o cache extent do `ListView`), quebrando a contagem exata.
- **Fix:** Troquei a asserção de contagem fixa por uma verificação de que os cards materializados pertencem todos a Campinas, mantendo as asserções de texto específicas (id 42/57 presentes, "Terreno..." de Valinhos ausente).
- **Files modified:** test/presentation/vitrine_fluxo_test.dart
- **Verification:** `flutter test test/presentation/vitrine_fluxo_test.dart` — 3/3 passando.
- **Committed in:** 137c4bc (Task 3 commit)

**3. [Rule 1 - Bug] Viewport de teste dita quantos `ImovelCard`s materializam (cache extent do `ListView`)**
- **Found during:** Task 3, ao escrever `vitrine_screen_test.dart` e ajustar `vitrine_fluxo_test.dart`
- **Issue:** Um viewport MUITO alto faz a primeira página inteira caber na tela sem rolar, disparando o auto-carregamento de "não preenche a tela" da própria Task 3 — inflando a contagem de cards além do esperado num teste que queria só a primeira página. Um viewport MUITO baixo materializa menos cards do que o cache extent permitiria.
- **Fix:** Escolhi viewports intermediários por caso: `(400, 1200)` para os testes de rodapé de `vitrine_screen_test.dart` (card completo + rodapé visíveis, sem preencher a ponto de acionar o auto-carregamento) e mantive `(400, 2400)` em `vitrine_fluxo_test.dart` (já calibrado em 02-01, continua rolável).
- **Files modified:** test/presentation/vitrine_screen_test.dart, test/presentation/vitrine_fluxo_test.dart
- **Verification:** `flutter test` (suíte completa) — 115/115 passando.
- **Committed in:** 137c4bc (Task 3 commit)

---

**Total deviations:** 3 auto-fixed (todos Rule 1 — bugs de teste introduzidos pela própria expansão de escopo desta plan, nenhum de código de produção).
**Impact on plan:** Nenhum scope creep — todas as correções foram necessárias para os próprios verifies/testes desta plan passarem; nenhuma mudou o comportamento de produção além do que a Task já especificava.

## Issues Encountered
None.

## User Setup Required
None - o mock roda inteiramente em memória; nenhuma configuração de serviço externo nova nesta plan.

## Next Phase Readiness
- VIT-05 completo e testado (unit + bloc_test + widget + e2e); scroll infinito prova 40 ids únicos de Campinas, na ordem do servidor, sem duplicar/embaralhar (critério de sucesso 4 da fase).
- `parametros_consulta_imoveis.dart` já isola o mapeamento de query params no formato exato do contrato — plano 02-05 (busca/ordenação) e a Fase 4 (DataSource remota) reaproveitam sem reescrever.
- A pipeline `_paginar()` do mock já tem os hooks de busca/ordenação identificados (comentário explícito "pass-through até o plano 02-05") — plano 02-05 implementa o filtro/ordenação de verdade sem mudar a assinatura pública da DataSource.
- Human-check de scroll físico real (emulador + dev server Django) registrado em `WINDOWS.md` (id 3, `unrun-verify`) — consolidado no UAT de fim de fase (`human_verify_mode: end-of-phase`), mesmo padrão dos planos 02-01/02-02.

---
*Phase: 02-vitrine-lista-busca-e-ordena-o*
*Completed: 2026-09-25*

## Self-Check: PASSED

- Todos os 9 arquivos criados/modificados (7 `lib`/`test` + `parametros_consulta_imoveis.dart` + `vitrine_screen_test.dart`) verificados presentes em disco (`[ -f ]`).
- Os 3 commits de task (`b510a80`, `3acda3c`, `137c4bc`) verificados presentes em `git log --oneline --all`.
- `flutter test` (suíte completa, 115 testes), `flutter analyze` (clean) e o grep negativo `Random|DateTime\.now` (vazio) re-executados nesta sessão, no HEAD final, todos passando.
- Teste e2e do critério de sucesso 4 da fase (`vitrine_fluxo_test.dart#Campinas: rolar até o fim...`) re-confirmado verde na mesma execução da suíte completa.
- Commit ledger: `plan_head_before` = `e418343`; `git rev-list --count e418343..HEAD` = 3, batendo com `actuals.commits`.
