---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 03
subsystem: api
tags: [django, drf, throttling, token-auth, login, seguranca]

requires:
  - phase: 08-01
    provides: "acervo do corretor em GET /api/imoveis/ e AcervoApiTests (faz POST em api-login)"
  - phase: 07
    provides: "POST /api/auth/login/ (token) no repo web"
provides:
  - "Limite de tentativas no login da API em dois baldes (e-mail por SHA-256 e IP), 429 com Retry-After"
  - "LOGIN_TAXA_POR_EMAIL (10/hour) e LOGIN_TAXA_POR_IP (30/hour) validadas na partida"
  - "Login imune a token velho no cabecalho (authentication_classes = [])"
  - "GET /api/auth/eu/ devolve so {perfil}; POST /api/auth/sair/ revoga o token (204)"
affects: [08-05 repositorio de autenticacao no app, 08-04 contrato §14, 08-12 human-check]

actuals:
  tokens: 9500
  tasks: 2
  commits: 2
plan_head_before: ed251b1c72e0b64fc9bc9dcf741599e25a25d2f8
plan_head_after: abaf9fe06844ae28bf2e7a8d47ae5c4156c54301

tech-stack:
  added: []
  patterns:
    - "SimpleRateThrottle por escopo com chave de cache por hash (e-mail nunca em texto)"
    - "fixar_taxa_alta_no_login(teste): cache.clear + mock.patch.object(rate) nos throttles do login, molde de fixar_taxa_alta"
    - "rotas do app so com TokenAuthentication (sem sessao nem CSRF)"

key-files:
  created: []
  modified:
    - "C:/projetos/imoveis-aqui/Web/core/throttles.py"
    - "C:/projetos/imoveis-aqui/Web/config/settings.py"
    - "C:/projetos/imoveis-aqui/Web/.env.example"
    - "C:/projetos/imoveis-aqui/Web/contas/api/views.py"
    - "C:/projetos/imoveis-aqui/Web/contas/api/urls.py"
    - "C:/projetos/imoveis-aqui/Web/contas/tests.py"
    - "C:/projetos/imoveis-aqui/Web/imoveis/tests.py"
    - "C:/projetos/imoveis-aqui/README.md"

key-decisions:
  - "Taxas 10/hour por e-mail e 30/hour por IP (A1), por variavel de ambiente: reversivel sem codigo; confirmar no human-check do 08-12"
  - "eu devolve so {perfil} (nao reutiliza UsuarioSerializer, que expoe e-mail e empresa)"
  - "Sair apaga todos os tokens do usuario (filter.delete), nao so request.auth: token unico por usuario desconecta todos os aparelhos"
  - "ThrottleLoginPorEmail devolve chave None se o corpo nao for objeto ou nao tiver e-mail; o 400 do serializer responde"

patterns-established:
  - "Todo teste que faz POST em api-login chama fixar_taxa_alta_no_login (ou o equivalente) no setUp"

requirements-completed: [AUTH-06, AUTH-05, AUTH-02, AUTH-03, API-10]

coverage:
  - id: D1
    description: "Login limita tentativas por e-mail (hash) e por IP: 429 com Retry-After e detail, igual para e-mail existente ou nao"
    requirement: "AUTH-06"
    verification:
      - kind: unit
        ref: "Web/contas/tests.py#LoginLimiteDeTentativasTests"
        status: pass
    human_judgment: false
  - id: D2
    description: "Token revogado no cabecalho nao derruba o login (200 com senha certa, 400 com errada, nunca 401)"
    requirement: "AUTH-03"
    verification:
      - kind: unit
        ref: "Web/contas/tests.py#LoginApiTests"
        status: pass
    human_judgment: false
  - id: D3
    description: "GET /api/auth/eu/ devolve exatamente {perfil}; sem token ou so com sessao do site e 401"
    requirement: "AUTH-05"
    verification:
      - kind: unit
        ref: "Web/contas/tests.py#EuApiTests"
        status: pass
    human_judgment: false
  - id: D4
    description: "POST /api/auth/sair/ apaga o token (204); a chave antiga da 401 e um novo login gera chave nova"
    requirement: "AUTH-02"
    verification:
      - kind: unit
        ref: "Web/contas/tests.py#SairApiTests"
        status: pass
    human_judgment: false
  - id: D5
    description: "Suite Django inteira verde sem depender da taxa do ambiente"
    requirement: "API-10"
    verification:
      - kind: command
        ref: "manage.py test --noinput (743 testes)"
        status: pass
    human_judgment: false

duration: 15 min
completed: 2026-11-21
status: complete
---

# Phase 08 Plan 03: Seguranca do login e rotas eu/sair na API Summary

**Login da API com limite de tentativas por e-mail (chave SHA-256) e por IP (429 + Retry-After, resposta igual para e-mail existente ou nao), login imune a token velho, `GET /api/auth/eu/` com so `{perfil}` e `POST /api/auth/sair/` que apaga o token no servidor.**

## Performance

- **Duration:** 15 min
- **Started:** 2026-11-21T13:13Z
- **Completed:** 2026-11-21
- **Tasks:** 2
- **Files modified:** 8 (todos no repo web)

## Accomplishments

- `ThrottleLoginPorEmail` e `ThrottleLoginPorIp` em `core/throttles.py`, antes do `authenticate()`; taxas em `LOGIN_TAXA_POR_EMAIL`/`LOGIN_TAXA_POR_IP`, validadas na partida como `VITRINE_TAXA_ANONIMA`.
- `LoginAPIView` com `authentication_classes = []` (token revogado no cabecalho nao da 401) e os dois throttles.
- `EuAPIView` e `SairAPIView` so com `TokenAuthentication`; rotas `api-eu` e `api-sair`.
- README da web com as duas rotas novas, o limite do login e as variaveis de taxa; `.env.example` com as duas linhas.
- 29 testes novos na web (suite total 743 verdes; eram 719); app: `flutter test` 794 verdes e `flutter analyze lib` com os mesmos 30 `info` pre-existentes (nada do app mudou).

## Task Commits (repo web, branch feat/APP08, nada enviado)

1. **Task 1: limite de tentativas no login por e-mail e por IP** - `036d2aa` (feat)
2. **Task 2: rotas quem sou eu e sair (revoga o token)** - `abaf9fe` (feat)

**Plan metadata:** commit docs(08-03) no repo do app logo apos este arquivo.

## Decisions Made

- Taxas `10/hour` e `30/hour` (A1): o balde por e-mail freia forca bruta; o por IP acomoda NAT de escritorio. Mudam por `.env`.
- `eu` nao reutiliza `UsuarioSerializer` (expoe e-mail e empresa): devolve so o papel.
- Sair usa `Token.objects.filter(user=request.user).delete()`; consequencia aceita (D-A): desconecta os outros aparelhos do mesmo corretor, o site (sessao) nao e afetado.

## Deviations from Plan

### Ajustes de ambiente (sem mudar o plano)

- **Caminho do repo web:** o caminho do plano (`C:/Users/allys/OneDrive/Área de Trabalho/Imoveis-aqui`) e obsoleto; usado `C:/projetos/imoveis-aqui` (instrucao do orquestrador), em `files_modified`, preconditions e comandos de verificacao.
- **Gate de verificacao de `origin/feat/APP08`:** conferido com `git rev-parse --verify -q origin/feat/APP08` (nao existe), arvore limpa e `Web/requirements.txt` sem diferenca contra `d9ddd8f`.

Fora isso, plano executado como escrito. Tasks `tdd="true"` em plano `type: execute`: RED visto antes (Task 1: `ImportError` de `ThrottleLoginPorEmail`; Task 2: `NoReverseMatch` de `api-eu`), um commit por task.

## Issues Encountered

None.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None - a superficie nova (login limitado, `eu`, `sair`) e a do `<threat_model>` do plano (T-08-13 a T-08-18, T-08-SC mitigadas; T-08-19 e T-08-20 aceitas e a registrar no 08-04).

## Next Phase Readiness

O app (08-05) pode chamar `GET /api/auth/eu/` para rotear por papel e `POST /api/auth/sair/` para revogar (tratando 401 de repeticao como sucesso), e deve tratar o 429 do login usando `Retry-After` (ate 3600 s). Pendente: confirmar as taxas A1 no human-check do 08-12 e registrar os riscos aceitos (bloqueio dirigido de e-mail, CGNAT, `LocMemCache` por processo) no §14.8 do contrato (08-04).

## Self-Check: PASSED

- Commits `036d2aa` e `abaf9fe` existem no repo web em `feat/APP08` (4 commits sobre `d9ddd8f`), arvore limpa, sem `origin/feat/APP08`.
- `manage.py test --noinput`: 743 testes OK; `flutter test`: 794 verdes.
