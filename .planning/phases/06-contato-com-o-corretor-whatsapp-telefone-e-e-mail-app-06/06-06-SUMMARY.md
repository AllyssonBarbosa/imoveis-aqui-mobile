---
phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
plan: 06
subsystem: dominio
tags: [contato, url_launcher, gateway, usecase, externalApplication, whatsapp]
status: complete

requires:
  - phase: 06-contato-com-o-corretor-whatsapp-telefone-e-e-mail-app-06
    provides: "ContatoRepository.registrarContato -> Result<Uri> e ApiFalsa com POST (06-05); CanalContato (06-04)"
provides:
  - "LinkLauncherGateway.abrir(Uri) -> Future<bool> (nunca lanca) e ContatoSemAplicativoException"
  - "UrlLauncherGatewayImpl: launchUrl com LaunchMode.externalApplication, falhas da plataforma viram false"
  - "ContatarCorretorUseCase.call(imovelId, canal) -> Result<void>: registra antes de abrir, nunca desfaz o registro"
affects: [06-07, 06-08, 06-09, 06-10]

plan_head_before: b905653655c8a7b3cd755a382703cecfc7cece07
actuals:
  tokens: 8500   # chars/4 sobre codigo e testes alterados (gateway, impl, use case, 2 testes, pubspec)
  tasks: 2
  commits: 2     # MEDIDO: git rev-list --count b905653..HEAD antes do commit do SUMMARY

tech-stack:
  added:
    - "url_launcher 6.3.3 (flutter.dev); url_launcher_android 3.2.6 e demais plataformas transitivas"
    - "dev: url_launcher_platform_interface 2.3.2, plugin_platform_interface 2.1.8 (ja transitivas, declaradas por import direto nos testes)"
  patterns:
    - "Gateway de plataforma em domain/gateways com impl em data/gateways que normaliza on Exception / on Error (analogo ao GeocodingGateway)"
    - "Teste de plataforma por UrlLauncherPlatform falso (Fake + MockPlatformInterfaceMixin), instancia restaurada em addTearDown"
    - "Use case registra e so entao abre; falha de abertura e falha tipada, nunca desfaz"

key-files:
  created:
    - lib/domain/gateways/link_launcher_gateway.dart
    - lib/data/gateways/url_launcher_gateway_impl.dart
    - lib/domain/usecases/contatar_corretor_usecase.dart
    - test/data/url_launcher_gateway_impl_test.dart
    - test/domain/contatar_corretor_usecase_test.dart
  modified:
    - pubspec.yaml
    - pubspec.lock
    - lib/di/injection.config.dart

key-decisions:
  - "Link sempre aberto com LaunchMode.externalApplication: platformDefault abriria wa.me numa aba interna (Pitfall 1)"
  - "Qualquer excecao/erro da plataforma vira false no gateway (ACTIVITY_NOT_FOUND no Android, URL invalida no iOS, MissingPluginException em teste)"
  - "Sem canLaunchUrl, sem <queries> no AndroidManifest e sem LSApplicationQueriesSchemes: android/ e ios/ intocados (D-15)"
  - "Open Question 3 decidida: se o visitante sair da tela durante o POST o link ainda abre, pois o contato foi registrado e foi ele quem pediu"

requirements-completed: [APP06-C2, APP06-C3, APP06-C4]

coverage:
  - id: D1
    description: "Ponta a ponta: POST na ApiFalsa, repositorio real e UrlLauncherPlatform falso recebe exatamente o link capturado do WhatsApp, com externalApplication, depois de exatamente um POST"
    requirement: APP06-C2
    verification:
      - kind: unit
        ref: "test/domain/contatar_corretor_usecase_test.dart grupo 'ponta a ponta (ApiFalsa + UrlLauncherPlatform falso)'"
        status: pass
    human_judgment: false
  - id: D2
    description: "Gateway entrega wa.me, tel e mailto ao sistema como aplicativo externo; false, PlatformException ACTIVITY_NOT_FOUND e ArgumentError viram false sem lancar"
    requirement: APP06-C3
    verification:
      - kind: unit
        ref: "test/data/url_launcher_gateway_impl_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Registro antes da abertura; falha no registro nao abre nada; abertura false devolve ContatoSemAplicativoException sem desfazer o registro"
    requirement: APP06-C4
    verification:
      - kind: unit
        ref: "test/domain/contatar_corretor_usecase_test.dart grupo 'bordas'"
        status: pass
    human_judgment: false
  - id: D4
    description: "O WhatsApp/discador/cliente de e-mail realmente abre em aparelho real (a plataforma real so e exercitada em dispositivo)"
    requirement: APP06-C2
    verification: []
    human_judgment: true
    rationale: "Os testes usam UrlLauncherPlatform falso; abrir app externo de verdade depende do aparelho e fica para a verificacao manual da fase"
---

# Phase 6 Plan 06: url_launcher atras de um gateway e ContatarCorretorUseCase Summary

**`url_launcher` 6.3.3 atras de `LinkLauncherGateway` (sempre `externalApplication`, falhas da plataforma viram `false`) e `ContatarCorretorUseCase` que registra o contato antes de abrir o link e nunca desfaz o registro, provado de ponta a ponta da ApiFalsa ate o `UrlLauncherPlatform` falso.**

## Performance

- **Duration:** ~20 min (execucao retomada apos limite de uso; tempo de espera nao contado)
- **Completed:** 2026-11-18
- **Tasks:** 2 (1 tracer, 1 auto/tdd)
- **Files modified:** 8 (5 criados, 3 modificados)

## Accomplishments

- Dependencias: `url_launcher: ^6.3.3` (resolvido 6.3.3, `url_launcher_android` 3.2.6) e, em dev, `url_launcher_platform_interface` 2.3.2 e `plugin_platform_interface` 2.1.8, com comentario em portugues. `android/` e `ios/` sem nenhuma mudanca (`git diff main -- android ios` vazio).
- `LinkLauncherGateway`/`UrlLauncherGatewayImpl` (`@LazySingleton(as: ...)`): `launchUrl(link, mode: LaunchMode.externalApplication)` com `on Exception` e `on Error` devolvendo `false`; o link nunca e logado.
- `ContatarCorretorUseCase` (`@injectable`): `registrarContato` primeiro; `Success` abre e devolve `Result.success(null)` ou `ContatoSemAplicativoException`; `Failure` sobe sem abrir; `Loading` repassado.
- Tracer: a cadeia real `ContatoRemoteDataSource` sobre `ApiFalsa` -> `ContatoRepositoryImpl` -> `UrlLauncherGatewayImpl` -> `UrlLauncherPlatform` falso recebe o link de `contato_201_whatsapp.json` byte a byte, com `PreferredLaunchMode.externalApplication`, quando a ApiFalsa ja tinha exatamente uma chamada (o POST).
- Bordas: tres esquemas, `false`, `PlatformException(ACTIVITY_NOT_FOUND)` e `ArgumentError` no gateway; cinco falhas de registro (400, 404, 429, link invalido, `DioException`), abertura `false` e `Loading` no use case, com `verifyInOrder`/`verifyNever`.

## Task Commits

1. **Task 1 (tracer): url_launcher atras de LinkLauncherGateway e ContatarCorretorUseCase** - `d9ff4d3` (feat)
2. **Task 2: bordas do gateway e do ContatarCorretorUseCase** - `a382ead` (test)

Repo da API: nenhum commit (opcao-a). Nada de push.

## Verificacao

- Gate do tracer: `dart run build_runner build -d` sem SEVERE (61 saidas; `injection.config.dart` registra `UrlLauncherGatewayImpl` e `ContatarCorretorUseCase`); `flutter test ... --plain-name "ponta a ponta"` passou antes da Task 2.
- `flutter test test/data/url_launcher_gateway_impl_test.dart test/domain/contatar_corretor_usecase_test.dart`: 15 passaram. `flutter test` (suite inteira): 662 passaram. `flutter analyze`: sem issues.
- Criterios de aceitacao: dependencias presentes em `pubspec.yaml`, `git diff --quiet main -- android ios` ok, `grep canLaunchUrl lib/` sem ocorrencias, `LaunchMode.externalApplication`, `on Exception`, `on Error`, `@LazySingleton(as: LinkLauncherGateway)` e `@injectable` presentes.
- Verificacao do plano ("spec-less probe fallback"): pulada no planejamento, conforme registrado no proprio plano.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Bloqueio] Import de `LinkDelegate` no teste**
- **Found during:** Task 1
- **Issue:** o fake do plano sobrescreve `LinkDelegate? get linkDelegate`, mas o tipo vive em `package:url_launcher_platform_interface/link.dart`, nao no import indicado no plano; a compilacao do teste falhava com "Type 'LinkDelegate' not found".
- **Fix:** adicionado `import 'package:url_launcher_platform_interface/link.dart';` nos dois arquivos de teste que definem o fake.
- **Files modified:** test/domain/contatar_corretor_usecase_test.dart, test/data/url_launcher_gateway_impl_test.dart
- **Commit:** d9ff4d3 e a382ead

**Total deviations:** 1 auto-fixed (1 bloqueio de import). **Impact:** nenhum no escopo nem no comportamento.

## Known Stubs

None.

## Threat Flags

None - nenhuma superficie nova alem das cobertas pelo threat model do plano.

## Issues Encountered

A execucao foi interrompida por limite de uso antes de qualquer alteracao de codigo e retomada depois; sem efeito no resultado.

## Self-Check: PASSED

- Arquivos criados presentes: link_launcher_gateway.dart, url_launcher_gateway_impl.dart, contatar_corretor_usecase.dart, url_launcher_gateway_impl_test.dart, contatar_corretor_usecase_test.dart.
- Commits `d9ff4d3` e `a382ead` existem em feat/APP06; `git rev-list --count b905653..HEAD` = 2.
