---
phase: 12-area-do-gestor-acompanhamento-dos-corretores
plan: 09
subsystem: presentation
tags: [roteamento-por-papel, area-gestor, fluxo-ponta-a-ponta, pilha-real, tdd, gates-finais, uat]

requires:
  - phase: 12
    provides: "12-08: AreaGestorScreen e as 4 seções; 12-07: AreaGestorCubit; 12-01..12-03: rotas /api/relatorios/ e fixtures do wire; sessão: EntradaAreaScreen, LoginScreen, PilhaReal e ApiFalsa"
provides:
  - "Papel.gestor => AreaGestorScreen na entrada pelo botão do topo e no destino do login; Papel.administrador => AvisoAreaScreen com título e mensagem próprios"
  - "area_gestor_fluxo_test.dart: 6 fluxos ponta a ponta sobre o DI de produção e o wire capturado (4 seções, token, período, falha por seção, 403, 401, corretor fora)"
  - "GES-01..GES-06, API-15 e API-16 fechados no REQUIREMENTS; gates finais da fase medidos nos dois repositórios"
  - "Roteiro de verificação humana (UAT) com e-mail e senha em cada passo de login, e o preparo do Postgres feito pelo Allysson"
affects: [verificação da fase 12, UAT de fim de fase]

# Medido: git rev-list --count ${PLAN_HEAD_BEFORE}..HEAD (ledger gsd-plan-head-before-12-09), antes do commit do SUMMARY
commits: 4
plan_head_before: b64a1de03bd5b4ba4b37b0081a54e13ed3705986
plan_head_after: e7c70d12c74cd306715dd6f36439ffd35e41f484

estimate_actuals_note: "tokens = chars/4 sobre o diff do plano (38345 chars, 551 linhas inseridas e 49 removidas em 10 arquivos, nenhum gerado)"
actuals:
  tokens: 9600
  tasks: 4
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Roteamento por papel em um switch exaustivo sobre Papel, repetido igual na entrada pelo topo e no destino do login"
    - "Fluxo ponta a ponta sobre o DI de produção trocando só os dois Dio e o ArmazenamentoToken; fixture do gestor pela sobrescrita da ApiFalsa"

key-files:
  created:
    - test/presentation/area_gestor_fluxo_test.dart
  modified:
    - lib/presentation/sessao/entrada_area_screen.dart
    - lib/presentation/login/login_screen.dart
    - lib/presentation/sessao/aviso_area_screen.dart
    - test/presentation/aviso_area_screen_test.dart
    - test/presentation/entrada_area_screen_test.dart
    - test/presentation/login_screen_test.dart
    - test/presentation/login_fluxo_test.dart
    - test/support/pilha_real.dart
    - .planning/REQUIREMENTS.md

key-decisions:
  - "O papel não é guardado no aparelho: a tela da área vem só do papel que GET /api/auth/eu/ devolve a cada entrada; o botão do topo continua dizendo 'Meu acervo' para qualquer sessão (D-01, D-04)"
  - "Administrador continua no aviso, agora 'Área do administrador' / 'A área do administrador não está no app.', com o mesmo Sair (D-02)"
  - "O preparo do Postgres do UAT (gestor da vitrine e seed_demo) só aconteceu no checkpoint blocking-human da Task 4, rodado pelo Allysson; nenhum agente tocou no banco nem na porta 8000 (D-31)"

patterns-established:
  - "Checkpoint blocking-human para escrita no banco do desenvolvedor: o script fica fora dos repositórios e o agente só confere a existência dele e a limpeza dos dois repos"

requirements-completed: [GES-01, GES-02, GES-03, GES-04, GES-05, GES-06, API-15, API-16]

coverage:
  - id: D1
    description: "Gestor entra na Área do gestor depois do login e pelo botão do topo; administrador cai no aviso 'Área do administrador'; corretor segue no Meu acervo"
    requirement: "GES-06"
    verification:
      - kind: unit
        ref: "flutter test test/presentation/entrada_area_screen_test.dart test/presentation/login_screen_test.dart test/presentation/aviso_area_screen_test.dart test/presentation/login_fluxo_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Ponta a ponta sobre o DI de produção: 4 seções com os números das fixtures, token em cada pedido, período pede de novo só os contatos, falha por seção isolada, 403 com texto fixo, 401 volta ao login deixando só a vitrine, corretor sem nenhum pedido a /api/relatorios/"
    requirement: "GES-01, GES-02, GES-03, GES-04, GES-05, GES-06"
    verification:
      - kind: integration
        ref: "flutter test test/presentation/area_gestor_fluxo_test.dart (6 testWidgets)"
        status: pass
    human_judgment: false
  - id: D3
    description: "REQUIREMENTS com GES-01..GES-06, API-15 e API-16 em [x] e Complete na tabela"
    requirement: "API-15, API-16"
    verification:
      - kind: other
        ref: "grep dos 8 IDs em .planning/REQUIREMENTS.md (Task 3, terceira verificação automatizada)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Gates finais da fase: analyze limpo, flutter test inteiro e suíte Django da feat/APP12"
    verification:
      - kind: other
        ref: "flutter analyze lib --no-fatal-infos; flutter test (1924); manage.py test --noinput com DATABASE_URL=sqlite://:memory: (803 OK)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Aparência da Área do gestor em aparelho real, comparação dos números com o painel do site e fluxos de login com os dados do Postgres do Allysson"
    verification: []
    human_judgment: true
    rationale: "Aparência, legibilidade e conferência contra o painel do site e o Postgres real não são asseridas por teste; fica para o roteiro humano deste SUMMARY, rodado pelo Allysson no UAT de fim de fase"

# Metrics
duration: ~25 min (trabalho do agente, sem a espera do checkpoint da Task 4)
completed: 2026-11-25
status: complete
---

# Phase 12 Plan 09: Ligação da Área do gestor ao app e gates finais Summary

**O gestor passa a cair na Área do gestor depois do login e pelo botão do topo (que segue "Meu acervo"), o administrador fica no aviso "Área do administrador", seis fluxos ponta a ponta sobre o DI de produção provam as 4 seções, o período, o 403 e o 401, os 8 requisitos da fase estão fechados, os gates finais passam nos dois repositórios sem nenhum push e o Allysson preparou o Postgres do UAT na Task 4.**

## Performance

- **Duration:** ~25 min de trabalho do agente (aproximado; não inclui a espera do checkpoint da Task 4)
- **Started:** 2026-11-25T21:47:00Z (primeiro commit RED às 18:47 -03:00)
- **Completed:** 2026-11-25T22:14:00Z (verificação da Task 4 e SUMMARY)
- **Tasks:** 4 (3 automáticas + 1 `checkpoint:human-action`)
- **Files modified:** 10 (1 criado, 9 modificados; nenhum gerado)

## Accomplishments

- **Roteamento por papel (Task 1, TDD):** `EntradaAreaScreen` e o destino do `LoginScreen` usam o mesmo `switch` sobre `Papel`: `Papel.gestor => const AreaGestorScreen()`, `Papel.administrador => AvisoAreaScreen`, corretor segue no "Meu acervo". O `AvisoAreaScreen` passou a ser só do administrador (título "Área do administrador", mensagem "A área do administrador não está no app.", mesmo botão Sair). Login e sessão não mudaram (D-01, D-02, D-04).
- **Ponta a ponta (Task 2):** `test/presentation/area_gestor_fluxo_test.dart`, 6 `testWidgets` sobre `PilhaReal.preparar` (DI de produção trocando só os dois `Dio` e o `ArmazenamentoToken`) com o wire capturado, `eu_gestor.json` pela sobrescrita da `ApiFalsa` e `conferirCabecalhosDeAutorizacao` cobrindo toda rota `/api/relatorios/`. Cobre as 4 seções com os números das fixtures, trocar o período pedindo de novo só os contatos, falha de uma seção sem derrubar as outras, 403 com "Só o gestor da imobiliária pode ver estes números.", 401 voltando ao login com "Sua sessão terminou. Entre de novo." (token nulo e só a vitrine embaixo) e o corretor sem nenhum pedido a `/api/relatorios/`.
- **REQUIREMENTS e gates finais (Task 3):** os 8 IDs em `[x]` e `Complete` na tabela; gates da fase rodados à mão (D-30), números abaixo.
- **Preparo do UAT (Task 4):** o Allysson rodou o script de preparo no Postgres dele; resultado abaixo.

## Gates finais medidos (D-30)

| Gate | Resultado |
|------|-----------|
| `flutter analyze lib --no-fatal-infos` | 0 errors, 0 warnings; 59 infos, todas o `deprecated_member_use` do import de `material.dart` (mesmo baseline do 12-08) |
| `flutter test` (inteiro) | 1924 testes, All tests passed (linha de base da fase: 1743; 1918 ao fim do 12-08) |
| Django, `feat/APP12`, `DATABASE_URL="sqlite://:memory:"` | 803 testes, OK |
| Push | nenhum nos dois repositórios: `origin/feat/APP12` não existe no app nem no repo web |
| `.claude/CLAUDE.md` | sem diff desde `439746a` |
| Repo web | na `feat/APP12`, `git status --porcelain` vazio |

## Task Commits

1. **Task 1 RED: testes de roteamento por papel** - `1dd0cd9` (test)
2. **Task 1 GREEN: gestor para a Área do gestor (entrada e login), administrador no aviso novo** - `9f75bc1` (feat)
3. **Task 2: fluxos ponta a ponta da Área do gestor sobre a pilha real** - `5aa8580` (test)
4. **Task 3: REQUIREMENTS completos** - `e7c70d1` (docs)
5. **Task 4: checkpoint humano, sem commit** (o script fica fora dos dois repositórios)

**Plan metadata:** commit `docs(12-09)` (este SUMMARY, STATE, ROADMAP e REQUIREMENTS)

## TDD Gate Compliance

- **RED (`1dd0cd9`):** os testes novos falharam por asserção (o gestor ainda ia para o aviso, o aviso ainda dizia o texto antigo), não por sintaxe nem fixture; o RED foi provado rodando os arquivos contra o código antigo. O `gsd_run check tdd-red-evidence` não foi usado: `flutter test` não emite nenhum dos formatos que o classificador aceita (mesmo critério do 12-03, 12-04, 12-07 e 12-08). Avaliação semântica: o alvo falhou pelo motivo planejado.
- **GREEN (`9f75bc1`):** os testes de roteamento, do aviso, do login e do fluxo de login passam.
- **Verificação por mutação:** feita; desfazer o roteamento do gestor (voltar ao aviso) faz os testes novos falharem de novo, então os testes protegem o comportamento.
- **REFACTOR:** nenhum.

A Task 2 (`5aa8580`) é só teste sobre código já ligado na Task 1, por desenho do plano.

## Task 4: preparo do UAT no Postgres do Allysson

`checkpoint:human-action` com `gate="blocking-human"`: o Allysson rodou o script `C:\Users\allys\OneDrive\Área de Trabalho\criar_gestor_vitrine.py`, que fica fora dos dois repositórios, por conta própria. Como o PowerShell não tem redirecionamento com `<`, ele usou o equivalente da forma do plano, na pasta `Web/` do repo web:

`.\venv\Scripts\python.exe manage.py shell -c "exec(open(r'C:\Users\allys\OneDrive\Área de Trabalho\criar_gestor_vitrine.py', encoding='utf-8').read())"`

Terminou sem erro. Saída informada por ele (só nomes, e-mails e empresa, mais as credenciais fixas de demonstração do próprio `seed_demo`):

- `Gestor da vitrine: Gestor Vitrine Demo <gestor.vitrine.demo@example.com> - criado`
- `Empresa da vitrine: Imobiliária Vitrine Demo (dev)`
- `seed_demo`: "Dados de teste prontos." e os 3 usuários: Gestor Demo `<gestor@demo.com>` - GESTOR - Imobiliaria Demo; Corretor Demo `<corretor@demo.com>` - CORRETOR - Imobiliaria Demo; Administrador `<admin@imoveisaqui.com>` - ADMINISTRADOR - (sem empresa).

Conferência do agente depois do "feito", sem tocar no banco e sem pedir nada à porta 8000 (um login criaria token no Postgres):

- o script existe fora dos dois repositórios (`test -f` encontrou o arquivo);
- `git -C "<repo web>" status --porcelain` vazio;
- o `git status --porcelain` do app lista só `.gsd/dispatch-isolation-sentinel.json` e `.planning/state.json` (arquivos de runtime do orquestrador), nunca o script.

Nenhum agente rodou o script, escreveu no Postgres ou fez requisição ao servidor da porta 8000.

## Roteiro de verificação humana (UAT de fim de fase)

**Nenhum passo deste roteiro foi executado por agente.** Todos são do Allysson, no UAT de fim de fase (modo `end-of-phase`); o resultado deve ser registrado na verificação da fase. O `runserver` do Allysson serve a pasta web, que está na `feat/APP12` (as rotas novas já valem); o app roda no emulador Android com a API em `http://10.0.2.2:8000`.

0. **Pré-requisito:** a Task 4 já foi feita (seção acima): o gestor `gestor.vitrine.demo@example.com` (senha `Teste12345`) existe na empresa da vitrine e o `seed_demo` rodou no Postgres dele.
1. No app, na vitrine: tocar "Entrar" e entrar com e-mail `corretor.vitrine.demo@example.com` e senha `Teste12345` → cai no "Meu acervo", nunca na Área do gestor. Abrir um imóvel DISPONÍVEL, "Mudar situação" → Reservado, observação "Teste APP-12", confirmar. Tocar Sair e confirmar.
2. Tocar "Entrar" e entrar com e-mail `gestor.vitrine.demo@example.com` e senha `Teste12345` → abre a "Área do gestor" (título e Sair na barra de cima), com as 4 seções nesta ordem: Totais da empresa por situação, Acervo por corretor, Contatos por corretor, Mudanças de situação — últimos 7 dias. No app: o Acervo por corretor mostra "Corretor Vitrine Demo" e "Corretor Desativado Demo (desativado)", e o rodapé "Total: N imóveis" dele é o mesmo N dos totais da seção de cima; a mudança do passo 1 aparece em Mudanças de situação com "Corretor Vitrine Demo" e a observação "Teste APP-12". Num navegador, entrar no painel do site com e-mail `gestor.vitrine.demo@example.com` e senha `Teste12345` e comparar só o que o painel já mostra: em Relatórios → Acervo ("Acervo por natureza e situação"), a linha "Total" (Disponível, Reservado, Vendido, Alugado e o total) bate com os 4 blocos e o "Total: N imóveis" da seção de totais do app; em Relatórios → Contatos ("Todo o período."), os "Contatos" e o "Aguardando retorno" de cada corretor e a linha Total batem com a seção Contatos por corretor do app. (O painel do site não tem acervo por corretor nem mudanças recentes — essas páginas ficaram fora da fase; esses dados são conferidos só no app.)
3. Na seção Contatos por corretor, tocar o chip "Período": abre o seletor em português; escolher um intervalo → só esta seção recarrega, o chip mostra as datas e a linha "Período: ... a ...."; o "x" volta para "Todo o período.".
4. Voltar (gesto ou botão) → vitrine; o botão do topo continua "Meu acervo"; tocar nele → Área do gestor de novo, recarregando as 4 seções.
5. Tocar Sair na Área do gestor, confirmar, tocar "Entrar" e entrar com e-mail `gestor@demo.com` e senha `SenhaForte123` → a Área do gestor mostra só a "Imobiliaria Demo" (Corretor Demo, DEMO-CASA-01), nada da empresa da vitrine.
6. Tocar Sair, confirmar, tocar "Entrar" e entrar com e-mail `admin@imoveisaqui.com` e senha `TrocarSenha123` → tela "Área do administrador" com "A área do administrador não está no app." e o botão Sair.
7. **Visual (UI contract D-05..D-23, Claude's Discretion):** verde e branco do tema; blocos 2×2 dos totais legíveis; cada seção num cartão; nomes e títulos longos quebram sem estourar; confirmar que o 403 ("Só o gestor da imobiliária pode ver estes números.") pode manter o "Tentar de novo" e os textos no singular ("1 imóvel", "1 contato", "último dia").
8. **Proibições (revisão humana):** a `feat/APP12` dos dois repositórios continua só local (sem push, PR ou merge); `.claude/CLAUDE.md` sem mudança; o script da Task 4 ficou fora dos repositórios.

## Files Created/Modified

- `lib/presentation/sessao/entrada_area_screen.dart` - `switch` por papel: gestor na Área do gestor, administrador no aviso, corretor no acervo
- `lib/presentation/login/login_screen.dart` - o mesmo roteamento por papel depois do login
- `lib/presentation/sessao/aviso_area_screen.dart` - aviso só do administrador, com o texto novo
- `test/presentation/area_gestor_fluxo_test.dart` - 6 fluxos ponta a ponta sobre a pilha real
- `test/presentation/entrada_area_screen_test.dart`, `login_screen_test.dart`, `aviso_area_screen_test.dart`, `login_fluxo_test.dart` - roteamento por papel, texto do aviso e login do gestor
- `test/support/pilha_real.dart` - `conferirCabecalhosDeAutorizacao` passa a exigir o token em toda rota `/api/relatorios/`
- `.planning/REQUIREMENTS.md` - 8 IDs completos, linha `Last updated`

## Decisions Made

- A tela da área vem só do papel devolvido por `GET /api/auth/eu/` a cada entrada; nada de papel guardado no aparelho (T-12-23).
- Administrador no aviso, sem acesso a números de empresa (T-12-24).
- O preparo do Postgres do UAT só no checkpoint `blocking-human`, pelas mãos do Allysson (T-12-26).

## Deviations from Plan

### Ajustes menores

**1. [Rule 1 - Bug de teste] Asserção negativa do aviso reescrita sem o literal proibido**
- **Found during:** Task 1 (GREEN)
- **Issue:** a asserção negativa em `aviso_area_screen_test.dart` (o texto antigo do gestor não existe mais) estava escrita com o literal proibido do texto antigo.
- **Fix:** a asserção foi reescrita sem o literal proibido (`find.text('Área do gestor')` e `find.textContaining('área do gestor')` com `findsNothing`), mantendo a mesma garantia.
- **Files modified:** `test/presentation/aviso_area_screen_test.dart`
- **Committed in:** `9f75bc1`

**2. [Rule 1 - Bug de teste] Caso do gestor em `login_screen_test.dart` usa `pump` em vez de `pumpAndSettle`**
- **Found during:** Task 1 (GREEN)
- **Issue:** as seções carregando da `AreaGestorScreen` mantêm o indicador animado, então `pumpAndSettle` não assenta.
- **Fix:** o caso do gestor usa `pump()` seguido de `pump(500 ms)`, com comentário no teste.
- **Files modified:** `test/presentation/login_screen_test.dart`
- **Committed in:** `9f75bc1`

---

**Total deviations:** 2 auto-fixed (2 ajustes de teste, nenhum em código de produção)
**Impact on plan:** nenhum; sem mudança de escopo.

## Issues Encountered

- O PowerShell não tem `<` para redirecionar o script para `manage.py shell`; o Allysson usou o `shell -c "exec(open(...).read())"`, equivalente à forma do plano. Funcionou sem erro.

## Known Stubs

Nenhum.

## Threat Flags

Nenhum. T-12-23 (corretor na área do gestor) mitigado: papel do servidor a cada entrada e fluxo do corretor sem pedido a `/api/relatorios/`; T-12-24 (administrador) pelo aviso próprio; T-12-25 (401/Sair deixando a área na pilha) pelo fluxo ponta a ponta do 401; T-12-26 (script no Postgres) pelo checkpoint `blocking-human` rodado pelo Allysson; T-12-SC sem pacote novo.

## User Setup Required

None - o preparo do Postgres (Task 4) já foi feito pelo Allysson.

## Next Phase Readiness

- Todos os planos da fase 12 têm SUMMARY; falta a verificação da fase, que deve juntar o roteiro humano acima no UAT de fim de fase.
- Sem bloqueios. A `feat/APP12` segue só local nos dois repositórios (sem push, PR ou merge, D-B).

## Self-Check: PASSED

- Arquivos: `area_gestor_fluxo_test.dart`, `entrada_area_screen.dart`, `login_screen.dart`, `aviso_area_screen.dart` e `pilha_real.dart` existem.
- Commits `1dd0cd9`, `9f75bc1`, `5aa8580` e `e7c70d1` são ancestrais de `HEAD`; `commits: 4` medido do ledger.
- Verificação da Task 4: script presente fora dos dois repositórios, repo web limpo, app sem o script na árvore.

---
*Phase: 12-area-do-gestor-acompanhamento-dos-corretores*
*Completed: 2026-11-25*
