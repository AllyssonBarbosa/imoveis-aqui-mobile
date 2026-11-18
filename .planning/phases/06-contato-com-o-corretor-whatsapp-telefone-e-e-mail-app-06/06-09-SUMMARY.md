---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 09
subsystem: apresentacao
tags: [contato, perfil-corretor, barra-contato, freezed, e2e, widget-test]
status: complete

requires:
  - phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
    provides: "BarraContato, ContatoCubit e abrirDetalheImovel(criarContatoCubit) (06-07); bottom sheet, spinner e SnackBars (06-08); ApiFalsa com POST de contato (06-05)"
provides:
  - "ContatoDoImovel(imovelId, titulo, canais): contexto do imovel levado ao perfil"
  - "abrirPerfilCorretor(..., contato:, criarContatoCubit:) com a mesma BarraContato e legenda 'Sobre: <titulo>'"
  - "e2e: WhatsApp no perfil grava POST no mesmo imovel (path com o id da casa), sem credencial"
  - "Regras da barra travadas por teste nas duas telas (D-03, D-07, D-08, Pitfall 9)"
affects: [06-10]

plan_head_before: dfe7b4d730f7750c0c59d10b5b488e25dc98a79d
actuals:
  tokens: 7700   # chars/4 sobre as linhas adicionadas (git diff dfe7b4d..HEAD)
  tasks: 2
  commits: 2     # MEDIDO: git rev-list --count dfe7b4d..HEAD antes do commit do SUMMARY

tech-stack:
  added: []
  patterns:
    - "Rota do perfil e subarvore nova: o ContatoCubit e criado em abrirPerfilCorretor (BlocProvider create), getIt so ali e so com canais"
    - "Contexto do imovel viaja em memoria como entidade freezed (id, titulo, nomes de canal); nunca numero, e-mail ou link"

key-files:
  created:
    - lib/domain/entities/contato_do_imovel.dart
    - lib/domain/entities/contato_do_imovel.freezed.dart
  modified:
    - lib/presentation/detalhe_imovel/perfil_corretor_screen.dart
    - lib/presentation/detalhe_imovel/detalhe_imovel_screen.dart
    - test/presentation/detalhe_navegacao_test.dart
    - test/presentation/detalhe_imovel_screen_test.dart
    - test/presentation/perfil_corretor_screen_test.dart

key-decisions:
  - "Perfil sem imovel (ou com canais vazios) e montado exatamente como antes: sem BlocProvider, sem getIt, sem barra"
  - "Nenhuma mudanca de codigo em detalhe_imovel_screen.dart alem de passar o ContatoDoImovel: os testes de D-07 e Pitfall 9 passaram com a implementacao do 06-07"

requirements-completed: [APP06-C1, APP06-C3, APP06-C5, APP06-C6]

coverage:
  - id: E1
    description: "Do imovel ao perfil: perfil mostra 'Sobre: <titulo>' dentro de BarraContato; WhatsApp faz POST /api/publico/imoveis/<idCasa>/contato/ com {canal: WHATSAPP} sem authorization/cookie e o lancador recebe o link capturado"
    requirement: APP06-C5
    verification:
      - kind: widget
        ref: "test/presentation/detalhe_navegacao_test.dart 'perfil aberto a partir do imovel mostra \"Sobre: <titulo>\"...'"
        status: pass
    human_judgment: false
  - id: E2
    description: "Perfil: sem contato nao tem barra nem botao (T-04-08-01 intacto); com contato mostra Sobre/WhatsApp/⋮ e contatar(42, whatsapp); canais vazios sem barra e sem tocar o DI; titulo de 200 caracteres em 360 dp sem overflow; sem '@', 'creci', 'tel:', 'wa.me', 'mailto:'"
    requirement: APP06-C1
    verification:
      - kind: widget
        ref: "test/presentation/perfil_corretor_screen_test.dart 'barra de contato no perfil (APP 06, D-09, D-10)'"
        status: pass
    human_judgment: false
  - id: E3
    description: "Pagina: barra so em carregado com canais (inclusive sem corretor); legenda com o mesmo texto do cabecalho; VENDA_E_ALUGUEL curto mostra as duas linhas, longo so a principal (a outra so no topo); ausente em carregando/erro/404/sem canais; ultima secao acima da barra a 640 de altura; cartao leva ao perfil com 'Sobre: <titulo>' so com canais"
    requirement: APP06-C1
    verification:
      - kind: widget
        ref: "test/presentation/detalhe_imovel_screen_test.dart 'barra de contato (APP 06)'"
        status: pass
    human_judgment: false
  - id: E4
    description: "Aparencia real da barra no perfil (espaco, 2 linhas de titulo) no aparelho"
    requirement: APP06-C1
    verification: []
    human_judgment: true
    rationale: "Teste de widget nao julga layout fino; fica para a verificacao manual da fase (06-10)"
---

# Phase 6 Plan 09: Contato no perfil do corretor Summary

**O perfil do corretor aberto a partir de um imovel com canais mostra a mesma `BarraContato` com "Sobre: <titulo>" e o toque grava o contato no mesmo imovel (`POST /api/publico/imoveis/{id}/contato/`), sem mudar o model do servidor; as regras de visibilidade da barra nas duas telas estao travadas por testes de widget.**

## Performance

- **Duration:** ~25 min
- **Completed:** 2026-11-18
- **Tasks:** 2 (1 tracer, 1 auto/tdd)
- **Files modified:** 7 (2 criados, 5 modificados)

## Accomplishments

- `ContatoDoImovel` (freezed): `imovelId`, `titulo`, `canais` — so nomes de canal viajam na navegacao (D-02).
- `abrirPerfilCorretor(context, corretor, {contato, criarContatoCubit, construirImagemDeRede})`: com contato e canais, a rota envolve a tela em `BlocProvider<ContatoCubit>` (criado via `criarContatoCubit` ou `getIt`); sem eles, a tela e montada como antes, sem DI.
- `PerfilCorretorScreen.bottomNavigationBar = BarraContato(...)` com `Text('Sobre: ${titulo}', maxLines: 2, ellipsis)`; dartdocs reescritos (barra so quando aberto de um imovel; nunca numero, e-mail ou CRECI).
- `CartaoCorretor.aoTocar` passa `ContatoDoImovel(imovelId: detalhe.id, titulo: detalhe.titulo, canais: detalhe.canaisContato)` quando ha canais.
- Task 2: 11 novos testes de pagina (grupo 'barra de contato (APP 06)'), 6 de perfil; `pumpEstado` agora provê um `ContatoCubit` falso e aceita `largura`; teste D-12 renomeado para D-03 com as mesmas assercoes.

## Task Commits

1. **Task 1 (tracer): contato no perfil do corretor aberto a partir do imovel** - `1970434` (feat)
2. **Task 2: regras da barra de contato na pagina e no perfil** - `ff63780` (test)

Repo da API: nenhum commit (opcao-a). Nada de push.

## Verificacao

- `dart run build_runner build -d`: ok (gerou `contato_do_imovel.freezed.dart`).
- `flutter test test/presentation/detalhe_navegacao_test.dart`: 18 passaram; `--plain-name "perfil aberto a partir do imóvel"`: 1 passou.
- `flutter test test/presentation/perfil_corretor_screen_test.dart test/presentation/detalhe_imovel_screen_test.dart`: 10 + 48 passaram (inclui T-04-08-01).
- `--plain-name "barra de contato (APP 06)"`: 11 passaram.
- `flutter test` (suite inteira): 716 passaram. `flutter analyze`: sem issues.
- Verificacao "spec-less probe fallback": pulada no planejamento, conforme registrado no plano.

## Deviations from Plan

None - plan executed exactly as written. Os testes de D-07 e Pitfall 9 passaram com a implementacao existente do 06-07; nenhuma correcao em `_LegendaPrecoDaBarra` nem no `SliverPadding` foi necessaria. (Um erro de escopo do meu proprio teste - o botao "Abrir" da pagina-base entrava no finder de `FilledButton` - foi corrigido no mesmo teste, sem mudar codigo de producao.)

## Known Stubs

None.

## Threat Flags

None - sem superficie nova alem da coberta pelo threat model (T-06-09-01 a T-06-09-04 mitigados: `ContatoDoImovel` so com id/titulo/nomes de canal e teste sem '@'/'creci'/links; e2e afirma o id no path do POST; `getIt` so dentro de `abrirPerfilCorretor` e so com canais, provado por teste de canais vazios; testes de altura 640 e titulo de 200 caracteres a 360 dp).

## Recado para o Allysson (APP 07)

> Allysson, o componente de contato do APP 06 esta em `lib/presentation/contato/` (`BarraContato`, `ContatoCubit`, `mostrarContatoBottomSheet`). O perfil do corretor da branch `feat/APP06` ainda e a tela stub do APP 04. Quem fizer o merge por ultimo precisa plugar `BarraContato` na tela de perfil reescrita da `origin/feat/APP07`: a barra entra em `bottomNavigationBar` com `legenda: Text('Sobre: <titulo do imovel>')` e `abrirPerfilCorretor` recebe `contato: ContatoDoImovel(imovelId, titulo, canais)` e `criarContatoCubit` (o perfil e uma rota nova e nao herda o `ContatoCubit` da pagina, entao o `BlocProvider<ContatoCubit>` e criado na funcao de abertura). Sem imovel de origem (ex.: pagina da empresa) o perfil nao mostra barra nem botoes. Os testes `test/presentation/perfil_corretor_screen_test.dart` e `detalhe_navegacao_test.dart` ('perfil aberto a partir do imovel...') quebram se a barra for perdida no merge.

(Texto pronto para o usuario enviar no checkpoint do 06-10, Task 2, conforme D-11; o agente nao envia nada.)

## Issues Encountered

None.

## Self-Check: PASSED

- Arquivos presentes: contato_do_imovel.dart, contato_do_imovel.freezed.dart, perfil_corretor_screen.dart, detalhe_imovel_screen.dart e os tres arquivos de teste.
- Commits `1970434` e `ff63780` existem em feat/APP06; `git rev-list --count dfe7b4d..HEAD` = 2.
