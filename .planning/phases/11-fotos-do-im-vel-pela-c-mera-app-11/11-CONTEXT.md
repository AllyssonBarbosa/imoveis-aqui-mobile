# Phase 11: Fotos do Imóvel pela Câmera (APP 11) - Context

**Gathered:** 2026-11-25
**Status:** Ready for planning

<domain>
## Phase Boundary

O corretor, logado (Phase 8), abre um imóvel do acervo na tela de gestão (Phase 9) e toca em
**"Fotos"**. Abre uma tela própria onde ele:

1. tira foto pela câmera ou escolhe várias da galeria;
2. envia todas de uma vez, vendo o progresso de cada uma, e a que falha mostra o erro e tem
   "Tentar de novo" sem travar as outras;
3. reordena arrastando e escolhe a foto de capa;
4. apaga uma foto, com confirmação.

**Quem decide é o servidor.** O app nunca muda a ordem nem a capa localmente: ele pede para a API e
relê a lista. A web ganha, na `feat/APP11`, rotas autenticadas aninhadas no imóvel
(`/api/imoveis/{id}/fotos/…`), com o mesmo isolamento por empresa do acervo (imóvel de outra
empresa → 404). As fotos são as mesmas que a vitrine do app e o site leem, então aparecem lá com a
capa primeiro (critério 6).

**Fora desta fase:** mexer na rota antiga `/api/fotos-imovel/` (é de outra tarefa), editar ou
recortar a foto no app, legenda, vídeo, envio em segundo plano com o app fechado, fila que
sobrevive a fechar o app, publicar o imóvel pelo app e qualquer regra decidida no aparelho.

</domain>

<decisions>
## Implementation Decisions

### Travadas antes da discussão (D-A..D-C — não perguntar de novo)
- **D-A · Fluxo:** GSD completo (discutir → pesquisar → planejar → executar → verificar). Os comandos
  `/gsd-*` não estão instalados neste ambiente: os artefatos são escritos à mão, no mesmo formato
  das Phases 9, 10 e 12.
- **D-B · Branches:** `feat/APP11` nos dois repos, criadas de `origin/main` (app `c5c3d92`, web
  `5bdd5f1`), **sem upstream**. **Nenhum commit e nenhum push sem aprovação explícita da Palloma**,
  nem os commits de documentação do GSD (diferente da Phase 12).
- **D-C · Número:** Phase 11 (fase N = card APP N).

### Respostas da Palloma na discussão (2026-11-25)
- **D-01 · Rota aninhada:** `/api/imoveis/{id}/fotos/`. A rota antiga `/api/fotos-imovel/`
  (`FotoImovelViewSet`) **não é removida nem alterada**: é de outra tarefa da equipe. O app e os
  testes novos usam só a rota aninhada.
- **D-02 · Reordenar:** uma chamada com a **lista completa de ids**, gravada numa transação,
  devolvendo a lista relida. Lista com id faltando, repetido ou de outro imóvel → **400**.
- **D-03 · Quem pode:** qualquer **corretor da mesma empresa** do imóvel, igual ao acervo
  (`EhCorretor` + imóvel filtrado por `request.user.empresa`). Gestor e administrador ficam de fora
  (403); anônimo 401; imóvel de outra empresa ou inexistente 404 (critério 5).
- **D-04 · Capa:** a **primeira foto** de um imóvel sem fotos vira capa automaticamente. Ao apagar a
  capa, o servidor **promove a próxima pela ordem**. Imóvel com foto tem sempre exatamente uma capa
  gravada no banco.
- **D-05 · Apagar:** fecha o buraco na ordem (renumera `0..n-1`) e apaga o arquivo do disco
  (`imagem.delete(save=False)`, como os documentos), depois do commit da transação.
- **D-06 · Teto:** **30 fotos por imóvel**. A 31ª → 400 com mensagem clara
  ("Este imóvel já tem 30 fotos, o máximo permitido."). O app não conta: mostra a mensagem do
  servidor na foto recusada.
- **D-07 · Redimensionar no app:** lado maior até **1920 px**, **JPEG qualidade 85**, sem aumentar
  foto menor.
- **D-08 · Entrada:** botão **"Fotos"** na tela de gestão do imóvel (APP 09), abrindo uma tela
  própria (`Navigator.push`).
- **D-09 · Correções pedidas:** envio de **uma foto por requisição** (sem gravação parcial),
  **ordem = maior ordem + 1** (não `count()`), **definir capa com `transaction.atomic`**.

### Web — rotas (`feat/APP11`, repo `../imoveis-aqui/Web`)
- **D-10 · Rotas** (nomes finais com o planejador; todas com barra final):
  | Método e rota | Corpo | Resposta |
  |---|---|---|
  | `GET /api/imoveis/{id}/fotos/` | — | 200, lista na ordem do servidor |
  | `POST /api/imoveis/{id}/fotos/` | multipart, **um** arquivo no campo `imagem` | 201, a foto criada |
  | `PUT /api/imoveis/{id}/fotos/ordem/` | `{"ids": [3, 1, 2]}` | 200, lista relida |
  | `POST /api/imoveis/{id}/fotos/{foto_id}/capa/` | — | 200, lista relida |
  | `DELETE /api/imoveis/{id}/fotos/{foto_id}/` | — | 200, lista relida |

  Item da lista e da foto criada: `{"id", "imagem" (URL absoluta), "ordem", "capa"}`. **A lista
  vem ordenada por `ordem, id`** (a ordem que o corretor arrumou; a capa é marcada pelo campo, não
  pela posição). Mais de um arquivo no POST, ou nenhum → 400. Foto de outro imóvel no `foto_id` →
  404.
- **D-11 · Regras num lugar só:** um serviço novo `Web/imoveis/fotos.py` (`adicionar_foto`,
  `reordenar_fotos`, `definir_capa`, `apagar_foto`). Cada função roda em `transaction.atomic` e trava a
  linha do imóvel (`select_for_update`): dois envios ao mesmo tempo não repetem a ordem nem criam
  duas capas, e o teto de 30 não é furado. As views só chamam o serviço. `FotoImovel.definir_como_capa()`
  passa a ser atômico (D-09); é o único ponto onde a rota antiga e o painel do site mudam de
  comportamento, só ficando mais seguros. **Interpretação confirmada pela Palloma em 2026-11-25.**
- **D-12 · Validação do arquivo:** a mesma `validar_imagem` (Pillow, JPEG/PNG/WEBP, 5 MB), chamada
  pelo `full_clean()` do model. Erro → 400 `{"imagem": ["<mensagem em português>"]}`. O teto vai na
  mesma chave. O `DATA_UPLOAD_MAX_MEMORY_SIZE` do Django não muda (o arquivo vai para
  `FILES`, não conta).
- **D-13 · Sem migração:** o model já tem `ordem` e `capa`. Fotos antigas com ordem repetida ou sem
  capa são corrigidas pela primeira reordenação, capa ou exclusão; o GET não grava nada.
- **D-14 · Testes no Django** (`Web/imoveis/tests.py`, ou um `tests_fotos.py` se o planejador
  preferir): isolamento (outra empresa 404 nas 5 rotas, `foto_id` de outro imóvel 404, gestor 403,
  anônimo 401), capa única (a primeira foto vira capa, trocar a capa deixa uma só, apagar a capa
  promove a próxima, apagar a última deixa zero), reordenação (lista certa grava `0..n-1`; faltando,
  repetido, de outro imóvel ou corpo inválido → 400 sem mudar nada), envio (dois arquivos → 400 sem
  gravar, tipo inválido e tamanho → 400, 31ª → 400, ordem = maior + 1 depois de uma exclusão),
  exclusão (renumera e apaga o arquivo do disco), e a leitura pública com a capa primeiro (D-24).
  `MEDIA_ROOT` temporário nos testes que gravam arquivo.

### App — tela de fotos
- **D-15 · Tela:** `FotosImovelScreen`, `AppBar` "Fotos" com o código do imóvel no subtítulo ou no
  título (planejador). Corpo, de cima para baixo: os dois botões de entrada, a fila de envio (se
  houver) e a lista das fotos do servidor.
- **D-16 · Entrada de fotos:** `FilledButton.icon` "Tirar foto" (câmera, uma por vez) e
  `OutlinedButton.icon` "Escolher da galeria" (várias). `image_picker` ^1.2.4,
  `requestFullMetadata: false`. Cancelar o seletor não faz nada. O app **não** limita a quantidade
  escolhida (o teto é do servidor, D-06).
- **D-17 · Redimensionar:** `flutter_image_compress` ^2.5.1 (`minWidth`/`minHeight` 1920, que
  funcionam como lado máximo, mantém a proporção, não aumenta; `format: CompressFormat.jpeg`,
  `quality: 85`, `autoCorrectionAngle: true`, `keepExif: false`). Isso também tira a localização GPS
  da foto antes de ela sair do aparelho. Fica atrás de uma interface na camada de dados
  (`PreparadorDeFoto` ou nome do planejador) para os testes não dependerem do plugin. Falha ao preparar
  → a foto entra na fila já com erro e "Tentar de novo".
- **D-18 · Fila de envio (critério 2):** cada foto escolhida vira um item da fila, com miniatura
  local, barra de progresso (`onSendProgress` do Dio) e um de três estados: enviando, aguardando,
  falhou (texto e "Tentar de novo"). **Uma requisição por foto, uma de cada vez, na ordem da
  escolha.** A ordem no servidor fica igual à da escolha. Uma falha não para a fila: as próximas
  continuam. O item enviado com sucesso sai da fila, e a lista do servidor é relida. Falhas com
  mensagem do servidor (400: tipo, tamanho, teto) mostram essa mensagem achatada
  (`mensagemDeRecusa`). As outras mostram um texto fixo ("Não foi possível enviar."). O item falho
  também tem "Remover" para sair da fila sem reenviar. A fila é só de memória: sair da tela com
  envio pendente pede confirmação ("Sair e cancelar os envios?"), e fechar o app perde a fila.
- **D-19 · Tempo de envio:** o envio usa o `Dio` autenticado com `sendTimeout` próprio por
  requisição (sugestão: 60 s), sem mudar os 10 s das outras rotas. Sem nova tentativa automática:
  um POST que esgotou o tempo pode ter gravado; o "Tentar de novo" é do corretor e, depois dele, a
  lista relida mostra a verdade.
- **D-20 · Reordenar (critério 3):** `ReorderableListView` com miniatura, posição e o selo "Capa".
  Ao soltar, o app manda `PUT …/ordem/` com a lista completa de ids na ordem nova e **não** move o
  item localmente: a lista fica travada (indicador de progresso, arrastar desligado) e mostra a ordem
  do servidor até a resposta, e então mostra a lista devolvida. Recusa → SnackBar e lista relida.
  Reordenar fica desligado enquanto há envio em andamento (evita mandar uma lista sem a foto que
  acabou de entrar, o que daria 400).
  — **Reversibility:** reversible. Se o "pulo" da lista incomodar no UAT, dá para mostrar a ordem
  pedida como prévia esmaecida sem mudar a regra do servidor.
- **D-21 · Capa:** menu por foto (`PopupMenuButton` ou `MenuAnchor`) com "Definir como capa"
  (some na foto que já é capa) → `POST …/capa/` → mostra a lista devolvida. A foto capa tem um
  `Chip`/selo "Capa", lido do campo `capa` do servidor.
- **D-22 · Apagar (critério 4):** "Apagar" no mesmo menu → diálogo "Apagar esta foto?" (com
  "Cancelar" e "Apagar") → `DELETE` → mostra a lista devolvida e o SnackBar "Foto apagada." O app não
  escolhe a nova capa (D-04).
- **D-23 · Estados e falhas:** carga inicial com carregando / erro com "Tentar de novo" / vazio
  ("Este imóvel ainda não tem fotos."). **401 em qualquer chamada** (leitura, envio, ordem, capa,
  apagar) → `voltarAoLoginComSessaoTerminada` (o mesmo helper da APP 09/10/12), e a fila para.
  404 → "Este imóvel não está mais no seu acervo." (texto da gestão). Ao voltar para a gestão, se
  alguma foto mudou, a gestão relê o imóvel (o cabeçalho mostra a capa nova), no mesmo padrão
  `mudou` da APP 09.

### Critério 6 — vitrine e site
- **D-24 · Capa primeiro no site:** a página pública do imóvel no site (`site_publico/views.py`,
  `imovel`) passa a usar o mesmo `Prefetch("fotos", queryset=FotoImovel.objects.order_by("-capa",
  "ordem", "id"))` do detalhe da API pública. Hoje ela usa a ordem padrão, e a capa não vem primeiro
  na galeria do site. É uma linha, com teste. **Aprovado pela Palloma em 2026-11-25:** o `site_publico` é a
  tarefa W10 dela, não de outra frente. A vitrine do app (APP 02/04) já mostra a capa no cartão e primeiro na galeria. As
  fotos só aparecem na vitrine e no site se o imóvel estiver na vitrine (publicado e disponível),
  regra que já existe e não muda.

### Plataformas e permissões
- **D-25 · iOS:** `ios/Runner/Info.plist` ganha `NSCameraUsageDescription` ("Usamos a câmera para
  você fotografar o imóvel e enviar para o anúncio.") e `NSPhotoLibraryUsageDescription` ("Usamos a
  galeria para você escolher fotos do imóvel e enviar para o anúncio."). Sem microfone (não há
  vídeo).
- **D-26 · Android:** o `image_picker` usa o app de câmera do sistema (intenção `IMAGE_CAPTURE`) e o seletor
  de fotos do Android, sem permissão do nosso app. **Não se declara `android.permission.CAMERA`.** Conferido no
  código do `image_picker_android` 0.8.13+25 (11-05): se `CAMERA` estiver declarada, o plugin
  (`ImagePickerUtils.needRequestCameraPermission`) pede a permissão ao corretor antes de abrir a câmera. Seria uma
  pergunta a mais sem ganho (corrige a justificativa anterior, que falava em `SecurityException`). O plugin trata
  câmera ausente com `ActivityNotFoundException` (sem `resolveActivity`), então **não precisa de `<queries>`** para
  `IMAGE_CAPTURE`. Nenhum plugin novo declara `CAMERA` no manifesto dele. O manifesto do app ganhou só o comentário.
  **Aprovado pela Palloma em 2026-11-25** (sem `CAMERA`, com comentário; no iOS as duas chaves).
- **D-27 · App morto pelo Android:** com pouca memória o Android pode matar a activity durante a
  câmera. `retrieveLostData()` fica **fora desta fase** (a foto se perde e o corretor tira de novo). O
  roteiro de UAT anota isso. Ver Deferred.

### Contrato, fixtures e UAT
- **D-28 · Contrato:** `01-CONTRATO-API.md` ganha o **§19 "Fotos do imóvel (Fase 11)"**: as 5 rotas,
  campos do item, multipart (`imagem`, um arquivo), 400 (tipo, tamanho, teto, nenhum ou vários
  arquivos, lista de ordem inválida), 401, 403, 404, capa única e promoção, ordem `0..n-1`, URL
  absoluta da imagem, e que a leitura pública põe a capa primeiro.
- **D-29 · Fixtures:** grupo novo **`fotos`** em `tool/capturar_fixtures_api.py` (porta sugerida
  8011, na linha da 8012 da Phase 12), capturado da API real: lista vazia, envio 201 (com imagens
  geradas pelo Pillow ou bytes fixos dentro do script), lista com 3, ordem 200, ordem 400, capa 200,
  apagar 200 (com a capa promovida), 400 de tipo, 400 de tamanho, 400 de teto, 404 de outra empresa,
  403 do gestor e 401. O script limpa as fotos que criou no fim. Testes de contrato no app
  (`contrato_fotos_imovel_test.dart`) leem todas as fixtures nos Models.
- **D-30 · Requisitos:** IDs novos no `REQUIREMENTS.md`: **FOT-01..FOT-06** (um por critério),
  **API-17** (rotas da web com testes) e **API-18** (§19 + fixtures + testes de contrato).
- **D-31 · UAT:** roteiro no emulador Android (`11-UAT.md`) com o **e-mail** de cada conta escrito
  no passo que pede login (feedback da APP 10) e a **origem da senha** indicada, **nunca a senha em
  arquivo** (regra do README; ajustado pela Palloma em 2026-11-26): corretor da empresa da vitrine
  (`corretor.vitrine.demo@example.com`, senha definida na hora por `SENHA_DEV_CORRETOR`); contas da
  outra empresa com a senha da saída do `seed_demo`;
  imóvel publicado e disponível de Campinas, câmera do emulador (cena virtual) e galeria (imagens
  copiadas com `adb push` + scan de mídia). Passos: tirar foto, escolher 3 da galeria, ver o progresso,
  forçar uma falha (ex.: derrubar o `runserver` no meio) e usar "Tentar de novo", reordenar, definir
  capa, apagar, e conferir **na vitrine do app e no site** a ordem e a capa primeiro. Um passo de
  isolamento usa um imóvel de outra empresa pela API (curl com token) → 404.

### Regras do projeto (carregadas das fases anteriores)
- **D-32 [informational]:** Clean Architecture (data/domain/presentation), Cubit com estado
  freezed, `Result` e falhas tipadas na camada de dados, sem `try/catch` na UI, Material 3 verde e
  branco (cores só do `ColorScheme`, texto do `textTheme`), código e comentários em português,
  `Navigator.push` + `MaterialPageRoute`, telas aceitando `criarCubit` para testes de widget, o
  localizador de serviços só no abridor da tela.
- **D-33 [informational]:** `flutter analyze` limpo (fora as infos antigas de `deprecated_member_use`)
  e `flutter test` verde rodados à mão a cada onda. `python manage.py test` no Django a cada plano
  web. Arquivos gerados reescritos só com CRLF pelo `build_runner` voltam com `git checkout --`.
  **O Flutter local é 3.47.5 e o lock da `main` foi resolvido com o 3.50.1**: adicionar
  `image_picker` e `flutter_image_compress` com o 3.47.5 vai mexer em versões indiretas do
  `pubspec.lock`. O planejador trata isso no primeiro plano do app (ver nota no fim).

### Claude's Discretion
- Nomes de classes, arquivos, rotas finais e estados. Sugestão: `lib/presentation/fotos_imovel/`
  (`FotosImovelScreen`, `FotosImovelCubit` com a lista do servidor e a fila no mesmo estado, ou dois
  Cubits), `widgets/fila_envio.dart`, `widgets/lista_fotos.dart`; entidades `FotoImovel` e
  `EnvioDeFoto`; `FotosImovelRepository`, use cases (`ListarFotosUseCase`, `EnviarFotoUseCase`,
  `ReordenarFotosUseCase`, `DefinirCapaUseCase`, `ApagarFotoUseCase`);
  `FotosImovelRemoteDataSource` no `Dio` autenticado; `SeletorDeFotos` (image_picker) e
  `PreparadorDeFoto` (compressão) atrás de interfaces.
- Na web: `@action`s no `ImovelViewSet` ou views próprias em `imoveis/api/urls.py`, desde que
  respeitem D-03 e D-10.
- Visual (miniatura, espaçamentos, ícones). Só cores do `ColorScheme`. Confirmado no human-check.
- **UI-SPEC:** as decisões D-15 a D-23 servem de contrato de UI, como nas Phases 8, 10 e 12.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Card e escopo
- `.planning/phases/11-fotos-do-im-vel-pela-c-mera-app-11/11-CARD-APP11.md` — card, levantamento da web, causa do `pubspec.lock`.
- `.planning/ROADMAP.md` § "Phase 11", `.planning/REQUIREMENTS.md`, `.planning/PROJECT.md`.

### Contrato da API
- `.planning/phases/01-localiza-o-escolha-de-cidade-e-contrato-da-api/01-CONTRATO-API.md` §14 (login, `Dio` autenticado, 401), §16 (rotas do imóvel do corretor), §18 (último número usado; modelo de seção) — o §19 novo segue o mesmo formato.

### Decisões das fases anteriores
- `.planning/phases/08-login-e-rea-do-corretor-o-acervo/08-CONTEXT.md` — sessão, 401, `Dio` autenticado, textos fixos.
- `.planning/phases/09-mudan-a-de-situa-o-do-im-vel-pelo-app-app-09/09-CONTEXT.md` — tela de gestão, abridor dono do Cubit, `mudou`, recusa do servidor com `mensagemDeRecusa`.
- `.planning/phases/12-area-do-gestor-acompanhamento-dos-corretores/12-CONTEXT.md` — formato de fixtures e testes de contrato.

### Web (`../imoveis-aqui/Web`, branch `feat/APP11` = `origin/main` 5bdd5f1)
- `Web/imoveis/models.py:256` — `FotoImovel`, `uma_capa_por_imovel`, `definir_como_capa`.
- `Web/core/validators.py` — `validar_imagem`, `TAMANHO_MAXIMO_IMAGEM_MB`, `FORMATOS_DE_IMAGEM_PERMITIDOS`.
- `Web/imoveis/api/views.py` — `ImovelViewSet` (escopo de empresa, `EhCorretor`), `FotoImovelViewSet` (rota antiga, **não mexer**), `DocumentoImovelViewSet` (apaga arquivo do disco), Prefetch da capa primeiro (linha ~493).
- `Web/imoveis/api/serializers.py` — `FotoImovelSerializer`, `FotoPublicaSerializer`, `FotoCapaMixin`.
- `Web/imoveis/api/urls.py` — router onde entram as rotas novas.
- `Web/core/mixins.py`, `Web/core/permissions.py` — `EmpresaScopedQuerySetMixin`, `EhCorretor`.
- `Web/site_publico/views.py:110` — página do imóvel no site (D-24).
- `Web/imoveis/tests.py` — testes atuais de foto (linhas ~240, 326, 416–445, 2545, 3751).

### App (este repo)
- `lib/presentation/gestao_imovel/gestao_imovel_screen.dart` + `gestao_imovel_cubit.dart` — onde entra o botão "Fotos" e o `mudou`.
- `lib/data/datasources/gestao_imovel_remote_datasource.dart` + `lib/data/repositories/gestao_imovel_repository_impl.dart` — modelo de DataSource no `Dio` autenticado e tradução de 400/401/403/404.
- `lib/data/network/mensagem_de_recusa.dart`, `interceptador_sessao.dart` — mensagem do servidor e 401.
- `lib/presentation/sessao/sessao_expirada.dart` (`voltarAoLoginComSessaoTerminada`).
- `lib/di/modulo_rede.dart` — `Dio` `@Named('autenticado')`, timeouts de 10 s.
- `test/support/api_falsa.dart`, `pilha_real.dart` — e2e com a API falsa.
- `tool/capturar_fixtures_api.py` — `GRUPOS`, `_entrar`, `capturar_gestor` como modelo.
- `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `abrirGestaoImovel` / `GestaoImovelCubit.mudou`: o mesmo padrão de "abridor dono do Cubit" serve para `abrirFotosImovel`, e o `mudou` da gestão relê o cabeçalho na volta.
- `mensagemDeRecusa`: achata a mensagem 400 do Django (`{"imagem": [...]}`, `{"ids": [...]}`).
- `voltarAoLoginComSessaoTerminada` + `SessaoExpiradaException` do interceptador.
- `ImagemRede` / `cached_network_image` para as miniaturas do servidor.
- `CabecalhoGestao` já mostra a foto de capa.

### Established Patterns
- DataSource fino que não captura `DioException`, repositório com cadeia única de tradução, Model freezed lido contra fixtures reais, Cubit com estado freezed e `switch` exaustivo, DI por `injectable`.
- Web: regra no model ou num serviço, view fina, isolamento pelo queryset (404), testes com `APIClient` e token.

### Integration Points
- `gestao_imovel_screen.dart`: botão "Fotos" quando o imóvel carregou.
- `lib/di/`: DataSource, Repository, UseCases, Cubit, `SeletorDeFotos`, `PreparadorDeFoto`.
- `pubspec.yaml`: `image_picker`, `flutter_image_compress`.
- Web: `imoveis/fotos.py` (novo), `imoveis/api/views.py`, `imoveis/api/urls.py`, `imoveis/models.py` (`definir_como_capa` atômico), `site_publico/views.py` (D-24), testes, README da API.

</code_context>

<specifics>
## Specific Ideas

- A história fala de "publicar o anúncio no mesmo dia": o fluxo precisa funcionar com a internet
  móvel da visita. Por isso há compressão antes do envio, uma requisição por foto e "Tentar de novo"
  por foto.
- Na UAT a Palloma confere as fotos na vitrine do app e no site, na ordem certa e com a capa primeiro.

</specifics>

<deferred>
## Deferred Ideas

- **Recuperar a foto quando o Android mata o app durante a câmera** (`retrieveLostData`), D-27.
- **Fila persistente / envio em segundo plano** com o app fechado.
- **Envio em paralelo** (2–3 fotos ao mesmo tempo): a ordem no servidor deixaria de seguir a escolha.
- **Legenda da foto, recorte e rotação no app.**
- **Ajustar a rota antiga `/api/fotos-imovel/` e o painel do site** para usarem o serviço novo
  (capa automática, renumeração, arquivo apagado): é de outra tarefa. O serviço fica pronto para eles
  usarem.
- **Miniatura da capa no painel do site** (`imoveis/imovel_list.html` usa `fotos.all|first`, não a capa).
- **Gestor gerenciando fotos** pelo app.

</deferred>

---

## Nota para o planejador — `pubspec.lock` e Flutter 3.47.5

O `pub add` com o Flutter 3.47.5 vai descer `test`/`analyzer`/`freezed` no lock (ver card). Opções:
(a) **escolhida em 2026-11-25: a Palloma está atualizando para o Flutter 3.50.1 e avisa antes do 11-05** (recomendado: mesma
versão da equipe); (b) gerar o lock e conferir que só entram `image_picker`, `flutter_image_compress`
e as dependências deles, revertendo o resto à mão. O primeiro plano do app começa conferindo
`flutter --version` e para se ainda for 3.47.5 sem decisão.

*Phase: 11-fotos-do-im-vel-pela-c-mera-app-11*
*Context gathered: 2026-11-25*
