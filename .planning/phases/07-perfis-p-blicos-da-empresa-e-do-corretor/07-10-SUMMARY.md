---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 10
subsystem: presentation/perfis
tags: [flutter, cubit, paginacao, rolagem-infinita, slivers, e2e]
status: complete
requires:
  - phase: 07-06
    provides: VitrineAnuncianteMockDataSource (cursor, paginas de 10)
  - phase: 07-08
    provides: VitrineAnuncianteState/Cubit, SliverImoveisDoAnunciante, abrirPerfilCorretor
provides:
  - VitrineAnuncianteCubit.carregarMais (guardas) e tentarNovamente atendendo tambem o erro de carregar mais
  - RodapePaginacaoLista (carregando-mais / erro / fim) parametrizado por callback
  - CorpoPerfilComVitrine (CustomScrollView com ScrollController, gatilho a 90%, pagina curta) reutilizavel pela pagina da empresa
  - Rolagem infinita da vitrine na pagina do corretor (PERF-03)
affects: [07-11 e 07-12 pagina da empresa]
tech-stack:
  added: []
  patterns:
    - corpo rolavel compartilhado (cabecalho em slivers + vitrine opcional) dono do ScrollController
    - escuta do Cubit da vitrine por StreamSubscription do State, ligada so quando a vitrine existe (sem recriar o CustomScrollView)
key-files:
  created:
    - lib/presentation/perfis/widgets/rodape_paginacao_lista.dart
    - lib/presentation/perfis/widgets/corpo_perfil_com_vitrine.dart
    - test/presentation/corpo_perfil_com_vitrine_test.dart
  modified:
    - lib/presentation/perfis/vitrine_anunciante_cubit.dart
    - lib/presentation/perfis/widgets/sliver_imoveis_anunciante.dart
    - lib/presentation/perfis/perfil_corretor_screen.dart
    - test/presentation/vitrine_anunciante_cubit_test.dart
    - test/presentation/detalhe_navegacao_test.dart
key-decisions:
  - "Gatilho de rolagem e checagem de pagina curta compartilham um unico predicado no State (carregada, sem carregandoMais/erroAoCarregarMais, com proximaPagina) antes de chamar o Cubit: erro nunca redispara por rolagem, so pelo botao"
  - "Escuta dos estados da vitrine por StreamSubscription no State (ligada em initState/didUpdateWidget quando vitrine != null) em vez de BlocListener condicional, para nao trocar a arvore e recriar o CustomScrollView quando o perfil termina de carregar"
  - "Rodape copiado do da vitrine da cidade (lib/presentation/vitrine intacto, git diff vazio)"
requirements-completed: [PERF-03, API-08]
plan_head_before: 86c67dae53412ec83bea8352fcc4c06f94c29546
commits: 3
actuals:
  tokens: 14000
  tasks: 2
  commits: 3
coverage:
  - deliverable: "carregarMais acumula sem duplicar na ordem recebida; falha mantem a lista e o retry repete o mesmo cursor; guardas contra chamada dupla e close em voo"
    verification:
      - {kind: test, ref: "test/presentation/vitrine_anunciante_cubit_test.dart#carregarMais", status: pass}
    human_judgment: false
  - deliverable: "Rodape de carregando/erro/fim e gatilho a 90% na pagina do corretor; pagina curta se completa sozinha; vitrine nula nunca toca o Cubit"
    verification:
      - {kind: test, ref: "test/presentation/corpo_perfil_com_vitrine_test.dart", status: pass}
      - {kind: test, ref: "test/presentation/perfil_corretor_screen_test.dart", status: pass}
    human_judgment: false
  - deliverable: "Marina (corretor 7, 4 paginas) rola ate 'Voce chegou ao fim da lista' com todos os ids sem repetir"
    verification:
      - {kind: test, ref: "test/presentation/detalhe_navegacao_test.dart#rolagem infinita da vitrine do corretor", status: pass}
    human_judgment: false
---

# Phase 7 Plan 10: Rolagem infinita da vitrine do anunciante Summary

**A pagina do corretor pagina a vitrine por cursor com os quatro estados da vitrine da cidade (gatilho a 90%, rodape de carregando/erro/fim, retry so pelo botao, pagina curta que se completa sozinha), por um corpo rolavel compartilhado que a pagina da empresa reaproveita.**

## Accomplishments

- `VitrineAnuncianteCubit.carregarMais()` com as tres guardas (fora de `carregada`, pagina em voo/falha pendente, sem proxima pagina); `_carregarProximaPagina()` acumula `[...itens, ...novos]`, marca `erroAoCarregarMais` em falha mantendo os itens e nunca emite com o Cubit fechado. `tentarNovamente()` agora atende o erro da primeira pagina e o de carregar mais (mesmo cursor). O cursor continua opaco no Cubit.
- `RodapePaginacaoLista`: copia fiel do rodape da cidade com retry por callback.
- `CorpoPerfilComVitrine`: StatefulWidget dono do `ScrollController(keepScrollOffset: false)`; com vitrine ativa pede a proxima pagina a 90% e agenda a checagem de pagina curta (pos-frame) no primeiro build, na transicao null -> vitrine e a cada novo estado do Cubit; com `vitrine == null` nao le o Cubit (provider preguicoso intacto, perfil 404 nunca cria a vitrine).
- `SliverImoveisDoAnunciante` termina a lista carregada com o rodape; `PerfilCorretorScreen` passa a montar `CorpoPerfilComVitrine` (switch continua exaustivo, sem ramo abrangente).
- Testes: 10 novos de Cubit (inclui pilha real sobre o mock do corretor 7), 13 de componente (6 do rodape, 7 do corpo) e 1 e2e ate o fim da lista com os ids calculados das fixtures. Suite completa: 761 testes verdes; `flutter analyze` limpo.

## Task Commits

1. Task 1 RED: `72f6689` test(07-10) testes de carregarMais
2. Task 1 GREEN: `f9c5119` feat(07-10) carregarMais e retry no Cubit
3. Task 2: `49a61f5` feat(07-10) rodape, corpo com gatilho/pagina curta, tela e testes

## Deviations from Plan

### Auto-fixed / design adjustments

**1. [Rule 3 - Blocking/design] Escuta por StreamSubscription em vez de BlocListener**
- **Found during:** Task 2
- **Issue:** o plano manda envolver o `CustomScrollView` num `BlocListener` quando a vitrine esta ativa; como a vitrine surge na transicao carregando -> carregado do perfil, a troca de pai recriaria o `CustomScrollView` (e o Scrollable) naquele momento.
- **Fix:** o `State` assina `cubit.stream` em `initState`/`didUpdateWidget` quando `vitrine != null` e cancela no `dispose` (ou quando a vitrine some). Mesmo comportamento (checagem de pagina curta a cada novo estado e uma vez ao ligar), arvore estavel.
- **Files modified:** lib/presentation/perfis/widgets/corpo_perfil_com_vitrine.dart
- **Commit:** 49a61f5

**2. [Rule 2 - Correctness] Gatilho de rolagem checa o estado antes de chamar o Cubit**
- **Found during:** Task 2 (comportamento exigido: "com erroAoCarregarMais, arrastar nao chama carregarMais()")
- **Fix:** `_pedirProximaPaginaSePossivel()` aplica o mesmo predicado ao gatilho de 90% e a checagem de pagina curta; o Cubit repete as guardas.
- **Commit:** 49a61f5

**Total deviations:** 2 (1 Rule 3, 1 Rule 2). **Impact:** nenhum no contrato publico (`CorpoPerfilComVitrine({cabecalho, vitrine})` como planejado).

Observacoes: o `dart format` tocou `apresentacao_perfil.dart` (fora do escopo) e foi revertido; `lib/presentation/vitrine` sem diff contra `ba77b1e`.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None. Mitigacoes T-07-28 (guardas, parada em `next == null`, retry so por botao) e T-07-29 (Cubit/UI nunca interpretam `next`) aplicadas.

## Self-Check: PASSED

- Arquivos criados presentes (rodape, corpo, teste do corpo); commits 72f6689, f9c5119, 49a61f5 no historico.
- `flutter analyze` sem issues; `flutter test` completo verde (761); guarda de captura/cor e diff da vitrine da cidade vazios.
