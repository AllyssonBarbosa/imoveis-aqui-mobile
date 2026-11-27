---
phase: 11-fotos-do-im-vel-pela-c-mera-app-11
plan: 02
subsystem: web (site público W10 + API)
tags: [fotos, vitrine, site, capa]
requires: ["11-01"]
provides:
  - "Galeria da página do imóvel no site com a capa primeiro (mesma sequência do detalhe da API pública)"
  - "Prova no Django de que ordem e capa gravadas pelas rotas aninhadas aparecem iguais na vitrine e no site"
key-files:
  modified:
    - "C:/Users/Palloma/Documents/imoveis-aqui/Web/site_publico/views.py"
    - "C:/Users/Palloma/Documents/imoveis-aqui/Web/site_publico/tests.py"
    - "C:/Users/Palloma/Documents/imoveis-aqui/Web/imoveis/tests_fotos.py"
requirements-completed: []  # FOT-06 só fecha no human-check do 11-09 (vitrine do app + site no emulador)
completed: 2026-11-25
---

# 11-02 — Capa primeiro no site e critério 6 provado no servidor

## O que foi feito
- **Gate (Task 0):** já resolvido. A Palloma liberou mexer no `site_publico` (é a tarefa W10 dela).
- **`site_publico/views.py` (`imovel`):** o `prefetch_related("fotos")` virou
  `Prefetch("fotos", queryset=FotoImovel.objects.order_by("-capa", "ordem", "id"))`, igual ao detalhe
  da API pública. O template não muda: ele já usa a primeira foto como foto grande.
- **Teste do site** (`PaginaImovelTests.test_galeria_comeca_pela_capa_e_segue_a_ordem_como_a_api`):
  a casa do cenário tem a capa na foto de ordem 1. O teste confere a sequência do contexto, a foto
  grande (`data-galeria-principal`), as miniaturas (`data-galeria-foto`) e a igualdade com
  `GET /api/publico/imoveis/<id>/`. **Falhou antes da correção** (a galeria começava pela foto de
  ordem 0) e passou depois.
- **Ponta a ponta** (`imoveis/tests_fotos.py`, `FotosNaVitrineTests` sobre o `VitrineBase`): o corretor
  envia 3 fotos pela rota aninhada, reordena para [c, a, b] e define `b` como capa. Detalhe público,
  galeria do site = [b, c, a] e `foto_capa` do cartão da busca = b. Depois de apagar `b`, `c` é
  promovida e as três leituras passam a começar por `c`.

## Desvios do plano
- Nenhum. O teste do site também compara direto com a API pública, uma checagem a mais do que o plano pedia.

## Verificação
- `python manage.py test site_publico`: 28 OK. `python manage.py test imoveis.tests_fotos`: 31 OK.
- `python manage.py test` inteiro: **835 OK**. `check` limpo.
- Sem commit (aguardando aprovação da Palloma) e sem push.
