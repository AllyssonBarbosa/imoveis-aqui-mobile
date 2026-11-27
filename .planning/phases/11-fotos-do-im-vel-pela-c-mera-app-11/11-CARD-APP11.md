# Card APP 11 · Fotos do imóvel pela câmera (tarefa A11)

Fonte: texto oficial do card, enviado pela Palloma em 2026-11-25. Usado como PRD da Phase 11
(fase N = card APP N).

## História (texto do card, sem alteração)

Como corretor, eu quero fotografar o imóvel na visita e enviar dali mesmo para publicar o anúncio no
mesmo dia.

## Critérios de aceite (texto do card, sem alteração)

1. Tirar foto pela câmera ou escolher da galeria do aparelho
2. Enviar várias fotos de uma vez, com progresso e aviso de erro
3. Reordenar as fotos e escolher a foto de capa
4. Apagar foto enviada por engano
5. Só funciona nos imóveis a que o corretor tem acesso (os dele e os da imobiliária)
6. As fotos enviadas aparecem na vitrine e no site

## Pontos de partida (levantamento de 2026-11-25)

- **APP 09 já está na `main` dos dois repos.** App: `origin/main` = `c5c3d92` (APP 09, 10 e 12).
  Web (`../imoveis-aqui`, pasta `Web`): `origin/main` = `5bdd5f1` (APP 09, 10, 12 e WEB-12).
- **Branches:** `feat/APP11` criada de `origin/main` nos dois repos, **sem upstream** (o
  `git switch -c … origin/main` deixava a branch rastreando a `main`; o upstream foi removido para
  um `git push` futuro não mirar na `main`). A WEB-12 estava limpa e igual à remota antes da troca.
- **App, árvore local:** as mudanças locais (`pubspec.lock` voltando de versão e ~70 arquivos
  gerados) foram descartadas com `git restore .` com autorização. Causa: o lock da `main` foi
  resolvido com o Flutter 3.50.1 (commit `fbf0de8`), e o `flutter_test` do Flutter 3.47.5 fixa
  `test_api 0.7.12`, o que obriga o `pub get` a descer `test`, `analyzer` (14.1 → 13.3) e
  `freezed` (4.0.3 → 4.0.1). Solução: a equipe usar o mesmo Flutter (3.50.1).

## O que a web já tem (`origin/main` 5bdd5f1)

- **Model `FotoImovel`** (`Web/imoveis/models.py:256`): `imovel` (FK, `related_name="fotos"`),
  `imagem` (`ImageField`, `upload_to="imoveis/fotos/"`, `validators=[validar_imagem]`), `ordem`
  (`PositiveIntegerField`, padrão 0), `capa` (bool). `ordering = ["ordem", "id"]`. Regra no banco
  `uma_capa_por_imovel` (`UniqueConstraint` com `condition=Q(capa=True)`). `definir_como_capa()`
  desmarca a capa atual e marca a nova **sem** `transaction.atomic`.
- **Validação** (`Web/core/validators.py`): `validar_imagem` abre o arquivo com o Pillow (não confia
  no content-type): JPEG, PNG ou WEBP (`FORMATOS_DE_IMAGEM_PERMITIDOS`), até 5 MB
  (`TAMANHO_MAXIMO_IMAGEM_MB`).
- **Rota antiga `/api/fotos-imovel/`** (`FotoImovelViewSet`, `EhCorretor`, filtro
  `imovel__empresa`): várias imagens por requisição com gravação parcial, `ordem = count()`, sem
  reordenação, `PATCH` que troca a imagem, `DELETE` que deixa o arquivo no disco e o buraco na
  ordem. **É de outra tarefa da equipe e fica como está** (decisão da Palloma).
- **Painel do site** (`Web/imoveis/views.py`: `imovel_upload_fotos`, `imovel_definir_capa`,
  `imovel_excluir_foto`): mesmos problemas de ordem e de arquivo; também de outra frente.
- **Leitura pública:** o detalhe da API pública (`imoveis/api/views.py:493`) usa
  `Prefetch("fotos", order_by("-capa", "ordem", "id"))` → capa primeiro. O `foto_capa` do cartão
  (`FotoCapaMixin`) usa a capa marcada, senão a primeira. **A página do imóvel no site**
  (`site_publico/views.py:116`) faz `prefetch_related("fotos")` com a ordem padrão
  (`ordem, id`): a capa **não** vem primeiro na galeria do site (ver D-24 do CONTEXT). O `site_publico`
  é a tarefa W10 da Palloma.
