# Phase 11 (APP 11) — Notas para os Pull Requests

Pontos que a Palloma pediu para citar nos PRs da `feat/APP11` (app e web). Atualizado a cada plano.

## App

- **Avisos `deprecated_member_use` do `material.dart`.** Com o Flutter 3.50.1 (Dart 3.14.0), o `flutter analyze` marca
  como obsoleto o import `package:flutter/material.dart` e recomenda `package:material_ui/material_ui.dart`. Antes da
  Phase 11 já eram **100 infos**, todas em arquivos antigos. **As telas novas da Phase 11 seguem o CLAUDE.md** (Material 3
  com widgets de `material.dart`), então somam infos do mesmo tipo. A migração para `material_ui` fica para uma tarefa
  própria da equipe, para não misturar com o card. Não há `warning` nem `error` no analyze. Depois do 11-08: **105
  infos** (+5, todas o import de `material.dart` nos arquivos novos: `fotos_imovel_screen.dart`, `fila_envio.dart`,
  `item_foto.dart` e dois testes). O `onReorder` do `ReorderableListView`, também obsoleto no 3.50.1, **não** foi
  usado: a tela usa o substituto `onReorderItem`. No fim (11-09): **106 infos** (+1 do import no teste ponta a ponta novo).
- **Flutter 3.50.1.** O `pubspec.lock` da `main` foi resolvido com o 3.50.1 (commit `fbf0de8`). Com o 3.47.5 o
  `flutter pub get` descia `test`, `analyzer` e `freezed`. Quem for revisar ou rodar precisa do 3.50.1.
- **Pacotes novos:** `image_picker ^1.2.4` e `flutter_image_compress ^2.5.1`. O lock só ganhou esses pacotes e as
  dependências deles; nenhuma versão existente mudou.
- **Permissões:** iOS com `NSCameraUsageDescription` e `NSPhotoLibraryUsageDescription`. Android **sem**
  `android.permission.CAMERA`, de propósito (comentário no manifesto): o `image_picker` usa a câmera e o seletor do
  sistema. Se `CAMERA` fosse declarada, o plugin pediria a permissão ao corretor sem necessidade. Também não precisa
  de `<queries>`.
- **Capa na volta para a gestão:** o `GET /api/imoveis/<id>/` que a gestão lê não traz fotos no Model do app, então
  a tela de fotos devolve a capa que o servidor marcou na última lista que ela recebeu, e o cabeçalho a mostra. O acervo
  relê a API na volta (cartão com a capa nova). Mexer em fotos não esconde "Ver na vitrine" (isso continua só para a
  mudança de situação).
- **Privacidade:** a foto sai do aparelho reduzida (1920 px, JPEG 85) e **sem EXIF**, logo sem a localização GPS.
- **ApiFalsa dos testes:** o adaptador falso passou a drenar o corpo de todo pedido (como a rede faz), para o
  `onSendProgress` do upload disparar nos testes; a suíte antiga continuou toda verde.
- **Fixtures:** 13 fixtures capturadas do Django real (grupo `fotos` em `tool/capturar_fixtures_api.py`) e §19 no
  contrato.

## Web

- **Rota antiga intocada:** `/api/fotos-imovel/` (`FotoImovelViewSet`, de outra tarefa) continua como estava. A única
  mudança que a alcança é `FotoImovel.definir_como_capa()` passar a rodar em `transaction.atomic`.
- **Rotas novas** em `/api/imoveis/<id>/fotos/…`, com as regras em `Web/imoveis/fotos.py`, sem migração.
- **`site_publico` (W10):** a galeria da página do imóvel passou a começar pela capa, na mesma sequência do detalhe da
  API pública.

## UAT

- O UAT do 11-09 roda no emulador Android. A Palloma vai instalar o Android Studio antes dele: a máquina de
  desenvolvimento não tinha Android SDK durante a execução, por isso a conferência do manifesto foi feita lendo os
  manifestos e o código dos plugins.
