---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 07
subsystem: ui
tags: [flutter, dart, cubit, freezed, intl, gestao, historico, situacao]

requires:
  - phase: 09-mudança-de-situação (09-05)
    provides: GestaoImovelCubit/State, abrirGestaoImovel, GestaoImovelScreen (tracer), PilhaReal.entrarNoAcervo
  - phase: 09-mudança-de-situação (09-06)
    provides: ObterHistoricoSituacaoUseCase, MudancaSituacao e a rota do histórico na ApiFalsa
  - phase: 09-mudança-de-situação (09-01)
    provides: fixtures capturadas imovel_gestao_disponivel.json, historico_um_item/contrato/vazio.json
provides:
  - "Cabeçalho da gestão (foto de capa do cartão, código, título, preço por linhasDePrecoPorFinalidade) e seção Situação com 'desde dd/MM/yyyy HH:mm' do servidor"
  - "'Ver na vitrine' só quando o cartão trouxe na_vitrine do servidor, abrindo a página pública pelo padrão abrirDetalheImovel"
  - "Histórico de situações na tela, na ordem do servidor, com texto de vazio do site e falha parcial só do histórico"
  - "GestaoImovelCubit carregando imóvel e histórico em paralelo (Future.wait) e tentarNovamenteHistorico()"
  - "formatarDataHora/textoDesde (dd/MM/yyyy HH:mm sobre toLocal, sem locale) em apresentacao_gestao.dart"
affects: [09-08 mudança de situação, 09-09 desfechos, 09-10 recarga do acervo e 'Ver na vitrine' some depois da mudança (D-18), 09-13]

actuals:
  tokens: 10200
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "Duas leituras independentes no mesmo Cubit: Future.wait sobre as duas e um único emit com os dois desfechos; versão própria da repetição do histórico"
    - "Tela de gestão como ListView única (cabeçalho + seções), sem lista aninhada; nos testes de widget, superfície de celular (400x900) por causa da foto 16:9"
    - "Data do servidor formatada com DateFormat('dd/MM/yyyy HH:mm') sobre toLocal(), sem locale (não exige initializeDateFormatting)"

key-files:
  created:
    - lib/presentation/gestao_imovel/widgets/cabecalho_gestao.dart
    - lib/presentation/gestao_imovel/widgets/secao_situacao.dart
    - lib/presentation/gestao_imovel/widgets/historico_situacao.dart
    - test/presentation/apresentacao_gestao_test.dart
    - test/presentation/gestao_imovel_screen_test.dart
    - test/presentation/historico_situacao_test.dart
  modified:
    - lib/presentation/gestao_imovel/apresentacao_gestao.dart
    - lib/presentation/gestao_imovel/gestao_imovel_screen.dart
    - lib/presentation/gestao_imovel/gestao_imovel_state.dart
    - lib/presentation/gestao_imovel/gestao_imovel_state.freezed.dart
    - lib/presentation/gestao_imovel/gestao_imovel_cubit.dart
    - lib/di/injection.config.dart
    - test/presentation/gestao_imovel_cubit_test.dart
    - test/presentation/gestao_imovel_fluxo_test.dart

key-decisions:
  - "Retry do histórico usa token próprio (_versaoHistorico) e também confere a versão da carga: não invalida o imóvel em voo, mas uma carga nova vence a repetição"
  - "Future.wait sobre as duas leituras e depois await de cada uma (já completas) para manter os tipos de Result sem cast"
  - "tentarNovamente() (erro do imóvel) continua repetindo a carga completa, imóvel e histórico juntos"
  - "Texto de data do 'desde' no fluxo é conferido com RegExp(^desde \\d), porque o texto de vazio do histórico também contém 'desde o cadastro'"

patterns-established:
  - "ConteudoHistorico (carregando | carregado(itens) | erro) como segundo campo do estado de tela, molde ConteudoImovelGestao"
  - "Observação do servidor exibida como Text simples (T-09-13), sem Text.rich nem link"

requirements-completed: [SIT-07, SIT-01, SIT-03]

coverage:
  - id: D1
    description: "Cabeçalho mostra só foto de capa do cartão, código, título e preço por linhasDePrecoPorFinalidade; seção Situação mostra o rótulo e 'desde dd/MM/yyyy HH:mm' do servidor, sem endereço nem descrição"
    requirement: "SIT-01"
    verification:
      - kind: unit
        ref: "test/presentation/gestao_imovel_screen_test.dart#carregado: título, preço, \"Situação\", rótulo e \"desde\" do servidor"
        status: pass
      - kind: unit
        ref: "test/presentation/apresentacao_gestao_test.dart#formatarDataHora (D-05)"
        status: pass
    human_judgment: false
  - id: D2
    description: "'Ver na vitrine' só aparece com na_vitrine do cartão e abre a página pública com o imóvel de mesmo id; sem na_vitrine o botão não existe"
    requirement: "SIT-07"
    verification:
      - kind: unit
        ref: "test/presentation/gestao_imovel_screen_test.dart#\"Ver na vitrine\" só com naVitrine do servidor"
        status: pass
      - kind: unit
        ref: "test/presentation/gestao_imovel_screen_test.dart#sem naVitrine o botão \"Ver na vitrine\" não existe"
        status: pass
    human_judgment: false
  - id: D3
    description: "Histórico na tela na ordem do servidor: de → para, quando e quem, observação só se houver, '—' para situação desconhecida, texto de vazio do site, observação como texto simples"
    requirement: "SIT-03"
    verification:
      - kind: unit
        ref: "test/presentation/historico_situacao_test.dart"
        status: pass
      - kind: e2e
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#histórico com uma mudança do servidor aparece com de → para"
        status: pass
    human_judgment: false
  - id: D4
    description: "Imóvel e histórico carregam em paralelo num único estado; falha só do histórico mantém o imóvel e 'Tentar de novo' repete só o histórico; respostas vencidas são descartadas"
    requirement: "SIT-03"
    verification:
      - kind: unit
        ref: "test/presentation/gestao_imovel_cubit_test.dart"
        status: pass
      - kind: e2e
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#falha só do histórico mantém o imóvel na tela"
        status: pass
    human_judgment: false
  - id: D5
    description: "Aparência da tela de gestão (foto 16:9, espaçamentos, hierarquia tipográfica, rolagem) em aparelho real"
    verification: []
    human_judgment: true
    rationale: "Layout e leitura visual não são provados por teste de widget; o human-check de fim de fase confere no aparelho"

duration: 12 min
completed: 2026-11-22
plan_head_before: f0957225cf6dad3ced4e97fdfdc7ea8e4b804915
commits: 2
status: complete
---

# Phase 9 Plan 07: Tela de gestão completa para leitura Summary

**A tela de gestão do imóvel mostra cabeçalho (capa, código, título, preço), situação com "desde dd/MM/yyyy HH:mm" do servidor, "Ver na vitrine" só com `na_vitrine` e o histórico de mudanças na ordem do servidor, lido em paralelo com o imóvel por `Future.wait`, com falha parcial só do histórico**

## Performance

- **Duration:** 12 min
- **Started:** 2026-11-22T15:52:00Z (aprox.)
- **Completed:** 2026-11-22T15:58:00Z (aprox.)
- **Tasks:** 2
- **Files modified:** 14 (6 criados, 8 alterados)

## Accomplishments

- Task 1: `CabecalhoGestao` (foto 16:9 com `ImagemRede`, código, título, preço) usa os dados do imóvel quando já carregado e os da prévia antes disso, sem "pular" quando o detalhe chega. `SecaoSituacao` mostra "Situação", a marca com `rotuloSituacao` e `textoDesde(situacaoDesde)`. `formatarDataHora` = `DateFormat('dd/MM/yyyy HH:mm')` sobre `toLocal()`, sem locale (D-05, A3).
- "Ver na vitrine" (`OutlinedButton.icon`, `Icons.storefront`) só com `previa.naVitrine` do servidor; chama `aoVerNaVitrine` (padrão `abrirDetalheImovel`) com `previa.paraPrevia()`. A tela nunca olha `publicado` nem `situacao` para isso (D-02, provado por `grep` do gate).
- Task 2: `GestaoImovelState.historico` (`ConteudoHistorico`: `HistoricoCarregando`, `HistoricoCarregado`, `HistoricoErro`). `GestaoImovelCubit` recebe também `ObterHistoricoSituacaoUseCase`, dispara as duas leituras juntas, descarta resposta de versão vencida e emite um único estado com os dois desfechos. `tentarNovamenteHistorico()` repete só o histórico.
- `HistoricoSituacao`: lista na ordem recebida (`Column` + `Divider`, sem lista aninhada, sem reordenar/filtrar/paginar), item com "Disponível → Reservado", "dd/MM/yyyy HH:mm · Nome" e a observação só quando não vazia como `Text` simples (T-09-13); vazio com o texto do site; situação nula como "—".
- Fluxo na pilha real: histórico vazio por padrão, uma mudança servida pelo wire (`historico_um_item.json`) aparece com a observação da captura e falha só do histórico mantém o imóvel; `conferirCabecalhosDeAutorizacao()` passa nos três.
- `flutter analyze lib` limpo; `flutter test` inteiro verde: **1319** (1293 antes deste plano + 26).

## Task Commits

1. **Task 1: Cabeçalho, situação com "desde" e "Ver na vitrine" só com na_vitrine** - `aa6fc34` (feat; testes primeiro, RED = falha de carga por símbolos inexistentes)
2. **Task 2: Histórico na tela, carga em paralelo e falha parcial** - `9e4ac5f` (feat; testes primeiro)

**Plan metadata:** commits docs(09-07) logo após este SUMMARY.

## Files Created/Modified

- `lib/presentation/gestao_imovel/apresentacao_gestao.dart` - textos fixos, `formatarDataHora`, `textoDesde`, textos do histórico (`rotuloSituacaoOuTraco`, `textoDeParaHistorico`, `textoQuandoEQuem`)
- `lib/presentation/gestao_imovel/widgets/cabecalho_gestao.dart`, `secao_situacao.dart`, `historico_situacao.dart` - widgets novos, só `ColorScheme` e `textTheme`
- `lib/presentation/gestao_imovel/gestao_imovel_screen.dart` - `ListView` única, `aoVerNaVitrine`, `construirImagemDeRede` (`@visibleForTesting`), seção do histórico
- `lib/presentation/gestao_imovel/gestao_imovel_state.dart` (+ `.freezed.dart`) - campo `historico` e a união `ConteudoHistorico`
- `lib/presentation/gestao_imovel/gestao_imovel_cubit.dart` - `Future.wait`, `tentarNovamenteHistorico()`
- `lib/di/injection.config.dart` - Cubit com os dois use cases (único gerado além do `.freezed.dart` do estado; nenhum só-CRLF para restaurar)
- `test/presentation/apresentacao_gestao_test.dart`, `gestao_imovel_screen_test.dart`, `historico_situacao_test.dart` (novos); `gestao_imovel_cubit_test.dart`, `gestao_imovel_fluxo_test.dart` (ampliados)

## Decisions Made

- Retry do histórico com token próprio (`_versaoHistorico`) que também confere a versão da carga: não invalida a leitura do imóvel em voo, mas uma carga nova sempre vence uma repetição antiga.
- `Future.wait<Object>` sobre as duas leituras e, em seguida, `await` de cada uma (já completa) para manter os tipos de `Result` sem cast.
- `tentarNovamente()` (erro do imóvel) segue repetindo a carga completa, imóvel e histórico juntos.
- Nos testes de widget e de fluxo que olham o histórico, a superfície é 400x900: com a foto 16:9 na largura padrão (800) o `ListView` não constrói o que fica abaixo da área visível.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Asserção do "desde" no fluxo pegava também o texto de vazio do histórico**
- **Found during:** Task 2 (fluxo na pilha real)
- **Issue:** `find.textContaining('desde ')` passou a achar dois textos ("desde 22/11/2026 ..." e "disponível desde o cadastro"), o que quebrou a asserção que a Task 1 já tinha deixado verde.
- **Fix:** o padrão virou `RegExp(r'^desde \d')`, que só casa com o "desde" da situação.
- **Files modified:** `test/presentation/gestao_imovel_fluxo_test.dart`
- **Verification:** os quatro arquivos de teste da Task 2 verdes
- **Committed in:** `9e4ac5f`

---

**Total deviations:** 1 auto-fixed (1 bug, só em teste)
**Impact on plan:** nenhuma mudança de escopo ou de código de produção.

## Issues Encountered

- Primeira rodada dos testes de tela da Task 1 falhou porque a foto 16:9 na largura padrão do teste empurrava o conteúdo para fora da área visível (o `ListView` é preguiçoso). Resolvido com superfície de celular nos testes; o código de produção não mudou.

## Verificação

- Task 1: `apresentacao_gestao_test.dart`, `gestao_imovel_screen_test.dart` e `gestao_imovel_fluxo_test.dart` verdes; `flutter analyze lib` limpo; gate de `grep` (DateFormat sem locale, `toLocal()`, `naVitrine` na tela, nenhum `publicado`/`situacao ==` na tela) passou.
- Task 2: `historico_situacao_test.dart`, `gestao_imovel_cubit_test.dart`, `gestao_imovel_screen_test.dart` e `gestao_imovel_fluxo_test.dart` verdes (31 casos); gate de `grep` (`Future.wait`, texto de vazio, `HistoricoSituacao` na tela, `ObterHistoricoSituacaoUseCase` no Cubit) passou.
- Fim da onda 5 (D-16): `flutter analyze lib` limpo e `flutter test` inteiro, **1319 verdes**.
- Nenhum gerado só-CRLF deixado modificado; nenhum push.

## Threat Flags

None - nenhuma superfície nova além da planejada (T-09-03 a tela só mostra o que veio dos UseCases e resposta vencida é descartada por teste; T-09-04 `conferirCabecalhosDeAutorizacao` nos fluxos do histórico; T-09-13 observação só como `Text` simples, provado por teste; T-09-10 situação desconhecida vira "—"; T-09-SC nenhum pacote novo, o `intl` já estava no `pubspec.yaml`).

## Known Stubs

Nenhum stub. "Mudar situação" e o "Ver na vitrine" que some depois de uma mudança (D-18) entram nos planos 09-08 e 09-10, como o plano previa.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- A tela de gestão está completa para leitura; 09-08 pode acrescentar a mudança de situação ao mesmo `GestaoImovelState` e ao Cubit (que já tem os dois use cases de leitura).
- Depois de uma mudança, o histórico precisa ser relido: `tentarNovamenteHistorico()` já faz isso sem tocar no imóvel (ponto de reuso para o 09-09/09-10).
- Commits locais em `feat/APP09`; nenhum push.

## Self-Check: PASSED

- Os 6 arquivos criados existem em disco e estão commitados (`git ls-files` confere).
- Commits `aa6fc34` e `9e4ac5f` existem em `feat/APP09`; `git rev-list --count f095722..HEAD` = 2.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
