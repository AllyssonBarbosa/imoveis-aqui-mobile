---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 05
subsystem: auth
tags: [flutter, dio, freezed, repository, result, falhas-tipadas]

requires:
  - phase: 08-02
    provides: "ArmazenamentoToken, Dio @Named('autenticado') com InterceptadorSessao, SessaoExpiradaException, ApiFalsa com cabecalhos"
  - phase: 08-04
    provides: "fixtures reais login_200, erro_400_login, erro_401, eu_corretor, eu_gestor e a secao 14 do contrato"
provides:
  - "AutenticacaoDataSource/AutenticacaoRemoteDataSource: login no Dio publico; eu e sair no Dio autenticado (sair com 5 s)"
  - "EuModel.paraPapel -> Papel (corretor, gestor, administrador); papel desconhecido e FormatException"
  - "Falhas tipadas por status: CredenciaisInvalidas (400), LimiteTentativas(aguardar, 429), SemPermissao (403), FalhaDeConexao, SessaoExpirada (401)"
  - "AutenticacaoRepository/Impl: entrar guarda so o token; sair e descartarSessaoLocal nunca lancam"
  - "ApiFalsa serve as 3 rotas de auth e grava o corpo dos pedidos"
affects: [08-06, 08-07 use cases e SessaoCubit, 08-10 tela de login, 08-11, 08-12]

actuals:
  tokens: 14500
  tasks: 2
  commits: 2
plan_head_before: 64faa108468d36a97cbd10bbf1db62a632fae962
plan_head_after: e1ccef735518eefdf830f6a92914e2b031ed198a

tech-stack:
  added: []
  patterns:
    - "DataSource fina: nao captura DioException; o repositorio traduz por status em uma cadeia unica (_executar)"
    - "apagar do token isolado em _apagarTokenLocal (on Exception) usado no finally do sair e no descarte"
    - "falhas de dominio sem texto do servidor: a apresentacao escolhe a mensagem so pelo tipo"

key-files:
  created:
    - lib/domain/entities/papel.dart
    - lib/data/models/eu_model.dart
    - lib/data/models/eu_model.freezed.dart
    - lib/data/models/eu_model.g.dart
    - lib/data/datasources/autenticacao_datasource.dart
    - lib/data/datasources/autenticacao_remote_datasource.dart
    - lib/domain/repositories/autenticacao_repository.dart
    - lib/data/repositories/autenticacao_repository_impl.dart
    - test/data/autenticacao_remote_datasource_test.dart
    - test/data/autenticacao_repository_impl_test.dart
  modified:
    - lib/domain/repositories/falhas_autenticacao.dart
    - lib/di/injection.config.dart
    - test/support/api_falsa.dart

key-decisions:
  - "Retry-After limitado a 24 h em esperaDoLimite: um valor enorme nao estoura a Duration (T-08-29)"
  - "Leitura do Retry-After por headers['retry-after'].first em vez de headers.value(): value() lanca com mais de um valor"
  - "RequisicaoGravada da ApiFalsa passou a gravar o corpo (opcoes.data) para provar o {email, password} do login"

patterns-established:
  - "Quem traduz status em falha e so o repositorio; o texto do corpo da resposta nunca sobe"

requirements-completed: [AUTH-01, AUTH-02, AUTH-03, AUTH-05]

coverage:
  - id: D1
    description: "Login pelo Dio publico (sem Authorization mesmo com token guardado); so o token da resposta e guardado; senha sem trim"
    requirement: "AUTH-01"
    verification:
      - kind: unit
        ref: "test/data/autenticacao_remote_datasource_test.dart#login sem Authorization com token guardado"
        status: pass
      - kind: unit
        ref: "test/data/autenticacao_repository_impl_test.dart#sucesso salva só o token devolvido e devolve Success"
        status: pass
    human_judgment: false
  - id: D2
    description: "Falhas tipadas por status (400, 429 com Retry-After, 403, 401, rede/5xx) sem texto do servidor"
    requirement: "AUTH-03"
    verification:
      - kind: unit
        ref: "test/data/autenticacao_repository_impl_test.dart#nenhuma falha traduzida carrega o texto do servidor"
        status: pass
      - kind: unit
        ref: "test/data/autenticacao_repository_impl_test.dart#429 com retry-after: 120 traz aguardar de 120 s"
        status: pass
    human_judgment: false
  - id: D3
    description: "Sair e descartarSessaoLocal apagam o token e nunca lancam (rede, 401, Exception, PlatformException)"
    requirement: "AUTH-05"
    verification:
      - kind: unit
        ref: "test/data/autenticacao_repository_impl_test.dart#sair"
        status: pass
      - kind: unit
        ref: "test/data/autenticacao_repository_impl_test.dart#descartarSessaoLocal com apagar() lançando não lança"
        status: pass
    human_judgment: false
  - id: D4
    description: "Papel do usuario vindo do servidor; perfil desconhecido e FormatException"
    requirement: "AUTH-02"
    verification:
      - kind: unit
        ref: "test/data/autenticacao_remote_datasource_test.dart#perfil desconhecido lança FormatException"
        status: pass
    human_judgment: false

duration: 20 min
completed: 2026-11-21
status: complete
---

# Phase 08 Plan 05: Camada de dados da autenticacao Summary

**DataSource de login/eu/sair (login no Dio publico, o resto no autenticado), `EuModel` -> `Papel` e `AutenticacaoRepositoryImpl` que traduz 400/429(Retry-After)/403/401/rede em falhas tipadas sem texto do servidor e cujo `sair`/`descartarSessaoLocal` nunca lancam, nem com `apagar()` lancando `PlatformException`.**

## Performance

- **Duration:** 20 min
- **Tasks:** 2
- **Files modified:** 13 (10 criados, 3 alterados)

## Accomplishments

- `AutenticacaoRemoteDataSource` fina: login por `_dioPublico` (nunca leva `Authorization`), `eu`/`sair` por `_dioAutenticado`, Sair com 5 s de limite.
- `EuModel` freezed com `paraPapel()`; `ApiFalsa` com as 3 rotas de auth (401 sem `Authorization: Token`) e corpo gravado nos pedidos.
- Cinco falhas tipadas em `falhas_autenticacao.dart`, todas `const`, com `toString` fixo.
- `AutenticacaoRepositoryImpl`: cadeia `_executar`, `esperaDoLimite`, `_apagarTokenLocal` (tolera `PlatformException`), `sair` com `finally`.
- 38 testes novos (13 do DataSource/EuModel, 25 do repositorio); suite completa: 856 verdes (818 + 38).

## Task Commits

1. **Task 1: DataSource de autenticacao, EuModel -> Papel e rotas de auth na ApiFalsa** - `872ec2d` (feat)
2. **Task 2: Falhas tipadas e AutenticacaoRepositoryImpl** - `e1ccef7` (feat)

**Plan metadata:** commit docs(08-05) logo apos este arquivo.

## Decisions Made

- `esperaDoLimite` limita o `Retry-After` a 24 h (alem do que o plano pedia: nulo para ausente/nao numerico/negativo), porque um inteiro enorme estouraria a `Duration`.
- O `Retry-After` e lido por `headers['retry-after']?.first` e nao por `headers.value(...)`, que lanca com mais de um valor.
- `RequisicaoGravada` da `ApiFalsa` ganhou o campo `corpo`, necessario para conferir `{email, password}` e a senha sem `trim`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Caminho do repo web desatualizado**
- **Found during:** leitura do plano
- **Issue:** o plano cita um caminho antigo do repo web; este plano nao toca o repo web, entao nao houve substituicao necessaria (registrado conforme as instrucoes do orquestrador).

**2. [Rule 2 - Critical] Limite superior no Retry-After**
- **Found during:** Task 2
- **Issue:** `Duration(seconds: int64max)` estoura em plataformas nativas (T-08-29).
- **Fix:** `esperaDoLimite` devolve no maximo 24 h; teste cobre o valor hostil.
- **Files modified:** lib/data/repositories/autenticacao_repository_impl.dart, test/data/autenticacao_repository_impl_test.dart
- **Commit:** e1ccef7

**3. [Rule 3 - Blocking] Corpo dos pedidos nao era gravado pela ApiFalsa**
- **Found during:** Task 1
- **Fix:** campo opcional `corpo` em `RequisicaoGravada` (o plano previa essa alternativa).
- **Commit:** 872ec2d

Observacoes sem desvio:
- Os gerados (`*.freezed.dart`/`*.g.dart`) que mudaram so de quebra de linha foram restaurados com `git checkout --`; ficaram apenas `eu_model.*` (novos) e `injection.config.dart` (10 linhas reais).
- `flutter analyze lib` segue com os 30 `info` `deprecated_member_use` anteriores (arquivos de fora desta fase); nenhum nos arquivos novos ou alterados.
- Tasks `tdd="true"` em plano `type: execute`: um commit por task, teste escrito junto da implementacao.
- O 429 do login traz `Retry-After` (ate 3600 s) e o 401 de um Sair repetido e tratado como sucesso (o `sair()` engole qualquer `Exception`), conforme as notas do 08-03.

## Issues Encountered

None.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None - superficie exatamente a do `<threat_model>` (T-08-24 a T-08-29, T-08-SC), todas mitigadas.

## Next Phase Readiness

Pronto para o 08-06/08-07: o contrato `AutenticacaoRepository` ja garante que `sair` e `descartarSessaoLocal` nunca lancam, e `obterPapel` devolve `FormatException` para papel desconhecido (o rollback fica no `EntrarUseCase`).

## Self-Check: PASSED

- Arquivos criados existem; commits `872ec2d` e `e1ccef7` no ramo `feat/APP08`.
- `flutter test`: 856 verdes; `flutter analyze` dos arquivos novos limpo; gates de grep do plano OK.
