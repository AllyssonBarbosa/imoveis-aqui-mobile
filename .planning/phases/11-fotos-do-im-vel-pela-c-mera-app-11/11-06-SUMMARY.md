---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
plan: 06
subsystem: app (camada de dados)
tags: [dio, multipart, progresso, repositorio, image_picker, flutter_image_compress]
requires: ["11-05"]
provides:
  - "FotoImovelModel (4 chaves, lido contra todas as fixtures)"
  - "FotosImovelDataSource + FotosImovelRemoteDataSource (multipart com FormData novo a cada envio, onSendProgress, sendTimeout de 60 s só no envio)"
  - "FotosImovelRepositoryImpl (401 → sessão, 400/403 com texto → FotoRecusadaException, 404 → ImovelNaoEncontrado, resto → conexão) e fracaoEnviada"
  - "SeletorDeFotosImagePicker e PreparadorDeFotoCompressao (gateways reais)"
  - "ApiFalsa: rotas de fotos, drenagem do corpo (progresso real), bytes e sendTimeout gravados, requisicoesDasFotos"
key-files:
  created:
    - "lib/data/models/foto_imovel_model.dart (+ .freezed.dart, .g.dart)"
    - "lib/data/datasources/fotos_imovel_datasource.dart"
    - "lib/data/datasources/fotos_imovel_remote_datasource.dart"
    - "lib/data/repositories/fotos_imovel_repository_impl.dart"
    - "lib/data/gateways/seletor_de_fotos_image_picker.dart"
    - "lib/data/gateways/preparador_de_foto_compressao.dart"
    - "test/data/fotos/fotos_imovel_dados_test.dart"
    - "test/di/injection_fotos_test.dart"
  modified:
    - "lib/domain/gateways/seletor_de_fotos_gateway.dart (FalhaAoEscolherFotoException)"
    - "lib/domain/gateways/preparador_de_foto_gateway.dart (FalhaAoPrepararFotoException)"
    - "lib/di/injection.config.dart"
    - "test/support/api_falsa.dart"
completed: 2026-11-25
---

# 11-06 — Camada de dados das fotos

## O que foi feito
- **Model** `FotoImovelModel(id, imagem, ordem, capa)` com `paraEntidade()`. Chave faltando ou de tipo errado gera `TypeError`,
  que vira falha tipada.
- **DataSource remota** no `Dio` `@Named('autenticado')`. Rotas exatamente as do §19, com barra final.
  - `enviar` monta um `FormData` **novo a cada chamada** a partir do caminho (`MultipartFile.fromFile`, campo `imagem`,
    `foto.jpg`, `image/jpeg`), passa `onSendProgress` e usa `Options(sendTimeout: 60 s)`.
  - `listar`/`reordenar`/`definirCapa`/`apagar` leem a lista na ordem recebida.
  - Não captura `DioException`.
- **Repositório** no molde da gestão (`_executar`), listas imutáveis, sem nova tentativa automática. O progresso vira
  fração 0..1 (`fracaoEnviada`, `null` quando o total é desconhecido).
- **Gateways reais:**
  - `SeletorDeFotosImagePicker`: `pickImage(camera)` / `pickMultiImage`, ambos com `requestFullMetadata: false`.
    Falha da plataforma → `FalhaAoEscolherFotoException`.
  - `PreparadorDeFotoCompressao`: `compressAndGetFile` com 1920/1920, qualidade 85, JPEG, `autoCorrectionAngle`,
    `keepExif: false`, num arquivo único na pasta temporária. `descartar` apaga e ignora `FileSystemException`.
- **ApiFalsa:**
  - O adaptador agora **drena o corpo do pedido**, como a rede faria. Sem isso o `onSendProgress` nunca dispara.
  - `RequisicaoGravada` ganhou `bytesEnviados`, `corpoEmTexto` e `tempoDeEnvio`.
  - Rotas das fotos servem as fixtures (401 sem token, 405 em método errado), mais o getter `requisicoesDasFotos`.

## Desvios do plano
- **Gateways no domínio ganharam falhas próprias** (`FalhaAoEscolherFotoException`, `FalhaAoPrepararFotoException`) em
  vez de reaproveitar `FalhaDeConexaoException`, que seria um nome enganoso para "câmera negada" ou "foto ilegível".
- **Pasta temporária:** `Directory.systemTemp` (o cache do app no Android/iOS), sem adicionar `path_provider`.
- **Drenagem na ApiFalsa vale para todo pedido**, não só os de foto. A suíte antiga continuou toda verde com a mudança
  (1950 → 1950 antes dos testes novos).
- Testes num arquivo só (`test/data/fotos/fotos_imovel_dados_test.dart`) para Model, DataSource e repositório.

## Verificação
- `flutter test test/data/fotos`: **31 OK**, entre eles:
  - o multipart com exatamente um `name="imagem"`, `filename="foto.jpg"` e `content-type: image/jpeg`, e corpo maior que o arquivo;
  - o progresso avisado mais de uma vez, terminando em `enviados == total` (fração final 1.0);
  - enviar duas vezes o mesmo arquivo; o `sendTimeout` de 60 s só no envio;
  - o corpo do PUT `{"ids": [...]}`; os 401 nas 5 operações;
  - os quatro 400 do envio e o da ordem com a mensagem do servidor; 403 com texto; 404 sem texto;
  - 500 e 400 sem texto; corpo malformado; arquivo local inexistente sem requisição; `sendTimeout` sem nova tentativa;
  - nenhuma string `fotos-imovel` no código de `lib/`.
- `flutter test test/di/injection_fotos_test.dart`: 2 OK (7 use cases e as implementações reais pelo DI de produção).
- `flutter test` inteiro: **1983 OK**. `flutter analyze`: os mesmos 100 infos antigos de `material.dart`, nenhum `warning`,
  `error` ou info nos arquivos novos.
- Gerados reescritos só com fim de linha voltaram com `git checkout --`.
- O preparador e o seletor reais não rodam em `flutter test` (plugins): ficam cobertos pelo UAT do 11-09.
- Sem commit no app (aguardando aprovação).
