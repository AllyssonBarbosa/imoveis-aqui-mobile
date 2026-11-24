---
phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09
plan: 13
subsystem: ui
tags: [flutter, dart, cubit, navigator, acervo, fluxo-ponta-a-ponta, requisitos]

requires:
  - phase: 09-mudança-de-situação (09-12)
    provides: recusas e falhas da mudança de situação; GestaoImovelState.mudou e registrarMudanca()
  - phase: 09-mudança-de-situação (09-02)
    provides: worktree ../imoveis-aqui-APP09 na feat/APP09 e a suíte Django com as travas das rotas do corretor
provides:
  - "AoAbrirGestao e abrirGestaoImovel devolvendo Future<bool> (o mudou lido do Cubit depois da volta)"
  - "AcervoCubit.recarregar(): relê a primeira página mantendo busca e situação"
  - "AcervoScreen recarregando o acervo da API só quando a gestão volta com true"
  - "fluxo ponta a ponta da volta ao acervo sobre a pilha real e o wire capturado"
  - "README com a seção Situação do imóvel (APP-09) e o roteiro de dados de teste sem senha"
  - "REQUIREMENTS com SIT-01..07, API-11 e API-12 Complete e ACV-04 superado pelo SIT-07"
affects: [UAT da fase 9, /gsd-verify-work 9, APP-12 (área do gestor)]

plan_head_before: 0c0303171799f4ef6242ceaf1f42e1f722d950be

actuals:
  tokens: 4200
  tasks: 2
  commits: 2

tech-stack:
  added: []
  patterns:
    - "o abridor da rota lê o estado do Cubit depois do push e devolve o resultado (vale para AppBar, botão voltar do sistema e gesto do iOS, que não passam resultado pelo pop); a tela não usa PopScope"
    - "corpo de lista derivado em memória de uma fixture capturada (cópia com o item em RESERVADO), nunca fixture nova escrita à mão"

key-files:
  created: []
  modified:
    - lib/presentation/gestao_imovel/gestao_imovel_screen.dart
    - lib/presentation/acervo/acervo_cubit.dart
    - lib/presentation/acervo/acervo_screen.dart
    - test/presentation/acervo_cubit_test.dart
    - test/presentation/acervo_screen_test.dart
    - test/presentation/gestao_imovel_screen_test.dart
    - test/presentation/gestao_imovel_fluxo_test.dart
    - README.md
    - .planning/REQUIREMENTS.md

key-decisions:
  - "A tela do acervo captura o AcervoCubit ANTES do await do abridor e confere mounted na volta (o contexto pode ter morrido enquanto a gestão estava aberta)"
  - "O chip do cartão depois da volta é o que o servidor mandou na nova consulta; o app não altera o item localmente (D-12, AC-2)"
  - "No fluxo, o chip 'Reservado' do cartão é buscado dentro do cartão (chave imovel-acervo-<id>), porque a barra de filtros do acervo também tem um chip 'Reservado'"

patterns-established:
  - "Abridor devolve Future<bool> lido do Cubit: o chamador decide recarregar sem depender de como o usuário voltou"

requirements-completed: [SIT-01, SIT-02, SIT-03, SIT-04, SIT-05, SIT-06, SIT-07, API-11, API-12]

coverage:
  - id: D1
    description: "Ao voltar da gestão depois de uma mudança (AppBar, botão voltar do sistema), o Meu acervo recarrega da API com a busca e a situação atuais; sem mudança, não recarrega"
    requirement: "SIT-05"
    verification:
      - kind: unit
        ref: "test/presentation/acervo_cubit_test.dart#recarregar (D-12) mantém a busca e a situação"
        status: pass
      - kind: unit
        ref: "test/presentation/acervo_screen_test.dart#volta da gestão (D-12)"
        status: pass
      - kind: unit
        ref: "test/presentation/gestao_imovel_screen_test.dart#abrirGestaoImovel devolve se mudou (D-12, A4)"
        status: pass
      - kind: e2e
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#volta ao acervo depois da gestão (D-12, SIT-05, AC-2, AC-5)"
        status: pass
    human_judgment: false
  - id: D2
    description: "O chip de situação do cartão depois da volta é o que o servidor mandou na nova consulta (corpo derivado de acervo_p1.json com o item 36 em RESERVADO), com o token só nas rotas autenticadas"
    requirement: "SIT-05"
    verification:
      - kind: e2e
        ref: "test/presentation/gestao_imovel_fluxo_test.dart#mudou e voltou pela AppBar: novo GET /api/imoveis/ sem page e o cartão mostra Reservado"
        status: pass
    human_judgment: false
  - id: D3
    description: "A metade do servidor do SIT-05/AC-5: a vitrine pública da cidade lista só disponível e publicado, e o detalhe público do reservado dá 404 (testes já na origin/main 8bf4448, rodados no worktree feat/APP09)"
    requirement: "SIT-05"
    verification:
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrinePublicaTests.test_vitrine_so_lista_disponivel_e_publicado"
        status: pass
      - kind: unit
        ref: "Web/imoveis/tests.py#VitrinePublicaTests.test_detalhe_de_imovel_fora_da_vitrine_da_404"
        status: pass
    human_judgment: false
  - id: D4
    description: "REQUIREMENTS: SIT-01..07, API-11 e API-12 marcados Complete; ACV-04 com a nota de superado pelo SIT-07; README com o roteiro de dados de teste sem senha"
    requirement: "API-12"
    verification:
      - kind: other
        ref: "grep dos nove IDs em REQUIREMENTS.md (checkbox [x] e linha da tabela Complete) + grep da seção do README"
        status: pass
    human_judgment: false
  - id: D5
    description: "Vitrine pública refletindo a mudança contra o Django real, recusa real do contrato assinado, colega sem botão, visual da tela e da folha, gesto de voltar do iOS, decisões D-17/D-18, assunções A3/A4 e a autorização de push"
    verification: []
    human_judgment: true
    rationale: "Depende de olho humano (visual Material 3, gesto do iOS) e do Django real com dados semeados; o roteiro está no human-check da Task 2 e na seção do README, para o UAT de fim de fase"

duration: 30min
completed: 2026-11-22
status: complete
---

# Phase 9 Plan 13: Volta ao acervo recarrega da API e fechamento da fase Summary

**Meu acervo relê a lista da API ao voltar da gestão com mudança (o abridor devolve o `mudou` lido do Cubit, valendo para AppBar, botão do sistema e gesto do iOS), com fluxo ponta a ponta sobre o wire capturado, README com o roteiro de teste e os nove requisitos da fase fechados**

## Performance

- **Duration:** ~30 min
- **Started:** ~2026-11-22T19:00:00Z (aproximado)
- **Completed:** 2026-11-22T19:35:00Z (aproximado)
- **Tasks:** 2
- **Files modified:** 9

## Accomplishments

- `AoAbrirGestao`/`abrirGestaoImovel` passam a devolver `Future<bool>`: depois do `push` o abridor lê `cubit.state.mudou`, fecha o Cubit e devolve o valor. Como o botão voltar do sistema e o gesto do iOS não passam resultado pelo `pop`, ler o Cubit cobre as três formas de voltar sem `PopScope` (que desligaria o gesto do iOS).
- `AcervoCubit.recarregar()` reaproveita `_aplicarConsulta(state.termoBusca, state.situacao)`: um carregando com a mesma busca e a mesma situação e a primeira página relida. `AcervoScreen` captura o Cubit antes do `await`, confere `mounted` e só recarrega com `true`.
- Fluxo ponta a ponta pela pilha real (cartão → abridor → Cubit → UseCase → Repository → DataSource → `Dio` autenticado) sobre a `ApiFalsa`: mudou e voltou pela AppBar (novo `GET /api/imoveis/` sem `page`, cartão "Reservado" vindo de um corpo derivado em memória de `acervo_p1.json`), mudou e voltou por `handlePopRoute`, e abrir e voltar sem mudar (nenhum `GET` novo). `conferirCabecalhosDeAutorizacao()` passa nos três.
- README: seção `### Situação do imóvel (APP-09)` com o que a fase entrega, o servidor do worktree `feat/APP09` (nunca o clone numa branch sem as rotas), os dados de teste sem nenhuma senha escrita (senha escolhida na hora e definida por variável de ambiente) e os cenários `DEV-*`, `DEV-CAMPINAS-14` e `DEMO-CASA-01`. O bullet do acervo da APP-08, que dizia que o cartão só abre a página pública, foi corrigido.
- REQUIREMENTS: SIT-01..07, API-11 e API-12 em `[x]` e `Complete` (SIT-03, SIT-04 e SIT-05 foram os que faltavam fechar aqui; os outros seis já tinham sido marcados pelos planos anteriores); ACV-04 com a nota "Superado na Phase 9 pelo SIT-07".

## Gates finais (D-16)

- App: `flutter analyze lib` limpo ("No issues found!"); `flutter test` inteiro verde, **1442 testes** (a linha de base citada no plano era 1194; a diferença vem dos planos 09-03..09-12 e dos 9 testes novos deste plano).
- Web, worktree `feat/APP09`: `manage.py test --noinput` verde, **753 testes** (743 da `origin/main` + 10 do 09-02), árvore limpa, nenhum `refs/remotes/origin/feat/APP09`; o clone `../imoveis-aqui` continua na `feat/APP06`.
- Evidência da metade do servidor do SIT-05/AC-5, rodados à parte no worktree (`Ran 2 tests ... OK`): `VitrinePublicaTests.test_vitrine_so_lista_disponivel_e_publicado` (a vitrine da cidade lista só o imóvel disponível e publicado; o reservado por `mudar_situacao` fica de fora) e `VitrinePublicaTests.test_detalhe_de_imovel_fora_da_vitrine_da_404` (o detalhe público do reservado dá 404), já na `origin/main` (`8bf4448`).
- Nenhum `git push` em nenhum dos dois repositórios; no app, branch `feat/APP09` e nenhum arquivo gerado (`*.freezed.dart`, `*.g.dart`, `injection.config.dart`) modificado.

## Task Commits

1. **Task 1: volta ao acervo recarrega da API (D-12) e fluxos ponta a ponta** - `3312cdb` (feat)
2. **Task 2: README, REQUIREMENTS e gates finais** - `3d54cd6` (docs)

**Plan metadata:** commit docs(09-13) deste SUMMARY e de STATE/ROADMAP (a seguir)

## Files Created/Modified

- `lib/presentation/gestao_imovel/gestao_imovel_screen.dart` - `AoAbrirGestao` e `abrirGestaoImovel` devolvem `Future<bool>` (o `mudou` do Cubit)
- `lib/presentation/acervo/acervo_cubit.dart` - `recarregar()` mantendo busca e situação
- `lib/presentation/acervo/acervo_screen.dart` - `_abrirGestao` recarrega o acervo só com `true` e a tela ainda montada
- `test/presentation/acervo_cubit_test.dart` - grupo `recarregar (D-12)`
- `test/presentation/acervo_screen_test.dart` - falsos do abridor devolvem `false` por padrão; grupo `volta da gestão (D-12)`
- `test/presentation/gestao_imovel_screen_test.dart` - grupo do abridor: AppBar, `handlePopRoute` e sem mudança, com o Cubit fechado em todos
- `test/presentation/gestao_imovel_fluxo_test.dart` - grupo da volta ao acervo sobre a pilha real
- `README.md` - seção `### Situação do imóvel (APP-09)`
- `.planning/REQUIREMENTS.md` - nove IDs Complete, nota no ACV-04, data da última atualização

## Decisions Made

- Cubit do acervo capturado antes do `await` e `mounted` conferido na volta, porque o `BuildContext` pode ter saído da árvore enquanto a gestão estava aberta.
- O app não altera o item localmente depois da mudança: o chip do cartão vem do corpo da nova consulta (T-09-03).
- Volta ao topo com o carregando aceita como comportamento do `recarregar()` (pergunta aberta 5 da pesquisa, resolvida na D-12).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug de teste] Chip "Reservado" ambíguo no fluxo**
- **Found during:** Task 1 (fluxo ponta a ponta)
- **Issue:** `find.text('Reservado')` achava dois widgets na volta: o chip do cartão e o chip de filtro "Reservado" da barra do acervo
- **Fix:** o finder passou a ser escopado ao cartão (`_chipDoCartao`, pela chave `imovel-acervo-<id>`)
- **Files modified:** test/presentation/gestao_imovel_fluxo_test.dart
- **Verification:** os três testes do grupo passam
- **Committed in:** 3312cdb

**2. [Rule 2 - Documentação desatualizada] Bullet do README da APP-08**
- **Found during:** Task 2
- **Issue:** o README da APP-08 ainda dizia que o cartão só abre a página do imóvel quando está na vitrine, o que o SIT-07 superou
- **Fix:** o bullet agora diz que o cartão abre a tela de gestão e que a página pública só abre por "Ver na vitrine"
- **Files modified:** README.md
- **Committed in:** 3d54cd6

---

**Total deviations:** 2 auto-fixed (1 teste, 1 documentação)
**Impact on plan:** sem mudança de escopo. O TDD foi seguido só em parte na Task 1: a implementação (pequena e já descrita no plano) foi escrita antes dos testes novos, que depois foram escritos e rodados verdes; não houve ciclo RED/GREEN com commits separados (o plano pede um commit por tarefa).

## Issues Encountered

- Nenhum problema de execução. Os seis IDs que o plano mandava marcar já estavam `Complete` (marcados pelos planos 09-01, 09-02 e seguintes); só SIT-03, SIT-04 e SIT-05 estavam pendentes.

## Known Stubs

Nenhum stub nos arquivos criados ou modificados.

## Threat Flags

Nenhuma superfície nova de segurança: nenhuma rota, caminho de autenticação ou esquema novo; `recarregar()` só repete a consulta autenticada que já existia.

## User Setup Required

None - nenhuma configuração de serviço externo. Para o UAT, os dados de teste e o servidor estão na seção `### Situação do imóvel (APP-09)` do README.

## Verificação humana de fim de fase (human-check da Task 2, para o UAT)

`workflow.human_verify_mode = end-of-phase`: o roteiro de 10 passos está no `<verify><human-check>` do `09-13-PLAN.md` e é consolidado pelo verificador. Resumo do que só uma pessoa confere: servidor do worktree `feat/APP09`; visual Material 3 da tela e da folha (D-01..D-12); reservar com observação e ver a tela, o histórico e o acervo recarregado (inclusive pelo botão voltar do Android e pelo gesto do iOS, A4); a vitrine pública da cidade sem o imóvel reservado e com ele de volta ao voltar a Disponível (AC-5 ponta a ponta); `DEV-CAMPINAS-14` sem botão; `DEMO-CASA-01` com a recusa do contrato assinado; servidor fora do ar e sessão revogada durante o envio; gestor no aviso (D-07); e decidir sobre o push das branches `feat/APP09` do app e da web e sobre pedir à equipe web o `max_length` da observação.

## Next Phase Readiness

- Todos os planos da fase 9 têm SUMMARY; a fase está pronta para `/gsd-verify-work 9` (UAT de fim de fase) e depois para decidir o push.
- Nada foi empurrado: o push das duas `feat/APP09` depende de autorização explícita do usuário.

## Self-Check: PASSED

- Arquivos modificados existem e os commits `3312cdb` e `3d54cd6` existem na `feat/APP09`.
- Critérios de aceite das duas tarefas rodados de novo: greps do `<verify>`, `flutter analyze lib`, `flutter test` (1442) e a suíte Django (753) todos verdes.

---
*Phase: 09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09*
*Completed: 2026-11-22*
