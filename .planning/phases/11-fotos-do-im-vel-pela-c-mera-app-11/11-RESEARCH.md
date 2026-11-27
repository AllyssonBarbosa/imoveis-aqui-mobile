# Phase 11: Fotos do Imóvel pela Câmera (APP 11) - Research

**Researched:** 2026-11-25
**Domain:** upload multipart com progresso (Flutter/Dio), câmera e galeria (image_picker),
compressão no aparelho, rotas DRF com transação e trava de linha.
**Confidence:** HIGH para o que foi lido no código e no pub.dev; MEDIUM onde está marcado.

## Summary

O backend já tem o model certo (`FotoImovel` com `ordem`, `capa` e capa única no banco) e a
validação certa (`validar_imagem` com Pillow). O trabalho na web é um **serviço transacional** e
cinco rotas finas aninhadas no imóvel, além de uma linha no `site_publico` para a capa vir primeiro.
No app, o trabalho é uma fila sequencial de envios multipart com progresso por foto, em cima do
`Dio` autenticado que já existe, mais duas dependências novas (`image_picker`,
`flutter_image_compress`) atrás de interfaces.

**Recomendação principal:** regras só em `Web/imoveis/fotos.py` com `select_for_update` no imóvel.
No app, um Cubit que é dono da lista do servidor e da fila, sem nunca reordenar localmente.

## Standard Stack

| Pacote | Versão | Fonte | Uso |
|---|---|---|---|
| `image_picker` | ^1.2.4 | pub.dev (flutter.dev), lido em 2026-11-25 | `pickImage(source: camera)`, `pickMultiImage()`; `requestFullMetadata: false` |
| `flutter_image_compress` | ^2.5.1 | pub.dev (fluttercandies.com), lido em 2026-11-25 | `compressAndGetFile(origem, destino, minWidth: 1920, minHeight: 1920, quality: 85, format: CompressFormat.jpeg)` |
| `dio` | ^5.11.1 (já no projeto) | — | `FormData`, `MultipartFile.fromFile`, `onSendProgress`, `Options(sendTimeout:)` |
| Django/DRF | já no projeto | — | `transaction.atomic`, `select_for_update`, `transaction.on_commit`, `MultiPartParser` |

**Não usar:** `permission_handler` (D-26: a câmera não precisa de permissão no Android pelo
`image_picker`), `image` (puro Dart, decodifica e redimensiona na thread da UI; lento com fotos de 12 MP),
pacotes de grade reordenável (`ReorderableListView` do Material resolve).

## Fatos verificados

### image_picker 1.2.4
- **iOS:** `NSPhotoLibraryUsageDescription` (exigido pela App Store mesmo com
  `requestFullMetadata: false`) e `NSCameraUsageDescription`. Microfone só para vídeo.
- **Android:** "No configuration required — the plugin should work out of the box." Usa a intenção
  do sistema para a câmera e o seletor de fotos do Android.
- **Android pode matar a activity** durante a câmera com pouca memória; o resultado só volta por
  `retrieveLostData()` na abertura. Fora da fase (D-27). `launchMode: singleInstance` faz o picker
  devolver cancelado; o projeto usa o `singleTop` padrão do Flutter (conferir no manifesto, sem mudança).
- **[HIGH, conferido no código do plugin no 11-05 — ver D-26; o texto abaixo foi superado] `CAMERA` no manifesto:** comportamento documentado do Android: se o app declara
  `android.permission.CAMERA` e ela não foi concedida, `ACTION_IMAGE_CAPTURE` lança
  `SecurityException`. Por isso não se declara (D-26). Hoje o manifesto não declara `CAMERA`.
  O executor confere que nenhum plugin a traz pelo manifesto mesclado
  (`build/app/intermediates/merged_manifests/...`) depois do `flutter build apk --debug`.
- **[HIGH, conferido no 11-05: não precisa — ver D-26] `<queries>`:** a visibilidade de pacotes do Android 11+ exige
  `<intent><action android:name="android.media.action.IMAGE_CAPTURE"/></intent>` em `<queries>`
  para `resolveActivity` achar o app de câmera. O manifesto do próprio plugin pode já trazer isso.
  O executor confere no manifesto mesclado e só adiciona no app se faltar. O manifesto já tem um
  bloco `<queries>` (do `url_launcher`).

### flutter_image_compress 2.5.1
- `minWidth`/`minHeight` funcionam como **lado máximo** (nome histórico): mantém a proporção, nunca
  corta e **não aumenta** foto menor (D-07).
- JPEG é o padrão; `format: CompressFormat.jpeg` deixa explícito. `quality` 0–100.
- `autoCorrectionAngle: true` (padrão) desvira pelo EXIF. Não somar com `rotate` diferente de 0.
- `keepExif: false` (padrão): o EXIF não vai para a saída, e isso inclui o **GPS**. É ganho de
  privacidade: a foto não leva a localização do aparelho para o site público.
- Android, iOS, macOS. Sem Windows: em teste de unidade o preparador real nunca roda (fica atrás
  de `PreparadorDeFoto`).

### Dio — multipart e progresso
- `FormData.fromMap({'imagem': await MultipartFile.fromFile(caminho, filename: 'foto.jpg',
  contentType: DioMediaType('image', 'jpeg'))})`.
- **Armadilha:** um `FormData`/`MultipartFile` **não pode ser enviado duas vezes** ("The FormData has
  already been finalized"). O "Tentar de novo" precisa **montar um FormData novo** a partir do caminho
  do arquivo preparado. A DataSource recebe o caminho, nunca um `FormData` pronto.
- `onSendProgress: (enviado, total)`: `total` pode ser -1 quando o tamanho não é conhecido; com
  `MultipartFile.fromFile` o `FormData` tem `length` e o total vem certo. Tratar -1 como
  indeterminado.
- `Options(sendTimeout: Duration(seconds: 60))` por requisição sobrescreve o padrão (D-19). Com
  `sendTimeout` e corpo em stream, o Dio aplica o tempo ao envio do corpo. `receiveTimeout` continua
  10 s (a resposta do Django é pequena).
- O interceptador de sessão converte 401 em `SessaoExpiradaException` dentro do `DioException.error`;
  vale também para o POST multipart.
- **ApiFalsa:** o `_AdaptadorApiFalsa.fetch` recebe `requestStream`. O `onSendProgress` só dispara
  quando o adaptador **consome** o stream, então as rotas de foto na `ApiFalsa` drenam
  `requestStream` (e podem gravar os bytes para o teste conferir o campo `imagem`).

### Django
- `select_for_update()` precisa estar dentro de `transaction.atomic`. No SQLite dos testes é
  ignorado (sem erro), mas a trava vale no Postgres de produção. Os testes de concorrência ficam
  lógicos (ordem = maior + 1, teto conferido dentro da transação), sem threads.
- `UniqueConstraint(fields=["imovel"], condition=Q(capa=True))`: trocar a capa precisa desmarcar a
  antiga **antes** de marcar a nova, na mesma transação (`update(capa=False)` → `save(capa=True)`),
  como o `definir_como_capa` já faz. Ao apagar a capa: `delete()` e depois promover a primeira das
  restantes por `ordem, id`.
- Renumerar: ler as restantes por `ordem, id` e `bulk_update` com `ordem = índice`.
- Apagar o arquivo: `transaction.on_commit(lambda: storage.delete(nome))`. Se a transação desfaz, o
  arquivo fica. Mesmo padrão dos documentos (`documento.arquivo.delete(save=False)`), só que depois
  do commit.
- `full_clean()` no `FotoImovel` roda `validar_imagem` (tipo e tamanho) e a validação do
  `ImageField` (Pillow). Erro → `{"imagem": [...]}` 400.
- Upload grande: arquivos acima de `FILE_UPLOAD_MAX_MEMORY_SIZE` (2,5 MB padrão) vão para arquivo
  temporário; não conta no `DATA_UPLOAD_MAX_MEMORY_SIZE`. Nada a configurar.
- `ImageField` serializado com `request` no contexto vira URL absoluta (`build_absolute_uri`), igual ao
  `FotoImovelSerializer` atual e ao que a vitrine já consome no emulador (`10.0.2.2`).
- **Site (D-24):** `site_publico/views.py:116` usa `prefetch_related("fotos")` com a ordem do model
  (`ordem, id`) e passa para o `ImovelVitrineDetalheSerializer`, cujo `fotos` lê esse prefetch. Trocar
  por `Prefetch("fotos", queryset=FotoImovel.objects.order_by("-capa", "ordem", "id"))` põe a capa
  primeiro, igual à API pública.

## Architecture Patterns (copiar das fases anteriores)

| Peça nova | Copiar de |
|---|---|
| `FotosImovelRemoteDataSource` | `gestao_imovel_remote_datasource.dart` (fina, `@Named('autenticado')`, `FormatException` para corpo errado) |
| `FotosImovelRepositoryImpl` | `gestao_imovel_repository_impl.dart` (`_executar` com sessão → 400/403 com `mensagemDeRecusa` → 404 → resto) |
| Falha de recusa | `MudancaSituacaoRecusadaException` → `FotoRecusadaException(mensagem)` |
| Abridor + Cubit dono | `abrirGestaoImovel` (cria o Cubit, `push`, devolve `mudou`, fecha) |
| 401 na tela | `BlocListener` + `voltarAoLoginComSessaoTerminada` com a conferência no `initState` |
| Model + fixtures | Phase 12: `contrato_area_gestor_test.dart`, Models lidos contra todas as fixtures |
| Grupo de captura | `capturar_gestor` em `tool/capturar_fixtures_api.py` (`_entrar`, `_exigir_chaves`, `salvar`) |
| Rotas web com escopo | `ImovelViewSet` (`EmpresaScopedQuerySetMixin`, `EhCorretor`); `@action(detail=True, url_path=...)` |

### Estado sugerido do Cubit (freezed)
```
FotosImovelState(
  lista: ListaFotos  // sealed: Carregando | Carregada(List<FotoImovel>) | Erro | NaoEncontrado | SessaoExpirada
  fila: List<EnvioDeFoto>  // imutável; cada um: id local, caminhoLocal, estado (Aguardando | Preparando | Enviando(progresso 0..1 ou null) | Falhou(mensagem?))
  operacao: OperacaoFotos  // sealed: Nenhuma | Reordenando | DefinindoCapa(fotoId) | Apagando(fotoId)
  falhasDeOperacao: int  // gatilho de SnackBar, como `falhasAoAtualizar` da APP 09
  mudou: bool  // a gestão relê na volta
)
```
A fila processa um item por vez (`_processando`), na ordem. Uma falha marca o item e segue para o
próximo. 401 em qualquer ponto → `lista = SessaoExpirada` e a fila para (os itens ficam como estão;
a tela sai para o login).

## Common Pitfalls
1. **Reenviar o mesmo `FormData`** no "Tentar de novo" → erro do Dio. Montar de novo a partir do caminho.
2. **Reordenar com envio em andamento** → a lista mandada não tem a foto nova → 400. D-20 desliga
   o arrastar enquanto a fila trabalha.
3. **`ReorderableListView.onReorder`** entrega `newIndex` deslocado quando o item desce
   (`if (newIndex > oldIndex) newIndex -= 1`). O cálculo da lista de ids pedida fica numa função pura testada.
4. **Arquivos temporários** da câmera e da compressão ficam no cache do app. Apagar o arquivo
   comprimido depois do envio aceito e ao remover da fila (o sistema limpa o resto).
5. **Teste do Django gravando em `media/`** → usar `override_settings(MEDIA_ROOT=tempfile.mkdtemp())`
   e limpar no `tearDown`.
6. **Fixture de foto com URL absoluta do host da captura** (`http://127.0.0.1:8011/media/...`): o
   Model só confere que é `String`; o teste de contrato não depende do host.
7. **`pubspec.lock` com Flutter 3.47.5** (ver CONTEXT, nota final).

## Validation Architecture
- **Web:** `python manage.py test imoveis site_publico` a cada plano web; testes listados em D-14.
- **App:** `flutter test` (unidade do serviço de fila, função de reordenação, repositório com
  `DioAdapter` falso, `bloc_test` do Cubit, widget da tela, e2e na `pilha_real` com a `ApiFalsa`) e
  `flutter analyze`.
- **Contrato:** fixtures reais → Models (app) e as mesmas formas conferidas no script de captura.
- **Manual:** UAT no emulador (câmera virtual, galeria, vitrine do app e site).

## Sources
- pub.dev `image_picker` (1.2.4) e `flutter_image_compress` (2.5.1), lidos em 2026-11-25. HIGH.
- Código lido em `origin/main` dos dois repos (arquivos citados no CONTEXT). HIGH.
- Comportamento do `CAMERA` declarado × `ACTION_IMAGE_CAPTURE` e `<queries>`: documentação do Android,
  conhecimento prévio, não relido nesta sessão. MEDIUM, conferido pelo executor no manifesto mesclado.
