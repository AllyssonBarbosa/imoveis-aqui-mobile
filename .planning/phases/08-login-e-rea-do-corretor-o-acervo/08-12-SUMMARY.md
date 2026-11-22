---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 12
subsystem: testing
tags: [flutter, widget-test, e2e, dio, get_it, readme, requirements]

requires:
  - phase: 08-02
    provides: "ArmazenamentoToken, InterceptadorSessao e o Dio 'autenticado'"
  - phase: 08-08
    provides: "ApiFalsa com rotas de auth e acervo, requisicoesGravadas, ArmazenamentoTokenEmMemoria"
  - phase: 08-10
    provides: "LoginScreen, AvisoAreaScreen, Sair com confirmacao"
  - phase: 08-11
    provides: "BotaoSessaoTopo, EntradaAreaScreen e SessaoCubit acima do MaterialApp"
provides:
  - "Fluxos ponta a ponta da fase pela pilha real do app sobre a ApiFalsa (13 testes)"
  - "PilhaReal: DI de producao com so os dois Dio e o ArmazenamentoToken trocados"
  - "ApiFalsa.responder(cabecalhos:) para o Retry-After do 429"
  - "README: secao Area do corretor (APP-08) com roteiro de dados de teste sem senha"
  - "ACV-01..04 marcados como completos; os 12 IDs da fase fechados"
affects: []

actuals:
  tokens: 28000
  tasks: 2
  commits: 2
plan_head_before: 36c0de7b9e989777a4956a9552197c334dd1d01e
plan_head_after: bcfc3293b6814d4e46a2d9487bb8f2372c6e70ea

tech-stack:
  added: []
  patterns:
    - "Fluxo ponta a ponta: configureDependencies() de producao e troca so do Dio publico, do Dio 'autenticado' e do ArmazenamentoToken antes de resolver qualquer DataSource"
    - "Conferencia de Authorization por requisicoesGravadas: login e rotas publicas sem token; eu, acervo e sair sempre com token"

key-files:
  created:
    - test/presentation/login_fluxo_test.dart
    - test/presentation/acervo_fluxo_test.dart
    - test/support/pilha_real.dart
  modified:
    - test/support/api_falsa.dart
    - README.md
    - .planning/REQUIREMENTS.md

key-decisions:
  - "A montagem da pilha real ficou num helper compartilhado (test/support/pilha_real.dart) em vez de duplicada nos dois arquivos de fluxo"
  - "Os fluxos do acervo entram pelo botao Meu acervo do topo com o token ja guardado, como o usuario faz, e nao montando a AcervoScreen direto"

patterns-established:
  - "PilhaReal.preparar(token:) + abrirApp(tester) + conferirCabecalhosDeAutorizacao() para qualquer fluxo futuro sobre a pilha real"

requirements-completed: [AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05, AUTH-06, ACV-01, ACV-02, ACV-03, ACV-04, API-09, API-10]

coverage:
  - id: D1
    description: "Abertura sem sessao: vitrine com Entrar e nenhum pedido a /api/auth/ nem a /api/imoveis/ (AC-6)"
    requirement: "AUTH-04"
    verification:
      - kind: automated_ui
        ref: "test/presentation/login_fluxo_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "Login do corretor ate Meu acervo e o voltar a vitrine; gestor no aviso; 400 e 429 com as mensagens fixas (AC-1, AC-3, D-02, D-04, D-B)"
    requirement: "AUTH-01"
    verification:
      - kind: automated_ui
        ref: "test/presentation/login_fluxo_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Acervo: p1, p2 pela URL next, busca DEV-CAMPINAS-14, chip Vendido sem resultado (AC-4)"
    requirement: "ACV-01"
    verification:
      - kind: automated_ui
        ref: "test/presentation/acervo_fluxo_test.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "Sair com confirmacao, tambem com 500 do servidor, e 401 no acervo voltando ao login com aviso (AC-2)"
    requirement: "AUTH-02"
    verification:
      - kind: automated_ui
        ref: "test/presentation/acervo_fluxo_test.dart"
        status: pass
    human_judgment: false
  - id: D5
    description: "Authorization so nas rotas autenticadas: login e rotas publicas sem token, eu/acervo/sair com token (T-08-45)"
    requirement: "AUTH-02"
    verification:
      - kind: automated_ui
        ref: "test/support/pilha_real.dart"
        status: pass
    human_judgment: false
  - id: D6
    description: "Emulador contra o Django real, iOS Keychain, limites de tentativas, aparencia e autofill, botao em 360 dp, push das branches e nota do CLAUDE.md"
    verification: []
    human_judgment: true
    rationale: "Dependem de aparelho, Mac M1, decisao de taxa e autorizacao do usuario; nenhum teste automatizado os afirma."

duration: 25min
completed: 2026-11-21
status: complete
---

# Phase 8 Plan 12: Fechamento da fase (fluxos ponta a ponta, README e requisitos) Summary

**Os seis criterios do card provados ponta a ponta pela pilha real do app (DI de producao, Cubits, repositorios, DataSources e InterceptadorSessao) sobre o wire capturado do Django, mais o README da area do corretor e os 12 requisitos da fase fechados.**

## Performance

- **Duration:** 25 min
- **Tasks:** 2
- **Files modified:** 6 (3 criados, 3 modificados)

## Accomplishments
- 13 testes de fluxo ponta a ponta: abertura sem pedido a `/api/auth/` nem a `/api/imoveis/` (AC-6); login do corretor ate "Meu acervo" e o "voltar" (AC-1, D-02); rolagem para a p2 pela URL `next`; busca `DEV-CAMPINAS-14`; chip "Vendido" sem resultado; Sair com confirmacao, tambem com 500 do servidor (AC-2); gestor no aviso (D-B); 400 e 429 com `Retry-After: 120` (AC-3, D-04); 401 no acervo voltando ao login com aviso e token apagado.
- Cabecalhos conferidos por `requisicoesGravadas` em todos os fluxos: o login e toda rota `/api/publico/...` (mesmo com sessao) sem `Authorization`; `eu`, `acervo` e `sair` sempre com `Token 000...0` (T-08-45).
- README com a secao "Area do corretor (APP-08)": o que a fase entrega, onde fica o token, como preparar dados no Django da `feat/APP08` sem senha no repositorio, o que conferir e os avisos do Sair (token unico) e do limite de tentativas.
- REQUIREMENTS: ACV-01..04 marcados como completos (AUTH-01..06, API-09 e API-10 ja estavam marcados pelos planos anteriores); `Last updated` atualizado.

## Task Commits

1. **Task 1: Fluxos ponta a ponta da fase** - `22eecd5` (test)
2. **Task 2: README, REQUIREMENTS e gates finais** - `bcfc329` (docs)

**Plan metadata:** commit docs(08-12) logo apos este arquivo.

## Files Created/Modified
- `test/presentation/login_fluxo_test.dart` (7 testes) - abertura, corretor, rotas publicas, gestor, 400, 429
- `test/presentation/acervo_fluxo_test.dart` (6 testes) - paginas, busca, situacao, Sair com e sem 500, 401
- `test/support/pilha_real.dart` - monta o DI de producao com so os dois `Dio` e o `ArmazenamentoToken` trocados; abre o app como o `main()`; confere os cabecalhos
- `test/support/api_falsa.dart` - `responder(...)` ganha `cabecalhos`
- `README.md` - secao "Area do corretor (APP-08)"
- `.planning/REQUIREMENTS.md` - ACV-01..04 completos

## Decisions Made
Ver `key-decisions` no cabecalho.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Caminho do repositorio web desatualizado**
- **Found during:** Task 2 (gates)
- **Issue:** os comandos do plano apontam para `C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui`, que nao existe.
- **Fix:** usado `C:/projetos/imoveis-aqui` (Django em `Web`), conforme orientacao do orquestrador.

**2. [Rule 3 - Blocking] Helper compartilhado em arquivo extra**
- **Issue:** o plano lista so tres arquivos de teste; montar a pilha real nos dois arquivos de fluxo duplicaria ~60 linhas.
- **Fix:** criado `test/support/pilha_real.dart`. Como o `instanceName: 'autenticado'` fica no helper, o `login_fluxo_test.dart` ganhou um teste proprio que afirma que o `Dio` autenticado e o publico sao instancias distintas no DI de producao (a checagem por `grep` do plano continua valida).

**3. [Rule 3 - Blocking] `flutter analyze lib` nao fica "No issues found!"**
- **Issue:** baseline de 38 `info` `deprecated_member_use` (`package:flutter/material.dart` esta deprecated no Flutter 3.47) em arquivos fora deste plano.
- **Fix:** nenhum, conforme orientacao do orquestrador. Este plano nao mexe em `lib/`: continuam 38 itens do mesmo tipo.

**4. [Rule 3 - Blocking] Ajustes de teste de widget**
- Os fluxos usam `pump` com duracoes fixas (nunca `pumpAndSettle`); "Vendido" fica fora da tela na linha rolavel de chips e precisa de `ensureVisible`; a entrada do acervo tem duas transicoes (entrada e substituicao pelo acervo), entao `abrirAcervo` espera 12 quadros de 100 ms.

**Total deviations:** 4 auto-fixed, 0 afetam o escopo.

## Issues Encountered
- O `dart format` do `api_falsa.dart` reformataria trechos antigos; o arquivo foi deixado com so a alteracao do plano. Nos tres arquivos novos o formato foi aplicado.

## Gates finais (D-18)

| Gate | Resultado |
|------|-----------|
| `flutter test` (app) | 1059 passando (1046 + 13 novos), 0 falhas |
| `flutter analyze lib` (app) | 38 `info` `deprecated_member_use` (baseline, nenhum tipo novo) |
| `manage.py test --noinput` (web, `DATABASE_URL="sqlite://:memory:"`) | 743 testes, OK |
| Repo web | arvore limpa, branch `feat/APP08` com 4 commits locais, sem `origin/feat/APP08` |
| Repo app | branch `feat/APP08`, nenhum gerado modificado; `origin/feat/APP08` existe, mas em `f5754dc docs(08): create phase plan` (anterior a execucao); os 37 commits de execucao da fase estao sem push |

Nenhum `git push` foi feito neste plano.

## Known Stubs
None.

## Threat Flags
None. Nenhum endpoint, caminho de autenticacao ou acesso a arquivo novo; o plano so adiciona testes e documentacao.

## Verificacao humana pendente (UAT de fim de fase)

Nada abaixo foi executado pelo executor; ficam para a pessoa:

1. **Emulador Android contra o Django real** da `feat/APP08` (`runserver 0.0.0.0:8000`, `10.0.2.2` no `ALLOWED_HOSTS`): abrir sem login cai na vitrine com "Entrar" (AC-6).
2. **Corretor da empresa demo:** "Entrar" leva a "Meu acervo"; "voltar" mostra a vitrine com "Meu acervo"; fechar e reabrir o app continua em "Meu acervo" (AC-1, AC-2, D-02).
3. **Acervo:** `DEV-*` com a marca "Seu" (menos `DEV-CAMPINAS-14`), rolagem infinita, busca `DEV-CAMPINAS-14`, chips de situacao, toque no cartao abre a pagina do imovel; conferir o visual Material 3 verde e branco do cartao compacto (AC-4).
4. **Erros de login e limite de tentativas (A1):** senha errada e e-mail inexistente mostram a mesma frase (AC-3); repetir ate o limite e decidir se `10/hour` por e-mail e `30/hour` por IP servem (`LOGIN_TAXA_POR_EMAIL` e `LOGIN_TAXA_POR_IP` mudam pelo `.env`).
5. **Outra empresa, gestor e administrador:** corretor B so ve `DEMO-CASA-01` (Vendido, sem toque) e nenhum `DEV-*` (AC-5); gestor e administrador caem em "A area do gestor ainda nao esta no app." com Sair (D-B).
6. **Sair em dois aparelhos:** Sair num deles; o outro volta ao login com "Sua sessao terminou. Entre de novo." ao tocar em "Meu acervo" (token unico, §14.4).
7. **iOS no Mac M1 (A3):** entrar, fechar e reabrir o app no simulador; se o token nao persistir, adicionar a capability Keychain Sharing pelo Xcode e registrar o achado.
8. **Aparencia e autofill:** aparencia das telas de login, aviso e acervo; oferta de preenchimento do gerenciador de senhas no login.
9. **Botao do topo a 360 dp:** conferir "Entrar"/"Meu acervo" ao lado do seletor de cidade em tela estreita (pendencia do 08-11).
10. **Push e PR (D-12):** autorizar ou nao o push das branches `feat/APP08` dos dois repositorios (nenhum plano fez push) e avisar o time da web que `GET /api/imoveis/` mudou de lista simples para envelope paginado.
11. **Nota do `.claude/CLAUDE.md`:** autorizar ou nao a atualizacao de uma linha em Supporting Libraries (`shared_preferences`): a frase que dispensa `flutter_secure_storage` ("no credentials, no login, nothing sensitive is stored") passa a dizer que a cidade continua em `shared_preferences` e que o token da API do corretor (APP-08) fica em `flutter_secure_storage` (D-D). Este plano nao editou o arquivo; o override segue registrado no 08-02 e aqui.

## Next Phase Readiness
- A fase 08 tem todos os planos executados e os 12 requisitos marcados; falta o UAT humano acima e a decisao de push/PR (D-12).

## Self-Check: PASSED
- Arquivos conferidos no disco; commits `22eecd5` e `bcfc329` presentes em `HEAD`.
