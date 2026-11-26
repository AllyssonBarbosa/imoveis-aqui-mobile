---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
plan: 05
subsystem: app (pacotes, plataformas, domínio)
tags: [image_picker, flutter_image_compress, permissoes, dominio]
requires: ["11-04"]
provides:
  - "image_picker ^1.2.4 e flutter_image_compress ^2.5.1 no pubspec (lock só com adições)"
  - "Info.plist com NSCameraUsageDescription e NSPhotoLibraryUsageDescription; manifesto sem CAMERA, com comentário"
  - "Entidades FotoImovel e FotoEscolhida, idsNaOrdemPedida, FotosImovelRepository + FotoRecusadaException"
  - "SeletorDeFotosGateway e PreparadorDeFotoGateway (ladoMaximoDaFoto=1920, qualidadeJpegDaFoto=85)"
  - "7 use cases: Listar, Preparar, Enviar (descarta o JPEG no sucesso), DescartarFotoPreparada, Reordenar, DefinirCapa, Apagar"
key-files:
  created:
    - "lib/domain/entities/foto_imovel.dart (+ .freezed.dart)"
    - "lib/domain/repositories/fotos_imovel_repository.dart"
    - "lib/domain/gateways/seletor_de_fotos_gateway.dart"
    - "lib/domain/gateways/preparador_de_foto_gateway.dart"
    - "lib/domain/usecases/{listar_fotos,preparar_foto,enviar_foto,descartar_foto_preparada,reordenar_fotos,definir_capa,apagar_foto}_usecase.dart"
    - "test/domain/fotos_imovel_dominio_test.dart"
  modified: ["pubspec.yaml", "pubspec.lock", "ios/Runner/Info.plist", "android/app/src/main/AndroidManifest.xml", "lib/di/injection.config.dart"]
completed: 2026-11-25
---

# 11-05 — Pacotes, permissões e domínio das fotos

## O que foi feito
- **Task 0 (Flutter):** resolvida pela Palloma: Flutter 3.50.1 / Dart 3.14.0. O `flutter pub get` dela não mudou o lock.
- **Pacotes:** `flutter pub add` e depois `^` com comentário no `pubspec.yaml`. Diff de versões do lock: **só adições**
  (`image_picker*`, `flutter_image_compress*`, `file_selector_*`, `cross_file`, `flutter_plugin_android_lifecycle`).
  Nenhuma versão existente mudou.
- **iOS:** as duas chaves com os textos do D-25, com um comentário.
- **Android:** comentário explicando a ausência de `CAMERA`.
- **Domínio:**
  - `FotoImovel(id, url, ordem, capa)` e `FotoEscolhida(caminho)` (freezed).
  - `idsNaOrdemPedida` (função pura: corrige o `para` do `ReorderableListView`, devolve `null` quando nada muda,
    lista imutável).
  - `FotosImovelRepository` com as falhas documentadas e `FotoRecusadaException` (sem a mensagem no `toString`).
  - Typedef `AoProgredirEnvio` (fração 0..1 ou `null`).
  - Gateways do seletor (resultados em `Result`) e do preparador (`preparar` e `descartar`).
  - 7 use cases `@injectable`.

## Desvios do plano
1. **Android, sem build:** esta máquina **não tem Android SDK** (`flutter build apk --debug` → "No Android SDK found").
   Em vez do manifesto mesclado, li os manifestos e o código dos plugins no cache do pub:
   - nenhum plugin novo declara `CAMERA`;
   - o `image_picker_android` não usa `resolveActivity` (trata `ActivityNotFoundException`), então **`<queries>`
     não é necessário**;
   - **correção do D-26:** declarar `CAMERA` não causaria `SecurityException`. O plugin detecta a declaração e pede
     a permissão ao corretor. A decisão (não declarar) continua a mesma, com o motivo certo (evitar uma pergunta inútil).
     CONTEXT D-26, RESEARCH e o comentário do manifesto foram corrigidos.
   - **Impacto no UAT:** o roteiro do 11-09 pede emulador Android. Ou a Palloma instala o Android Studio/SDK nesta
     máquina, ou o UAT roda noutra máquina.
2. **Pastas:** gateways em `lib/domain/gateways/` (padrão do projeto: geolocator, geocoding, url_launcher), não em
   `lib/domain/services/`. `FotoEscolhida` e `idsNaOrdemPedida` ficaram em `entities/foto_imovel.dart`, e
   `FotoRecusadaException` no arquivo do repositório (molde da `MudancaSituacaoRecusadaException`), sem
   `falhas_fotos.dart`.
3. **Use cases a mais:** `PrepararFotoUseCase` e `DescartarFotoPreparadaUseCase`, para o Cubit nunca tocar em gateway.
   O `EnviarFotoUseCase` apaga o JPEG temporário só quando o servidor aceita (no "Tentar de novo" reenvia o mesmo
   arquivo sem preparar de novo).
4. **Seletor com `Result`:** `tirarFoto()` → `Result<FotoEscolhida?>` e `escolherDaGaleria()` →
   `Result<List<FotoEscolhida>>`. Acesso negado no iOS vira falha tipada, sem `try/catch` na UI.

## Verificação
- `flutter test test/domain/fotos_imovel_dominio_test.dart`: 13 OK.
- `flutter test` inteiro: **1950 OK**.
- `flutter analyze`: 100 infos, **todos `deprecated_member_use`** do import `package:flutter/material.dart` em arquivos
  antigos (o Flutter 3.50.1 recomenda `material_ui`). Nenhum nos arquivos novos. O D-30 da Phase 12 citava 41; a
  diferença vem da versão do analisador, não desta fase. **Atenção para o 11-07/08:** as telas novas vão importar
  `material.dart` (exigido pelo CLAUDE.md) e somar infos do mesmo tipo.
- Arquivos gerados que o `build_runner` reescreveu só com fim de linha voltaram com `git checkout --`. Ficou só a
  mudança real do `injection.config.dart` (os 7 use cases). Três arquivos antigos que o `dart format` mexeu foram
  revertidos.
- A DI resolve os use cases só quando o repositório e o preparador existirem (11-06). Como o `get_it` é preguiçoso,
  nada quebra antes disso.
- Sem commit no app (aguardando aprovação).
