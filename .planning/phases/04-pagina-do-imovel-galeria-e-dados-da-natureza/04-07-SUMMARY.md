---
phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
plan: 07
subsystem: ui
tags: [flutter, material3, presentation, pageview, interactiveviewer, cached-network-image, tdd, dart]

requires:
  - phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza
    provides: "DetalheImovelScreen com SliverAppBar fixo e botao voltar translucido (04-03), DetalheImovel.fotos na ordem recebida e filtradas http(s) (04-04), secoes da natureza (04-06)"
provides:
  - "ImagemRede e ImagemPadraoImovel compartilhadas por vitrine e detalhe (imagem de rede sem AspectRatio, fallback verde)"
  - "GaleriaImovel: PageView lazy com todas as fotos na ordem recebida, contador N/M e Semantics 'Foto N de M'"
  - "VisualizadorFotos + abrirVisualizadorFotos: tela cheia com swipe, pinch-zoom 1x a 4x (InteractiveViewer do SDK) e botao Fechar"
  - "Topo da pagina do imovel: galeria quando carregado, capa da previa nos demais estados"
affects: [04-08, fase-05 endpoint real do detalhe]

actuals:
  tokens: 7966
  tasks: 2
  commits: 4

plan_head_before: 1abf12305d307d01d6b41c11eaaaeb590fca3cc1

tech-stack:
  added: []
  patterns:
    - "ImagemRede sem AspectRatio: quem usa decide o slot (card = 16:9, galeria = preenche o SliverAppBar)"
    - "Gancho de teste construirImagemDeRede repassado ate a folha; @visibleForTesting so nas pontas (tela, FotoCapaImovel) para o analyzer ficar limpo"
    - "Indice de pagina e zoom como estado efemero de State, nunca no Cubit; um State/TransformationController por pagina do visualizador"

key-files:
  created:
    - lib/presentation/comum/imagem_rede.dart
    - lib/presentation/detalhe_imovel/widgets/galeria_imovel.dart
    - lib/presentation/detalhe_imovel/widgets/visualizador_fotos.dart
    - test/presentation/galeria_imovel_test.dart
    - test/presentation/visualizador_fotos_test.dart
  modified:
    - lib/presentation/vitrine/widgets/foto_capa_imovel.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart
    - test/presentation/detalhe_imovel_screen_test.dart

key-decisions:
  - "@visibleForTesting fica apenas em DetalheImovelScreen e FotoCapaImovel; em ImagemRede e GaleriaImovel o gancho e documentado mas sem anotacao, porque o analyzer acusa invalid_use_of_visible_for_testing_member quando lib repassa o parametro anotado"
  - "Uma unica foto mostra '1/1' (A7: D-07 nao manda esconder)"
  - "Visualizador usa icone de imagem quebrada branco como fallback (imagemPadrao) em vez do verde da vitrine, que ficaria destoante sobre fundo preto"
  - "Somente a foto visivel decide travar o swipe: o callback de zoom carrega o indice da pagina e o pai ignora paginas que nao sao a atual"

patterns-established:
  - "Zoom x swipe (A1): PageView.physics = NeverScrollableScrollPhysics enquanto getMaxScaleOnAxis() > 1.01 da pagina visivel; onPageChanged limpa a flag e a pagina nova nasce sem zoom"
  - "Teste de swipe sobre InteractiveViewer usa arrasto de dedo real (varios moveBy curtos passando de meia pagina); um unico salto ou arrasto curto volta para a pagina original"

requirements-completed: [DET-02]

coverage:
  - id: D1
    description: "Topo da pagina carregada e uma galeria PageView com todas as fotos na ordem recebida e contador N/M; arrastar troca foto e contador"
    requirement: DET-02
    verification:
      - kind: unit
        ref: "test/presentation/galeria_imovel_test.dart#arrastar para a esquerda troca a foto e o contador (2/3)"
        status: pass
      - kind: unit
        ref: "test/presentation/detalhe_imovel_screen_test.dart#carregado com 3 fotos mostra a galeria e o contador 1/3"
        status: pass
    human_judgment: false
  - id: D2
    description: "Galeria no SliverAppBar fixo: ao rolar a barra encolhe e o botao voltar continua visivel e legivel sobre qualquer foto (D-09)"
    requirement: DET-02
    verification:
      - kind: unit
        ref: "test/presentation/detalhe_imovel_screen_test.dart#galeria (DET-02) (tooltip Voltar presente em todos os estados)"
        status: pass
    human_judgment: true
    rationale: "Legibilidade do botao voltar sobre fotos claras e escuras e o comportamento visual do colapso nao sao julgaveis em teste de widget; confirmar no human-check de fim de fase"
  - id: D3
    description: "Imovel sem fotos mostra a imagem padrao verde, sem contador e sem toque; carregando mostra a capa da previa sem contador"
    requirement: DET-02
    verification:
      - kind: unit
        ref: "test/presentation/detalhe_imovel_screen_test.dart#carregado sem fotos mostra a imagem padrao, sem contador (D-10)"
        status: pass
      - kind: unit
        ref: "test/presentation/detalhe_imovel_screen_test.dart#carregando mostra a capa da previa, sem galeria nem contador (D-16)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Tocar numa foto abre visualizador em tela cheia na mesma foto, com swipe, pinch-zoom ate 4x via InteractiveViewer sem pacote novo, botao fechar e physics travada enquanto ampliada"
    requirement: DET-02
    verification:
      - kind: unit
        ref: "test/presentation/visualizador_fotos_test.dart#ampliada, a pagina trava o swipe; ao voltar a 1x, destrava"
        status: pass
      - kind: unit
        ref: "test/presentation/detalhe_imovel_screen_test.dart#tocar na segunda foto da galeria abre o visualizador em 2/3"
        status: pass
    human_judgment: true
    rationale: "O mecanismo (physics acompanha a escala) e testado, mas o toque real do pinch e a arbitragem de gestos entre InteractiveViewer e PageView (RESEARCH A1, confianca baixa) so podem ser julgados em aparelho/emulador"

duration: 10min
completed: 2026-10-12
status: complete
---

# Phase 4 Plan 07: Galeria de fotos e visualizador em tela cheia Summary

**Galeria PageView com contador N/M no SliverAppBar fixo e visualizador em tela cheia com swipe e pinch-zoom de 1x a 4x via InteractiveViewer do SDK (sem pacote novo), com imagem de rede extraida para ImagemRede compartilhada com a vitrine**

## Performance

- **Duration:** 10 min
- **Started:** 2026-10-12T14:32:38Z
- **Completed:** 2026-10-12T14:38:02Z
- **Tasks:** 2
- **Files modified:** 8 (5 criados, 3 alterados)

## Accomplishments

- `ImagemRede`/`ImagemPadraoImovel` extraidos de `FotoCapaImovel`, que agora so envolve `ImagemRede` em `AspectRatio(16/9)`; todos os testes do card e da vitrine seguem verdes.
- `GaleriaImovel` mostra todas as fotos na ordem recebida (nunca reordena), contador N/M, `Semantics` "Foto N de M" por slide e callback de toque com o indice; sem fotos cai na imagem padrao verde, sem contador.
- `DetalheImovelScreen` coloca a galeria no `FlexibleSpaceBar` quando carregado e a capa da previa nos demais estados (D-16), mantendo `pinned: true` e o botao voltar translucido (D-09).
- `VisualizadorFotos`: rota `fullscreenDialog`, fundo preto, `InteractiveViewer` 1x a 4x por pagina com `TransformationController` proprio, titulo N/M, botao "Fechar", e swipe travado enquanto a foto visivel esta ampliada.

## Task Commits

Cada tarefa seguiu RED -> GREEN, sem REFACTOR separado (nada a limpar):

1. **Task 1: Galeria com contador N/M, imagem padrao sem fotos**
   - `4833df1` (test) - testes falhando + esqueletos so para compilar
   - `642011d` (feat) - ImagemRede, FotoCapaImovel delegando, GaleriaImovel e galeria no SliverAppBar
2. **Task 2: Visualizador em tela cheia com swipe e pinch-zoom**
   - `343a378` (test) - testes falhando + esqueleto so para compilar
   - `9ceff15` (feat) - VisualizadorFotos, abrirVisualizadorFotos e fio do toque na galeria

**Plan metadata:** commit `docs(04-07)` seguinte (SUMMARY) e commit final de STATE/ROADMAP/REQUIREMENTS.

## Files Created/Modified

- `lib/presentation/comum/imagem_rede.dart` - `ImagemPadraoImovel` (verde + casa) e `ImagemRede` (CachedNetworkImage com fallback, gancho de teste)
- `lib/presentation/vitrine/widgets/foto_capa_imovel.dart` - mesma API publica, agora `AspectRatio(16/9)` em volta de `ImagemRede`
- `lib/presentation/detalhe_imovel/widgets/galeria_imovel.dart` - PageView lazy + contador + semantica + toque
- `lib/presentation/detalhe_imovel/widgets/visualizador_fotos.dart` - rota e widget do visualizador, pagina com zoom
- `lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart` - galeria/capa no app bar, `construirImagemDeRede` de teste, `aoTocarFoto` abrindo o visualizador
- `test/presentation/galeria_imovel_test.dart`, `test/presentation/visualizador_fotos_test.dart` - novos; `detalhe_imovel_screen_test.dart` - grupos de galeria e visualizador

## Decisions Made

- `@visibleForTesting` so em `DetalheImovelScreen` e `FotoCapaImovel` (pontas); `ImagemRede` e `GaleriaImovel` documentam o gancho sem anotar, porque o analyzer rejeita (warning) o repasse de um parametro anotado dentro de `lib`.
- Foto unica mostra "1/1" (A7 confirmada como decisao de UX, sujeita ao human-check).
- Fallback do visualizador e um icone branco de imagem quebrada (via `imagemPadrao`), nao o verde da vitrine.
- O callback de zoom carrega o indice da pagina; o pai so reage a pagina atual.

## TDD Gate Compliance

Gates RED e GREEN presentes para as duas tarefas (`test(04-07)` antes de cada `feat(04-07)`). Observacao: as novas classes nao existiam, entao o commit RED inclui esqueletos que apenas compilam (retornam `SizedBox.shrink`), para que os testes novos falhem em asserções do comportamento planejado, e nao em erro de compilacao. Os registros formais de `gsd_run check tdd-red-evidence` nao foram gerados (o plano e `type: execute`, nao `type: tdd`). No RED da Task 2 os testes que olham um widget inexistente falham com `StateError`/expect de lookup na ausencia do comportamento, e o teste "sem fotos nao abre o visualizador" ja passava no RED (guarda de regressao, nao de comportamento novo).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] @visibleForTesting nos ganchos repassados gerava warnings do analyzer**
- **Found during:** Task 1 (GREEN)
- **Issue:** `flutter analyze` reportou 4 `invalid_use_of_visible_for_testing_member` ao repassar `construirImagemDeRede` de tela -> galeria -> ImagemRede e de FotoCapaImovel -> ImagemRede; o criterio de sucesso exige analyzer limpo.
- **Fix:** anotacao mantida apenas nas pontas (`DetalheImovelScreen`, `FotoCapaImovel`); removida de `ImagemRede` e `GaleriaImovel`, com comentario explicando.
- **Files modified:** imagem_rede.dart, galeria_imovel.dart, foto_capa_imovel.dart, detalhe_imovel_screen.dart
- **Verification:** `flutter analyze` sem issues; testes verdes.
- **Committed in:** 642011d

**2. [Rule 1 - Bug] Teste de swipe do visualizador usava arrasto que nao assentava na pagina seguinte**
- **Found during:** Task 2 (GREEN)
- **Issue:** o primeiro arrasto de teste (um salto grande, depois 20 passos de 20 px) ficava em 1,475 paginas e voltava para a pagina original; o comportamento do app estava certo, o teste e que nao passava de meia pagina. Experimento isolado mostrou que um `PageView` com `InteractiveViewer` por pagina segue o dedo normalmente.
- **Fix:** helper `deslizarParaEsquerda` com 30 passos de 20 px, passando de meia pagina.
- **Files modified:** test/presentation/visualizador_fotos_test.dart
- **Verification:** teste passa; suite completa verde.
- **Committed in:** 9ceff15

---

**Total deviations:** 2 auto-fixed (1 blocking, 1 bug de teste)
**Impact on plan:** Nenhum aumento de escopo; a primeira e consequencia direta da exigencia de analyzer limpo, a segunda e ajuste do proprio teste.

## Issues Encountered

- Disco com 3,5 GiB livres (acima do minimo de 2 GiB da precondicao); nenhuma falha de espaco durante `flutter test`.

## Known Stubs

Nenhum. Os esqueletos do commit RED foram todos substituidos pela implementacao real no commit GREEN correspondente.

## Threat Flags

Nenhuma superficie nova alem do modelo de ameacas do plano: `PageView.builder` lazy (T-04-07-01), apenas URLs ja filtradas http(s) na camada de dados (T-04-07-03) e nenhum pacote de galeria/zoom em `pubspec.yaml` (T-04-07-SC, gate de grep passou).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Pronto para o 04-08. O human-check de fim de fase fica pendente: pinch real, arrasto da foto ampliada e legibilidade do botao voltar sobre fotos claras/escuras (imoveis 103 com quatro fotos e 104 sem fotos, em Campinas).
- Risco aberto A1 (confianca baixa): arbitragem real de gestos zoom x swipe so e confirmada em aparelho/emulador.

## Self-Check: PASSED

- Arquivos criados presentes: imagem_rede.dart, galeria_imovel.dart, visualizador_fotos.dart, galeria_imovel_test.dart, visualizador_fotos_test.dart.
- Commits 4833df1, 642011d, 343a378, 9ceff15 existem na branch feat/APP04.
- `flutter analyze`: sem issues. `flutter test`: 553 testes passando. Gates de grep (sem reordenacao de fotos; sem pacote de galeria/zoom no pubspec) passaram.

---
*Phase: 04-pagina-do-imovel-galeria-e-dados-da-natureza*
*Completed: 2026-10-12*
