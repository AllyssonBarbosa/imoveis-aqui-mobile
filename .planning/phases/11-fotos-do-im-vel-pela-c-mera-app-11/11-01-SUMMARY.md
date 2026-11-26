---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
plan: 01
subsystem: web (Django/DRF)
tags: [fotos, upload, multitenant, transacao]
requires: []
provides:
  - "Rotas GET/POST /api/imoveis/<id>/fotos/, PUT .../fotos/ordem/, POST .../fotos/<foto_id>/capa/, DELETE .../fotos/<foto_id>/"
  - "Serviço Web/imoveis/fotos.py (LIMITE_FOTOS_POR_IMOVEL=30, adicionar_foto, reordenar_fotos, definir_capa, apagar_foto, fotos_do_imovel)"
affects: [11-02, 11-03]
key-files:
  created:
    - "C:/Users/Palloma/Documents/imoveis-aqui/Web/imoveis/fotos.py"
    - "C:/Users/Palloma/Documents/imoveis-aqui/Web/imoveis/tests_fotos.py"
  modified:
    - "C:/Users/Palloma/Documents/imoveis-aqui/Web/imoveis/models.py"
    - "C:/Users/Palloma/Documents/imoveis-aqui/Web/imoveis/api/views.py"
    - "C:/Users/Palloma/Documents/imoveis-aqui/Web/imoveis/api/serializers.py"
    - "C:/Users/Palloma/Documents/imoveis-aqui/README.md"
requirements-completed: []  # API-17 só é marcado Complete depois do human-check (11-09)
completed: 2026-11-25
---

# 11-01 — Rotas de fotos aninhadas no imóvel (web)

## O que foi feito
- **Serviço `imoveis/fotos.py`:** cada função roda em `transaction.atomic` e trava a linha do imóvel
  (`select_for_update`).
  - `adicionar_foto`: teto de 30 (`{"imagem": ["Este imóvel já tem 30 fotos, o máximo permitido."]}`),
    ordem = maior + 1 (0 sem fotos), capa se o imóvel não tem capa, `full_clean()` antes de gravar.
  - `reordenar_fotos`: `ids` precisa ser lista de inteiros (bool não vale) com exatamente as fotos do
    imóvel, sem repetição. Senão `{"ids": [...]}` e nada muda.
  - `definir_capa`: trava o imóvel e chama `definir_como_capa()`.
  - `apagar_foto`: apaga, renumera `0..n-1`, promove a primeira restante se o imóvel ficou sem capa, e
    apaga o arquivo em `transaction.on_commit`.
- **`FotoImovel.definir_como_capa()`** dentro de `transaction.atomic` (é a única mudança que alcança a
  rota antiga e o painel do site; interpretação confirmada pela Palloma).
- **Rotas** como `@action`s do `ImovelViewSet` (escopo de empresa pelo mixin e `EhCorretor`), nomes
  `imovel-fotos`, `imovel-fotos-ordem`, `imovel-fotos-capa`, `imovel-foto`. Respostas com o novo
  `FotoDoImovelSerializer` (`id`, `imagem` absoluta, `ordem`, `capa`). POST com 0 ou ≥2 arquivos →
  `{"imagem": ["Envie exatamente uma imagem por requisição."]}`.
- **README** com as 5 rotas e as regras; as linhas da rota antiga marcadas como "rota antiga (outra tarefa)".

## Desvios do plano
- **Capa automática generalizada:** o plano dizia "capa se é a primeira foto" e "promove ao apagar a
  capa". Implementado como "capa se o imóvel não tem capa" e "promove se o imóvel ficou sem capa".
  Cobre os mesmos casos e também corrige fotos antigas sem capa (D-04: imóvel com foto tem sempre
  uma capa). Teste `test_imovel_com_fotos_sem_capa_ganha_capa_na_proxima_foto`.
- Testes num arquivo novo `imoveis/tests_fotos.py` (o plano deixava a escolha), reaproveitando os
  helpers e o `MediaTemporariaMixin` de `imoveis/tests.py`.

## Verificação
- `python manage.py test imoveis.tests_fotos`: **29 testes OK** (12 do serviço, 17 das rotas: token,
  colega da mesma empresa, outra empresa 404 nas 5 rotas sem mudar nada, imóvel inexistente 404,
  foto de outro imóvel 404, gestor e administrador 403, anônimo 401, 201 com URL absoluta, 0/2
  arquivos, tipo, tamanho, teto, ordem da lista, reordenar ok/inválido, capa, apagar a capa com
  promoção, renumeração e arquivo apagado, rota antiga respondendo).
- **Mutação:** com `ordem = count()` e `capa=False` no serviço, 5 testes falham. O serviço foi restaurado.
- `python manage.py test` inteiro: **832 testes OK**. `check` limpo e `makemigrations --check`
  sem mudanças (sem migração).
- `git diff` de `views.py`: só imports e as actions novas no `ImovelViewSet`; `FotoImovelViewSet`
  intocado.
- Nenhum commit, nenhum push.
