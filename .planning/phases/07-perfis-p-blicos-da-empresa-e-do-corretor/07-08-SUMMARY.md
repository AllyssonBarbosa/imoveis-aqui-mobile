---
phase: 07-perfis-p-blicos-da-empresa-e-do-corretor
plan: 08
subsystem: presentation/perfis
tags: [flutter, cubit, freezed, slivers, vitrine-anunciante, e2e]
status: complete
requires:
  - phase: 07-04
    provides: PerfilCorretorScreen, PerfilCorretorCubit, abrirPerfilCorretor, ErroPerfil
  - phase: 07-06
    provides: BuscarImoveisDoAnuncianteUseCase, VitrineAnuncianteRepositoryImpl, VitrineAnuncianteMockDataSource (§12)
  - phase: 07-07
    provides: corretor desativado 99 (imovel 337), grupos e2e em detalhe_navegacao_test
provides:
  - VitrineAnuncianteState (carregando/vazia/erro/carregada) e VitrineAnuncianteCubit (carregar, tentarNovamente)
  - SliverImoveisDoAnunciante (titulo + estados em slivers, ImovelCard na ordem recebida)
  - "Imoveis de {nome}" na pagina do corretor (PERF-03) pela pilha real do §12 sobre o mock
affects: [07-10 paginacao da vitrine do anunciante, 07-09/07-11 pagina da empresa]
tech-stack:
  added: []
  patterns:
    - MultiBlocProvider em abrirPerfilCorretor com provider da vitrine preguicoso (so nasce com perfil 200)
    - estado "achatado" carregada(itens, proximaPagina, carregandoMais, erroAoCarregarMais) como na vitrine da cidade
key-files:
  created:
    - lib/presentation/perfis/vitrine_anunciante_state.dart
    - lib/presentation/perfis/vitrine_anunciante_state.freezed.dart
    - lib/presentation/perfis/vitrine_anunciante_cubit.dart
    - lib/presentation/perfis/widgets/sliver_imoveis_anunciante.dart
    - test/presentation/vitrine_anunciante_cubit_test.dart
  modified:
    - lib/presentation/perfis/apresentacao_perfil.dart
    - lib/presentation/perfis/perfil_corretor_screen.dart
    - lib/di/injection.config.dart
    - test/presentation/apresentacao_perfil_test.dart
    - test/presentation/perfil_corretor_screen_test.dart
    - test/presentation/detalhe_navegacao_test.dart
key-decisions:
  - "Provider da vitrine preguicoso: duas latencias em sequencia (perfil, depois vitrine), em troca de nunca consultar imoveis de corretor 404 (T-07-25, contador 0 no e2e)"
  - "tentarNovamente so age a partir de VitrineAnuncianteErro; a 07-10 estende para o erro de 'carregar mais'"
  - "Estado vazio provado pela pilha real com o corretor 10 (Bruno Sales), sem caso especial na tela"
requirements-completed: [PERF-03, API-08]
plan_head_before: a97f69c43ca2e9457bef1fac0159c515880f112f
plan_head_after: 35153563953c7cd42fcad1a1761ce52b95e69d9d
commits: 2
actuals:
  tokens: 13400
  tasks: 2
  commits: 2
coverage:
  - deliverable: "Imoveis de {nome} com cards da vitrine do anunciante na ordem recebida; toque abre o imovel e voltar retorna ao perfil"
    verification:
      - {kind: test, ref: "test/presentation/detalhe_navegacao_test.dart#fluxo completo", status: pass}
      - {kind: test, ref: "test/presentation/perfil_corretor_screen_test.dart#carregada mostra os cards na ORDEM RECEBIDA", status: pass}
    human_judgment: false
  - deliverable: "Vitrine vazia (corretor 10 pela pilha real) e erro com 'Tentar de novo'"
    verification:
      - {kind: test, ref: "test/presentation/detalhe_navegacao_test.dart#anunciante sem imoveis (D-12)", status: pass}
      - {kind: test, ref: "test/presentation/vitrine_anunciante_cubit_test.dart", status: pass}
    human_judgment: false
  - deliverable: "Corretor desativado nunca cria a vitrine nem dispara a busca; guardas de concorrencia do Cubit"
    verification:
      - {kind: test, ref: "test/presentation/detalhe_navegacao_test.dart#corretor desativado", status: pass}
      - {kind: test, ref: "test/presentation/vitrine_anunciante_cubit_test.dart#fechar", status: pass}
    human_judgment: false
---

# Phase 7 Plan 08: Vitrine do anunciante na pagina do corretor Summary

**A pagina do corretor mostra "Imoveis de {nome}" com os cards do §12 (VitrineAnuncianteCubit -> use case -> repositorio -> mock), com vazio, erro com retry e vitrine so criada depois do perfil 200.**

## Accomplishments

- `VitrineAnuncianteState` freezed (carregando/vazia/erro/carregada) e `VitrineAnuncianteCubit` `@injectable`, com `isClosed` antes de cada `emit` e `tentarNovamente` restrito ao estado de erro.
- `SliverImoveisDoAnunciante`: titulo + `switch` exaustivo; `ImovelCard(key: imovel-anunciante-<id>)` na ordem recebida, toque via `aoAbrirImovel` (padrao `abrirDetalheImovel`).
- `abrirPerfilCorretor` monta `MultiBlocProvider` (perfil + vitrine preguicosa) e ganha `criarVitrineCubit`/`aoAbrirImovel`; `getIt` continua so ali (2 usos).
- Testes: e2e Marina -> card 42 -> voltar ao perfil; corretor desativado com contador 0; grupo "anunciante sem imoveis" com o corretor 10; DI real; 6 casos de tela com MockCubit; 10 casos de Cubit.

## Task Commits

1. Task 1 (estado, Cubit, sliver, tela, DI, e2e, tela, apresentacao): `1ea2240`
2. Task 2 (testes do Cubit: vazio, erro, retry, guardas, close): `3515356`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Testes existentes de 07-02/07-04/07-07 precisaram de um VitrineAnuncianteCubit** (risco ja aceito pelo usuario)
- **Found during:** Task 1
- **Issue:** `perfil_corretor_screen_test.dart` abria o perfil carregado sem prover a vitrine (cairia no `getIt`); o harness do e2e tambem; o teste de DI real terminava com timer pendente (a vitrine passou a carregar depois do perfil).
- **Fix:** harness da tela ganhou `_VitrineAnuncianteCubitFalso` (MockCubit) com padrao `vazia` (sem spinner extra nos testes antigos), janela alta (slivers lazy) e `aoAbrirImovel` de captura; e2e registra a fabrica real da vitrine; teste de DI real avanca a latencia da vitrine e usa janela alta.
- **Files modified:** test/presentation/perfil_corretor_screen_test.dart, test/presentation/detalhe_navegacao_test.dart
- **Commit:** 1ea2240

**2. [Rule 1 - Bug de teste] Ajustes de temporizacao/visibilidade nos testes novos**
- A vitrine do Bruno nasce no frame seguinte ao perfil (a transicao de 400 ms cobre a latencia de 300 ms); rota coberta fica fora de cena (`find` nao a ve). Asserts ajustados de acordo; o caso de "fechar antes da resposta" via blocTest foi substituido por teste simples (o blocTest fecha o Cubit depois do `act` e ficava preso aguardando a resposta).

**3. [Organizacao] Divisao dos commits**
- O Cubit, o sliver e o botao "Tentar de novo" foram escritos juntos na Task 1; o commit da Task 2 contem so `vitrine_anunciante_cubit_test.dart`. Comportamento final identico ao plano.

**Total deviations:** 3 (1 Rule 3, 1 Rule 1 de teste, 1 organizacional). **Impact:** nenhum no escopo; sem mudanca de producao fora do plano.

## Verification

- `dart run build_runner build -d`: ok (apenas `vitrine_anunciante_state.freezed.dart` e `injection.config.dart` mantidos; diffs so de fim de linha em outros gerados foram revertidos).
- `flutter analyze`: No issues found.
- `flutter test` (suite completa): 719 testes, All tests passed.
- Guardas do plano: sem MockDataSource/Fixture em presentation/domain; `getIt<` so em `perfil_corretor_screen.dart` (2); `git diff ba77b1e -- lib/presentation/vitrine` vazio; sem `try {` em `lib/presentation/perfis`.

## Known Stubs

Nenhum. Os flags `carregandoMais`/`erroAoCarregarMais` ficam `false` ate a 07-10 (intencional, documentado no estado).

## Threat Flags

Nenhum novo. T-07-24 (getIt so em `abrirPerfilCorretor`) e T-07-25 (vitrine so com perfil 200, contador 0) mitigados e cobertos por teste.

## Self-Check: PASSED

- Arquivos criados presentes em disco; commits `1ea2240` e `3515356` no ramo do worktree; suite completa verde.
