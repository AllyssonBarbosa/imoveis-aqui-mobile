---
phase: 02-vitrine-lista-busca-e-ordena-o
plan: 04
subsystem: api
tags: [dio, cursor-pagination, injectable, di, android-manifest, ios-ats, readme]

# Dependency graph
requires:
  - phase: 02-vitrine-lista-busca-e-ordena-o
    provides: "02-02: GET /api/publico/cidades/ real no repo irmão (AllowAny, cursor page_size=50, servido-only) + seed semear_vitrine_dev"
provides:
  - "CidadeRemoteDataSource (Dio) consumindo GET /api/publico/cidades/ com base URL configurável via --dart-define=API_BASE_URL (D-17)"
  - "Asset local assets/cidades.json e CidadeLocalDataSource removidos — fonte única da verdade (D-16)"
  - "Cidade salva entra direto na vitrine mesmo com GET /cidades fora do ar (D-16, F1/D-08)"
  - "Estado de lista de cidades vazia com mensagem própria + Tentar de novo (D-16)"
  - "Rede nativa liberada para o servidor de dev: INTERNET no manifest principal, cleartext só em debug, NSAllowsLocalNetworking no iOS (D-17)"
  - "README documentando API_BASE_URL (emulador/simulador/aparelho) e como subir o Django de dev"
affects: ["04 (endpoint real de /imoveis herda o mesmo padrão de CidadeRemoteDataSource/ModuloRede)"]

# Actuals (#2632)
actuals:
  tokens: 11720
  tasks: 2
  commits: 4
  plan_head_before: cfa2c3ec28c12dc4e48ebb9eae2d5c2102695f1d

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "ModuloRede: @module abstract class expondo um único Dio @lazySingleton com baseUrl = String.fromEnvironment('API_BASE_URL', ...) — primeiro uso de @module/Dio no repo, sem @Environment (não há segunda implementação ainda)"
    - "CidadeRemoteDataSource segue 'next' como URL absoluta (dio.get(url) direto), validando scheme/host/port contra a baseUrl configurada antes de seguir, e limitando a 20 páginas — ambos como FormatException explícita"
    - "Falha ao carregar a lista atendida não interrompe quem já tem cidade salva: ValidarCidadeAtendidaUseCase emite autorizadaEAtendida(cidadeSalva) na Failure/Loading em vez de um estado de erro"

key-files:
  created:
    - lib/di/modulo_rede.dart
    - test/data/cidade_remote_datasource_test.dart
  modified:
    - lib/data/datasources/cidade_remote_datasource.dart
    - lib/data/repositories/cidade_repository_impl.dart
    - lib/data/models/cidade_model.dart
    - lib/di/injection.dart
    - lib/di/injection.config.dart
    - lib/domain/repositories/cidade_repository.dart
    - lib/domain/usecases/obter_cidades_atendidas_usecase.dart
    - lib/domain/usecases/validar_cidade_atendida_usecase.dart
    - lib/presentation/cidade_selecao/cidade_selecao_screen.dart
    - lib/presentation/cidade_selecao/cidade_selecao_state.dart
    - pubspec.yaml
    - android/app/src/main/AndroidManifest.xml
    - android/app/src/debug/AndroidManifest.xml
    - ios/Runner/Info.plist
    - README.md
    - test/domain/validar_cidade_atendida_usecase_test.dart
    - test/presentation/cidade_selecao_screen_test.dart
  deleted:
    - lib/data/datasources/cidade_local_datasource.dart
    - assets/cidades.json
    - test/data/cidade_local_datasource_test.dart

key-decisions:
  - "CidadeRemoteDataSource não ganhou um construtor secundário @visibleForTesting: injetar um Dio real com um HttpClientAdapter fake cobre os testes sem precisar de uma segunda via de construção (RESEARCH Pattern 5 seguido à risca)."
  - "As duas asserções de CidadeRepositoryImpl (sucesso/HTTP 500) ficaram no mesmo arquivo de teste do datasource (cidade_remote_datasource_test.dart), exatamente como o plano pediu, usando o mesmo Dio fake em vez de mockar CidadeRemoteDataSource."
  - "Doc-comment em cidade_selecao_state.dart referencia ValidarCidadeAtendidaUseCase como texto plano (crase simples), não como link [ClasseX] do dartdoc, para não arriscar um lint de referência não resolvida em CI."

requirements-completed: [VIT-06]

coverage:
  - id: D1
    description: "CidadeRemoteDataSource consome GET /api/publico/cidades/ via Dio: uma página, paginação seguindo o next absoluto, linhas inválidas descartadas, next de origem estranha rejeitado, cap de 20 páginas, HTTP 500 propaga, envelope malformado vira FormatException"
    requirement: "VIT-06"
    verification:
      - kind: unit
        ref: "test/data/cidade_remote_datasource_test.dart#CidadeRemoteDataSource (9 casos)"
        status: pass
    human_judgment: false
  - id: D2
    description: "CidadeRepositoryImpl sobre o datasource remoto: sucesso vira Result.success, HTTP 500 vira Result.failure"
    requirement: "VIT-06"
    verification:
      - kind: unit
        ref: "test/data/cidade_remote_datasource_test.dart#CidadeRepositoryImpl (sobre CidadeRemoteDataSource) (2 casos)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Asset local, CidadeLocalDataSource e seu teste removidos; pubspec sem a entrada de asset; nenhuma referência a CidadeLocalDataSource remanescente em lib/ ou test/"
    verification:
      - kind: other
        ref: "test ! -e assets/cidades.json && test ! -e lib/data/datasources/cidade_local_datasource.dart && test ! -e test/data/cidade_local_datasource_test.dart && ! grep -rn CidadeLocalDataSource lib test && ! grep -n assets/cidades.json pubspec.yaml"
        status: pass
    human_judgment: false
  - id: D4
    description: "Falha ao carregar a lista atendida não impede quem já tem cidade salva de entrar direto (autorizadaEAtendida), sem tocar GPS/geocodificação"
    requirement: "VIT-06"
    verification:
      - kind: unit
        ref: "test/domain/validar_cidade_atendida_usecase_test.dart#falha ao carregar a lista atendida → cidade salva entra direto (autorizadaEAtendida), sem depender do endpoint de cidades (D-16)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Lista de cidades atendidas vazia mostra 'Nenhuma cidade atendida no momento.' + Tentar de novo (chama carregarLista()), nunca uma lista vazia muda"
    requirement: "VIT-06"
    verification:
      - kind: automated_ui
        ref: "test/presentation/cidade_selecao_screen_test.dart#lista de cidades atendidas vazia: mensagem própria + \"Tentar de novo\" chamando carregarLista(), nunca uma lista vazia muda"
        status: pass
    human_judgment: false
  - id: D6
    description: "Android: INTERNET no manifest principal, cleartext só no manifest de debug/profile; iOS: NSAppTransportSecurity só com NSAllowsLocalNetworking, ATS não desligado globalmente"
    verification:
      - kind: other
        ref: "grep INTERNET/usesCleartextTraffic nos dois manifests + plutil -lint e plutil -extract NSAppTransportSecurity.* em ios/Runner/Info.plist"
        status: pass
    human_judgment: false
  - id: D7
    description: "README documenta API_BASE_URL para emulador/simulador/aparelho e os passos para subir o Django de dev (migrate, semear_vitrine_dev, runserver 0.0.0.0:8000), sem mais um número de testes hardcoded"
    verification:
      - kind: other
        ref: "grep API_BASE_URL/10.0.2.2/127.0.0.1/semear_vitrine_dev/runserver README.md"
        status: pass
    human_judgment: false
  - id: D8
    description: "Verificação visual real: emulador Android e simulador iOS consumindo o Django de dev de verdade (lista de 4 cidades, queda/recuperação do servidor, entrada direta com cidade salva e servidor fora)"
    verification: []
    human_judgment: true
    rationale: "Requer emulador/simulador reais, o servidor Django do usuário rodando com suas credenciais Postgres, e o repo irmão ../imoveis-aqui commitado/autorizado (02-02 ainda está uncommitted, aguardando o usuário) — consolidado no UAT de fim de fase (human_verify_mode=end-of-phase), exatamente como o próprio <human-check> da Task 2 já previa."

# Metrics
duration: 27min
completed: 2026-09-25
status: complete
---

# Phase 2 Plan 4: Cidades via API Real + Rede Nativa de Dev Summary

**Seletor de cidade trocado do asset fixo para `GET /api/publico/cidades/` real via Dio (base URL configurável, D-17), com a fonte local totalmente removida (D-16), cidade salva imune a uma falha do endpoint, estado próprio para lista vazia, e Android/iOS liberados para falar com o Django de desenvolvimento.**

## Performance

- **Duration:** 27 min
- **Started:** 2026-09-25T21:05:00Z
- **Completed:** 2026-09-25T21:32:00Z
- **Tasks:** 2 (ambas `tdd="true"`, ciclo RED→GREEN completo, sem REFACTOR necessário)
- **Files modified:** 22 (2 criados, 17 modificados, 3 deletados)

## Accomplishments
- `CidadeRemoteDataSource` consome `GET /api/publico/cidades/` via `Dio`, seguindo o `next` como URL absoluta até `null`, rejeitando um `next` de origem diferente da base URL e limitando a 20 páginas — ambos como `FormatException` explícita, nunca um loop ou uma requisição para outro host (T-02-04-02)
- `ModuloRede` (`@module`) expõe um único `Dio` singleton com `baseUrl` vindo de `String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000')` (D-17) e timeouts de 10s (T-02-04-03)
- `assets/cidades.json`, `CidadeLocalDataSource` e seu teste removidos por completo — fonte única da verdade (D-16); `CidadeRepository` continua com a mesma interface de 3 métodos (F1/D-14)
- `ValidarCidadeAtendidaUseCase`: uma falha em `GET /api/publico/cidades/` não impede mais quem já tem cidade salva de entrar direto na vitrine (`autorizadaEAtendida`), sem tocar GPS/geocodificação (D-16, F1/D-08)
- `CidadeSelecaoScreen`: uma lista de cidades atendidas vazia agora mostra "Nenhuma cidade atendida no momento." + "Tentar de novo" (novo `_CorpoListaVazia`) em vez de uma lista vazia muda, cabeado em todo estado que produz lista (D-16)
- Android: `INTERNET` movido para o manifest principal (necessário em release também); `usesCleartextTraffic="true"` isolado no manifest de debug/profile. iOS: `NSAppTransportSecurity` com apenas `NSAllowsLocalNetworking`, sem desligar o ATS globalmente (T-02-04-01)
- README ganhou a seção "API e servidor de desenvolvimento": `API_BASE_URL` para emulador/simulador/aparelho físico e os passos para subir o Django (`migrate`, `semear_vitrine_dev`, `runserver 0.0.0.0:8000`)
- `injection.config.dart` regenerado: `Dio` e `CidadeRemoteDataSource` registrados, nenhuma referência remanescente à classe removida
- 125/125 testes (`flutter test`) verdes, `flutter analyze` limpo

## Task Commits

Cada task seguiu o ciclo RED → GREEN (TDD, sem REFACTOR — o código já saiu limpo):

1. **Task 1: CidadeRemoteDataSource via Dio + troca por DI e remoção do asset (VIT-06, D-16, D-17)**
   - RED: `8252640` (`test(02-04)`) — 11 testes cobrindo todo o `<behavior>`, todos falhando genuinamente (`UnimplementedError`, nunca erro de compilação)
   - GREEN: `95a80b8` (`feat(02-04)`) — implementação completa + remoção do asset/datasource local/teste + `pubspec.yaml` + regeneração de `injection.config.dart`; 11/11 verdes
2. **Task 2: Cidade salva entra sem depender da lista, lista vazia tratada, rede nativa de dev e README (D-16, D-17)**
   - RED: `1ef4b73` (`test(02-04)`) — expectativa da Failure atualizada + novo teste de widget para lista vazia, ambos falhando genuinamente
   - GREEN: `073cb72` (`feat(02-04)`) — usecase + `_CorpoListaVazia` + manifests Android/iOS + README; 125/125 verdes

**Plan metadata:** commitado junto com este SUMMARY.

## Files Created/Modified

- `lib/di/modulo_rede.dart` - `urlBaseApi` (D-17) + `ModuloRede.@module` com `Dio` `@lazySingleton`
- `lib/data/datasources/cidade_remote_datasource.dart` - paginação via `next` absoluto, validação de origem, cap de 20 páginas, parse defensivo
- `lib/data/repositories/cidade_repository_impl.dart` - injeta `CidadeRemoteDataSource` em vez da fonte local
- `lib/data/models/cidade_model.dart`, `lib/domain/repositories/cidade_repository.dart`, `lib/domain/usecases/obter_cidades_atendidas_usecase.dart`, `lib/di/injection.dart` - doc comments atualizados (fonte agora é o endpoint público)
- `lib/domain/usecases/validar_cidade_atendida_usecase.dart` - Failure/Loading → `autorizadaEAtendida(cidadeSalva)` (D-16)
- `lib/presentation/cidade_selecao/cidade_selecao_state.dart` - doc de `erroCarregarCidades` atualizado
- `lib/presentation/cidade_selecao/cidade_selecao_screen.dart` - `_CorpoLista.onRecarregar` + novo `_CorpoListaVazia`
- `pubspec.yaml` - entrada `assets: - assets/cidades.json` removida
- `android/app/src/main/AndroidManifest.xml` - `+INTERNET`; `android/app/src/debug/AndroidManifest.xml` - `+usesCleartextTraffic`
- `ios/Runner/Info.plist` - `NSAppTransportSecurity.NSAllowsLocalNetworking`
- `README.md` - seção "API e servidor de desenvolvimento"; removida a frase com contagem fixa de testes
- `test/data/cidade_remote_datasource_test.dart` (novo) - 11 casos (datasource + repositório)
- `test/domain/validar_cidade_atendida_usecase_test.dart`, `test/presentation/cidade_selecao_screen_test.dart` - atualizados/expandidos
- **Deletados:** `lib/data/datasources/cidade_local_datasource.dart`, `assets/cidades.json`, `test/data/cidade_local_datasource_test.dart`

## Decisions Made
- `CidadeRemoteDataSource` ficou com um único construtor injetando `Dio` — sem construtor `@visibleForTesting` extra, porque um `Dio` real com um `HttpClientAdapter` fake (hand-written, sem pacote novo) já cobre 100% dos casos de teste (RESEARCH Pattern 5).
- Os dois testes de `CidadeRepositoryImpl` (sucesso/HTTP 500) foram colocados no mesmo `cidade_remote_datasource_test.dart`, reaproveitando o mesmo `Dio` fake em vez de mockar `CidadeRemoteDataSource` com mocktail — só `CidadePrefsDataSource` é mockado, exatamente como o plano descreveu.
- Falha ao carregar `/cidades` deixou de emitir `erroCarregarCidades` para quem tem cidade salva — passa a emitir `autorizadaEAtendida(cidadeSalva)` diretamente (D-16). `erroCarregarCidades` continua existindo para os fluxos que de fato dependem da lista (GPS negado/recusado sem cidade salva, "Tentar de novo" manual).

## Deviations from Plan

None — plan executado como escrito. O `<human-check>` da Task 2 (emulador/simulador reais contra o Django de dev) é, por natureza, não automatizável por este agente e fica consolidado no UAT de fim de fase (`human_verify_mode: end-of-phase`), como o próprio plano já previa.

## Issues Encountered
None.

## User Setup Required

Nenhum passo novo além do já registrado no SUMMARY do plano 02-02 (criar `.env` no repo irmão, `migrate`, `semear_vitrine_dev`, `runserver 0.0.0.0:8000`, e autorizar o commit em `../imoveis-aqui`) — este plano só passou a **consumir** esse endpoint pelo app, sem exigir nenhuma configuração adicional. O README agora documenta esses mesmos passos do lado do app (`API_BASE_URL`).

## Next Phase Readiness
- VIT-06 completo: o seletor de cidade lê exclusivamente `GET /api/publico/cidades/`, com fallback correto para quem já tem cidade salva e tratamento de lista vazia.
- `ModuloRede`/`CidadeRemoteDataSource` estabelecem o padrão de DI de `Dio` que a Fase 4 reaproveita para o endpoint real de `/imoveis` (API-04).
- Verificação visual real (emulador Android + simulador iOS contra o Django de dev) fica para o UAT de fim de fase, junto com a verificação pendente do plano 02-02 (repo irmão ainda uncommitted, aguardando autorização do usuário).

---
*Phase: 02-vitrine-lista-busca-e-ordena-o*
*Completed: 2026-09-25*

## TDD Gate Compliance

Ambas as tasks (`tdd="true"`) completaram o ciclo RED → GREEN com commits distintos:

| Task | RED | GREEN | REFACTOR | Status |
|------|-----|-------|----------|--------|
| 1 (CidadeRemoteDataSource) | `8252640` | `95a80b8` | — (não necessário) | Pass |
| 2 (cidade salva + lista vazia + rede nativa) | `1ef4b73` | `073cb72` | — (não necessário) | Pass |

Em ambos os casos o RED foi uma falha de asserção genuína (não erro de compilação): a Task 1 usou uma implementação-esqueleto (`throw UnimplementedError()`) só para permitir que os testes compilassem e falhassem pela razão certa; a Task 2 alterou a expectativa de um teste já existente e adicionou um teste de widget novo, ambos falhando contra o comportamento antigo antes da mudança.

## Self-Check: PASSED

- Todos os arquivos criados/modificados/deletados verificados presentes (ou ausentes, no caso das remoções) em disco.
- Commits `8252640`, `95a80b8`, `1ef4b73`, `073cb72` confirmados em `git log --oneline --all`.
- `flutter test` completo (125/125) e `flutter analyze` (limpo) re-executados nesta sessão.
- Todos os `<acceptance_criteria>` de ambas as tasks re-verificados via grep/plutil/test -e conforme listado no plano.
- `commits: 4` medido via `git rev-list --count ${plan_head_before}..HEAD` (não narrado).
