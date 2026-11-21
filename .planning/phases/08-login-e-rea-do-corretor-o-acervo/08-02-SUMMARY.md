---
phase: 08-login-e-rea-do-corretor-o-acervo
plan: 02
subsystem: auth
tags: [flutter, dio, flutter_secure_storage, interceptor, token, sessao]

requires:
  - phase: 07
    provides: "POST /api/auth/login/ (token) no repo web; Dio publico e DI via injectable"
provides:
  - "ArmazenamentoToken (ler/salvar/apagar) com impl segura em Keychain/Keystore e fake em memoria para testes"
  - "Dio @Named('autenticado') com InterceptadorSessao: Authorization so na mesma origem, 401 vira SessaoExpiradaException"
  - "construirDioAutenticado compartilhado entre producao e ApiFalsa; ApiFalsa grava metodo e cabecalhos"
affects: [08-03, 08-05 repositorio de autenticacao, 08-08 acervo no app, 08-12 human-check]

actuals:
  tokens: 7250
  tasks: 2
  commits: 2
plan_head_before: 428c804c0a6e00c6ec41a5fb0a45802810edd53a
plan_head_after: 7a81892fcab7841e892af781cf1504ed202b90ab

tech-stack:
  added: ["flutter_secure_storage ^11.2.0 (resolvido 11.2.0)"]
  patterns:
    - "token atras de interface propria (ArmazenamentoToken) com fake de teste; nenhum teste toca o canal de plataforma"
    - "segundo Dio nomeado no DI; o publico continua sem interceptor"
    - "compare-and-delete do token no 401 via RequestOptions.extra['token_usado']"
    - "funcao de topo construirDioAutenticado usada pela producao e pela ApiFalsa"

key-files:
  created:
    - lib/data/datasources/armazenamento_token.dart
    - lib/data/datasources/armazenamento_token_seguro.dart
    - lib/data/network/mesma_origem.dart
    - lib/data/network/interceptador_sessao.dart
    - lib/domain/repositories/falhas_autenticacao.dart
    - test/support/armazenamento_token_em_memoria.dart
    - test/data/armazenamento_token_seguro_test.dart
    - test/data/interceptador_sessao_test.dart
  modified:
    - pubspec.yaml
    - pubspec.lock
    - android/app/src/main/AndroidManifest.xml
    - lib/di/modulo_rede.dart
    - lib/di/injection.config.dart
    - test/support/api_falsa.dart

key-decisions:
  - "Sem .entitlements nem edicao do project.pbxproj no iOS (A3): persistencia do Keychain no iOS fica para o human-check de fim de fase num Mac (08-12)"
  - "ler() do armazenamento seguro e fail-closed (PlatformException -> null); salvar/apagar deixam a excecao subir para o chamador decidir"
  - "401 sem token_usado (pedido feito sem token) nunca apaga o token guardado: so apaga se o token usado for igual ao atual"
  - ".claude/CLAUDE.md nao editado: a nota sobre flutter_secure_storage (D-D a substitui) e pedida ao usuario no 08-12"

patterns-established:
  - "Quem precisa do token usa o Dio @Named('autenticado'); o Dio publico (vitrine, login) nunca leva Authorization"
  - "Falha de sessao e tipada (SessaoExpiradaException em falhas_autenticacao.dart); o 08-05 acrescenta as demais neste arquivo"

requirements-completed: [AUTH-02]

coverage:
  - id: D1
    description: "Token guardado so no armazenamento seguro, atras de ArmazenamentoToken; leitura ilegivel vira sem sessao; allowBackup desligado no Android"
    requirement: "AUTH-02"
    verification:
      - kind: unit
        ref: "test/data/armazenamento_token_seguro_test.dart"
        status: pass
      - kind: command
        ref: "grep -q 'android:allowBackup=\"false\"' android/app/src/main/AndroidManifest.xml"
        status: pass
    human_judgment: false
  - id: D2
    description: "Authorization: Token so no Dio autenticado e so para a origem da API; Dio publico sem interceptor; sem LogInterceptor em lib/"
    requirement: "AUTH-02"
    verification:
      - kind: unit
        ref: "test/data/interceptador_sessao_test.dart#InterceptadorSessao"
        status: pass
      - kind: unit
        ref: "test/data/interceptador_sessao_test.dart#registro no DI de produção"
        status: pass
    human_judgment: false
  - id: D3
    description: "401 vira SessaoExpiradaException com compare-and-delete; PlatformException do apagar() nao impede a falha tipada; sem redirecionamento"
    requirement: "AUTH-02"
    verification:
      - kind: unit
        ref: "test/data/interceptador_sessao_test.dart#401 atrasado de um token antigo não apaga o token novo"
        status: pass
      - kind: unit
        ref: "test/data/interceptador_sessao_test.dart#PlatformException ao apagar não impede a falha tipada"
        status: pass
    human_judgment: false
  - id: D4
    description: "Persistencia real do token no Keychain do iOS e no Keystore do Android entre aberturas do app"
    requirement: "AUTH-02"
    human_judgment: true
    rationale: "Depende do SO do aparelho (Keychain num Mac M1, Keystore num emulador/aparelho); nenhum teste automatizado atravessa o canal de plataforma. Coberto pelo human-check do 08-12."

duration: 10 min
completed: 2026-11-21
status: complete
---

# Phase 08 Plan 02: Infra de sessao do app Summary

**Token da API no Keychain/Keystore (`flutter_secure_storage ^11.2.0`) atras de `ArmazenamentoToken`, e um segundo `Dio` `@Named('autenticado')` cujo `InterceptadorSessao` leva `Authorization: Token` so para a origem da API e transforma todo 401 em `SessaoExpiradaException` com compare-and-delete.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-11-21T13:01:29Z
- **Completed:** 2026-11-21T13:11Z
- **Tasks:** 2
- **Files modified:** 14 (8 criados, 6 alterados)

## Accomplishments

- Armazenamento do token atras de interface propria, com a impl segura fail-closed na leitura e um fake em memoria para todos os testes.
- `android:allowBackup="false"` no manifest principal (o backup nao restaura mais uma chave do Keystore que nao abre).
- `InterceptadorSessao`: Authorization so na mesma origem da base URL (remove qualquer Authorization nas outras), 401 tipado, compare-and-delete e `apagar()` tolerante a `PlatformException`.
- `construirDioAutenticado` (sem redirecionamento, mesmos timeouts) e `Dio` `@Named('autenticado')` no DI; o `Dio` publico ficou identico.
- `ApiFalsa` passa a gravar metodo e cabecalhos (`requisicoesGravadas`) e a criar o Dio autenticado de producao (`criarDioAutenticado`).
- 20 testes novos (5 do armazenamento, 15 do interceptador/DI): suite completa em 794 verdes (774 + 20).

## Task Commits

1. **Task 1: flutter_secure_storage atras de ArmazenamentoToken, allowBackup desligado e fake em memoria** - `0996f06` (feat)
2. **Task 2: Dio @Named('autenticado') com InterceptadorSessao e ApiFalsa gravando cabecalhos** - `7a81892` (feat)

**Plan metadata:** commit docs(08-02) logo apos este arquivo.

## Decisions Made

- iOS sem `.entitlements`/`pbxproj` (A3 da pesquisa): o app nao usa App Group, o Keychain usa o grupo padrao; editar o `pbxproj` no Windows, as cegas, arriscaria quebrar o build iOS. Verificacao no Mac M1 no human-check do 08-12.
- Um 401 de pedido feito sem token (`token_usado` ausente) nao apaga o token guardado: protege um login novo que chegou no meio do caminho.
- `.claude/CLAUDE.md` nao foi editado (arquivo compartilhado da equipe); a nota sobre `flutter_secure_storage` precisa de autorizacao do usuario no 08-12, item 9.

## Deviations from Plan

None - plan executed exactly as written.

Observacoes sem desvio:
- `flutter analyze lib` reporta 30 `info` `deprecated_member_use` (`package:flutter/material.dart` esta marcado como obsoleto no Flutter 3.47) em arquivos que este plano nao tocou; nenhum nos arquivos novos ou alterados (`flutter analyze` dos testes novos e de `test/support` sai limpo). Sao anteriores ao plano e fora do escopo; nao corrigidos.
- Tasks `tdd="true"` em plano `type: execute`: o teste foi escrito primeiro e visto falhar (Task 1: "Method not found: ArmazenamentoTokenSeguro") e a implementacao veio depois, com um commit por task (como pede o plano), sem commits separados de RED/GREEN.
- O `pubspec.lock` commitado inclui a entrada transitiva `listen` pendente de um `flutter pub get` anterior, como autorizado pelo orquestrador.
- O repo web citado no plano nao foi usado por este plano.

## Issues Encountered

None.

## Authentication Gates

None.

## Known Stubs

None.

## Threat Flags

None - a superficie nova (Dio autenticado, armazenamento do token) e exatamente a do `<threat_model>` do plano (T-08-07 a T-08-12, T-08-49, T-08-SC), todas mitigadas.

## Next Phase Readiness

Pronto para os planos seguintes da fase: o repositorio de autenticacao (08-05) usa `ArmazenamentoToken` e acrescenta as demais falhas em `falhas_autenticacao.dart`; as rotas autenticadas usam `getIt<Dio>(instanceName: 'autenticado')`. Pendente no 08-12: persistencia do Keychain no iOS num Mac M1 e o pedido de atualizacao da nota do `.claude/CLAUDE.md`.

## Self-Check: PASSED

- Arquivos criados e alterados existem em disco; commits `0996f06` e `7a81892` no ramo `feat/APP08`.
- `flutter test` inteiro: 794 verdes; `flutter analyze` dos arquivos novos limpo; gates de grep do plano OK; nenhum `*.freezed.dart`/`*.g.dart` modificado.
